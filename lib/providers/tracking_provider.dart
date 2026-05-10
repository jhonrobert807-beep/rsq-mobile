import 'package:flutter/material.dart';
import '../models/tracking_model.dart';
import '../services/socket_service.dart';

class TrackingProvider extends ChangeNotifier {
  TrackingModel? _latestLocation;
  bool _isConnected = false;

  TrackingModel? get latestLocation => _latestLocation;
  bool get isConnected => _isConnected;

  Future<void> subscribeToRide(String rideRequestId) async {
    await SocketService.connectTracking();
    _isConnected = true;
    SocketService.subscribeToRide(rideRequestId);
    SocketService.onRideLocation(rideRequestId, (data) {
      _latestLocation = TrackingModel.fromJson(data);
      notifyListeners();
    });
    notifyListeners();
  }

  void disconnect() {
    SocketService.disconnectTracking();
    _isConnected = false;
    notifyListeners();
  }
}
