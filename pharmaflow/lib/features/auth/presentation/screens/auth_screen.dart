import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../controllers/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isLogin = true;
  String selectedRole = 'patient';
  
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Mot de passe oublié'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Saisissez votre email de récupération (celui utilisé à l\'inscription).',
              style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Email de récupération',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isEmpty) return;
              try {
                await ref.read(authControllerProvider.notifier).resetPassword(email);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email de réinitialisation envoyé.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Envoyer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) return;

    if (isLogin) {
      await ref.read(authControllerProvider.notifier).signIn(email, password);
    } else {
      final name = _nameController.text.trim();
      if (name.isEmpty) return;
      await ref.read(authControllerProvider.notifier).signUp(
        email: email, 
        password: password, 
        name: name, 
        role: selectedRole,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    
    // Ecoute des erreurs pour afficher un SnackBar
    ref.listen(authControllerProvider, (previous, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
        );
      } else if (next is AsyncData && next.value != null) {
        // Redirection en fonction du rôle
        if (next.value!.role == 'pharmacist') {
          context.go('/pharmacist_dashboard');
        } else {
          context.go('/main');
        }
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // Background design
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withValues(alpha: 0.5),
              ),
            ).animate().fadeIn(duration: 1.seconds).scale(),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ).animate().fadeIn(duration: 1.seconds).scale(),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GlassmorphicContainer(
                  width: double.infinity,
                  height: isLogin ? 480 : 660,
                  borderRadius: 24,
                  blur: 20,
                  alignment: Alignment.bottomCenter,
                  border: 1.5,
                  linearGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    stops: const [0.1, 1],
                  ),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title
                        Text(
                          isLogin ? 'Bon retour !' : 'Créer un compte',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ).animate().fadeIn().slideY(begin: -0.2),
                        const SizedBox(height: 8),
                        Text(
                          isLogin 
                              ? 'Connectez-vous pour accéder à votre espace santé.' 
                              : 'Rejoignez PharmaFlow et simplifiez votre santé.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondaryLight,
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                        
                        const SizedBox(height: 32),
                        
                        if (!isLogin) ...[
                          CustomTextField(
                            hintText: 'Nom complet',
                            prefixIcon: Icons.person_outline_rounded,
                            controller: _nameController,
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                          const SizedBox(height: 16),
                          
                          // Sélection du rôle
                          const Text(
                            'Je suis un :',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRoleCard(
                                  title: 'Patient / Client',
                                  icon: Icons.person_outline_rounded,
                                  isSelected: selectedRole == 'patient',
                                  onTap: () => setState(() => selectedRole = 'patient'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildRoleCard(
                                  title: 'Pharmacien',
                                  icon: Icons.local_pharmacy_outlined,
                                  isSelected: selectedRole == 'pharmacist',
                                  onTap: () => setState(() => selectedRole = 'pharmacist'),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 250.ms),
                          const SizedBox(height: 16),
                        ],
                        
                        CustomTextField(
                          hintText: 'Adresse Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                        const SizedBox(height: 16),
                        
                        CustomTextField(
                          hintText: 'Mot de passe',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          controller: _passwordController,
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),
                        
                        if (isLogin) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => _showForgotPasswordDialog(context),
                              child: const Text('Mot de passe oublié ?', style: TextStyle(color: AppColors.primary)),
                            ),
                          ).animate().fadeIn(delay: 500.ms),
                        ] else const SizedBox(height: 24),
                        
                        authState.isLoading 
                        ? const Center(child: CircularProgressIndicator()) 
                        : PrimaryButton(
                            text: isLogin ? 'Se connecter' : 'S\'inscrire',
                            onPressed: _submit,
                          ).animate().fadeIn(delay: 600.ms).scale(),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLogin ? 'Pas encore de compte ?' : 'Déjà un compte ?',
                              style: const TextStyle(color: AppColors.textSecondaryLight),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: Text(
                                isLogin ? 'S\'inscrire' : 'Se connecter',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 700.ms),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
