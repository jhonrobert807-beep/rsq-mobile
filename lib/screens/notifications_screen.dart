import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../services/notification_api.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  late Map<String, bool> _settings;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSaving = false;
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _settings = {
      'rideUpdates': true,
      'promotions': false,
      'safetyAlerts': true,
      'paymentReminders': true,
      'systemNotifications': true,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_prefsLoaded) {
      _prefsLoaded = true;
      _loadPreferences();
    }
  }

  Future<void> _loadPreferences() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        _showError('User not logged in');
        return;
      }

      setState(() => _isLoading = true);
      final prefs = await NotificationApi.getPreferences(userId);

      final p = prefs['preferences'] as Map? ?? prefs;
      setState(() {
        _settings = {
          'rideUpdates': p['rideUpdates'] as bool? ?? true,
          'promotions': p['promotions'] as bool? ?? false,
          'safetyAlerts': p['safetyAlerts'] as bool? ?? true,
          'paymentReminders': p['paymentReminders'] as bool? ?? true,
          'systemNotifications': p['systemNotifications'] as bool? ?? true,
        };
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      _showError('Failed to load preferences: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _savePreferences() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        _showError('User not logged in');
        return;
      }

      setState(() => _isSaving = true);

      await NotificationApi.updatePreferences(
        userId: userId,
        rideUpdates: _settings['rideUpdates'] ?? true,
        promotions: _settings['promotions'] ?? false,
        safetyAlerts: _settings['safetyAlerts'] ?? true,
        paymentReminders: _settings['paymentReminders'] ?? true,
        systemNotifications: _settings['systemNotifications'] ?? true,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        _showSuccess('Notification preferences saved');
      }
    } catch (e) {
      _showError('Failed to save preferences: ${e.toString()}');
      setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => _errorMessage = message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.userProfile),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                    ),
                  ),
                _buildSectionHeader('Ride & Safety'),
                _buildSwitchRow('rideUpdates', 'Ride Updates'),
                _buildSwitchRow('safetyAlerts', 'Safety Alerts'),

                const SizedBox(height: 20),
                const Divider(thickness: 1, color: Color(0xFFF5F5F5)),
                const SizedBox(height: 10),

                _buildSectionHeader('Payments & Promotions'),
                _buildSwitchRow('paymentReminders', 'Payment Reminders'),
                _buildSwitchRow('promotions', 'Promotions'),

                const SizedBox(height: 20),
                const Divider(thickness: 1, color: Color(0xFFF5F5F5)),
                const SizedBox(height: 10),

                _buildSectionHeader('System'),
                _buildSwitchRow('systemNotifications', 'System Notifications'),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSaving ? null : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA51C24),
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Preferences',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
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
  Widget _buildSwitchRow(String key, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Color(0xFF616161),
              fontWeight: FontWeight.w400,
            ),
          ),
          // Using Transform.scale to ensure a "Standard" Figma look
          Transform.scale(
            scale: 0.85,
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