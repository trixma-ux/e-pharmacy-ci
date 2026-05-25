// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/cart_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _selectedPaymentMethod = 0;
  bool _isProcessing = false;
  String? _ordonnanceUrl;
  String? _ordonnanceFileName;

  void _pickOrdonnanceImage() {
    final uploadInput = html.FileUploadInputElement()
      ..accept = 'image/*'
      ..click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _ordonnanceUrl = reader.result as String?;
            _ordonnanceFileName = file.name;
          });
        });
      }
    });
  }

  void _processPayment() async {
    final cartNotifier = ref.read(cartProvider.notifier);
    if (cartNotifier.hasItemsRequiringPrescription && _ordonnanceUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez uploader votre ordonnance pour les médicaments sur prescription.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isProcessing = false);
      ref.read(cartProvider.notifier).clear();
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80)
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            const Text('Paiement Réussi !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Votre commande a été transmise à la pharmacie et est en attente de validation.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/main');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retour à l\'accueil', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartNotifier = ref.watch(cartProvider.notifier);
    final cartTotal = cartNotifier.grandTotal;
    final requiresOrdonnance = cartNotifier.hasItemsRequiringPrescription;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryLight),
          onPressed: () => context.pop(),
        ),
        title: const Text('Paiement', style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Méthode de paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentOption(
              index: 0,
              title: 'Wave Mobile Money',
              subtitle: 'Payer avec Wave',
              icon: Icons.waves,
              color: const Color(0xFF1CB5E0),
            ).animate().fadeIn(delay: 100.ms).slideX(),
            const SizedBox(height: 12),
            _buildPaymentOption(
              index: 1,
              title: 'Orange Money',
              subtitle: 'Payer avec Orange Money',
              icon: Icons.phone_android,
              color: const Color(0xFFFF7900),
            ).animate().fadeIn(delay: 200.ms).slideX(),
            const SizedBox(height: 12),
            _buildPaymentOption(
              index: 2,
              title: 'Paiement à la livraison',
              subtitle: 'Espèces à la réception',
              icon: Icons.money,
              color: Colors.green,
            ).animate().fadeIn(delay: 300.ms).slideX(),

            if (requiresOrdonnance) ...[
              const SizedBox(height: 32),
              const Text('Upload de l\'ordonnance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Un ou plusieurs médicaments nécessitent une ordonnance.',
                  style: TextStyle(color: AppColors.error, fontSize: 12)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickOrdonnanceImage,
                child: Container(
                  width: double.infinity,
                  height: _ordonnanceUrl != null ? 220 : 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _ordonnanceUrl != null ? AppColors.success : AppColors.primary.withValues(alpha: 0.5),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: _ordonnanceUrl != null
                        ? AppColors.success.withValues(alpha: 0.05)
                        : AppColors.primary.withValues(alpha: 0.05),
                  ),
                  child: _ordonnanceUrl != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                _ordonnanceUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit, size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    const Text('Changer', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle, size: 14, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      _ordonnanceFileName ?? 'Ordonnance',
                                      style: const TextStyle(color: Colors.white, fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                            const SizedBox(height: 8),
                            const Text('Cliquez pour sélectionner votre ordonnance',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.primaryDark, fontSize: 13)),
                            const SizedBox(height: 4),
                            const Text('Format : JPG, PNG',
                                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 11)),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isProcessing
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Confirmer le paiement (${cartNotifier.formatPrice(cartTotal)})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({required int index, required String title, required String subtitle, required IconData icon, required Color color}) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.borderLight,
            ),
          ],
        ),
      ),
    );
  }
}
