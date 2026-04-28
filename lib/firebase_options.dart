// Generated-like Firebase options.
// TODO: Run `flutterfire configure` to generate platform-specific Android/iOS/macOS values.

import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform. '
          'Run flutterfire configure.',
        );
    }
  }

  // NOTE: Values below map to provided Firebase project configs (Web + Android + iOS).
  // Run `flutterfire configure` to complete macOS and any remaining platform-specific fields.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA0WKRADKnPd5NStDKAVLjXlR-wCHa8v20',
    appId: '1:220155676506:android:f154183365e59b0ae6d563',
    messagingSenderId: '220155676506',
    projectId: 'ari-mobile-bf746',
    storageBucket: 'ari-mobile-bf746.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD0-zoc2zn6zVcP9J-mv7su9-7JTj-7ESU',
    appId: '1:220155676506:ios:268ef50d08ad46f5e6d563',
    messagingSenderId: '220155676506',
    projectId: 'ari-mobile-bf746',
    storageBucket: 'ari-mobile-bf746.firebasestorage.app',
    iosBundleId: 'com.ari.mobile',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDp5jFMoyznxMUHHy3O9U7i1I4sTu7x2Fk',
    appId: '1:220155676506:web:d0f99f879fcc68d7e6d563',
    messagingSenderId: '220155676506',
    projectId: 'ari-mobile-bf746',
    authDomain: 'ari-mobile-bf746.firebaseapp.com',
    storageBucket: 'ari-mobile-bf746.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDp5jFMoyznxMUHHy3O9U7i1I4sTu7x2Fk',
    appId: '1:220155676506:web:d0f99f879fcc68d7e6d563',
    messagingSenderId: '220155676506',
    projectId: 'ari-mobile-bf746',
    storageBucket: 'ari-mobile-bf746.firebasestorage.app',
    iosBundleId: 'com.ari.mobile.macos',
  );
}
