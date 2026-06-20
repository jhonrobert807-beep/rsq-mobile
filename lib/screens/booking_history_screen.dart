import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../models/ride_request_model.dart';
import '../providers/ride_provider.dart';

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
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<RideProvider>(
        builder: (context, rideProvider, _) {
          if (rideProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (rideProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bookings',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      rideProvider.error ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => rideProvider.loadMyRides(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (rideProvider.myRides.isEmpty) {
            return Center(
              child: Text(
                'No booking history',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              const Text(
                'Ambulance Booking',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              ...rideProvider.myRides.map((ride) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: GestureDetector(
                  onTap: () {
                    rideProvider.setActiveRide(ride);
                    Navigator.pushNamed(context, AppRoutes.userRideDetails);
                  },
                  child: _BookingCard(ride: ride),
                ),
              )).toList(),
            ],
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final RideRequestModel ride;

  const _BookingCard({required this.ride});

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final rideDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (rideDate == today) {
      return 'Today';
    } else if (rideDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getAmbulanceImage(String ambulanceType) {
    if (ambulanceType.contains('DOCTOR')) {
      return 'assets/images/ambulance_ven2.png';
    }
    return 'assets/images/ambulance_ven1.png';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'IN_TRIP':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ambulanceImage = _getAmbulanceImage(ride.ambulanceType);
    final formattedDate = _formatDate(ride.requestedAt);
    final formattedTime = _formatTime(ride.requestedAt);
    final rating = (ride.userRating ?? 4.5).toStringAsFixed(1);
    final price = ride.formattedCost;
    final statusColor = _getStatusColor(ride.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Ambulance Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    ambulanceImage,
                    width: 90,
                    height: 70,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Icon(Icons.local_hospital),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.ambulanceRegistrationNumber ?? ride.ambulanceType,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$formattedDate  •  $formattedTime',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton.icon(
                              onPressed: ride.isCompleted ? () {} : null,
                              icon: const Icon(Icons.refresh, size: 14),
                              label: const Text(
                                'Rebook',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828),
                                disabledBackgroundColor: Colors.grey[300],
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Status and Rating Badge
          Positioned(
            top: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (ride.userRating != null)
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        rating,
                        style: const TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ride.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}