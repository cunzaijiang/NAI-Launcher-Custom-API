import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nai_launcher/core/network/nai_chat_image_codec.dart';
import 'package:nai_launcher/core/network/request_builders/nai_image_request_builder.dart';
import 'package:nai_launcher/core/utils/image_save_utils.dart';
import 'package:nai_launcher/data/models/image/image_params.dart';
import 'package:nai_launcher/data/services/metadata/unified_metadata_parser.dart';

void main() {
  test(
    'Chat wire grid and PNG native centers share the snapped effective snapshot',
    () async {
      for (final stored in [false, true]) {
        final params = ImageParams(
          model: 'nai-diffusion-4-5-full',
          seed: 42,
          characters: [
            for (final x in [0.25, 0.75])
              CharacterPrompt(
                prompt: 'role',
                positionX: stored ? x : null,
                positionY: stored ? 0.5 : null,
              ),
          ],
        );
        final builder = NAIImageRequestBuilder(
          params: params,
          useChatApi: true,
          encodeVibe:
              (image, {required model, informationExtracted = 1}) async {
                fail('Position normalization must not encode references');
              },
        );
        final built = await builder.build(sampler: 'k_euler');
        final outer = await NAIChatImageCodec.buildRequest(
          params: builder.params,
          nativeRequestData: built.requestData,
        );
        final draw =
            jsonDecode((outer['messages'] as List).single['content'] as String)
                as Map;
        expect((draw['characters'] as List).map((c) => c['position']), [
          'B3',
          'D3',
        ]);
        final png = await NAIChatImageCodec.withRequestMetadata(
          NAIChatImageCodec.decodeResponse(_response(_png())),
          params: builder.params,
          requestSeed: built.seed,
          requestParameters: built.requestParameters,
        );
        final metadata = UnifiedMetadataParser.parseFromPng(png).metadata!;
        expect(metadata.characterInfos.map((c) => c.centerX), [0.3, 0.7]);
        expect(metadata.characterInfos.map((c) => c.centerY), [0.5, 0.5]);
        final captions =
            built.requestParameters['v4_prompt']['caption']['char_captions']
                as List;
        expect(captions.map((c) => c['centers'][0]['x']), [0.3, 0.7]);
        expect(params.characters.first.positionX, stored ? 0.25 : null);
      }
    },
  );
  test('legacy AI wire snapshots always send manual grid positions', () async {
    for (final stored in [false, true]) {
      final outer = await NAIChatImageCodec.buildRequest(
        params: const ImageParams(model: 'nai-diffusion-4-5-full'),
        nativeRequestData: {
          'model': 'nai-diffusion-4-5-full',
          'input': 'test',
          'parameters': {
            'width': 64,
            'height': 64,
            'steps': 28,
            'n_samples': 1,
            'sampler': 'k_euler',
            'scale': 4.0,
            'seed': 42,
            'use_coords': false,
            'characterPrompts': [
              {
                'prompt': 'girl',
                'uc': 'blurry',
                if (stored) 'center': {'x': 0.9, 'y': 0.1},
              },
            ],
          },
        },
      );
      final draw =
          jsonDecode((outer['messages'] as List).single['content'] as String)
              as Map;
      expect(draw['use_coords'], true);
      expect(draw['characters'], [
        {
          'prompt': 'girl',
          'negative_prompt': 'blurry',
          'position': stored ? 'E1' : 'C3',
        },
      ]);
    }
  });
  group('Chat image edit numeric boundaries', () {
    Future<Map<String, dynamic>> build({
      required ImageGenerationAction action,
      Object? strength = 0.5,
      Object? noise = 0.0,
      Object? inpaintStrength = 1.0,
    }) => NAIChatImageCodec.buildRequest(
      params: ImageParams(model: 'nai-diffusion-4-5-full', action: action),
      nativeRequestData: {
        'model': 'nai-diffusion-4-5-full',
        'input': 'test',
        'parameters': {
          'width': 64,
          'height': 64,
          'steps': 28,
          'n_samples': 1,
          'sampler': 'k_euler_ancestral',
          'scale': 4.0,
          'seed': 42,
          'noise_schedule': 'karras',
          'image': 'source',
          'mask': 'mask',
          'strength': strength,
          'noise': noise,
          'inpaintImg2ImgStrength': inpaintStrength,
        },
      },
    );

    test(
      'accepts exact i2i strength and noise endpoints without clamping',
      () async {
        for (final strength in [0.01, 0.99]) {
          for (final noise in [0.0, 0.99]) {
            final outer = await build(
              action: ImageGenerationAction.img2img,
              strength: strength,
              noise: noise,
            );
            final draw =
                jsonDecode(
                      (outer['messages'] as List).single['content'] as String,
                    )
                    as Map;
            expect(draw['i2i']['strength'], strength);
            expect(draw['i2i']['noise'], noise);
          }
        }
      },
    );

    test('accepts exact inpaint strength endpoints without clamping', () async {
      for (final strength in [0.01, 1.0]) {
        final outer = await build(
          action: ImageGenerationAction.infill,
          inpaintStrength: strength,
        );
        final draw =
            jsonDecode((outer['messages'] as List).single['content'] as String)
                as Map;
        expect(draw['inpaint']['strength'], strength);
      }
    });

    for (final (field, invalid) in <(String, List<Object?>)>[
      (
        'i2i.strength',
        [
          0,
          0.009,
          0.991,
          1,
          double.nan,
          double.infinity,
          double.negativeInfinity,
          null,
          '0.5',
        ],
      ),
      (
        'i2i.noise',
        [
          -0.001,
          0.991,
          1,
          double.nan,
          double.infinity,
          double.negativeInfinity,
          null,
          '0.5',
        ],
      ),
      (
        'inpaint.strength',
        [
          0,
          0.009,
          1.001,
          double.nan,
          double.infinity,
          double.negativeInfinity,
          '0.5',
        ],
      ),
    ]) {
      test(
        'rejects invalid $field with explicit finite range detail',
        () async {
          for (final value in invalid) {
            await expectLater(
              build(
                action: field == 'inpaint.strength'
                    ? ImageGenerationAction.infill
                    : ImageGenerationAction.img2img,
                strength: field == 'i2i.strength' ? value : 0.5,
                noise: field == 'i2i.noise' ? value : 0.0,
                inpaintStrength: field == 'inpaint.strength' ? value : 1.0,
              ),
              throwsA(
                isA<ArgumentError>().having(
                  (e) => e.toString(),
                  'detail',
                  allOf(
                    contains(field),
                    contains('finite number in'),
                    contains(
                      field == 'inpaint.strength'
                          ? '[0.01, 1]'
                          : field == 'i2i.noise'
                          ? '[0, 0.99]'
                          : '[0.01, 0.99]',
                    ),
                  ),
                ),
              ),
            );
          }
        },
      );
    }
  });

  test(
    'decodes PNG, seed comment, final usage and opaque cache identifiers',
    () {
      final decoded = NAIChatImageCodec.decodeResponse(
        _response(
          _png(),
          suffix: '<!-- seeds: [12345] -->',
          extras: {
            'usage': {'total_tokens': 17},
            'vibe_cache_ids': ['opaque-id'],
          },
        ),
      );
      expect((decoded.width, decoded.height), (64, 128));
      expect(decoded.seed, 12345);
      expect(decoded.usage, {'total_tokens': 17});
      expect(decoded.vibeCacheIds, ['opaque-id']);
    },
  );

  test(
    'reads optional cache IDs comment without persisting or requiring it',
    () {
      final decoded = NAIChatImageCodec.decodeResponse(
        _response(
          _png(),
          suffix: '<!-- vibe_cache_ids: ["cache-a", "cache-b"] -->',
        ),
      );
      expect(decoded.vibeCacheIds, ['cache-a', 'cache-b']);
      final malformed = NAIChatImageCodec.decodeResponse(
        _response(_png(), suffix: '<!-- vibe_cache_ids: [bad] -->'),
      );
      expect(malformed.vibeCacheIds, isEmpty);
    },
  );

  test(
    'seed precedence is PNG metadata then comment then resolved request seed',
    () async {
      const params = ImageParams(model: 'nai-diffusion-4-5-full', seed: -1);
      final embedded = await ImageSaveUtils.rebuildImageBytesWithMetadata(
        imageBytes: _png(),
        params: params,
        actualSeed: 987,
      );
      for (final (png, suffix, expected) in [
        (embedded, '<!-- seeds: [123] -->', 987),
        (_png(), '<!-- seeds: [123] -->', 123),
        (_png(), '', 42),
      ]) {
        final image = await NAIChatImageCodec.withRequestMetadata(
          NAIChatImageCodec.decodeResponse(_response(png, suffix: suffix)),
          params: params,
          requestSeed: 42,
          requestParameters: const {},
        );
        final metadata = UnifiedMetadataParser.parseFromPng(image).metadata!;
        expect(metadata.seed, expected);
        expect((metadata.width, metadata.height), (64, 128));
      }
    },
  );

  test('malformed JSON and error envelope report meaningful detail', () {
    expect(
      () => NAIChatImageCodec.decodeResponse('{bad'),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'detail',
          contains('malformed JSON'),
        ),
      ),
    );
    expect(
      () => NAIChatImageCodec.decodeResponse(
        jsonEncode({
          'error': {
            'message': 'Rejected',
            'code': 'bad_request',
            'param': 'size',
          },
        }),
      ),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'detail',
          allOf(
            contains('Rejected'),
            contains('code=bad_request'),
            contains('param=size'),
          ),
        ),
      ),
    );
  });

  test(
    'rejects remote URLs, multiple images, corrupt base64 and non-PNG data',
    () {
      final png = base64Encode(_png());
      for (final content in [
        '![x](https://untrusted.invalid/a.png)',
        '![x](data:image/png;base64,$png) ![x](data:image/png;base64,$png)',
        '![x](data:image/png;base64,abc=def)',
        '![x](data:image/png;base64,AQID)',
        '![x](data:image/jpeg;base64,$png)',
      ]) {
        expect(
          () => NAIChatImageCodec.decodeResponse(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': content},
                },
              ],
            }),
          ),
          throwsA(isA<FormatException>()),
        );
      }
    },
  );
}

Uint8List _png() =>
    Uint8List.fromList(img.encodePng(img.Image(width: 64, height: 128)));
String _response(
  Uint8List png, {
  String suffix = '',
  Map<String, dynamic> extras = const {},
}) => jsonEncode({
  'choices': [
    {
      'message': {
        'content':
            '![image](data:image/png;base64,${base64Encode(png)})$suffix',
      },
    },
  ],
  ...extras,
});
