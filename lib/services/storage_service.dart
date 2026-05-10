import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyUser = 'current_user';

  static Future<void> saveTokens(String access, String refresh) async {
    await Future.wait([
      _storage.write(key: _keyAccess, value: access),
      _storage.write(key: _keyRefresh, value: refresh),
    ]);
  }

  static Future<String?> getAccessToken() => _storage.read(key: _keyAccess);
  static Future<String?> getRefreshToken() => _storage.read(key: _keyRefresh);

  static Future<void> saveUser(UserModel user) =>
      _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));

  static Future<UserModel?> getUser() async {
    final raw = await _storage.read(key: _keyUser);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  static Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _keyAccess),
      _storage.delete(key: _keyRefresh),
      _storage.delete(key: _keyUser),
    ]);
  }
}
