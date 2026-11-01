import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'nai_api_endpoint.dart';

/// Holds the API endpoint used by the currently authenticated account.
class NaiApiEndpointService extends ChangeNotifier {
  NaiApiEndpointConfig _current = NaiApiEndpointConfig.official;

  NaiApiEndpointConfig get current => _current;

  void setCurrent(NaiApiEndpointConfig endpoint) {
    if (_current == endpoint) return;
    _current = endpoint;
    notifyListeners();
  }

  void resetToOfficial() => setCurrent(NaiApiEndpointConfig.official);

  String mainUrl(String endpoint) => _current.mainUrl(endpoint);

  String imageUrl(String endpoint) => _current.imageUrl(endpoint);

  String userUrl(String endpoint) => _current.userUrl(endpoint);
}

final naiApiEndpointServiceProvider = Provider<NaiApiEndpointService>((ref) {
  final service = NaiApiEndpointService();
  ref.onDispose(service.dispose);
  return service;
});

/// Observe profile changes even when the account mutates the service in place.
final naiApiEndpointConfigProvider = Provider<NaiApiEndpointConfig>((ref) {
  final service = ref.watch(naiApiEndpointServiceProvider);
  void changed() => ref.invalidateSelf();
  service.addListener(changed);
  ref.onDispose(() => service.removeListener(changed));
  return service.current;
});
