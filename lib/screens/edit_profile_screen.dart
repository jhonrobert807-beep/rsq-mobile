import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../core/errors/app_exception.dart';
import '../providers/auth_provider.dart';
import '../services/user_api.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _initialized = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email ?? '';
        _phoneController.text = user.phone ?? '';
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.length < 2) {
      _showError('Name must be at least 2 characters');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final updated = await UserApi.updateUser(
        userId,
        name: name.isNotEmpty ? name : null,
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
      );
      if (!mounted) return;
      context.read<AuthProvider>().updateUser(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } on AppException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Failed to update profile. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
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
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
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
                      _buildControllerField(label: 'Full name', controller: _nameController),
                      _buildInputField(label: 'Nick name', initialValue: ''),
                      _buildControllerField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
                      _buildPhoneField(),
                      Row(
                        children: [
                          Expanded(child: _buildInputField(label: 'Country', initialValue: 'Pakistan', isDropdown: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInputField(label: 'Genre', initialValue: '')),
                        ],
                      ),
                      _buildInputField(label: 'Address', initialValue: ''),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC62828),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            'SUBMIT',
                            style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildControllerField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: _inputStyle,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: _labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: const Color(0xFFF6F9FF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2196F3))),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required String initialValue, bool isDropdown = false}) {
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isDropdown ? const Icon(Icons.arrow_drop_down, color: Colors.grey) : null,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2196F3))),
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: _phoneController,
        style: _inputStyle,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Phone number',
          labelStyle: _labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: const Color(0xFFF6F9FF),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: Color(0xFF135D1D), shape: BoxShape.circle),
                  child: const Center(child: Text('🇵🇰', style: TextStyle(fontSize: 16))),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2196F3))),
        ),
      ),
    );
  }
}
