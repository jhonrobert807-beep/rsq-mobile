import 'package:flutter/material.dart';
import '../services/admin_api.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _adminActions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get stats => _stats;
  List<Map<String, dynamic>> get adminActions => _adminActions;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _stats = await AdminApi.getStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAdminActions({int? limit, int? offset}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _adminActions = await AdminApi.getActions(limit: limit, offset: offset);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAction({
    required String actionType,
    required String description,
    String? userId,
    String? targetId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final action = await AdminApi.createAction(
        actionType: actionType,
        description: description,
        userId: userId,
        targetId: targetId,
      );
      _adminActions.insert(0, action);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getActionById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final action = await AdminApi.getActionById(id);
      _isLoading = false;
      notifyListeners();
      return action;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
