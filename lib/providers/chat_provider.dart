import 'package:flutter/material.dart';
import '../models/chat_message_model.dart';
import '../services/chat_api.dart';
import '../services/socket_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessageModel> _messages = [];
  bool _isConnected = false;

  List<ChatMessageModel> get messages => _messages;
  bool get isConnected => _isConnected;

  Future<void> loadAndConnect(String rideRequestId, String currentUserId, String receiverId) async {
    _messages = await ChatApi.getRideMessages(rideRequestId);
    notifyListeners();

    await SocketService.connectChat();
    _isConnected = true;
    SocketService.joinRideChat(rideRequestId);
    SocketService.onNewMessage((data) {
      _messages.add(ChatMessageModel.fromJson(data));
      notifyListeners();
    });
    notifyListeners();
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

  @override
  void dispose() {
    SocketService.disconnectChat();
    super.dispose();
  }
}
