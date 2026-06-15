import '../core/errors/app_exception.dart';
import '../models/ambulance_model.dart';
import 'api_service.dart';

class AmbulanceApi {
  static Future<AmbulanceModel> createAmbulance({
    required String licensePlate,
    required String ambulanceType,
    required String driverId,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{
        'licensePlate': licensePlate,
        'ambulanceType': ambulanceType,
        'driverId': driverId,
      };
      if (status != null) data['status'] = status;
      final result = await ApiService.post('/ambulances', data: data);
      return AmbulanceModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to create ambulance: ${e.toString()}');
    }
  }

  static Future<List<AmbulanceModel>> getAllAmbulances() async {
    try {
      final result = await ApiService.get('/ambulances');
      return (result as List).map((e) => AmbulanceModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException('Failed to fetch ambulances: ${e.toString()}');
    }
  }

  static Future<AmbulanceModel> getAmbulanceById(String id) async {
    try {
      final result = await ApiService.get('/ambulances/$id');
      return AmbulanceModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to fetch ambulance: ${e.toString()}');
    }
  }

  static Future<AmbulanceModel> updateAmbulance(String id, {
    String? licensePlate,
    String? ambulanceType,
    String? driverId,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (licensePlate != null) data['licensePlate'] = licensePlate;
      if (ambulanceType != null) data['ambulanceType'] = ambulanceType;
      if (driverId != null) data['driverId'] = driverId;
      if (status != null) data['status'] = status;
      final result = await ApiService.patch('/ambulances/$id', data: data);
      return AmbulanceModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to update ambulance: ${e.toString()}');
    }
  }

  static Future<void> deleteAmbulance(String id) async {
    try {
      await ApiService.delete('/ambulances/$id');
    } catch (e) {
      throw AppException('Failed to delete ambulance: ${e.toString()}');
    }
  }
}
