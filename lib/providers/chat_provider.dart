import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/chat_api.dart';
import '../services/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessageModel> _messages = [];
  bool _isConnected = false;
  int _unreadCount = 0;
  String? _currentRideId;

  List<ChatMessageModel> get messages => _messages;
  bool get isConnected => _isConnected;
  int get unreadCount => _unreadCount;

  // Call this when the ride starts (from ride screen) to listen for incoming messages
  Future<void> connectBackground(String rideRequestId, String currentUserId) async {
    if (_currentRideId == rideRequestId && _isConnected) return;
    _currentRideId = rideRequestId;
    _unreadCount = 0;

    if (!SocketService.isChatConnected()) {
      await SocketService.connectChat();
    }
    _isConnected = true;
    SocketService.joinRideChat(rideRequestId);

    // Register unread counter — off() clears any prior listener first
    SocketService.onNewMessage((data) {
      final message = ChatMessageModel.fromJson(data);
      if (message.senderId != currentUserId) {
        _unreadCount++;
        notifyListeners();
      }
    });
    Future.microtask(notifyListeners);
  }

  void clearUnread() {
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> loadAndConnect(String rideRequestId, String currentUserId, String receiverId) async {
    _messages = await ChatApi.getRideMessages(rideRequestId);
    notifyListeners();

    await SocketService.connectChat();
    _isConnected = true;
    SocketService.joinRideChat(rideRequestId);
    SocketService.onNewMessage((data) {
      final msg = ChatMessageModel.fromJson(data);
      final exists = _messages.any((m) => m.id == msg.id);
      if (!exists) {
        _messages.add(msg);
        notifyListeners();
      }
    });
    Future.microtask(notifyListeners);
  }

  void sendMessage({
    required String senderId,
    required String receiverId,
    required String rideRequestId,
    required String message,
  }) {
    SocketService.sendChatMessage({
      'senderId': senderId,
      'receiverId': receiverId,
      'rideRequestId': rideRequestId,
      'message': message,
      'messageType': 'TEXT',
    });
  }

  void disconnect() {
    _isConnected = false;
    _currentRideId = null;
    _unreadCount = 0;
    SocketService.disconnectChat();
    notifyListeners();
  }

  @override
  void dispose() {
    SocketService.disconnectChat();
    super.dispose();
  }
}
