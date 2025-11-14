// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not supported in this configuration');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS not supported');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCW8ul_nFvKe_wPKZExheMooWIWtvUOcR4',
    appId: '1:403308051319:android:1093e9bf8a041612d6ff72',
    messagingSenderId: '403308051319',
    projectId: 'thenexstore-1ebc5',
    storageBucket: 'thenexstore-1ebc5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCmACg3dNGCz36YZBQ4xXZFe62jxZW5cW4',
    appId: '1:1014653005389:ios:d5fc2c793d701695607604',
    messagingSenderId: '1014653005389',
    projectId: 'thenexstore-a2764',
    storageBucket: 'thenexstore-a2764.firebasestorage.app',
    iosBundleId: 'com.ecom.thenexstore',
  );
}