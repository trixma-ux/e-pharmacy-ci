import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../pharmacist/data/order_repository.dart';
import '../../../pharmacist/domain/order_model.dart';

class MyOrdersScreen extends ConsumerWidget {
  const MyOrdersScreen({super.key});

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFE65100);
      case OrderStatus.validated:
        return const Color(0xFF2E7D32);
      case OrderStatus.rejected:
        return const Color(0xFFC62828);
      case OrderStatus.delivering:
        return const Color(0xFF1565C0);
      case OrderStatus.delivered:
        return const Color(0xFF6A1B9A);
      case OrderStatus.cancelled:
        return const Color(0xFF546E7A);
    }
  }

  IconData _statusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case OrderStatus.validated:
        return Icons.check_circle_rounded;
      case OrderStatus.rejected:
        return Icons.cancel_rounded;
      case OrderStatus.delivering:
        return Icons.local_shipping_rounded;
      case OrderStatus.delivered:
        return Icons.done_all_rounded;
      case OrderStatus.cancelled:
        return Icons.do_not_disturb_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes commandes')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Connectez-vous pour voir vos commandes.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    final ordersAsync = ref.watch(patientOrdersProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimaryLight),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Mes commandes',
          style: TextStyle(color: AppColors.textPrimaryLight, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 72, color: AppColors.primary.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune commande pour le moment',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vos commandes apparaîtront ici après validation.',
                    style: TextStyle(color: AppColors.textSecondaryLight.withValues(alpha: 0.9)),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/main'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('Commander', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ).animate().fadeIn();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _PatientOrderCard(
                order: order,
                index: index,
                currentUserId: user.id,
                statusColor: _statusColor(order.status),
                statusIcon: _statusIcon(order.status),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Erreur: $e', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}

class _PatientOrderCard extends ConsumerStatefulWidget {
  final OrderModel order;
  final int index;
  final String currentUserId;
  final Color statusColor;
  final IconData statusIcon;

  const _PatientOrderCard({
    required this.order,
    required this.index,
    required this.currentUserId,
    required this.statusColor,
    required this.statusIcon,
  });

  @override
  ConsumerState<_PatientOrderCard> createState() => _PatientOrderCardState();
}

class _PatientOrderCardState extends ConsumerState<_PatientOrderCard> {
  bool _cancelling = false;

  bool get _showCancel =>
      widget.order.canBeCancelled && widget.order.patientId == widget.currentUserId;

  Future<void> _confirmAndCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la commande ?'),
        content: const Text(
          'Cette action est définitive. Votre commande en attente sera annulée et ne pourra plus être traitée.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Retour'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFC62828)),
            child: const Text('Confirmer l\'annulation'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await ref.read(orderRepositoryProvider).cancelPatientOrder(widget.order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Commande annulée.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'annuler la commande. Veuillez réessayer.'),
          backgroundColor: Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final dateStr = DateFormat('dd MMM yyyy • HH:mm', 'fr_FR').format(order.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.statusIcon, color: widget.statusColor, size: 22),
            ),
            title: Text(
              order.formatPrice(order.grandTotal),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(order.statusLabel, style: TextStyle(color: widget.statusColor, fontWeight: FontWeight.w600)),
                Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
              ],
            ),
            children: [
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(child: Text('${item.name} (${item.form})')),
                        Text('x${item.quantity}'),
                        const SizedBox(width: 8),
                        Text(order.formatPrice(item.priceValue * item.quantity)),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Paiement'),
                  Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          if (_showCancel)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _cancelling ? null : _confirmAndCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(color: Color(0xFFC62828)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: _cancelling
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC62828)),
                        )
                      : const Text('Annuler la commande', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
        ],
      ),
    ),
    ).animate().fadeIn(delay: Duration(milliseconds: 60 * widget.index)).slideY(begin: 0.05);
  }
}
