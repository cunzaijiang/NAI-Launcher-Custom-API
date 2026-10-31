import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nai_launcher/core/network/nai_chat_image_codec.dart';
import 'package:nai_launcher/core/utils/image_save_utils.dart';
import 'package:nai_launcher/data/models/image/image_params.dart';
import 'package:nai_launcher/data/services/metadata/unified_metadata_parser.dart';

void main() {
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
