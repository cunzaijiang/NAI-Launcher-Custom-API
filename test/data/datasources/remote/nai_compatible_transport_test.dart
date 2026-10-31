import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:msgpack_dart/msgpack_dart.dart' as msgpack;
import 'package:nai_launcher/core/network/critical_network_activity.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint_service.dart';
import 'package:nai_launcher/core/network/nai_compatible_request.dart';
import 'package:nai_launcher/data/datasources/remote/nai_generation_transport.dart';
import 'package:nai_launcher/data/datasources/remote/nai_image_enhancement_api_service.dart';

void main() {
  late Dio dio;
  late _RecordingAdapter adapter;
  late NaiApiEndpointService endpoints;
  late NaiGenerationTransport transport;

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
  });
  tearDown(() => dio.close(force: true));

  test(
    'ZIP request preserves native JSON images and inpaint parameters',
    () async {
      final payload = _request(model: 'nai-diffusion-4-5-full-inpainting');
      payload['action'] = 'infill';
      final parameters = payload['parameters'] as Map<String, dynamic>;
      parameters.addAll({
        'image': 'AQID',
        'mask': 'BAUG',
        'strength': 0.8,
        'noise': 0,
        'img2img': {'strength': 0.5, 'color_correct': true},
        'extra_noise_seed': 41,
      });
      final original = jsonEncode(payload);
      final request = transport.beginRequest();
      addTearDown(() => transport.completeRequest(request));
      final progress = <int>[];
      final response = await transport.sendZip(
        payload,
        request,
        onProgress: (received, _) => progress.add(received),
      );

      expect(response.data, [1, 2, 3]);
      expect(adapter.requests.single.contentType, Headers.jsonContentType);
      expect(adapter.requests.single.method, 'POST');
      expect(
        adapter.requests.single.path,
        'https://compatible.invalid/v1/ai/generate-image',
      );
      expect(adapter.jsonBodies.single, {
        ...payload,
        'model': 'nai-diffusion-4-5-full',
      });
      expect(jsonEncode(payload), original);
      expect(adapter.bodies.single, isNot(contains('cache_secret_key')));
      expect(progress, isNotEmpty);
    },
  );

  test(
    'stream passes through final-only official messagepack unchanged',
    () async {
      final message = msgpack.serialize({
        'event_type': 'final',
        'samp_ix': 0,
        'image': Uint8List.fromList([7, 8, 9]),
      });
      final frame = Uint8List(4 + message.length);
      ByteData.sublistView(frame).setUint32(0, message.length, Endian.big);
      frame.setRange(4, frame.length, message);
      adapter.response = frame;
      final request = transport.beginRequest();
      addTearDown(() => transport.completeRequest(request));
      final payload = _request();
      (payload['parameters'] as Map)['stream'] = 'msgpack';
      final response = await transport.sendStream(payload, request);
      final received = await response.data!.stream
          .expand((bytes) => bytes)
          .toList();

      expect(received, frame);
      expect(adapter.jsonBodies.single, payload);
      expect(adapter.requests.single.responseType, ResponseType.stream);
      expect(adapter.requests.single.cancelToken, same(request.cancelToken));
      expect(adapter.requests.single.path, endsWith('/generate-image-stream'));
    },
  );

  test(
    'all five supported models and their inpainting aliases are retained',
    () async {
      for (final model in NaiCompatibleRequest.generationModels) {
        for (final suffix in ['', '-inpainting']) {
          final request = transport.beginRequest();
          try {
            await transport.sendZip(_request(model: '$model$suffix'), request);
          } finally {
            transport.completeRequest(request);
          }
          expect(adapter.jsonBodies.last['model'], model);
        }
      }
    },
  );

  test(
    'native Vibe and Precise payloads are not rewritten into caches',
    () async {
      for (final key in [
        'reference_image_multiple',
        'director_reference_images',
      ]) {
        final payload = _request();
        (payload['parameters'] as Map)[key] = ['AQID', 'BAUG'];
        final request = transport.beginRequest();
        try {
          await transport.sendZip(payload, request);
        } finally {
          transport.completeRequest(request);
        }
        expect(adapter.jsonBodies.last, payload);
        expect(adapter.bodies.last, isNot(contains('_cached')));
      }
    },
  );

  test(
    'invalid capabilities fail before ZIP or stream network access',
    () async {
      final invalid = <Map<String, dynamic>>[
        _request(model: 'nai-diffusion-3'),
        _request(model: 'nai-diffusion-4-curated-preview'),
        _request(model: 'nai-diffusion-5-full-medium'),
        _request(model: 'nai-diffusion-5-full-medium-inpainting'),
        _request(parameters: {'n_samples': 2}),
        _request(parameters: {'n_samples': 0}),
        _request(parameters: {'steps': 0}),
        _request(parameters: {'steps': 51}),
        _request(parameters: {'width': 63}),
        _request(parameters: {'width': 4097}),
        _request(parameters: {'width': 65}),
        _request(parameters: {'width': 2048, 'height': 2048}),
        _request(
          parameters: {'reference_image_multiple': List.filled(5, 'AQID')},
        ),
        _request(
          parameters: {'director_reference_images': List.filled(5, 'AQID')},
        ),
        _request(
          parameters: {
            'reference_image_multiple': ['AQID'],
            'director_reference_images': ['BAUG'],
          },
        ),
        _request(
          model: 'nai-diffusion-4-full',
          parameters: {
            'director_reference_images': ['AQID'],
          },
        ),
        for (final model in [
          'nai-diffusion-5-full',
          'nai-diffusion-5-curated',
        ]) ...[
          _request(
            model: model,
            parameters: {
              'reference_image_multiple': ['AQID'],
            },
          ),
          _request(
            model: model,
            parameters: {
              'director_reference_images': ['AQID'],
            },
          ),
          _request(model: model, parameters: {'sampler': 'k_dpm_2_ancestral'}),
          _request(model: model, parameters: {'skip_cfg_above_sigma': 58}),
          _request(model: model, parameters: {'effort': 'medium'}),
        ],
        _request(
          parameters: {
            'characterPrompts': List.filled(7, {'prompt': 'role'}),
          },
        ),
        for (final key in ['v4_prompt', 'v4_negative_prompt'])
          _request(
            parameters: {
              key: {
                'caption': {
                  'char_captions': List.filled(7, {'char_caption': 'role'}),
                },
              },
            },
          ),
        _request(
          parameters: {
            'reference_image_multiple_cached': [
              {'data': 'AQID'},
            ],
          },
        ),
      ];
      for (final payload in invalid) {
        final request = transport.beginRequest();
        try {
          expect(
            () => transport.sendZip(payload, request),
            throwsA(anyOf(isA<ArgumentError>(), isA<UnsupportedError>())),
          );
          expect(
            () => transport.sendStream(payload, request),
            throwsA(anyOf(isA<ArgumentError>(), isA<UnsupportedError>())),
          );
        } finally {
          transport.completeRequest(request);
        }
      }
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'valid boundary dimensions, steps and text roles are accepted',
    () async {
      for (final dimensions in [(64, 4096), (2048, 1536), (4096, 64)]) {
        for (final steps in [1, 50]) {
          final request = transport.beginRequest();
          try {
            await transport.sendZip(
              _request(
                parameters: {
                  'width': dimensions.$1,
                  'height': dimensions.$2,
                  'steps': steps,
                  'characterPrompts': List.filled(6, {'prompt': 'role'}),
                },
              ),
              request,
            );
          } finally {
            transport.completeRequest(request);
          }
        }
      }
      expect(adapter.requests, hasLength(6));
    },
  );

  test('official and generic third-party requests remain multipart', () async {
    for (final config in [
      NaiApiEndpointConfig.official,
      NaiApiEndpointConfig.fromInput(mainBaseUrl: 'https://generic.invalid'),
    ]) {
      endpoints.setCurrent(config);
      // Deliberately invalid for the special profile: no profile validation here.
      final payload = {
        'model': 'nai-diffusion-3',
        'parameters': {'image': 'AQID'},
      };
      final request = transport.beginRequest();
      try {
        await transport.sendZip(payload, request);
        await transport.sendStream(payload, request);
      } finally {
        transport.completeRequest(request);
      }
      expect(
        adapter.requests.last.contentType,
        startsWith('multipart/form-data;'),
      );
      expect(adapter.bodies.last, contains('image_cache_secret_key'));
    }
  });

  test(
    'compatible encode-vibe sends JSON and returns binary as base64',
    () async {
      final source = Uint8List.fromList(
        img.encodePng(img.Image(width: 8, height: 8)),
      );
      final activity = CriticalNetworkActivityCoordinator();
      final service = NAIImageEnhancementApiService(dio, endpoints, activity);
      for (final model in NaiCompatibleRequest.vibeModels) {
        final result = await service.encodeVibe(
          source,
          model: model,
          informationExtracted: 0.35,
        );
        expect(result, base64Encode(adapter.response));
        expect(adapter.jsonBodies.last, {
          'image': base64Encode(source),
          'information_extracted': 0.35,
          'model': model,
        });
        expect(adapter.requests.last.contentType, Headers.jsonContentType);
        expect(adapter.requests.last.path, endsWith('/encode-vibe'));
        expect(activity.isActive, isFalse);
      }
    },
  );

  test(
    'unsupported tools and encoding models fail before image work or network',
    () async {
      final activity = CriticalNetworkActivityCoordinator();
      final service = NAIImageEnhancementApiService(dio, endpoints, activity);
      final invalidImage = Uint8List(0);
      for (final operation in <Future<dynamic> Function()>[
        () => service.upscaleImage(invalidImage),
        () => service.removeBackground(invalidImage),
        () => service.getImageTags(invalidImage),
        () => service.encodeVibe(invalidImage, model: 'nai-diffusion-5-full'),
        () =>
            service.encodeVibe(invalidImage, model: 'nai-diffusion-5-curated'),
        () => service.encodeVibe(invalidImage, model: 'nai-diffusion-3'),
      ]) {
        await expectLater(operation, throwsA(isA<UnsupportedError>()));
        expect(activity.isActive, isFalse);
      }
      expect(adapter.requests, isEmpty);
    },
  );

  test(
    'enhancement reports nested OpenAI error message, code and param',
    () async {
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
      final activity = CriticalNetworkActivityCoordinator();
      final service = NAIImageEnhancementApiService(dio, endpoints, activity);
      await expectLater(
        service.encodeVibe(
          Uint8List.fromList(img.encodePng(img.Image(width: 8, height: 8))),
          model: 'nai-diffusion-4-full',
        ),
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
      expect(activity.isActive, isFalse);
    },
  );
}

Map<String, dynamic> _request({
  String model = 'nai-diffusion-4-5-full',
  Map<String, dynamic> parameters = const {},
}) => {
  'input': 'landscape',
  'model': model,
  'action': 'generate',
  'parameters': {
    'width': 1024,
    'height': 1024,
    'steps': 28,
    'n_samples': 1,
    'sampler': 'k_euler_ancestral',
    ...parameters,
  },
};

class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];
  final bodies = <String>[];
  Uint8List response = Uint8List.fromList([1, 2, 3]);
  int status = 200;

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
    return ResponseBody.fromBytes(
      response,
      status,
      headers: {
        Headers.contentTypeHeader: ['application/octet-stream'],
        Headers.contentLengthHeader: ['${response.length}'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
