import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/chat_api.dart';
import '../services/socket_service.dart';
import '../models/chat_message_model.dart';
import '../core/errors/app_exception.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final String rideRequestId;
  final String recipientId;
  final String recipientName;
  final bool isGroup;

  const ChatScreen({
    super.key,
    required this.rideRequestId,
    required this.recipientId,
    required this.recipientName,
    this.isGroup = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _isSocketConnected = false;
  Timer? _pollTimer;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = context.read<AuthProvider>().currentUser?.id;
    // Clear badge as soon as chat is opened
    context.read<ChatProvider>().clearUnread();
    _initializeChat();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pollMessages());
  }

  Future<void> _initializeChat() async {
    await _loadMessages();
    await _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    try {
      // Connect only if not already connected (ChatProvider may have already connected)
      if (!SocketService.isChatConnected()) {
        await SocketService.connectChat();
      }
      SocketService.joinRideChat(widget.rideRequestId);

      // off() ensures only ONE listener is ever registered at a time
      SocketService.onNewMessage((data) {
        if (!mounted) return;
        final message = ChatMessageModel.fromJson(data);
        if (_messages.any((m) => m.id == message.id)) return;
        setState(() => _messages.add(message));
        _scrollToBottom();
      });

      setState(() => _isSocketConnected = true);
    } catch (_) {}
  }

  Future<void> _pollMessages() async {
    if (!mounted) return;
    try {
      final messages = await ChatApi.getRideMessages(widget.rideRequestId);
      if (!mounted) return;
      // Replace list only if something actually changed (by ID set comparison)
      final existingIds = _messages.map((m) => m.id).toSet();
      final fetchedIds = messages.map((m) => m.id).toSet();
      if (!existingIds.containsAll(fetchedIds) || !fetchedIds.containsAll(existingIds)) {
        setState(() {
          _messages.clear();
          _messages.addAll(messages);
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
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
        _scrollToBottom();
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
      final sentMessage = await ChatApi.sendMessage(
          widget.rideRequestId, message, widget.recipientId);
      if (mounted) {
        setState(() => _messages.add(sentMessage));
        _scrollToBottom();
      }

      // WebSocket broadcast is handled by the backend after REST save — no double-emit needed
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
            CircleAvatar(
              radius: 18,
              backgroundColor: widget.isGroup ? const Color(0xFF8D0B0B) : Colors.grey,
              child: Icon(
                widget.isGroup ? Icons.group : Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isGroup ? 'Ride Group Chat' : widget.recipientName,
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                if (widget.isGroup)
                  const Text('Patient · Driver · Paramedic',
                      style: TextStyle(color: Colors.grey, fontSize: 11)),
              ],
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadMessages,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      itemCount: _messages.isEmpty
                          ? 1
                          : _messages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) return _buildSystemCard();
                        if (_messages.isEmpty) return const SizedBox.shrink();
                        final msg = _messages[index - 1];
                        final isMine = msg.senderId == _currentUserId;
                        return _buildMessage(msg.message, isMine,
                            senderName: (!isMine && widget.isGroup) ? (msg.senderName ?? 'Member') : null);
                      },
                    ),
                  ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

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
      child: const Column(
        children: [
          Text(
            "Start Conversation",
            style: TextStyle(
              color: Color(0xFF008B8B),
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

  Widget _buildMessage(String text, bool isMine, {String? senderName}) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (senderName != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                senderName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8D0B0B),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMine ? const Color(0xFFDCF8C6) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isMine ? 12 : 0),
                bottomRight: Radius.circular(isMine ? 0 : 12),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 260),
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
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
                        controller: _messageController,
                        onSubmitted: (_) =>
                            _isSending ? null : _sendMessage(_messageController.text),
                        decoration: const InputDecoration(
                          hintText: "Type message",
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
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
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed:
                  _isSending ? null : () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }
}
