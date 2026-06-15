import '../core/errors/app_exception.dart';
import 'api_service.dart';

class DriverPerformanceApi {
  static Future<Map<String, dynamic>> getAllStats() async {
    try {
      final result = await ApiService.get('/driver-performance');
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to fetch all driver stats: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getCurrentDriverStats() async {
    try {
      final result = await ApiService.get('/driver-performance/me');
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to fetch current driver stats: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> getDriverStats(String driverId) async {
    try {
      final result = await ApiService.get('/driver-performance/$driverId');
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to fetch driver stats: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> updateDriverStats(String driverId, {
    double? rating,
    int? completedRides,
    int? cancelledRides,
    double? averageResponseTime,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (rating != null) data['rating'] = rating;
      if (completedRides != null) data['completedRides'] = completedRides;
      if (cancelledRides != null) data['cancelledRides'] = cancelledRides;
      if (averageResponseTime != null) data['averageResponseTime'] = averageResponseTime;

      final result = await ApiService.patch('/driver-performance/$driverId', data: data);
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to update driver stats: ${e.toString()}');
    }
  }
}
