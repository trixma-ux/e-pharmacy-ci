import '../../features/auth/domain/models/user_model.dart';

/// Chemins utilisés par la redirection selon le rôle / statut.
class AppPaths {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const main = '/main';
  static const pharmacistDashboard = '/pharmacist_dashboard';
  static const pendingValidation = '/pending_validation';

  static const publicPaths = {splash, onboarding, auth};
}

/// Écran d'accueil d'un utilisateur connecté :
/// - pharmacien non validé (status != 'approved') => écran d'attente ;
/// - pharmacien validé ou admin => tableau de bord ;
/// - patient => accueil patient.
String homePathFor(UserModel user) {
  if (user.isPendingPharmacist) return AppPaths.pendingValidation;
  if (user.isStaff) return AppPaths.pharmacistDashboard;
  return AppPaths.main;
}

/// Logique de redirection de GoRouter (testable sans widget).
String? redirectFor(UserModel? user, String path) {
  if (path == AppPaths.splash) return null;

  if (user == null) {
    return AppPaths.publicPaths.contains(path) ? null : AppPaths.auth;
  }

  // Les pages publiques restent accessibles (l'écran de connexion redirige
  // lui-même après authentification).
  if (AppPaths.publicPaths.contains(path)) return null;

  final home = homePathFor(user);
  if (user.isPendingPharmacist) {
    return path == AppPaths.pendingValidation ? null : home;
  }
  if (user.isStaff) {
    return path == AppPaths.pharmacistDashboard ? null : home;
  }
  // Patient : ni tableau de bord pharmacien ni écran d'attente.
  if (path == AppPaths.pharmacistDashboard || path == AppPaths.pendingValidation) {
    return home;
  }
  return null;
}
