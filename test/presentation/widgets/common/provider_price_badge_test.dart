import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/services/provider_pricing_service.dart';
import 'package:nai_launcher/core/models/provider_generation_usage.dart';
import 'package:nai_launcher/data/models/image/image_params.dart';
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

Widget app(
  Widget child, {
  ProviderPriceEstimate? quote = const ProviderPriceEstimate(
    lowerMicros: 50000,
    upperMicros: 90000,
  ),
  double scale = 1,
  ProviderBillingSummaryData? billing,
  ImageWorkflowState workflow = const ImageWorkflowState(),
}) => ProviderScope(
  overrides: [
    customProviderPricingVisibleProvider.overrideWith((ref) => true),
    providerPricingOriginSupportedProvider.overrideWith((ref) => true),
    providerPriceEstimateProvider.overrideWith((ref) => quote),
    providerPricingCatalogProvider.overrideWith(_Catalog.new),
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
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets(
    'shows unitless range, public rule metadata, stale state and accessible refresh',
    (tester) async {
      _Catalog.refreshes = 0;
      await tester.pumpWidget(app(const AnlasCostBadge(isGenerating: false)));
      await tester.pumpAndSettle();
      expect(find.text('预计 0.05–0.09'), findsOneWidget);
      final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltip.message, contains('模型基础价格：0.05'));
      expect(tooltip.message, contains('每 1 Anlas 附加价格：0.01'));
      expect(tooltip.message, contains('rules-v7'));
      expect(tooltip.message, contains('更新时间：'));
      expect(tooltip.message, contains('离线或缓存价格已过期'));
      expect(tooltip.message, contains('刷新服务商价格'));
      await tester.tap(find.byType(InkWell));
      expect(_Catalog.refreshes, 1);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(_Catalog.refreshes, 2);
    },
  );
  testWidgets('unknown stays --, free provider quote remains visible', (
    tester,
  ) async {
    await tester.pumpWidget(app(const ProviderPriceBadge(), quote: null));
    expect(find.text('--'), findsOneWidget);
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
  for (final width in [320.0, 600.0, 840.0, 1180.0, 1600.0]) {
    testWidgets(
      'separate provider pricing row remains reachable at width $width, 3x text',
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
        final badge = tester.getRect(find.byType(ProviderPriceBadge));
        final generate = tester.getRect(find.text('生成'));
        expect(badge.top, greaterThanOrEqualTo(generate.bottom));
        expect(find.text('按返回用量计算 0.05'), findsOneWidget);
        expect(
          tester.getRect(find.text('按返回用量计算 0.05')).top,
          greaterThanOrEqualTo(badge.bottom),
        );
        expect(find.text('根据公开价格和返回用量计算，非账户实际扣费'), findsOneWidget);
        await tester.tap(find.byType(InkWell).last);
        expect(_Catalog.refreshes, 1);
        expect(generated, 0, reason: 'refresh must not submit generation');
        expect(tester.takeException(), isNull);
      },
    );
  }
}
