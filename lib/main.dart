import 'package:flutter/material.dart';
import 'package:resqlink_mobile/config/theme.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resqlink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash, 
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}

