import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/role_redirect.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

/// Écran affiché à un pharmacien tant que son compte n'est pas validé
/// (status != 'approved'). N'écoute AUCUN flux de commandes : les règles
/// Firestore refusent ces lectures à un pharmacien en attente.
class PendingValidationScreen extends ConsumerStatefulWidget {
  const PendingValidationScreen({super.key});

  @override
  ConsumerState<PendingValidationScreen> createState() => _PendingValidationScreenState();
}

class _PendingValidationScreenState extends ConsumerState<PendingValidationScreen> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      final user = await ref.read(authControllerProvider.notifier).reloadCurrentUser();
      if (!mounted) return;
      if (user == null) {
        context.go(AppPaths.auth);
      } else if (!user.isPendingPharmacist) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Votre compte a été validé. Bienvenue !'),
          backgroundColor: AppColors.success,
        ));
        context.go(homePathFor(user));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Votre compte est toujours en attente de validation.'),
        ));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Impossible de vérifier votre compte. Réessayez plus tard.'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _logout() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (mounted) context.go(AppPaths.auth);
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(authControllerProvider).valueOrNull?.name ?? '';
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.hourglass_top_rounded, size: 56, color: AppColors.warning),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Compte en attente de validation',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${name.isNotEmpty ? 'Bonjour $name, v' : 'V'}otre compte pharmacien a bien été créé. '
                    'Il doit être validé par un pharmacien déjà validé ou par un administrateur '
                    'avant que vous puissiez accéder au tableau de bord et aux commandes.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, height: 1.4, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      key: const Key('pending_check_button'),
                      onPressed: _checking ? null : _check,
                      icon: _checking
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.refresh_rounded),
                      label: const Text('Vérifier à nouveau'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      key: const Key('pending_logout_button'),
                      onPressed: _logout,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Se déconnecter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
