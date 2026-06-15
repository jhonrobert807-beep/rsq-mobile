import '../core/errors/app_exception.dart';
import 'api_service.dart';

class NotificationApi {
  /// Get notification preferences for current user
  static Future<Map<String, dynamic>> getPreferences(String userId) async {
    try {
      final result = await ApiService.get('/notifications/preferences/$userId');
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to fetch notification preferences: ${e.toString()}');
    }
  }

  /// Update notification preferences
  static Future<Map<String, dynamic>> updatePreferences({
    required String userId,
    required bool rideUpdates,
    required bool promotions,
    required bool safetyAlerts,
    required bool paymentReminders,
    required bool systemNotifications,
  }) async {
    try {
      final result = await ApiService.patch(
        '/notifications/preferences/$userId',
        data: {
          'rideUpdates': rideUpdates,
          'promotions': promotions,
          'safetyAlerts': safetyAlerts,
          'paymentReminders': paymentReminders,
          'systemNotifications': systemNotifications,
        },
      );
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to update notification preferences: ${e.toString()}');
    }
  }

  /// Get all notifications for user
  static Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    try {
      final result = await ApiService.get('/notifications/$userId');
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AppException('Failed to fetch notifications: ${e.toString()}');
    }
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      await ApiService.patch('/notifications/$notificationId/read');
    } catch (e) {
      throw AppException('Failed to mark notification as read: ${e.toString()}');
    }
  }

  /// Delete a notification
  static Future<void> deleteNotification(String notificationId) async {
    try {
      await ApiService.delete('/notifications/$notificationId');
    } catch (e) {
      throw AppException('Failed to delete notification: ${e.toString()}');
    }
  }

  /// Clear all notifications
  static Future<void> clearAllNotifications(String userId) async {
    try {
      await ApiService.post('/notifications/$userId/clear');
    } catch (e) {
      throw AppException('Failed to clear notifications: ${e.toString()}');
    }
  }
}
