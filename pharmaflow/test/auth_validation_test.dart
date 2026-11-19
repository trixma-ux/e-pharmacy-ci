import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmaflow/core/errors/auth_error_messages.dart';
import 'package:pharmaflow/core/validation/form_validators.dart';

void main() {
  group('authErrorMessage', () {
    test('maps FirebaseAuthException codes to French', () {
      expect(authErrorMessage(FirebaseAuthException(code: 'invalid-credential')),
          'Email ou mot de passe incorrect.');
      expect(authErrorMessage(FirebaseAuthException(code: 'too-many-requests')),
          contains('Trop de tentatives'));
      expect(authErrorMessage(FirebaseAuthException(code: 'network-request-failed')),
          contains('Connexion réseau'));
    });

    test('maps wrapped exceptions containing [firebase_auth/<code>]', () {
      final e = Exception(
          'Erreur de connexion: [firebase_auth/user-not-found] There is no user record.');
      expect(authErrorMessage(e), "Aucun compte n'est associé à cet email.");
      expect(authErrorMessage(Exception('Firebase: Error (auth/invalid-email).')),
          "L'adresse email n'est pas valide.");
    });

    test('never shows raw Firebase text for unknown errors', () {
      final msg = authErrorMessage(Exception('[firebase_auth/unknown-xyz] boom'));
      expect(msg, isNot(contains('firebase')));
    });

    test('keeps short French business messages', () {
      expect(authErrorMessage(Exception('Données utilisateur introuvables.')),
          'Données utilisateur introuvables.');
    });
  });

  group('FormValidators', () {
    test('email', () {
      expect(FormValidators.email(''), isNotNull);
      expect(FormValidators.email('pas-un-email'), 'Adresse email invalide.');
      expect(FormValidators.email('a@b.ci'), isNull);
    });
    test('password', () {
      expect(FormValidators.password(''), isNotNull);
      expect(FormValidators.password('123', isSignUp: true), isNotNull);
      expect(FormValidators.password('123'), isNull);
    });
    test('name', () {
      expect(FormValidators.fullName('  '), isNotNull);
      expect(FormValidators.fullName('Awa Koné'), isNull);
    });
  });
}
