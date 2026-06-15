import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_api.dart';

class UserProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<UserModel> _users = [];
  UserModel? _selectedUser;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<UserModel> get users => _users;
  UserModel? get selectedUser => _selectedUser;

  Future<void> loadAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await UserApi.getAllUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedUser = await UserApi.getUserById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(String id, {
    String? name,
    String? email,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await UserApi.updateUser(
        id,
        name: name,
        email: email,
        phone: phone,
      );
      _selectedUser = updated;
      _users = _users.map((u) => u.id == id ? updated : u).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await UserApi.deleteUser(id);
      _users = _users.where((u) => u.id != id).toList();
      if (_selectedUser?.id == id) _selectedUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectUser(UserModel user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
