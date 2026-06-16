import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../services/auth_api.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double alignmentX = 1.1;
  double alignmentY = 0.4;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _checkSession);
  }

  Future<void> _checkSession() async {
    if (!mounted) return;
    final token = await StorageService.getAccessToken();
    if (token != null) {
      try {
        final user = await AuthApi.getProfile();
        if (!mounted) return;
        context.read<AuthProvider>().updateUser(user);
        _navigateByRole(user.role);
        return;
      } catch (_) {
        await StorageService.clearAll();
      }
    }
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.welcome);
  }

  void _navigateByRole(String role) {
    switch (role) {
      case 'DRIVER':
        Navigator.pushReplacementNamed(context, AppRoutes.driverHomeScreen);
        break;
      case 'PARAMEDIC':
        Navigator.pushReplacementNamed(context, AppRoutes.paramedicHomeScreen);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo and text container
            SizedBox(
              width: 320,
              height: 280,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/the-logo.png',
                          width: 900,
                          height: 250,
                        ),
                      ),
                    ],
                  ),
                  // AMBULANCE SERVICE text with custom alignment
                  Align(
                    alignment: Alignment(alignmentX, alignmentY),
                    child: Text(
                      'AMBULANCE SERVICE',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
