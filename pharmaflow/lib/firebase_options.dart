// Fichier généré automatiquement par 'flutterfire configure'
// CECI EST UN FICHIER TEMPORAIRE POUR PERMETTRE LA COMPILATION.
// VEUILLEZ EXECUTER `flutterfire configure` DANS VOTRE TERMINAL POUR LE REMPLACER.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('DefaultFirebaseOptions have not been configured for web.');
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
    apiKey: 'AIzaSyBzDA8hvWeXSm8d68MSWGwtlhWIlDSycQo',
    appId: '1:256831019681:web:7022006904a72cad4deee0',
    messagingSenderId: '256831019681',
    projectId: 'pharmacyflow-bd0ef',
    authDomain: 'pharmacyflow-bd0ef.firebaseapp.com',
    storageBucket: 'pharmacyflow-bd0ef.firebasestorage.app',
    measurementId: 'G-Q8PZ8R5T4X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBzDA8hvWeXSm8d68MSWGwtlhWIlDSycQo',
    appId: '1:256831019681:android:7022006904a72cad4deee0', // Note: Android utilise généralement un appId spécifique mais celui-ci permettra une connexion basique
    messagingSenderId: '256831019681',
    projectId: 'pharmacyflow-bd0ef',
    storageBucket: 'pharmacyflow-bd0ef.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBzDA8hvWeXSm8d68MSWGwtlhWIlDSycQo',
    appId: '1:256831019681:ios:7022006904a72cad4deee0',
    messagingSenderId: '256831019681',
    projectId: 'pharmacyflow-bd0ef',
    storageBucket: 'pharmacyflow-bd0ef.firebasestorage.app',
    iosBundleId: 'com.trixmaux.pharmaflow',
  );
}
