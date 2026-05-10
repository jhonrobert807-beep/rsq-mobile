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
            // Added scroll view to prevent overflow
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 80),

                // Title
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

                // Feature Card 1
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
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

                // Feature Card 2
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: _buildFeatureCard(
                    context,
                    title: 'Book an Ambulance with Consultant',
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/doctor-icon.png',
                          width: 18,
                          height: 18,
                        ),
                        const SizedBox(width: 4),
                        Image.asset(
                          'assets/images/ambulance.png',
                          width: 26,
                          height: 26,
                          color: const Color(0xFFE31E24),
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider/Space to separate User Features from Role Access
                const SizedBox(height: 40),
                const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
                const SizedBox(height: 20),

                // Driver Access Button
                GestureDetector(
                  onTap: () {
                    // Navigate to Driver Alert or Driver Window
                    Navigator.pushNamed(context, AppRoutes.driverProfileScreen);
                  },
                  child: _buildFeatureCard(
                    context,
                    title: 'Login as Driver',
                    backgroundColor: const Color(
                      0xFFE31E24,
                    ), // Role-specific color
                    textColor: Colors.white,
                    icon: const Icon(
                      Icons.drive_eta,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Paramedic Access Button
                GestureDetector(
                  onTap: () {
                    // Navigate to Paramedic Alert window
                    Navigator.pushNamed(
                      context,
                      AppRoutes.paramedicProfileScreen,
                    );
                  },
                  child: _buildFeatureCard(
                    context,
                    title: 'Login as Paramedic',
                    backgroundColor: const Color(
                      0xFFE31E24,
                    ), // Distinct blue for Paramedic
                    textColor: Colors.white,
                    icon: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 26,
                    ),
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

  // Modified helper to accept background and text colors
  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required Widget icon,
    Color backgroundColor = const Color(0xFFF0FFF0),
    Color textColor = Colors.black,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ), // Slightly more padding
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
                fontWeight: FontWeight.w500,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          const SizedBox(width: 8),
          icon,
        ],
      ),
    );
  }
}
