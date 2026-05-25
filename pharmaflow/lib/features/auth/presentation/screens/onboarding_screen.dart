import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Trouvez vos médicaments",
      "subtitle": "Recherchez parmi des milliers de produits de santé et trouvez exactement ce qu'il vous faut en quelques clics.",
      "icon": "search"
    },
    {
      "title": "Commandez en ligne",
      "subtitle": "Scannez votre ordonnance ou ajoutez vos produits au panier. Validation pharmaceutique garantie.",
      "icon": "receipt_long"
    },
    {
      "title": "Suivi en temps réel",
      "subtitle": "Soyez informé de l'état de votre commande à chaque étape, de la préparation au retrait.",
      "icon": "local_shipping"
    }
  ];

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'search':
        return Icons.search_rounded;
      case 'receipt_long':
        return Icons.receipt_long_rounded;
      case 'local_shipping':
        return Icons.local_shipping_rounded;
      default:
        return Icons.health_and_safety_rounded;
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to Login/Signup
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Passer', style: TextStyle(color: AppColors.textSecondaryLight)),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _currentPage = value;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  final data = _onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration mock
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconData(data["icon"]!),
                            size: 100,
                            color: AppColors.primary,
                          ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                        ),
                        const SizedBox(height: 64),
                        Text(
                          data["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        Text(
                          data["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: AppColors.textSecondaryLight,
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Indicators & Button
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index ? AppColors.primary : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next / Start Button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: Icon(
                      _currentPage == _onboardingData.length - 1 
                          ? Icons.check 
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ).animate().scale(delay: 600.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
