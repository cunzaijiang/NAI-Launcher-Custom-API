import 'provider_pricing.dart';

/// Observed metadata from one successful compatible-provider image response.
///
/// No prompts, credentials, image data or currency assumptions are retained.
/// Token counts are the response values, never client-side Anlas encodings.
class ProviderGenerationUsage {
  const ProviderGenerationUsage({
    required this.endpoint,
    required this.requestedModel,
    required this.requestedAt,
    required this.sessionEpoch,
    this.responseModel,
    this.requestId,
    this.promptTokens,
    this.completionTokens,
    this.totalTokens,
    this.catalogSnapshot,
  });

  final String endpoint;
  final String requestedModel;
  final String? responseModel;
  final String? requestId;
  final DateTime requestedAt;
  final int sessionEpoch;
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;

  /// The public rules known when this request began; never a wallet debit.
  final ProviderPricingCatalog? catalogSnapshot;
  String? get catalogVersion => catalogSnapshot?.pricingVersion;

  /// Only an explicitly returned model can identify observed billing usage.
  String? get actualModel => responseModel;

  static int? parseTokenCount(Object? value) {
    if (value is! num ||
        !value.isFinite ||
        value < 0 ||
        value != value.round()) {
      return null;
    }
    return value.toInt();
  }
}
