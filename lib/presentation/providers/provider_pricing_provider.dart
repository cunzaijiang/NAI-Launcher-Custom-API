import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/nai_api_endpoint_service.dart';
import '../../core/services/anlas_calculator.dart';
import '../../core/services/provider_pricing_service.dart';
import '../../core/utils/focused_inpaint_utils.dart';
import '../../data/models/image/image_params.dart';
import '../../data/services/auth_provider.dart';
import 'cost_estimate_provider.dart';
import 'generation/image_workflow_controller.dart';
import 'image_generation_provider.dart';

/// Read auth as well: the endpoint service changes in place during account swaps.
final customProviderPricingVisibleProvider = Provider<bool>((ref) {
  ref.watch(authNotifierProvider);
  return ref.watch(naiApiEndpointServiceProvider).current.isOpenAiCompatible;
});

final providerPricingOriginSupportedProvider = Provider<bool>((ref) {
  // The custom/official boolean can stay unchanged while two custom accounts swap.
  ref.watch(authNotifierProvider);
  if (!ref.watch(customProviderPricingVisibleProvider)) return false;
  final endpoint = ref.watch(naiApiEndpointServiceProvider).current;
  bool supported(String url) {
    final uri = Uri.tryParse(url);
    return uri != null &&
        uri.hasAuthority &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment &&
        (uri.path.isEmpty || uri.path == '/v1' || uri.path == '/v1/') &&
        ProviderPricingService.supportsOrigin(uri.origin);
  }

  return supported(endpoint.mainBaseUrl) && supported(endpoint.imageBaseUrl);
});

final providerPricingCatalogProvider =
    AutoDisposeAsyncNotifierProvider<
      ProviderPricingCatalogNotifier,
      ProviderPricingResult?
    >(ProviderPricingCatalogNotifier.new);

class ProviderPricingCatalogNotifier
    extends AutoDisposeAsyncNotifier<ProviderPricingResult?> {
  int _generation = 0;

  @override
  Future<ProviderPricingResult?> build() async {
    _generation++;
    ref.onDispose(() => _generation++);
    if (!ref.watch(providerPricingOriginSupportedProvider)) return null;
    final service = ref.watch(providerPricingServiceProvider);
    // Start before fetching so even an initial offline/invalid response retries.
    // The public GET runs independently of generation and never gates it.
    final timer = Timer.periodic(ProviderPricingService.cacheTtl, (_) {
      unawaited(refresh());
    });
    ref.onDispose(timer.cancel);
    return service.getCatalog();
  }

  Future<void> refresh() async {
    if (state.isLoading || !ref.read(providerPricingOriginSupportedProvider)) {
      return;
    }
    final generation = _generation;
    final service = ref.read(providerPricingServiceProvider);
    state = const AsyncLoading<ProviderPricingResult?>().copyWithPrevious(
      state,
    );
    final result = await AsyncValue.guard(
      () => service.getCatalog(forceRefresh: true),
    );
    if (generation == _generation) state = result;
  }
}

/// Unitless provider amounts are deliberately separate from int Anlas estimates.
class ProviderPriceEstimate {
  const ProviderPriceEstimate({
    required this.lowerMicros,
    required this.upperMicros,
  });

  final int lowerMicros;
  final int upperMicros;
  bool get isRange => lowerMicros != upperMicros;
  String get formatted => isRange
      ? '${formatProviderPriceMicros(lowerMicros)}–${formatProviderPriceMicros(upperMicros)}'
      : formatProviderPriceMicros(lowerMicros);
}

String formatProviderPriceMicros(int micros) {
  final whole = micros ~/ 1000000;
  final fraction = (micros % 1000000)
      .toString()
      .padLeft(6, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty ? '$whole' : '$whole.$fraction';
}

/// One provider HTTP request is sent for every sample, including batch images.
/// Local Vibe encodings cannot establish the remote provider's cache state.
ProviderPriceEstimate? estimateProviderPrice({
  required ProviderPricingCatalog catalog,
  required ImageParams params,
  required int imagesPerRequest,
  required int width,
  required int height,
  required double strength,
}) {
  if (width <= 0 ||
      height <= 0 ||
      params.steps <= 0 ||
      params.nSamples <= 0 ||
      imagesPerRequest <= 0 ||
      !strength.isFinite ||
      strength < 0 ||
      strength > 1) {
    return null;
  }
  final effectiveSteps =
      params.capabilities.fixedSettings?.steps ?? params.steps;
  final baseAnlas = width * height <= 1048576 && effectiveSteps <= 28
      ? 0
      : AnlasCalculator.calculateFromValues(
          width: width,
          height: height,
          steps: params.steps,
          nSamples: 1,
          smea: params.effectiveSmea,
          smeaDyn: params.effectiveSmeaDyn,
          model: params.model,
          strength: strength,
        );
  if (baseAnlas < 0) return null;
  final precise = AnlasCalculator.resolvePreciseReferenceExtraCost(params);
  final lowerAnlas =
      baseAnlas +
      precise +
      AnlasCalculator.resolveVibeReferenceExtraCost(params);
  final upperAnlas =
      lowerAnlas +
      (AnlasCalculator.usesVibeReferences(params)
          ? params.enabledVibeReferencesV4.length * 2
          : 0);
  final lower = catalog.evaluateAnlas(params.model, lowerAnlas);
  final upper = catalog.evaluateAnlas(params.model, upperAnlas);
  if (lower == null || upper == null) return null;
  final count = params.nSamples * imagesPerRequest;
  final lowerMicros = lower.amountMicros * count;
  final upperMicros = upper.amountMicros * count;
  return ProviderPriceEstimate(
    lowerMicros: lowerMicros < upperMicros ? lowerMicros : upperMicros,
    upperMicros: upperMicros > lowerMicros ? upperMicros : lowerMicros,
  );
}

final providerPriceEstimateProvider = Provider<ProviderPriceEstimate?>((ref) {
  if (!ref.watch(providerPricingOriginSupportedProvider)) return null;
  final workflow = ref.watch(imageWorkflowControllerProvider);
  if (workflow.isUpscale) return null;
  final catalog = ref
      .watch(providerPricingCatalogProvider)
      .valueOrNull
      ?.catalog;
  if (catalog == null) return null;
  final params = ref.watch(generationParamsNotifierProvider);
  var size = resolveGenerationBillingSize(
    width: params.width,
    height: params.height,
    maxEnhance: params.effectiveUpscaledEnhance,
  );
  if (workflow.focusedInpaintEnabled &&
      params.action == ImageGenerationAction.infill) {
    final sourceWidth =
        workflow.sourceImageWidth ?? workflow.sourceWidth ?? params.width;
    final sourceHeight =
        workflow.sourceImageHeight ?? workflow.sourceHeight ?? params.height;
    final crop = workflow.focusedContextCrop;
    final selection = workflow.focusedSelectionRect;
    final FocusedInpaintGeometry? geometry;
    if (crop != null) {
      geometry = FocusedInpaintUtils.resolveGeometryForCrop(
        sourceWidth: sourceWidth,
        sourceHeight: sourceHeight,
        crop: crop,
      );
    } else if (selection != null) {
      geometry = FocusedInpaintUtils.resolveGeometryForSelection(
        sourceWidth: sourceWidth,
        sourceHeight: sourceHeight,
        selectionRect: selection,
        minContextMegaPixels: workflow.minimumContextMegaPixels,
      );
    } else {
      final mask = ref.watch(focusedInpaintMaskRequestSizeProvider);
      if (mask.isLoading || mask.hasError) return null;
      geometry = mask.valueOrNull;
    }
    if (geometry == null) return null;
    size = (width: geometry.requestWidth, height: geometry.requestHeight);
  }
  return estimateProviderPrice(
    catalog: catalog,
    params: params,
    imagesPerRequest: ref.watch(imagesPerRequestProvider),
    width: size.width,
    height: size.height,
    strength: switch (params.action) {
      ImageGenerationAction.generate => 1,
      ImageGenerationAction.img2img => params.strength,
      ImageGenerationAction.infill => params.inpaintStrength,
    },
  );
});
