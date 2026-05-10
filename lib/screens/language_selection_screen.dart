import 'package:flutter/material.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  // Currently selected language
  String _selectedLanguage = 'English (UK)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionHeader('Suggested'),
          _buildLanguageOption('English (US)'),
          _buildLanguageOption('English (UK)'),
          
          const SizedBox(height: 15),
          const Divider(thickness: 1, color: Color(0xFFF5F5F5)),
          const SizedBox(height: 10),
          
          _buildSectionHeader('Others'),
          _buildLanguageOption('Mandarin'),
          _buildLanguageOption('Urdu'),
          _buildLanguageOption('Spanish'),
          _buildLanguageOption('French'),
          _buildLanguageOption('Arabic'),
          _buildLanguageOption('Russian'),
          _buildLanguageOption('Indonesia'),
          _buildLanguageOption('Vietnamese'),
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
  Widget _buildLanguageOption(String language) {
    bool isSelected = _selectedLanguage == language;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 14,
                color: Color(0xFF424242),
                fontWeight: FontWeight.w400,
              ),
            ),
            // Custom sized radio-style circle to match Figma precisely
            Container(
              height: 20,
              width: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2196F3) : const Color(0xFFD1E4FF),
                  width: isSelected ? 6 : 2, // Inner dot effect
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