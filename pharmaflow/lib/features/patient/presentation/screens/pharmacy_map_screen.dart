import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class PharmacyMapScreen extends StatefulWidget {
  const PharmacyMapScreen({super.key});

  @override
  State<PharmacyMapScreen> createState() => _PharmacyMapScreenState();
}

class _PharmacyMapScreenState extends State<PharmacyMapScreen> {
  // Coordonnées pour Abidjan, Côte d'Ivoire
  final LatLng _abidjanCenter = const LatLng(5.359951, -4.008256);
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    // Créer de fausses pharmacies aux alentours
    _markers.add(
      Marker(
        point: const LatLng(5.362000, -4.010000),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _showPharmacyDetails('Pharmacie Sainte Marie', 'Ouvert 24/24', '1.2 km'),
          child: const Icon(Icons.local_pharmacy, color: AppColors.error, size: 40),
        ),
      ),
    );
    _markers.add(
      Marker(
        point: const LatLng(5.355000, -4.005000),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () => _showPharmacyDetails('Pharmacie de la Grâce', 'Ferme à 22h', '0.8 km'),
          child: const Icon(Icons.local_pharmacy, color: AppColors.primary, size: 40),
        ),
      ),
    );
  }

  void _showPharmacyDetails(String name, String status, String distance) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(status, style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 4),
                  Text(distance, style: const TextStyle(color: AppColors.textSecondaryLight)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.directions),
                      label: const Text('Itinéraire'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Fermer le bottom sheet
                        context.push('/chat'); // Aller au chat
                      },
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                      label: const Text('Contacter', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _abidjanCenter,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.trixmaux.pharmaflow',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          
          // Header / Barre de recherche sur la carte
          Positioned(
            top: 50,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.primary),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Rechercher une pharmacie...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
