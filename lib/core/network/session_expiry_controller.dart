import 'package:flutter/foundation.dart';

/// Bridges session-expiry events from the network layer to the app router.
class SessionExpiryController extends ChangeNotifier {
  bool _hasPendingExpiry = false;

  void notifySessionExpired() {
    if (_hasPendingExpiry) {
      return;
    }
    _hasPendingExpiry = true;
    notifyListeners();
  }

  bool consumeSessionExpired() {
    if (!_hasPendingExpiry) {
      return false;
    }
    _hasPendingExpiry = false;
    return true;
  }
}
