import 'package:flutter/material.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class EditParamedicProfileScreen extends StatefulWidget {
  const EditParamedicProfileScreen({super.key});

  @override
  State<EditParamedicProfileScreen> createState() =>
      _EditParamedicProfileScreenState();
}

class _EditParamedicProfileScreenState
    extends State<EditParamedicProfileScreen> {
  // Roboto TextStyles defined for reuse
  final TextStyle _labelStyle = const TextStyle(
    fontFamily: 'Roboto',
    color: Color(0xFF9E9E9E),
    fontSize: 12,
  );

  final TextStyle _inputStyle = const TextStyle(
    fontFamily: 'Roboto',
    color: Colors.black,
    fontSize: 15,
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
          onPressed: () => Navigator.pushReplacementNamed(
            context,
            AppRoutes.paramedicProfileScreen,
          ),
        ),
        title: const Text(
          'Edit profile',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
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
                      _buildInputField(
                        label: "Full name",
                        initialValue: "Paramedic",
                      ),
                      _buildInputField(
                        label: "Nick name",
                        initialValue: "Paramedic",
                      ),
                      _buildInputField(
                        label: "Email",
                        initialValue: "Paramedic@gmail.com",
                      ),
                      _buildPhoneField(), // Fixed overflow
                      Row(
                        children: [
                          Expanded(
                            child: _buildInputField(
                              label: "Country",
                              initialValue: "Pakistan",
                              isDropdown: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInputField(
                              label: "Genre",
                              initialValue: "Female",
                            ),
                          ),
                        ],
                      ),
                      _buildInputField(
                        label: "Address",
                        initialValue: "R 33 Gulshan Iqbal, Karachi",
                      ),
                    ],
                  ),
                ),
              ),
              // Pushes button to the bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  Widget _buildInputField({
    required String label,
    required String initialValue,
    bool isDropdown = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: isDropdown,
        style: _inputStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: _labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: const Color(0xFFF6F9FF),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          suffixIcon: isDropdown
              ? const Icon(Icons.arrow_drop_down, color: Colors.grey)
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2196F3)),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: "09876 54321",
        style: _inputStyle,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: "Phone number",
          labelStyle: _labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: const Color(0xFFF6F9FF),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Fixes the RenderFlex overflow
              children: [
                // Local asset or Icon to avoid HTTP request failures
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFF135D1D),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text("🇵🇰", style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2196F3)),
          ),
        ),
      ),
    );
  }
}
