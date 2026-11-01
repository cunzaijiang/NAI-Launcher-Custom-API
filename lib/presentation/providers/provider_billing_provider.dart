import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/provider_generation_usage.dart';
import '../../core/models/provider_pricing.dart';
import '../../core/network/nai_api_endpoint_service.dart';
import '../../core/services/provider_generation_usage_store.dart';
import 'provider_pricing_provider.dart';

final providerGenerationUsageProvider =
    StreamProvider<ProviderGenerationUsage?>((ref) async* {
      final store = ref.watch(providerGenerationUsageStoreProvider);
      yield store.latest;
      yield* store.changes;
    });

class ProviderBillingSummaryData {
  const ProviderBillingSummaryData({
    required this.usage,
    required this.quote,
    required this.catalogVersion,
    required this.isStale,
  });

  final ProviderGenerationUsage usage;
  final ProviderPriceQuote? quote;
  final String? catalogVersion;
  final bool isStale;

  /// Large encoded completion usage with a noncanonical prompt count must not
  /// be described as an actual Anlas debit, even when the rule has a fallback.
  bool get hasEncodingMismatch =>
      usage.completionTokens != null &&
      usage.completionTokens! >= 10000 &&
      usage.completionTokens! % 10000 == 0 &&
      usage.promptTokens != 1;

  String? get formattedAmount => quote == null
      ? null
      : formatProviderPriceMicros((quote!.amount * 1000000).round());
}

/// The response model must explicitly match the canonical model actually sent.
/// Never borrow an estimate's p=1 encoding for a real response.
ProviderBillingSummaryData evaluateProviderBilling({
  required ProviderGenerationUsage usage,
  required ProviderPricingResult? pricing,
}) {
  // A missing request-time catalog is itself a snapshot: later prices must not
  // silently reprice an observation that started with unknown pricing.
  final catalog = usage.catalogSnapshot;
  final promptTokens = usage.promptTokens;
  final completionTokens = usage.completionTokens;
  final model = usage.actualModel;
  final quote =
      model != null &&
          model == usage.requestedModel &&
          promptTokens != null &&
          completionTokens != null
      ? catalog?.evaluateUsage(
          model,
          promptTokens: promptTokens,
          completionTokens: completionTokens,
        )
      : null;
  return ProviderBillingSummaryData(
    usage: usage,
    quote: quote,
    catalogVersion: catalog?.pricingVersion,
    isStale: pricing?.isStale ?? true,
  );
}

final providerBillingSummaryProvider = Provider<ProviderBillingSummaryData?>((
  ref,
) {
  if (!ref.watch(providerPricingOriginSupportedProvider)) return null;
  final store = ref.watch(providerGenerationUsageStoreProvider);
  final usage = ref.watch(providerGenerationUsageProvider).valueOrNull;
  if (usage == null || usage.sessionEpoch != store.sessionEpoch) return null;
  final endpoint = ref.watch(naiApiEndpointServiceProvider).current;
  if (usage.endpoint != endpoint.imageBaseUrl) return null;
  return evaluateProviderBilling(
    usage: usage,
    pricing: ref.watch(providerPricingCatalogProvider).valueOrNull,
  );
});
