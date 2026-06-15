import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _keyAccess = 'access_token';
  static const _keyRefresh = 'refresh_token';
  static const _keyUser = 'current_user';

  static Future<void> saveTokens(String access, String refresh) async {
    try {
      await Future.wait([
        _storage.write(key: _keyAccess, value: access),
        _storage.write(key: _keyRefresh, value: refresh),
      ]);
    } catch (e) {
      // Fallback for web or environments where secure storage fails
      if (!_isWeb()) rethrow;
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _keyAccess);
    } catch (e) {
      if (!_isWeb()) rethrow;
      return null;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefresh);
    } catch (e) {
      if (!_isWeb()) rethrow;
      return null;
    }
  }

  static Future<void> saveUser(UserModel user) async {
    try {
      await _storage.write(key: _keyUser, value: jsonEncode(user.toJson()));
    } catch (e) {
      if (!_isWeb()) rethrow;
    }
  }

  static Future<UserModel?> getUser() async {
    try {
      final raw = await _storage.read(key: _keyUser);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw));
    } catch (e) {
      if (!_isWeb()) rethrow;
      return null;
    }
  }

  static Future<void> clearAll() async {
    try {
      await Future.wait([
        _storage.delete(key: _keyAccess),
        _storage.delete(key: _keyRefresh),
        _storage.delete(key: _keyUser),
      ]);
    } catch (e) {
      if (!_isWeb()) rethrow;
    }
  }

  static bool _isWeb() {
    try {
      // If we're on web, kIsWeb would be true
      return identical(0, 0.0);
    } catch (_) {
      return false;
    }
  }
}
