import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/models/image_generation_artifact.dart';
import '../../../core/models/provider_generation_usage.dart';
import '../../../core/services/provider_generation_usage_store.dart';
import '../../../core/services/provider_pricing_service.dart';
import '../../../core/network/browser_multipart_body.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/critical_network_activity.dart';
import '../../../core/network/nai_api_endpoint.dart';
import '../../../core/network/nai_api_endpoint_service.dart';
import '../../../core/network/nai_chat_image_codec.dart';
import '../../../core/network/request_builders/nai_image_request_builder.dart';
import '../../../core/utils/app_logger.dart';
import '../../models/image/image_params.dart';
import '../../models/image/image_stream_chunk.dart';
import '../../services/auth_provider.dart';
import 'nai_generation_response_processor.dart';
import 'nai_generation_transport.dart';
import 'nai_image_enhancement_api_service.dart';

part 'nai_image_generation_api_service.g.dart';

/// Compatibility facade for NovelAI image generation.
///
/// Request construction remains coordinated here while transport mechanics and
/// response decoding/composition live in dedicated collaborators.
class NAIImageGenerationApiService {
  NAIImageGenerationApiService(
    Dio dio,
    this._enhancementService,
    NaiApiEndpointService endpointService, [
    CriticalNetworkActivityCoordinator? networkActivity,
    ProviderGenerationUsageStore? usageStore,
    this._pricingService,
  ]) : _usageStore = usageStore,
       _endpointService = endpointService,
       _transport = NaiGenerationTransport(dio, endpointService),
       _responseProcessor = NaiGenerationResponseProcessor(),
       _networkActivity =
           networkActivity ?? CriticalNetworkActivityCoordinator.instance;

  static final Object _cancellationLeaseZoneKey = Object();

  final NAIImageEnhancementApiService _enhancementService;
  final NaiApiEndpointService _endpointService;
  final NaiGenerationTransport _transport;
  final NaiGenerationResponseProcessor _responseProcessor;
  final CriticalNetworkActivityCoordinator _networkActivity;
  final ProviderGenerationUsageStore? _usageStore;
  final ProviderPricingService? _pricingService;
  var _legacyCancellationEpoch = 0;

  static T withCancellationLease<T>(
    NaiGenerationCancellationLease lease,
    T Function() action,
  ) => runZoned(
    action,
    zoneValues: <Object?, Object?>{_cancellationLeaseZoneKey: lease},
  );

  static NaiGenerationCancellationLease? _effectiveCancellationLease(
    NaiGenerationCancellationLease? explicitLease,
  ) =>
      explicitLease ??
      Zone.current[_cancellationLeaseZoneKey]
          as NaiGenerationCancellationLease?;

  /// Maps model-specific sampler compatibility exactly as the legacy service.
  @visibleForTesting
  static String mapSamplerForModel(String sampler, String model) {
    final mapped = Samplers.resolveForModel(sampler, model);
    if (mapped == sampler) return sampler;
    if (mapped == Samplers.kEulerAncestral) {
      AppLogger.w(
        'Model $model does not support DDIM sampler, falling back to Euler Ancestral',
        'ImgGen',
      );
    } else {
      AppLogger.i('Mapping DDIM to DDIM v3 for model: $model', 'ImgGen');
    }
    return mapped;
  }

  /// Retained for callers and tests that inspect the official multipart shape.
  @visibleForTesting
  static BrowserMultipartBody buildGenerationMultipart(
    Map<String, dynamic> requestData,
  ) {
    return NaiGenerationTransport.buildGenerationMultipart(requestData);
  }

  Future<(List<Uint8List>, Map<int, String>)> generateImage(
    ImageParams params, {
    void Function(int, int)? onProgress,
    bool focusedInpaintEnabled = false,
    double minimumContextMegaPixels = 88.0,
    Rect? focusedSelectionRect,
    Rect? focusedContextCrop,
    NaiGenerationCancellationLease? cancellationLease,
  }) async {
    final result = await _generateImageArtifacts(
      params,
      onProgress: onProgress,
      focusedInpaintEnabled: focusedInpaintEnabled,
      minimumContextMegaPixels: minimumContextMegaPixels,
      focusedSelectionRect: focusedSelectionRect,
      focusedContextCrop: focusedContextCrop,
      cancellationLease: cancellationLease,
    );
    return (
      result.$1
          .map((artifact) => artifact.displayImageBytes)
          .toList(growable: false),
      result.$2,
    );
  }

  Future<(List<Uint8List>, Map<int, String>)>
  generateImageWithEncodingsCancellable(
    ImageParams params, {
    void Function(int, int)? onProgress,
    bool focusedInpaintEnabled = false,
    double minimumContextMegaPixels = 88.0,
    Rect? focusedSelectionRect,
    Rect? focusedContextCrop,
    NaiGenerationCancellationLease? cancellationLease,
  }) {
    return generateImage(
      params,
      onProgress: onProgress,
      focusedInpaintEnabled: focusedInpaintEnabled,
      minimumContextMegaPixels: minimumContextMegaPixels,
      focusedSelectionRect: focusedSelectionRect,
      focusedContextCrop: focusedContextCrop,
      cancellationLease: cancellationLease,
    );
  }

  Future<List<Uint8List>> generateImageCancellable(
    ImageParams params, {
    void Function(int, int)? onProgress,
    bool focusedInpaintEnabled = false,
    double minimumContextMegaPixels = 88.0,
    Rect? focusedSelectionRect,
    Rect? focusedContextCrop,
    NaiGenerationCancellationLease? cancellationLease,
  }) async {
    final result = await generateImageWithEncodingsCancellable(
      params,
      onProgress: onProgress,
      focusedInpaintEnabled: focusedInpaintEnabled,
      minimumContextMegaPixels: minimumContextMegaPixels,
      focusedSelectionRect: focusedSelectionRect,
      focusedContextCrop: focusedContextCrop,
      cancellationLease: cancellationLease,
    );
    return result.$1;
  }

  Future<List<ImageGenerationArtifact>> generateImageArtifactsCancellable(
    ImageParams params, {
    void Function(int, int)? onProgress,
    bool focusedInpaintEnabled = false,
    double minimumContextMegaPixels = 88.0,
    Rect? focusedSelectionRect,
    Rect? focusedContextCrop,
    NaiGenerationCancellationLease? cancellationLease,
  }) async {
    final result = await _generateImageArtifacts(
      params,
      onProgress: onProgress,
      focusedInpaintEnabled: focusedInpaintEnabled,
      minimumContextMegaPixels: minimumContextMegaPixels,
      focusedSelectionRect: focusedSelectionRect,
      focusedContextCrop: focusedContextCrop,
      cancellationLease: cancellationLease,
    );
    return result.$1;
  }

  Future<(List<ImageGenerationArtifact>, Map<int, String>)>
  _generateImageArtifacts(
    ImageParams params, {
    void Function(int, int)? onProgress,
    required bool focusedInpaintEnabled,
    required double minimumContextMegaPixels,
    Rect? focusedSelectionRect,
    Rect? focusedContextCrop,
    NaiGenerationCancellationLease? cancellationLease,
  }) async {
    final activity = _networkActivity.acquire(
      CriticalNetworkActivityType.imageGeneration,
    );
    final request = _transport.beginRequest(
      _effectiveCancellationLease(cancellationLease),
    );
    try {
      final command = await _prepareCommand(
        params,
        isStream: false,
        focusedInpaintEnabled: focusedInpaintEnabled,
        minimumContextMegaPixels: minimumContextMegaPixels,
        focusedSelectionRect: focusedSelectionRect,
        focusedContextCrop: focusedContextCrop,
      );
      _validatePreparedSession(command, request);
      if (command.isChatApi) {
        final artifact = await _sendChat(
          command,
          request,
          onProgress: onProgress,
        );
        return ([artifact], <int, String>{});
      }
      final response = await _transport.sendZip(
        command.buildResult.requestData,
        request,
        onProgress: onProgress,
      );
      final artifacts = await _responseProcessor.processZip(
        response.data!,
        command.responseContext,
      );
      return (artifacts, command.buildResult.vibeEncodingMap);
    } finally {
      _transport.completeRequest(request);
      activity.release();
    }
  }

  NaiGenerationCancellationLease createCancellationLease() =>
      _transport.createCancellationLease();

  /// Cancels one run when [lease] is supplied. The no-argument form is kept
  /// for legacy callers and targets only the transport's latest request.
  void cancelGeneration([NaiGenerationCancellationLease? lease]) {
    if (lease == null) {
      _legacyCancellationEpoch += 1;
      _transport.cancelCurrentRequest();
    } else {
      _transport.cancelLease(lease);
    }
  }

  void cancelCurrentGenerationRequest(NaiGenerationCancellationLease lease) =>
      _transport.cancelCurrentRequest(lease);

  void releaseCancellationLease(NaiGenerationCancellationLease lease) =>
      _transport.releaseLease(lease);

  Stream<ImageStreamChunk> generateImageStream(
    ImageParams params, {
    bool focusedInpaintEnabled = false,
    double minimumContextMegaPixels = 88.0,
    Rect? focusedSelectionRect,
    Rect? focusedContextCrop,
    NaiGenerationCancellationLease? cancellationLease,
  }) {
    final effectiveLease = _effectiveCancellationLease(cancellationLease);
    final legacyCancellationEpoch = effectiveLease == null
        ? _legacyCancellationEpoch
        : null;
    return _generateImageStream(
      params,
      effectiveLease,
      legacyCancellationEpoch: legacyCancellationEpoch,
      focusedInpaintEnabled: focusedInpaintEnabled,
      minimumContextMegaPixels: minimumContextMegaPixels,
      focusedSelectionRect: focusedSelectionRect,
      focusedContextCrop: focusedContextCrop,
    );
  }

  Stream<ImageStreamChunk> _generateImageStream(
    ImageParams params,
    NaiGenerationCancellationLease? cancellationLease, {
    required int? legacyCancellationEpoch,
    required bool focusedInpaintEnabled,
    required double minimumContextMegaPixels,
    Rect? focusedSelectionRect,
    Rect? focusedContextCrop,
  }) async* {
    // async* does not execute until listen, so an abandoned stream owns no
    // transport request. Leases and the legacy epoch retain pre-listen cancel.
    final activity = _networkActivity.acquire(
      CriticalNetworkActivityType.imageGeneration,
    );
    final request = _transport.beginRequest(cancellationLease);
    try {
      if (legacyCancellationEpoch != null &&
          legacyCancellationEpoch != _legacyCancellationEpoch) {
        request.cancelToken.cancel('Generation cancelled before listen');
      }
      if (request.cancelToken.isCancelled) {
        yield ImageStreamChunk.error('Cancelled');
        return;
      }
      final command = await _prepareCommand(
        params,
        isStream: true,
        focusedInpaintEnabled: focusedInpaintEnabled,
        minimumContextMegaPixels: minimumContextMegaPixels,
        focusedSelectionRect: focusedSelectionRect,
        focusedContextCrop: focusedContextCrop,
      );
      if (request.cancelToken.isCancelled) {
        yield ImageStreamChunk.error('Cancelled');
        return;
      }

      _validatePreparedSession(command, request);
      if (command.isChatApi) {
        final artifact = await _sendChat(command, request);
        if (request.cancelToken.isCancelled) {
          yield ImageStreamChunk.error('Cancelled');
          return;
        }
        yield ImageStreamChunk.complete(
          artifact.displayImageBytes,
          sampleIndex: 0,
        );
        return;
      }
      final response = await _transport.sendStream(
        command.buildResult.requestData,
        request,
      );
      yield* _responseProcessor.processMessagePackStream(
        response.data!.stream,
        command.responseContext,
        cancelToken: request.cancelToken,
      );
    } on DioException catch (error) {
      yield ImageStreamChunk.error(
        await _responseProcessor.formatStreamDioError(error),
      );
    } catch (error) {
      AppLogger.e('Stream generation failed: $error', 'ImgGen');
      yield ImageStreamChunk.error(error.toString());
    } finally {
      _transport.completeRequest(request);
      activity.release();
    }
  }

  void _validatePreparedSession(
    _PreparedGeneration command,
    NaiGenerationRequest request,
  ) {
    if (command.endpoint != _endpointService.current ||
        command.usageSessionEpoch != (_usageStore?.sessionEpoch ?? 0)) {
      request.cancelToken.cancel(
        'Generation session changed during preparation',
      );
    }
    if (request.cancelToken.isCancelled) throw request.cancelToken.cancelError!;
  }

  Future<ImageGenerationArtifact> _sendChat(
    _PreparedGeneration command,
    NaiGenerationRequest request, {
    void Function(int, int)? onProgress,
  }) async {
    if (request.cancelToken.isCancelled) throw request.cancelToken.cancelError!;
    final payload = await NAIChatImageCodec.buildRequest(
      params: command.responseContext.originalParams,
      nativeRequestData: command.buildResult.requestData,
    );
    _validatePreparedSession(command, request);
    final requestedAt = DateTime.now().toUtc();
    final endpoint = command.endpoint;
    final response = await _transport.sendChat(
      payload,
      request,
      onProgress: onProgress,
    );
    final decoded = NAIChatImageCodec.decodeResponse(response.data ?? '');
    AppLogger.d(
      'Chat drawing complete: usageFields=${decoded.usage.length}, '
          'vibeCacheCount=${decoded.vibeCacheIds.length}',
      'ImgGen',
    );
    final image = await NAIChatImageCodec.withRequestMetadata(
      decoded,
      params: command.responseContext.originalParams,
      requestSeed: command.buildResult.seed,
      requestParameters: command.buildResult.requestParameters,
    );
    if (request.cancelToken.isCancelled) throw request.cancelToken.cancelError!;
    final artifact = await _responseProcessor.composeImage(
      image,
      command.responseContext,
    );
    if (request.cancelToken.isCancelled) throw request.cancelToken.cancelError!;
    if (endpoint == _endpointService.current) {
      _usageStore?.record(
        ProviderGenerationUsage(
          endpoint: endpoint.imageBaseUrl,
          requestedModel: payload['model'] as String,
          responseModel: decoded.model,
          requestId:
              decoded.requestId ?? response.headers.value('x-request-id'),
          requestedAt: requestedAt,
          sessionEpoch: command.usageSessionEpoch,
          catalogSnapshot: command.pricingCatalog,
          promptTokens: ProviderGenerationUsage.parseTokenCount(
            decoded.usage['prompt_tokens'],
          ),
          completionTokens: ProviderGenerationUsage.parseTokenCount(
            decoded.usage['completion_tokens'],
          ),
          totalTokens: ProviderGenerationUsage.parseTokenCount(
            decoded.usage['total_tokens'],
          ),
        ),
      );
    }
    return artifact;
  }

  Future<_PreparedGeneration> _prepareCommand(
    ImageParams params, {
    required bool isStream,
    required bool focusedInpaintEnabled,
    required double minimumContextMegaPixels,
    Rect? focusedSelectionRect,
    Rect? focusedContextCrop,
  }) async {
    final endpoint = _endpointService.current;
    final usageSessionEpoch = _usageStore?.sessionEpoch ?? 0;
    final pricingCatalog = _pricingService?.currentCatalog;
    if (endpoint.isOpenAiCompatible) {
      NAIChatImageCodec.validateParams(params);
    }
    final focusedRequest = await _responseProcessor.prepareFocusedInpaint(
      params,
      enabled: focusedInpaintEnabled,
      minimumContextMegaPixels: minimumContextMegaPixels,
      focusedSelectionRect: focusedSelectionRect,
      focusedContextCrop: focusedContextCrop,
    );
    final effectiveParams = _responseProcessor.applyFocusedRequest(
      params,
      focusedRequest,
    );

    final isCompatible = endpoint.isOpenAiCompatible;
    if (!isCompatible &&
        effectiveParams.hasVibeReferencesV4 &&
        effectiveParams.hasPreciseReferences) {
      AppLogger.d(
        'Both Vibe Transfer and Precise Reference are enabled; skipping vibe payload in favor of Precise Reference',
        'ImgGen',
      );
    }
    final preciseReferences = isCompatible || effectiveParams.isV45Model
        ? effectiveParams.enabledPreciseReferences
        : <PreciseReference>[];
    final buildResult =
        await NAIImageRequestBuilder(
          params: effectiveParams,
          isOpenAiCompatible: isCompatible,
          useChatApi: isCompatible,
          encodeVibe: _enhancementService.encodeVibe,
          preciseReferences: preciseReferences,
        ).build(
          sampler: mapSamplerForModel(
            effectiveParams.sampler,
            effectiveParams.model,
          ),
          isStream: isStream,
        );

    AppLogger.d(
      'Generating image with action: ${effectiveParams.action.value}, model: ${effectiveParams.model}',
      'ImgGen',
    );

    return _PreparedGeneration(
      endpoint: endpoint,
      usageSessionEpoch: usageSessionEpoch,
      pricingCatalog: pricingCatalog,
      isChatApi: isCompatible,
      buildResult: buildResult,
      responseContext: NaiGenerationResponseContext(
        originalParams: params,
        focusedRequest: focusedRequest,
        requestBuildResult: buildResult,
      ),
    );
  }
}

class _PreparedGeneration {
  const _PreparedGeneration({
    required this.endpoint,
    required this.usageSessionEpoch,
    required this.pricingCatalog,
    required this.isChatApi,
    required this.buildResult,
    required this.responseContext,
  });

  final NaiApiEndpointConfig endpoint;
  final int usageSessionEpoch;
  final ProviderPricingCatalog? pricingCatalog;
  final bool isChatApi;
  final NAIImageRequestBuildResult buildResult;
  final NaiGenerationResponseContext responseContext;
}

/// NAIImageGenerationApiService Provider.
///
/// keepAlive ensures cancellation reaches the same facade and transport lease
/// that started the in-flight request.
@Riverpod(keepAlive: true)
NAIImageGenerationApiService naiImageGenerationApiService(Ref ref) {
  final dio = ref.watch(dioClientProvider);
  final enhancementService = ref.watch(naiImageEnhancementApiServiceProvider);
  final endpointService = ref.watch(naiApiEndpointServiceProvider);
  final usageStore = ref.watch(providerGenerationUsageStoreProvider);
  ref.listen(
    authNotifierProvider.select((auth) => (auth.status, auth.accountId)),
    (previous, next) => usageStore.clear(),
  );
  return NAIImageGenerationApiService(
    dio,
    enhancementService,
    endpointService,
    null,
    usageStore,
    ref.watch(providerPricingServiceProvider),
  );
}
