import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../../../../core/theme/app_colors.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'pharmacy_map_screen.dart';
import 'profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const PharmacyMapScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Affichage de l'écran actif
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // Bottom Navigation Bar Flottante et Glassmorphism
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: GlassmorphicContainer(
              width: double.infinity,
              height: 70,
              borderRadius: 35,
              blur: 20,
              alignment: Alignment.bottomCenter,
              border: 1,
              linearGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.6),
                ],
              ),
              borderGradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.1),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(icon: Icons.home_rounded, label: 'Accueil', index: 0),
                  _buildNavItem(icon: Icons.shopping_bag_rounded, label: 'Panier', index: 1),
                  _buildNavItem(icon: Icons.map_rounded, label: 'Carte', index: 2),
                  _buildNavItem(icon: Icons.person_rounded, label: 'Profil', index: 3),
                ],
              ),
            ).animate().slideY(begin: 1, duration: 500.ms, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 200.ms).slideX(begin: -0.2),
            ]
          ],
        ),
      ),
    );
  }
}
