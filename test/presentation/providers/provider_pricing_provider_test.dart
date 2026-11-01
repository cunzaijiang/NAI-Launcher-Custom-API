import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/enums/precise_ref_type.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint.dart';
import 'package:nai_launcher/core/network/nai_api_endpoint_service.dart';
import 'package:nai_launcher/core/services/anlas_calculator.dart';
import 'package:nai_launcher/core/services/provider_pricing_service.dart';
import 'package:nai_launcher/core/utils/focused_inpaint_utils.dart';
import 'package:nai_launcher/data/models/image/image_params.dart';
import 'package:nai_launcher/data/models/vibe/vibe_reference.dart';
import 'package:nai_launcher/data/services/auth_provider.dart';
import 'package:nai_launcher/presentation/providers/cost_estimate_provider.dart';
import 'package:nai_launcher/presentation/providers/generation/image_workflow_controller.dart';
import 'package:nai_launcher/presentation/providers/image_generation_provider.dart';
import 'package:nai_launcher/presentation/providers/provider_pricing_provider.dart';

const model = 'nai-diffusion-4-5-full';
ProviderPricingCatalog catalog({
  String fixed = '0.05',
}) => ProviderPricingCatalog.fromJson({
  'success': true,
  'pricing_version': 'test-v1',
  'group_ratio': {'NovelAI分组': 1},
  'data': [
    {
      'model_name': model,
      'billing_mode': 'tiered_expr',
      'billing_expr':
          'p == 1 && c >= 10000 && floor(c / 10000) * 10000 == c ? tier("anlas", 50000 + c * 1) : tier("base", fixed($fixed))',
      'enable_groups': ['NovelAI分组'],
    },
  ],
}, fetchedAt: DateTime.utc(2026, 11));

ProviderPriceEstimate? quote(
  ImageParams params, {
  int images = 1,
  ProviderPricingCatalog? prices,
}) => estimateProviderPrice(
  catalog: prices ?? catalog(),
  params: params,
  imagesPerRequest: images,
  width: params.width,
  height: params.height,
  strength: params.action == ImageGenerationAction.img2img
      ? params.strength
      : 1,
);

class _Auth extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.authenticated);
}

class _Params extends GenerationParamsNotifier {
  _Params(this.params);
  final ImageParams params;
  @override
  ImageParams build() => params;
}

class _Images extends ImagesPerRequest {
  @override
  int build() => 1;
}

class _Workflow extends ImageWorkflowController {
  _Workflow(this.workflow);
  final ImageWorkflowState workflow;
  @override
  ImageWorkflowState build() => workflow;
}

class _Catalog extends ProviderPricingCatalogNotifier {
  @override
  Future<ProviderPricingResult?> build() async =>
      ProviderPricingResult(catalog: catalog(), isStale: false);
}

class _Service extends ProviderPricingService {
  int calls = 0;
  final forcedRefreshes = <bool>[];
  ProviderPricingResult? result;
  Completer<ProviderPricingResult>? pending;
  @override
  Future<ProviderPricingResult> getCatalog({bool forceRefresh = false}) {
    calls++;
    forcedRefreshes.add(forceRefresh);
    return pending?.future ??
        Future.value(
          result ?? ProviderPricingResult(catalog: catalog(), isStale: false),
        );
  }
}

void main() {
  testWidgets('mounted catalog refreshes every hour and cancels on disposal', (
    tester,
  ) async {
    final service = _Service();
    final container = ProviderContainer(
      overrides: [
        providerPricingOriginSupportedProvider.overrideWith((ref) => true),
        providerPricingServiceProvider.overrideWithValue(service),
      ],
    );
    final subscription = container.listen(
      providerPricingCatalogProvider,
      (_, __) {},
    );
    await tester.pump();
    expect(service.forcedRefreshes, [false]);
    await tester.pump(const Duration(minutes: 59));
    expect(service.calls, 1);
    await tester.pump(const Duration(minutes: 1));
    await tester.pump();
    expect(service.forcedRefreshes, [false, true]);
    await tester.pump(const Duration(hours: 1));
    await tester.pump();
    expect(service.forcedRefreshes, [false, true, true]);
    subscription.close();
    // Auto-disposal must cancel the timer without disposing the whole scope.
    await tester.pump();
    await tester.pump(const Duration(hours: 2));
    expect(service.calls, 3);
    container.dispose();
  });
  testWidgets(
    'first offline failure retries hourly without a generation dependency',
    (tester) async {
      final service = _Service()
        ..result = const ProviderPricingResult(
          catalog: null,
          isStale: true,
          error: ProviderPricingError.network,
        );
      final container = ProviderContainer(
        overrides: [
          providerPricingOriginSupportedProvider.overrideWith((ref) => true),
          providerPricingServiceProvider.overrideWithValue(service),
          generationParamsNotifierProvider.overrideWith(
            () => throw StateError('pricing must not read generation'),
          ),
          imageWorkflowControllerProvider.overrideWith(
            () => throw StateError('pricing must not read workflow'),
          ),
        ],
      );
      final subscription = container.listen(
        providerPricingCatalogProvider,
        (_, __) {},
      );
      await tester.pump();
      expect(
        container.read(providerPricingCatalogProvider).valueOrNull?.error,
        ProviderPricingError.network,
      );
      service.result = ProviderPricingResult(
        catalog: catalog(),
        isStale: false,
      );
      await tester.pump(const Duration(hours: 1));
      await tester.pump();
      expect(service.forcedRefreshes, [false, true]);
      expect(
        container.read(providerPricingCatalogProvider).valueOrNull?.catalog,
        isNotNull,
      );
      subscription.close();
      // A standalone ProviderContainer schedules disposal on a zero-delay
      // event-loop task, not Flutter's frame/microtask queue.
      await tester.pump(Duration.zero);
      container.dispose();
    },
  );
  testWidgets(
    'hourly ticks do not overlap a pending refresh or survive origin change',
    (tester) async {
      final service = _Service();
      final supported = StateProvider<bool>((ref) => true);
      final container = ProviderContainer(
        overrides: [
          providerPricingOriginSupportedProvider.overrideWith(
            (ref) => ref.watch(supported),
          ),
          providerPricingServiceProvider.overrideWithValue(service),
        ],
      );
      final subscription = container.listen(
        providerPricingCatalogProvider,
        (_, __) {},
      );
      await tester.pump();
      service.pending = Completer<ProviderPricingResult>();
      await tester.pump(const Duration(hours: 1));
      expect(service.calls, 2);
      await tester.pump(const Duration(hours: 1));
      expect(service.calls, 2);
      container.read(supported.notifier).state = false;
      // Run Riverpod's queued dependency rebuild before delivering the old GET.
      await tester.pump(Duration.zero);
      service.pending!.complete(
        ProviderPricingResult(catalog: catalog(), isStale: false),
      );
      await tester.pump();
      expect(
        container.read(providerPricingCatalogProvider).valueOrNull,
        isNull,
      );
      await tester.pump(const Duration(hours: 2));
      expect(service.calls, 2);
      subscription.close();
      // A standalone ProviderContainer schedules disposal on a zero-delay
      // event-loop task, not Flutter's frame/microtask queue.
      await tester.pump(Duration.zero);
      container.dispose();
    },
  );
  test('formats raw integers, fractions and ranges without units', () {
    expect(formatProviderPriceMicros(0), '0');
    expect(formatProviderPriceMicros(50000), '0.05');
    expect(formatProviderPriceMicros(100001), '0.100001');
    expect(
      const ProviderPriceEstimate(
        lowerMicros: 50000,
        upperMicros: 90000,
      ).formatted,
      '0.05–0.09',
    );
  });
  test(
    'inclusive 1MP and 28 step boundary uses provider fallback, not zero Anlas display',
    () {
      const params = ImageParams(
        model: model,
        width: 1024,
        height: 1024,
        steps: 28,
      );
      expect(quote(params)!.formatted, '0.05');
      expect(quote(params, prices: catalog(fixed: '0'))!.formatted, '0');
    },
  );
  test('area or steps above boundary uses non-discounted Anlas formula', () {
    for (final params in [
      const ImageParams(model: model, width: 1088, height: 1024, steps: 28),
      const ImageParams(model: model, width: 1024, height: 1024, steps: 29),
    ]) {
      final anlas = AnlasCalculator.calculateFromValues(
        width: params.width,
        height: params.height,
        steps: params.steps,
        nSamples: 1,
        smea: params.effectiveSmea,
        smeaDyn: params.effectiveSmeaDyn,
        model: model,
      );
      expect(quote(params)!.lowerMicros, 50000 + anlas * 10000);
    }
  });
  test(
    'img2img above boundary respects strength without subscription discount',
    () {
      const params = ImageParams(
        model: model,
        width: 1536,
        height: 1024,
        steps: 28,
        action: ImageGenerationAction.img2img,
        strength: 0.2,
      );
      expect(
        quote(params)!.lowerMicros,
        lessThan(quote(params.copyWith(strength: 1))!.lowerMicros),
      );
    },
  );
  test('sample and images are independent provider requests', () {
    expect(
      quote(const ImageParams(model: model, nSamples: 3), images: 2)!.formatted,
      '0.3',
    );
  });
  test(
    'server Vibe cache range is repeated for every request, even locally encoded refs',
    () {
      const params = ImageParams(
        model: model,
        nSamples: 3,
        vibeReferencesV4: [
          VibeReference(
            displayName: 'cached',
            vibeEncoding: 'encoded',
            encodingModel: model,
          ),
          VibeReference(
            displayName: 'disabled',
            vibeEncoding: '',
            enabled: false,
          ),
        ],
      );
      final result = quote(params, images: 2)!;
      expect(result.lowerMicros, 300000);
      expect(result.upperMicros, 420000);
    },
  );
  test(
    'precise reference adds five per enabled ref per independent request',
    () {
      final params = ImageParams(
        model: model,
        nSamples: 2,
        preciseReferences: [
          PreciseReference(image: Uint8List(0), type: PreciseRefType.character),
        ],
      );
      expect(quote(params, images: 3)!.formatted, '0.6');
    },
  );
  test('missing public model or invalid request remains unknown', () {
    expect(quote(const ImageParams(model: 'not-public')), isNull);
    expect(quote(const ImageParams(model: model, width: 0)), isNull);
    expect(quote(const ImageParams(model: model), images: 0), isNull);
  });
  test(
    'unsupported origin never invokes service; auth swap invalidates support',
    () async {
      final service = _Service();
      final endpoint = NaiApiEndpointService();
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(_Auth.new),
          naiApiEndpointServiceProvider.overrideWithValue(endpoint),
          providerPricingServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);
      endpoint.setCurrent(
        NaiApiEndpointConfig.fromInput(
          mainBaseUrl: 'https://other.example',
          protocol: NaiApiProtocol.openAiCompatible,
        ),
      );
      expect(
        await container.read(providerPricingCatalogProvider.future),
        isNull,
      );
      expect(service.calls, 0);
      endpoint.setCurrent(
        NaiApiEndpointConfig.fromInput(
          mainBaseUrl: ProviderPricingService.publicOrigin,
          protocol: NaiApiProtocol.openAiCompatible,
        ),
      );
      container.read(authNotifierProvider.notifier).state = const AuthState(
        status: AuthStatus.authenticated,
        accountId: 'next',
      );
      expect(
        (await container.read(providerPricingCatalogProvider.future))?.catalog,
        isNotNull,
      );
      expect(service.calls, 1);
    },
  );
  test('refresh after disposal cannot publish stale state', () async {
    final service = _Service();
    final container = ProviderContainer(
      overrides: [
        providerPricingOriginSupportedProvider.overrideWith((ref) => true),
        providerPricingServiceProvider.overrideWithValue(service),
      ],
    );
    final subscription = container.listen(
      providerPricingCatalogProvider,
      (_, __) {},
    );
    await container.read(providerPricingCatalogProvider.future);
    service.pending = Completer<ProviderPricingResult>();
    final refresh = container
        .read(providerPricingCatalogProvider.notifier)
        .refresh();
    subscription.close();
    container.dispose();
    service.pending!.complete(
      ProviderPricingResult(catalog: catalog(), isStale: false),
    );
    await refresh;
  });
  test(
    'focused crop uses resolved geometry instead of full source dimensions',
    () async {
      final container = ProviderContainer(
        overrides: [
          providerPricingOriginSupportedProvider.overrideWith((ref) => true),
          providerPricingCatalogProvider.overrideWith(_Catalog.new),
          imagesPerRequestProvider.overrideWith(_Images.new),
          generationParamsNotifierProvider.overrideWith(
            () => _Params(
              const ImageParams(
                model: model,
                width: 2048,
                height: 2048,
                action: ImageGenerationAction.infill,
              ),
            ),
          ),
          imageWorkflowControllerProvider.overrideWith(
            () => _Workflow(
              const ImageWorkflowState(
                focusedInpaintEnabled: true,
                sourceImageWidth: 2048,
                sourceImageHeight: 2048,
                focusedContextCrop: Rect.fromLTWH(256, 256, 512, 512),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(providerPricingCatalogProvider.future);
      expect(container.read(providerPriceEstimateProvider)!.formatted, '0.05');
    },
  );
  test(
    'focused mask not ready/error/null stays unknown rather than full-size quote',
    () async {
      for (final mask in <AsyncValue<FocusedInpaintGeometry?>>[
        const AsyncLoading(),
        AsyncError(StateError('mask'), StackTrace.current),
        const AsyncData(null),
      ]) {
        final container = ProviderContainer(
          overrides: [
            providerPricingOriginSupportedProvider.overrideWith((ref) => true),
            providerPricingCatalogProvider.overrideWith(_Catalog.new),
            generationParamsNotifierProvider.overrideWith(
              () => _Params(
                const ImageParams(
                  model: model,
                  action: ImageGenerationAction.infill,
                ),
              ),
            ),
            imageWorkflowControllerProvider.overrideWith(
              () => _Workflow(
                const ImageWorkflowState(focusedInpaintEnabled: true),
              ),
            ),
            focusedInpaintMaskRequestSizeProvider.overrideWith((ref) => mask),
          ],
        );
        await container.read(providerPricingCatalogProvider.future);
        expect(container.read(providerPriceEstimateProvider), isNull);
        container.dispose();
      }
    },
  );
}
