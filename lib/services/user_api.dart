import '../core/constants/api_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserApi {
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final result = await ApiService.get(ApiConstants.users);
      return (result as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      throw AppException('Failed to fetch users: ${e.toString()}');
    }
  }

  static Future<UserModel> getUserById(String id) async {
    try {
      final result = await ApiService.get('${ApiConstants.users}/$id');
      return UserModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to fetch user: ${e.toString()}');
    }
  }

  static Future<UserModel> updateUser(String id, {String? name, String? email, String? phone}) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      final result = await ApiService.patch('${ApiConstants.users}/$id', data: data);
      return UserModel.fromJson(result);
    } catch (e) {
      throw AppException('Failed to update user: ${e.toString()}');
    }
  }

  static Future<void> deleteUser(String id) async {
    try {
      await ApiService.delete('${ApiConstants.users}/$id');
    } catch (e) {
      throw AppException('Failed to delete user: ${e.toString()}');
    }
  }
}
