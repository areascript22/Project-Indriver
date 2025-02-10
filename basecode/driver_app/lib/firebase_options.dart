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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAMJYuaPz5cRQYk6O9EqB-8RBGcKG9gzQ',
    appId: '1:1029433641745:android:2018d73263a9baaeeedab0',
    messagingSenderId: '1029433641745',
    projectId: 'taxi-riobamba',
    databaseURL: 'https://taxi-riobamba-default-rtdb.firebaseio.com',
    storageBucket: 'taxi-riobamba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4Fs9VCwQbAbVXqw2U1d6OGAvKCp5yaEc',
    appId: '1:1029433641745:ios:f0f44f2fe7440ba0eedab0',
    messagingSenderId: '1029433641745',
    projectId: 'taxi-riobamba',
    databaseURL: 'https://taxi-riobamba-default-rtdb.firebaseio.com',
    storageBucket: 'taxi-riobamba.firebasestorage.app',
    iosBundleId: 'com.example.driverApp',
  );
}
