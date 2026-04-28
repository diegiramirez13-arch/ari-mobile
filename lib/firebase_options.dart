// Este archivo es generado por FlutterFire CLI
// Ejecutar: flutterfire configure
// Más info: https://firebase.flutter.dev/docs/cli

import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    if (Platform.isAndroid) {
      return android;
    }

    if (Platform.isIOS) {
      return ios;
    }

    throw UnsupportedError('Plataforma no soportada para FirebaseOptions.');
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REEMPLAZAR_CON_TU_API_KEY',
    appId: 'REEMPLAZAR_CON_TU_APP_ID',
    messagingSenderId: 'REEMPLAZAR_CON_TU_MESSAGING_SENDER_ID',
    projectId: 'REEMPLAZAR_CON_TU_PROJECT_ID',
    databaseURL: 'REEMPLAZAR_CON_TU_DATABASE_URL',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REEMPLAZAR_CON_TU_API_KEY',
    appId: 'REEMPLAZAR_CON_TU_APP_ID',
    messagingSenderId: 'REEMPLAZAR_CON_TU_MESSAGING_SENDER_ID',
    projectId: 'REEMPLAZAR_CON_TU_PROJECT_ID',
    databaseURL: 'REEMPLAZAR_CON_TU_DATABASE_URL',
    iosBundleId: 'REEMPLAZAR_CON_TU_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REEMPLAZAR_CON_TU_API_KEY',
    appId: 'REEMPLAZAR_CON_TU_APP_ID',
    messagingSenderId: 'REEMPLAZAR_CON_TU_MESSAGING_SENDER_ID',
    projectId: 'REEMPLAZAR_CON_TU_PROJECT_ID',
    authDomain: 'REEMPLAZAR_CON_TU_AUTH_DOMAIN',
    databaseURL: 'REEMPLAZAR_CON_TU_DATABASE_URL',
    storageBucket: 'REEMPLAZAR_CON_TU_STORAGE_BUCKET',
  );

  // SETUP INSTRUCTIONS:
  // 1. Go to https://console.firebase.google.com
  // 2. Create your Firebase project
  // 3. Add Android, iOS, and Web apps
  // 4. Download google-services.json and GoogleService-Info.plist
  // 5. Run: flutterfire configure
  // 6. This file will be auto-updated with your credentials
}
