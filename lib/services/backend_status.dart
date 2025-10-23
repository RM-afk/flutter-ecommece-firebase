import 'package:firebase_core/firebase_core.dart';

/// Central helper to determine if Firebase backend is available.
class BackendStatus {
  static bool get isFirebaseAvailable {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
