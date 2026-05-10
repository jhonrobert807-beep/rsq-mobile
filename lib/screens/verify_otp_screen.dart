// import 'package:flutter/material.dart';

// class VerifyOtpScreen extends StatefulWidget {
//   const VerifyOtpScreen({super.key});

//   @override
//   State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
// }

// class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
//   final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
//   final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

//   @override
//   void initState() {
//     super.initState();
//     // Auto-focus first OTP field
//     Future.delayed(Duration.zero, () {
//       _otpFocusNodes[0].requestFocus();
//     });
//   }

//   @override
//   void dispose() {
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var node in _otpFocusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }

//   void _handleOtpInput(int index, String value) {
//     if (value.isNotEmpty && index < 5) {
//       _otpFocusNodes[index + 1].requestFocus();
//     } else if (value.isEmpty && index > 0) {
//       _otpFocusNodes[index - 1].requestFocus();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start, // Keep this for the Back button
//             children: [
//               // Back Button (Figma Style)
//               Padding(
//                 padding: const EdgeInsets.only(top: 12.0, bottom: 24.0),
//                 child: GestureDetector(
//                   onTap: () => Navigator.maybePop(context),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.arrow_back_ios_new,
//                         color: Colors.black,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         'Back',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 14,
//                           fontFamily: 'Roboto',
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),


//               // Title & Subtitle (Now Centered)
//               Container(
//                 alignment: Alignment.center, // This centers the children horizontally
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center, // Ensure text inside column is also centered
//                   children: [
//                     // Title (Figma Style)
//                     Text(
//                       'Phone verification',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black,
//                         fontFamily: 'Roboto',
//                         height: 1.3,
//                       ),
//                     ),
//                     const SizedBox(height: 4), // Tighter spacing

//                     // Subtitle (Figma Style)
//                     Text(
//                       'Enter an OTP code', // Updated text to match screenshot
//                       style: TextStyle(
//                         fontSize: 13,
//                         color: Colors.grey[600],
//                         fontFamily: 'Roboto',
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // OTP Input Fields (Pixel Perfect)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(5, (index) {
//                   return SizedBox(
//                     width: 48,
//                     height: 48, // Match Figma's square box height
//                     child: TextField(
//                       controller: _otpControllers[index],
//                       focusNode: _otpFocusNodes[index],
//                       textAlign: TextAlign.center,
//                       maxLength: 1,
//                       keyboardType: TextInputType.number,
//                       onChanged: (value) => _handleOtpInput(index, value),
//                       decoration: InputDecoration(
//                         counterText: '',
//                         contentPadding: EdgeInsets.zero, // Remove internal padding for pixel-perfect look
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(6),
//                           borderSide: BorderSide(
//                             color: Colors.grey[300]!, // Light grey border
//                             width: 1,
//                           ),
//                         ),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(6),
//                           borderSide: BorderSide(
//                             color: Colors.grey[300]!, // Light grey border
//                             width: 1,
//                           ),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(6),
//                           borderSide: const BorderSide(
//                             color: Color(0xFFD42C2C), // Red when focused
//                             width: 2,
//                           ),
//                         ),
//                         // Optional: Add a hint text style to make it look empty
//                         hintText: '',
//                         hintStyle: TextStyle(color: Colors.transparent),
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//               const SizedBox(height: 18),

//               // Resend Link (Pixel Perfect - Split Text & Centered)
//               // Wrap RichText in a Container with alignment set to center
//               Container(
//                 alignment: Alignment.center, // ← THIS IS THE KEY CHANGE
//                 child: GestureDetector(
//                   onTap: () {
//                     // Handle resend logic
//                   },
//                   child: RichText(
//                     text: TextSpan(
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontFamily: 'Roboto',
//                       ),
//                       children: [
//                         TextSpan(
//                           text: "Didn't receive code? ",
//                           style: TextStyle(
//                             color: Colors.grey[600], // Dark grey for the first part
//                           ),
//                         ),
//                         TextSpan(
//                           text: "Resend again",
//                           style: TextStyle(
//                             color: const Color(0xFFD42C2C), // Red for the link part
//                             decoration: TextDecoration.underline,
//                             decorationThickness: 1,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Verify Button (Pixel Perfect)
//               SizedBox(
//                 height: 44, // Adjusted from 48 to match Figma's button height
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFD42C2C),
//                     padding: EdgeInsets.zero, // Remove padding, use fixed height
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(6), // Match Figma corner radius
//                     ),
//                     elevation: 0,
//                   ),
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/set_password');
//                   },
//                   child: const Text(
//                     'Verify',
//                     style: TextStyle(
//                       fontSize: 16, // Increased for better visibility
//                       fontWeight: FontWeight.bold, // Bold as per Figma
//                       color: Colors.white,
//                       fontFamily: 'Roboto',
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  // Updated to 5 controllers & focus nodes
  final List<TextEditingController> _otpControllers = List.generate(5, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(5, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _otpFocusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) controller.dispose();
    for (var node in _otpFocusNodes) node.dispose();
    super.dispose();
  }

  void _handleOtpInput(int index, String value) {
    if (value.isNotEmpty && index < 4) { // index < 4 → max index = 4 (5th field)
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
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
                      Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✅ Title & Subtitle — Centered
              Container(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Phone verification',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter an OTP code',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16), // ✅ Tightened: was 24 → now 16

              // ✅ OTP Fields — 5 boxes
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
                          borderSide: const BorderSide(color: Color(0xFFD42C2C), width: 2),
                        ),
                        hintText: '',
                        hintStyle: TextStyle(color: Colors.transparent),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),

              // ✅ Resend Link — Centered & Partially Colored
              Container(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    // TODO: Add resend logic
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 12, fontFamily: 'Roboto'),
                      children: [
                        TextSpan(
                          text: "Didn't receive code? ",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextSpan(
                          text: "Resend again",
                          style: TextStyle(
                            color: const Color(0xFFD42C2C),
                            decoration: TextDecoration.underline,
                            decorationThickness: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ✅ Verify Button
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
                  onPressed: () {
                    Navigator.pushNamed(context, '/set_password');
                  },
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
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
}