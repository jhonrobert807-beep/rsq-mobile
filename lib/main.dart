import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'routes/app_routes.dart';
import 'services/api_service.dart';
import 'providers/auth_provider.dart';
import 'providers/ride_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/tracking_provider.dart';

void main() {
  ApiService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RideProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
      ],
      child: MaterialApp(
        title: 'Resqlink',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
