import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../services/language_api.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _selectedLanguage;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<Map<String, String>> _availableLanguages = [];

  // Language code mapping
  final Map<String, String> _languageMap = {
    'en': 'English',
    'es': 'Spanish',
    'fr': 'French',
    'de': 'German',
    'pt': 'Portuguese',
    'ar': 'Arabic',
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguage = 'en';
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    try {
      setState(() => _isLoading = true);

      final languages = await LanguageApi.getAvailableLanguages();

      // Convert to list for UI
      final langList = (languages as List)
          .map((lang) => {
                'code': lang['code'] as String? ?? 'en',
                'name': lang['name'] as String? ?? 'English',
              })
          .toList();

      // Also load current user preference
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;

      if (userId != null) {
        try {
          final pref = await LanguageApi.getLanguagePreference(userId);
          if (mounted) {
            setState(() {
              _selectedLanguage = pref;
              _availableLanguages = langList;
              _isLoading = false;
              _errorMessage = null;
            });
          }
        } catch (e) {
          // Preference load failed, but show available languages anyway
          if (mounted) {
            setState(() {
              _availableLanguages = langList;
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _availableLanguages = langList;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      _showError('Failed to load languages: ${e.toString()}');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveLanguage(String languageCode) async {
    try {
      if (!mounted) return;
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.currentUser?.id;

      if (userId == null) {
        _showError('User not logged in');
        return;
      }

      setState(() => _isSaving = true);

      await LanguageApi.setLanguagePreference(
        userId: userId,
        languageCode: languageCode,
      );

      if (mounted) {
        setState(() {
          _selectedLanguage = languageCode;
          _isSaving = false;
        });
        _showSuccess('Language saved successfully');
      }
    } catch (e) {
      _showError('Failed to save language: ${e.toString()}');
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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
          'Language',
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
                _buildSectionHeader('Available Languages'),
                ..._availableLanguages.map((lang) =>
                    _buildLanguageOption(lang['code']!, lang['name']!)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () => _saveLanguage(_selectedLanguage),
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
                          'Save Language',
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

  // Section Header matching previous screens
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
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

  // Standard-sized Radio List Tile
  Widget _buildLanguageOption(String code, String language) {
    bool isSelected = _selectedLanguage == code;

    return InkWell(
      onTap: _isSaving ? null : () => _saveLanguage(code),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                language,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 14,
                  color: Color(isSelected ? 0xFF2196F3 : 0xFF424242),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            // Custom sized radio-style circle
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFD1E4FF),
                  width: isSelected ? 6 : 2,
                ),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}