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
    apiKey: 'AIzaSyAhxR3QKnQovL4N-P0H5siBtw4qXToE62o',
    appId: '1:95865025556:web:adab8e6bd60bcf2ad1e301',
    messagingSenderId: '95865025556',
    projectId: 'bearista-boba',
    authDomain: 'bearista-boba.firebaseapp.com',
    storageBucket: 'bearista-boba.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBrFHO4KDViaS33SAlihy1w5GvcHASyIEk',
    appId: '1:95865025556:android:faf7c5080375b18dd1e301',
    messagingSenderId: '95865025556',
    projectId: 'bearista-boba',
    storageBucket: 'bearista-boba.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCLjq6UgeSjc-jrJxckBZvcZS882X_1AuQ',
    appId: '1:95865025556:ios:b7a3e80cb439c1a0d1e301',
    messagingSenderId: '95865025556',
    projectId: 'bearista-boba',
    storageBucket: 'bearista-boba.firebasestorage.app',
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
