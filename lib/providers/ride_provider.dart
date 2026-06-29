import 'package:flutter/material.dart';
import '../models/ride_request_model.dart';
import '../models/location_model.dart';
import '../services/ride_api.dart';
import '../services/location_api.dart';
import '../core/errors/app_exception.dart';

class RideProvider extends ChangeNotifier {
  RideRequestModel? _activeRide;
  List<RideRequestModel> _myRides = [];
  bool _isLoading = false;
  String? _error;

  // Booking flow state
  LocationModel? _selectedPickup;
  LocationModel? _selectedDestination;
  String? _selectedVehicleType;
  String? _selectedPaymentMethod;
  List<LocationModel> _destinationSuggestions = [];

  RideRequestModel? get activeRide => _activeRide;
  List<RideRequestModel> get myRides => _myRides;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Booking flow getters
  LocationModel? get selectedPickup => _selectedPickup;
  LocationModel? get selectedDestination => _selectedDestination;
  String? get selectedVehicleType => _selectedVehicleType;
  String? get selectedPaymentMethod => _selectedPaymentMethod;
  List<LocationModel> get destinationSuggestions => _destinationSuggestions;

  bool get isBookingValid =>
      _selectedPickup != null &&
      _selectedDestination != null &&
      _selectedVehicleType != null &&
      _selectedPaymentMethod != null;

  Future<void> searchDestinations(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      _destinationSuggestions = await LocationApi.searchLocations(
        query: query,
        latitude: _selectedPickup?.latitude,
        longitude: _selectedPickup?.longitude,
      ).then((results) => results
          .map((json) => LocationModel.fromJson(json))
          .toList());

      notifyListeners();
    } catch (e) {
      _error = 'Failed to search destinations: $e';
      _destinationSuggestions = [];
      notifyListeners();
    } finally {
      _isLoading = false;
    }
  }

  void setPickup(LocationModel location) {
    _selectedPickup = location;
    _destinationSuggestions = [];
    notifyListeners();
  }

  void setDestination(LocationModel location) {
    _selectedDestination = location;
    _destinationSuggestions = [];
    notifyListeners();
  }

  void setVehicleType(String vehicleType) {
    _selectedVehicleType = vehicleType;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void clearBookingFlow() {
    _selectedPickup = null;
    _selectedDestination = null;
    _selectedVehicleType = null;
    _selectedPaymentMethod = null;
    _destinationSuggestions = [];
    notifyListeners();
  }

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
      _error = null;
      notifyListeners();
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load rides: ${e.toString()}';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshActiveRide() async {
    if (_activeRide == null) return;
    try {
      final updated = await RideApi.getRide(_activeRide!.id);
      if (updated.status != _activeRide!.status ||
          updated.assignedDriverId != _activeRide!.assignedDriverId ||
          updated.driverName != _activeRide!.driverName ||
          updated.etaMinutes != _activeRide!.etaMinutes ||
          updated.cost != _activeRide!.cost ||
          updated.paymentStatus != _activeRide!.paymentStatus) {
        _activeRide = updated;
        notifyListeners();
      }
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
