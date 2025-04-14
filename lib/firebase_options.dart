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
    apiKey: 'AIzaSyBiTR9dKEpge9FDGwedmGiXi_WL_HAB3fw',
    appId: '1:1023540559048:web:f2c329ba875718fe3df9fd',
    messagingSenderId: '1023540559048',
    projectId: 'chichrental-364ce',
    authDomain: 'chichrental-364ce.firebaseapp.com',
    storageBucket: 'chichrental-364ce.firebasestorage.app',
    measurementId: 'G-BSQ20F27NS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmu3DOemSA3Dxz0Us-vIvFJ0pKUTyst9I',
    appId: '1:1023540559048:android:56db9648dbe283f43df9fd',
    messagingSenderId: '1023540559048',
    projectId: 'chichrental-364ce',
    storageBucket: 'chichrental-364ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA0XK9USIJclwaSROo2Xs3ur95uylee5xQ',
    appId: '1:1023540559048:ios:1ac933344f0805483df9fd',
    messagingSenderId: '1023540559048',
    projectId: 'chichrental-364ce',
    storageBucket: 'chichrental-364ce.firebasestorage.app',
    iosBundleId: 'com.example.chichrental',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA0XK9USIJclwaSROo2Xs3ur95uylee5xQ',
    appId: '1:1023540559048:ios:1ac933344f0805483df9fd',
    messagingSenderId: '1023540559048',
    projectId: 'chichrental-364ce',
    storageBucket: 'chichrental-364ce.firebasestorage.app',
    iosBundleId: 'com.example.chichrental',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBiTR9dKEpge9FDGwedmGiXi_WL_HAB3fw',
    appId: '1:1023540559048:web:4a38aef39dd4cbb73df9fd',
    messagingSenderId: '1023540559048',
    projectId: 'chichrental-364ce',
    authDomain: 'chichrental-364ce.firebaseapp.com',
    storageBucket: 'chichrental-364ce.firebasestorage.app',
    measurementId: 'G-EKGQ9DDLXN',
  );
}
