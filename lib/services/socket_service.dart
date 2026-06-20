import 'package:socket_io_client/socket_io_client.dart' as io;
import '../core/constants/api_constants.dart';
import 'storage_service.dart';

class SocketService {
  static io.Socket? _trackingSocket;
  static io.Socket? _chatSocket;

  static Future<void> connectTracking() async {
    final token = await StorageService.getAccessToken();
    _trackingSocket = io.io(
      '${ApiConstants.socketUrl}/tracking',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );

    _trackingSocket?.on('connect', (_) {
      print('✅ Tracking socket connected');
    });

    _trackingSocket?.on('connect_error', (error) {
      print('❌ Tracking connection error: $error');
    });

    _trackingSocket?.on('disconnect', (_) {
      print('⚠️ Tracking socket disconnected');
    });
  }

  static Future<void> connectChat() async {
    final token = await StorageService.getAccessToken();
    _chatSocket = io.io(
      '${ApiConstants.socketUrl}/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .build(),
    );

    _chatSocket?.on('connect', (_) {
      print('✅ Chat socket connected');
    });

    _chatSocket?.on('connect_error', (error) {
      print('❌ Chat connection error: $error');
    });

    _chatSocket?.on('disconnect', (_) {
      print('⚠️ Chat socket disconnected');
    });
  }

  static void emitLocation(String ambulanceId, double lat, double lng, {String? rideRequestId}) {
    final data = {'ambulanceId': ambulanceId, 'lat': lat, 'lng': lng};
    if (rideRequestId != null) data['rideRequestId'] = rideRequestId;
    _trackingSocket?.emit('updateLocation', data);
  }

  static void subscribeToRide(String rideRequestId) {
    _trackingSocket?.emit('subscribeToRide', {'rideRequestId': rideRequestId});
  }

  static void onRideLocation(String rideRequestId, Function(dynamic) callback) {
    _trackingSocket?.on('ride:$rideRequestId:location', callback);
  }

  static void joinRideChat(String rideRequestId) {
    _chatSocket?.emit('joinRide', {'rideRequestId': rideRequestId});
  }

  static void sendChatMessage(Map<String, dynamic> data) {
    _chatSocket?.emit('sendMessage', data);
  }

  static void onNewMessage(Function(dynamic) callback) {
    _chatSocket?.off('newMessage'); // remove any existing listener first
    _chatSocket?.on('newMessage', callback);
  }

  static bool isChatConnected() => _chatSocket?.connected ?? false;
  static bool isTrackingConnected() => _trackingSocket?.connected ?? false;

  static void disconnectTracking() => _trackingSocket?.disconnect();
  static void disconnectChat() => _chatSocket?.disconnect();
}
