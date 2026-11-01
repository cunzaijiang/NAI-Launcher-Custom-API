import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

import '../../data/models/image/image_params.dart';
import '../../data/services/metadata/unified_metadata_parser.dart';
import '../enums/precise_ref_type.dart';
import '../utils/exif_orientation.dart';
import '../utils/chat_character_position.dart';
import '../utils/character_center_resolver.dart';
import '../utils/image_save_utils.dart';
import 'nai_compatible_request.dart';
import 'request_builders/reference_strength_normalization.dart';

/// The explicitly selected Chat drawing protocol, not the native NovelAI API.
abstract final class NAIChatImageCodec {
  /// Chat has no transparent-background or premultiplied-alpha controls.
  static void validateParams(ImageParams params) {
    if (params.transparentBackground || !params.straightAlpha) {
      throw UnsupportedError(
        'Chat drawing does not support transparent background or custom alpha mode',
      );
    }
  }

  /// Consumes the shared builder's effective text, seed and normalized source
  /// images. References remain raw images: native Vibe encodings are not images.
  static Future<Map<String, dynamic>> buildRequest({
    required ImageParams params,
    required Map<String, dynamic> nativeRequestData,
  }) async {
    validateParams(params);
    final native = nativeRequestData['parameters'];
    if (native is! Map<String, dynamic>) {
      throw ArgumentError(
        'Chat drawing requires normalized request parameters',
      );
    }
    final vibes = params.enabledVibeReferencesV4;
    final precise = params.enabledPreciseReferences;
    final validated = NaiCompatibleRequest.generation({
      ...nativeRequestData,
      'parameters': {
        ...native,
        'reference_image_multiple': List.filled(vibes.length, ''),
        'director_reference_images': List.filled(precise.length, ''),
      },
    });
    final draw = <String, dynamic>{
      'prompt': nativeRequestData['input'],
      'negative_prompt': native['negative_prompt'] ?? native['uc'] ?? '',
      // The common builder has already expanded both presets exactly once.
      'quality': false,
      'uc_preset': 'none',
      'size': [native['width'], native['height']],
      'steps': native['steps'],
      'scale': native['scale'],
      'sampler': native['sampler'],
      'seed': native['seed'],
      'variety_boost': params.varietyPlus,
      'cfg_rescale': native['cfg_rescale'] ?? params.cfgRescale,
      'noise_schedule': native['noise_schedule'] == 'native'
          ? 'karras'
          : native['noise_schedule'],
      'n_samples': 1,
      'image_format': 'png',
    };
    if (params.action != ImageGenerationAction.generate &&
        native['image'] == null) {
      throw ArgumentError(
        'Chat drawing requires a source image for ${params.action.value}',
      );
    }
    if (params.action == ImageGenerationAction.infill &&
        native['mask'] == null) {
      throw ArgumentError('Chat inpainting requires a mask');
    }
    if (params.action == ImageGenerationAction.img2img) {
      _validateRange(native['strength'], 'i2i.strength', 0.01, 0.99);
      _validateRange(native['noise'], 'i2i.noise', 0, 0.99);
      draw['i2i'] = {
        'image': native['image'],
        'strength': native['strength'],
        'noise': native['noise'],
        if (native['extra_noise_seed'] != null)
          'seed': native['extra_noise_seed'],
      };
    } else if (params.action == ImageGenerationAction.infill) {
      final strength =
          native['inpaintImg2ImgStrength'] ?? params.inpaintStrength;
      _validateRange(strength, 'inpaint.strength', 0.01, 1);
      draw['inpaint'] = {
        'image': native['image'],
        'mask': native['mask'],
        'strength': strength,
        if (native['extra_noise_seed'] != null)
          'seed': native['extra_noise_seed'],
      };
    }
    final characters = _characters(native);
    if (characters.isNotEmpty) {
      draw['characters'] = characters;
      draw['use_coords'] = true;
    }
    if (vibes.isNotEmpty) {
      final strengths = normalizeReferenceStrengths(
        vibes.map((vibe) => vibe.strength).toList(),
        enabled: params.normalizeVibeStrength,
      );
      final refs = <Map<String, dynamic>>[];
      for (var i = 0; i < vibes.length; i++) {
        final vibe = vibes[i];
        if (!vibe.canReencodeFromRawSource) {
          throw UnsupportedError(
            'Chat Vibe reference ${vibe.displayName} requires its original image; '
            'native encoded-only Vibe data cannot be sent as an image',
          );
        }
        refs.add({
          'image': base64Encode(
            await ExifOrientation.bakeToPngAsync(vibe.rawImageData!),
          ),
          'strength': strengths[i],
          'info_extracted': vibe.infoExtracted,
        });
      }
      draw['controlnet'] = {'strength': 1.0, 'images': refs};
    }
    if (precise.isNotEmpty) {
      draw['character_references'] = await Future.wait(
        precise.map(
          (reference) async => <String, dynamic>{
            'image': base64Encode(
              await ExifOrientation.bakeToPngAsync(reference.image),
            ),
            'type': reference.type.toApiString(),
            'strength': reference.strength,
            'fidelity': reference.fidelity,
          },
        ),
      );
    }
    return {
      'model': validated['model'],
      'messages': [
        {'role': 'user', 'content': jsonEncode(draw)},
      ],
      'stream': false,
    };
  }

  static void _validateRange(Object? value, String field, num min, num max) {
    if (value is! num || !value.isFinite || value < min || value > max) {
      throw ArgumentError.value(
        value,
        field,
        'Chat drawing $field must be a finite number in [$min, $max]',
      );
    }
  }

  static List<Map<String, dynamic>> _characters(Map<String, dynamic> native) {
    final prompt = native['v4_prompt'];
    final caption = prompt is Map ? prompt['caption'] : null;
    final captions = caption is Map ? caption['char_captions'] : null;
    final roles = native['characterPrompts'];
    if (roles is! List) return [];
    return List.generate(roles.length, (i) {
      final role = roles[i];
      if (role is! Map) throw ArgumentError('Invalid character $i');
      if (captions is List && i < captions.length) {
        final item = captions[i];
        final centers = item is Map ? item['centers'] : null;
        if (centers is List && centers.length > 1) {
          throw UnsupportedError(
            'Chat characters support only one grid center',
          );
        }
      }
      final rawCenter = role['center'];
      final center = CharacterCenterResolver.resolve(
        CharacterPrompt(
          prompt: role['prompt'] as String? ?? '',
          positionX: rawCenter is Map
              ? (rawCenter['x'] as num?)?.toDouble()
              : null,
          positionY: rawCenter is Map
              ? (rawCenter['y'] as num?)?.toDouble()
              : null,
        ),
        index: i,
        total: roles.length,
        useCoords: native['use_coords'] == true,
      );
      return <String, dynamic>{
        'prompt': role['prompt'],
        'negative_prompt': role['uc'] ?? '',
        'position': ChatCharacterPosition.grid(center.x, center.y),
      };
    });
  }

  /// Parse the entire response, including strict PNG pixel validation, off the
  /// UI isolate. Only the response string and sendable bytes/metadata cross the
  /// boundary; no request, cancellation token or service is captured.
  /// Do not queue this latency-sensitive step behind the metadata compute gate.
  static Future<NAIChatImageResponse> decodeResponseAsync(String body) =>
      compute(decodeResponse, body, debugLabel: 'chat-image-response');

  /// Only inline PNG data URIs are accepted. Never follow remote image URLs.
  static NAIChatImageResponse decodeResponse(String body) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      throw const FormatException('Chat drawing returned malformed JSON');
    }
    if (decoded is! Map) {
      throw const FormatException(
        'Chat drawing response must be a JSON object',
      );
    }
    if (decoded['error'] != null) {
      final error = decoded['error'];
      if (error is Map) {
        throw StateError(
          [
            error['message'] ?? 'Chat drawing failed',
            if (error['code'] != null) 'code=${error['code']}',
            if (error['param'] != null) 'param=${error['param']}',
          ].join(' | '),
        );
      }
      throw StateError('Chat drawing failed: $error');
    }
    final choices = decoded['choices'];
    final choice = choices is List && choices.isNotEmpty ? choices.first : null;
    final message = choice is Map ? choice['message'] : null;
    final content = message is Map ? message['content'] : null;
    if (content is! String) {
      throw const FormatException(
        'Chat drawing response has no message content',
      );
    }
    final matches = RegExp(
      r'!\[[^\]]*\]\(data:image/png;base64,([A-Za-z0-9+/=\r\n]+)\)',
      caseSensitive: false,
    ).allMatches(content).toList();
    if (matches.length != 1) {
      throw const FormatException(
        'Chat drawing must return exactly one inline Markdown PNG data URI',
      );
    }
    final Uint8List bytes;
    try {
      bytes = base64Decode(
        matches.single.group(1)!.replaceAll(RegExp(r'\s'), ''),
      );
    } on FormatException {
      throw const FormatException('Chat drawing returned invalid PNG base64');
    }
    final int width;
    final int height;
    try {
      final png = img.PngDecoder();
      final info = png.startDecode(bytes);
      if (info == null || png.decodeFrame(0) == null) {
        throw const FormatException('Invalid PNG');
      }
      width = info.width;
      height = info.height;
    } catch (_) {
      throw const FormatException(
        'Chat drawing returned invalid PNG image data',
      );
    }
    final seedMatch = RegExp(
      r'<!--\s*seeds\s*:\s*\[?\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(content);
    final usage = decoded['usage'];
    final cacheIds = decoded['vibe_cache_ids'] ?? _cacheIdsComment(content);
    return NAIChatImageResponse(
      image: bytes,
      width: width,
      height: height,
      seed: seedMatch == null ? null : int.tryParse(seedMatch.group(1)!),
      usage: usage is Map ? Map<String, dynamic>.from(usage) : const {},
      model: decoded['model'] is String ? decoded['model'] as String : null,
      requestId: decoded['id'] is String ? decoded['id'] as String : null,
      vibeCacheIds: cacheIds is List
          ? cacheIds.whereType<String>().toList()
          : const [],
    );
  }

  // Cache identifiers are response metadata only; they are not persisted or
  // reused as native Vibe encodings.
  static List<String> _cacheIdsComment(String content) {
    final match = RegExp(
      r'<!--\s*vibe_cache_ids\s*:\s*(\[[\s\S]*?\])\s*-->',
      caseSensitive: false,
    ).firstMatch(content);
    if (match == null) return const [];
    try {
      final value = jsonDecode(match.group(1)!);
      return value is List ? value.whereType<String>().toList() : const [];
    } on FormatException {
      return const [];
    }
  }

  /// Keep a server PNG seed when present; otherwise retain the effective random
  /// request seed so downstream metadata consumers do not restore -1.
  static Future<Uint8List> withRequestMetadata(
    NAIChatImageResponse response, {
    required ImageParams params,
    required int requestSeed,
    required Map<String, dynamic> requestParameters,
  }) async {
    final embedded = UnifiedMetadataParser.parseFromPngWithoutPixelDecode(
      response.image,
    )?.metadata?.seed;
    List<Map<String, dynamic>>? captions(String key) {
      final prompt = requestParameters[key];
      final caption = prompt is Map ? prompt['caption'] : null;
      final roles = caption is Map ? caption['char_captions'] : null;
      return roles is List
          ? roles.map((role) => Map<String, dynamic>.from(role as Map)).toList()
          : null;
    }

    return ImageSaveUtils.rebuildImageBytesWithMetadata(
      imageBytes: response.image,
      params: params.copyWith(
        width: response.width,
        height: response.height,
        seed: requestSeed,
      ),
      actualSeed: embedded ?? response.seed ?? requestSeed,
      charCaptions: captions('v4_prompt'),
      charNegCaptions: captions('v4_negative_prompt'),
      useCoords:
          requestParameters['use_coords'] == true ||
          params.characters.isNotEmpty,
    );
  }
}

class NAIChatImageResponse {
  const NAIChatImageResponse({
    required this.image,
    required this.width,
    required this.height,
    this.seed,
    this.usage = const {},
    this.model,
    this.requestId,
    this.vibeCacheIds = const [],
  });

  final Uint8List image;
  final int width;
  final int height;
  final int? seed;
  final Map<String, dynamic> usage;
  final String? model;
  final String? requestId;
  final List<String> vibeCacheIds;
}
