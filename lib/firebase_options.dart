// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyBOPAMHKkQDM9ND10pRHDVkAdH3usfsNwQ',
    appId: '1:576797195319:web:2cf2e564c99e01be1113b2',
    messagingSenderId: '576797195319',
    projectId: 'finalproject-c2238',
    authDomain: 'finalproject-c2238.firebaseapp.com',
    storageBucket: 'finalproject-c2238.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCPABoZNWae4tB0h4wFgfFDLHNTLy3jhwI',
    appId: '1:576797195319:android:0d0d7a48074bc3461113b2',
    messagingSenderId: '576797195319',
    projectId: 'finalproject-c2238',
    storageBucket: 'finalproject-c2238.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNFSDdbo9H6i3digzK0pidKsVZPoGkYgo',
    appId: '1:576797195319:ios:daceffa87c3305211113b2',
    messagingSenderId: '576797195319',
    projectId: 'finalproject-c2238',
    storageBucket: 'finalproject-c2238.appspot.com',
    iosBundleId: 'com.example.finalProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBNFSDdbo9H6i3digzK0pidKsVZPoGkYgo',
    appId: '1:576797195319:ios:1270634a62f3539c1113b2',
    messagingSenderId: '576797195319',
    projectId: 'finalproject-c2238',
    storageBucket: 'finalproject-c2238.appspot.com',
    iosBundleId: 'com.example.finalProject.RunnerTests',
  );
}
