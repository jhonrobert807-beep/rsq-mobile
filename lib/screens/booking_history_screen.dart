import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/ride_request_model.dart';
import '../providers/ride_provider.dart';
import '../routes/app_routes.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().loadMyRides();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideProvider = context.watch<RideProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
        ),
        title: const Text(
          'Booking history',
          style: TextStyle(fontFamily: 'Roboto', color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: rideProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFD42C2C)))
          : rideProvider.myRides.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No bookings yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: rideProvider.myRides.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    return _buildRideCard(context, rideProvider.myRides[index]);
                  },
                ),
    );
  }

  Widget _buildRideCard(BuildContext context, RideRequestModel ride) {
    final isWithDoctor = ride.ambulanceType == 'WITH_DOCTOR';
    final statusColor = ride.isCompleted
        ? Colors.green
        : ride.isCancelled
            ? Colors.red
            : Colors.orange;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_hospital, color: Color(0xFFD42C2C), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isWithDoctor ? 'Ambulance with Consultant' : 'Basic Ambulance',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Roboto'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM d, y  hh:mm a').format(ride.requestedAt.toLocal()),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12, fontFamily: 'Roboto'),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ride.status.replaceAll('_', ' '),
                    style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ride.formattedCost,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFD42C2C)),
                ),
                if (ride.userRating != null)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(ride.userRating!.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                if (ride.ambulanceRegistrationNumber != null)
                  Text(
                    ride.ambulanceRegistrationNumber!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
              ],
            ),
            if (!ride.isCancelled && !ride.isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD42C2C)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      context.read<RideProvider>().setActiveRide(ride);
                      Navigator.pushNamed(context, AppRoutes.userRideDetails);
                    },
                    child: const Text('View Details', style: TextStyle(color: Color(0xFFD42C2C))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
