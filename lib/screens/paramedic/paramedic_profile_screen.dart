import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../../models/driver_profile_model.dart';
import '../../models/ride_request_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ride_provider.dart';
import '../../services/driver_api.dart';
import '../../services/ride_api.dart';

class ParamedicProfileScreen extends StatefulWidget {
  const ParamedicProfileScreen({super.key});

  @override
  State<ParamedicProfileScreen> createState() => _ParamedicProfileScreenState();
}

class _ParamedicProfileScreenState extends State<ParamedicProfileScreen> {
  DriverProfileModel? _paramedicProfile;
  Timer? _pollTimer;
  bool _hasAlert = false;
  int _selectedTab = 0;
  List<RideRequestModel> _myRides = [];

  @override
  void initState() {
    super.initState();
    _loadParamedicProfile();
    _loadRideHistory();
    _startPolling();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args == 'history') setState(() => _selectedTab = 1);
    });
  }

  Future<void> _loadRideHistory() async {
    try {
      final rides = await RideApi.getDriverRides();
      if (mounted) setState(() => _myRides = rides);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadParamedicProfile() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;
    try {
      final profile = await ParamedicApi.getProfileByUserId(userId);
      if (mounted) setState(() => _paramedicProfile = profile);
    } catch (_) {}
  }

  void _startPolling() {
    _checkForRides();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkForRides());
  }

  Future<void> _checkForRides() async {
    if (!mounted || _hasAlert) return;
    try {
      final rides = await RideApi.getDriverRides();
      if (!mounted || _hasAlert) return;
      final rideProvider = context.read<RideProvider>();

      // Show alert only for WAITING_DRIVER_ACCEPT
      final waiting = rides.where((r) => r.status == 'WAITING_DRIVER_ACCEPT').toList();
      if (waiting.isNotEmpty) {
        _hasAlert = true;
        final ride = waiting.first;
        rideProvider.setActiveRide(ride);
        final result = await Navigator.of(context).pushNamed(AppRoutes.paramedicAlertScreen);
        if (!mounted) return;
        if (result == 'accepted') {
          await _openGroupChat(ride.id, ride.assignedDriverId ?? ride.userId, ride.patientName ?? 'Patient');
        }
        if (mounted) setState(() => _hasAlert = false);
        return;
      }

      // Driver already accepted — go straight to chat
      final active = rides.where((r) =>
        r.status == 'DRIVER_ACCEPTED' ||
        r.status == 'DRIVER_ARRIVED' ||
        r.status == 'IN_TRIP'
      ).toList();
      if (active.isNotEmpty) {
        _hasAlert = true;
        final ride = active.first;
        rideProvider.setActiveRide(ride);
        await _openGroupChat(ride.id, ride.assignedDriverId ?? ride.userId, ride.patientName ?? 'Patient');
        if (mounted) setState(() => _hasAlert = false);
      }
    } catch (_) {}
  }

  Future<void> _openGroupChat(String rideId, String recipientId, String recipientName) async {
    if (!mounted) return;
    await Navigator.of(context).pushNamed(AppRoutes.chatScreen, arguments: {
      'rideRequestId': rideId,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'isGroup': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark, statusBarColor: Colors.transparent),
    );

    final user = context.watch<AuthProvider>().currentUser;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        bottomNavigationBar: _buildBottomNav(),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  ClipPath(
                    clipper: _HeaderClipper(),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      color: const Color(0xFFEBF0F0),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                                onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.paramedicHomeScreen),
                              splashRadius: 24,
                              padding: EdgeInsets.zero,
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.notifications_none_outlined, size: 28, color: Colors.black),
                              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.paramedicnotificationsSetting),
                              splashRadius: 24,
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_active, size: 26),
                                  onPressed: _checkForRides,
                                  splashRadius: 22,
                                  padding: EdgeInsets.zero,
                                  tooltip: 'Check for rides',
                                ),
                                if (_hasAlert)
                                  const Positioned(
                                    right: 8,
                                    top: 8,
                                    child: CircleAvatar(radius: 5, backgroundColor: Colors.red),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 15),
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 26),
                              onPressed: () {},
                              splashRadius: 22,
                              padding: EdgeInsets.zero,
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
                          backgroundImage: AssetImage('assets/images/profile.jpg'),
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
                            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.editParamedicProfileScreen),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            Text(
              user?.name ?? 'Paramedic Staff',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Paramedic Staff',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              user?.displayContact ?? '',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),

            if (_paramedicProfile != null) ...[
              const SizedBox(height: 8),
              Text(
                'License: ${_paramedicProfile!.licenseNumber ?? 'N/A'}  •  ${_paramedicProfile!.experienceYears ?? 0} yrs exp',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],

            const SizedBox(height: 20),

            // Tab selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _tabButton('Profile', 0),
                  const SizedBox(width: 12),
                  _tabButton('Ride History', 1),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedTab == 0) ...[
              _buildProfileCard([
                _buildListTile(Icons.account_box_outlined, 'Edit profile information', onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.editParamedicProfileScreen)),
                const Divider(height: 1),
                _buildListTile(Icons.notifications_none_outlined, 'Notifications', trailing: 'ON'),
                const Divider(height: 1),
                _buildListTile(Icons.translate, 'Language', trailing: 'English'),
              ]),
              _buildProfileCard([
                _buildListTile(Icons.people_outline, 'Help & Support'),
                const Divider(height: 1),
                _buildListTile(Icons.lock_outline, 'Privacy policy'),
                const Divider(height: 1),
                _buildListTile(Icons.logout, 'Logout', isLogout: true, onTap: () async {
                  final navigator = Navigator.of(context);
                  await context.read<AuthProvider>().logout();
                  if (mounted) navigator.pushReplacementNamed(AppRoutes.welcome);
                }),
              ]),
            ] else
              _buildRideHistory(),

            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _tabButton(String label, int index) {
    final isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFA51C24) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildRideHistory() {
    if (_myRides.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(child: Text('No ride history', style: TextStyle(color: Colors.grey))),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _myRides.length,
      itemBuilder: (_, i) {
        final ride = _myRides[i];
        final isCompleted = ride.status == 'COMPLETED';
        final statusColor = isCompleted ? Colors.green : ride.status == 'CANCELLED' ? Colors.red : Colors.orange;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: const Color(0xFFFFF5F5), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.local_hospital, color: Color(0xFFA51C24), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.ambulanceType == 'WITH_DOCTOR' ? 'With Consultant' : 'Basic Ambulance',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ride.requestedAt.day}/${ride.requestedAt.month}/${ride.requestedAt.year}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: Text(ride.status.replaceAll('_', ' '), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 4),
                  Text(ride.formattedCost, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home, 'Home', true),
          _navItem(Icons.person, 'Profile', false),
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

  Widget _buildListTile(IconData icon, String title, {String? trailing, bool isLogout = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isLogout ? Colors.red : Colors.black87, size: 22),
            const SizedBox(width: 15),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: isLogout ? Colors.red : Colors.black87))),
            if (trailing != null)
              Text(trailing, style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
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
