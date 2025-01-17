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
    apiKey: 'AIzaSyANcgU06aZ1ClQ77nZYbQPzaI6F-ZO5r7E',
    appId: '1:612543190638:web:c72dff49ad4f3fb1df387f',
    messagingSenderId: '612543190638',
    projectId: 'argos-app-30cfc',
    authDomain: 'argos-app-30cfc.firebaseapp.com',
    storageBucket: 'argos-app-30cfc.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyCymO2MA0np550rGEtLnZtauP3sn96YkmU",
      authDomain: "practihub-2428c.firebaseapp.com",
      databaseURL: "https://practihub-2428c-default-rtdb.firebaseio.com",
      projectId: "practihub-2428c",
      storageBucket: "practihub-2428c.appspot.com",
      messagingSenderId: "312406835627",
      appId: "1:312406835627:web:878c5937e9abbc27f012ee");

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDF8B9bu66kKESDopwSP7Tskwtj2HN1OMU',
    appId: '1:612543190638:ios:1377f8c4e394134bdf387f',
    messagingSenderId: '612543190638',
    projectId: 'argos-app-30cfc',
    storageBucket: 'argos-app-30cfc.appspot.com',
    iosBundleId: 'com.example.argosApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDF8B9bu66kKESDopwSP7Tskwtj2HN1OMU',
    appId: '1:612543190638:ios:1377f8c4e394134bdf387f',
    messagingSenderId: '612543190638',
    projectId: 'argos-app-30cfc',
    storageBucket: 'argos-app-30cfc.appspot.com',
    iosBundleId: 'com.example.argosApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyANcgU06aZ1ClQ77nZYbQPzaI6F-ZO5r7E',
    appId: '1:612543190638:web:efdab87e9134029ddf387f',
    messagingSenderId: '612543190638',
    projectId: 'argos-app-30cfc',
    authDomain: 'argos-app-30cfc.firebaseapp.com',
    storageBucket: 'argos-app-30cfc.appspot.com',
  );
}
