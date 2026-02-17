// Este archivo es generado por FlutterFire CLI
// Ejecutar: flutterfire configure
// Más info: https://firebase.flutter.dev/docs/cli

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return web;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'ari-mobile',
    databaseURL: 'https://ari-mobile.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'ari-mobile',
    databaseURL: 'https://ari-mobile.firebaseio.com',
    iosBundleId: 'com.ari.mobile',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'ari-mobile',
    authDomain: 'ari-mobile.firebaseapp.com',
    databaseURL: 'https://ari-mobile.firebaseio.com',
    storageBucket: 'ari-mobile.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'ari-mobile',
    databaseURL: 'https://ari-mobile.firebaseio.com',
    iosBundleId: 'com.ari.mobile.macos',
  );

  // SETUP INSTRUCTIONS:
  // 1. Go to https://console.firebase.google.com
  // 2. Create project "ari-mobile"
  // 3. Add Android, iOS, Web apps
  // 4. Download google-services.json and GoogleService-Info.plist
  // 5. Run: flutterfire configure
  // 6. This file will be auto-updated with your credentials
}
