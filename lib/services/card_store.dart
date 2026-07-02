import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SavedCard {
  final String number;
  final String holderName;
  final String expiry;

  const SavedCard({required this.number, required this.holderName, required this.expiry});

  String get maskedNumber => '**** **** **** ${number.replaceAll(' ', '').length >= 4 ? number.replaceAll(' ', '').substring(number.replaceAll(' ', '').length - 4) : number}';

  Map<String, dynamic> toJson() => {'number': number, 'holderName': holderName, 'expiry': expiry};

  factory SavedCard.fromJson(Map<String, dynamic> j) =>
      SavedCard(number: j['number'] as String, holderName: j['holderName'] as String, expiry: j['expiry'] as String);
}

class CardStore {
  CardStore._();
  static final CardStore instance = CardStore._();

  static const _storage = FlutterSecureStorage();
  static const _key = 'saved_cards';

  final List<SavedCard> _cards = [];

  List<SavedCard> get cards => List.unmodifiable(_cards);

  Future<void> load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw != null) {
        final list = jsonDecode(raw) as List<dynamic>;
        _cards
          ..clear()
          ..addAll(list.map((e) => SavedCard.fromJson(e as Map<String, dynamic>)));
      }
    } catch (_) {}
  }

  Future<void> addCard(SavedCard card) async {
    _cards.add(card);
    await _save();
  }

  Future<void> removeCard(int index) async {
    if (index >= 0 && index < _cards.length) {
      _cards.removeAt(index);
      await _save();
    }
  }

  Future<void> _save() async {
    await _storage.write(key: _key, value: jsonEncode(_cards.map((c) => c.toJson()).toList()));
  }
}
