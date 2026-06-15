import 'package:flutter/material.dart';
import '../services/organization_api.dart';

class OrganizationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _organizations = [];
  Map<String, dynamic>? _selectedOrganization;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get organizations => _organizations;
  Map<String, dynamic>? get selectedOrganization => _selectedOrganization;

  Future<void> loadOrganizations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _organizations = await OrganizationApi.getAllOrganizations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrganizationById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedOrganization = await OrganizationApi.getOrganizationById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrganization({
    required String name,
    required String address,
    String? phone,
    String? email,
    String? website,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final org = await OrganizationApi.createOrganization(
        name: name,
        address: address,
        phone: phone,
        email: email,
        website: website,
      );
      _organizations.add(org);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrganization(String id, {
    String? name,
    String? address,
    String? phone,
    String? email,
    String? website,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await OrganizationApi.updateOrganization(
        id,
        name: name,
        address: address,
        phone: phone,
        email: email,
        website: website,
      );
      _organizations = _organizations.map((o) => o['id'] == id ? updated : o).toList();
      if (_selectedOrganization?['id'] == id) _selectedOrganization = updated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrganization(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await OrganizationApi.deleteOrganization(id);
      _organizations = _organizations.where((o) => o['id'] != id).toList();
      if (_selectedOrganization?['id'] == id) _selectedOrganization = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectOrganization(Map<String, dynamic> org) {
    _selectedOrganization = org;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
