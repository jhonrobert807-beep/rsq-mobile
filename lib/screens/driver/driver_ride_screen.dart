import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import '../../providers/ride_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/ride_api.dart';

class DriverRideScreen extends StatefulWidget {
  const DriverRideScreen({super.key});

  @override
  State<DriverRideScreen> createState() => _DriverRideScreenState();
}

class _DriverRideScreenState extends State<DriverRideScreen> {
  bool _isEnding = false;
  bool _isStarting = false;
  Timer? _pollTimer;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshRide());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectChatBackground();
      _fetchRoute();
    });
  }

  void _connectChatBackground() {
    final ride = context.read<RideProvider>().activeRide;
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (ride != null && userId != null) {
      context.read<ChatProvider>().connectBackground(ride.id, userId);
    }
  }

  Future<void> _fetchRoute() async {
    final ride = context.read<RideProvider>().activeRide;
    if (ride == null) return;
    if (ride.destinationLat == null || ride.destinationLng == null) return;

    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${ride.pickupLng},${ride.pickupLat};'
          '${ride.destinationLng},${ride.destinationLat}'
          '?geometries=geojson&overview=full';

      final response = await Dio().get(url);
      final coords = response.data['routes'][0]['geometry']['coordinates'] as List;
      final points = coords.map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble())).toList();
      if (mounted) setState(() => _routePoints = points);
    } catch (_) {
      final ride = context.read<RideProvider>().activeRide;
      if (ride != null && ride.destinationLat != null && mounted) {
        setState(() => _routePoints = [
          LatLng(ride.pickupLat, ride.pickupLng),
          LatLng(ride.destinationLat!, ride.destinationLng!),
        ]);
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshRide() async {
    if (!mounted) return;
    final ride = context.read<RideProvider>().activeRide;
    if (ride == null) return;
    try {
      final updated = await RideApi.getRide(ride.id);
      if (mounted) context.read<RideProvider>().setActiveRide(updated);
    } catch (_) {}
  }

  Future<void> _startRide() async {
    final ride = context.read<RideProvider>().activeRide;
    if (ride == null) return;
    setState(() => _isStarting = true);
    try {
      await RideApi.updateStatus(ride.id, 'IN_TRIP');
      if (mounted) {
        final updated = await RideApi.getRide(ride.id);
        context.read<RideProvider>().setActiveRide(updated);
        setState(() => _isStarting = false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to start ride. Try again.'), backgroundColor: Colors.red),
        );
        setState(() => _isStarting = false);
      }
    }
  }

  Future<void> _endRide() async {
    final ride = context.read<RideProvider>().activeRide;
    if (ride == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Ride'),
        content: const Text('Are you sure you want to end this ride?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End Ride', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isEnding = true);
    try {
      await RideApi.updateStatus(ride.id, 'COMPLETED');
      if (mounted) {
        context.read<RideProvider>().clearActiveRide();
        Navigator.pushReplacementNamed(context, AppRoutes.driverHomeScreen);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to end ride. Try again.'), backgroundColor: Colors.red),
        );
        setState(() => _isEnding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent),
    );

    final ride = context.watch<RideProvider>().activeRide;
    final pickupLabel = ride != null
        ? '${ride.pickupLat.toStringAsFixed(4)}, ${ride.pickupLng.toStringAsFixed(4)}'
        : 'Unknown';
    final destinationLabel = (ride?.destinationLat != null && ride?.destinationLng != null)
        ? '${ride!.destinationLat!.toStringAsFixed(4)}, ${ride.destinationLng!.toStringAsFixed(4)}'
        : null;
    final typeLabel = ride?.ambulanceType == 'WITH_DOCTOR' ? 'With Consultant' : 'Basic Ambulance';
    final statusLabel = ride?.status.replaceAll('_', ' ') ?? 'ACTIVE';
    final etaLabel = ride?.etaMinutes != null ? '${ride!.etaMinutes} min' : '--';
    final fareLabel = ride?.formattedCost ?? '--';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: ride != null
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: ride.destinationLat != null && ride.destinationLng != null
                          ? LatLng(
                              (ride.pickupLat + ride.destinationLat!) / 2,
                              (ride.pickupLng + ride.destinationLng!) / 2,
                            )
                          : LatLng(ride.pickupLat, ride.pickupLng),
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.resqlink.mobile',
                      ),
                      if (_routePoints.length >= 2)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              color: const Color(0xFF1565C0),
                              strokeWidth: 4,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(ride.pickupLat, ride.pickupLng),
                            width: 48,
                            height: 48,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                              ),
                              child: const Center(
                                child: Text('🚑', style: TextStyle(fontSize: 24)),
                              ),
                            ),
                          ),
                          if (ride.destinationLat != null && ride.destinationLng != null)
                            Marker(
                              point: LatLng(ride.destinationLat!, ride.destinationLng!),
                              width: 40,
                              height: 48,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on, color: Color(0xFFD30000), size: 40),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  )
                : Image.asset('assets/images/fare-select.png', fit: BoxFit.cover),
          ),

          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 5))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRouteRow(Colors.green, 'Pickup: $pickupLabel'),
                  if (destinationLabel != null) ...[
                    const SizedBox(height: 12),
                    _buildRouteRow(Colors.red, 'Drop: $destinationLabel'),
                  ],
                  const SizedBox(height: 12),
                  _buildRouteRow(Colors.blue, typeLabel),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(statusLabel, style: TextStyle(color: Colors.red.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),

          if (ride?.ambulanceType == 'WITH_DOCTOR' && ride?.paramedicName != null)
            Positioned(
              bottom: 185,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2E7D32).withOpacity(0.3)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, color: Color(0xFF2E7D32), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Paramedic Partner', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                          Text(ride!.paramedicName!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          if (ride.paramedicPhone != null)
                            Text(ride.paramedicPhone!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip(Icons.timer_outlined, etaLabel, 'ETA'),
                _buildInfoChip(Icons.payments_outlined, fareLabel, 'Fare', iconText: 'Rs'),
              ],
            ),
          ),

          Positioned(
            bottom: 110,
            right: 20,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: () {
                    final ride = context.read<RideProvider>().activeRide;
                    if (ride != null) {
                      context.read<ChatProvider>().clearUnread();
                      Navigator.pushNamed(context, AppRoutes.chatScreen, arguments: {
                        'rideRequestId': ride.id,
                        'recipientId': ride.userId,
                        'recipientName': ride.patientName ?? 'Patient',
                        'isGroup': ride.ambulanceType == 'WITH_DOCTOR',
                      });
                    }
                  },
                  child: const Icon(Icons.chat_bubble_outline, color: Color(0xFFD30000)),
                ),
                Consumer<ChatProvider>(
                  builder: (_, chat, __) {
                    if (chat.unreadCount == 0) return const SizedBox.shrink();
                    return Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            chat.unreadCount > 9 ? '9+' : '${chat.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ride?.status == 'IN_TRIP'
                  ? ElevatedButton(
                      onPressed: _isEnding ? null : _endRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD30000),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _isEnding
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('End Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    )
                  : ElevatedButton(
                      onPressed: _isStarting ? null : _startRide,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      child: _isStarting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Start Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(Color color, String label) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87))),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label, {String? iconText}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)]),
      child: Column(
        children: [
          iconText != null
              ? Text(iconText, style: const TextStyle(color: Color(0xFFD30000), fontSize: 15, fontWeight: FontWeight.bold))
              : Icon(icon, color: const Color(0xFFD30000), size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }
}
