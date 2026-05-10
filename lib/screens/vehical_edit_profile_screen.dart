import 'package:flutter/material.dart';

class VehicleProfileEditScreen extends StatefulWidget {
  const VehicleProfileEditScreen({super.key});

  @override
  State<VehicleProfileEditScreen> createState() => _VehicleProfileEditScreenState();
}

class _VehicleProfileEditScreenState extends State<VehicleProfileEditScreen> {
  // Styles using Roboto font from your pubspec.yaml
  final TextStyle _labelStyle = const TextStyle(
    fontFamily: 'Roboto',
    color: Color(0xFF9E9E9E),
    fontSize: 12,
  );

  final TextStyle _inputStyle = const TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Vehicle Edit profile',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      // Column + Expanded + Spacer strategy to pin button at bottom
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildInputField(label: "Vehicle Owner", initialValue: "xyssx xsdyzz"),
                      _buildInputField(label: "Vehicle Registration Number", initialValue: "KA 01 SS 0128"),
                      _buildInputField(label: "Vehicle Type", initialValue: "Express Ambulance"),
                      _buildPhoneField(), // Stability fix for the flag overflow
                      Row(
                        children: [
                          Expanded(child: _buildInputField(label: "Country", initialValue: "Pakistan", isDropdown: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInputField(label: "Genre", initialValue: "Male")),
                        ],
                      ),
                      _buildInputField(label: "Vehicle Registered City", initialValue: "Karachi, Pakistan"),
                    ],
                  ),
                ),
              ),
              // Button pinned to the bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828), // Figma Red
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'SUBMIT',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required String initialValue, bool isDropdown = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: isDropdown,
        style: _inputStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: _labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: const Color(0xFFF5F8FF), // Light blue tint from Figma
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          suffixIcon: isDropdown ? const Icon(Icons.arrow_drop_down, color: Colors.grey) : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextFormField(
        initialValue: "09876 54321",
        style: _inputStyle,
        decoration: InputDecoration(
          labelText: "Phone number",
          labelStyle: _labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: const Color(0xFFF5F8FF),
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Prevents the RenderFlex overflow
              children: [
                // Circular flag fallback to prevent NetworkImage errors
                Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFF135D1D),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(child: Text("🇵🇰", style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2196F3)),
          ),
        ),
      ),
    );
  }
}