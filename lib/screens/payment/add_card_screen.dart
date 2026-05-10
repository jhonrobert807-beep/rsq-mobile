import 'package:flutter/material.dart';

class AddCardScreen extends StatelessWidget {
  const AddCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Standard Roboto styles based on your design
    const TextStyle labelStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xFF455A64), // Dark blue-grey for labels
    );

    const TextStyle hintStyle = TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      color: Colors.grey,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Add card',
          style: TextStyle(
            fontFamily: 'Roboto',
            color: Color(0xFF263238),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CARD NUMBER', style: labelStyle),
            const SizedBox(height: 8),
            _buildTextField(hintText: 'Enter card number'),
            
            const SizedBox(height: 20),
            const Text('CARD HOLDER NAME', style: labelStyle),
            const SizedBox(height: 8),
            _buildTextField(hintText: 'Enter card holder name'),
            
            const SizedBox(height: 20),
            const Text('EXP. DATE', style: labelStyle),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTextField(hintText: 'MM/YY')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(hintText: 'CVV')),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Container for Scan and Face ID options
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildListOption(Icons.center_focus_weak, 'Scan card'),
                  const Divider(height: 1, indent: 50),
                  _buildListOption(Icons.face, 'Add face ID'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for standard input fields
  Widget _buildTextField({required String hintText}) {
    return TextFormField(
      style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF7F8F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 1),
        ),
      ),
    );
  }

  // Helper for the bottom options (Scan/FaceID)
  Widget _buildListOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF455A64)),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: Color(0xFF455A64),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {},
    );
  }
}