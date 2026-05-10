import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class SelectRouteScreen extends StatefulWidget {
  const SelectRouteScreen({super.key});

  @override
  State<SelectRouteScreen> createState() => _SelectRouteScreenState();
}

class _SelectRouteScreenState extends State<SelectRouteScreen> {
  static const Color softPinkBg = Color(0xFFFFF5F5);

  double _pickupLat = 24.8607;
  double _pickupLng = 67.0011;
  String _pickupLabel = 'Getting location...';

  @override
  void initState() {
    super.initState();
    _getLocation();
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
    } catch (_) {
      setState(() => _pickupLabel = 'Karachi, Pakistan (default)');
    }
  }

  void _goToVehicleSelect() {
    Navigator.pushNamed(
      context,
      AppRoutes.selectVehicle,
      arguments: {'pickupLat': _pickupLat, 'pickupLng': _pickupLng, 'pickupLabel': _pickupLabel},
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

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

              Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 6, backgroundColor: Colors.red),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'To',
                          hintStyle: TextStyle(fontSize: 15, color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
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

              Expanded(
                child: ListView.separated(
                  itemCount: 3,
                  separatorBuilder: (context, index) => Divider(color: Colors.grey.shade200, height: 1),
                  itemBuilder: (context, index) {
                    final destinations = [
                      ('Plot B-5', 'Shifa International Hospital, Karachi'),
                      ('Plot C-9', 'Aga Khan Hospital, Karachi'),
                      ('Block 7', 'Civil Hospital, Karachi'),
                    ];
                    return InkWell(
                      onTap: _goToVehicleSelect,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            Icon(Icons.history, color: Colors.red.shade400, size: 20),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(destinations[index].$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(destinations[index].$2, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
