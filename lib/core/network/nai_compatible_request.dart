/// Validation for the OpenAI-compatible provider's NovelAI-native JSON API.
///
/// This is deliberately separate from the official multipart/cache protocol.
class NaiCompatibleRequest {
  static const generationModels = {
    'nai-diffusion-4-full',
    'nai-diffusion-4-5-full',
    'nai-diffusion-4-5-curated',
    'nai-diffusion-5-full',
    'nai-diffusion-5-curated',
  };

  static const vibeModels = {
    'nai-diffusion-4-full',
    'nai-diffusion-4-5-full',
    'nai-diffusion-4-5-curated',
  };

  /// Preserve the native payload, including base64 images and inpaint masks.
  /// Only the official inpainting model alias needs translation.
  static Map<String, dynamic> generation(Map<String, dynamic> request) {
    final originalModel = request['model'];
    final model = originalModel is String
        ? originalModel.replaceFirst(RegExp(r'-inpainting$'), '')
        : originalModel;
    if (model is! String || !generationModels.contains(model)) {
      throw UnsupportedError(
        'OpenAI-compatible NovelAI API does not support model $originalModel '
        '(including V5 medium effort).',
      );
    }
    final parameters = request['parameters'];
    if (parameters is! Map) {
      throw ArgumentError('NovelAI parameters must be a JSON object');
    }
    if (parameters['n_samples'] != 1) {
      throw ArgumentError('OpenAI-compatible NovelAI API requires n_samples=1');
    }
    _integerInRange(parameters['steps'], 'steps', 1, 50);
    final width = _integerInRange(parameters['width'], 'width', 64, 4096);
    final height = _integerInRange(parameters['height'], 'height', 64, 4096);
    if (width % 64 != 0 || height % 64 != 0 || width * height > 3145728) {
      throw ArgumentError(
        'Dimensions must be multiples of 64 and at most 3145728 pixels',
      );
    }

    if (_hasValue(parameters['upscale']) ||
        parameters['upscaled_enhance'] == true) {
      throw UnsupportedError(
        'OpenAI-compatible NovelAI API does not support end-to-end upscale '
        'or upscaled enhancement',
      );
    }
    final vibeCount =
        _referenceCount(parameters, 'reference_image_multiple') +
        (_hasValue(parameters['reference_image']) ? 1 : 0);
    final preciseCount = _referenceCount(
      parameters,
      'director_reference_images',
    );
    for (final key in [
      'reference_image_multiple_cached',
      'director_reference_images_cached',
    ]) {
      if (_hasValue(parameters[key])) {
        throw UnsupportedError(
          'OpenAI-compatible NovelAI API requires native base64 references, '
          'not $key',
        );
      }
    }
    if (vibeCount > 4 || preciseCount > 4) {
      throw ArgumentError('At most 4 reference images are supported');
    }
    if (vibeCount > 0 && preciseCount > 0) {
      throw UnsupportedError(
        'Vibe Transfer and Precise Reference are exclusive',
      );
    }
    if (model == 'nai-diffusion-4-full' && preciseCount > 0) {
      throw UnsupportedError('V4 does not support Precise Reference');
    }
    if (model.startsWith('nai-diffusion-5-')) {
      if (vibeCount + preciseCount > 0) {
        throw UnsupportedError('V5 does not support reference images');
      }
      if (parameters['sampler'] == 'k_dpm_2_ancestral') {
        throw UnsupportedError('V5 does not support k_dpm_2_ancestral');
      }
      if (_hasValue(parameters['skip_cfg_above_sigma']) ||
          parameters['variety'] == true ||
          parameters['varietyPlus'] == true) {
        throw UnsupportedError('V5 does not support Variety+');
      }
      if (parameters['effort'] == 'medium' || request['effort'] == 'medium') {
        throw UnsupportedError('V5 medium effort is not supported');
      }
    }
    _validateRoles(parameters['characterPrompts']);
    for (final key in ['v4_prompt', 'v4_negative_prompt']) {
      final prompt = parameters[key];
      if (prompt is Map) {
        final caption = prompt['caption'];
        if (caption is Map) _validateRoles(caption['char_captions']);
      }
    }
    return {...request, 'model': model};
  }

  static void validateVibeModel(String model) {
    if (!vibeModels.contains(model)) {
      throw UnsupportedError(
        'OpenAI-compatible NovelAI encode-vibe does not support model $model',
      );
    }
  }

  static int _integerInRange(Object? value, String name, int min, int max) {
    if (value is! int || value < min || value > max) {
      throw ArgumentError('$name must be an integer between $min and $max');
    }
    return value;
  }

  static int _referenceCount(Map parameters, String key) {
    final value = parameters[key];
    if (value == null) return 0;
    if (value is! List) throw ArgumentError('$key must be a list');
    return value.length;
  }

  static bool _hasValue(Object? value) => switch (value) {
    null || false => false,
    final String value => value.isNotEmpty,
    final List value => value.isNotEmpty,
    _ => true,
  };

  static void _validateRoles(Object? roles) {
    if (roles is List && roles.length > 6) {
      throw ArgumentError('At most 6 text roles are supported');
    }
  }
}
