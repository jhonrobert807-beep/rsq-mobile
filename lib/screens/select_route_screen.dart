import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../models/location_model.dart';
import '../providers/ride_provider.dart';

class SelectRouteScreen extends StatefulWidget {
  const SelectRouteScreen({super.key});

  @override
  State<SelectRouteScreen> createState() => _SelectRouteScreenState();
}

class _SelectRouteScreenState extends State<SelectRouteScreen> {
  static const Color softPinkBg = Color(0xFFFFF5F5);

  late TextEditingController _searchController;
  double _pickupLat = 24.8607;
  double _pickupLng = 67.0011;
  String _pickupLabel = 'Getting location...';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _getLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _pickupLabel = 'Karachi, Pakistan (default)');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _pickupLabel = 'Karachi, Pakistan (default)');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _pickupLabel = 'Karachi, Pakistan (default)');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _pickupLat = position.latitude;
        _pickupLng = position.longitude;
        _pickupLabel = 'Current Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      });

      // Set pickup location in provider
      if (mounted) {
        final rideProvider = context.read<RideProvider>();
        rideProvider.setPickup(LocationModel(
          id: 'current',
          name: 'Current Location',
          address: _pickupLabel,
          latitude: _pickupLat,
          longitude: _pickupLng,
          type: 'current_location',
        ));
      }
    } catch (_) {
      setState(() => _pickupLabel = 'Karachi, Pakistan (default)');
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<RideProvider>().destinationSuggestions.clear();
      return;
    }

    // Debounced search (300ms)
    Future.delayed(const Duration(milliseconds: 300), () async {
      if (mounted && _searchController.text == query) {
        await context.read<RideProvider>().searchDestinations(query);
      }
    });
  }

  void _selectDestination(LocationModel location) {
    context.read<RideProvider>().setDestination(location);
    _searchController.clear();

    // Navigate to vehicle selection
    Navigator.pushNamed(
      context,
      AppRoutes.selectVehicle,
      arguments: {
        'pickupLat': _pickupLat,
        'pickupLng': _pickupLng,
        'pickupLabel': _pickupLabel,
        'destinationLat': location.latitude,
        'destinationLng': location.longitude,
        'destinationName': location.name,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark, statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Enter your route', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.black, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Current location
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: softPinkBg, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 6, backgroundColor: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _pickupLabel,
                          style: TextStyle(fontSize: 15, color: Colors.black.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Search field
                Consumer<RideProvider>(
                  builder: (context, rideProvider, _) {
                    return Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red.shade400),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 6, backgroundColor: Colors.red.shade400),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Search destination',
                                    hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onChanged: _onSearchChanged,
                                ),
                              ),
                              if (rideProvider.isLoading)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.red.shade400)),
                                )
                              else if (_searchController.text.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                  icon: const Icon(Icons.clear, color: Colors.black54),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(maxWidth: 24, maxHeight: 24),
                                ),
                            ],
                          ),
                        ),

                        // Dropdown suggestions
                        if (rideProvider.destinationSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: rideProvider.destinationSuggestions.length,
                              separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1, indent: 12, endIndent: 12),
                              itemBuilder: (context, index) {
                                final location = rideProvider.destinationSuggestions[index];
                                return InkWell(
                                  onTap: () => _selectDestination(location),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          location.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          location.address,
                                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (location.distance != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              '${location.distance!.toStringAsFixed(1)} km away',
                                              style: TextStyle(color: Colors.blue.shade600, fontSize: 11),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        if (_searchController.text.isNotEmpty && rideProvider.destinationSuggestions.isEmpty && !rideProvider.isLoading)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Text(
                                'No locations found',
                                style: TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                InkWell(
                  onTap: _getLocation,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Use current location', style: TextStyle(fontSize: 15, color: Colors.blue, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text('Quick destinations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                const SizedBox(height: 12),

                ...List.generate(3, (index) {
                  final destinations = [
                    ('Plot B-5', 'Shifa International Hospital', 24.8126, 67.0354),
                    ('Plot C-9', 'Aga Khan Hospital', 24.8084, 67.0295),
                    ('Block 7', 'Civil Hospital', 24.8089, 67.0215),
                  ];

                  final dest = destinations[index];

                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          _selectDestination(
                            LocationModel(
                              id: 'quick-$index',
                              name: dest.$2,
                              address: dest.$1,
                              latitude: dest.$3,
                              longitude: dest.$4,
                              type: 'hospital',
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: Row(
                            children: [
                              Icon(Icons.history, color: Colors.red.shade400, size: 20),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(dest.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(dest.$2, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (index < 2) Divider(color: Colors.grey.shade200, height: 1),
                    ],
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
