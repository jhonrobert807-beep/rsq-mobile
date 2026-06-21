import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_api.dart';
import '../services/storage_service.dart';
import '../core/errors/app_exception.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  Future<void> loadFromStorage() async {
    final user = await StorageService.getUser();
    final token = await StorageService.getAccessToken();
    if (user != null && token != null) {
      _currentUser = user;
      notifyListeners();
    }
  }

  Future<String?> login({String? email, String? phone, required String password}) async {
    _setLoading(true);
    try {
      final result = await AuthApi.login(email: email, phone: phone, password: password);
      await _saveSession(result);
      return null;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> register({
    required String name,
    String? email,
    String? phone,
    required String password,
    String role = 'USER',
  }) async {
    _setLoading(true);
    try {
      final result = await AuthApi.register(
        name: name, email: email, phone: phone, password: password, role: role,
      );
      await _saveSession(result);
      return null;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> googleLogin({String? idToken, String? accessToken, String? role}) async {
    _setLoading(true);
    try {
      final result = await AuthApi.googleLogin(idToken: idToken, accessToken: accessToken, role: role);
      await _saveSession(result);
      return null;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void updateUser(UserModel user) {
    _currentUser = user;
    StorageService.saveUser(user);
    notifyListeners();
  }

  Future<void> _saveSession(Map<String, dynamic> result) async {
    final user = UserModel.fromJson(result['user']);
    await StorageService.saveTokens(result['accessToken'], result['refreshToken']);
    await StorageService.saveUser(user);
    _currentUser = user;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
