import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/ride_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../services/ride_api.dart';

class UserRideDetailsScreen extends StatefulWidget {
  const UserRideDetailsScreen({super.key});

  @override
  State<UserRideDetailsScreen> createState() => _UserRideDetailsScreenState();
}

class _UserRideDetailsScreenState extends State<UserRideDetailsScreen> {
  Timer? _pollTimer;
  bool _ratingShown = false;
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (mounted) context.read<RideProvider>().refreshActiveRide();
    });
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
      // Fall back to straight line if routing fails
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

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: const Text('Are you sure you want to cancel this ride?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<RideProvider>().cancelRide();
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  Future<void> _showRatingDialog(String rideId) async {
    if (_ratingShown) return;
    _ratingShown = true;
    double selectedRating = 5;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          title: const Text('Rate Your Ride', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your experience?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setModalState(() => selectedRating = (i + 1).toDouble()),
                    child: Icon(
                      i < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD42C2C)),
              onPressed: () async {
                try {
                  await RideApi.rateRide(rideId, selectedRating);
                } catch (_) {}
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark, statusBarColor: Colors.transparent),
    );

    final ride = context.watch<RideProvider>().activeRide;

    if (ride == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFFD42C2C))),
      );
    }

    // Trigger rating dialog when ride is completed
    if (ride.isCompleted && ride.userRating == null && !_ratingShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showRatingDialog(ride.id));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
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
                                  Icon(Icons.location_on, color: Color(0xFFD42C2C), size: 40),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 50,
                    right: 20,
                    child: _buildStatusBadge(ride.status),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -8)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),

                  // Driver + Ambulance row
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: const Icon(Icons.person, color: Color(0xFF9E9E9E), size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.driverName ?? 'Finding driver...',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Roboto', color: Color(0xFF1A1A1A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ride.driverPhone ?? (ride.assignedDriverId != null ? 'Assigned' : ''),
                              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            ride.ambulanceRegistrationNumber ?? '—',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Roboto', color: Color(0xFF1A1A1A)),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ride.ambulanceType == 'WITH_DOCTOR'
                                  ? const Color(0xFFEDE7F6)
                                  : const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              ride.ambulanceType == 'WITH_DOCTOR' ? 'With Consultant' : 'Basic',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: ride.ambulanceType == 'WITH_DOCTOR'
                                    ? const Color(0xFF6A1B9A)
                                    : const Color(0xFF1565C0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Divider(color: Colors.grey[100], height: 1),
                  const SizedBox(height: 16),

                  // ETA + Fare chips
                  Row(
                    children: [
                      Expanded(child: _buildInfoChip(Icons.timer_outlined, ride.formattedEta, 'ETA')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInfoChip(Icons.payments_outlined, ride.formattedCost, 'Fare')),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Cancel button
                  if (ride.isActive)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _cancel,
                        icon: const Icon(Icons.cancel_outlined, color: Color(0xFFD42C2C), size: 18),
                        label: const Text('Cancel Ride', style: TextStyle(color: Color(0xFFD42C2C), fontWeight: FontWeight.w600, fontSize: 14)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD42C2C), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          backgroundColor: const Color(0xFFFFF5F5),
                        ),
                      ),
                    ),

                  if (ride.isActive) const SizedBox(height: 14),

                  // Action buttons row
                  Row(
                    children: [
                      Expanded(child: _buildActionButton(Icons.phone_outlined, 'Call', const Color(0xFF1565C0), const Color(0xFFE3F2FD),
                          onTap: () {
                            final phone = ride.driverPhone;
                            if (phone != null && phone.isNotEmpty) {
                              launchUrl(Uri.parse('tel:$phone'));
                            }
                          })),
                      const SizedBox(width: 10),
                      Expanded(child: _buildChatButton(ride)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildActionButton(Icons.home_outlined, 'Home', const Color(0xFF424242), const Color(0xFFF5F5F5),
                          onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.home))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final label = status.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFD42C2C), size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1A1A1A))),
              Text(label, style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color iconColor, Color bgColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: iconColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton(dynamic ride) {
    final unread = context.watch<ChatProvider>().unreadCount;
    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(Icons.chat_rounded, 'Chat', const Color(0xFF2E7D32), const Color(0xFFE8F5E9),
                onTap: () {
                  context.read<ChatProvider>().clearUnread();
                  Navigator.pushNamed(context, AppRoutes.chatScreen, arguments: {
                    'rideRequestId': ride.id,
                    'recipientId': ride.assignedDriverId ?? '',
                    'recipientName': ride.driverName ?? 'Driver',
                    'isGroup': ride.ambulanceType == 'WITH_DOCTOR',
                  });
                }),
          ),
          if (unread > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(color: Color(0xFFD42C2C), shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
