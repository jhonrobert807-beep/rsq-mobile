import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthApi {
  static Future<Map<String, dynamic>> login({String? email, String? phone, required String password}) async {
    final data = <String, dynamic>{'password': password};
    if (email != null && email.isNotEmpty) data['email'] = email;
    if (phone != null && phone.isNotEmpty) data['phone'] = phone;
    return await ApiService.post(ApiConstants.login, data: data);
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    String role = 'USER',
  }) async {
    final data = <String, dynamic>{'name': name, 'password': password, 'role': role};
    if (email != null && email.isNotEmpty) data['email'] = email;
    if (phone != null && phone.isNotEmpty) data['phone'] = phone;
    return await ApiService.post(ApiConstants.register, data: data);
  }

  static Future<UserModel> getProfile() async {
    final data = await ApiService.get(ApiConstants.profile);
    return UserModel.fromJson(data);
  }

  static Future<void> sendOtp(String identifier) async {
    await ApiService.post(ApiConstants.sendOtp, data: {'identifier': identifier});
  }

  static Future<bool> verifyOtp(String identifier, String code) async {
    final result = await ApiService.post(ApiConstants.verifyOtp, data: {'identifier': identifier, 'code': code});
    return result['verified'] == true;
  }
}
