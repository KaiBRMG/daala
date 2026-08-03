// File generated for the Daala Firebase project (daala-69a44).
//
// The Android values below are transcribed from `android/app/google-services.json`.
// iOS has no `GoogleService-Info.plist` in the repo yet, so the iOS branch throws
// with instructions rather than shipping fabricated keys.
//
// To (re)generate this file properly for every platform — and to have the iOS
// plist written for you — run:
//
//     dart pub global activate flutterfire_cli
//     flutterfire configure --project=daala-69a44
//
// That command overwrites this file; that is expected and fine.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Per-platform [FirebaseOptions] for the Daala app.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Daala does not ship a web target. Run `flutterfire configure` if that '
        'changes.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'Daala targets Android and iOS only (got $defaultTargetPlatform).',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRm5PaC-GN8ZC3cm4ad7ZUT7_ibhnWFJY',
    appId: '1:824314646136:android:882d2a17d0faed70f4e78d',
    messagingSenderId: '824314646136',
    projectId: 'daala-69a44',
    storageBucket: 'daala-69a44.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCnLkuPrnK3m4e6hDcRwJHb_8vQ4EQtx0',
    appId: '1:824314646136:ios:08cc4003c91110e8f4e78d',
    messagingSenderId: '824314646136',
    projectId: 'daala-69a44',
    storageBucket: 'daala-69a44.firebasestorage.app',
    iosBundleId: 'za.co.daala.daala',
  );
}
