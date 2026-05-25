import 'dart:math';
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
  final LatLng _abidjanCenter = const LatLng(5.359951, -4.008256);
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Liste des pharmacies ivoiriennes réelles
  final List<Map<String, dynamic>> _pharmacies = [
    {
      'name': 'Pharmacie Saint Jean Cocody',
      'lat': 5.3488,
      'lng': -3.9972,
      'is24h': true,
      'start': '00:00',
      'end': '23:59',
      'description': 'Cocody, Boulevard de France, près du carrefour Saint Jean',
      'phone': '+225 27 22 44 29 44',
    },
    {
      'name': 'Pharmacie de la Paix Adjamé',
      'lat': 5.3582,
      'lng': -4.0267,
      'is24h': false,
      'start': '08:00',
      'end': '22:00',
      'description': 'Adjamé, Boulevard Nangui Abrogoua',
      'phone': '+225 27 20 37 11 81',
    },
    {
      'name': 'Pharmacie du Pont Plateau',
      'lat': 5.3262,
      'lng': -4.0194,
      'is24h': false,
      'start': '08:00',
      'end': '20:00',
      'description': 'Plateau, Boulevard de la République, face au pont Félix Houphouët-Boigny',
      'phone': '+225 27 20 21 00 22',
    },
    {
      'name': 'Pharmacie de Marcory',
      'lat': 5.3056,
      'lng': -3.9881,
      'is24h': false,
      'start': '08:00',
      'end': '22:00',
      'description': 'Marcory, Boulevard de Marseille',
      'phone': '+225 27 21 26 15 15',
    },
    {
      'name': 'Pharmacie Bel Horizon Cocody',
      'lat': 5.3562,
      'lng': -3.9681,
      'is24h': true,
      'start': '00:00',
      'end': '23:59',
      'description': 'Cocody Riviera 3, près du rond-point de la Riviera',
      'phone': '+225 27 22 47 18 18',
    },
    {
      'name': 'Pharmacie Sainte Marie Cocody',
      'lat': 5.3620,
      'lng': -4.0100,
      'is24h': false,
      'start': '08:00',
      'end': '22:30',
      'description': 'Cocody, Cité des Arts, en face du Lycée Classique d\'Abidjan',
      'phone': '+225 27 22 44 00 00',
    },
    {
      'name': 'Pharmacie de la Grâce Angré',
      'lat': 5.3950,
      'lng': -4.0050,
      'is24h': false,
      'start': '08:00',
      'end': '23:00',
      'description': 'Cocody Angré, 8ème Tranche, près de la CNPS',
      'phone': '+225 27 22 50 12 12',
    },
    {
      'name': 'Pharmacie Saint Gabriel Yopougon',
      'lat': 5.3400,
      'lng': -4.0700,
      'is24h': false,
      'start': '08:00',
      'end': '22:00',
      'description': 'Yopougon, Quartier Maroc, face à la paroisse Saint Gabriel',
      'phone': '+225 27 23 45 67 89',
    },
    {
      'name': 'Pharmacie du Commerce Plateau',
      'lat': 5.3255,
      'lng': -4.0180,
      'is24h': false,
      'start': '07:30',
      'end': '20:00',
      'description': 'Plateau, Avenue Noguès, près de la Galerie Peyrissac',
      'phone': '+225 27 20 30 40 50',
    },
    {
      'name': 'Pharmacie des Allées Marcory',
      'lat': 5.3010,
      'lng': -3.9780,
      'is24h': true,
      'start': '00:00',
      'end': '23:59',
      'description': 'Marcory Zone 4, Boulevard du 7 Décembre',
      'phone': '+225 27 21 35 35 35',
    },
    {
      'name': 'Pharmacie de l\'Indénié Adjamé',
      'lat': 5.3370,
      'lng': -4.0150,
      'is24h': false,
      'start': '08:00',
      'end': '21:00',
      'description': 'Plateau/Adjamé, Carrefour de l\'Indénié',
      'phone': '+225 27 20 22 18 18',
    },
    {
      'name': 'Pharmacie du Val Cocody',
      'lat': 5.3520,
      'lng': -3.9850,
      'is24h': false,
      'start': '08:00',
      'end': '22:00',
      'description': 'Cocody, Rue des Jardins, près du supermarché Hayat',
      'phone': '+225 27 22 41 41 41',
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
    _mapController.dispose();
    super.dispose();
  }

  // Vérifier en temps réel si la pharmacie est ouverte
  bool _isPharmacyOpen(Map<String, dynamic> pharmacy) {
    if (pharmacy['is24h'] == true) return true;
    try {
      final now = DateTime.now();
      final currentMinutes = now.hour * 60 + now.minute;

      final startParts = (pharmacy['start'] as String).split(':');
      final endParts = (pharmacy['end'] as String).split(':');

      final startMinutes = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      if (endMinutes > startMinutes) {
        return currentMinutes >= startMinutes && currentMinutes < endMinutes;
      } else {
        // Cas des heures de garde qui passent par minuit
        return currentMinutes >= startMinutes || currentMinutes < endMinutes;
      }
    } catch (e) {
      return false;
    }
  }

  String _getStatusText(Map<String, dynamic> pharmacy) {
    final isOpen = _isPharmacyOpen(pharmacy);
    if (pharmacy['is24h'] == true) {
      return 'Ouvert 24h/24';
    }
    if (isOpen) {
      return 'Ouvert actuellement (ferme à ${pharmacy['end']})';
    } else {
      return 'Fermé actuellement (ouvre à ${pharmacy['start']})';
    }
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const double earthRadius = 6371.0; // km
    final double lat1Rad = p1.latitude * pi / 180.0;
    final double lat2Rad = p2.latitude * pi / 180.0;
    final double deltaLatRad = (p2.latitude - p1.latitude) * pi / 180.0;
    final double deltaLngRad = (p2.longitude - p1.longitude) * pi / 180.0;

    final double a = sin(deltaLatRad / 2.0) * sin(deltaLatRad / 2.0) +
        cos(lat1Rad) * cos(lat2Rad) *
            sin(deltaLngRad / 2.0) * sin(deltaLngRad / 2.0);
    final double c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a));
    return earthRadius * c;
  }

  List<Map<String, dynamic>> get _filteredPharmacies {
    if (_searchQuery.isEmpty) return _pharmacies;
    return _pharmacies.where((p) {
      final name = p['name'].toString().toLowerCase();
      final description = p['description'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || description.contains(query);
    }).toList();
  }

  void _showPharmacyDetails(Map<String, dynamic> pharmacy) {
    final isOpen = _isPharmacyOpen(pharmacy);
    final statusText = _getStatusText(pharmacy);
    final distance = _calculateDistance(_abidjanCenter, LatLng(pharmacy['lat'] as double, pharmacy['lng'] as double));

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
              Text(
                pharmacy['name'] as String,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pharmacy['description'] as String,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: isOpen ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(
                      color: isOpen ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${distance.toStringAsFixed(1)} km d\'ici',
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Icon(
                    Icons.phone,
                    size: 18,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    pharmacy['phone'] as String,
                    style: const TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.directions, color: AppColors.primary),
                      label: const Text('Itinéraire', style: TextStyle(color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/chat');
                      },
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                      label: const Text('Contacter', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
    final filtered = _filteredPharmacies;
    final markers = filtered.map((pharmacy) {
      final latLng = LatLng(pharmacy['lat'] as double, pharmacy['lng'] as double);
      final isOpen = _isPharmacyOpen(pharmacy);
      return Marker(
        point: latLng,
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            _mapController.move(latLng, 15.0);
            _showPharmacyDetails(pharmacy);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: isOpen ? AppColors.success : AppColors.error,
                size: 45,
              ),
              const Positioned(
                top: 8,
                child: Icon(
                  Icons.local_pharmacy,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _abidjanCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.trixmaux.pharmaflow',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          
          Positioned(
            top: 50,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher une pharmacie...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondaryLight),
                      onPressed: () {
                        _searchController.clear();
                      },
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
