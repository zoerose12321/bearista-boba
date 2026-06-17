import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Initializes Firebase once at app startup (v0.1.61+).
class FirebaseBootstrap {
  static bool isReady = false;
  static String? initError;

  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) {
      isReady = true;
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isReady = true;
      initError = null;
    } catch (error, stackTrace) {
      isReady = false;
      initError = error.toString();
      debugPrint('Firebase init failed: $error');
      debugPrint('$stackTrace');
    }
  }
}
