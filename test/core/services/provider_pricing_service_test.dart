import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/services/provider_pricing_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _v45 = 'nai-diffusion-4-5-full';
const _v5 = 'nai-diffusion-5-curated';
const _condition = 'p==1 && c>=10000 && floor(c/10000)*10000==c';
const _expr45 = '$_condition ? tier("anlas",c*1) : tier("free",fixed(0))';
const _expr5 =
    '$_condition ? tier("anlas",50000+c*1) : tier("base",fixed(0.05))';
final _now = DateTime.utc(2026, 11, 1, 12);

Map<String, dynamic> _payload({
  String version = 'version-1',
  String expression45 = _expr45,
  String expression5 = _expr5,
  double factor = 1,
}) => {
  'success': true,
  'pricing_version': version,
  'group_ratio': {PricingRule.groupName: factor},
  'currency': 'ignored',
  'data': [
    for (final entry in {_v45: expression45, _v5: expression5}.entries)
      {
        'model_name': entry.key,
        'billing_mode': 'tiered_expr',
        'billing_expr': entry.value,
        'enable_groups': [PricingRule.groupName],
      },
    {'model_name': 'other-provider-model'},
  ],
};

String _cache(Map<String, dynamic> payload, DateTime fetchedAt) => jsonEncode({
  'schema': 1,
  'fetched_at': fetchedAt.toIso8601String(),
  'catalog': payload,
});

ResponseBody _body(Object payload, {int status = 200}) =>
    ResponseBody.fromString(
      payload is String ? payload : jsonEncode(payload),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

typedef _Handler = FutureOr<ResponseBody> Function(RequestOptions options);

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);
  _Handler handler;
  final requests = <RequestOptions>[];
  bool closed = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) => closed = true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('bounded pricing rules', () {
    test('canonical 0, 1 and 12 Anlas estimates and fractional fixed base', () {
      final catalog = ProviderPricingCatalog.fromJson(
        _payload(),
        fetchedAt: _now,
      );
      expect(catalog.evaluateAnlas(_v45, 0)!.amount, 0);
      expect(catalog.evaluateAnlas(_v45, 1)!.amount, .01);
      expect(catalog.evaluateAnlas(_v45, 12)!.amount, .12);
      expect(catalog.evaluateAnlas(_v5, 0)!.amount, .05);
      expect(catalog.evaluateAnlas(_v5, 1)!.amount, .06);
      expect(catalog.evaluateAnlas(_v5, 12)!.amount, .17);
      expect(catalog.evaluateAnlas(_v5, 12)!.amountMicros, 170000);
      expect(catalog.evaluateAnlas(_v5, 0)!.completionTokens, 2);
      expect(catalog.evaluateAnlas(_v5, 0)!.tier, 'base');
      expect(catalog.evaluateAnlas(_v5, 12)!.usedAnlasBranch, isTrue);
      expect(catalog.evaluateAnlas('unknown', 12), isNull);
      expect(catalog.rules.keys, unorderedEquals([_v45, _v5]));
    });

    test('raw p=100000 never becomes synthetic p=1', () {
      final catalog = ProviderPricingCatalog.fromJson(
        _payload(),
        fetchedAt: _now,
      );
      for (final model in [_v45, _v5]) {
        final quote = catalog.evaluateUsage(
          model,
          promptTokens: 100000,
          completionTokens: 120000,
        )!;
        expect(quote.promptTokens, 100000);
        expect(quote.completionTokens, 120000);
        expect(quote.usedAnlasBranch, isFalse);
        expect(quote.amount, model == _v5 ? .05 : 0);
      }
    });

    test('server threshold and divisibility govern the selected branch', () {
      final rule = PricingRule(modelName: _v5, billingExpression: _expr5);
      for (final c in [0, 2, 9999, 10001, 120001]) {
        final quote = rule.evaluateUsage(promptTokens: 1, completionTokens: c)!;
        expect(quote.amount, .05);
        expect(quote.usedAnlasBranch, isFalse);
      }
      expect(
        rule.evaluateUsage(promptTokens: 1, completionTokens: 10000)!.amount,
        .06,
      );
    });

    test('numeric rate, offset, base and group changes are data-driven', () {
      final catalog = ProviderPricingCatalog.fromJson(
        _payload(
          expression5:
              '$_condition ? tier("anlas",7.5e4+c*2.5) : tier("base",fixed(.125))',
          factor: .4,
        ),
        fetchedAt: _now,
      );
      expect(catalog.evaluateAnlas(_v5, 12)!.amount, closeTo(.15, 1e-12));
      expect(catalog.evaluateAnlas(_v5, 0)!.amount, .05);
      expect(catalog.groupFactor, .4);
    });

    test(
      'unknown shapes, oversized rules and nonfinite values fail closed',
      () {
        for (final expression in [
          _expr5.replaceFirst('p==1', 'p==2'),
          _expr5.replaceFirst('10000', '1000'),
          _expr5.replaceFirst('c*1', 'c/1'),
          _expr5.replaceFirst('fixed(0.05)', 'fetch(0.05)'),
          _expr5.replaceFirst('50000', '-50000'),
          _expr5.replaceFirst('50000', '1e999'),
          _expr5.replaceFirst('floor', 'f loor'),
          '$_expr5; anything()',
          ' ' * 4097,
        ]) {
          final rule = PricingRule(
            modelName: _v5,
            billingExpression: expression,
          );
          expect(rule.isSupported, isFalse, reason: expression);
          expect(rule.evaluateAnlas(1), isNull);
        }
        expect(
          PricingRule(
            modelName: 'unknown',
            billingExpression: _expr5,
          ).isSupported,
          isFalse,
        );
        expect(
          PricingRule(
            modelName: _v5,
            billingExpression: _expr5,
            billingMode: 'unknown',
          ).evaluateAnlas(1),
          isNull,
        );
      },
    );

    test('invalid inputs and overflow never yield a fabricated zero', () {
      final rule = PricingRule(modelName: _v5, billingExpression: _expr5);
      expect(rule.evaluateAnlas(-1), isNull);
      expect(rule.evaluateAnlas(900719925475), isNull);
      expect(rule.evaluateAnlas(1, groupFactor: double.nan), isNull);
      expect(rule.evaluateAnlas(1, groupFactor: -1), isNull);
      expect(rule.evaluateUsage(promptTokens: -1, completionTokens: 2), isNull);
      expect(rule.evaluateUsage(promptTokens: 1, completionTokens: -1), isNull);
      expect(rule.evaluateAnlas(1, groupFactor: 0)!.amount, 0);
      final overflow = PricingRule(
        modelName: _v5,
        billingExpression: _expr5.replaceFirst('c*1', 'c*1e308'),
      );
      expect(overflow.evaluateAnlas(1), isNull);
    });

    test('invalid envelope, duplicate rule and disabled group handling', () {
      for (final payload in [
        _payload()..['success'] = false,
        _payload()..['pricing_version'] = '',
        _payload()..['group_ratio'] = {},
        _payload()..['group_ratio'] = {PricingRule.groupName: -1},
        _payload()..['data'] = ['bad'],
      ]) {
        expect(
          () => ProviderPricingCatalog.fromJson(payload, fetchedAt: _now),
          throwsFormatException,
        );
      }
      final duplicate = _payload();
      (duplicate['data'] as List).add((duplicate['data'] as List).first);
      expect(
        () => ProviderPricingCatalog.fromJson(duplicate, fetchedAt: _now),
        throwsFormatException,
      );
      final disabled = _payload();
      (disabled['data'] as List).first['enable_groups'] = ['other'];
      final catalog = ProviderPricingCatalog.fromJson(
        disabled,
        fetchedAt: _now,
      );
      expect(catalog.ruleFor(_v45), isNull);
      expect(catalog.evaluateAnlas(_v45, 1), isNull);
      expect(() => catalog.rules.clear(), throwsUnsupportedError);
    });
  });

  group('isolated public catalog service', () {
    late _Adapter adapter;
    late Dio injected;
    late ProviderPricingService service;
    late DateTime now;
    String? persisted;
    var writes = 0;

    setUp(() {
      now = _now;
      persisted = null;
      writes = 0;
      adapter = _Adapter((_) => _body(_payload()));
      injected = Dio()..httpClientAdapter = adapter;
      service = ProviderPricingService(
        dio: injected,
        readCache: () async => persisted,
        writeCache: (value) async {
          persisted = value;
          writes++;
        },
        clock: () => now,
      );
    });
    tearDown(() {
      service.dispose();
      injected.close(force: true);
    });

    test(
      'GET has no auth, cookies, app interceptors, redirects or app base URL',
      () async {
        injected.options.headers = {
          'Authorization': 'private',
          'Cookie': 'private',
        };
        injected.options.baseUrl = 'https://unrelated.invalid/proxy/';
        injected.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              fail('Authenticated interceptor must not run');
            },
          ),
        );
        final result = await service.getCatalog();
        expect(result.error, isNull);
        expect(result.isStale, isFalse);
        final request = adapter.requests.single;
        expect(
          request.uri.toString(),
          '${ProviderPricingService.publicOrigin}/api/pricing',
        );
        expect(request.method, 'GET');
        expect(
          request.headers.keys.map((key) => key.toLowerCase()),
          isNot(contains(anyOf('authorization', 'cookie'))),
        );
        expect(request.followRedirects, isFalse);
        expect(request.maxRedirects, 0);
        expect(request.connectTimeout, const Duration(seconds: 5));
        expect(request.sendTimeout, const Duration(seconds: 5));
        expect(request.receiveTimeout, const Duration(seconds: 5));
        expect(request.responseType, ResponseType.stream);
        expect(writes, 1);
        expect(persisted, isNot(contains('private')));
        expect(persisted, isNot(contains('currency')));
      },
    );

    test(
      'strict normalized provider origin guards cache and network',
      () async {
        for (final origin in [
          'http://api.cunzaijiang.cn',
          'https://api.cunzaijiang.cn.evil.invalid',
          'https://api.cunzaijiang.cn:444',
          'https://private@api.cunzaijiang.cn',
          'https://api.cunzaijiang.cn/v1',
          'https://api.cunzaijiang.cn/?x=1',
          'https://api.cunzaijiang.cn/#fragment',
          'https://other.invalid',
        ]) {
          final rejected = ProviderPricingService(
            origin: origin,
            dio: injected,
            readCache: () async => throw StateError('Cache must not be read'),
          );
          final result = await rejected.getCatalog();
          expect(result.error, ProviderPricingError.unsupportedOrigin);
          expect(result.catalog, isNull);
          rejected.dispose();
        }
        expect(adapter.requests, isEmpty);
        expect(
          ProviderPricingService.supportsOrigin(
            'HTTPS://API.CUNZAIJIANG.CN:443/',
          ),
          isTrue,
        );
        expect(
          ProviderPricingService.supportsOrigin('https://api.cunzaijiang.cn/'),
          isTrue,
        );
      },
    );

    test(
      'fresh durable cache avoids network and preserves server version',
      () async {
        persisted = _cache(
          _payload(version: 'cached'),
          now.subtract(const Duration(minutes: 10)),
        );
        final result = await service.getCatalog();
        expect(result.catalog!.pricingVersion, 'cached');
        expect(result.isStale, isFalse);
        expect(adapter.requests, isEmpty);
        expect(writes, 0);
      },
    );

    test(
      'one-hour TTL refreshes; failures keep last success and stale age',
      () async {
        await service.getCatalog();
        adapter.handler = (options) =>
            throw DioException(requestOptions: options);
        now = now.add(const Duration(minutes: 5));
        final freshFailure = await service.getCatalog(forceRefresh: true);
        expect(freshFailure.isStale, isFalse);
        expect(freshFailure.error, ProviderPricingError.network);
        expect(freshFailure.catalog!.fetchedAt, _now);
        now = _now.add(const Duration(hours: 1));
        final staleFailure = await service.getCatalog();
        expect(staleFailure.isStale, isTrue);
        expect(staleFailure.catalog!.pricingVersion, 'version-1');
        expect(writes, 1);
        adapter.handler = (_) => _body(_payload(version: 'updated'));
        final updated = await service.getCatalog();
        expect(updated.catalog!.pricingVersion, 'updated');
        expect(updated.isStale, isFalse);
        expect(updated.error, isNull);
        expect(writes, 2);
      },
    );

    test(
      'malformed response or redirect never replaces successful cache',
      () async {
        final original = await service.getCatalog();
        expect(service.currentCatalog, same(original.catalog));
        final originalCache = persisted;
        for (final body in [
          _body(_payload()..['success'] = false),
          _body('{broken'),
          _body([]),
          _body(_payload()..['group_ratio'] = {}),
          ResponseBody.fromString(
            '',
            302,
            headers: {
              'location': ['https://other.invalid'],
            },
          ),
        ]) {
          adapter.handler = (_) => body;
          final result = await service.getCatalog(forceRefresh: true);
          expect(result.error, ProviderPricingError.invalidResponse);
          expect(result.catalog, same(original.catalog));
          expect(persisted, originalCache);
        }
        expect(writes, 1);
      },
    );

    test(
      'new valid unsupported protocol invalidates old supported quotes',
      () async {
        await service.getCatalog();
        adapter.handler = (_) =>
            _body(_payload(version: 'new', expression5: 'new_protocol()'));
        final result = await service.getCatalog(forceRefresh: true);
        expect(result.catalog!.pricingVersion, 'new');
        expect(result.catalog!.ruleFor(_v5)!.isSupported, isFalse);
        expect(result.catalog!.evaluateAnlas(_v5, 1), isNull);
        expect(result.error, isNull);
      },
    );

    test('stream and declared response size are bounded to one MiB', () async {
      for (final declared in [false, true]) {
        var consumed = 0;
        Stream<Uint8List> oversized() async* {
          consumed++;
          yield Uint8List(ProviderPricingService.maxResponseBytes);
          consumed++;
          yield Uint8List(1);
          consumed++;
          yield Uint8List(1);
        }

        adapter.handler = (_) => ResponseBody(
          oversized(),
          200,
          headers: declared
              ? {
                  'content-length': ['1048577'],
                }
              : {},
        );
        final result = await service.getCatalog(forceRefresh: true);
        expect(result.error, ProviderPricingError.invalidResponse);
        expect(result.catalog, isNull);
        expect(consumed, declared ? 0 : 2);
      }
      expect(writes, 0);
    });

    test(
      'initial offline load exposes expired durable cache and error',
      () async {
        final fetchedAt = now.subtract(const Duration(hours: 2));
        persisted = _cache(_payload(version: 'offline-cache'), fetchedAt);
        adapter.handler = (options) =>
            throw DioException(requestOptions: options);
        final result = await service.getCatalog();
        expect(result.catalog!.pricingVersion, 'offline-cache');
        expect(result.catalog!.fetchedAt, fetchedAt);
        expect(result.isStale, isTrue);
        expect(result.error, ProviderPricingError.network);
        expect(writes, 0);
      },
    );

    test('exactly one MiB is accepted when valid JSON', () async {
      final json = jsonEncode(_payload());
      final padding =
          ProviderPricingService.maxResponseBytes - utf8.encode(json).length;
      adapter.handler = (_) => _body('$json${' ' * padding}');
      expect((await service.getCatalog()).error, isNull);
    });

    test(
      'broken/future cache recovers by fetching valid public data',
      () async {
        persisted = _cache(_payload(), now.add(const Duration(days: 1)));
        final result = await service.getCatalog();
        expect(result.error, isNull);
        expect(result.catalog!.fetchedAt, now);
        expect(adapter.requests, hasLength(1));
      },
    );

    test('failed cache save does not discard a newly fetched quote', () async {
      final failing = ProviderPricingService(
        dio: injected,
        readCache: () async => 'broken',
        writeCache: (_) async => throw StateError('full'),
        clock: () => now,
      );
      final result = await failing.getCatalog();
      expect(result.error, ProviderPricingError.cacheUnavailable);
      expect(result.isStale, isFalse);
      expect(result.catalog!.evaluateAnlas(_v5, 1)!.amount, .06);
      failing.dispose();
    });

    test('parallel callers share one public fetch', () async {
      final body = Completer<ResponseBody>();
      final requested = Completer<void>();
      adapter.handler = (_) {
        requested.complete();
        return body.future;
      };
      final first = service.getCatalog();
      final second = service.getCatalog(forceRefresh: true);
      await requested.future;
      expect(adapter.requests, hasLength(1));
      body.complete(_body(_payload()));
      final results = await Future.wait([first, second]);
      expect(results[0].catalog, same(results[1].catalog));
      expect(writes, 1);
    });

    test('total request deadline is five seconds even if adapter stalls', () {
      fakeAsync((async) {
        final stalled = Completer<ResponseBody>();
        adapter.handler = (_) => stalled.future;
        ProviderPricingResult? result;
        service.getCatalog().then((value) => result = value);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 4));
        expect(result, isNull);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(result!.error, ProviderPricingError.network);
        expect(result!.catalog, isNull);
        stalled.complete(_body(_payload()));
        async.flushMicrotasks();
        expect(writes, 0);
      });
    });

    test(
      'default SharedPreferences cache is durable between instances',
      () async {
        SharedPreferences.setMockInitialValues({});
        final first = ProviderPricingService(dio: injected, clock: () => now);
        await first.getCatalog();
        first.dispose();
        final second = ProviderPricingService(dio: injected, clock: () => now);
        final result = await second.getCatalog();
        expect(result.catalog!.pricingVersion, 'version-1');
        expect(adapter.requests, hasLength(1));
        expect(
          (await SharedPreferences.getInstance()).getString(
            ProviderPricingService.cacheKey,
          ),
          isNotNull,
        );
        second.dispose();
      },
    );
  });
}
