import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart';

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
    apiKey: 'AIzaSyD1qMSEB5RIkgni8lnKm1NcxmMnp0Vahb8',
    appId: '1:831069810194:android:56ff1a0717cf1f5cac32cb',
    messagingSenderId: '831069810194',
    projectId: 'task-ai-69bdc',
    storageBucket: 'task-ai-69bdc.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDI5LteqomfYr-n4wzQofe6gpl3KCSqPts',
    appId: '1:831069810194:ios:217c392a39aa8e2cac32cb',
    messagingSenderId: '831069810194',
    projectId: 'task-ai-69bdc',
    storageBucket: 'task-ai-69bdc.firebasestorage.app',
    iosClientId:
        '831069810194-9iavo3v320fahtaf755s51tujt70g5i8.apps.googleusercontent.com',
    iosBundleId: 'com.example.taskAi',
  );
}
