import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/enums/precise_ref_type.dart';
import 'package:nai_launcher/data/models/vibe/vibe_reference.dart';
import 'package:nai_launcher/core/utils/prompt_preset_resolution.dart';
import 'package:nai_launcher/data/models/image/image_params.dart';
import 'package:nai_launcher/data/models/fixed_tag/fixed_tag_usage_snapshot.dart';
import 'package:nai_launcher/presentation/providers/generation/generation_request_preparation_service.dart';

GenerationRequestPreparationService _profilePreparation(
  Future<ImageParams> Function(ImageParams) prepareVibes, {
  bool isOpenAiCompatible = true,
}) => GenerationRequestPreparationService(
  GenerationPreparationDependencies(
    prompt: GenerationPromptPreparation(
      randomModeEnabled: false,
      queueExecuting: false,
      generateAndApplyRandomPrompt: (_) async => '',
      resolveAliases: (value) => value,
      applyFixedPositiveTags: (value) => value,
      applyFixedNegativeTags: (value) => value,
      fixedTagUsageSnapshot: const FixedTagUsageSnapshot(),
      resolvePresets: (params) => PromptPresetResolution(
        prompt: params.prompt,
        negativePrompt: params.negativePrompt,
        qualityToggle: params.qualityToggle,
        ucPreset: params.ucPreset,
        omitQualityTagHint: params.omitQualityTagHint,
        omitUcPresetTagHint: params.omitUcPresetTagHint,
      ),
    ),
    characters: GenerationCharacterPreparation(
      read: (_) =>
          const CharacterPreparationSnapshot(characters: [], useCoords: false),
    ),
    vibes: GenerationVibePreparation(prepare: prepareVibes),
    focused: GenerationFocusedPreparation(
      read: () => const GenerationFocusedSnapshot(
        enabled: false,
        minimumContextMegaPixels: 0,
      ),
    ),
  ),
  isOpenAiCompatible: isOpenAiCompatible,
);

void main() {
  test(
    'profile preparation rejects invalid references before Vibe preparation',
    () async {
      var prepareCalls = 0;
      final vibe = VibeReference(
        displayName: 'raw',
        vibeEncoding: '',
        rawImageData: Uint8List.fromList([1]),
      );
      final precise = PreciseReference(
        image: Uint8List.fromList([1]),
        type: PreciseRefType.character,
      );
      final service = _profilePreparation((params) async {
        prepareCalls++;
        return params;
      });
      for (final params in [
        ImageParams(
          model: 'nai-diffusion-4-5-full',
          vibeReferencesV4: List.filled(5, vibe),
        ),
        ImageParams(
          model: 'nai-diffusion-4-5-full',
          vibeReferencesV4: [vibe],
          preciseReferences: [precise],
        ),
        ImageParams(model: 'nai-diffusion-5-full', vibeReferencesV4: [vibe]),
        ImageParams(
          model: 'nai-diffusion-4-full',
          preciseReferences: [precise],
        ),
      ]) {
        await expectLater(
          service.prepareInitial(params),
          throwsA(anyOf(isA<ArgumentError>(), isA<UnsupportedError>())),
        );
      }
      expect(prepareCalls, 0);
    },
  );

  test(
    'Chat preparation preserves raw references and count without native encoding',
    () async {
      var prepareCalls = 0;
      final raw = VibeReference(
        displayName: 'raw',
        vibeEncoding: '',
        rawImageData: Uint8List.fromList([1]),
      );
      final service = _profilePreparation((params) async {
        prepareCalls++;
        return params.copyWith(
          vibeReferencesV4: [raw.withEncodedVibe('AQID', model: params.model)],
        );
      });
      final result = await service.prepareInitial(
        ImageParams(
          model: 'nai-diffusion-4-5-full',
          nSamples: 3,
          vibeReferencesV4: [raw],
        ),
      );
      expect(prepareCalls, 0);
      expect(result.params.nSamples, 3);
      expect(result.params.vibeReferencesV4.single, raw);
    },
  );

  test(
    'Chat preparation rejects encoded-only Vibes without native encoding',
    () async {
      final service = _profilePreparation((_) async {
        fail('Native paid Vibe preparation must not run');
      });
      for (final raw in [null, Uint8List(0)]) {
        await expectLater(
          service.prepareInitial(
            ImageParams(
              model: 'nai-diffusion-4-5-full',
              vibeReferencesV4: [
                VibeReference(
                  displayName: 'encoded-only',
                  vibeEncoding: 'AQID',
                  rawImageData: raw,
                ),
              ],
            ),
          ),
          throwsA(isA<UnsupportedError>()),
        );
      }
    },
  );

  test(
    'official preparation still applies native Vibe cache updates',
    () async {
      var calls = 0;
      final service = _profilePreparation((params) async {
        calls++;
        return params.copyWith(
          vibeReferencesV4: const [
            VibeReference(displayName: 'cached', vibeEncoding: 'AQID'),
          ],
        );
      }, isOpenAiCompatible: false);
      final result = await service.prepareInitial(const ImageParams());
      expect(calls, 1);
      expect(result.params.vibeReferencesV4.single.vibeEncoding, 'AQID');
    },
  );

  test(
    'disabled aliases never reach expansion and request snapshots retain only active content',
    () async {
      final expanded = <String>[];
      final service = GenerationRequestPreparationService(
        GenerationPreparationDependencies(
          prompt: GenerationPromptPreparation(
            randomModeEnabled: false,
            queueExecuting: false,
            generateAndApplyRandomPrompt: (_) async => '',
            resolveAliases: (source) {
              expanded.add(source);
              return source;
            },
            applyFixedPositiveTags: (source) => '$source, /*disabled:fixed*/',
            applyFixedNegativeTags: (source) => source,
            fixedTagUsageSnapshot: const FixedTagUsageSnapshot(),
            resolvePresets: (params) => PromptPresetResolution(
              prompt: params.prompt,
              negativePrompt: params.negativePrompt,
              qualityToggle: false,
              ucPreset: 0,
              omitQualityTagHint: false,
              omitUcPresetTagHint: false,
            ),
          ),
          characters: GenerationCharacterPreparation(
            read: (_) => const CharacterPreparationSnapshot(
              characters: [
                CharacterPrompt(
                  prompt: 'girl, /*disabled:hat*/',
                  negativePrompt: '/*disabled:bad*/',
                ),
              ],
              useCoords: false,
            ),
          ),
          vibes: GenerationVibePreparation(prepare: (params) async => params),
          focused: GenerationFocusedPreparation(
            read: () => const GenerationFocusedSnapshot(
              enabled: false,
              minimumContextMegaPixels: 0,
            ),
          ),
        ),
      );
      const original = ImageParams(
        prompt: 'cat, /*disabled:<random:secret1,secret2>*/',
        negativePrompt: 'bad, /*disabled:noise*/',
      );
      final prepared = await service.prepareInitial(original);
      expect(expanded, ['cat', 'bad']);
      expect(prepared.params.prompt, 'cat');
      expect(prepared.params.negativePrompt, 'bad');
      expect(prepared.params.characters.single.prompt, 'girl');
      expect(prepared.params.characters.single.negativePrompt, '');
      expect(original.prompt, contains('/*disabled:'));
    },
  );
  test(
    'ordinary library alias insertion submits only its positive portion',
    () async {
      final service = GenerationRequestPreparationService(
        GenerationPreparationDependencies(
          prompt: GenerationPromptPreparation(
            randomModeEnabled: false,
            queueExecuting: false,
            generateAndApplyRandomPrompt: (_) async => '',
            resolveAliases: (prompt) => prompt == '<alice>'
                ? 'girl, blue eyes, negative(red hair, glasses)'
                : prompt,
            applyFixedPositiveTags: (prompt) =>
                '$prompt, negative(fixed literal)',
            applyFixedNegativeTags: (prompt) => prompt,
            fixedTagUsageSnapshot: const FixedTagUsageSnapshot(),
            resolvePresets: (params) => PromptPresetResolution(
              prompt: params.prompt,
              negativePrompt: params.negativePrompt,
              qualityToggle: params.qualityToggle,
              ucPreset: params.ucPreset,
              omitQualityTagHint: params.omitQualityTagHint,
              omitUcPresetTagHint: params.omitUcPresetTagHint,
            ),
          ),
          characters: GenerationCharacterPreparation(
            read: (_) => const CharacterPreparationSnapshot(
              characters: [],
              useCoords: false,
            ),
          ),
          vibes: GenerationVibePreparation(prepare: (params) async => params),
          focused: GenerationFocusedPreparation(
            read: () => const GenerationFocusedSnapshot(
              enabled: false,
              minimumContextMegaPixels: 0,
            ),
          ),
        ),
      );

      final result = await service.prepareInitial(
        const ImageParams(prompt: '<alice>', negativePrompt: 'global uc'),
      );

      expect(result.params.prompt, 'girl, blue eyes, negative(fixed literal)');
      expect(result.params.negativePrompt, 'global uc');
      expect(result.params.prompt, isNot(contains('red hair')));
      expect(result.params.prompt, isNot(contains('glasses')));
    },
  );
}
