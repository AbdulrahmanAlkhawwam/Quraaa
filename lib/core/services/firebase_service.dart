import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';
import '../utils/logger.dart';

/// Firebase initialization helper for the Quraaa app.
///
/// Keeps the entry point free of Firebase bootstrap logic and provides a single
/// place to handle initialization errors.
abstract final class FirebaseService {
  /// Initializes Firebase for the current platform if it is not already
  /// initialized.
  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('Firebase initialized successfully.');
    } catch (error, stackTrace) {
      AppLogger.error('Firebase initialization failed', error, stackTrace);
    }
  }
}
