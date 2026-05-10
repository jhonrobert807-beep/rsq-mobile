import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class SelectVehicleScreen extends StatelessWidget {
  const SelectVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. MAP SECTION
            Expanded(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/select-vehical.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  
                  // Top Route Info Card
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: _buildRouteInfoCard(),
                  ),

                  // Back Button (Bottom Left of Map)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: _buildCircleIconButton(Icons.arrow_back, () => Navigator.pop(context)),
                  ),
                ],
              ),
            ),

            // 2. VEHICLE SELECTION BOTTOM SECTION
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Draggable handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  _buildVehicleTile(
                    title: 'Ambulance with Consultant',
                    subtitle: '1 - 3 min',
                    price: 'PKR 150/km',
                    isSelected: true,
                    iconPath: 'assets/images/doctor-icon.png',
                  ),
                  
                  const SizedBox(height: 12),

                  _buildVehicleTile(
                    title: 'Only Ambulance',
                    subtitle: '4 - 5 min',
                    price: 'PKR 100/km',
                    isSelected: false,
                    iconPath: 'assets/images/ambulance.png',
                  ),

                  const SizedBox(height: 24),

                  // PIXEL PERFECT BOTTOM ROW (Visa + Button + Filter)
                  Row(
                    children: [
                      // Visa / Payment Section
                      _buildPaymentMethod(),

                      const SizedBox(width: 12),

                      // Main Action Button
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.fareSelection);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935), // Correct Brand Red
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Select an Ambulance',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Filter Icon Button
                      _buildCircleIconButton(Icons.tune, () {}, size: 48, iconSize: 20),
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

  Widget _buildPaymentMethod() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/visa.png', width: 32),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
      ],
    );
  }

  Widget _buildRouteInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildRouteLine(Colors.green, 'Plot B-5'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(indent: 12, endIndent: 12, height: 1),
          ),
          _buildRouteLine(Colors.red, 'Plot C-9 - 10 min'),
        ],
      ),
    );
  }

  Widget _buildRouteLine(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTile({
    required String title,
    required String subtitle,
    required String price,
    required bool isSelected,
    required String iconPath,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFFE53935) : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Roboto'),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, fontFamily: 'Roboto'),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Roboto'),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, VoidCallback onTap, {double size = 45, double iconSize = 20}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, size: iconSize, color: Colors.black),
      ),
    );
  }
}