import '../core/errors/app_exception.dart';
import 'api_service.dart';

class AdminApi {
  /// Get admin statistics dashboard data
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final result = await ApiService.get('/admin-stats');
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to fetch admin stats: ${e.toString()}');
    }
  }

  /// Create an admin action/log entry
  static Future<Map<String, dynamic>> createAction({
    required String actionType,
    required String description,
    String? userId,
    String? targetId,
  }) async {
    try {
      final data = <String, dynamic>{
        'actionType': actionType,
        'description': description,
      };
      if (userId != null) data['userId'] = userId;
      if (targetId != null) data['targetId'] = targetId;

      final result = await ApiService.post('/admin-actions', data: data);
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to create admin action: ${e.toString()}');
    }
  }

  /// Get all admin actions/logs
  static Future<List<Map<String, dynamic>>> getActions({
    int? limit,
    int? offset,
  }) async {
    try {
      final params = <String, dynamic>{};
      if (limit != null) params['limit'] = limit;
      if (offset != null) params['offset'] = offset;

      final result = await ApiService.get('/admin-actions', params: params);
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AppException('Failed to fetch admin actions: ${e.toString()}');
    }
  }

  /// Get specific admin action details
  static Future<Map<String, dynamic>> getActionById(String id) async {
    try {
      final result = await ApiService.get('/admin-actions/$id');
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to fetch admin action: ${e.toString()}');
    }
  }
}
