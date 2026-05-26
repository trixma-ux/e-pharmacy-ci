// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/cart_provider.dart';
import '../../../pharmacist/data/order_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

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

  final List<Map<String, String>> _paymentMethods = [
    {'title': 'Wave Mobile Money', 'subtitle': 'Payer avec Wave', 'key': 'Wave'},
    {'title': 'Orange Money', 'subtitle': 'Payer avec Orange Money', 'key': 'Orange Money'},
    {'title': 'Paiement à la livraison', 'subtitle': 'Espèces à la réception', 'key': 'Espèces'},
  ];

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

  Future<void> _processPayment() async {
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartItems = ref.read(cartProvider);

    if (cartNotifier.hasItemsRequiringPrescription && _ordonnanceUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez uploader votre ordonnance avant de confirmer.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Connectez-vous pour passer commande.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
      context.go('/auth');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final authState = ref.read(authControllerProvider).value;
      final patientName = authState?.name ?? 'Patient';

      final orderRepo = ref.read(orderRepositoryProvider);
      await orderRepo.createOrder({
        'patientId': user.uid,
        'patientName': patientName,
        'items': cartItems.map((item) => {
          'name': item.name,
          'form': item.form,
          'quantity': item.quantity,
          'priceValue': item.priceValue,
          'requiresPrescription': item.requiresPrescription,
        }).toList(),
        'totalValue': cartNotifier.totalValue,
        'deliveryFee': cartNotifier.deliveryFee,
        'paymentMethod': _paymentMethods[_selectedPaymentMethod]['key'],
        'status': 'pending',
        'ordonnanceUrl': _ordonnanceUrl,
        'createdAt': Timestamp.now(),
        'updatedAt': null,
      });

      cartNotifier.clear();
      if (mounted) {
        setState(() => _isProcessing = false);
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 90)
                  .animate()
                  .scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 20),
              const Text('Commande envoyée !',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text(
                'Votre commande a été transmise à la pharmacie. Le pharmacien la validera sous peu.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondaryLight, height: 1.5),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/my_orders');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Voir mes commandes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartNotifier = ref.watch(cartProvider.notifier);
    final requiresOrdonnance = cartNotifier.hasItemsRequiringPrescription;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimaryLight),
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
            const Text('Méthode de paiement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(_paymentMethods.length, (i) {
              final icons = [Icons.waves, Icons.phone_android, Icons.money];
              final colors = [const Color(0xFF1CB5E0), const Color(0xFFFF7900), Colors.green];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildPaymentOption(
                  index: i,
                  title: _paymentMethods[i]['title']!,
                  subtitle: _paymentMethods[i]['subtitle']!,
                  icon: icons[i],
                  color: colors[i],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: 100 * (i + 1))).slideX();
            }),

            if (requiresOrdonnance) ...[
              const SizedBox(height: 28),
              const Text('Upload de l\'ordonnance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text(
                '⚠️ Un ou plusieurs médicaments nécessitent une ordonnance.',
                style: TextStyle(color: AppColors.error, fontSize: 13),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _pickOrdonnanceImage,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: _ordonnanceUrl != null ? 220 : 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _ordonnanceUrl != null
                          ? const Color(0xFF2D9D5D)
                          : AppColors.primary.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    color: _ordonnanceUrl != null
                        ? const Color(0xFF2D9D5D).withValues(alpha: 0.05)
                        : AppColors.primary.withValues(alpha: 0.04),
                  ),
                  child: _ordonnanceUrl != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(_ordonnanceUrl!, fit: BoxFit.cover,
                                  width: double.infinity, height: double.infinity),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text('Changer', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10, left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D9D5D).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
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

            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.4),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 22, width: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        'Confirmer la commande (${cartNotifier.formatPrice(cartNotifier.grandTotal)})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({required int index, required String title, required String subtitle, required IconData icon, required Color color}) {
    final isSelected = _selectedPaymentMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
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
