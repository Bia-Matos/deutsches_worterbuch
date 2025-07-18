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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDoEJFRj_dTRhup-27EoniQI0FtRNL-n9s',
    appId: '1:218594979462:web:3cae97bd8fe15bce192b07',
    messagingSenderId: '218594979462',
    projectId: 'deutsches-worterbuch',
    authDomain: 'deutsches-worterbuch.firebaseapp.com',
    storageBucket: 'deutsches-worterbuch.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTgTYjERnNfuCN0BNgIOHeJHlnh1R1sTk',
    appId: '1:218594979462:ios:43d34b532424bcd9192b07',
    messagingSenderId: '218594979462',
    projectId: 'deutsches-worterbuch',
    storageBucket: 'deutsches-worterbuch.firebasestorage.app',
    iosBundleId: 'com.wort',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCTgTYjERnNfuCN0BNgIOHeJHlnh1R1sTk',
    appId: '1:218594979462:ios:53fc2d76cf3d77df192b07',
    messagingSenderId: '218594979462',
    projectId: 'deutsches-worterbuch',
    storageBucket: 'deutsches-worterbuch.firebasestorage.app',
    iosBundleId: 'com.ds',
  );
}
