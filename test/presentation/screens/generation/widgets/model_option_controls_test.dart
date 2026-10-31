import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nai_launcher/core/constants/api_constants.dart';
import 'package:nai_launcher/core/constants/storage_keys.dart';
import 'package:nai_launcher/core/enums/image_model_mode.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint_service.dart';
import 'package:nai_launcher/core/network/nai_compatible_request.dart';
import 'package:nai_launcher/core/storage/local_storage_service.dart';
import 'package:nai_launcher/data/models/vibe/vibe_library_entry.dart';
import 'package:nai_launcher/data/services/auth_provider.dart';
import 'package:nai_launcher/data/services/vibe_library_storage_service.dart';
import 'package:nai_launcher/l10n/app_localizations.dart';
import 'package:nai_launcher/presentation/providers/generation/generation_params_notifier.dart';
import 'package:nai_launcher/presentation/providers/generation/generation_params_selectors.dart';
import 'package:nai_launcher/presentation/providers/generation/image_workflow_controller.dart';
import 'package:nai_launcher/presentation/screens/generation/widgets/generation_param_sections.dart';
import 'package:nai_launcher/presentation/screens/generation/widgets/generation_toggle_button.dart';
import 'package:nai_launcher/presentation/screens/generation/widgets/img2img_adjustment_section.dart';
import 'package:nai_launcher/presentation/screens/generation/widgets/img2img_panel_data.dart';
import 'package:nai_launcher/presentation/widgets/common/themed_dropdown.dart';
import 'package:nai_launcher/presentation/widgets/common/themed_slider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory hiveTempDir;

  setUpAll(() async {
    hiveTempDir = await Directory.systemTemp.createTemp(
      'model_option_controls_test_',
    );
    Hive.init(hiveTempDir.path);
    // 内存后端：widget test 的 FakeAsync 时钟里发起的落盘写不会完成。
    await Hive.openBox(StorageKeys.settingsBox, bytes: Uint8List(0));
  });

  tearDown(() async {
    await Hive.box(StorageKeys.settingsBox).clear();
  });

  tearDownAll(() async {
    await Hive.close().timeout(const Duration(seconds: 10));
    if (await hiveTempDir.exists()) {
      await hiveTempDir.delete(recursive: true);
    }
  });

  Future<ProviderContainer> pumpSections(
    WidgetTester tester, {
    required String model,
    NaiApiEndpointConfig endpoint = NaiApiEndpointConfig.official,
    bool includeSize = false,
    bool includeEnhance = false,
    double width = 600,
    double textScale = 1,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(_TestAuthNotifier.new),
          naiApiEndpointServiceProvider.overrideWithValue(
            NaiApiEndpointService()..setCurrent(endpoint),
          ),
          localStorageServiceProvider.overrideWith(
            (ref) => _TestLocalStorageService(model),
          ),
          vibeLibraryStorageServiceProvider.overrideWithValue(
            _TestVibeLibraryStorageService(),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('zh'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const ModelSection(),
                  if (includeSize) const SizeSection(),
                  const StepsSection(),
                  const SamplerSection(),
                  const NoiseScheduleSection(),
                  const CfgScaleSection(),
                  const AdvancedSamplingOptions(),
                  if (includeEnhance)
                    Consumer(
                      builder: (context, ref, child) =>
                          Img2ImgAdjustmentSection(
                            data: Img2ImgPanelData(
                              params: ref.watch(
                                generationParamsNotifierProvider.select(
                                  selectImg2ImgPanelViewData,
                                ),
                              ),
                              workflow: ref.watch(
                                imageWorkflowControllerProvider,
                              ),
                            ),
                          ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return ProviderScope.containerOf(tester.element(find.byType(ModelSection)));
  }

  final modeToggle = find.byKey(const ValueKey('generation-model-mode'));
  final effortToggle = find.byKey(const ValueKey('generation-effort'));

  double titleCenter(WidgetTester tester) =>
      tester.getCenter(find.text('模型')).dy;

  ThemedSlider stepsSlider(WidgetTester tester) => tester
      .widgetList<ThemedSlider>(find.byType(ThemedSlider))
      .singleWhere((slider) => slider.max == 50);

  ThemedSlider cfgRescaleSlider(WidgetTester tester) => tester
      .widgetList<ThemedSlider>(find.byType(ThemedSlider))
      .singleWhere((slider) => slider.max == 1);

  final compatibleEndpoint = NaiApiEndpointConfig.fromInput(
    mainBaseUrl: 'https://compatible.example',
    protocol: NaiApiProtocol.openAiCompatible,
  );
  final genericEndpoint = NaiApiEndpointConfig.fromInput(
    mainBaseUrl: 'https://generic.example',
  );

  final varietyToggle = find.widgetWithText(GenerationToggleButton, 'Variety+');
  final maxChip = find.widgetWithText(ChoiceChip, '最大');

  for (final model in [
    ImageModels.animeDiffusionV5Full,
    ImageModels.animeDiffusionV5Curated,
    ImageModels.animeDiffusionV5FullMedium,
  ]) {
    testWidgets('compatible V5 Variety+ is off-only: $model', (tester) async {
      final container = await pumpSections(
        tester,
        model: model,
        endpoint: compatibleEndpoint,
      );
      expect(varietyToggle, findsNothing);
      final params = container.read(generationParamsNotifierProvider.notifier)
        ..updateVarietyPlus(true);
      await tester.pump();
      final toggle = tester.widget<GenerationToggleButton>(varietyToggle);
      expect(toggle.isEnabled, isTrue);
      expect(
        container.read(generationParamsNotifierProvider).varietyPlus,
        isTrue,
      );
      await tester.ensureVisible(varietyToggle);
      await tester.tap(varietyToggle);
      await tester.pump();
      expect(
        container.read(generationParamsNotifierProvider).varietyPlus,
        isFalse,
      );
      expect(varietyToggle, findsNothing);
      toggle.onChanged!(true);
      await tester.pump();
      expect(
        container.read(generationParamsNotifierProvider).varietyPlus,
        isFalse,
      );
      params.updateVarietyPlus(true);
      await tester.pump();
      expect(varietyToggle, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final endpoint in [NaiApiEndpointConfig.official, genericEndpoint]) {
    testWidgets(
      'non-profile V5 keeps Variety+ toggle: ${endpoint.mainBaseUrl}',
      (tester) async {
        final container = await pumpSections(
          tester,
          model: ImageModels.animeDiffusionV5Full,
          endpoint: endpoint,
        );
        await tester.ensureVisible(varietyToggle);
        await tester.tap(varietyToggle);
        await tester.pump();
        expect(
          container.read(generationParamsNotifierProvider).varietyPlus,
          isTrue,
        );
        await tester.tap(varietyToggle);
        await tester.pump();
        expect(
          container.read(generationParamsNotifierProvider).varietyPlus,
          isFalse,
        );
      },
    );
  }

  testWidgets('compatible V4.5 keeps Variety+ available', (tester) async {
    final container = await pumpSections(
      tester,
      model: ImageModels.animeDiffusionV45Full,
      endpoint: compatibleEndpoint,
    );
    await tester.ensureVisible(varietyToggle);
    await tester.tap(varietyToggle);
    await tester.pump();
    expect(
      container.read(generationParamsNotifierProvider).varietyPlus,
      isTrue,
    );
  });

  void enterEnhance(ProviderContainer container) {
    container
        .read(generationParamsNotifierProvider.notifier)
        .setSourceImage(Uint8List.fromList([1]));
    container.read(imageWorkflowControllerProvider.notifier)
      ..setSourceImageDimensions(768, 1024)
      ..enterEnhanceMode();
  }

  for (final endpoint in [NaiApiEndpointConfig.official, genericEndpoint]) {
    testWidgets('non-profile enhance keeps Max: ${endpoint.mainBaseUrl}', (
      tester,
    ) async {
      final container = await pumpSections(
        tester,
        model: ImageModels.animeDiffusionV5Full,
        endpoint: endpoint,
        includeEnhance: true,
      );
      enterEnhance(container);
      await tester.pump();
      expect(tester.widget<ChoiceChip>(maxChip).selected, isFalse);
      await tester.ensureVisible(maxChip);
      await tester.tap(maxChip);
      await tester.pump();
      expect(
        container.read(imageWorkflowControllerProvider).enhance.maxScale,
        isTrue,
      );
      expect(
        container.read(generationParamsNotifierProvider).upscaledEnhance,
        isTrue,
      );
      await tester.tap(find.widgetWithText(ChoiceChip, '1x'));
      await tester.pump();
      expect(
        container.read(imageWorkflowControllerProvider).enhance.maxScale,
        isFalse,
      );
      expect(
        container.read(generationParamsNotifierProvider).upscaledEnhance,
        isFalse,
      );
      expect(maxChip, findsOneWidget);
    });
  }

  for (final flagOnly in [false, true]) {
    testWidgets(
      'compatible enhance allows clearing saved Max, flag-only=$flagOnly',
      (tester) async {
        final container = await pumpSections(
          tester,
          model: ImageModels.animeDiffusionV5Full,
          endpoint: compatibleEndpoint,
          includeEnhance: true,
        );
        enterEnhance(container);
        await tester.pump();
        expect(maxChip, findsNothing);
        if (flagOnly) {
          container
              .read(generationParamsNotifierProvider.notifier)
              .updateUpscaledEnhance(true);
        } else {
          container
              .read(imageWorkflowControllerProvider.notifier)
              .selectEnhanceMaxScale();
        }
        await tester.pump();
        final chip = tester.widget<ChoiceChip>(maxChip);
        expect(chip.selected, isTrue);
        expect(
          container.read(generationParamsNotifierProvider).upscaledEnhance,
          isTrue,
        );
        await tester.ensureVisible(maxChip);
        await tester.tap(maxChip);
        await tester.pump();
        expect(
          container.read(imageWorkflowControllerProvider).enhance.maxScale,
          isFalse,
        );
        expect(
          container.read(generationParamsNotifierProvider).upscaledEnhance,
          isFalse,
        );
        expect(maxChip, findsNothing);
        chip.onSelected!(true);
        await tester.pump();
        expect(
          container.read(imageWorkflowControllerProvider).enhance.maxScale,
          isFalse,
        );
        expect(
          container.read(generationParamsNotifierProvider).upscaledEnhance,
          isFalse,
        );
        expect(maxChip, findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'account switch keeps unsupported values until explicitly cleared',
    (tester) async {
      final container = await pumpSections(
        tester,
        model: ImageModels.animeDiffusionV5Full,
        includeEnhance: true,
      );
      enterEnhance(container);
      container
          .read(generationParamsNotifierProvider.notifier)
          .updateVarietyPlus(true);
      container
          .read(imageWorkflowControllerProvider.notifier)
          .selectEnhanceMaxScale();
      await tester.pump();
      final auth =
          container.read(authNotifierProvider.notifier) as _TestAuthNotifier;
      auth.switchEndpoint(compatibleEndpoint);
      await tester.pump();
      expect(
        tester.widget<GenerationToggleButton>(varietyToggle).isEnabled,
        isTrue,
      );
      expect(tester.widget<ChoiceChip>(maxChip).selected, isTrue);
      await tester.ensureVisible(varietyToggle);
      await tester.tap(varietyToggle);
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, '1x'));
      await tester.tap(find.widgetWithText(ChoiceChip, '1x'));
      await tester.pump();
      expect(
        container.read(generationParamsNotifierProvider).varietyPlus,
        isFalse,
      );
      expect(
        container.read(generationParamsNotifierProvider).upscaledEnhance,
        isFalse,
      );
      expect(
        container.read(imageWorkflowControllerProvider).enhance.maxScale,
        isFalse,
      );
      expect(varietyToggle, findsNothing);
      expect(maxChip, findsNothing);
      auth.switchEndpoint(NaiApiEndpointConfig.official);
      await tester.pump();
      expect(varietyToggle, findsOneWidget);
      expect(maxChip, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  ThemedDropdown<String> modelDropdown(WidgetTester tester) =>
      tester.widget<ThemedDropdown<String>>(
        find.descendant(
          of: find.byType(ModelSection),
          matching: find.byType(ThemedDropdown<String>),
        ),
      );

  ThemedDropdown<String> samplerDropdown(WidgetTester tester) =>
      tester.widget<ThemedDropdown<String>>(
        find.descendant(
          of: find.byType(SamplerSection),
          matching: find.byType(ThemedDropdown<String>),
        ),
      );

  String? renderedModelSelection(WidgetTester tester) => tester
      .state<FormFieldState<String>>(
        find.descendant(
          of: find.byType(ModelSection),
          matching: find.byType(DropdownButtonFormField<String>),
        ),
      )
      .value;

  for (final model in NaiCompatibleRequest.generationModels) {
    testWidgets('compatible profile offers exactly five models for $model', (
      tester,
    ) async {
      final container = await pumpSections(
        tester,
        model: model,
        endpoint: compatibleEndpoint,
      );

      final dropdown = modelDropdown(tester);
      expect(
        dropdown.items.map((item) => item.value),
        unorderedEquals(NaiCompatibleRequest.generationModels),
      );
      expect(dropdown.value, model);
      expect(container.read(generationParamsNotifierProvider).model, model);
      expect(effortToggle, findsNothing);
      expect(modeToggle, findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  for (final model in [
    ImageModels.animeDiffusionV3,
    ImageModels.animeDiffusionV4Curated,
    ImageModels.animeDiffusionV5FullMedium,
    'unknown-saved-model',
  ]) {
    testWidgets('compatible profile preserves unsupported saved model $model', (
      tester,
    ) async {
      final container = await pumpSections(
        tester,
        model: model,
        endpoint: compatibleEndpoint,
      );

      final dropdown = modelDropdown(tester);
      expect(dropdown.value, isNull);
      expect(dropdown.hintText, contains(model));
      expect(dropdown.items.map((item) => item.value), isNot(contains(model)));
      expect(container.read(generationParamsNotifierProvider).model, model);
      expect(effortToggle, findsNothing);
      expect(tester.takeException(), isNull);

      // Explicitly choosing High works even when Medium shares its selector ID.
      await tester.tap(find.byType(ThemedDropdown<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('NAI Diffusion V5 (Full)').last);
      await tester.pumpAndSettle();
      expect(
        container.read(generationParamsNotifierProvider).model,
        ImageModels.animeDiffusionV5Full,
      );
      expect(stepsSlider(tester).onChanged, isNotNull);
    });
  }

  testWidgets('generic third-party keeps official model and effort options', (
    tester,
  ) async {
    final container = await pumpSections(
      tester,
      model: ImageModels.animeDiffusionV5FullMedium,
      endpoint: genericEndpoint,
    );

    expect(effortToggle, findsOneWidget);
    expect(modelDropdown(tester).value, ImageModels.animeDiffusionV5Full);
    expect(
      modelDropdown(tester).items.map((item) => item.value),
      contains(ImageModels.animeDiffusionV3),
    );
    modelDropdown(tester).onChanged!(ImageModels.animeDiffusionV5Full);
    await tester.pump();
    expect(
      container.read(generationParamsNotifierProvider).model,
      ImageModels.animeDiffusionV5FullMedium,
    );
  });

  testWidgets(
    'account transitions rebuild profile restrictions without edits',
    (tester) async {
      final container = await pumpSections(
        tester,
        model: ImageModels.animeDiffusionV5FullMedium,
        includeSize: true,
      );
      final params = container.read(generationParamsNotifierProvider.notifier)
        ..updateE2eUpscale(true);
      final auth =
          container.read(authNotifierProvider.notifier) as _TestAuthNotifier;
      await tester.pump();
      expect(effortToggle, findsOneWidget);
      expect(renderedModelSelection(tester), ImageModels.animeDiffusionV5Full);

      auth.switchEndpoint(compatibleEndpoint);
      await tester.pump();
      expect(effortToggle, findsNothing);
      expect(modelDropdown(tester).value, isNull);
      expect(renderedModelSelection(tester), isNull);
      expect(find.widgetWithText(GenerationToggleButton, '×2'), findsOneWidget);
      expect(
        container.read(generationParamsNotifierProvider).model,
        ImageModels.animeDiffusionV5FullMedium,
      );
      expect(
        container.read(generationParamsNotifierProvider).e2eUpscale,
        isTrue,
      );

      params
        ..updateModel(ImageModels.animeDiffusionV5Full)
        ..updateSampler(Samplers.kDpm2Ancestral);
      await tester.pump();
      expect(samplerDropdown(tester).value, isNull);
      params.updateSampler(Samplers.kEulerAncestral);
      auth.switchEndpoint(genericEndpoint);
      await tester.pump();
      expect(effortToggle, findsOneWidget);
      expect(modelDropdown(tester).value, ImageModels.animeDiffusionV5Full);
      expect(samplerDropdown(tester).value, Samplers.kEulerAncestral);
      expect(tester.takeException(), isNull);
    },
  );

  for (final model in [
    ImageModels.animeDiffusionV5Full,
    ImageModels.animeDiffusionV3,
  ]) {
    testWidgets('compatible e2e upscale is off-only, including saved $model', (
      tester,
    ) async {
      final container = await pumpSections(
        tester,
        model: model,
        endpoint: compatibleEndpoint,
        includeSize: true,
      );
      final toggleFinder = find.widgetWithText(GenerationToggleButton, '×2');
      expect(toggleFinder, findsNothing);
      container
          .read(generationParamsNotifierProvider.notifier)
          .updateE2eUpscale(true);
      await tester.pump();
      final toggle = tester.widget<GenerationToggleButton>(toggleFinder);
      expect(toggle.isEnabled, isTrue);
      await tester.tap(toggleFinder);
      await tester.pump();
      expect(
        container.read(generationParamsNotifierProvider).e2eUpscale,
        isFalse,
      );
      expect(toggleFinder, findsNothing);
      // Even a callback retained from the previous frame cannot enable it.
      toggle.onChanged!(true);
      await tester.pump();
      expect(
        container.read(generationParamsNotifierProvider).e2eUpscale,
        isFalse,
      );
      expect(toggleFinder, findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final model in [
    ImageModels.animeDiffusionV5Full,
    ImageModels.animeDiffusionV5Curated,
  ]) {
    testWidgets(
      'compatible V5 preserves but cannot choose DPM2 Ancestral: $model',
      (tester) async {
        final container = await pumpSections(
          tester,
          model: model,
          endpoint: compatibleEndpoint,
        );
        container
            .read(generationParamsNotifierProvider.notifier)
            .updateSampler(Samplers.kDpm2Ancestral);
        await tester.pump();
        final dropdown = samplerDropdown(tester);
        expect(
          dropdown.items.map((item) => item.value),
          isNot(contains(Samplers.kDpm2Ancestral)),
        );
        expect(dropdown.value, isNull);
        expect(dropdown.hintText, contains(Samplers.kDpm2Ancestral));
        dropdown.onChanged!(Samplers.kDpm2Ancestral);
        expect(
          container.read(generationParamsNotifierProvider).sampler,
          Samplers.kDpm2Ancestral,
        );
        dropdown.onChanged!(Samplers.kEulerAncestral);
        await tester.pump();
        expect(samplerDropdown(tester).value, Samplers.kEulerAncestral);
        // A rejected callback cannot replace a now-valid selection.
        samplerDropdown(tester).onChanged!(Samplers.kDpm2Ancestral);
        expect(
          container.read(generationParamsNotifierProvider).sampler,
          Samplers.kEulerAncestral,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final width in [320.0, 600.0, 840.0, 1180.0, 1600.0]) {
    testWidgets(
      'compatible saved Medium is recoverable at ${width}px, 3x text',
      (tester) async {
        final container = await pumpSections(
          tester,
          model: ImageModels.animeDiffusionV5FullMedium,
          endpoint: compatibleEndpoint,
          width: width,
          textScale: 3,
        );
        expect(effortToggle, findsNothing);
        expect(modeToggle, findsOneWidget);
        expect(
          modelDropdown(tester).hintText,
          ImageModels.animeDiffusionV5FullMedium,
        );
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('兽人'));
        await tester.tap(find.text('兽人'));
        await tester.pump();
        expect(
          container.read(generationParamsNotifierProvider).modelMode,
          ImageModelMode.furry,
        );
        await tester.ensureVisible(find.byType(ThemedDropdown<String>).first);
        await tester.tap(find.byType(ThemedDropdown<String>).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('NAI Diffusion V5 (Full)').last);
        await tester.pumpAndSettle();
        expect(
          container.read(generationParamsNotifierProvider).model,
          ImageModels.animeDiffusionV5Full,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('V5 Full shows mode and effort, starting on the full model', (
    tester,
  ) async {
    await pumpSections(tester, model: ImageModels.animeDiffusionV5Full);

    expect(modeToggle, findsOneWidget);
    expect(effortToggle, findsOneWidget);
    for (final label in ['动漫', '兽人', '节约', '标准']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('模式'), findsNothing);
    expect(find.text('生成档位'), findsNothing);
    expect(stepsSlider(tester).onChanged, isNotNull);
  });

  testWidgets('switching to Medium locks the controls it takes over', (
    tester,
  ) async {
    final container = await pumpSections(
      tester,
      model: ImageModels.animeDiffusionV5Full,
    );

    await tester.tap(find.text('节约'));
    await tester.pump();

    expect(
      container.read(generationParamsNotifierProvider).model,
      ImageModels.animeDiffusionV5FullMedium,
    );
    final modelDropdown = tester.widget<ThemedDropdown<String>>(
      find.byType(ThemedDropdown<String>).first,
    );
    expect(modelDropdown.value, ImageModels.animeDiffusionV5Full);

    expect(find.text('步数: 14'), findsOneWidget);
    expect(stepsSlider(tester).onChanged, isNull);
    final dropdowns = tester
        .widgetList<ThemedDropdown<String>>(find.byType(ThemedDropdown<String>))
        .skip(1);
    expect(dropdowns.every((dropdown) => dropdown.onChanged == null), isTrue);
    expect(
      dropdowns.map((dropdown) => dropdown.value),
      containsAll([Samplers.kEulerAncestral, NoiseSchedules.karras]),
    );
    expect(cfgRescaleSlider(tester).onChanged, isNull);
    expect(find.textContaining('节约档'), findsNothing);
    final varietyPlus = tester.widget<GenerationToggleButton>(
      find.widgetWithText(GenerationToggleButton, 'Variety+'),
    );
    expect(varietyPlus.onChanged, isNull);
    expect(varietyPlus.isEnabled, isFalse);

    await tester.tap(find.text('标准'));
    await tester.pump();
    expect(
      container.read(generationParamsNotifierProvider).model,
      ImageModels.animeDiffusionV5Full,
    );
    expect(stepsSlider(tester).onChanged, isNotNull);
    expect(cfgRescaleSlider(tester).onChanged, isNotNull);
  });

  testWidgets('re-selecting V5 Full in the dropdown keeps Medium', (
    tester,
  ) async {
    final container = await pumpSections(
      tester,
      model: ImageModels.animeDiffusionV5FullMedium,
    );

    tester
        .widget<ThemedDropdown<String>>(
          find.byType(ThemedDropdown<String>).first,
        )
        .onChanged!(ImageModels.animeDiffusionV5Full);
    await tester.pump();

    expect(
      container.read(generationParamsNotifierProvider).model,
      ImageModels.animeDiffusionV5FullMedium,
    );
  });

  testWidgets('furry mode toggles without an inline explanation', (
    tester,
  ) async {
    final container = await pumpSections(
      tester,
      model: ImageModels.animeDiffusionV45Full,
    );

    expect(effortToggle, findsNothing);
    await tester.tap(find.text('兽人'));
    await tester.pump();

    expect(
      container.read(generationParamsNotifierProvider).modelMode,
      ImageModelMode.furry,
    );
    expect(find.textContaining('fur dataset'), findsNothing);
  });

  testWidgets('mode and effort sit right-aligned in the model title row', (
    tester,
  ) async {
    await pumpSections(tester, model: ImageModels.animeDiffusionV5Full);

    for (final toggle in [modeToggle, effortToggle]) {
      expect(
        tester.getCenter(toggle).dy,
        moreOrLessEquals(titleCenter(tester), epsilon: 1),
      );
    }
    final dropdown = tester.getRect(find.byType(ThemedDropdown<String>).first);
    final mode = tester.getRect(modeToggle);
    final effort = tester.getRect(effortToggle);
    expect(mode.right, lessThan(effort.left));
    expect(effort.right, moreOrLessEquals(dropdown.right, epsilon: 1));
    expect(effort.bottom, lessThanOrEqualTo(dropdown.top));
  });

  testWidgets('models without furry mode or effort show neither control', (
    tester,
  ) async {
    await pumpSections(tester, model: ImageModels.animeDiffusionV3);

    expect(modeToggle, findsNothing);
    expect(effortToggle, findsNothing);
  });

  testWidgets('advanced sampling options render nothing without controls', (
    tester,
  ) async {
    final advancedContent = find.descendant(
      of: find.byType(AdvancedSamplingOptions),
      matching: find.byType(Column),
    );
    final container = await pumpSections(
      tester,
      model: ImageModels.furryDiffusion,
    );
    expect(advancedContent, findsNothing);

    final notifier = container.read(generationParamsNotifierProvider.notifier)
      ..updateModel(ImageModels.animeDiffusionV3);
    await tester.pump();
    expect(advancedContent, findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AdvancedSamplingOptions),
        matching: find.text('SMEA'),
      ),
      findsWidgets,
    );

    notifier.updateSampler(Samplers.ddim);
    await tester.pump();
    expect(advancedContent, findsNothing);

    notifier.updateModel(ImageModels.animeDiffusionV5FullMedium);
    await tester.pump();
    expect(advancedContent, findsOneWidget);
    expect(cfgRescaleSlider(tester).onChanged, isNull);
  });

  for (final width in [320.0, 600.0, 840.0]) {
    testWidgets('Medium stays fully reachable at ${width.toInt()}px, 3x text', (
      tester,
    ) async {
      final container = await pumpSections(
        tester,
        model: ImageModels.animeDiffusionV5FullMedium,
        width: width,
        textScale: 3,
      );

      expect(tester.takeException(), isNull);
      for (final label in ['动漫', '兽人', '节约', '标准']) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      expect(stepsSlider(tester).onChanged, isNull);
      expect(find.textContaining('节约档'), findsNothing);
      expect(
        tester.getCenter(effortToggle).dy,
        moreOrLessEquals(titleCenter(tester), epsilon: 1),
      );

      await tester.ensureVisible(find.text('标准'));
      await tester.pump();
      await tester.tap(find.text('标准'));
      await tester.pump();
      expect(
        container.read(generationParamsNotifierProvider).model,
        ImageModels.animeDiffusionV5Full,
      );
    });
  }
}

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.authenticated);

  void switchEndpoint(NaiApiEndpointConfig endpoint) {
    ref.read(naiApiEndpointServiceProvider).setCurrent(endpoint);
    state = AuthState(
      status: AuthStatus.authenticated,
      accountId: endpoint.mainBaseUrl,
    );
  }
}

class _TestLocalStorageService extends LocalStorageService {
  _TestLocalStorageService(this._model);

  final String _model;
  final Map<String, Object?> _settings = {};

  @override
  T? getSetting<T>(String key, {T? defaultValue}) {
    final value = _settings[key];
    return value is T ? value : defaultValue;
  }

  @override
  Future<void> setSetting<T>(String key, T value) async {
    _settings[key] = value;
  }

  @override
  String getLastPrompt() => '';

  @override
  String getLastNegativePrompt() => '';

  @override
  String getDefaultModel() => _model;

  @override
  String getDefaultSampler() => Samplers.kDpmpp2m;

  @override
  int getDefaultSteps() => 28;

  @override
  double getDefaultScale() => 4.0;

  @override
  int getDefaultWidth() => 832;

  @override
  int getDefaultHeight() => 1216;

  @override
  bool getLastSmea() => false;

  @override
  bool getLastSmeaDyn() => false;

  @override
  double getLastCfgRescale() => 0.0;

  @override
  String getLastNoiseSchedule() => NoiseSchedules.exponential;

  @override
  bool getLastVarietyPlus() => false;

  @override
  bool getSeedLocked() => false;

  @override
  int? getLockedSeedValue() => null;
}

class _TestVibeLibraryStorageService extends VibeLibraryStorageService {
  @override
  Future<List<VibeLibraryEntry>> getRecentDisplayEntries({
    int limit = 20,
  }) async {
    return const [];
  }

  @override
  Future<void> saveGenerationStateUtf8Json(Uint8List stateJson) async {}
}
