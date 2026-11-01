import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/models/provider_generation_usage.dart';
import 'package:nai_launcher/core/models/provider_pricing.dart';
import 'package:nai_launcher/presentation/providers/provider_billing_provider.dart';

ProviderPricingCatalog _catalog({String version = 'v1', double fixed = 0.03}) =>
    ProviderPricingCatalog.fromJson({
      'success': true,
      'pricing_version': version,
      'group_ratio': {'NovelAI分组': 1},
      'data': [
        {
          'model_name': 'nai-diffusion-4-5-full',
          'billing_mode': 'tiered_expr',
          'enable_groups': ['NovelAI分组'],
          'billing_expr':
              'p == 1 && c >= 10000 && floor(c / 10000) * 10000 == c '
              '? tier("anlas", c * 0.01) : tier("base", fixed($fixed))',
        },
      ],
    }, fetchedAt: DateTime.utc(2026));

ProviderGenerationUsage _usage({
  int? prompt = 100000,
  int? completion = 1850000,
  String? model = 'nai-diffusion-4-5-full',
  ProviderPricingCatalog? snapshot,
  bool hasSnapshot = true,
}) => ProviderGenerationUsage(
  endpoint: 'https://api.cunzaijiang.cn/v1',
  requestedModel: 'nai-diffusion-4-5-full',
  responseModel: model,
  requestedAt: DateTime.utc(2026),
  sessionEpoch: 0,
  promptTokens: prompt,
  completionTokens: completion,
  catalogSnapshot: hasSnapshot ? snapshot ?? _catalog() : null,
);

void main() {
  ProviderBillingSummaryData evaluate(ProviderGenerationUsage usage) =>
      evaluateProviderBilling(
        usage: usage,
        pricing: ProviderPricingResult(catalog: _catalog(), isStale: false),
      );

  test('p100000 uses strict fallback and warns, never canonical p1', () {
    final result = evaluate(_usage());
    expect(result.quote!.promptTokens, 100000);
    expect(result.quote!.usedAnlasBranch, false);
    expect(result.quote!.amount, 0.03);
    expect(result.formattedAmount, '0.03');
    expect(result.hasEncodingMismatch, true);
    expect(result.catalogVersion, 'v1');
  });

  test('p1 encoded completion follows actual usage without warning', () {
    final result = evaluate(_usage(prompt: 1));
    expect(result.quote!.usedAnlasBranch, true);
    expect(result.quote!.amount, closeTo(0.0185, 0.000000001));
    expect(result.hasEncodingMismatch, false);
  });

  test('absent or mismatching response model stays unknown', () {
    for (final model in <String?>[null, 'nai-diffusion-5-full']) {
      expect(evaluate(_usage(model: model)).quote, isNull);
    }
  });

  test('missing raw counts do not become zero or an estimate', () {
    expect(evaluate(_usage(prompt: null)).quote, isNull);
    expect(evaluate(_usage(completion: null)).quote, isNull);
  });

  test('missing request snapshot stays unknown after catalogs arrive', () {
    final usage = _usage(hasSnapshot: false);
    for (final pricing in <ProviderPricingResult?>[
      null,
      ProviderPricingResult(catalog: _catalog(), isStale: false),
      ProviderPricingResult(
        catalog: _catalog(version: 'later-version', fixed: 9),
        isStale: false,
      ),
    ]) {
      final result = evaluateProviderBilling(usage: usage, pricing: pricing);
      expect(result.quote, isNull);
      expect(result.formattedAmount, isNull);
      expect(result.catalogVersion, isNull);
      expect(result.hasEncodingMismatch, true);
    }
  });

  test('request pricing snapshot is stable after catalog changes', () {
    final result = evaluateProviderBilling(
      usage: _usage(snapshot: _catalog(version: 'request-version')),
      pricing: ProviderPricingResult(
        catalog: _catalog(version: 'new-version', fixed: 9),
        isStale: false,
      ),
    );
    expect(result.catalogVersion, 'request-version');
    expect(result.quote!.amount, 0.03);
  });
}
