import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:nai_launcher/core/constants/app_version.dart';
import 'package:nai_launcher/core/constants/storage_keys.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint_service.dart';
import 'package:nai_launcher/core/platform/platform_capabilities.dart';
import 'package:nai_launcher/core/services/provider_pricing_service.dart';
import 'package:nai_launcher/core/shortcuts/shortcut_config.dart';
import 'package:nai_launcher/core/storage/local_storage_service.dart';
import 'package:nai_launcher/data/models/image/image_params.dart';
import 'package:nai_launcher/data/models/user/user_subscription.dart';
import 'package:nai_launcher/data/services/account_manager_provider.dart';
import 'package:nai_launcher/data/services/auth_provider.dart';
import 'package:nai_launcher/l10n/app_localizations.dart';
import 'package:nai_launcher/presentation/adaptive/interaction_policy.dart';
import 'package:nai_launcher/presentation/providers/cost_estimate_provider.dart';
import 'package:nai_launcher/presentation/providers/generation_layout_mode_provider.dart';
import 'package:nai_launcher/presentation/providers/image_generation_provider.dart';
import 'package:nai_launcher/presentation/providers/krita/krita_bridge_notifier.dart';
import 'package:nai_launcher/presentation/providers/provider_billing_provider.dart';
import 'package:nai_launcher/presentation/providers/provider_pricing_provider.dart';
import 'package:nai_launcher/presentation/providers/queue_execution_provider.dart';
import 'package:nai_launcher/presentation/providers/replication_queue_provider.dart';
import 'package:nai_launcher/presentation/providers/shortcuts_provider.dart';
import 'package:nai_launcher/presentation/providers/subscription_provider.dart';
import 'package:nai_launcher/presentation/providers/update_provider.dart';
import 'package:nai_launcher/presentation/router/app_branch.dart';
import 'package:nai_launcher/presentation/router/desktop_shell.dart';
import 'package:nai_launcher/presentation/screens/generation/generation_screen.dart';
import 'package:nai_launcher/presentation/screens/generation/widgets/generation_controls/generation_controls.dart';
import 'package:nai_launcher/presentation/widgets/common/themed_confirm_dialog.dart';

// Real DesktopShell + complete GenerationScreen; only side effects are faked.
// A tap must traverse the real GenerationControls._handleGenerate and guard.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    PackageInfo.setMockInitialValues(
      appName: 'NAI Launcher',
      packageName: 'nai_launcher',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
    await AppVersion.initialize();
    await Hive.openBox<dynamic>(StorageKeys.settingsBox, bytes: Uint8List(0));
    await Hive.openBox<dynamic>(StorageKeys.historyBox, bytes: Uint8List(0));
  });
  tearDownAll(() => Hive.close().timeout(const Duration(seconds: 10)));

  for (final mode in GenerationLayoutMode.values) {
    for (final width in [1180.0, 1600.0]) {
      testWidgets(
        '${mode.name} $width desktop price tap reaches notifier through guard',
        (tester) async {
          final harness = await _pumpShell(tester, mode, width);
          final l10n = AppLocalizations.of(
            tester.element(find.byType(GenerationControls)),
          )!;
          expect(find.byType(DesktopShell), findsOneWidget);
          expect(find.byType(GenerationScreen), findsOneWidget);
          final price = find.text('预计 0.05');
          expect(price.hitTestable(), findsOneWidget);
          final primary = find.ancestor(
            of: price,
            matching: find.byType(FilledButton),
          );
          final refresh = find.byKey(const ValueKey('provider-price-refresh'));
          expect(
            tester.getRect(primary).overlaps(tester.getRect(refresh)),
            isFalse,
          );
          expect(
            find.descendant(of: primary, matching: find.byType(IconButton)),
            findsNothing,
          );

          await tester.tap(refresh);
          await tester.pump();
          expect(harness.catalog.refreshCount, 1);
          expect(harness.generation.generateCount, 0);
          await tester.tap(price);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          expect(find.byType(ThemedConfirmDialog), findsOneWidget);
          expect(
            harness.generation.generateCount,
            0,
            reason: 'guard must precede notifier',
          );
          await tester.tap(find.text(l10n.common_cancel));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          expect(harness.generation.generateCount, 0);
          await tester.tap(price);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          await tester.tap(find.text(l10n.settings_continueGeneration));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 200));
          expect(harness.generation.generateCount, 1);
          expect(harness.generation.lastParams?.prompt, 'a quiet landscape');
          expect(harness.catalog.refreshCount, 1);

          harness.cooldown.setRemaining(3);
          await tester.pump();
          expect(tester.widget<FilledButton>(primary).onPressed, isNull);
          await tester.tap(price);
          await tester.pump();
          expect(harness.generation.generateCount, 1);
          expect(find.byType(ThemedConfirmDialog), findsNothing);
          harness.cooldown.setRemaining(0);
          harness.krita.setGenerating(true);
          await tester.pump();
          expect(tester.widget<FilledButton>(primary).onPressed, isNull);
          await tester.tap(price);
          expect(harness.generation.generateCount, 1);
          harness.krita.setGenerating(false);
          harness.generation.setState(
            const ImageGenerationState(isSubmitting: true),
          );
          await tester.pump();
          expect(find.text(l10n.common_cancel).hitTestable(), findsOneWidget);
          await tester.tap(find.text(l10n.common_cancel));
          await tester.pump();
          expect(harness.generation.cancelCount, 1);
          harness.generation.setState(
            const ImageGenerationState(
              status: GenerationStatus.generating,
              currentImage: 1,
              totalImages: 2,
            ),
          );
          await tester.pump();
          await tester.tap(
            find.text('${l10n.generation_skipCurrentBatch} 1/2'),
          );
          expect(harness.generation.skipCount, 1);
          await tester.tap(find.text(l10n.common_cancel));
          await tester.pump();
          expect(harness.generation.cancelCount, 2);
          harness.generation.setState(
            const ImageGenerationState(
              status: GenerationStatus.completed,
              isSubmitting: true,
              isSaving: true,
            ),
          );
          await tester.pump();
          final saving = find.text(l10n.common_saving);
          expect(saving, findsOneWidget);
          final savingButton = find.ancestor(
            of: saving,
            matching: find.byType(FilledButton),
          );
          expect(tester.widget<FilledButton>(savingButton).onPressed, isNull);
          expect(
            find.descendant(
              of: savingButton,
              matching: find.byType(CircularProgressIndicator),
            ),
            findsNothing,
          );
          await tester.tap(saving);
          expect(harness.generation.generateCount, 1);
          harness.generation.setState(
            const ImageGenerationState(
              status: GenerationStatus.completed,
              isSubmitting: true,
            ),
          );
          await tester.pump();
          expect(find.text(l10n.comfyWorkflow_processing), findsOneWidget);
          expect(
            tester
                .widget<FilledButton>(
                  find.ancestor(
                    of: find.text(l10n.comfyWorkflow_processing),
                    matching: find.byType(FilledButton),
                  ),
                )
                .onPressed,
            isNull,
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump(const Duration(milliseconds: 500));
          harness.container.dispose();
        },
      );
    }
  }
}

Future<_Harness> _pumpShell(
  WidgetTester tester,
  GenerationLayoutMode mode,
  double width,
) async {
  PlatformCapabilities.debugOverride = PlatformCapabilities.forPlatform(
    TargetPlatform.windows,
  );
  addTearDown(() => PlatformCapabilities.debugOverride = null);
  await tester.binding.setSurfaceSize(Size(width, 950));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final shell = _NavigationShell();
  when(() => shell.currentIndex).thenReturn(AppBranch.generation.index);
  final endpoint = NaiApiEndpointService()
    ..setCurrent(
      NaiApiEndpointConfig.fromInput(
        mainBaseUrl: 'https://example.invalid',
        protocol: NaiApiProtocol.openAiCompatible,
      ),
    );
  addTearDown(endpoint.dispose);
  final generation = _Generation();
  final cooldown = _Cooldown();
  final krita = _Krita();
  final catalog = _Catalog();
  final container = ProviderContainer(
    overrides: [
      localStorageServiceProvider.overrideWith((ref) => _Storage()),
      authNotifierProvider.overrideWith(_Auth.new),
      accountManagerNotifierProvider.overrideWith(_Accounts.new),
      updateStateNotifierProvider.overrideWith(_Update.new),
      imageGenerationNotifierProvider.overrideWith(() => generation),
      generationParamsNotifierProvider.overrideWith(_Params.new),
      generationCooldownProvider.overrideWith(() => cooldown),
      kritaBridgeNotifierProvider.overrideWith((ref) => krita),
      generationLayoutModeNotifierProvider.overrideWith(
        () => _LayoutMode(mode),
      ),
      shortcutConfigNotifierProvider.overrideWith(_Shortcuts.new),
      replicationQueueNotifierProvider.overrideWith(_Queue.new),
      queueExecutionNotifierProvider.overrideWith(_Execution.new),
      subscriptionNotifierProvider.overrideWith(_Subscription.new),
      naiApiEndpointServiceProvider.overrideWithValue(endpoint),
      providerPricingOriginSupportedProvider.overrideWith((ref) => true),
      providerPricingCatalogProvider.overrideWith(() => catalog),
      providerPriceEstimateProvider.overrideWith(
        (ref) =>
            const ProviderPriceEstimate(lowerMicros: 50000, upperMicros: 50000),
      ),
      providerBillingSummaryProvider.overrideWith((ref) => null),
      estimatedCostProvider.overrideWith((ref) => 0),
      isFreeGenerationProvider.overrideWith((ref) => true),
    ],
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('zh'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: InteractionPolicyScope(
          initialPolicy: const InteractionPolicy(
            modality: InteractionModality.pointer,
            touchAvailable: false,
            precisePointerAvailable: true,
          ),
          child: DesktopShell(
            navigationShell: shell,
            content: const GenerationScreen(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  return _Harness(container, generation, cooldown, krita, catalog);
}

class _Harness {
  _Harness(
    this.container,
    this.generation,
    this.cooldown,
    this.krita,
    this.catalog,
  );
  final ProviderContainer container;
  final _Generation generation;
  final _Cooldown cooldown;
  final _Krita krita;
  final _Catalog catalog;
}

class _Generation extends ImageGenerationNotifier {
  int generateCount = 0;
  int cancelCount = 0;
  int skipCount = 0;
  ImageParams? lastParams;
  @override
  ImageGenerationState build() => const ImageGenerationState();
  void setState(ImageGenerationState value) => state = value;
  @override
  Future<void> generate(
    ImageParams params, {
    int? batchSizeOverride,
    bool preserveCharacterSnapshot = false,
    GenerationFocusedSnapshot? focusedOverride,
    bool bypassRandomPrompt = false,
  }) async {
    generateCount++;
    lastParams = params;
  }

  @override
  void cancel() {
    cancelCount++;
    state = const ImageGenerationState();
  }

  @override
  void skipCurrentRequest() => skipCount++;
}

class _Params extends GenerationParamsNotifier {
  @override
  ImageParams build() => const ImageParams(prompt: 'a quiet landscape');
  @override
  Future<void> restoreGenerationState() async {}
  @override
  Future<void> loadPanelStates() async {}
}

class _Cooldown extends GenerationCooldownNotifier {
  @override
  GenerationCooldownState build() => const GenerationCooldownState();
  void setRemaining(int value) =>
      state = GenerationCooldownState(remainingSeconds: value);
}

class _Krita extends KritaBridgeNotifier {
  void setGenerating(bool value) =>
      state = KritaBridgeState(activeRequestId: value ? 'fake-krita' : null);
  @override
  Future<void> close() async {}
}

class _Catalog extends ProviderPricingCatalogNotifier {
  int refreshCount = 0;
  @override
  Future<ProviderPricingResult?> build() async => null;
  @override
  Future<void> refresh() async {
    refreshCount++;
  }
}

class _LayoutMode extends GenerationLayoutModeNotifier {
  _LayoutMode(this.mode);
  final GenerationLayoutMode mode;
  @override
  GenerationLayoutMode build() => mode;
}

class _Storage extends LocalStorageService {
  final values = <String, Object?>{StorageKeys.protectionMode: true};
  @override
  T? getSetting<T>(String key, {T? defaultValue}) =>
      values.containsKey(key) ? values[key] as T? : defaultValue;
  @override
  Future<void> setSetting<T>(String key, T value) async {
    values[key] = value;
  }
}

class _Auth extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.authenticated);
}

class _Accounts extends AccountManagerNotifier {
  @override
  AccountManagerState build() => const AccountManagerState();
}

class _Update extends UpdateStateNotifier {
  @override
  UpdateState build() => const UpdateState();
}

class _Subscription extends SubscriptionNotifier {
  @override
  SubscriptionState build() => const SubscriptionState.initial();
}

class _Queue extends ReplicationQueueNotifier {
  @override
  ReplicationQueueState build() => const ReplicationQueueState();
}

class _Execution extends QueueExecutionNotifier {
  @override
  QueueExecutionState build() => const QueueExecutionState();
}

class _Shortcuts extends ShortcutConfigNotifier {
  @override
  Future<ShortcutConfig> build() async => ShortcutConfig.createDefault();
}

class _NavigationShell extends Mock implements StatefulNavigationShell {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) =>
      '_NavigationShell';
}
