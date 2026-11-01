import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/services/provider_pricing_service.dart';
import 'package:nai_launcher/core/models/provider_generation_usage.dart';
import 'package:nai_launcher/data/models/image/image_params.dart';
import 'package:nai_launcher/data/models/user/user_subscription.dart';
import 'package:nai_launcher/presentation/providers/cost_estimate_provider.dart';
import 'package:nai_launcher/presentation/providers/subscription_provider.dart';
import 'package:nai_launcher/presentation/screens/generation/mobile_generation_chrome.dart';
import 'package:nai_launcher/presentation/screens/generation/mobile_generation_controller.dart';
import 'package:nai_launcher/presentation/screens/generation/mobile_generation_view_data.dart';
import 'package:nai_launcher/presentation/widgets/common/owned_scroll_controller.dart';
import 'package:nai_launcher/l10n/app_localizations.dart';
import 'package:nai_launcher/presentation/providers/generation/image_workflow_controller.dart';
import 'package:nai_launcher/presentation/providers/image_generation_provider.dart';
import 'package:nai_launcher/presentation/providers/provider_billing_provider.dart';
import 'package:nai_launcher/presentation/providers/provider_pricing_provider.dart';
import 'package:nai_launcher/presentation/screens/generation/widgets/generation_controls/generate_button.dart';
import 'package:nai_launcher/presentation/widgets/common/anlas_cost_badge.dart';
import 'package:nai_launcher/presentation/widgets/common/provider_price_badge.dart';

class _Params extends GenerationParamsNotifier {
  @override
  ImageParams build() => const ImageParams(model: 'nai-diffusion-4-5-full');
}

class _Workflow extends ImageWorkflowController {
  _Workflow([this.workflow = const ImageWorkflowState()]);
  final ImageWorkflowState workflow;
  @override
  ImageWorkflowState build() => workflow;
}

class _Catalog extends ProviderPricingCatalogNotifier {
  static int refreshes = 0;
  @override
  Future<ProviderPricingResult?> build() async => ProviderPricingResult(
    isStale: true,
    error: ProviderPricingError.network,
    catalog: ProviderPricingCatalog.fromJson({
      'success': true,
      'pricing_version': 'rules-v7',
      'group_ratio': {'NovelAI分组': 1},
      'data': [
        {
          'model_name': 'nai-diffusion-4-5-full',
          'billing_mode': 'tiered_expr',
          'enable_groups': ['NovelAI分组'],
          'billing_expr':
              'p==1&&c>=10000&&floor(c/10000)*10000==c?tier("anlas",50000+c*1):tier("base",fixed(0.05))',
        },
      ],
    }, fetchedAt: DateTime.utc(2026, 10, 31)),
  );
  @override
  Future<void> refresh() async {
    refreshes++;
  }
}

class _Subscription extends SubscriptionNotifier {
  @override
  SubscriptionState build() => const SubscriptionState.initial();
}

class _LoadingCatalog extends ProviderPricingCatalogNotifier {
  _LoadingCatalog(this.completer);
  final Completer<ProviderPricingResult?> completer;
  @override
  Future<ProviderPricingResult?> build() => completer.future;
}

class _MobileController extends Fake implements MobileGenerationController {
  @override
  bool get agentFullScreen => false;
  @override
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void openParameterDrawer() {}
  @override
  void openAgentChat() {}
  @override
  void openHistoryDrawer() {}
  @override
  void closePromptEditor() {}
  @override
  Future<void> generate(BuildContext context) async {}
  @override
  void cancelGeneration() {}
  @override
  void skipCurrentRequest() {}
}

Widget mobileChrome({bool keyboardVisible = false}) => MobileGenerationChrome(
  controller: _MobileController(),
  data: MobileGenerationViewData(
    batchStatus: (
      isGenerating: false,
      isPreparing: false,
      currentImage: 0,
      totalImages: 1,
    ),
    cooldownRemainingSeconds: 0,
    // The editor chrome avoids unrelated agent/subscription initialization.
    isPromptMaximized: true,
    isSelectionMode: false,
    isFixedTagsOverlayVisible: false,
    keyboardVisible: keyboardVisible,
    isGenerating: false,
    isLauncherGenerating: false,
    requiresLogin: false,
    showRandomTools: false,
    isUpscaleMode: false,
    randomModeEnabled: false,
    promptSummary: '',
    enabledCharacterCount: 0,
    qualityEnabled: false,
    negativePresetLabel: null,
    fixedTagCount: 0,
  ),
  historyViewport: OwnedViewportOffset(),
  body: const SizedBox.expand(),
);

Widget app(
  Widget child, {
  ProviderPriceEstimate? quote = const ProviderPriceEstimate(
    lowerMicros: 50000,
    upperMicros: 90000,
  ),
  double scale = 1,
  bool chrome = false,
  bool supported = true,
  Completer<ProviderPricingResult?>? loading,
  ProviderBillingSummaryData? billing,
  ImageWorkflowState workflow = const ImageWorkflowState(),
}) => ProviderScope(
  overrides: [
    customProviderPricingVisibleProvider.overrideWith((ref) => true),
    providerPricingOriginSupportedProvider.overrideWith((ref) => supported),
    providerPriceEstimateProvider.overrideWith((ref) => quote),
    providerPricingCatalogProvider.overrideWith(
      () => loading == null ? _Catalog() : _LoadingCatalog(loading),
    ),
    subscriptionNotifierProvider.overrideWith(_Subscription.new),
    estimatedCostProvider.overrideWith((ref) => null),
    providerBillingSummaryProvider.overrideWith((ref) => billing),
    generationParamsNotifierProvider.overrideWith(_Params.new),
    imageWorkflowControllerProvider.overrideWith(() => _Workflow(workflow)),
  ],
  child: MaterialApp(
    locale: const Locale('zh'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: chrome ? child : Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets(
    'shows unitless range, public rule metadata, stale state and accessible refresh',
    (tester) async {
      _Catalog.refreshes = 0;
      await tester.pumpWidget(
        app(
          const Column(
            children: [
              AnlasCostBadge(isGenerating: false),
              ProviderPriceRefreshButton(),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('预计 0.05–0.09'), findsOneWidget);
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, contains('模型基础价格：0.05'));
      expect(tooltip.message, contains('每 1 Anlas 附加价格：0.01'));
      expect(tooltip.message, contains('rules-v7'));
      expect(tooltip.message, contains('更新时间：'));
      expect(tooltip.message, contains('离线或缓存价格已过期'));
      expect(tooltip.message, contains('刷新服务商价格'));
      await tester.tap(find.byKey(const ValueKey('provider-price-refresh')));
      expect(_Catalog.refreshes, 1);
      Focus.of(
        tester.element(find.byIcon(Icons.refresh_rounded)),
      ).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(_Catalog.refreshes, 2);
    },
  );
  testWidgets('unknown stays --, free provider quote remains visible', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ProviderPriceBadge(), quote: null));
    expect(find.text('预计 --'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(
      app(
        const ProviderPriceBadge(),
        quote: const ProviderPriceEstimate(lowerMicros: 0, upperMicros: 0),
      ),
    );
    expect(find.text('预计 0'), findsOneWidget);
  });
  testWidgets('local upscale hides provider prices', (tester) async {
    await tester.pumpWidget(
      app(
        const ProviderPriceBadge(),
        workflow: const ImageWorkflowState(
          mode: ImageWorkflowMode.upscale,
          upscale: UpscaleWorkflowSettings(backend: UpscaleBackend.comfyui),
        ),
      ),
    );
    expect(find.textContaining('预计'), findsNothing);
  });
  testWidgets('loading keeps unknown estimate and never blocks generate', (
    tester,
  ) async {
    final completer = Completer<ProviderPricingResult?>();
    var generated = 0;
    await tester.pumpWidget(
      app(
        GenerateButtonWithCost(
          isGenerating: false,
          showCancel: false,
          batchStatus: (
            isGenerating: false,
            isPreparing: false,
            currentImage: 0,
            totalImages: 1,
          ),
          onGenerate: () => generated++,
          onCancel: () {},
          onSkipCurrent: () {},
        ),
        quote: null,
        loading: completer,
      ),
    );
    await tester.pump();
    expect(find.text('预计 --'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final refresh = tester.widget<IconButton>(
      find.byKey(const ValueKey('provider-price-refresh')),
    );
    expect(refresh.onPressed, isNull);
    expect(refresh.tooltip, contains('正在刷新服务商价格'));
    await tester.tap(find.text('预计 --'));
    expect(generated, 1);
    completer.complete(null);
    await tester.pumpAndSettle();
  });

  testWidgets('unsupported price remains unknown with disabled refresh', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        const Column(
          children: [ProviderPriceBadge(), ProviderPriceRefreshButton()],
        ),
        quote: null,
        supported: false,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('预计 --'), findsOneWidget);
    expect(
      tester.widget<IconButton>(find.byType(IconButton)).onPressed,
      isNull,
    );
  });

  for (final width in [320.0, 600.0, 840.0, 1180.0, 1600.0]) {
    testWidgets(
      'mobile custom action fits width $width at 3x with SafeArea and IME',
      (tester) async {
        tester.view.physicalSize = Size(width, 320);
        tester.view.devicePixelRatio = 1;
        tester.view.padding = const FakeViewPadding(bottom: 24);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPadding);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpWidget(app(mobileChrome(), chrome: true, scale: 3));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('预计 0.05–0.09'), findsOneWidget);
        final button = tester.getRect(find.byType(FilledButton));
        final price = tester.getRect(find.text('预计 0.05–0.09'));
        expect(button.contains(price.topLeft), isTrue);
        expect(
          button.contains(price.bottomRight),
          isTrue,
          reason: 'price $price must fit inside button $button',
        );
        expect(button.bottom, lessThanOrEqualTo(296));
        final refresh = find.byKey(const ValueKey('provider-price-refresh'));
        expect(refresh.hitTestable(), findsOneWidget);
        expect(tester.getSize(refresh), const Size(44, 44));
        tester.view.viewInsets = const FakeViewPadding(bottom: 180);
        await tester.pumpWidget(
          app(mobileChrome(keyboardVisible: true), chrome: true, scale: 3),
        );
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('generation-mobile-bottom-bar')),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'estimate is inside generate, refresh is separate at width $width, 3x text',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var generated = 0;
        _Catalog.refreshes = 0;
        await tester.pumpWidget(
          app(
            GenerateButtonWithCost(
              isGenerating: false,
              showCancel: false,
              batchStatus: (
                isGenerating: false,
                isPreparing: false,
                currentImage: 0,
                totalImages: 1,
              ),
              onGenerate: () => generated++,
              onCancel: () {},
              onSkipCurrent: () {},
            ),
            scale: 3,
            billing: ProviderBillingSummaryData(
              usage: ProviderGenerationUsage(
                endpoint: 'https://api.cunzaijiang.cn/v1',
                requestedModel: 'nai-diffusion-4-5-full',
                responseModel: 'nai-diffusion-4-5-full',
                requestedAt: DateTime.utc(2026, 11),
                sessionEpoch: 1,
                promptTokens: 1,
                completionTokens: 2,
              ),
              quote: const ProviderPriceQuote(
                amount: 0.05,
                tier: 'base',
                promptTokens: 1,
                completionTokens: 2,
              ),
              catalogVersion: 'rules-v7',
              isStale: false,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('预计 0.05–0.09'), findsOneWidget);
        final generateFinder = find.byType(FilledButton);
        final generate = tester.getRect(generateFinder);
        final price = tester.getRect(find.text('预计 0.05–0.09'));
        expect(generate.contains(price.topLeft), isTrue);
        expect(
          generate.contains(price.bottomRight),
          isTrue,
          reason: 'price $price must fit inside button $generate',
        );
        expect(
          find.descendant(
            of: generateFinder,
            matching: find.byType(ProviderPriceBadge),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(ProviderPriceBadge),
            matching: find.byType(InkWell),
          ),
          findsNothing,
        );
        final refreshFinder = find.byKey(
          const ValueKey('provider-price-refresh'),
        );
        final refresh = tester.getRect(refreshFinder);
        expect(refresh.width, greaterThanOrEqualTo(44));
        expect(refresh.height, greaterThanOrEqualTo(44));
        expect(generate.overlaps(refresh), isFalse);
        expect(generate.height, greaterThanOrEqualTo(44));
        expect(find.text('按返回用量计算 0.05'), findsOneWidget);
        expect(
          tester.getRect(find.text('按返回用量计算 0.05')).top,
          greaterThanOrEqualTo(generate.bottom),
        );
        expect(find.text('根据公开价格和返回用量计算，非账户实际扣费'), findsOneWidget);
        await tester.tap(refreshFinder);
        expect(_Catalog.refreshes, 1);
        expect(generated, 0, reason: 'refresh must not submit generation');
        await tester.tap(find.text('预计 0.05–0.09'));
        expect(generated, 1, reason: 'amount belongs to generate tap target');
        expect(_Catalog.refreshes, 1, reason: 'generate must not refresh');
        Focus.of(
          tester.element(find.byIcon(Icons.refresh_rounded)),
        ).requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        expect(_Catalog.refreshes, 2);
        expect(generated, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
