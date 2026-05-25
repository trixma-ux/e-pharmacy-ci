import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../widgets/medicine_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Liste de 16 médicaments ivoiriens courants
  final List<Map<String, dynamic>> _medicines = [
    {
      'name': 'Doliprane 1000mg',
      'form': 'Comprimés',
      'price': '1 500 FCFA',
      'requiresPrescription': false,
    },
    {
      'name': 'Co-Artesiane',
      'form': 'Suspension buvable',
      'price': '3 200 FCFA',
      'requiresPrescription': true,
    },
    {
      'name': 'Amoxicilline 500mg',
      'form': 'Gélules',
      'price': '2 000 FCFA',
      'requiresPrescription': true,
    },
    {
      'name': 'Spasfon',
      'form': 'Comprimés',
      'price': '1 800 FCFA',
      'requiresPrescription': false,
    },
    {
      'name': 'Gaviscon',
      'form': 'Suspension buvable',
      'price': '2 500 FCFA',
      'requiresPrescription': false,
    },
    {
      'name': 'Ventoline 100µg',
      'form': 'Inhalateur',
      'price': '4 500 FCFA',
      'requiresPrescription': true,
    },
    {
      'name': 'Metformine 1000mg',
      'form': 'Comprimés',
      'price': '3 800 FCFA',
      'requiresPrescription': true,
    },
    {
      'name': 'Loratadine 10mg',
      'form': 'Comprimés',
      'price': '1 200 FCFA',
      'requiresPrescription': false,
    },
    {
      'name': 'Efferalgan 500mg',
      'form': 'Comprimés effervescents',
      'price': '1 400 FCFA',
      'requiresPrescription': false,
    },
    {
      'name': 'Augmentin 1g',
      'form': 'Poudre pour suspension',
      'price': '6 500 FCFA',
      'requiresPrescription': true,
    },
    {
      'name': 'Malarone',
      'form': 'Comprimés',
      'price': '8 900 FCFA',
      'requiresPrescription': true,
    },
    {
      'name': 'Voltarene 50mg',
      'form': 'Comprimés',
      'price': '2 800 FCFA',
      'requiresPrescription': true,
    },
    {
      'name': 'Imodium 2mg',
      'form': 'Gélules',
      'price': '1 500 FCFA',
      'requiresPrescription': false,
    },
    {
      'name': 'Smecta',
      'form': 'Sachets',
      'price': '2 200 FCFA',
      'requiresPrescription': false,
    },
    {
      'name': 'Vogalene 5mg',
      'form': 'Comprimés',
      'price': '1 900 FCFA',
      'requiresPrescription': true,
    },
    {
      'name': 'Nurofen 400mg',
      'form': 'Comprimés',
      'price': '2 100 FCFA',
      'requiresPrescription': false,
    },
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
                          const Text(
                            'Bonjour, 👋',
                            style: TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: AppColors.textPrimaryLight,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                            ),
                            child: ClipOval(
                              child: userPhoto != null && userPhoto.isNotEmpty
                                  ? Image.network(
                                      userPhoto,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.person, color: AppColors.primary),
                                    )
                                  : Container(
                                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                                      child: Center(
                                        child: Text(
                                          userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un médicament...',
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textSecondaryLight),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
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
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Icon(
                          Icons.local_pharmacy,
                          size: 150,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Scannez votre\nOrdonnance',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Rapide & Sécurisé',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Produits Populaires',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Tout voir', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),
              ),
            ),

            // Products Grid
            if (filtered.isEmpty)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Aucun médicament trouvé',
                      style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 16),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final med = filtered[index];
                      return MedicineCard(
                        name: med['name'] as String,
                        form: med['form'] as String,
                        price: med['price'] as String,
                        requiresPrescription: med['requiresPrescription'] as bool,
                      ).animate().fadeIn(delay: Duration(milliseconds: 100 + (index * 50))).slideY(begin: 0.1);
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 120)), // Espace supplémentaire pour la barre de navigation flottante
          ],
        ),
      ),
    );
  }
}
