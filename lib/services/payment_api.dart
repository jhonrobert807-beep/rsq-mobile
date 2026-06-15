import '../core/constants/api_constants.dart';
import '../core/errors/app_exception.dart';
import 'api_service.dart';

class PaymentApi {
  /// Save a new payment card
  static Future<Map<String, dynamic>> saveCard({
    required String cardNumber,
    required String expiryDate,
    required String cvv,
    required String holderName,
  }) async {
    try {
      final result = await ApiService.post(
        '${ApiConstants.users}/payment-methods/cards',
        data: {
          'cardNumber': cardNumber,
          'expiryDate': expiryDate,
          'cvv': cvv,
          'holderName': holderName,
        },
      );
      return result;
    } catch (e) {
      throw AppException('Failed to save card: ${e.toString()}');
    }
  }

  /// Get all saved payment cards for user
  static Future<List<Map<String, dynamic>>> getSavedCards(String userId) async {
    try {
      final result = await ApiService.get('${ApiConstants.users}/$userId/payment-methods/cards');
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AppException('Failed to fetch cards: ${e.toString()}');
    }
  }

  /// Delete a saved payment card
  static Future<void> deleteCard(String cardId) async {
    try {
      await ApiService.delete('${ApiConstants.users}/payment-methods/cards/$cardId');
    } catch (e) {
      throw AppException('Failed to delete card: ${e.toString()}');
    }
  }

  /// Process payment for a ride
  static Future<Map<String, dynamic>> processPayment({
    required String rideRequestId,
    required String paymentMethodId,
    required double amount,
    required String currency,
  }) async {
    try {
      final result = await ApiService.post(
        '${ApiConstants.rideRequests}/$rideRequestId/payment',
        data: {
          'paymentMethodId': paymentMethodId,
          'amount': amount,
          'currency': currency,
          'status': 'PROCESSING',
        },
      );
      return result;
    } catch (e) {
      throw AppException('Payment failed: ${e.toString()}');
    }
  }

  /// Get payment history for user
  static Future<List<Map<String, dynamic>>> getPaymentHistory(String userId) async {
    try {
      final result = await ApiService.get('${ApiConstants.users}/$userId/payments');
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AppException('Failed to fetch payment history: ${e.toString()}');
    }
  }

  /// Refund a ride payment
  static Future<Map<String, dynamic>> refundPayment({
    required String rideRequestId,
    required String reason,
  }) async {
    try {
      final result = await ApiService.post(
        '${ApiConstants.rideRequests}/$rideRequestId/refund',
        data: {'reason': reason},
      );
      return result;
    } catch (e) {
      throw AppException('Refund failed: ${e.toString()}');
    }
  }
}
