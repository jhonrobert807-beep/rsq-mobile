import '../core/constants/api_constants.dart';
import '../models/chat_message_model.dart';
import 'api_service.dart';

class ChatApi {
  static Future<List<ChatMessageModel>> getRideMessages(String rideRequestId) async {
    final result = await ApiService.get('${ApiConstants.chats}/ride/$rideRequestId');
    return (result as List).map((e) => ChatMessageModel.fromJson(e)).toList();
  }
}
