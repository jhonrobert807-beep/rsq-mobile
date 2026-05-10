import 'package:flutter/material.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';

class CardFlowScreen extends StatefulWidget {
  const CardFlowScreen({super.key});

  @override
  State<CardFlowScreen> createState() => _CardFlowScreenState();
}

class _CardFlowScreenState extends State<CardFlowScreen> {
  // 0: Form (Manual + Submit), 1: Scanner UI, 2: Preview Screen
  int _viewIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _viewIndex == 1 ? null : _buildAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentView(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
        onPressed: () {
          if (_viewIndex > 0) {
            setState(() => _viewIndex = 0);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        },
      ),
      title: const Text(
        'Add card',
        style: TextStyle(
          fontFamily: 'Roboto', 
          color: Colors.black, 
          fontWeight: FontWeight.bold, 
          fontSize: 18
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    if (_viewIndex == 0) return _buildManualForm();
    if (_viewIndex == 1) return _buildScannerUI();
    return _buildCardPreview();
  }

  // --- SCREEN 1: MANUAL FORM WITH SUBMIT BUTTON ---
  Widget _buildManualForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _inputLabel("CARD NUMBER"),
          _textField("Enter card number"),
          const SizedBox(height: 20),
          _inputLabel("CARD HOLDER NAME"),
          _textField("Enter card holder name"),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [_inputLabel("EXP. DATE"), _textField("MM/YY")]
                )
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [_inputLabel("CVV"), _textField("CVV")]
                )
              ),
            ],
          ),
          
          // Primary Submit Button placed directly after fields
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                // Logic to save manual entry
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828), // Matches your SUBMIT button
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'SUBMIT',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),
          
          // Secondary Scan Options
          _buildActionList(),
        ],
      ),
    );
  }

  // --- SCREEN 3: SCANNER UI (The Dark Overlay) ---
  Widget _buildScannerUI() {
    return Stack(
      children: [
        Container(color: Colors.black.withOpacity(0.7)),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 220,
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2196F3), width: 3),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Hold the card inside the frame. It will be\nscanned automatically',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Roboto', color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Center(
            child: TextButton(
              onPressed: () => setState(() => _viewIndex = 2),
              child: const Text("SIMULATE SCAN SUCCESS", style: TextStyle(color: Colors.white54)),
            ),
          ),
        )
      ],
    );
  }

  // --- SCREEN 2: CARD PREVIEW ---
  Widget _buildCardPreview() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            height: 210,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF263238),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _virtualCardContent(),
          ),
        ),
        const Spacer(),
        _buildBottomBar(),
      ],
    );
  }

  // --- UI COMPONENTS ---

  Widget _virtualCardContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.topRight, 
            child: Icon(Icons.credit_card, color: Colors.orange, size: 32)
          ),
          const Text("CARD NUMBER", style: TextStyle(color: Colors.white54, fontSize: 10)),
          const Text("4950 45XX XXXX XXXX", style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
          const Spacer(),
          Row(
            children: [
              _cardSubDetail("MONTH/YEAR", "01/23"),
              const SizedBox(width: 40),
              _cardSubDetail("CVV", "XXX"),
            ],
          ),
          const SizedBox(height: 12),
          const Text("JEFF STOCKWELL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white, 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Row(children: [Icon(Icons.qr_code_scanner, color: Colors.grey), SizedBox(width: 8), Text("Scan", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))]),
          TextButton(
            onPressed: () => setState(() => _viewIndex = 0),
            child: const Text("Done", style: TextStyle(color: Color(0xFFC62828), fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _inputLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8), 
    child: Text(text, style: const TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey))
  );

  Widget _textField(String hint) => TextField(
    style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
    decoration: InputDecoration(
      hintText: hint, 
      filled: true, 
      fillColor: const Color(0xFFF7F8F9), 
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), 
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
    )
  );

  Widget _buildActionList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.qr_code_scanner, color: Color(0xFF455A64)), 
            title: const Text("Scan card", style: TextStyle(fontFamily: 'Roboto')), 
            trailing: const Icon(Icons.arrow_forward_ios, size: 14), 
            onTap: () => setState(() => _viewIndex = 1)
          ),
          const Divider(height: 1, indent: 55),
          const ListTile(
            leading: Icon(Icons.face, color: Color(0xFF455A64)), 
            title: Text("Add face ID", style: TextStyle(fontFamily: 'Roboto')), 
            trailing: Icon(Icons.arrow_forward_ios, size: 14)
          ),
        ],
      ),
    );
  }

  Widget _cardSubDetail(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, 
    children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8)), 
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 13))
    ]
  );
}