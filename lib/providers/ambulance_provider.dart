import 'package:flutter/material.dart';
import '../models/ambulance_model.dart';
import '../services/ambulance_api.dart';

class AmbulanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<AmbulanceModel> _ambulances = [];
  AmbulanceModel? _selectedAmbulance;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AmbulanceModel> get ambulances => _ambulances;
  AmbulanceModel? get selectedAmbulance => _selectedAmbulance;

  Future<void> loadAmbulances() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ambulances = await AmbulanceApi.getAllAmbulances();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAmbulanceById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedAmbulance = await AmbulanceApi.getAmbulanceById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAmbulance({
    required String licensePlate,
    required String ambulanceType,
    required String driverId,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ambulance = await AmbulanceApi.createAmbulance(
        licensePlate: licensePlate,
        ambulanceType: ambulanceType,
        driverId: driverId,
        status: status,
      );
      _ambulances.add(ambulance);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAmbulance(String id, {
    String? licensePlate,
    String? ambulanceType,
    String? driverId,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await AmbulanceApi.updateAmbulance(
        id,
        licensePlate: licensePlate,
        ambulanceType: ambulanceType,
        driverId: driverId,
        status: status,
      );
      _ambulances = _ambulances.map((a) => a.id == id ? updated : a).toList();
      if (_selectedAmbulance?.id == id) _selectedAmbulance = updated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAmbulance(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AmbulanceApi.deleteAmbulance(id);
      _ambulances = _ambulances.where((a) => a.id != id).toList();
      if (_selectedAmbulance?.id == id) _selectedAmbulance = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAmbulance(AmbulanceModel ambulance) {
    _selectedAmbulance = ambulance;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
