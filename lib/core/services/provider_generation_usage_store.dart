import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/provider_generation_usage.dart';

/// Session-local usage observation. This is not a wallet or billing ledger.
class ProviderGenerationUsageStore {
  final _changes = StreamController<ProviderGenerationUsage?>.broadcast();
  ProviderGenerationUsage? _latest;
  var _sessionEpoch = 0;
  var _closed = false;

  ProviderGenerationUsage? get latest => _latest;
  int get sessionEpoch => _sessionEpoch;
  Stream<ProviderGenerationUsage?> get changes => _changes.stream;

  void record(ProviderGenerationUsage usage) {
    if (_closed || usage.sessionEpoch != _sessionEpoch) return;
    if (_latest != null && usage.requestedAt.isBefore(_latest!.requestedAt)) {
      return;
    }
    _latest = usage;
    _changes.add(usage);
  }

  /// Also invalidates observations belonging to an in-flight old session.
  void clear() {
    if (_closed) return;
    _sessionEpoch++;
    _latest = null;
    _changes.add(null);
  }

  void dispose() {
    _closed = true;
    _latest = null;
    unawaited(_changes.close());
  }
}

final providerGenerationUsageStoreProvider =
    Provider<ProviderGenerationUsageStore>((ref) {
      final store = ProviderGenerationUsageStore();
      ref.onDispose(store.dispose);
      return store;
    });
