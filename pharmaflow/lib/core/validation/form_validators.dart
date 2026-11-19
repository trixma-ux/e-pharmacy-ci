/// Validateurs de formulaires (messages en français).
class FormValidators {
  FormValidators._();

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Veuillez saisir votre adresse email.';
    if (!_emailRegex.hasMatch(v)) return 'Adresse email invalide.';
    return null;
  }

  static String? password(String? value, {bool isSignUp = false}) {
    final v = value ?? '';
    if (v.isEmpty) return 'Veuillez saisir votre mot de passe.';
    if (isSignUp && v.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    return null;
  }

  static String? requiredField(String? value, {String label = 'ce champ'}) {
    if ((value?.trim() ?? '').isEmpty) return 'Veuillez renseigner $label.';
    return null;
  }

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Veuillez saisir votre nom complet.';
    if (v.length < 2) return 'Nom trop court.';
    return null;
  }
}
