import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import '../providers/auth_provider.dart';
import '../services/google_sign_in_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreeTerms = false;
  String _role = 'USER';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) _role = args['role'] as String? ?? 'USER';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final rawPhone = _phoneController.text.trim();
    final localPhone = rawPhone.startsWith('0') ? rawPhone.substring(1) : rawPhone;
    final phone = localPhone.isNotEmpty ? '+92$localPhone' : '';
    final password = _passwordController.text;

    if (name.length < 2) {
      _showError('Name must be at least 2 characters');
      return;
    }
    if (email.isEmpty && rawPhone.isEmpty) {
      _showError('Please enter your email or phone number');
      return;
    }
    if (rawPhone.isNotEmpty && !RegExp(r'^3\d{9}$').hasMatch(localPhone)) {
      _showError('Please enter a valid Pakistani mobile number');
      return;
    }
    if (password.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    if (!_agreeTerms) {
      _showError('Please agree to the Terms of Service');
      return;
    }

    final error = await context.read<AuthProvider>().register(
      name: name,
      email: email.isNotEmpty ? email : null,
      phone: phone.isNotEmpty ? phone : null,
      password: password,
      role: _role,
    );

    if (!mounted) return;
    if (error != null) {
      _showError(error);
      return;
    }

    // After signup, redirect to OTP verification with email/phone
    final identifier = email.isNotEmpty ? email : phone;
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.verifyOtp,
      arguments: {'identifier': identifier, 'isSignup': true},
    );
  }

  Future<void> _signUpWithGoogle() async {
    final account = await GoogleSignInService.signIn();
    if (account == null) {
      _showError('Google sign-up failed');
      return;
    }

    final tokenResult = await GoogleSignInService.getToken();
    if (tokenResult == null) {
      _showError('Failed to get Google token');
      return;
    }

    if (!mounted) return;
    final error = await context.read<AuthProvider>().googleLogin(
      idToken: tokenResult.isAccessToken ? null : tokenResult.token,
      accessToken: tokenResult.isAccessToken ? tokenResult.token : null,
      role: _role,
    );

    if (!mounted) return;
    if (error != null) {
      _showError(error);
      return;
    }

    final role = context.read<AuthProvider>().currentUser?.role ?? 'USER';
    switch (role) {
      case 'DRIVER':
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.driverHomeScreen, (_) => false);
        break;
      case 'PARAMEDIC':
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.paramedicHomeScreen, (_) => false);
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                      const SizedBox(width: 4),
                      Text('Back', style: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Roboto')),
                    ],
                  ),
                ),
              ),

              Text(
                'Sign up with your email or phone number',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: 'Roboto'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD42C2C), width: 1)),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: 'Roboto'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD42C2C), width: 1)),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Your mobile number',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: 'Roboto'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD42C2C), width: 1)),
                  prefixIcon: SizedBox(
                    width: 70,
                    child: ClipRect(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2, right: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(right: BorderSide(color: Colors.grey[300]!, width: 1)),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/images/pk_flag.png', width: 14, height: 10, fit: BoxFit.contain),
                                    const SizedBox(width: 2),
                                    Icon(Icons.expand_more, color: Colors.grey[500], size: 14),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Text('+92', style: TextStyle(fontSize: 12, color: Colors.black, fontFamily: 'Roboto'), maxLines: 1, overflow: TextOverflow.fade),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints.tightFor(width: 70, height: 48),
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Password (min. 8 characters)',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontFamily: 'Roboto'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey[300]!, width: 1)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFD42C2C), width: 1)),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _agreeTerms = !_agreeTerms),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _agreeTerms ? const Color(0xFFD42C2C) : Colors.grey[300]!, width: 2),
                        color: _agreeTerms ? const Color(0xFFD42C2C) : Colors.white,
                      ),
                      child: Center(child: _agreeTerms ? const Icon(Icons.check, color: Colors.white, size: 14) : null),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13, color: Colors.grey[700], fontFamily: 'Roboto'),
                        children: [
                          const TextSpan(text: 'By signing up, you agree to the '),
                          const TextSpan(text: 'Terms of service', style: TextStyle(color: Color(0xFFD42C2C), fontWeight: FontWeight.w500)),
                          const TextSpan(text: ' and '),
                          const TextSpan(text: 'Privacy policy.', style: TextStyle(color: Color(0xFFD42C2C), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD42C2C),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : _signup,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Roboto'),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontFamily: 'Roboto')),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: Colors.grey[300]!, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _signUpWithGoogle(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/gmail.png', width: 20, height: 20),
                      const SizedBox(width: 12),
                      const Text('Sign up with Google', style: TextStyle(fontSize: 14, color: Colors.black87, fontFamily: 'Roboto', fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], fontFamily: 'Roboto'),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Sign in',
                        style: const TextStyle(color: Color(0xFFD42C2C), fontWeight: FontWeight.bold),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, AppRoutes.login, arguments: {'role': _role});
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
