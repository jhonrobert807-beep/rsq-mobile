import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../models/ambulance_model.dart';
import '../services/dispatch_api.dart';

class FareSelectionScreen extends StatefulWidget {
  const FareSelectionScreen({super.key});

  @override
  State<FareSelectionScreen> createState() => _FareSelectionScreenState();
}

class _FareSelectionScreenState extends State<FareSelectionScreen> {
  double _pickupLat = 24.8607;
  double _pickupLng = 67.0011;
  String _pickupLabel = 'Current Location';
  String _ambulanceType = 'BASIC';
  AmbulanceModel? _nearestAmbulance;
  bool _loadingAmbulance = true;
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
        _ambulanceType = args['ambulanceType'] as String? ?? 'BASIC';
      }
      _initialized = true;
      _loadNearest();
    }
  }

  Future<void> _loadNearest() async {
    setState(() => _loadingAmbulance = true);
    try {
      final results = await DispatchApi.findNearest(
        lat: _pickupLat,
        lng: _pickupLng,
        type: _ambulanceType,
        radiusKm: 10,
      );
      if (mounted && results.isNotEmpty) {
        setState(() => _nearestAmbulance = results.first);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingAmbulance = false);
    }
  }

  void _goToPayment() {
    Navigator.pushNamed(
      context,
      AppRoutes.paymentMethodScreen,
      arguments: {
        'pickupLat': _pickupLat,
        'pickupLng': _pickupLng,
        'ambulanceType': _ambulanceType,
        'ambulanceId': _nearestAmbulance?.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark, statusBarColor: Colors.transparent),
    );

    final pricePerKm = _ambulanceType == 'WITH_DOCTOR' ? 'PKR 100/km' : 'PKR 50/km';
    final baseFare = _ambulanceType == 'WITH_DOCTOR' ? 500 : 200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/fare-select.png', fit: BoxFit.cover),
          ),

          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  _buildSimpleRouteRow(Colors.green, _pickupLabel),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider(height: 1, thickness: 0.5)),
                  _buildSimpleRouteRow(Colors.red, 'Select destination'),
                ],
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.close, size: 22),
                        ),
                        const Expanded(
                          child: Center(
                            child: Text('Ambulance is on the way', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 22),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Text('PKR ', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text(
                            '$baseFare base + $pricePerKm',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red[700]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(Icons.local_hospital, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        _loadingAmbulance
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(
                                _nearestAmbulance != null
                                    ? 'Reg: ${_nearestAmbulance!.registrationNumber ?? 'Unassigned'} • ${_nearestAmbulance!.displayEta} away'
                                    : 'No ambulance available nearby',
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildSelectionTile(Icons.payments_outlined, 'Cash', hasArrow: true),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          _buildSimpleRouteRow(Colors.green, _pickupLabel, isBold: true),
                          const SizedBox(height: 12),
                          _buildSimpleRouteRow(Colors.red, 'Destination'),
                        ],
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
                              onPressed: _nearestAmbulance == null && !_loadingAmbulance ? null : _goToPayment,
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
            ),
          ),
        ],
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

  Widget _buildSimpleRouteRow(Color color, String text, {bool isBold = false}) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionTile(IconData icon, String title, {bool hasArrow = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const Spacer(),
          if (hasArrow) const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}
