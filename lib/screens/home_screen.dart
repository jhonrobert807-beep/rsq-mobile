import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/ride_provider.dart';
import '../services/ride_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _checkActiveRide();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkActiveRide());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkActiveRide() async {
    if (!mounted) return;
    try {
      final rides = await RideApi.getMyRides();
      final active = rides.where((r) =>
        r.status == 'CREATED' ||
        r.status == 'DISPATCHING' ||
        r.status == 'WAITING_DRIVER_ACCEPT' ||
        r.status == 'DRIVER_ACCEPTED' ||
        r.status == 'DRIVER_ARRIVED' ||
        r.status == 'IN_TRIP'
      ).toList();
      if (mounted) {
        if (active.isNotEmpty) {
          context.read<RideProvider>().setActiveRide(active.first);
        } else {
          context.read<RideProvider>().clearActiveRide();
        }
      }
    } catch (_) {}
  }

  // Theme Constants
  static const Color primaryRed = Color(0xFF8D0B0B);
  static const Color lightPinkBg = Color(0xFFFFF5F5);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
    );

    context.watch<AuthProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _buildAppBarContent(context),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildActiveRideBanner(context),
                _buildRoundedBanner('assets/images/banner_top.png', 370),
                const SizedBox(height: 24),
                _buildSearchBar(context),
                const SizedBox(height: 18),
                _buildLocationList(context),
                const SizedBox(height: 24),
                _buildRoundedBanner('assets/images/banner_bottom.png', 165),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- SIDE MENU (DRAWER) PIXEL PERFECT ---
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Custom Header
          Container(
            padding: const EdgeInsets.only(
              top: 60,
              left: 20,
              bottom: 30,
              right: 20,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(color: primaryRed),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: primaryRed, size: 40),
                ),
                const SizedBox(height: 15),
                Text(
                  'Welcome ${context.read<AuthProvider>().currentUser?.name ?? 'User'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  context.read<AuthProvider>().currentUser?.displayContact ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _drawerItem(Icons.person_outline, 'My Profile', () {
            Navigator.pop(context);
            Navigator.pushNamed(context, AppRoutes.userProfile);
          }),
          _drawerItem(
            Icons.history,
            'Booking History',
            () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.bookingHistoryScreen,
            ),
          ),
          _drawerItem(
            Icons.notifications_none,
            'Notifications',
            () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.notificationsSetting,
            ),
          ),
          _drawerItem(
            Icons.payment,
            'Manage Payment Methods',
            () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.paymentMethodScreen,
            ),
          ),
          _drawerItem(
            Icons.payment,
            'Payment',
            () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.cardFlowScreen,
            ),
          ),
          _drawerItem(
            Icons.settings_outlined,
            'Settings',
            () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.languageSelection,
            ),
          ),
          _drawerItem(
            Icons.notes,
            'Privacy Policy',
            () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.privacyPolicy,
            ),
          ),

          const Spacer(),
          const Divider(indent: 20, endIndent: 20),
          _drawerItem(Icons.logout, 'Logout', () {
            Navigator.pop(context); // Close Drawer
            _showLogoutModal(context); // Show custom modal
          }, isLogout: true),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 25),
      leading: Icon(
        icon,
        color: isLogout ? Colors.redAccent : primaryRed,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isLogout ? Colors.redAccent : Colors.black87,
          fontFamily: 'Roboto',
        ),
      ),
      onTap: onTap,
    );
  }

  // --- LOGOUT MODAL PIXEL PERFECT ---
  void _showLogoutModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout_rounded, size: 60, color: primaryRed),
                const SizedBox(height: 20),
                const Text(
                  "Logout",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Are you sure you want to sign out\nof ResQLink?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: primaryRed),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: primaryRed,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await context.read<AuthProvider>().logout();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(context, AppRoutes.welcome);
                          }
                        },
                        child: const Text(
                          "Logout",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- APP BAR ---
  Widget _buildAppBarContent(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[100],
                child: const Icon(Icons.menu, color: Colors.black, size: 20),
              ),
              const Positioned(
                right: 2,
                top: 2,
                child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              'Welcome ${context.read<AuthProvider>().currentUser?.name ?? 'User'}!',
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Today is ${DateFormat('MMMM d, y').format(DateTime.now())}',
              style: const TextStyle(
                fontFamily: 'Roboto',
                color: Color(0xFF9E9E9E),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildActiveRideBanner(BuildContext context) {
    final ride = context.watch<RideProvider>().activeRide;
    if (ride == null) return const SizedBox.shrink();

    final statusLabel = ride.status.replaceAll('_', ' ');
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.userRideDetails),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryRed.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_hospital, color: primaryRed, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Ride in Progress',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: primaryRed,
                    ),
                  ),
                  Text(
                    statusLabel,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: primaryRed, size: 14),
          ],
        ),
      ),
    );
  }

  // --- OTHER COMPONENTS ---
  Widget _buildRoundedBanner(String assetPath, double height) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: primaryRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.selectRoute),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: primaryRed.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[400], size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Where to & for how much?',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationList(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: lightPinkBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(3, (index) {
          return InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.selectRoute);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    color: primaryRed.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plot B-5',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Shifa International Hospital, Karachi',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            color: Color(0xFF757575),
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', true),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.userProfile),
            child: _navItem(Icons.person, 'Profile', false),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive) {
    final color = isActive ? primaryRed : Colors.grey.shade400;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 26),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: color,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
