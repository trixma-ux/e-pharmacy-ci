// Configuration Firebase du projet epharmacy-ci-steve-1d90d (compte gomonsteve01@gmail.com).
// Web : app « E-Pharmacy CI Web » enregistrée. Android/iOS : apps non encore enregistrées
// dans ce projet, lancer `flutterfire configure --project=epharmacy-ci-steve-1d90d` pour un build mobile.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for macos.');
      case TargetPlatform.windows:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for windows.');
      case TargetPlatform.linux:
        throw UnsupportedError('DefaultFirebaseOptions have not been configured for linux.');
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChRkpMPovAx0fGLtmHwwD14oZihUTOBpU',
    appId: '1:207478254280:web:0bba3a4e089a74fd3293fd',
    messagingSenderId: '207478254280',
    projectId: 'epharmacy-ci-steve-1d90d',
    authDomain: 'epharmacy-ci-steve-1d90d.firebaseapp.com',
    storageBucket: 'epharmacy-ci-steve-1d90d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyChRkpMPovAx0fGLtmHwwD14oZihUTOBpU',
    appId: '1:207478254280:android:7022006904a72cad4deee0', // Note: Android utilise généralement un appId spécifique mais celui-ci permettra une connexion basique
    messagingSenderId: '207478254280',
    projectId: 'epharmacy-ci-steve-1d90d',
    storageBucket: 'epharmacy-ci-steve-1d90d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChRkpMPovAx0fGLtmHwwD14oZihUTOBpU',
    appId: '1:207478254280:ios:7022006904a72cad4deee0',
    messagingSenderId: '207478254280',
    projectId: 'epharmacy-ci-steve-1d90d',
    storageBucket: 'epharmacy-ci-steve-1d90d.firebasestorage.app',
    iosBundleId: 'com.trixmaux.pharmaflow',
  );
}
