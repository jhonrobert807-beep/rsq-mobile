import '../core/constants/api_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/driver_profile_model.dart';
import 'api_service.dart';

class DriverApi {
  static Future<DriverProfileModel> createProfile({
    required String userId,
    required String licenseNumber,
    required String vehicleType,
    String? licenseExpiry,
  }) async {
    try {
      final data = <String, dynamic>{
        'userId': userId,
        'licenseNumber': licenseNumber,
        'vehicleType': vehicleType,
      };
      if (licenseExpiry != null) data['licenseExpiry'] = licenseExpiry;
      final result = await ApiService.post(ApiConstants.driverProfiles, data: data);
      return DriverProfileModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to create driver profile: ${e.toString()}');
    }
  }

  static Future<List<DriverProfileModel>> getAllDrivers() async {
    try {
      final result = await ApiService.get(ApiConstants.driverProfiles);
      return (result as List).map((e) => DriverProfileModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException('Failed to fetch drivers: ${e.toString()}');
    }
  }

  static Future<DriverProfileModel> getDriverById(String id) async {
    try {
      final result = await ApiService.get('${ApiConstants.driverProfiles}/$id');
      return DriverProfileModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to fetch driver: ${e.toString()}');
    }
  }

  static Future<DriverProfileModel> getProfileByUserId(String userId) async {
    try {
      final result = await ApiService.get('${ApiConstants.driverProfiles}/user/$userId');
      return DriverProfileModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to fetch driver profile: ${e.toString()}');
    }
  }

  static Future<DriverProfileModel> updateProfile(String id, {
    String? licenseNumber,
    String? vehicleType,
    String? licenseExpiry,
    String? vehicleOwner,
    String? vehicleRegistrationNumber,
    String? vehicleCity,
    String? gender,
    String? country,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (licenseNumber != null) data['licenseNumber'] = licenseNumber;
      if (vehicleType != null) data['vehicleType'] = vehicleType;
      if (licenseExpiry != null) data['licenseExpiry'] = licenseExpiry;
      if (vehicleOwner != null) data['vehicleOwner'] = vehicleOwner;
      if (vehicleRegistrationNumber != null) data['vehicleRegistrationNumber'] = vehicleRegistrationNumber;
      if (vehicleCity != null) data['vehicleCity'] = vehicleCity;
      if (gender != null) data['gender'] = gender;
      if (country != null) data['country'] = country;
      // Use /me endpoint so driver can update their own profile without ADMIN role
      final result = await ApiService.patch('${ApiConstants.driverProfiles}/me', data: data);
      return DriverProfileModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to update driver profile: ${e.toString()}');
    }
  }

  static Future<void> deleteProfile(String id) async {
    try {
      await ApiService.delete('${ApiConstants.driverProfiles}/$id');
    } catch (e) {
      throw AppException('Failed to delete driver profile: ${e.toString()}');
    }
  }
}

class ParamedicApi {
  static Future<DriverProfileModel> createProfile({
    required String userId,
    required String licenseNumber,
    String? certifications,
  }) async {
    try {
      final data = <String, dynamic>{
        'userId': userId,
        'licenseNumber': licenseNumber,
      };
      if (certifications != null) data['certifications'] = certifications;
      final result = await ApiService.post(ApiConstants.paramedicProfiles, data: data);
      return DriverProfileModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to create paramedic profile: ${e.toString()}');
    }
  }

  static Future<List<DriverProfileModel>> getAllParamedics() async {
    try {
      final result = await ApiService.get(ApiConstants.paramedicProfiles);
      return (result as List).map((e) => DriverProfileModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException('Failed to fetch paramedics: ${e.toString()}');
    }
  }

  static Future<DriverProfileModel> getParamedicById(String id) async {
    try {
      final result = await ApiService.get('${ApiConstants.paramedicProfiles}/$id');
      return DriverProfileModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to fetch paramedic: ${e.toString()}');
    }
  }

  static Future<DriverProfileModel> getProfileByUserId(String userId) async {
    try {
      final result = await ApiService.get('${ApiConstants.paramedicProfiles}/user/$userId');
      return DriverProfileModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to fetch paramedic profile: ${e.toString()}');
    }
  }

  static Future<DriverProfileModel> updateProfile(String id, {
    String? licenseNumber,
    String? certifications,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (licenseNumber != null) data['licenseNumber'] = licenseNumber;
      if (certifications != null) data['certifications'] = certifications;
      final result = await ApiService.patch('${ApiConstants.paramedicProfiles}/$id', data: data);
      return DriverProfileModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to update paramedic profile: ${e.toString()}');
    }
  }

  static Future<void> deleteProfile(String id) async {
    try {
      await ApiService.delete('${ApiConstants.paramedicProfiles}/$id');
    } catch (e) {
      throw AppException('Failed to delete paramedic profile: ${e.toString()}');
    }
  }
}
