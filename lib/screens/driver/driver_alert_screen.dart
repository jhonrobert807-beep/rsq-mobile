import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/ride_api.dart';

class DriverAlertScreen extends StatefulWidget {
  const DriverAlertScreen({super.key});

  @override
  State<DriverAlertScreen> createState() => _DriverAlertScreenState();
}

class _DriverAlertScreenState extends State<DriverAlertScreen> {
  bool _isLoading = false;

  Future<void> _accept() async {
    final ride = context.read<RideProvider>().activeRide;
    if (ride == null) return;
    setState(() => _isLoading = true);
    try {
      await RideApi.acceptRide(ride.id);
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.driverRideScreen);
    } catch (e) {
      if (mounted) {
        final msg = e.toString().toLowerCase();
        final isCancelled = msg.contains('cancel') || msg.contains('waiting_driver_accept') || msg.contains('invalid');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCancelled ? 'This ride was cancelled by the patient.' : 'Failed to accept ride. Try again.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.driverHomeScreen);
      }
    }
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
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildRouteRow(Colors.green, 'Pickup: $pickupLabel'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  _buildRouteRow(Colors.blue, typeLabel),
                ],
              ),
            ),
          ),

          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Column(
                      children: [
                        Text('Alert', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Do you want to accept the ride?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.8),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: _isLoading ? null : _accept,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                                    : const Text('yes', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w400)),
                              ),
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, thickness: 0.8),
                        Expanded(
                          child: InkWell(
                            onTap: _isLoading ? null : _reject,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Center(
                                child: Text('no', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.w400)),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildRouteRow(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87))),
      ],
    );
  }
}
