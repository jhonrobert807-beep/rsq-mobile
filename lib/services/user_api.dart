import '../core/constants/api_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserApi {
  static Future<UserModel> updateUser(String id, {String? name, String? email, String? phone}) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    final result = await ApiService.patch('${ApiConstants.users}/$id', data: data);
    return UserModel.fromJson(result);
  }
}
