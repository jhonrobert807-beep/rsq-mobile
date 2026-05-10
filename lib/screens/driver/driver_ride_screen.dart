import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../routes/app_routes.dart';

class DriverRideScreen extends StatelessWidget {
  const DriverRideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Light icons for the dark map background
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1. Dark Theme Map Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/fare-select.png', // Use your dark map asset here
              fit: BoxFit.cover,
            ),
          ),

          // 2. Top Route Info Card (Floating)
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRouteRow(Colors.green, "Plot B-5"),
                  const SizedBox(height: 12),
                  _buildRouteRow(Colors.red, "Plot C-9", time: "10 min"),
                ],
              ),
            ),
          ),

          // 3. Bottom Action Button (End Ride)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Logic to end the ride
                  Navigator.pushReplacementNamed(context, AppRoutes.welcome);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD30000), // Intense Red
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "End Ride",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the location rows
  Widget _buildRouteRow(Color color, String address, {String? time}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            address,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        if (time != null)
          Text(
            "~$time",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }
}
