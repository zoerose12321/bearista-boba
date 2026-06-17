// TODO: Replace placeholder values with your Firebase project via:
// dart pub global activate flutterfire_cli
// flutterfire configure
//
// Web/Chrome is the primary QA target for online café sessions (v0.1.61+).

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'TODO_REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: '1:000000000000:web:bearista_boba_placeholder',
    messagingSenderId: '000000000000',
    projectId: 'bearista-boba-dev',
    authDomain: 'bearista-boba-dev.firebaseapp.com',
    storageBucket: 'bearista-boba-dev.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'TODO_REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: '1:000000000000:android:bearista_boba_placeholder',
    messagingSenderId: '000000000000',
    projectId: 'bearista-boba-dev',
    storageBucket: 'bearista-boba-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TODO_REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: '1:000000000000:ios:bearista_boba_placeholder',
    messagingSenderId: '000000000000',
    projectId: 'bearista-boba-dev',
    storageBucket: 'bearista-boba-dev.appspot.com',
    iosBundleId: 'com.example.bearistaBoba',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'TODO_REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: '1:000000000000:ios:bearista_boba_placeholder',
    messagingSenderId: '000000000000',
    projectId: 'bearista-boba-dev',
    storageBucket: 'bearista-boba-dev.appspot.com',
    iosBundleId: 'com.example.bearistaBoba',
  );
}
