import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final List<String> _avatarPresets = [
    'https://api.dicebear.com/7.x/avataaars/png?seed=Sophia',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Jack',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Lily',
    'https://api.dicebear.com/7.x/avataaars/png?seed=Caleb',
    'https://api.dicebear.com/7.x/bottts/png?seed=Felix',
    'https://api.dicebear.com/7.x/bottts/png?seed=Aneka',
  ];

  void _showAvatarPicker(BuildContext context, String? currentPhoto) {
    final TextEditingController urlController = TextEditingController(text: currentPhoto);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choisir une photo de profil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Avatars prédéfinis',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _avatarPresets.length,
                  itemBuilder: (context, index) {
                    final avatarUrl = _avatarPresets[index];
                    return GestureDetector(
                      onTap: () {
                        ref.read(authControllerProvider.notifier).updateProfilePhoto(avatarUrl);
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: currentPhoto == avatarUrl ? AppColors.primary : Colors.transparent,
                            width: 3,
                          ),
                          color: AppColors.backgroundLight,
                        ),
                        child: ClipOval(
                          child: Image.network(avatarUrl),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ou entrez l\'URL d\'une image personnalisée',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: urlController,
                decoration: InputDecoration(
                  hintText: 'https://exemple.com/image.png',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final url = urlController.text.trim();
                    if (url.isNotEmpty) {
                      ref.read(authControllerProvider.notifier).updateProfilePhoto(url);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Enregistrer l\'URL', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Aucun utilisateur connecté.'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Profil avec gradient
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 60, bottom: 40, left: 24, right: 24),
                  child: Column(
                    children: [
                      // Photo de profil avec bouton Edit
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: ClipOval(
                              child: user.photoUrl != null && user.photoUrl!.isNotEmpty
                                  ? Image.network(
                                      user.photoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.person, size: 60, color: AppColors.primary),
                                    )
                                  : Container(
                                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                                      child: Center(
                                        child: Text(
                                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
                                          style: const TextStyle(
                                            fontSize: 48,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showAvatarPicker(context, user.photoUrl),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        user.role == 'pharmacist' ? 'Pharmacien' : 'Patient / Client',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Cartes d'informations
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        icon: Icons.person_outline,
                        title: 'Nom complet',
                        value: user.name,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.email_outlined,
                        title: 'Adresse de connexion',
                        value: user.email,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.security_outlined,
                        title: 'Email de récupération',
                        value: user.recoveryEmail,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        icon: Icons.work_outline,
                        title: 'Rôle',
                        value: user.role == 'pharmacist' ? 'Pharmacien' : 'Patient / Client',
                      ),
                      const SizedBox(height: 32),

                      // Bouton Déconnexion
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await ref.read(authControllerProvider.notifier).signOut();
                            if (context.mounted) {
                              context.go('/auth');
                            }
                          },
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: const Text('Se déconnecter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 100), // Marge pour la barre de navigation
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
