import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/driver_api.dart';

class EditDriverProfileScreen extends StatefulWidget {
  const EditDriverProfileScreen({super.key});

  @override
  State<EditDriverProfileScreen> createState() => _EditDriverProfileScreenState();
}

class _EditDriverProfileScreenState extends State<EditDriverProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _vehicleOwnerController;
  late final TextEditingController _registrationNumberController;
  late final TextEditingController _vehicleTypeController;
  late final TextEditingController _countryController;
  late final TextEditingController _genderController;
  late final TextEditingController _vehicleCityController;
  bool _isLoading = false;
  bool _initialized = false;

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'Roboto',
    color: Color(0xFF9E9E9E),
    fontSize: 12,
  );

  static const TextStyle _inputStyle = TextStyle(
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
      _nameController = TextEditingController(text: user?.name ?? '');
      _emailController = TextEditingController(text: user?.email ?? '');
      _phoneController = TextEditingController(text: user?.phone ?? '');
      _vehicleOwnerController = TextEditingController(text: user?.name ?? '');
      _registrationNumberController = TextEditingController(text: '');
      _vehicleTypeController = TextEditingController(text: 'Express Ambulance');
      _countryController = TextEditingController(text: 'Pakistan');
      _genderController = TextEditingController(text: 'Male');
      _vehicleCityController = TextEditingController(text: 'Karachi, Pakistan');
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _vehicleOwnerController.dispose();
    _registrationNumberController.dispose();
    _vehicleTypeController.dispose();
    _countryController.dispose();
    _genderController.dispose();
    _vehicleCityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final userId = context.read<AuthProvider>().currentUser?.id;
    if (userId == null) return;

    final vehicleOwner = _vehicleOwnerController.text.trim();
    final registrationNumber = _registrationNumberController.text.trim();
    final vehicleType = _vehicleTypeController.text.trim();
    final vehicleCity = _vehicleCityController.text.trim();
    final gender = _genderController.text.trim();
    final country = _countryController.text.trim();

    setState(() => _isLoading = true);
    try {
      late String profileId;

      // Try to get existing driver profile
      try {
        final driverProfile = await DriverApi.getProfileByUserId(userId);
        profileId = driverProfile.id;
      } catch (e) {
        // Profile doesn't exist, create one
        final newProfile = await DriverApi.createProfile(
          userId: userId,
          licenseNumber: '',
          vehicleType: vehicleType,
        );
        profileId = newProfile.id;
      }

      // Update driver profile with vehicle details
      await DriverApi.updateProfile(
        profileId,
        vehicleOwner: vehicleOwner.isNotEmpty ? vehicleOwner : null,
        vehicleRegistrationNumber: registrationNumber.isNotEmpty ? registrationNumber : null,
        vehicleType: vehicleType.isNotEmpty ? vehicleType : null,
        vehicleCity: vehicleCity.isNotEmpty ? vehicleCity : null,
        gender: gender.isNotEmpty ? gender : null,
        country: country.isNotEmpty ? country : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully'), backgroundColor: Colors.green),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.driverProfileScreen);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.driverProfileScreen),
        ),
        title: const Text('Edit profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildField(label: 'Vehicle Owner', controller: _vehicleOwnerController),
                      _buildField(label: 'Vehicle Registration Number', controller: _registrationNumberController),
                      _buildField(label: 'Vehicle Type', controller: _vehicleTypeController),
                      _buildPhoneField(label: 'Phone number', controller: _phoneController),
                      Row(
                        children: [
                          Expanded(child: _buildField(label: 'Country', controller: _countryController, isDropdown: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildField(label: 'Gender', controller: _genderController, isDropdown: true)),
                        ],
                      ),
                      _buildField(label: 'Vehicle Registered City', controller: _vehicleCityController),
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
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('SUBMIT', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isDropdown = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: _inputStyle,
        readOnly: isDropdown,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: _labelStyle,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          filled: true,
          fillColor: const Color(0xFFF6F9FF),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2196F3))),
          suffixIcon: isDropdown ? const Icon(Icons.arrow_drop_down, color: Colors.grey) : null,
        ),
      ),
    );
  }

  Widget _buildPhoneField({required String label, required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
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
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('🇵🇰'),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
