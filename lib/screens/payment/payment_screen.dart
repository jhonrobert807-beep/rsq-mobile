import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ride_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/ride_api.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedIndex = 0;
  bool _isProcessing = false;
  bool _isSuccess = false;
  String _transactionId = '';
  bool _initialized = false;

  static const _methods = [
    {'label': 'Cash', 'icon': Icons.money, 'color': Color(0xFF2E7D32)},
    {'label': 'JazzCash', 'icon': Icons.phone_android, 'color': Color(0xFFE53935)},
    {'label': 'EasyPaisa', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF00897B)},
    {'label': 'Visa', 'icon': Icons.credit_card, 'color': Color(0xFF1A237E)},
    {'label': 'MasterCard', 'icon': Icons.credit_card, 'color': Color(0xFFB71C1C)},
    {'label': 'Bank Transfer', 'icon': Icons.account_balance, 'color': Color(0xFF37474F)},
    {'label': 'PayPak', 'icon': Icons.credit_card, 'color': Color(0xFF1B5E20)},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final saved = context.read<RideProvider>().selectedPaymentMethod;
      if (saved != null) {
        final idx = _methods.indexWhere((m) => m['label'] == saved);
        if (idx != -1) _selectedIndex = idx;
      }
      _initialized = true;
    }
  }

  String _generateTxnId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return 'TXN-' + List.generate(10, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _pay() async {
    final ride = context.read<RideProvider>().activeRide;
    if (ride == null) return;

    setState(() => _isProcessing = true);

    // Fake 2 second processing delay
    await Future.delayed(const Duration(seconds: 2));

    final txnId = _generateTxnId();
    final method = _methods[_selectedIndex]['label'] as String;
    final apiMethod = method == 'Cash' ? 'CASH' : 'WALLET';

    try {
      await RideApi.updatePayment(ride.id, paymentStatus: 'PAID', paymentMethod: apiMethod);
    } catch (_) {
      // Still show success for demo — payment is dummy
    }

    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
        _transactionId = txnId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideProvider>().activeRide;
    final fare = ride?.formattedCost ?? 'PKR --';

    if (_isSuccess) return _buildSuccessScreen(fare);
    if (_isProcessing) return _buildProcessingScreen();
    return _buildSelectScreen(fare);
  }

  Widget _buildSelectScreen(String fare) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFCDD2)),
              ),
              child: Column(
                children: [
                  const Text('Total Amount', style: TextStyle(color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(fare, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFD42C2C))),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(_methods.length, (i) {
              final m = _methods[i];
              final isSelected = _selectedIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFFF5F5) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFD42C2C) : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (m['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(m['icon'] as IconData, color: m['color'] as Color, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(m['label'] as String,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected ? const Color(0xFFD42C2C) : Colors.transparent,
                          border: Border.all(
                            color: isSelected ? const Color(0xFFD42C2C) : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, color: Colors.white, size: 13)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _pay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD42C2C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: const Text('Confirm & Pay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingScreen() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFD42C2C), strokeWidth: 3),
            SizedBox(height: 24),
            Text('Processing Payment...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text('Please wait', style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(String fare) {
    final method = _methods[_selectedIndex]['label'] as String;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 60),
              ),
              const SizedBox(height: 24),
              const Text('Payment Successful!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Your ride has been paid via $method',
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Amount Paid', fare),
                    const Divider(height: 24),
                    _buildReceiptRow('Payment Method', method),
                    const Divider(height: 24),
                    _buildReceiptRow('Transaction ID', _transactionId),
                    const Divider(height: 24),
                    _buildReceiptRow('Status', 'PAID', valueColor: const Color(0xFF2E7D32)),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<RideProvider>().clearActiveRide();
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD42C2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Back to Home',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: valueColor ?? Colors.black)),
      ],
    );
  }
}
