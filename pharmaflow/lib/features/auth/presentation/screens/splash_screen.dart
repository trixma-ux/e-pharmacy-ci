import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final authAsync = ref.read(authControllerProvider);
    final user = authAsync.valueOrNull;

    if (user != null) {
      if (user.role == 'pharmacist') {
        context.go('/pharmacist_dashboard');
      } else {
        context.go('/main');
      }
      return;
    }

    // Attendre la fin du chargement auth si encore en cours
    if (authAsync.isLoading) {
      await ref.read(authControllerProvider.future);
      if (!mounted) return;
      final loadedUser = ref.read(authControllerProvider).valueOrNull;
      if (loadedUser != null) {
        context.go(loadedUser.role == 'pharmacist' ? '/pharmacist_dashboard' : '/main');
        return;
      }
    }

    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: const Icon(
                Icons.local_pharmacy_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            )
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .shimmer(delay: 800.ms, duration: 1200.ms),
            const SizedBox(height: 24),
            const Text(
              'PharmaFlow',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.5, end: 0, curve: Curves.easeOutQuad),
            const SizedBox(height: 8),
            Text(
              'Votre santé, sans attente.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
