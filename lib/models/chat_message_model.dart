class ChatMessageModel {
  final String id;
  final String rideRequestId;
  final String senderId;
  final String receiverId;
  final String messageType;
  final String message;
  final DateTime sentAt;
  final String? senderName;
  final String? senderRole;

  ChatMessageModel({
    required this.id,
    required this.rideRequestId,
    required this.senderId,
    required this.receiverId,
    required this.messageType,
    required this.message,
    required this.sentAt,
    this.senderName,
    this.senderRole,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        id: json['id'],
        rideRequestId: json['rideRequestId'],
        senderId: json['senderId'],
        receiverId: json['receiverId'],
        messageType: json['messageType'] ?? 'TEXT',
        message: json['message'],
        sentAt: DateTime.parse(json['sentAt']),
        senderName: json['sender']?['name'],
        senderRole: json['sender']?['role'],
      );
}
