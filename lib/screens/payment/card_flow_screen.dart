import 'package:flutter/material.dart';
import 'package:resqlink_mobile/routes/app_routes.dart';
import 'package:resqlink_mobile/services/card_store.dart';

class CardFlowScreen extends StatefulWidget {
  const CardFlowScreen({super.key});

  @override
  State<CardFlowScreen> createState() => _CardFlowScreenState();
}

class _CardFlowScreenState extends State<CardFlowScreen> {
  final _cardNumberCtrl = TextEditingController();
  final _holderNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _holderNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final number = _cardNumberCtrl.text.trim();
    final name = _holderNameCtrl.text.trim();
    final expiry = _expiryCtrl.text.trim();

    if (number.isEmpty || name.isEmpty || expiry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.red),
      );
      return;
    }

    await CardStore.instance.addCard(SavedCard(
      number: number,
      holderName: name,
      expiry: expiry,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card saved successfully'), backgroundColor: Colors.green),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add card',
          style: TextStyle(fontFamily: 'Roboto', color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputLabel("CARD NUMBER"),
            _textField("Enter card number", _cardNumberCtrl, keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            _inputLabel("CARD HOLDER NAME"),
            _textField("Enter card holder name", _holderNameCtrl),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_inputLabel("EXP. DATE"), _textField("MM/YY", _expiryCtrl, keyboardType: TextInputType.number)],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [_inputLabel("CVV"), _textField("CVV", _cvvCtrl, keyboardType: TextInputType.number, obscure: true)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'SUBMIT',
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(fontFamily: 'Roboto', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      );

  Widget _textField(String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, bool obscure = false}) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(fontFamily: 'Roboto', fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: const Color(0xFFF7F8F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}
