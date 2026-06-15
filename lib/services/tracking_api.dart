import '../core/errors/app_exception.dart';
import 'api_service.dart';

class TrackingApi {
  /// Update driver location during ride
  static Future<Map<String, dynamic>> updateLocation({
    required String rideRequestId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    double? bearing,
  }) async {
    try {
      final data = <String, dynamic>{
        'rideRequestId': rideRequestId,
        'latitude': latitude,
        'longitude': longitude,
      };
      if (accuracy != null) data['accuracy'] = accuracy;
      if (speed != null) data['speed'] = speed;
      if (bearing != null) data['bearing'] = bearing;

      final result = await ApiService.post(
        '/tracking/update',
        data: data,
      );
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to update location: ${e.toString()}');
    }
  }

  /// Get live tracking for a ride
  static Future<Map<String, dynamic>> getLiveTracking(String rideRequestId) async {
    try {
      final result = await ApiService.get('/tracking/live',
          params: {'rideRequestId': rideRequestId});
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to get live tracking: ${e.toString()}');
    }
  }

  /// Get ambulance location
  static Future<Map<String, dynamic>> getAmbulanceLocation(String ambulanceId) async {
    try {
      final result = await ApiService.get('/tracking/$ambulanceId');
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to get ambulance location: ${e.toString()}');
    }
  }

  /// Get location history for a ride
  static Future<List<Map<String, dynamic>>> getLocationHistory({
    required String rideRequestId,
    int? limit,
  }) async {
    try {
      final params = <String, dynamic>{'rideRequestId': rideRequestId};
      if (limit != null) params['limit'] = limit;

      final result = await ApiService.get('/tracking/$rideRequestId/history', params: params);
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AppException('Failed to get location history: ${e.toString()}');
    }
  }

  /// Start tracking for a ride
  static Future<void> startTracking(String rideRequestId) async {
    try {
      await ApiService.post(
        '/tracking/$rideRequestId/start',
        data: {'rideRequestId': rideRequestId},
      );
    } catch (e) {
      throw AppException('Failed to start tracking: ${e.toString()}');
    }
  }

  /// Stop tracking for a ride
  static Future<void> stopTracking(String rideRequestId) async {
    try {
      await ApiService.post(
        '/tracking/$rideRequestId/stop',
        data: {'rideRequestId': rideRequestId},
      );
    } catch (e) {
      throw AppException('Failed to stop tracking: ${e.toString()}');
    }
  }
}
