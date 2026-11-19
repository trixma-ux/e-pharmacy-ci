import 'package:firebase_auth/firebase_auth.dart';

/// Messages français pour les codes d'erreur Firebase Authentication.
const Map<String, String> _authMessages = {
  'invalid-credential': 'Email ou mot de passe incorrect.',
  'invalid-login-credentials': 'Email ou mot de passe incorrect.',
  'wrong-password': 'Email ou mot de passe incorrect.',
  'user-not-found': 'Aucun compte n\'est associé à cet email.',
  'invalid-email': 'L\'adresse email n\'est pas valide.',
  'missing-email': 'Veuillez saisir votre adresse email.',
  'missing-password': 'Veuillez saisir votre mot de passe.',
  'user-disabled': 'Ce compte a été désactivé. Contactez le support.',
  'too-many-requests':
      'Trop de tentatives. Veuillez patienter quelques minutes avant de réessayer.',
  'network-request-failed':
      'Connexion réseau impossible. Vérifiez votre connexion Internet.',
  'email-already-in-use': 'Un compte existe déjà avec cet email.',
  'weak-password': 'Mot de passe trop faible (6 caractères minimum).',
  'operation-not-allowed':
      'Ce mode de connexion n\'est pas activé. Contactez le support.',
  'requires-recent-login':
      'Pour des raisons de sécurité, veuillez vous reconnecter.',
  'expired-action-code': 'Ce lien a expiré. Veuillez recommencer.',
  'invalid-action-code': 'Ce lien n\'est plus valide.',
  'internal-error': 'Erreur interne du service. Réessayez plus tard.',
  'popup-closed-by-user': 'La fenêtre de connexion a été fermée.',
};

const String _defaultMessage =
    'Une erreur est survenue. Veuillez réessayer.';

/// Extrait le code Firebase d'une erreur, qu'il s'agisse d'une
/// [FirebaseAuthException] ou d'une exception enveloppée dont le texte
/// contient « [firebase_auth/<code>] » ou « auth/<code> ».
String? authErrorCode(Object error) {
  if (error is FirebaseAuthException) return error.code;
  final text = error.toString();
  final match = RegExp(r'(?:firebase_auth/|auth/)([a-z0-9-]+)').firstMatch(text);
  if (match != null) return match.group(1);
  for (final code in _authMessages.keys) {
    if (text.contains(code)) return code;
  }
  return null;
}

/// Convertit n'importe quelle erreur d'authentification en message
/// français lisible par l'utilisateur (jamais l'exception brute).
String authErrorMessage(Object error) {
  final code = authErrorCode(error);
  if (code != null && _authMessages.containsKey(code)) {
    return _authMessages[code]!;
  }
  // Messages métier déjà en français levés par l'application.
  final text = error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
  if (!text.contains('firebase') && !text.contains('[') && text.length < 120) {
    return text;
  }
  return _defaultMessage;
}
