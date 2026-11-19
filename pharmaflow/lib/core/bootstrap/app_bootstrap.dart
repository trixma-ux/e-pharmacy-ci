import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../firebase_options.dart';

/// Initialisation non bloquante de l'application.
///
/// Firebase (qui charge plusieurs SDK JavaScript sur le web) et les formats
/// de date sont initialisés en arrière-plan pour que Flutter puisse afficher
/// sa première image immédiatement. Le code qui dépend de Firebase attend
/// [ready] avant de l'utiliser.
class AppBootstrap {
  AppBootstrap._();

  static Future<void> _ready = Future<void>.value();

  /// Se termine quand Firebase et l'internationalisation sont prêts.
  static Future<void> get ready => _ready;

  static void start() {
    _ready = Future.wait<void>([
      _initFirebase(),
      initializeDateFormatting('fr_FR', null),
    ]);
  }

  static Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
  }
}
