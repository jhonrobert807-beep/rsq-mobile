import 'package:flutter/material.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double alignmentX = 1.1; // X-axis alignment (adjust from -1.0 to 1.0)
  double alignmentY = 0.4; // Y-axis alignment (adjust from -1.0 to 1.0)

  @override
  void initState() {
    super.initState();
    // Redirect to WelcomeScreen after 2 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.welcome);
      }
    });
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
