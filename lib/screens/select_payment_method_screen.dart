import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../providers/ride_provider.dart';
import '../services/card_store.dart';

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
  bool _isStandaloneMode = false; // true when opened from sidebar, not booking flow

  static const _staticMethods = [
    {'label': 'Cash', 'detail': 'Pay on delivery', 'method': 'CASH', 'icon': Icons.money},
    {'label': 'JazzCash', 'detail': '', 'method': 'WALLET', 'icon': Icons.phone_android},
    {'label': 'EasyPaisa', 'detail': '', 'method': 'WALLET', 'icon': Icons.account_balance_wallet},
    {'label': 'Credit/Debit Card', 'detail': 'Visa, MasterCard accepted', 'method': 'CARD', 'icon': Icons.credit_card},
    {'label': 'Bank Transfer', 'detail': '', 'method': 'WALLET', 'icon': Icons.account_balance},
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
      } else {
        _isStandaloneMode = true;
      }
      _initialized = true;
    }
  }

  List<Map<String, dynamic>> _buildAllMethods() {
    final saved = CardStore.instance.cards;
    return [
      ..._staticMethods,
      ...saved.map((c) => {
        'label': c.maskedNumber,
        'detail': '${c.holderName}  •  ${c.expiry}',
        'method': 'CARD',
        'icon': Icons.credit_card,
      }),
    ];
  }

  Future<void> _book() async {
    final allMethods = _buildAllMethods();
    final selectedLabel = allMethods[_selectedPayment]['label'] as String;
    context.read<RideProvider>().setPaymentMethod(selectedLabel);

    if (_isStandaloneMode) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$selectedLabel set as default payment method'),
          backgroundColor: Colors.green[700],
        ),
      );
      Navigator.pop(context);
      return;
    }

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
                  if (!_isStandaloneMode)
                    Text(priceLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Roboto')),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ...List.generate(_buildAllMethods().length, (index) {
                        final pm = _buildAllMethods()[index];
                        final isSelected = _selectedPayment == index;
                        final isSavedCard = index >= _staticMethods.length;
                        final cardIndex = index - _staticMethods.length;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPayment = index),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.blue[50] : Colors.white,
                                border: Border.all(color: isSelected ? Colors.blue.shade300 : Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(pm['icon'] as IconData? ?? Icons.payment, color: Colors.grey[600], size: 24),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(pm['label'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Roboto')),
                                        if ((pm['detail'] as String).isNotEmpty)
                                          Text(pm['detail'] as String, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: 'Roboto')),
                                      ],
                                    ),
                                  ),
                                  if (isSavedCard)
                                    GestureDetector(
                                      onTap: () async {
                                        await CardStore.instance.removeCard(cardIndex);
                                        if (_selectedPayment >= _buildAllMethods().length) {
                                          _selectedPayment = 0;
                                        }
                                        setState(() {});
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8),
                                        child: Icon(Icons.delete_outline, color: Colors.red[400], size: 20),
                                      ),
                                    )
                                  else
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
                      // Add Card button
                      GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(context, AppRoutes.cardFlowScreen);
                          setState(() {}); // refresh to show newly added card
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline, color: const Color(0xFFC62828), size: 20),
                              const SizedBox(width: 8),
                              const Text('Add New Card', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Roboto', color: Color(0xFFC62828))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _book,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          _isStandaloneMode ? 'Save Payment Method' : 'Confirm Payment Method',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Roboto'),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
