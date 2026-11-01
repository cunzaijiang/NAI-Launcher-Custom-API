import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/provider_pricing.dart';

export '../models/provider_pricing.dart';

typedef PricingCacheRead = Future<String?> Function();
typedef PricingCacheWrite = Future<void> Function(String value);

final providerPricingServiceProvider = Provider<ProviderPricingService>((ref) {
  final service = ProviderPricingService();
  ref.onDispose(service.dispose);
  return service;
});

/// Fetches public prices using an isolated client, never the authenticated app
/// client. An injected Dio supplies ONLY its adapter, not headers/interceptors.
class ProviderPricingService {
  ProviderPricingService({
    Dio? dio,
    PricingCacheRead? readCache,
    PricingCacheWrite? writeCache,
    DateTime Function()? clock,
    this.origin = publicOrigin,
  }) : _dio = Dio(BaseOptions(connectTimeout: requestTimeout)),
       _ownsAdapter = dio == null,
       _readCache = readCache ?? _defaultReadCache,
       _writeCache = writeCache ?? _defaultWriteCache,
       _clock = clock ?? DateTime.now {
    _dio.httpClientAdapter = _BoundedPricingAdapter(
      dio?.httpClientAdapter ?? _dio.httpClientAdapter,
    );
  }

  static const publicOrigin = 'https://api.cunzaijiang.cn';
  static const cacheTtl = Duration(hours: 1);
  static const requestTimeout = Duration(seconds: 5);
  static const maxResponseBytes = 1024 * 1024;
  // Device-local cache: cloud sync exports an explicit Hive settings allowlist,
  // not SharedPreferences. This key contains public data only, never credentials.
  static const cacheKey = 'provider_public_pricing_cache_v1';

  final String origin;
  final Dio _dio;
  final bool _ownsAdapter;
  final PricingCacheRead _readCache;
  final PricingCacheWrite _writeCache;
  final DateTime Function() _clock;
  ProviderPricingCatalog? _catalog;
  ProviderPricingError? _lastError;
  Future<void>? _cacheLoad;
  Future<ProviderPricingResult>? _inFlight;
  CancelToken? _cancelToken;

  /// The last validated catalog, without initiating any network operation.
  ProviderPricingCatalog? get currentCatalog => _catalog;

  /// No request (or cached provider quote) is allowed for proxy prefixes or
  /// another origin. Explicit default port, case and trailing slash normalize.
  static bool supportsOrigin(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        uri.scheme.toLowerCase() == 'https' &&
        uri.host.toLowerCase() == 'api.cunzaijiang.cn' &&
        uri.port == 443 &&
        uri.userInfo.isEmpty &&
        (uri.path.isEmpty || uri.path == '/') &&
        !uri.hasQuery &&
        !uri.hasFragment;
  }

  Future<ProviderPricingResult> getCatalog({bool forceRefresh = false}) async {
    if (!supportsOrigin(origin)) {
      return const ProviderPricingResult(
        catalog: null,
        isStale: true,
        error: ProviderPricingError.unsupportedOrigin,
      );
    }
    await (_cacheLoad ??= _loadCache());
    final pending = _inFlight;
    if (pending != null) return pending;
    if (!forceRefresh && _catalog != null && !_isStale) return _result();
    final refresh = _refresh();
    _inFlight = refresh;
    try {
      return await refresh;
    } finally {
      _inFlight = null;
    }
  }

  bool get _isStale {
    final catalog = _catalog;
    if (catalog == null) return true;
    final age = _clock().toUtc().difference(catalog.fetchedAt);
    return age.isNegative || age >= cacheTtl;
  }

  ProviderPricingResult _result() => ProviderPricingResult(
    catalog: _catalog,
    isStale: _isStale,
    error: _lastError,
  );

  Future<void> _loadCache() async {
    try {
      final cached = await _readCache();
      if (cached == null) return;
      if (cached.length > maxResponseBytes ||
          utf8.encode(cached).length > maxResponseBytes) {
        throw const FormatException('Cache exceeds limit');
      }
      final decoded = jsonDecode(cached);
      if (decoded is! Map<String, dynamic> || decoded['schema'] != 1) {
        throw const FormatException('Invalid cache schema');
      }
      final fetchedAt = DateTime.tryParse(decoded['fetched_at'] as String);
      final payload = decoded['catalog'];
      if (fetchedAt == null ||
          fetchedAt.isAfter(_clock().toUtc()) ||
          payload is! Map<String, dynamic>) {
        throw const FormatException('Invalid cached catalog');
      }
      _catalog = ProviderPricingCatalog.fromJson(payload, fetchedAt: fetchedAt);
    } catch (_) {
      // A broken cache must not block a new public fetch.
      _lastError = ProviderPricingError.cacheUnavailable;
    }
  }

  Future<ProviderPricingResult> _refresh() async {
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    try {
      final payload = await _fetch(cancelToken).timeout(
        requestTimeout,
        onTimeout: () {
          cancelToken.cancel('Public pricing timeout');
          throw TimeoutException('Public pricing timeout');
        },
      );
      // Only a completely validated success replaces the last successful data.
      final catalog = ProviderPricingCatalog.fromJson(
        payload,
        fetchedAt: _clock(),
      );
      _catalog = catalog;
      _lastError = null;
      try {
        await _writeCache(
          jsonEncode({
            'schema': 1,
            'fetched_at': catalog.fetchedAt.toIso8601String(),
            'catalog': catalog.toJson(),
          }),
        );
      } catch (_) {
        _lastError = ProviderPricingError.cacheUnavailable;
      }
    } on FormatException {
      _lastError = ProviderPricingError.invalidResponse;
    } on DioException catch (error) {
      _lastError =
          error.type == DioExceptionType.badResponse ||
              error.error is FormatException
          ? ProviderPricingError.invalidResponse
          : ProviderPricingError.network;
    } catch (_) {
      _lastError = ProviderPricingError.network;
    } finally {
      // Also release an adapter response rejected before stream subscription.
      cancelToken.cancel('Public pricing request finished');
      _cancelToken = null;
    }
    return _result();
  }

  Future<Map<String, dynamic>> _fetch(CancelToken cancelToken) async {
    // Every effective request option is supplied here; injected app client
    // options, auth and cookie interceptors are intentionally not inherited.
    final response = await _dio.get<ResponseBody>(
      '$publicOrigin/api/pricing',
      cancelToken: cancelToken,
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'application/json'},
        followRedirects: false,
        maxRedirects: 0,
        receiveDataWhenStatusError: false,
        sendTimeout: requestTimeout,
        receiveTimeout: requestTimeout,
        validateStatus: (status) => status == 200,
      ),
    );
    final body = response.data;
    if (body == null) throw const FormatException('Empty public pricing');
    final lengths = response.headers[Headers.contentLengthHeader];
    if (lengths != null &&
        lengths.any((value) => (int.tryParse(value) ?? 0) > maxResponseBytes)) {
      cancelToken.cancel('Public pricing exceeds size limit');
      throw const FormatException('Public pricing exceeds size limit');
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in body.stream) {
      if (bytes.length + chunk.length > maxResponseBytes) {
        cancelToken.cancel('Public pricing exceeds size limit');
        throw const FormatException('Public pricing exceeds size limit');
      }
      bytes.add(chunk);
    }
    final decoded = jsonDecode(utf8.decode(bytes.takeBytes()));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid public pricing JSON');
    }
    return decoded;
  }

  void dispose() {
    _cancelToken?.cancel('Public pricing service disposed');
    if (_ownsAdapter) _dio.close(force: true);
  }

  static Future<String?> _defaultReadCache() async =>
      (await SharedPreferences.getInstance()).getString(cacheKey);

  static Future<void> _defaultWriteCache(String value) async {
    final saved = await (await SharedPreferences.getInstance()).setString(
      cacheKey,
      value,
    );
    if (!saved) throw StateError('Public pricing cache write failed');
  }
}

/// Bound data before Dio's stream handler subscribes and buffers it. Consumer
/// checks alone are insufficient because Dio eagerly subscribes to the source.
class _BoundedPricingAdapter implements HttpClientAdapter {
  _BoundedPricingAdapter(this.inner);
  final HttpClientAdapter inner;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = await inner.fetch(options, requestStream, cancelFuture);
    final declaredLengths = body.headers.entries
        .where(
          (entry) => entry.key.toLowerCase() == Headers.contentLengthHeader,
        )
        .expand((entry) => entry.value);
    if (declaredLengths.any(
      (value) =>
          (int.tryParse(value) ?? 0) > ProviderPricingService.maxResponseBytes,
    )) {
      throw DioException(
        requestOptions: options,
        error: const FormatException('Public pricing exceeds size limit'),
      );
    }
    body.stream = _limit(body.stream);
    return body;
  }

  Stream<Uint8List> _limit(Stream<Uint8List> source) async* {
    var count = 0;
    await for (final chunk in source) {
      count += chunk.length;
      if (count > ProviderPricingService.maxResponseBytes) {
        // Throw before forwarding the chunk into Dio's eager stream buffer.
        throw const FormatException('Public pricing exceeds size limit');
      }
      yield chunk;
    }
  }

  @override
  void close({bool force = false}) => inner.close(force: force);
}
