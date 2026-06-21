
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
    apiKey: 'AIzaSyBQ_LaKU8yiQ89vO60M4aydEb9cgw2ARtI',
    appId: '1:504613830241:web:1867f367cf3080f34c7420',
    messagingSenderId: '504613830241',
    projectId: 'cash-control-4106f',
    authDomain: 'cash-control-4106f.firebaseapp.com',
    storageBucket: 'cash-control-4106f.firebasestorage.app',
    measurementId: 'G-D2BKYCW501',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA6NQMwndv6b_ApSuJdkuWXEkEVa2_4UWU',
    appId: '1:504613830241:android:295d3540ee3cb31a4c7420',
    messagingSenderId: '504613830241',
    projectId: 'cash-control-4106f',
    storageBucket: 'cash-control-4106f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBU_EyyvzDhSDfgItFtVk_uGy0o4fglEA8',
    appId: '1:504613830241:ios:69c16224111b1f904c7420',
    messagingSenderId: '504613830241',
    projectId: 'cash-control-4106f',
    storageBucket: 'cash-control-4106f.firebasestorage.app',
    iosClientId: '504613830241-14v5s68s6e0je6slm07kn7aa16n5clpu.apps.googleusercontent.com',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBU_EyyvzDhSDfgItFtVk_uGy0o4fglEA8',
    appId: '1:504613830241:ios:69c16224111b1f904c7420',
    messagingSenderId: '504613830241',
    projectId: 'cash-control-4106f',
    storageBucket: 'cash-control-4106f.firebasestorage.app',
    iosClientId: '504613830241-14v5s68s6e0je6slm07kn7aa16n5clpu.apps.googleusercontent.com',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBQ_LaKU8yiQ89vO60M4aydEb9cgw2ARtI',
    appId: '1:504613830241:web:38f1f3f7b36dfa4d4c7420',
    messagingSenderId: '504613830241',
    projectId: 'cash-control-4106f',
    authDomain: 'cash-control-4106f.firebaseapp.com',
    storageBucket: 'cash-control-4106f.firebasestorage.app',
    measurementId: 'G-P42L355K6L',
  );

}