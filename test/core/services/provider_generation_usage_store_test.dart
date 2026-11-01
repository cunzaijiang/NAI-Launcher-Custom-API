import 'package:flutter_test/flutter_test.dart';
import 'package:nai_launcher/core/models/provider_generation_usage.dart';
import 'package:nai_launcher/core/services/provider_generation_usage_store.dart';

void main() {
  ProviderGenerationUsage usage(int epoch, {int seconds = 0}) =>
      ProviderGenerationUsage(
        endpoint: 'https://provider.invalid/v1',
        requestedModel: 'requested-model',
        responseModel: 'observed-model',
        requestedAt: DateTime.utc(2026, 1, 1, 0, 0, seconds),
        sessionEpoch: epoch,
        promptTokens: 100000,
        completionTokens: 1850000,
        totalTokens: 1950000,
      );

  test('preserves returned counts without Anlas normalization', () {
    final store = ProviderGenerationUsageStore();
    addTearDown(store.dispose);
    store.record(usage(store.sessionEpoch));
    expect(store.latest!.promptTokens, 100000);
    expect(store.latest!.actualModel, 'observed-model');
  });

  test('session clear invalidates old requests and publishes reset', () async {
    final store = ProviderGenerationUsageStore();
    addTearDown(store.dispose);
    final events = <ProviderGenerationUsage?>[];
    final subscription = store.changes.listen(events.add);
    addTearDown(subscription.cancel);
    final old = usage(store.sessionEpoch);
    store.record(old);
    store.clear();
    store.record(old);
    await Future<void>.delayed(Duration.zero);
    expect(store.latest, isNull);
    expect(events, [old, null]);
    store.record(usage(store.sessionEpoch));
    expect(store.latest, isNotNull);
  });

  test('late completion of older request cannot replace latest request', () {
    final store = ProviderGenerationUsageStore();
    addTearDown(store.dispose);
    final newer = usage(store.sessionEpoch, seconds: 2);
    store.record(newer);
    store.record(usage(store.sessionEpoch));
    expect(store.latest, same(newer));
  });

  test('invalid counts stay unknown rather than rounded or coerced', () {
    for (final value in <Object?>[null, -1, 1.5, double.nan, '100000']) {
      expect(ProviderGenerationUsage.parseTokenCount(value), isNull);
    }
    expect(ProviderGenerationUsage.parseTokenCount(100000), 100000);
    expect(ProviderGenerationUsage.parseTokenCount(0), 0);
  });
}
