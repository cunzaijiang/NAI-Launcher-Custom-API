import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/models/provider_generation_usage.dart';
import 'package:nai_launcher/core/models/provider_pricing.dart';
import 'package:nai_launcher/l10n/app_localizations.dart';
import 'package:nai_launcher/presentation/providers/provider_billing_provider.dart';
import 'package:nai_launcher/presentation/widgets/generation/provider_billing_summary.dart';

void main() {
  testWidgets('unitless returned usage and warning wrap at all widths and 3x', (
    tester,
  ) async {
    addTearDown(() => tester.view.resetPhysicalSize());
    addTearDown(() => tester.view.resetDevicePixelRatio());
    tester.view.devicePixelRatio = 1;
    final summary = ProviderBillingSummaryData(
      usage: ProviderGenerationUsage(
        endpoint: 'https://api.cunzaijiang.cn/v1',
        requestedModel: 'nai-diffusion-4-5-full',
        responseModel: 'nai-diffusion-4-5-full',
        requestedAt: DateTime.utc(2026),
        sessionEpoch: 0,
        promptTokens: 100000,
        completionTokens: 1850000,
      ),
      quote: const ProviderPriceQuote(
        amount: 0.03,
        tier: 'base',
        promptTokens: 100000,
        completionTokens: 1850000,
      ),
      catalogVersion: 'test-version',
      isStale: false,
    );
    for (final width in [320.0, 600.0, 840.0, 1180.0, 1600.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            providerBillingSummaryProvider.overrideWithValue(summary),
          ],
          child: MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(3)),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(child: ProviderBillingSummary()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(ProviderBillingSummary));
      final l10n = AppLocalizations.of(context)!;
      expect(
        find.text('${l10n.providerBillingFromUsage} 0.03'),
        findsOneWidget,
      );
      expect(find.text(l10n.providerBillingNotWallet), findsOneWidget);
      expect(find.text(l10n.providerBillingEncodingMismatch), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'width=$width');
    }
  });
}
