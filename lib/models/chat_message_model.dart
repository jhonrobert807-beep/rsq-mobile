class ChatMessageModel {
  final String id;
  final String rideRequestId;
  final String senderId;
  final String receiverId;
  final String messageType;
  final String message;
  final DateTime sentAt;

  ChatMessageModel({
    required this.id,
    required this.rideRequestId,
    required this.senderId,
    required this.receiverId,
    required this.messageType,
    required this.message,
    required this.sentAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        id: json['id'],
        rideRequestId: json['rideRequestId'],
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        messageType: json['messageType'] ?? 'TEXT',
        message: json['message'],
        sentAt: DateTime.parse(json['sentAt']),
      );
}
