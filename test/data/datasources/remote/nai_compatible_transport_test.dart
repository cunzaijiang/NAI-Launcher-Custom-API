import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nai_launcher/core/enums/precise_ref_type.dart';
import 'package:nai_launcher/core/network/critical_network_activity.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint_service.dart';
import 'package:nai_launcher/core/network/nai_chat_image_codec.dart';
import 'package:nai_launcher/core/network/nai_compatible_request.dart';
import 'package:nai_launcher/core/network/request_builders/nai_image_request_builder.dart';
import 'package:nai_launcher/data/datasources/remote/nai_generation_transport.dart';
import 'package:nai_launcher/data/datasources/remote/nai_image_enhancement_api_service.dart';
import 'package:nai_launcher/data/datasources/remote/nai_image_generation_api_service.dart';
import 'package:nai_launcher/data/models/image/image_params.dart';
import 'package:nai_launcher/data/models/vibe/vibe_reference.dart';
import 'package:nai_launcher/data/services/metadata/unified_metadata_parser.dart';

void main() {
  late Dio dio;
  late _RecordingAdapter adapter;
  late NaiApiEndpointService endpoints;
  late NaiGenerationTransport transport;
  late NAIImageGenerationApiService service;
  late CriticalNetworkActivityCoordinator activity;

  setUp(() {
    adapter = _RecordingAdapter();
    dio = Dio()..httpClientAdapter = adapter;
    endpoints = NaiApiEndpointService()
      ..setCurrent(
        NaiApiEndpointConfig.fromInput(
          mainBaseUrl: 'https://compatible.invalid',
          protocol: NaiApiProtocol.openAiCompatible,
        ),
      );
    transport = NaiGenerationTransport(dio, endpoints);
    activity = CriticalNetworkActivityCoordinator();
    service = NAIImageGenerationApiService(
      dio,
      NAIImageEnhancementApiService(dio, endpoints),
      endpoints,
      activity,
    );
  });
  tearDown(() => dio.close(force: true));

  test(
    'all five models post only Chat with serialized drawing parameters',
    () async {
      for (final model in NaiCompatibleRequest.generationModels) {
        final images = await service.generateImage(
          ImageParams(
            model: model,
            prompt: 'landscape',
            negativePrompt: 'bad',
            seed: 42,
          ),
        );
        final outer = adapter.jsonBodies.last;
        final draw = _draw(outer);
        expect(outer['model'], model);
        expect(outer['stream'], false);
        expect((outer['messages'] as List).single['role'], 'user');
        expect(draw['prompt'], contains('landscape'));
        expect(draw['negative_prompt'], contains('bad'));
        expect(draw['quality'], false);
        expect(draw['uc_preset'], 'none');
        expect(draw['size'], [832, 1216]);
        expect(draw['seed'], 42);
        expect(draw['n_samples'], 1);
        expect(draw['image_format'], 'png');
        expect(draw.containsKey('parameters'), false);
        expect(draw.containsKey('stream'), false);
        expect(images.$1, hasLength(1));
        final metadata = UnifiedMetadataParser.parseFromPng(
          images.$1.single,
        ).metadata!;
        expect(metadata.seed, 42);
        expect(metadata.width, 64);
        expect(metadata.height, 64);
        expect(activity.isActive, false);
      }
      expect(adapter.requests, hasLength(5));
      for (final request in adapter.requests) {
        expect(request.method, 'POST');
        expect(request.path, 'https://compatible.invalid/v1/chat/completions');
        expect(request.contentType, Headers.jsonContentType);
        expect(request.responseType, ResponseType.plain);
      }
    },
  );

  test(
    'UI stream yields exactly one final chunk and no SSE/native request',
    () async {
      final chunks = await service
          .generateImageStream(
            const ImageParams(prompt: 'stream facade', seed: 42),
          )
          .toList();
      expect(chunks, hasLength(1));
      expect(chunks.single.isComplete, true);
      expect(chunks.single.finalImage, isNotNull);
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.path, endsWith('/v1/chat/completions'));
      expect(adapter.jsonBodies.single['stream'], false);
      expect(activity.isActive, false);
    },
  );

  test(
    'img2img shares source normalization and carries strength/noise',
    () async {
      await service.generateImage(
        ImageParams(
          model: 'nai-diffusion-4-5-full',
          prompt: 'edit',
          seed: 42,
          action: ImageGenerationAction.img2img,
          sourceImage: _png(80, 96),
          width: 64,
          height: 64,
          strength: 0.45,
          noise: 0.15,
        ),
      );
      final draw = _draw(adapter.jsonBodies.single);
      _expectOnlyChatFields(draw);
      final i2i = draw['i2i'] as Map;
      expect(i2i.keys, unorderedEquals(['image', 'strength', 'noise', 'seed']));
      final source = img.decodePng(base64Decode(i2i['image'] as String))!;
      expect((source.width, source.height), (64, 64));
      expect(i2i['strength'], 0.45);
      expect(i2i['noise'], 0.15);
      expect(i2i['seed'], 41);
      expect(draw.containsKey('inpaint'), false);
    },
  );

  test(
    'inpaint normalizes mask and composites unmasked source pixels',
    () async {
      adapter.response = _chatResponse(_png(256, 256));
      final source = img.Image(width: 256, height: 256)
        ..clear(img.ColorRgb8(210, 0, 0));
      final mask = img.Image(width: 256, height: 256)
        ..clear(img.ColorRgb8(0, 0, 0));
      img.fillRect(
        mask,
        x1: 112,
        y1: 112,
        x2: 143,
        y2: 143,
        color: img.ColorRgb8(255, 255, 255),
      );
      final images = await service.generateImage(
        ImageParams(
          model: 'nai-diffusion-4-5-full-inpainting',
          prompt: 'edit',
          seed: 42,
          action: ImageGenerationAction.infill,
          sourceImage: Uint8List.fromList(img.encodePng(source)),
          maskImage: Uint8List.fromList(img.encodePng(mask)),
          inpaintStrength: 0.35,
          strength: 0.8,
          noise: 0.2,
          width: 256,
          height: 256,
        ),
      );
      final outer = adapter.jsonBodies.single;
      expect(outer['model'], 'nai-diffusion-4-5-full');
      final draw = _draw(outer);
      _expectOnlyChatFields(draw);
      final inpaint = draw['inpaint'] as Map;
      expect(
        inpaint.keys,
        unorderedEquals(['image', 'mask', 'strength', 'seed']),
      );
      expect(inpaint['image'], isA<String>());
      expect(inpaint['mask'], isA<String>());
      expect(inpaint['strength'], 0.35);
      expect(inpaint['seed'], 41);
      expect(draw.containsKey('i2i'), false);
      final output = img.decodePng(images.$1.single)!;
      expect(output.getPixel(0, 0).r, 210);
      expect(output.getPixel(128, 128).b, 240);
      expect(
        UnifiedMetadataParser.parseFromPng(images.$1.single).metadata?.seed,
        42,
      );
    },
  );

  test(
    'focused inpaint keeps original canvas and metadata after composition',
    () async {
      final source = img.Image(width: 128, height: 128)
        ..clear(img.ColorRgb8(210, 0, 0));
      final mask = img.Image(width: 128, height: 128)
        ..clear(img.ColorRgb8(0, 0, 0));
      img.fillRect(
        mask,
        x1: 48,
        y1: 48,
        x2: 80,
        y2: 80,
        color: img.ColorRgb8(255, 255, 255),
      );
      final result = await service.generateImage(
        ImageParams(
          model: 'nai-diffusion-4-5-full',
          prompt: 'focused',
          seed: 42,
          width: 128,
          height: 128,
          action: ImageGenerationAction.infill,
          sourceImage: Uint8List.fromList(img.encodePng(source)),
          maskImage: Uint8List.fromList(img.encodePng(mask)),
        ),
        focusedInpaintEnabled: true,
        minimumContextMegaPixels: 0.004096,
        focusedContextCrop: const Rect.fromLTWH(32, 32, 64, 64),
      );
      final output = img.decodePng(result.$1.single)!;
      expect((output.width, output.height), (128, 128));
      expect(output.getPixel(0, 0).r, 210);
      final metadata = UnifiedMetadataParser.parseFromPng(
        result.$1.single,
      ).metadata!;
      expect(metadata.seed, 42);
      expect((metadata.width, metadata.height), (128, 128));
      expect(adapter.requests, hasLength(1));
    },
  );

  test(
    'raw Vibe draws without any encode endpoint and preserves controls',
    () async {
      await service.generateImage(
        ImageParams(
          model: 'nai-diffusion-4-5-full',
          prompt: 'reference',
          seed: 42,
          vibeReferencesV4: [
            VibeReference(
              displayName: 'raw',
              vibeEncoding: 'opaque-native',
              rawImageData: _png(8, 8),
              strength: 0.6,
              infoExtracted: 0.35,
            ),
          ],
        ),
      );
      final draw = _draw(adapter.jsonBodies.single);
      _expectOnlyChatFields(draw);
      final controlnet = draw['controlnet'] as Map;
      expect(controlnet.keys, unorderedEquals(['strength', 'images']));
      expect(controlnet['strength'], 1.0);
      final refs = controlnet['images'] as List;
      expect(
        refs.single.keys,
        unorderedEquals(['image', 'info_extracted', 'strength']),
      );
      expect(refs.single['strength'], 0.6);
      expect(refs.single['info_extracted'], 0.35);
      expect(
        img.decodePng(base64Decode(refs.single['image'] as String)),
        isNotNull,
      );
      expect(adapter.requests.single.path, endsWith('/chat/completions'));
    },
  );

  test('AI character placement explicitly disables use_coords', () async {
    await service.generateImage(
      const ImageParams(
        model: 'nai-diffusion-4-5-full',
        characters: [CharacterPrompt(prompt: 'girl')],
        useCoords: false,
      ),
    );
    final draw = _draw(adapter.jsonBodies.single);
    _expectOnlyChatFields(draw);
    expect(draw['use_coords'], false);
    expect(draw['characters'], [
      {'prompt': 'girl', 'negative_prompt': ''},
    ]);
  });

  test(
    'unsupported Chat alpha controls fail before source preparation',
    () async {
      for (final params in [
        ImageParams(
          transparentBackground: true,
          action: ImageGenerationAction.img2img,
          sourceImage: Uint8List(0),
        ),
        const ImageParams(straightAlpha: false),
      ]) {
        await expectLater(
          service.generateImage(params),
          throwsA(isA<UnsupportedError>()),
        );
      }
      expect(adapter.requests, isEmpty);
      expect(activity.isActive, false);
    },
  );

  test('encoded-only Vibe fails explicitly before network', () async {
    await expectLater(
      service.generateImage(
        const ImageParams(
          model: 'nai-diffusion-4-5-full',
          vibeReferencesV4: [
            VibeReference(displayName: 'encoded', vibeEncoding: 'AQID'),
          ],
        ),
      ),
      throwsA(isA<UnsupportedError>()),
    );
    expect(adapter.requests, isEmpty);
    expect(activity.isActive, false);
  });

  test(
    'precise reference and characters use Chat fields, never native arrays',
    () async {
      await service.generateImage(
        ImageParams(
          model: 'nai-diffusion-4-5-full',
          seed: 42,
          useCoords: true,
          preciseReferences: [
            PreciseReference(
              image: _png(8, 8),
              type: PreciseRefType.characterAndStyle,
              strength: 0.4,
              fidelity: 0.75,
            ),
          ],
          characters: [
            const CharacterPrompt(
              prompt: 'red hair',
              negativePrompt: 'hat',
              positionX: 0.5,
              positionY: 0.9,
            ),
          ],
        ),
      );
      final draw = _draw(adapter.jsonBodies.single);
      _expectOnlyChatFields(draw);
      expect(draw['use_coords'], true);
      final reference = (draw['character_references'] as List).single;
      expect(
        reference.keys,
        unorderedEquals(['image', 'type', 'fidelity', 'strength']),
      );
      expect(reference['type'], 'character&style');
      expect(reference['strength'], 0.4);
      expect(reference['fidelity'], 0.75);
      final referenceImage = img.decodePng(
        base64Decode(reference['image'] as String),
      )!;
      expect((referenceImage.width, referenceImage.height), (8, 8));
      expect(draw['characters'], [
        {'prompt': 'red hair', 'negative_prompt': 'hat', 'position': 'C5'},
      ]);
      expect(draw.containsKey('director_reference_images'), false);
    },
  );

  test(
    'HTTP 200 errors and malformed/non-inline responses fail without fallback',
    () async {
      for (final body in [
        jsonEncode({
          'error': {
            'message': 'Invalid draw',
            'code': 'invalid_image',
            'param': 'image',
          },
        }),
        '{bad JSON',
        jsonEncode({
          'choices': [
            {
              'message': {'content': '![image](https://other.invalid/a.png)'},
            },
          ],
        }),
        jsonEncode({
          'choices': [
            {
              'message': {'content': '![image](data:image/png;base64,AQID)'},
            },
          ],
        }),
      ]) {
        adapter.response = Uint8List.fromList(utf8.encode(body));
        final count = adapter.requests.length;
        await expectLater(
          service.generateImage(const ImageParams()),
          throwsA(anything),
        );
        expect(adapter.requests.length, count + 1);
        expect(activity.isActive, false);
      }
      adapter.response = Uint8List.fromList(
        utf8.encode(
          jsonEncode({
            'error': {
              'message': 'Invalid draw',
              'code': 'invalid_image',
              'param': 'image',
            },
          }),
        ),
      );
      final chunk =
          (await service.generateImageStream(const ImageParams()).toList())
              .single;
      expect(
        chunk.error,
        allOf(
          contains('Invalid draw'),
          contains('code=invalid_image'),
          contains('param=image'),
        ),
      );
    },
  );

  test('lease cancellation terminates Chat request and releases QoS', () async {
    adapter.pending = Completer<ResponseBody>();
    final lease = service.createCancellationLease();
    final generation = service.generateImage(
      const ImageParams(),
      cancellationLease: lease,
    );
    final handled = expectLater(generation, throwsA(isA<DioException>()));
    try {
      await Future.any([adapter.started.future, handled]);
      expect(adapter.requests, hasLength(1));
      service.cancelGeneration(lease);
      await handled;
      expect(activity.isActive, false);
      expect(lease.activeRequestCountForTesting, 0);
    } finally {
      if (!adapter.pending!.isCompleted) {
        adapter.pending!.complete(ResponseBody.fromBytes([], 200));
      }
      service.releaseCancellationLease(lease);
    }
  });

  test(
    'native methods reject Chat while official and generic stay multipart',
    () async {
      final request = transport.beginRequest();
      try {
        expect(() => transport.sendZip({}, request), throwsStateError);
        expect(() => transport.sendStream({}, request), throwsStateError);
        expect(adapter.requests, isEmpty);
        for (final config in [
          NaiApiEndpointConfig.official,
          NaiApiEndpointConfig.fromInput(
            mainBaseUrl: 'https://generic.invalid',
          ),
        ]) {
          endpoints.setCurrent(config);
          await transport.sendZip({
            'parameters': {'image': 'AQID'},
          }, request);
          await transport.sendStream({
            'parameters': {'image': 'AQID'},
          }, request);
          expect(
            adapter.requests.last.contentType,
            startsWith('multipart/form-data;'),
          );
          expect(adapter.bodies.last, contains('image_cache_secret_key'));
        }
      } finally {
        transport.completeRequest(request);
      }
    },
  );

  test(
    'independent native encode tool retains its separate JSON contract',
    () async {
      final enhancement = NAIImageEnhancementApiService(
        dio,
        endpoints,
        activity,
      );
      adapter.response = Uint8List.fromList([1, 2, 3]);
      for (final model in NaiCompatibleRequest.vibeModels) {
        final result = await enhancement.encodeVibe(
          _png(8, 8),
          model: model,
          informationExtracted: 0.35,
        );
        expect(result, base64Encode(adapter.response));
        expect(adapter.jsonBodies.last, {
          'image': base64Encode(_png(8, 8)),
          'information_extracted': 0.35,
          'model': model,
        });
        expect(adapter.requests.last.path, endsWith('/encode-vibe'));
        expect(activity.isActive, false);
      }
    },
  );

  test(
    'unsupported enhancement tools fail before image work or network',
    () async {
      final enhancement = NAIImageEnhancementApiService(
        dio,
        endpoints,
        activity,
      );
      final invalidImage = Uint8List(0);
      for (final operation in <Future<dynamic> Function()>[
        () => enhancement.upscaleImage(invalidImage),
        () => enhancement.removeBackground(invalidImage),
        () => enhancement.getImageTags(invalidImage),
        () =>
            enhancement.encodeVibe(invalidImage, model: 'nai-diffusion-5-full'),
        () => enhancement.encodeVibe(
          invalidImage,
          model: 'nai-diffusion-5-curated',
        ),
        () => enhancement.encodeVibe(invalidImage, model: 'nai-diffusion-3'),
      ]) {
        await expectLater(operation, throwsA(isA<UnsupportedError>()));
        expect(activity.isActive, false);
      }
      expect(adapter.requests, isEmpty);
    },
  );

  test('enhancement preserves nested OpenAI error detail', () async {
    final enhancement = NAIImageEnhancementApiService(dio, endpoints, activity);
    adapter.status = 422;
    adapter.response = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'error': {
            'message': 'Invalid image payload',
            'code': 'invalid_image',
            'param': 'image',
          },
        }),
      ),
    );
    await expectLater(
      enhancement.encodeVibe(_png(8, 8), model: 'nai-diffusion-4-full'),
      throwsA(
        isA<Exception>().having(
          (error) => error.toString(),
          'detail',
          allOf(
            contains('Invalid image payload'),
            contains('code=invalid_image'),
            contains('param=image'),
          ),
        ),
      ),
    );
    expect(adapter.requests, hasLength(1));
    expect(activity.isActive, false);
  });

  test('unsupported capability intent rejects before Chat access', () async {
    for (final params in [
      const ImageParams(model: 'nai-diffusion-3'),
      const ImageParams(model: 'nai-diffusion-5-full-medium'),
      const ImageParams(nSamples: 2),
      const ImageParams(steps: 51),
      const ImageParams(width: 65),
      const ImageParams(width: 2048, height: 2048),
      const ImageParams(e2eUpscale: true),
      ImageParams(
        vibeReferencesV4: [
          VibeReference(
            displayName: 'v5',
            vibeEncoding: '',
            rawImageData: _png(8, 8),
          ),
        ],
      ),
    ]) {
      await expectLater(service.generateImage(params), throwsA(anything));
    }
    expect(adapter.requests, isEmpty);
  });

  test(
    'multi-center characters fail rather than silently lose positions',
    () async {
      final built = await NAIImageRequestBuilder(
        params: const ImageParams(
          model: 'nai-diffusion-4-5-full',
          characters: [CharacterPrompt(prompt: 'girl')],
        ),
        encodeVibe: (_, {required model, informationExtracted = 1}) async => '',
      ).build(sampler: 'k_euler_ancestral');
      final caption =
          (built.requestParameters['v4_prompt'] as Map)['caption'] as Map;
      (caption['char_captions'] as List).single['centers'] = [
        {'x': 0.1, 'y': 0.1},
        {'x': 0.9, 'y': 0.9},
      ];
      await expectLater(
        NAIChatImageCodec.buildRequest(
          params: const ImageParams(model: 'nai-diffusion-4-5-full'),
          nativeRequestData: built.requestData,
        ),
        throwsA(isA<UnsupportedError>()),
      );
    },
  );
}

Map<String, dynamic> _draw(Map<String, dynamic> outer) =>
    jsonDecode((outer['messages'] as List).single['content'] as String)
        as Map<String, dynamic>;

void _expectOnlyChatFields(Map<String, dynamic> draw) {
  expect(
    draw.keys.toSet().difference({
      'prompt',
      'negative_prompt',
      'quality',
      'uc_preset',
      'size',
      'steps',
      'scale',
      'sampler',
      'seed',
      'variety_boost',
      'cfg_rescale',
      'noise_schedule',
      'n_samples',
      'image_format',
      'i2i',
      'inpaint',
      'characters',
      'use_coords',
      'controlnet',
      'character_references',
    }),
    isEmpty,
  );
}

Uint8List _png(int width, int height) => Uint8List.fromList(
  img.encodePng(
    img.Image(width: width, height: height)..clear(img.ColorRgb8(0, 0, 240)),
  ),
);

Uint8List _chatResponse(
  Uint8List png, {
  String suffix = '',
}) => Uint8List.fromList(
  utf8.encode(
    jsonEncode({
      'choices': [
        {
          'message': {
            'content':
                '![image](data:image/png;base64,${base64Encode(png)})$suffix',
          },
        },
      ],
      'usage': {'total_tokens': 1},
    }),
  ),
);

class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final bodies = <String>[];
  final started = Completer<void>();
  Completer<ResponseBody>? pending;
  int status = 200;
  late Uint8List response = Uint8List.fromList(
    utf8.encode(
      jsonEncode({
        'choices': [
          {
            'message': {
              'content':
                  '![image](data:image/png;base64,${base64Encode(_png(64, 64))})',
            },
          },
        ],
        'usage': {'total_tokens': 1},
      }),
    ),
  );

  List<Map<String, dynamic>> get jsonBodies => bodies
      .where((body) => body.startsWith('{'))
      .map((body) => jsonDecode(body) as Map<String, dynamic>)
      .toList();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final bytes = requestStream == null
        ? <int>[]
        : await requestStream.expand((chunk) => chunk).toList();
    bodies.add(utf8.decode(bytes, allowMalformed: true));
    if (!started.isCompleted) started.complete();
    if (pending != null) return pending!.future;
    return ResponseBody.fromBytes(
      response,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
        Headers.contentLengthHeader: ['${response.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
