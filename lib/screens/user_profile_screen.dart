import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Adding the Bottom Navigation Bar here
      bottomNavigationBar: _buildBottomNav(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section 1: Curved Header
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
            
              ClipPath(
                clipper: HeaderClipper(),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  color: const Color(0xFFEBF0F0),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_outlined, size: 28),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, AppRoutes.notificationsSetting);
                        },
                        splashRadius: 24,
                        tooltip: 'Notifications',
                        padding: EdgeInsets.zero,
                        splashColor: Colors.grey.shade300.withOpacity(0.5),
                        highlightColor: Colors.transparent,
                      ),
                      
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.history, size: 26),
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, AppRoutes.bookingHistoryScreen);
                            },
                            splashRadius: 22,
                            tooltip: 'Booking History',
                            padding: EdgeInsets.zero,
                            splashColor: Colors.grey.shade300.withOpacity(0.5),
                            highlightColor: Colors.transparent,
                          ),
                          const SizedBox(width: 15),
                          IconButton(
                            icon: const Icon(Icons.more_vert, size: 26),
                            onPressed: () {
                              // TODO: Show menu (e.g., PopupMenuButton)
                              print('More options tapped');
                            },
                            splashRadius: 22,
                            tooltip: 'More options',
                            padding: EdgeInsets.zero,
                            splashColor: Colors.grey.shade300.withOpacity(0.5),
                            highlightColor: Colors.transparent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
                            
                              

                Positioned(
                bottom: -15,
                child: Stack(
                  children: [
                    const CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 54,
                        backgroundImage: AssetImage('assets/images/profile.jpg'), // ✅ Fixed: use AssetImage for local assets
                      ),
                    ),
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade300),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          splashRadius: 20,
                          icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.black),
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, AppRoutes.editProfile);
                          },
                          tooltip: 'Edit profile picture',
                          // Optional: Add ripple effect
                          splashColor: Colors.black12,
                          highlightColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ],
            ),

            const SizedBox(height: 30),
            const Text('User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('User@gmail.com | +01 09876 54321', 
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),

            const SizedBox(height: 20),

            // Section 2: General Info Card
            _buildProfileCard([
              _buildListTile(Icons.account_box_outlined, 'Edit profile information'),
              const Divider(height: 1),
              _buildListTile(Icons.notifications_none_outlined, 'Notifications', trailing: 'ON'),
              const Divider(height: 1),
              _buildListTile(Icons.translate, 'Language', trailing: 'English'),
            ]),

            // Section 3: Vehicle & Theme Card
            _buildProfileCard([
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Vehicle Details', style: TextStyle(color: Colors.black87, fontSize: 14)),
              ),
              const Divider(height: 1),
              _buildListTile(Icons.face_retouching_natural_outlined, 'Theme', trailing: 'Light mode'),
            ]),

            // Section 4: Support Card
            _buildProfileCard([
              _buildListTile(Icons.people_outline, 'Help & Support'),
              const Divider(height: 1),
              _buildListTile(Icons.chat_bubble_outline, 'Contact us'),
              const Divider(height: 1),
              _buildListTile(Icons.lock_outline, 'Privacy policy'),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- UI Component Helpers ---

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', true),
          _navItem(Icons.person, 'Profile', false), // Profile is Active
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    final color = isActive ? const Color(0xFFA51C24) : Colors.grey.shade400;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildProfileCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(IconData icon, String title, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 22),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400))),
          if (trailing != null)
            Text(trailing, style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 50);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}