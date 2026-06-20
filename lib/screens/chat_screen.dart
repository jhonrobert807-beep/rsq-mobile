import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_api.dart';
import '../services/socket_service.dart';
import '../models/chat_message_model.dart';
import '../core/errors/app_exception.dart';
import '../providers/auth_provider.dart';

class ChatScreen extends StatefulWidget {
  final String rideRequestId;
  final String recipientId;
  final String recipientName;

  const ChatScreen({
    super.key,
    required this.rideRequestId,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _isSocketConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Load message history from REST API
    await _loadMessages();

    // Connect to WebSocket for real-time messages
    await _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      await SocketService.connectChat();
      SocketService.joinRideChat(widget.rideRequestId);

      // Listen for incoming messages
      SocketService.onNewMessage((data) {
        if (mounted) {
          final message = ChatMessageModel.fromJson(data);
          setState(() => _messages.add(message));
        }
      });

      setState(() => _isSocketConnected = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WebSocket connection failed, using fallback'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    SocketService.disconnectChat();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await ChatApi.getRideMessages(widget.rideRequestId);
      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: ${e.message}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _messageController.clear();
    setState(() => _isSending = true);

    try {
      final userId = context.read<AuthProvider>().currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      if (_isSocketConnected) {
        // Send via WebSocket (instant) - DON'T send senderId, backend extracts from JWT
        SocketService.sendChatMessage({
          'receiverId': widget.recipientId,
          'rideRequestId': widget.rideRequestId,
          'message': message,
          'messageType': 'TEXT',
        });

        // Optimistic update: add message to UI immediately
        final optimisticMessage = ChatMessageModel(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          rideRequestId: widget.rideRequestId,
          senderId: userId,
          receiverId: widget.recipientId,
          message: message,
          messageType: 'TEXT',
          sentAt: DateTime.now(),
        );
        setState(() => _messages.add(optimisticMessage));
      } else {
        // Fallback to REST if WebSocket unavailable
        final sentMessage = await ChatApi.sendMessage(widget.rideRequestId, message);
        setState(() => _messages.add(sentMessage));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ChatScreenUI(
      recipientName: widget.recipientName,
      messages: _messages,
      isLoading: _isLoading,
      isSending: _isSending,
      messageController: _messageController,
      onSendMessage: _sendMessage,
      onRefresh: _loadMessages,
    );
  }
}

class _ChatScreenUI extends StatelessWidget {
  final String recipientName;
  final List<ChatMessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final TextEditingController messageController;
  final Function(String) onSendMessage;
  final Future<void> Function() onRefresh;

  const _ChatScreenUI({
    required this.recipientName,
    required this.messages,
    required this.isLoading,
    required this.isSending,
    required this.messageController,
    required this.onSendMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE7DD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/images/paramedic.jpg'),
            ),
            const SizedBox(width: 10),
            Text(
              recipientName,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: Colors.black, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: onRefresh,
                    child: messages.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            children: [
                              _buildSystemCard(),
                              const SizedBox(height: 20),
                              Center(
                                child: Text(
                                  'No messages yet. Start the conversation!',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            itemCount: messages.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) return _buildSystemCard();
                              final message = messages[index - 1];
                              return _buildMessage(message.message, message.messageType == 'SENT');
                            },
                          ),
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // --- UI Components ---

  Widget _buildSystemCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: const [
          Text(
            "Start Conversation",
            style: TextStyle(
              color: Color(0xFF008B8B), // Dark Teal
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "You can now start chatting with the members",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String text, bool isSent) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          // Sent: Lavender/Light Blue | Received: White
          color: isSent ? const Color(0xFFE7E7FF) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isSent ? 12 : 0),
            bottomRight: Radius.circular(isSent ? 0 : 12),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 280),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: messageController,
                        onSubmitted: (_) => isSending ? null : onSendMessage(messageController.text),
                        decoration: const InputDecoration(
                          hintText: "Type message",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const Icon(Icons.attach_file, color: Colors.grey),
                  const SizedBox(width: 10),
                  const Icon(Icons.camera_alt, color: Colors.grey),
                  const SizedBox(width: 15),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0xFF008B8B),
            child: IconButton(
              icon: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: isSending ? null : () => onSendMessage(messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}
