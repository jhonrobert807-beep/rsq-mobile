import '../core/errors/app_exception.dart';
import 'api_service.dart';

class LocationApi {
  /// Search for locations by query (hospitals, landmarks, addresses)
  static Future<List<Map<String, dynamic>>> searchLocations({
    required String query,
    required double latitude,
    required double longitude,
    double radiusKm = 50,
  }) async {
    try {
      final result = await ApiService.get(
        '/locations/search',
        params: {
          'query': query,
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
        },
      );
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AppException('Location search failed: ${e.toString()}');
    }
  }

  /// Get nearby locations (hospitals, landmarks)
  static Future<List<Map<String, dynamic>>> getNearbyLocations({
    required double latitude,
    required double longitude,
    String? type,
    double radiusKm = 10,
  }) async {
    try {
      final params = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'radiusKm': radiusKm,
      };
      if (type != null) params['type'] = type;

      final result = await ApiService.get('/locations/nearby', params: params);
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AppException('Failed to fetch nearby locations: ${e.toString()}');
    }
  }

  /// Get location details by ID
  static Future<Map<String, dynamic>> getLocationDetails(String locationId) async {
    try {
      final result = await ApiService.get('/locations/$locationId');
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Failed to fetch location details: ${e.toString()}');
    }
  }

  /// Get popular destinations
  static Future<List<Map<String, dynamic>>> getPopularDestinations() async {
    try {
      final result = await ApiService.get('/locations/popular');
      return (result as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw AppException('Failed to fetch popular destinations: ${e.toString()}');
    }
  }

  /// Reverse geocode (get location from coordinates)
  static Future<Map<String, dynamic>> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await ApiService.get(
        '/locations/reverse-geocode',
        params: {'latitude': latitude, 'longitude': longitude},
      );
      return result as Map<String, dynamic>;
    } catch (e) {
      throw AppException('Reverse geocode failed: ${e.toString()}');
    }
  }
}
