// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA7E9SpTu6abPN9woqldfzpHfwBFr-KcjI',
    appId: '1:691830640099:web:5719d8fbcd270c912724d6',
    messagingSenderId: '691830640099',
    projectId: 'notificaciones-century21',
    authDomain: 'notificaciones-century21.firebaseapp.com',
    storageBucket: 'notificaciones-century21.firebasestorage.app',
    measurementId: 'G-DL9WRLXJ6F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBU6xVwhyx4BtaGz_ZSAqiZHDh5dyw5TVc',
    appId: '1:691830640099:android:8dcccce7acc6f7f02724d6',
    messagingSenderId: '691830640099',
    projectId: 'notificaciones-century21',
    storageBucket: 'notificaciones-century21.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAsNdNwFy4IOdG487QPRjhxdw1yGhRkIfc',
    appId: '1:691830640099:ios:81470458d3b372db2724d6',
    messagingSenderId: '691830640099',
    projectId: 'notificaciones-century21',
    storageBucket: 'notificaciones-century21.firebasestorage.app',
    iosBundleId: 'com.example.flutterCrmApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAsNdNwFy4IOdG487QPRjhxdw1yGhRkIfc',
    appId: '1:691830640099:ios:81470458d3b372db2724d6',
    messagingSenderId: '691830640099',
    projectId: 'notificaciones-century21',
    storageBucket: 'notificaciones-century21.firebasestorage.app',
    iosBundleId: 'com.example.flutterCrmApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA7E9SpTu6abPN9woqldfzpHfwBFr-KcjI',
    appId: '1:691830640099:web:648ab4bf999738942724d6',
    messagingSenderId: '691830640099',
    projectId: 'notificaciones-century21',
    authDomain: 'notificaciones-century21.firebaseapp.com',
    storageBucket: 'notificaciones-century21.firebasestorage.app',
    measurementId: 'G-PYTH4Z5TMC',
  );
}
