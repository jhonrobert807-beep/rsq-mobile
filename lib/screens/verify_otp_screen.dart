import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/errors/app_exception.dart';
import '../providers/auth_provider.dart';
import '../routes/app_routes.dart';
import '../services/auth_api.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(5, (_) => FocusNode());
  bool _isLoading = false;
  String _identifier = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) _identifier = args['identifier'] as String? ?? '';
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (mounted) _otpFocusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var c in _otpControllers) { c.dispose(); }
    for (var f in _otpFocusNodes) { f.dispose(); }
    super.dispose();
  }

  void _handleOtpInput(int index, String value) {
    // If pasted value has multiple digits, distribute them
    if (value.length > 1) {
      for (int i = 0; i < value.length && index + i < 5; i++) {
        _otpControllers[index + i].text = value[i];
      }
      // Move focus to next empty field or last field
      if (index + value.length < 5) {
        _otpFocusNodes[index + value.length].requestFocus();
      }
      return;
    }

    // Single digit input
    if (value.isNotEmpty && index < 4) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  void _navigateByRole(String role) {
    switch (role) {
      case 'DRIVER':
        Navigator.pushReplacementNamed(context, AppRoutes.driverHomeScreen);
        break;
      case 'PARAMEDIC':
        Navigator.pushReplacementNamed(context, AppRoutes.paramedicHomeScreen);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _verify() async {
    final code = _otpCode;
    if (code.length < 5) {
      _showError('Please enter the complete 5-digit OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final verified = await AuthApi.verifyOtp(_identifier, code);
      if (!mounted) return;
      if (verified) {
        final role = context.read<AuthProvider>().currentUser?.role ?? 'USER';
        _navigateByRole(role);
      } else {
        _showError('Invalid OTP. Please try again.');
      }
    } on AppException catch (e) {
      if (mounted) _showError(e.message);
    } catch (_) {
      if (mounted) _showError('Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    if (_identifier.isEmpty) return;
    try {
      await AuthApi.sendOtp(_identifier);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP resent successfully')),
        );
      }
    } catch (_) {
      if (mounted) _showError('Failed to resend OTP');
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 16),
                      const SizedBox(width: 4),
                      Text('Back', style: TextStyle(color: Colors.black, fontSize: 14, fontFamily: 'Roboto', fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),

              Container(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Phone verification',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black, fontFamily: 'Roboto', height: 1.3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _identifier.isNotEmpty ? 'Enter the OTP sent to $_identifier' : 'Enter an OTP code',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600], fontFamily: 'Roboto'),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) {
                  return SizedBox(
                    width: 48,
                    height: 48,
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _handleOtpInput(index, value),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD42C2C), width: 2)),
                        hintText: '',
                        hintStyle: const TextStyle(color: Colors.transparent),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),

              Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: _resend,
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 12, fontFamily: 'Roboto'),
                      children: [
                        TextSpan(text: "Didn't receive code? ", style: TextStyle(color: Colors.grey[600])),
                        const TextSpan(
                          text: "Resend again",
                          style: TextStyle(color: Color(0xFFD42C2C), decoration: TextDecoration.underline, decorationThickness: 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD42C2C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: _isLoading ? null : _verify,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Roboto'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
