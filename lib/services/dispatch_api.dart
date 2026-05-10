import '../core/constants/api_constants.dart';
import '../models/ambulance_model.dart';
import 'api_service.dart';

class DispatchApi {
  static Future<List<AmbulanceModel>> findNearest({
    required double lat,
    required double lng,
    String? type,
    double radiusKm = 10,
  }) async {
    final params = <String, dynamic>{'lat': lat, 'lng': lng, 'radiusKm': radiusKm};
    if (type != null) params['type'] = type;
    final result = await ApiService.get(ApiConstants.nearest, params: params);
    return (result as List).map((e) => AmbulanceModel.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> calculateDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) async {
    return await ApiService.get(ApiConstants.distance, params: {
      'lat1': lat1, 'lng1': lng1, 'lat2': lat2, 'lng2': lng2,
    });
  }
}
