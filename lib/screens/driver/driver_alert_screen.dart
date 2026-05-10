import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class DriverAlertScreen extends StatelessWidget {
  const DriverAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Making the status bar transparent to allow the map to bleed through
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
              'assets/images/fare-select.png', // Background map image
              fit: BoxFit.cover,
            ),
          ),

          // 2. Top Info Card (Pickup and Dropoff)
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildRouteRow(Colors.green, "Plot B-5"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  _buildRouteRow(Colors.red, "Plot C-9", time: "10 min"),
                ],
              ),
            ),
          ),

          // 3. Centered Alert Modal
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    child: Column(
                      children: [
                        Text(
                          "Alert",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Do you want to accept the ride?",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, thickness: 0.8),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        // YES Action
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.driverRideScreen,
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Center(
                                child: Text(
                                  "yes",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 1, thickness: 0.8),
                        // NO Action
                        Expanded(
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Center(
                                child: Text(
                                  "no",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
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

  Widget _buildRouteRow(Color color, String address, {String? time}) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 10),
        const SizedBox(width: 12),
        Text(
          address,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        if (time != null) ...[
          const SizedBox(width: 4),
          Text(
            "~$time",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
        ],
      ],
    );
  }
}
