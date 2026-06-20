import '../core/constants/api_constants.dart';
import '../models/chat_message_model.dart';
import 'api_service.dart';

class ChatApi {
  static Future<List<ChatMessageModel>> getRideMessages(String rideRequestId) async {
    final result = await ApiService.get('${ApiConstants.chats}/ride/$rideRequestId');
    return (result as List).map((e) => ChatMessageModel.fromJson(e)).toList();
  }

  static Future<ChatMessageModel> sendMessage(String rideRequestId, String message, String receiverId) async {
    final data = <String, dynamic>{
      'rideRequestId': rideRequestId,
      'message': message,
      'messageType': 'TEXT',
    };
    if (receiverId.isNotEmpty) data['receiverId'] = receiverId;
    final result = await ApiService.post(ApiConstants.chats, data: data);
    return ChatMessageModel.fromJson(result);
  }

  static Future<List<ChatMessageModel>> getConversation(
    String rideRequestId,
    String otherUserId,
  ) async {
    final result = await ApiService.get(
      '${ApiConstants.chats}/ride/$rideRequestId/conversation',
      params: {'userId': otherUserId},
    );
    return (result as List).map((e) => ChatMessageModel.fromJson(e)).toList();
  }
}
