class SavedCard {
  final String number;
  final String holderName;
  final String expiry;

  const SavedCard({required this.number, required this.holderName, required this.expiry});

  String get maskedNumber => '**** **** **** ${number.replaceAll(' ', '').length >= 4 ? number.replaceAll(' ', '').substring(number.replaceAll(' ', '').length - 4) : number}';
}

class CardStore {
  CardStore._();
  static final CardStore instance = CardStore._();

  final List<SavedCard> _cards = [];

  List<SavedCard> get cards => List.unmodifiable(_cards);

  void addCard(SavedCard card) {
    _cards.add(card);
  }
}
