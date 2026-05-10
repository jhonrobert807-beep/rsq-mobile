import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/ride_api.dart';

class DriverRideScreen extends StatefulWidget {
  const DriverRideScreen({super.key});

  @override
  State<DriverRideScreen> createState() => _DriverRideScreenState();
}

class _DriverRideScreenState extends State<DriverRideScreen> {
  bool _isEnding = false;

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
        Navigator.pushReplacementNamed(context, AppRoutes.driverProfileScreen);
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
    final typeLabel = ride?.ambulanceType == 'WITH_DOCTOR' ? 'With Consultant' : 'Basic Ambulance';
    final statusLabel = ride?.status.replaceAll('_', ' ') ?? 'ACTIVE';

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

          if (ride?.formattedCost != null)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoChip(Icons.timer_outlined, ride!.formattedEta, 'ETA'),
                  _buildInfoChip(Icons.attach_money, ride.formattedCost, 'Fare'),
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
              child: ElevatedButton(
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

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)]),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFFD30000), size: 20),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        ],
      ),
    );
  }
}
