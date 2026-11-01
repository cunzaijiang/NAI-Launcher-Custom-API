/// A unitless quote from the provider's public billing expression.
class ProviderPriceQuote {
  const ProviderPriceQuote({
    required this.amount,
    required this.tier,
    required this.promptTokens,
    required this.completionTokens,
  });

  final double amount;

  /// Round once per complete quote, not per token, for stable accumulation.
  int get amountMicros => (amount * 1000000).round();
  final String tier;
  final int promptTokens;
  final int completionTokens;
  bool get usedAnlasBranch => tier == 'anlas';
}

/// Deliberately recognizes only the provider's current two-branch protocol.
/// This is a bounded whitelist parser, not a general expression evaluator.
class PricingRule {
  PricingRule({
    required this.modelName,
    required this.billingExpression,
    this.billingMode = 'tiered_expr',
  }) : _rates = billingMode == 'tiered_expr' ? _parse(billingExpression) : null;

  static const supportedModels = {
    'nai-diffusion-4-5-full',
    'nai-diffusion-4-5-curated',
    'nai-diffusion-5-full',
    'nai-diffusion-5-curated',
  };
  static const groupName = 'NovelAI分组';
  static const _maxExactInteger = 9007199254740991;
  static const _number = r'(?:\d+(?:\.\d+)?|\.\d+)(?:[eE][+-]?\d+)?';
  static final _pattern = RegExp(
    r'^p==1&&c>=10000&&floor\(c/10000\)\*10000==c\?tier\("anlas",'
    '(?:($_number)\\+)?c\\*($_number)'
    r'\):tier\("(free|base)",fixed\('
    '($_number)'
    r'\)\)$',
  );

  final String modelName;
  final String billingExpression;
  final String billingMode;
  final _PricingRates? _rates;
  bool get isSupported => supportedModels.contains(modelName) && _rates != null;

  static _PricingRates? _parse(String expression) {
    if (expression.length > 4096 ||
        // Do not turn split identifiers/numbers into valid tokens.
        RegExp(r'[A-Za-z0-9_.]\s+[A-Za-z0-9_.]').hasMatch(expression)) {
      return null;
    }
    final match = _pattern.firstMatch(
      expression.replaceAll(RegExp(r'\s+'), ''),
    );
    if (match == null) return null;
    final offset = double.tryParse(match.group(1) ?? '0');
    final coefficient = double.tryParse(match.group(2)!);
    final fixed = double.tryParse(match.group(4)!);
    if ([
      offset,
      coefficient,
      fixed,
    ].any((value) => value == null || !value.isFinite || value < 0)) {
      return null;
    }
    return _PricingRates(offset!, coefficient!, fixed!, match.group(3)!);
  }

  /// Uses the actual raw token counts, including the fallback branch when the
  /// prompt count is not 1. Unknown or invalid values never become a zero quote.
  ProviderPriceQuote? evaluateUsage({
    required int promptTokens,
    required int completionTokens,
    double groupFactor = 1,
  }) {
    final rates = _rates;
    if (!isSupported ||
        rates == null ||
        promptTokens < 0 ||
        completionTokens < 0 ||
        promptTokens > _maxExactInteger ||
        completionTokens > _maxExactInteger ||
        !groupFactor.isFinite ||
        groupFactor < 0) {
      return null;
    }
    final anlas =
        promptTokens == 1 &&
        completionTokens >= 10000 &&
        completionTokens % 10000 == 0;
    final value = anlas
        ? (rates.offset + completionTokens * rates.coefficient) / 1000000
        : rates.fixed;
    final amount = value * groupFactor;
    if (!amount.isFinite || amount < 0 || amount * 1000000 > _maxExactInteger) {
      return null;
    }
    return ProviderPriceQuote(
      amount: amount,
      tier: anlas ? 'anlas' : rates.fallbackTier,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
    );
  }

  /// Canonical estimate input; never use this to rewrite recorded usage.
  ProviderPriceQuote? evaluateAnlas(int anlas, {double groupFactor = 1}) {
    if (anlas < 0 || anlas > _maxExactInteger ~/ 10000) return null;
    return evaluateUsage(
      promptTokens: 1,
      completionTokens: anlas == 0 ? 2 : anlas * 10000,
      groupFactor: groupFactor,
    );
  }
}

class _PricingRates {
  const _PricingRates(
    this.offset,
    this.coefficient,
    this.fixed,
    this.fallbackTier,
  );
  final double offset;
  final double coefficient;
  final double fixed;
  final String fallbackTier;
}

/// A validated public catalog. Non-NovelAI models and unrelated metadata are
/// intentionally discarded, including any currency metadata.
class ProviderPricingCatalog {
  ProviderPricingCatalog._({
    required this.pricingVersion,
    required this.fetchedAt,
    required this.groupFactor,
    required Map<String, PricingRule> rules,
  }) : rules = Map.unmodifiable(rules);

  factory ProviderPricingCatalog.fromJson(
    Map<String, dynamic> json, {
    required DateTime fetchedAt,
  }) {
    final version = json['pricing_version'];
    final data = json['data'];
    final groups = json['group_ratio'];
    final factor = groups is Map ? groups[PricingRule.groupName] : null;
    if (json['success'] != true ||
        version is! String ||
        version.trim().isEmpty ||
        version.length > 256 ||
        data is! List ||
        data.length > 10000 ||
        factor is! num ||
        !factor.isFinite ||
        factor < 0) {
      throw const FormatException('Invalid public pricing catalog');
    }
    final rules = <String, PricingRule>{};
    final seenModels = <String>{};
    for (final row in data) {
      if (row is! Map || row['model_name'] is! String) {
        throw const FormatException('Invalid pricing row');
      }
      final name = row['model_name'] as String;
      if (!PricingRule.supportedModels.contains(name)) continue;
      final expression = row['billing_expr'];
      final mode = row['billing_mode'];
      final enabled = row['enable_groups'];
      if (!seenModels.add(name) ||
          expression is! String ||
          expression.length > 4096 ||
          mode is! String ||
          enabled is! List ||
          enabled.any((group) => group is! String)) {
        throw const FormatException('Invalid NovelAI pricing rule');
      }
      if (!enabled.contains(PricingRule.groupName)) continue;
      rules[name] = PricingRule(
        modelName: name,
        billingExpression: expression,
        billingMode: mode,
      );
    }
    return ProviderPricingCatalog._(
      pricingVersion: version,
      fetchedAt: fetchedAt.toUtc(),
      groupFactor: factor.toDouble(),
      rules: rules,
    );
  }

  final String pricingVersion;
  final DateTime fetchedAt;
  final double groupFactor;
  final Map<String, PricingRule> rules;
  PricingRule? ruleFor(String modelName) => rules[modelName];

  ProviderPriceQuote? evaluateAnlas(String modelName, int anlas) =>
      ruleFor(modelName)?.evaluateAnlas(anlas, groupFactor: groupFactor);

  ProviderPriceQuote? evaluateUsage(
    String modelName, {
    required int promptTokens,
    required int completionTokens,
  }) => ruleFor(modelName)?.evaluateUsage(
    promptTokens: promptTokens,
    completionTokens: completionTokens,
    groupFactor: groupFactor,
  );

  Map<String, dynamic> toJson() => {
    'success': true,
    'pricing_version': pricingVersion,
    'group_ratio': {PricingRule.groupName: groupFactor},
    'data': [
      for (final rule in rules.values)
        {
          'model_name': rule.modelName,
          'billing_mode': rule.billingMode,
          'billing_expr': rule.billingExpression,
          'enable_groups': [PricingRule.groupName],
        },
    ],
  };
}

enum ProviderPricingError {
  unsupportedOrigin,
  network,
  invalidResponse,
  cacheUnavailable,
}

class ProviderPricingResult {
  const ProviderPricingResult({
    required this.catalog,
    required this.isStale,
    this.error,
  });
  final ProviderPricingCatalog? catalog;

  /// Independent of refresh errors: this reflects age since the last success.
  final bool isStale;
  final ProviderPricingError? error;
}
