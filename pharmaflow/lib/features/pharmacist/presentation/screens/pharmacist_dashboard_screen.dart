import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/order_repository.dart';
import '../../domain/order_model.dart';

class PharmacistDashboardScreen extends ConsumerStatefulWidget {
  const PharmacistDashboardScreen({super.key});

  @override
  ConsumerState<PharmacistDashboardScreen> createState() => _PharmacistDashboardScreenState();
}

class _PharmacistDashboardScreenState extends ConsumerState<PharmacistDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Status filter helpers ─────────────────────────────────────────────
  List<OrderModel> _filterOrders(List<OrderModel> orders, String status) {
    if (status == 'all') return orders;
    return orders.where((o) => o.status.name == status).toList();
  }

  // ─── Status badge ──────────────────────────────────────────────────────
  Widget _statusBadge(OrderStatus status) {
    Color bg, fg;
    IconData icon;
    switch (status) {
      case OrderStatus.pending:
        bg = const Color(0xFFFFF3E0); fg = const Color(0xFFE65100); icon = Icons.hourglass_top_rounded;
        break;
      case OrderStatus.validated:
        bg = const Color(0xFFE8F5E9); fg = const Color(0xFF2E7D32); icon = Icons.check_circle_rounded;
        break;
      case OrderStatus.rejected:
        bg = const Color(0xFFFFEBEE); fg = const Color(0xFFC62828); icon = Icons.cancel_rounded;
        break;
      case OrderStatus.delivering:
        bg = const Color(0xFFE3F2FD); fg = const Color(0xFF1565C0); icon = Icons.local_shipping_rounded;
        break;
      case OrderStatus.delivered:
        bg = const Color(0xFFF3E5F5); fg = const Color(0xFF6A1B9A); icon = Icons.done_all_rounded;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(status.name == 'pending' ? 'En attente' :
               status.name == 'validated' ? 'Validée' :
               status.name == 'rejected' ? 'Rejetée' :
               status.name == 'delivering' ? 'En livraison' : 'Livrée',
              style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ─── Update status ─────────────────────────────────────────────────────
  Future<void> _updateStatus(String orderId, OrderStatus newStatus) async {
    final repo = ref.read(orderRepositoryProvider);
    await repo.updateOrderStatus(orderId, newStatus);
    if (mounted) {
      final label = newStatus == OrderStatus.validated ? 'Commande validée ✅' :
                    newStatus == OrderStatus.rejected ? 'Commande rejetée ❌' :
                    newStatus == OrderStatus.delivering ? 'Mise en livraison 🚚' :
                    'Commande livrée 🎉';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(label),
        backgroundColor: newStatus == OrderStatus.validated ? AppColors.success :
                         newStatus == OrderStatus.rejected ? AppColors.error : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  // ─── Order detail bottom sheet ─────────────────────────────────────────
  void _showOrderDetail(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrderDetailSheet(order: order, onUpdateStatus: _updateStatus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final allOrdersAsync = ref.watch(allOrdersProvider);
    final statsAsync = ref.watch(orderStatsProvider);

    final userName = authState.when(
      data: (u) => u?.name ?? 'Pharmacien',
      loading: () => '...',
      error: (_, __) => 'Pharmacien',
    );
    final userPhoto = authState.when(
      data: (u) => u?.photoUrl,
      loading: () => null,
      error: (_, __) => null,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── Custom Premium App Bar ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, Color(0xFF005A8E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Avatar + Name
                            Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                                  ),
                                  child: ClipOval(
                                    child: userPhoto != null && userPhoto.isNotEmpty
                                        ? Image.network(userPhoto, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _defaultAvatar(userName))
                                        : _defaultAvatar(userName),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Bonjour,', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                                    Text(userName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                                    onPressed: () async {
                                      await ref.read(authControllerProvider.notifier).signOut();
                                      if (context.mounted) context.go('/auth');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Tableau de bord', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Gérez vos commandes en temps réel', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
              collapseMode: CollapseMode.parallax,
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.5),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              tabs: const [
                Tab(text: 'Aperçu'),
                Tab(text: 'Toutes'),
                Tab(text: 'En attente'),
                Tab(text: 'Historique'),
              ],
            ),
          ),
        ],

        body: TabBarView(
          controller: _tabController,
          children: [
            // ── TAB 1: Aperçu / Overview ─────────────────────────────────
            _buildOverviewTab(statsAsync, allOrdersAsync),

            // ── TAB 2: Toutes les commandes ──────────────────────────────
            _buildOrdersTab(allOrdersAsync, 'all'),

            // ── TAB 3: En attente ────────────────────────────────────────
            _buildOrdersTab(allOrdersAsync, 'pending'),

            // ── TAB 4: Historique ────────────────────────────────────────
            _buildOrdersTab(allOrdersAsync, 'delivered'),
          ],
        ),
      ),
    );
  }

  Widget _defaultAvatar(String name) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.3),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'P',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
        ),
      ),
    );
  }

  // ── Overview Tab ─────────────────────────────────────────────────────────
  Widget _buildOverviewTab(AsyncValue<Map<String, int>> statsAsync, AsyncValue<List<OrderModel>> ordersAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          statsAsync.when(
            data: (stats) => _buildStatsGrid(stats),
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
            error: (e, _) => Text('Erreur: $e'),
          ),
          const SizedBox(height: 28),

          // Commandes récentes
          const Text('Commandes récentes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          ordersAsync.when(
            data: (orders) {
              final recent = orders.take(5).toList();
              if (recent.isEmpty) {
                return _emptyState('Aucune commande pour l\'instant', 'Les commandes des patients apparaîtront ici');
              }
              return Column(
                children: recent.asMap().entries.map((e) => _buildOrderCard(e.value, e.key)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Erreur: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, int> stats) {
    final statItems = [
      {'label': 'Total commandes', 'value': stats['total'] ?? 0, 'icon': Icons.shopping_bag_rounded, 'color': AppColors.primary},
      {'label': 'En attente', 'value': stats['pending'] ?? 0, 'icon': Icons.hourglass_top_rounded, 'color': const Color(0xFFE65100)},
      {'label': 'Validées', 'value': stats['validated'] ?? 0, 'icon': Icons.check_circle_rounded, 'color': const Color(0xFF2E7D32)},
      {'label': 'En livraison', 'value': stats['delivering'] ?? 0, 'icon': Icons.local_shipping_rounded, 'color': const Color(0xFF1565C0)},
      {'label': 'Livrées', 'value': stats['delivered'] ?? 0, 'icon': Icons.done_all_rounded, 'color': const Color(0xFF6A1B9A)},
      {'label': 'Rejetées', 'value': stats['rejected'] ?? 0, 'icon': Icons.cancel_rounded, 'color': AppColors.error},
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.0,
      children: statItems.asMap().entries.map((entry) {
        final s = entry.value;
        final color = s['color'] as Color;
        final icon = s['icon'] as IconData;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text('${s['value']}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(s['label'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
            ],
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 80 * entry.key)).scale(begin: const Offset(0.9, 0.9));
      }).toList(),
    );
  }

  // ── Orders Tab ───────────────────────────────────────────────────────────
  Widget _buildOrdersTab(AsyncValue<List<OrderModel>> ordersAsync, String filter) {
    return ordersAsync.when(
      data: (orders) {
        final filtered = _filterOrders(orders, filter);
        if (filtered.isEmpty) {
          return _emptyState(
            filter == 'pending' ? 'Aucune commande en attente' : 'Aucune commande',
            filter == 'pending'
                ? 'Toutes les commandes ont été traitées 🎉'
                : 'Les commandes apparaîtront ici quand les patients commanderont',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filtered.length,
          itemBuilder: (ctx, i) => _buildOrderCard(filtered[i], i),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erreur: $e')),
    );
  }

  // ── Order Card ────────────────────────────────────────────────────────────
  Widget _buildOrderCard(OrderModel order, int index) {
    final orderNum = order.id.substring(0, 6).toUpperCase();
    final timeAgo = _timeAgo(order.createdAt);

    return GestureDetector(
      onTap: () => _showOrderDetail(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('#$orderNum',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(width: 8),
                            if (order.hasPrescriptionItems)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('📋 Ordonnance', style: TextStyle(fontSize: 9, color: AppColors.warning, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        Text('$timeAgo • ${order.patientName}',
                            style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                      ],
                    ),
                  ),
                  _statusBadge(order.status),
                ],
              ),
            ),

            // Divider + items
            const Divider(height: 1, indent: 18, endIndent: 18),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.items.map((i) => '${i.name} ×${i.quantity}').take(2).join(', ') +
                              (order.items.length > 2 ? ' +${order.items.length - 2}' : ''),
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    order.formatPrice(order.grandTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                  ),
                ],
              ),
            ),

            // Actions (only for pending)
            if (order.status == OrderStatus.pending) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _updateStatus(order.id, OrderStatus.rejected),
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Rejeter'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateStatus(order.id, OrderStatus.validated),
                        icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                        label: const Text('Valider', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (order.status == OrderStatus.validated) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(order.id, OrderStatus.delivering),
                    icon: const Icon(Icons.local_shipping_rounded, size: 16, color: Colors.white),
                    label: const Text('Mettre en livraison', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ] else if (order.status == OrderStatus.delivering) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(order.id, OrderStatus.delivered),
                    icon: const Icon(Icons.done_all_rounded, size: 16, color: Colors.white),
                    label: const Text('Marquer comme livrée', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A1B9A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 60 * index)).slideY(begin: 0.08),
    );
  }

  Widget _emptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 80, color: AppColors.primaryLight.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondaryLight)),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

// ─── Order Detail Bottom Sheet ───────────────────────────────────────────────
class _OrderDetailSheet extends ConsumerWidget {
  final OrderModel order;
  final Future<void> Function(String id, OrderStatus status) onUpdateStatus;

  const _OrderDetailSheet({required this.order, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderNum = order.id.substring(0, 6).toUpperCase();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2))),
            ),
            // Title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Commande #$orderNum', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(order.patientName, style: const TextStyle(color: AppColors.textSecondaryLight)),
                  ],
                ),
                _statusBadgeLocal(order.status),
              ],
            ),
            const SizedBox(height: 20),

            // Items
            const Text('Articles commandés', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            ...order.items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: item.requiresPrescription
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.medication_rounded,
                        color: item.requiresPrescription ? AppColors.warning : AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(item.form, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('×${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(order.formatPrice(item.priceValue * item.quantity),
                          style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            )),

            const SizedBox(height: 16),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.05), AppColors.primaryDark.withValues(alpha: 0.05)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Sous-total', style: TextStyle(color: AppColors.textSecondaryLight)),
                    Text(order.formatPrice(order.totalValue), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 6),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Livraison', style: TextStyle(color: AppColors.textSecondaryLight)),
                    Text(order.formatPrice(order.deliveryFee), style: const TextStyle(fontWeight: FontWeight.w600)),
                  ]),
                  const Divider(height: 18),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(order.formatPrice(order.grandTotal),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                  ]),
                ],
              ),
            ),

            // Ordonnance photo
            if (order.ordonnanceUrl != null) ...[
              const SizedBox(height: 20),
              const Text('Ordonnance', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  order.ordonnanceUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: AppColors.backgroundLight,
                    child: const Center(child: Text('Image non disponible', style: TextStyle(color: AppColors.textSecondaryLight))),
                  ),
                ),
              ),
            ],

            // Paiement
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.payment, size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: 8),
              Text('Paiement: ${order.paymentMethod}',
                  style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 13)),
            ]),

            const SizedBox(height: 24),

            // Action buttons in sheet
            if (order.status == OrderStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await onUpdateStatus(order.id, OrderStatus.rejected);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Rejeter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await onUpdateStatus(order.id, OrderStatus.validated);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('Valider ✅', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _statusBadgeLocal(OrderStatus status) {
    Color bg, fg;
    switch (status) {
      case OrderStatus.pending: bg = const Color(0xFFFFF3E0); fg = const Color(0xFFE65100); break;
      case OrderStatus.validated: bg = const Color(0xFFE8F5E9); fg = const Color(0xFF2E7D32); break;
      case OrderStatus.rejected: bg = const Color(0xFFFFEBEE); fg = const Color(0xFFC62828); break;
      case OrderStatus.delivering: bg = const Color(0xFFE3F2FD); fg = const Color(0xFF1565C0); break;
      case OrderStatus.delivered: bg = const Color(0xFFF3E5F5); fg = const Color(0xFF6A1B9A); break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.name == 'pending' ? 'En attente' :
                  status.name == 'validated' ? 'Validée' :
                  status.name == 'rejected' ? 'Rejetée' :
                  status.name == 'delivering' ? 'En livraison' : 'Livrée',
          style: TextStyle(color: fg, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}
