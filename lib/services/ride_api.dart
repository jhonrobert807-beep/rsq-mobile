import '../core/constants/api_constants.dart';
import '../models/ride_request_model.dart';
import 'api_service.dart';

class RideApi {
  static Future<RideRequestModel> createRide({
    required String ambulanceType,
    required double pickupLat,
    required double pickupLng,
    double? destinationLat,
    double? destinationLng,
  }) async {
    final data = <String, dynamic>{
      'ambulanceType': ambulanceType,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
    };
    if (destinationLat != null) data['destinationLat'] = destinationLat;
    if (destinationLng != null) data['destinationLng'] = destinationLng;
    final result = await ApiService.post(ApiConstants.rideRequests, data: data);
    return RideRequestModel.fromJson(result);
  }

  static Future<RideRequestModel> getRide(String id) async {
    final result = await ApiService.get('${ApiConstants.rideRequests}/$id');
    return RideRequestModel.fromJson(result);
  }

  static Future<List<RideRequestModel>> getMyRides() async {
    final result = await ApiService.get(ApiConstants.myRides);
    return (result as List).map((e) => RideRequestModel.fromJson(e)).toList();
  }

  static Future<List<RideRequestModel>> getDriverRides() async {
    final result = await ApiService.get(ApiConstants.driverRides);
    return (result as List).map((e) => RideRequestModel.fromJson(e)).toList();
  }

  static Future<void> cancelRide(String id) =>
      ApiService.patch('${ApiConstants.rideRequests}/$id/cancel');

  static Future<void> acceptRide(String id) =>
      ApiService.patch('${ApiConstants.rideRequests}/$id/accept');

  static Future<void> rejectRide(String id) =>
      ApiService.patch('${ApiConstants.rideRequests}/$id/reject');

  static Future<void> rateRide(String id, double rating) =>
      ApiService.post('${ApiConstants.rideRequests}/$id/rate', data: {'rating': rating});

  static Future<void> updateStatus(String id, String status) =>
      ApiService.patch('${ApiConstants.rideRequests}/$id/status', data: {'status': status});

  static Future<void> updatePayment(String id, {required String paymentStatus, String? paymentMethod}) =>
      ApiService.patch('${ApiConstants.rideRequests}/$id/payment', data: {
        'paymentStatus': paymentStatus,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      });
}
