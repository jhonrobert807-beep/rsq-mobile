import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../providers/ride_provider.dart';

class SelectPaymentMethodScreen extends StatefulWidget {
  const SelectPaymentMethodScreen({super.key});

  @override
  State<SelectPaymentMethodScreen> createState() => _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  int _selectedPayment = 0;
  double _pickupLat = 24.8607;
  double _pickupLng = 67.0011;
  double? _destinationLat;
  double? _destinationLng;
  String _ambulanceType = 'BASIC';
  bool _initialized = false;

  static const _paymentMethods = [
    {'label': 'Cash', 'detail': 'Pay on delivery', 'asset': null, 'method': 'CASH', 'icon': Icons.money},
    {'label': 'JazzCash', 'detail': '', 'asset': null, 'method': 'WALLET', 'icon': Icons.phone_android},
    {'label': 'EasyPaisa', 'detail': '', 'asset': null, 'method': 'WALLET', 'icon': Icons.account_balance_wallet},
    {'label': 'Visa', 'detail': '1024', 'asset': 'assets/images/visa.png', 'method': 'CARD', 'icon': null},
    {'label': 'MasterCard', 'detail': '4223', 'asset': 'assets/images/mastercard.png', 'method': 'CARD', 'icon': null},
    {'label': 'Bank Transfer', 'detail': '', 'asset': null, 'method': 'WALLET', 'icon': Icons.account_balance},
    {'label': 'PayPak', 'detail': '', 'asset': 'assets/images/paypak.png', 'method': 'CASH', 'icon': null},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _pickupLat = (args['pickupLat'] as num?)?.toDouble() ?? 24.8607;
        _pickupLng = (args['pickupLng'] as num?)?.toDouble() ?? 67.0011;
        _destinationLat = (args['destinationLat'] as num?)?.toDouble();
        _destinationLng = (args['destinationLng'] as num?)?.toDouble();
        _ambulanceType = args['ambulanceType'] as String? ?? 'BASIC';
      }
      _initialized = true;
    }
  }

  Future<void> _book() async {
    final selectedLabel = _paymentMethods[_selectedPayment]['label'] as String;
    context.read<RideProvider>().setPaymentMethod(selectedLabel);

    final error = await context.read<RideProvider>().createRide(
      ambulanceType: _ambulanceType,
      pickupLat: _pickupLat,
      pickupLng: _pickupLng,
      destinationLat: _destinationLat,
      destinationLng: _destinationLng,
    );

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red[700]),
      );
      return;
    }
    Navigator.pushReplacementNamed(context, AppRoutes.userRideDetails);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light, statusBarColor: Colors.white),
    );

    final isLoading = context.watch<RideProvider>().isLoading;
    final priceLabel = _ambulanceType == 'WITH_DOCTOR' ? 'Rs 100/km' : 'Rs 50/km';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: const Text(
          'Select payment method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto'),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Payment method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto')),
                  Text(priceLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto')),
                ],
              ),
              const SizedBox(height: 24),

              ...List.generate(_paymentMethods.length, (index) {
                final pm = _paymentMethods[index];
                final isSelected = _selectedPayment == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPayment = index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue[50] : Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          pm['asset'] != null
                              ? Image.asset(pm['asset']! as String, width: 32, height: 24)
                              : Icon(pm['icon'] as IconData? ?? Icons.payment, color: Colors.grey[600], size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pm['label']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Roboto')),
                                if (pm['detail']!.isNotEmpty)
                                  Text(pm['detail']!, style: TextStyle(fontSize: 14, color: Colors.grey[600], fontFamily: 'Roboto')),
                              ],
                            ),
                          ),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.green : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(color: isSelected ? Colors.green : Colors.grey[300]!),
                            ),
                            child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),

              Center(
                child: ElevatedButton(
                  onPressed: isLoading ? null : _book,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirm Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Roboto')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
