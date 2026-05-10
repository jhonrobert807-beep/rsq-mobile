import 'package:flutter/material.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class PMNotificationsSettingsScreen extends StatefulWidget {
  const PMNotificationsSettingsScreen({super.key});

  @override
  State<PMNotificationsSettingsScreen> createState() => _PMNotificationsSettingsScreenState();
}

class _PMNotificationsSettingsScreenState extends State<PMNotificationsSettingsScreen> {
  // State map to track toggle values
  final Map<String, bool> _settings = {
    'General Notification': true,
    'Sound': false,
    'Vibrate': true,
    'App updates': false,
    'Bill Reminder': true,
    'Promotion': true,
    'Discount Avaiable': false,
    'Payment Request': false,
    'New Service Available': false,
    'New Tips Available': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.paramedicProfileScreen),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionHeader('Common'),
          _buildSwitchRow('General Notification'),
          _buildSwitchRow('Sound'),
          _buildSwitchRow('Vibrate'),
          
          const SizedBox(height: 20),
          const Divider(thickness: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 10),
          
          _buildSectionHeader('System & services update'),
          _buildSwitchRow('App updates'),
          _buildSwitchRow('Bill Reminder'),
          _buildSwitchRow('Promotion'),
          _buildSwitchRow('Discount Avaiable'),
          _buildSwitchRow('Payment Request'),
          
          const SizedBox(height: 20),
          const Divider(thickness: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 10),
          
          _buildSectionHeader('Others'),
          _buildSwitchRow('New Service Available'),
          _buildSwitchRow('New Tips Available'),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  // Refined Row with standard-sized Switch
  Widget _buildSwitchRow(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF616161),
              fontWeight: FontWeight.w400,
            ),
          ),
          // Using Transform.scale to ensure a "Standard" Figma look
          Transform.scale(
            scale: 0.85, // Adjust this value to match your desired "standard" size
            child: Switch(
              value: _settings[key] ?? false,
              activeColor: Colors.white,
              activeTrackColor: const Color(0xFF2196F3),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (bool value) {
                setState(() {
                  _settings[key] = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}