import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class SelectVehicleScreen extends StatefulWidget {
  const SelectVehicleScreen({super.key});

  @override
  State<SelectVehicleScreen> createState() => _SelectVehicleScreenState();
}

class _SelectVehicleScreenState extends State<SelectVehicleScreen> {
  String _selectedType = 'WITH_DOCTOR';
  double _pickupLat = 24.8607;
  double _pickupLng = 67.0011;
  String _pickupLabel = 'Current Location';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _pickupLat = (args['pickupLat'] as num?)?.toDouble() ?? 24.8607;
        _pickupLng = (args['pickupLng'] as num?)?.toDouble() ?? 67.0011;
        _pickupLabel = args['pickupLabel'] as String? ?? 'Current Location';
      }
      _initialized = true;
    }
  }

  void _goToFareSelection() {
    Navigator.pushNamed(
      context,
      AppRoutes.fareSelection,
      arguments: {
        'pickupLat': _pickupLat,
        'pickupLng': _pickupLng,
        'pickupLabel': _pickupLabel,
        'ambulanceType': _selectedType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark, statusBarColor: Colors.transparent),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/select-vehical.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),

                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: _buildRouteInfoCard(),
                  ),

                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: _buildCircleIconButton(Icons.arrow_back, () => Navigator.pop(context)),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),

                  GestureDetector(
                    onTap: () => setState(() => _selectedType = 'WITH_DOCTOR'),
                    child: _buildVehicleTile(
                      title: 'Ambulance with Consultant',
                      subtitle: 'PKR 500 base + PKR 100/km',
                      price: 'PKR 100/km',
                      isSelected: _selectedType == 'WITH_DOCTOR',
                      iconPath: 'assets/images/doctor-icon.png',
                    ),
                  ),

                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () => setState(() => _selectedType = 'BASIC'),
                    child: _buildVehicleTile(
                      title: 'Only Ambulance',
                      subtitle: 'PKR 200 base + PKR 50/km',
                      price: 'PKR 50/km',
                      isSelected: _selectedType == 'BASIC',
                      iconPath: 'assets/images/ambulance.png',
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      _buildPaymentMethod(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _goToFareSelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Select an Ambulance',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Roboto'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildCircleIconButton(Icons.tune, () {}, size: 48, iconSize: 20),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/visa.png', width: 32),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
      ],
    );
  }

  Widget _buildRouteInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          _buildRouteLine(Colors.green, _pickupLabel),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Divider(indent: 12, endIndent: 12, height: 1),
          ),
          _buildRouteLine(Colors.red, 'Select destination'),
        ],
      ),
    );
  }

  Widget _buildRouteLine(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, fontFamily: 'Roboto'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTile({
    required String title,
    required String subtitle,
    required String price,
    required bool isSelected,
    required String iconPath,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? const Color(0xFFE53935) : Colors.grey[200]!, width: isSelected ? 2 : 1),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Roboto')),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontFamily: 'Roboto')),
              ],
            ),
          ),
          Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Roboto')),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, VoidCallback onTap, {double size = 45, double iconSize = 20}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(size),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: iconSize, color: Colors.black),
      ),
    );
  }
}
