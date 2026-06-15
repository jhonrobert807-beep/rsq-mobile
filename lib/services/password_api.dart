import '../core/constants/api_constants.dart';
import '../core/errors/app_exception.dart';
import 'api_service.dart';

class PasswordApi {
  /// Update user password (requires current password)
  static Future<void> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ApiService.patch(
        '${ApiConstants.users}/$userId/password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw AppException('Failed to update password: ${e.toString()}');
    }
  }

  /// Request password reset via email/phone
  static Future<void> requestPasswordReset(String emailOrPhone) async {
    try {
      await ApiService.post(
        '/password-reset/request',
        data: {'emailOrPhone': emailOrPhone},
      );
    } catch (e) {
      throw AppException('Failed to request password reset: ${e.toString()}');
    }
  }

  /// Verify password reset code
  static Future<void> verifyResetCode({
    required String emailOrPhone,
    required String code,
  }) async {
    try {
      await ApiService.post(
        '/password-reset/verify',
        data: {'emailOrPhone': emailOrPhone, 'code': code},
      );
    } catch (e) {
      throw AppException('Invalid or expired reset code: ${e.toString()}');
    }
  }

  /// Complete password reset with code
  static Future<void> completePasswordReset({
    required String emailOrPhone,
    required String code,
    required String newPassword,
  }) async {
    try {
      await ApiService.post(
        '/password-reset/complete',
        data: {
          'emailOrPhone': emailOrPhone,
          'code': code,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw AppException('Failed to reset password: ${e.toString()}');
    }
  }
}
