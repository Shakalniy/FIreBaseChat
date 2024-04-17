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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCY8S20myOhB1S6WPKcquI69nFIySaoNs8',
    appId: '1:1053740152801:web:f857ebc18c055208c084a0',
    messagingSenderId: '1053740152801',
    projectId: 'chatapp-cb990',
    authDomain: 'chatapp-cb990.firebaseapp.com',
    storageBucket: 'chatapp-cb990.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6OzpPly1oGbvYqCQ2uM8ZjCa5WcE8JBk',
    appId: '1:1053740152801:android:3c3f2069a069c008c084a0',
    messagingSenderId: '1053740152801',
    projectId: 'chatapp-cb990',
    storageBucket: 'chatapp-cb990.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVehRqQ8-UfClShCNIXELZhdwfsv6_VAs',
    appId: '1:1053740152801:ios:eca00c0849271054c084a0',
    messagingSenderId: '1053740152801',
    projectId: 'chatapp-cb990',
    storageBucket: 'chatapp-cb990.appspot.com',
    iosBundleId: 'com.example.chat',
  );
}
