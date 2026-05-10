import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class FareSelectionScreen extends StatelessWidget {
  const FareSelectionScreen({super.key});

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
      body: Stack(
        children: [
          // 1. Map Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/fare-select.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Full Width Route Card (Top)
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSimpleRouteRow(Colors.green, "Plot B-5"),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  _buildSimpleRouteRow(Colors.red, "Plot C-9 - 10 min"),
                ],
              ),
            ),
          ),

          // 3. Bottom Details Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with Close Button
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 22),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text(
                              "Ambulance is on the way",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 22), // Balance for the close icon
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Fare Display Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text("PKR ", style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text(
                            "150/km",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Ambulance Reg No
                    Row(
                      children: [
                        Icon(Icons.local_hospital, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          "Ambulance Register No: ABX 542",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Payment Selection
                    _buildSelectionTile(Icons.payments_outlined, "Cash", hasArrow: true),
                    const SizedBox(height: 12),

                    // Static Route Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildSimpleRouteRow(Colors.green, "Plot B-5", isBold: true),
                          const SizedBox(height: 12),
                          _buildSimpleRouteRow(Colors.red, "Plot C-9 - 10 min"),
                        ],
                      ),
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
                            Navigator.pushNamed(context, AppRoutes.paymentMethodScreen);
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
            ),
          ),
        ],
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
  Widget _buildSimpleRouteRow(Color color, String text, {bool isBold = false}) {
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
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionTile(IconData icon, String title, {bool hasArrow = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          if (hasArrow) const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}