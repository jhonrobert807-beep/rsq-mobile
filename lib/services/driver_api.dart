import '../core/constants/api_constants.dart';
import '../models/driver_profile_model.dart';
import 'api_service.dart';

class DriverApi {
  static Future<DriverProfileModel> getProfileByUserId(String userId) async {
    final result = await ApiService.get('${ApiConstants.driverProfiles}/user/$userId');
    return DriverProfileModel.fromJson(result);
  }
}

class ParamedicApi {
  static Future<DriverProfileModel> getProfileByUserId(String userId) async {
    final result = await ApiService.get('${ApiConstants.paramedicProfiles}/user/$userId');
    return DriverProfileModel.fromJson(result);
  }
}
