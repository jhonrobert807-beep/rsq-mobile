import 'package:flutter/material.dart';
import '../services/payment_api.dart';
import '../core/errors/app_exception.dart';

class PaymentProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _savedCards = [];
  List<Map<String, dynamic>> _paymentHistory = [];
  bool _isLoading = false;
  String? _error;
  String? _selectedCardId;

  List<Map<String, dynamic>> get savedCards => _savedCards;
  List<Map<String, dynamic>> get paymentHistory => _paymentHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCardId => _selectedCardId;

  /// Load saved cards for current user
  Future<void> loadSavedCards(String userId) async {
    _setLoading(true);
    try {
      _savedCards = await PaymentApi.getSavedCards(userId);
      _error = null;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Load payment history
  Future<void> loadPaymentHistory(String userId) async {
    _setLoading(true);
    try {
      _paymentHistory = await PaymentApi.getPaymentHistory(userId);
      _error = null;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Save a new card
  Future<String?> saveCard({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String holderName,
  }) async {
    _setLoading(true);
    try {
      final result = await PaymentApi.saveCard(
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cvv: cvv,
        holderName: holderName,
      );
      _savedCards.add(result);
      _error = null;
      notifyListeners();
      return null;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a saved card
  Future<String?> deleteCard(String cardId) async {
    _setLoading(true);
    try {
      await PaymentApi.deleteCard(cardId);
      _savedCards.removeWhere((card) => card['id'] == cardId);
      _error = null;
      notifyListeners();
      return null;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  /// Process payment for a ride
  Future<String?> processPayment({
    required String rideRequestId,
    required String paymentMethodId,
    required double amount,
    required String currency,
  }) async {
    _setLoading(true);
    try {
      await PaymentApi.processPayment(
        rideRequestId: rideRequestId,
        paymentMethodId: paymentMethodId,
        amount: amount,
        currency: currency,
      );
      _error = null;
      notifyListeners();
      return null;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  /// Request refund for a ride
  Future<String?> requestRefund({
    required String rideRequestId,
    required String reason,
  }) async {
    _setLoading(true);
    try {
      await PaymentApi.refundPayment(rideRequestId: rideRequestId, reason: reason);
      _error = null;
      notifyListeners();
      return null;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  /// Select a card for payment
  void selectCard(String cardId) {
    _selectedCardId = cardId;
    notifyListeners();
  }

  /// Clear selected card
  void clearSelection() {
    _selectedCardId = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
