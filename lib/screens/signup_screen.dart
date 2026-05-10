import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // Back Button (Custom PNG)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),
                child: GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new, // ← iOS-style thin arrow
                        color: Colors.black,
                        size: 18, // Slightly smaller for visual balance
                      ),
                      const SizedBox(width: 4), // Tighter spacing (iOS standard)
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              

              // ✅ Title — Tighter spacing
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

              // ✅ Name Field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFFD42C2C),
                      width: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ✅ Email Field
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFFD42C2C),
                      width: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ✅ Phone Field — Overflow-Free & Pixel-Perfect
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Your mobile number',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontFamily: 'Roboto',
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFD42C2C), width: 1),
                  ),
                  prefixIcon: SizedBox(
                    width: 70,
                    child: ClipRect(
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 2, right: 2), // ← Minimize padding
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Flag + Dropdown Section
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey[300]!, width: 1),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 2), // ← Reduced
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      'assets/images/pk_flag.png',
                                      width: 14,   // ↓ Further reduced
                                      height: 10,  // ↓ Further reduced
                                      fit: BoxFit.contain,
                                    ),
                                    const SizedBox(width: 2), // ↓ Reduced
                                    Icon(
                                      Icons.expand_more,
                                      color: Colors.grey[500],
                                      size: 14, // ↓ Further reduced
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 2), // ↓ Reduced from 4
                              Text(
                                '+92',
                                style: const TextStyle(
                                  fontSize: 12, // ↓ Reduced font size
                                  color: Colors.black,
                                  fontFamily: 'Roboto',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ),
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

              
              // ✅ Gender Dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: InputBorder.none,
                    hintText: 'Gender',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  value: null,
                  items: ['Male', 'Female', 'Other']
                      .map((e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {},
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontFamily: 'Roboto',
                  ),
                  iconSize: 20,
                ),
              ),
              const SizedBox(height: 16),

              // ✅ Terms Checkbox — Circular Style with Red Checkmark
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _agreeTerms = !_agreeTerms;
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _agreeTerms ? const Color(0xFFD42C2C) : Colors.grey[300]!,
                          width: 2,
                        ),
                        color: _agreeTerms ? const Color(0xFFD42C2C) : Colors.white,
                      ),
                      child: Center(
                        child: _agreeTerms
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 14,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontFamily: 'Roboto',
                        ),
                        children: [
                          const TextSpan(text: 'By signing up, you agree to the '),
                          TextSpan(
                            text: 'Terms of service',
                            style: const TextStyle(
                              color: Color(0xFFD42C2C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy policy.',
                            style: const TextStyle(
                              color: Color(0xFFD42C2C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ✅ Sign Up Button — Pixel Perfect
              SizedBox(
                height: 44,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD42C2C),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/send_verification');
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Divider & "or"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 16),
              
              // Gmail Button (with PNG icon)
              SizedBox(
                height: 50, // Match Figma button height
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.login);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/gmail.png',
                        width: 20,
                        height: 20,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Sign up with Gmail',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ✅ Sign In Link — Centered & Navigates to /sign_in
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontFamily: 'Roboto',
                    ),
                    children: [
                      const TextSpan(text: 'Already have an account? '),
                      TextSpan(
                        text: 'Sign in',
                        style: const TextStyle(
                          color: Color(0xFFD42C2C),
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, AppRoutes.login);
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