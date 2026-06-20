import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/ride_api.dart';

class ParamedicAlertScreen extends StatefulWidget {
  const ParamedicAlertScreen({super.key});

  @override
  State<ParamedicAlertScreen> createState() => _ParamedicAlertScreenState();
}

class _ParamedicAlertScreenState extends State<ParamedicAlertScreen> {
  bool _isLoading = false;

  Future<void> _accept() async {
    final ride = context.read<RideProvider>().activeRide;
    if (ride == null) return;
    // Paramedic is pre-assigned by admin — no API call needed.
    // Pop alert first so home screen's .then() fires and resets _hasAlert,
    // then home screen immediately pushes chat directly.
    if (mounted) Navigator.pop(context, 'accepted');
  }

  Future<void> _reject() async {
    final ride = context.read<RideProvider>().activeRide;
    if (ride == null) { Navigator.pop(context); return; }
    try {
      await RideApi.rejectRide(ride.id);
    } catch (_) {}
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.transparent),
    );

    final ride = context.watch<RideProvider>().activeRide;
    final pickupLabel = ride != null
        ? '${ride.pickupLat.toStringAsFixed(4)}, ${ride.pickupLng.toStringAsFixed(4)}'
        : 'Unknown location';
    final typeLabel = ride?.ambulanceType == 'WITH_DOCTOR' ? 'With Consultant' : 'Basic Ambulance';

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fare-select.png', fit: BoxFit.cover),
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
                  const SizedBox(height: 12),
                  _buildRouteRow(Colors.blue, typeLabel),
                ],
              ),
            ),
          ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Alert', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text(
                    'User needs consultation. Accept to start chat.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading ? null : _reject,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Decline', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _accept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD30000),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
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
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87))),
      ],
    );
  }
}
