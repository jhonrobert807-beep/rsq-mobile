import 'package:flutter/material.dart';
import '../models/ride_request_model.dart';
import '../services/ride_api.dart';
import '../core/errors/app_exception.dart';

class RideProvider extends ChangeNotifier {
  RideRequestModel? _activeRide;
  List<RideRequestModel> _myRides = [];
  bool _isLoading = false;
  String? _error;

  RideRequestModel? get activeRide => _activeRide;
  List<RideRequestModel> get myRides => _myRides;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> createRide({
    required String ambulanceType,
    required double pickupLat,
    required double pickupLng,
    double? destinationLat,
    double? destinationLng,
  }) async {
    _setLoading(true);
    try {
      _activeRide = await RideApi.createRide(
        ambulanceType: ambulanceType,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        destinationLat: destinationLat,
        destinationLng: destinationLng,
      );
      notifyListeners();
      return null;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyRides() async {
    _setLoading(true);
    try {
      _myRides = await RideApi.getMyRides();
      notifyListeners();
    } catch (_) {
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshActiveRide() async {
    if (_activeRide == null) return;
    try {
      _activeRide = await RideApi.getRide(_activeRide!.id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> cancelRide() async {
    if (_activeRide == null) return;
    await RideApi.cancelRide(_activeRide!.id);
    await refreshActiveRide();
  }

  void setActiveRide(RideRequestModel ride) {
    _activeRide = ride;
    notifyListeners();
  }

  void clearActiveRide() {
    _activeRide = null;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
