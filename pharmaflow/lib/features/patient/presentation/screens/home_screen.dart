import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/cart_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 30 médicaments ivoiriens courants en pharmacie
  final List<Map<String, dynamic>> _medicines = [
    {'name': 'Doliprane 1000mg', 'form': 'Comprimés (boîte de 16)', 'price': '1 500 FCFA', 'requiresPrescription': false},
    {'name': 'Co-Artesiane 80/480mg', 'form': 'Comprimés antipaludéens', 'price': '3 200 FCFA', 'requiresPrescription': true},
    {'name': 'Amoxicilline 500mg', 'form': 'Gélules (boîte de 16)', 'price': '2 000 FCFA', 'requiresPrescription': true},
    {'name': 'Spasfon', 'form': 'Comprimés antispasmodiques', 'price': '1 800 FCFA', 'requiresPrescription': false},
    {'name': 'Gaviscon', 'form': 'Suspension buvable (sachets)', 'price': '2 500 FCFA', 'requiresPrescription': false},
    {'name': 'Ventoline 100µg', 'form': 'Inhalateur (aérosol)', 'price': '4 500 FCFA', 'requiresPrescription': true},
    {'name': 'Metformine 1000mg', 'form': 'Comprimés diabète (30 cp)', 'price': '3 800 FCFA', 'requiresPrescription': true},
    {'name': 'Loratadine 10mg', 'form': 'Comprimés antiallergiques', 'price': '1 200 FCFA', 'requiresPrescription': false},
    {'name': 'Efferalgan 500mg', 'form': 'Comprimés effervescents', 'price': '1 400 FCFA', 'requiresPrescription': false},
    {'name': 'Augmentin 1g', 'form': 'Comprimés antibiotiques', 'price': '6 500 FCFA', 'requiresPrescription': true},
    {'name': 'Malarone', 'form': 'Comprimés antipaludéens', 'price': '8 900 FCFA', 'requiresPrescription': true},
    {'name': 'Voltarène 50mg', 'form': 'Comprimés anti-inflammatoires', 'price': '2 800 FCFA', 'requiresPrescription': true},
    {'name': 'Imodium 2mg', 'form': 'Gélules antidiarrhéiques', 'price': '1 500 FCFA', 'requiresPrescription': false},
    {'name': 'Smecta 3g', 'form': 'Poudre pour suspension (sachets)', 'price': '2 200 FCFA', 'requiresPrescription': false},
    {'name': 'Vogalène 5mg', 'form': 'Comprimés antiémétiques', 'price': '1 900 FCFA', 'requiresPrescription': true},
    {'name': 'Nurofen 400mg', 'form': 'Comprimés (boîte de 12)', 'price': '2 100 FCFA', 'requiresPrescription': false},
    {'name': 'Azithromycine 500mg', 'form': 'Comprimés antibiotiques (3 cp)', 'price': '5 000 FCFA', 'requiresPrescription': true},
    {'name': 'Ciprofloxacine 500mg', 'form': 'Comprimés antibiotiques (10 cp)', 'price': '4 200 FCFA', 'requiresPrescription': true},
    {'name': 'Oméprazole 20mg', 'form': 'Gélules anti-acide (14 cp)', 'price': '3 000 FCFA', 'requiresPrescription': false},
    {'name': 'Cotrimoxazole 480mg', 'form': 'Comprimés antibiotiques', 'price': '1 800 FCFA', 'requiresPrescription': true},
    {'name': 'Prednisolone 5mg', 'form': 'Comprimés corticoïdes', 'price': '2 500 FCFA', 'requiresPrescription': true},
    {'name': 'Ibuprofène 400mg', 'form': 'Comprimés anti-douleur', 'price': '1 600 FCFA', 'requiresPrescription': false},
    {'name': 'Paracétamol 500mg', 'form': 'Comprimés (boîte de 16)', 'price': '900 FCFA', 'requiresPrescription': false},
    {'name': 'Érythromycine 500mg', 'form': 'Comprimés antibiotiques (16 cp)', 'price': '3 500 FCFA', 'requiresPrescription': true},
    {'name': 'Métronidazole 500mg', 'form': 'Comprimés (boîte de 14)', 'price': '1 500 FCFA', 'requiresPrescription': true},
    {'name': 'Diclofénac 100mg', 'form': 'Suppositoires anti-inflammatoires', 'price': '2 200 FCFA', 'requiresPrescription': true},
    {'name': 'Quinine 300mg', 'form': 'Comprimés antipaludéens (30 cp)', 'price': '2 800 FCFA', 'requiresPrescription': true},
    {'name': 'Acide Folique 5mg', 'form': 'Comprimés vitaminés (30 cp)', 'price': '1 000 FCFA', 'requiresPrescription': false},
    {'name': 'Fer Fumarate 350mg', 'form': 'Comprimés pour l\'anémie', 'price': '1 200 FCFA', 'requiresPrescription': false},
    {'name': 'Atorvastatine 10mg', 'form': 'Comprimés cholestérol (30 cp)', 'price': '7 500 FCFA', 'requiresPrescription': true},
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredMedicines {
    if (_searchQuery.isEmpty) return _medicines;
    return _medicines.where((med) {
      final name = med['name'].toString().toLowerCase();
      final form = med['form'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || form.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredMedicines;
    final authState = ref.watch(authControllerProvider);
    final cartItems = ref.watch(cartProvider);

    final userName = authState.when(
      data: (user) => user?.name ?? 'Patient',
      loading: () => '...',
      error: (_, __) => 'Patient',
    );

    final userPhoto = authState.when(
      data: (user) => user?.photoUrl,
      loading: () => null,
      error: (_, __) => null,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar Custom
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Bonjour, 👋', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14)),
                          Text(
                            userName,
                            style: const TextStyle(color: AppColors.textPrimaryLight, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                                  onPressed: () {},
                                ),
                              ),
                              if (cartItems.isNotEmpty)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                                    child: Text(cartItems.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                            ),
                            child: ClipOval(
                              child: userPhoto != null && userPhoto.isNotEmpty
                                  ? Image.network(userPhoto, fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, st) => const Icon(Icons.person, color: AppColors.primary))
                                  : Container(
                                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                                      child: Center(
                                        child: Text(
                                          userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un médicament...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textSecondaryLight),
                              onPressed: () => _searchController.clear())
                          : Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.tune_rounded, color: AppColors.primary),
                            ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
              ),
            ),

            // Promotional Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20, bottom: -20,
                        child: Icon(Icons.local_pharmacy, size: 140, color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Scannez votre\nOrdonnance',
                                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: const Text('Rapide & Sécurisé',
                                  style: TextStyle(color: AppColors.primaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),
              ),
            ),

            // Categories Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _searchQuery.isEmpty
                          ? 'Médicaments disponibles (${_medicines.length})'
                          : 'Résultats (${filtered.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Tout voir', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              ),
            ),

            // Products List
            if (filtered.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('Aucun médicament trouvé', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 16)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final med = filtered[index];
                      return _buildMedicineRow(med, index);
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineRow(Map<String, dynamic> med, int index) {
    final cartNotifier = ref.read(cartProvider.notifier);
    final cartItems = ref.watch(cartProvider);
    final inCart = cartItems.any((item) => item.name == med['name']);
    final cartQty = inCart ? cartItems.firstWhere((item) => item.name == med['name']).quantity : 0;
    final requiresPrescription = med['requiresPrescription'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: inCart ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: requiresPrescription
                  ? AppColors.warning.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.medication_rounded,
              color: requiresPrescription ? AppColors.warning : AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (requiresPrescription)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Ordonnance requise',
                        style: TextStyle(fontSize: 9, color: AppColors.warning, fontWeight: FontWeight.bold)),
                  ),
                Text(
                  med['name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimaryLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(med['form'] as String,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(med['price'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Cart controls
          if (inCart)
            Row(
              children: [
                _qtyButton(Icons.remove, () => cartNotifier.removeItem(med['name'] as String)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('$cartQty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _qtyButton(Icons.add, () => cartNotifier.addItem(
                  name: med['name'] as String,
                  form: med['form'] as String,
                  price: med['price'] as String,
                  requiresPrescription: requiresPrescription,
                )),
              ],
            )
          else
            GestureDetector(
              onTap: () {
                cartNotifier.addItem(
                  name: med['name'] as String,
                  form: med['form'] as String,
                  price: med['price'] as String,
                  requiresPrescription: requiresPrescription,
                );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${med['name']} ajouté au panier'),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ));
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.05);
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}
