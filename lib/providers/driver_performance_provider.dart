import 'package:flutter/material.dart';
import '../services/driver_performance_api.dart';

class DriverPerformanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _currentDriverStats;
  Map<String, dynamic>? _allStats;
  final Map<String, dynamic> _driverStatsByDriverId = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get currentDriverStats => _currentDriverStats;
  Map<String, dynamic>? get allStats => _allStats;
  Map<String, dynamic> get driverStatsByDriverId => _driverStatsByDriverId;

  Future<void> loadAllStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allStats = await DriverPerformanceApi.getAllStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentDriverStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentDriverStats = await DriverPerformanceApi.getCurrentDriverStats();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDriverStats(String driverId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await DriverPerformanceApi.getDriverStats(driverId);
      _driverStatsByDriverId[driverId] = stats;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDriverStats(String driverId, {
    double? rating,
    int? completedRides,
    int? cancelledRides,
    double? averageResponseTime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await DriverPerformanceApi.updateDriverStats(
        driverId,
        rating: rating,
        completedRides: completedRides,
        cancelledRides: cancelledRides,
        averageResponseTime: averageResponseTime,
      );
      _driverStatsByDriverId[driverId] = updated;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
