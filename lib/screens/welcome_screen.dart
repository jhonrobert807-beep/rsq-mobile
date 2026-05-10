import 'package:flutter/material.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                const Text(
                  'Features Of App',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 80),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                    arguments: {'role': 'USER'},
                  ),
                  child: _buildFeatureCard(
                    context,
                    title: 'Booking an Ambulance',
                    icon: Image.asset(
                      'assets/images/ambulance.png',
                      width: 26,
                      height: 26,
                      color: const Color(0xFFE31E24),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                    arguments: {'role': 'USER'},
                  ),
                  child: _buildFeatureCard(
                    context,
                    title: 'Book an Ambulance with Consultant',
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset('assets/images/doctor-icon.png', width: 18, height: 18),
                        const SizedBox(width: 4),
                        Image.asset('assets/images/ambulance.png', width: 26, height: 26, color: const Color(0xFFE31E24)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                    arguments: {'role': 'DRIVER'},
                  ),
                  child: _buildFeatureCard(
                    context,
                    title: 'Login as Driver',
                    backgroundColor: const Color(0xFFE31E24),
                    textColor: Colors.white,
                    icon: const Icon(Icons.drive_eta, color: Colors.white, size: 26),
                  ),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.login,
                    arguments: {'role': 'PARAMEDIC'},
                  ),
                  child: _buildFeatureCard(
                    context,
                    title: 'Login as Paramedic',
                    backgroundColor: const Color(0xFFE31E24),
                    textColor: Colors.white,
                    icon: const Icon(Icons.medical_services, color: Colors.white, size: 26),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required Widget icon,
    Color backgroundColor = const Color(0xFFF0FFF0),
    Color textColor = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500, fontFamily: 'Roboto'),
            ),
          ),
          const SizedBox(width: 8),
          icon,
        ],
      ),
    );
  }
}
