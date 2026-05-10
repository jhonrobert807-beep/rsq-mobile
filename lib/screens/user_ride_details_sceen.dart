import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../routes/app_routes.dart';

class UserRideDetailsScreen extends StatelessWidget {
  const UserRideDetailsScreen({super.key});

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
        top: false,
        child: Column(
          children: [
            // 1. MAP SECTION (Bleeds into status bar)
            Expanded(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/ride-map.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Positioned(
                    top: 50,
                    left: 20,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4)
                          ],
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. DRIVER & RIDE DETAILS CARD
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle indicator
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Driver Details Row
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Color(0xFFF3F3F3),
                        child: Icon(Icons.person, color: Colors.grey, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mr XYZ',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Roboto'),
                            ),
                            Text(
                              'T728',
                              style: TextStyle(color: Colors.grey[500], fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'H9785K',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Roboto'),
                          ),
                          Text(
                            'Private Ambulance',
                            style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // THE TIMELINE (PIXEL PERFECT CONNECTOR)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildTimelineRow('11:24', 'Plot B-5', isStart: true),
                        // The Connector Line
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(left: 3.5), // Aligns line with dot center
                            width: 1,
                            height: 20,
                            color: Colors.grey[300],
                          ),
                        ),
                        _buildTimelineRow('11:38', 'Plot C-9', isStart: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PAYMENT METHOD
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFF0F0F0)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/images/mastercard.png', width: 24),
                        const SizedBox(width: 12),
                        const Text(
                          '**** 8295',
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, fontFamily: 'Roboto'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ACTION BUTTONS (CALL, CHAT, CLOSE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionCircle(Icons.phone),
                      _buildChatCircle('2'),
                      _buildActionCircle(Icons.close, onTap: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
                      }),
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

  Widget _buildTimelineRow(String time, String address, {required bool isStart}) {
    return Row(
      children: [
        Icon(
          Icons.circle,
          color: const Color(0xFF2196F3),
          size: 8,
        ),
        const SizedBox(width: 16),
        Text(
          time,
          style: TextStyle(color: Colors.grey[500], fontSize: 13, fontFamily: 'Roboto'),
        ),
        const SizedBox(width: 16),
        Text(
          address,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, fontFamily: 'Roboto'),
        ),
      ],
    );
  }

  // Widget _buildActionCircle(IconData icon) {
  //   return Container(
  //     width: 56,
  //     height: 56,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       shape: BoxShape.circle,
  //       border: Border.all(color: const Color(0xFFF0F0F0)),
  //     ),
  //     child: Icon(icon, color: Colors.black, size: 24),
  //   );
  // }

Widget _buildActionCircle(IconData icon, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Icon(icon, color: Colors.black, size: 24),
    ),
  );
}
  

  Widget _buildChatCircle(String badgeCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildActionCircle(Icons.chat_bubble_outline),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                badgeCount,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}