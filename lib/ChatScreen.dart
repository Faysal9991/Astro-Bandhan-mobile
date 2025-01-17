import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'Home/SocketService.dart';
import 'Message.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  final String astrologer_id;
  final String userId;
  final String userName;

  ChatScreen({
    required this.chatRoomId,
    required this.astrologer_id,
    required this.userId,
    required this.userName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Message> messages = [];
  late SocketService socketService;

  @override
  void initState() {
    super.initState();
    // Initialize socketService after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      socketService = Provider.of<SocketService>(context, listen: false);
      _connectToChatRoom();
    });
  }

  /// Connect to chat room via SocketService
  Future<void> _connectToChatRoom() async {
    // Connect the socket with userId
    socketService.connect(widget.userId, context);

    // Try fetching any existing chatRoomId from local storage
    final chatRoomId = await socketService.getChatRoomId(widget.userId, widget.astrologer_id);

    if (chatRoomId == null) {

      socketService.saveChatRoomId(widget.chatRoomId, widget.userId, widget.astrologer_id);

      print("start_chat-join_chat");

      // First time chat join
      socketService.socket.emit('joinChatFirstTime', {
        'userId': widget.userId,
        'astrologerId': widget.astrologer_id,
        'chatRoomId': widget.chatRoomId,
        'hitBy': 'astrologer',
      });

    } else {

      // Already have a chatRoomId stored
      print("start_chat");

      socketService.socket.emit('resumeChat', {
        'chatRoomId': widget.chatRoomId,
        'userId': widget.userId,
        'astrologerId': widget.astrologer_id
      });

    }

    // Attach listeners
    socketService.socket.on('chatEnded_XX', _onChatEndedXX);
    socketService.socket.on('chatEnded', _onChatEnded);
    socketService.socket.on('chatMessage', _onChatMessage);
  }

  /// Listener for 'chatEnded_XX' event
  void _onChatEndedXX(dynamic data) {
    if (!mounted) return;
    print("CHATTING_END");
    socketService.removeChatRoomId(widget.userId, widget.astrologer_id);
    print("Chat preferences cleared for key:");
    Navigator.pop(context);
  }

  /// Listener for 'chatEnded' event
  void _onChatEnded(dynamic data) {
    if (!mounted) return;
    print("CHATTING_END_chatEnded");
    socketService.removeChatRoomId(widget.userId, widget.astrologer_id);
    print("Chat preferences cleared for key:");
    Navigator.pop(context);
  }

  /// Listener for 'chatMessage' event
  void _onChatMessage(dynamic data) {
    if (!mounted) return;
    print('New message: $data');

    // Ensure data["messages"] is a list
    if (data["messages"] is List<dynamic>) {
      List<Message> newMessages = (data["messages"] as List<dynamic>)
          .map((msg) => Message.fromJson(msg))
          .toList();
      setState(() {
        messages.clear();
        messages.addAll(newMessages);
      });
    } else {
      // Handle unexpected data format if necessary
      print("Unexpected data format for 'chatMessage': $data");
    }
  }

  @override
  void dispose() {
    // Remove all listeners to prevent memory leaks and unwanted callbacks
    socketService.socket.off('chatEnded_XX', _onChatEndedXX);
    socketService.socket.off('chatEnded', _onChatEnded);
    socketService.socket.off('chatMessage', _onChatMessage);
    _messageController.dispose();
    super.dispose();
  }

  /// Emit "sendMessage" event
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final messageData = {
      'chatRoomId': widget.chatRoomId,
      'senderId': widget.astrologer_id,  // Astrologer ID
      'senderType': 'astrologer',        // Mark as astrologer
      'message': _messageController.text.trim(),
      'timestamp': DateTime.now().toIso8601String(),
      'messageType': 'text',
    };

    // Emit to server
    socketService.socket.emit('sendMessage', messageData);

    // Immediately show in our local UI
    setState(() {
      messages.add(Message.fromJson(messageData));
    });

    _messageController.clear();
  }

  /// Format the DateTime for display (e.g., 12:05 PM)
  String _formatTime(String isoString) {
    DateTime dateTime = DateTime.parse(isoString).toLocal();

    // You could use intl package (DateFormat) for better formatting:
    // return DateFormat('hh:mm a').format(dateTime);
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute < 10 ? '0${dateTime.minute}' : dateTime.minute;
    final amPm = dateTime.hour < 12 ? 'AM' : 'PM';

    return '$hour:$minute $amPm';
  }

  /// Build each chat bubble
  Widget _buildChatBubble(Message message) {
    // If the message senderType is 'astrologer', we treat it as "me"
    // (assuming you want astrologer messages on the right side)
    final bool isMe = (message.senderType == 'astrologer');

    // WhatsApp-like bubble colors
    final Color myBubbleColor = const Color(0xFFC6D6F8);   // Light green
    final Color otherBubbleColor = Colors.white;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // limit bubble width
        ),
        decoration: BoxDecoration(
          color: isMe ? myBubbleColor : otherBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // The main message content
            message.messageType == 'image'
                ? _buildImageMessage(message.message)
                : Text(
                message.message,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                )
            ),

            const SizedBox(height: 4),
            // Timestamp text
            Text(
              _formatTimestamp(message.timestamp),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            )
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final DateFormat formatter = DateFormat('hh:mm a'); // e.g., 12:05 PM
    return formatter.format(dateTime);
  }

  /// Build chat list
  Widget _buildMessageList() {
    return ListView.builder(
      reverse: true,
      // We want new messages at the bottom, so reverse the list
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex];
        return _buildChatBubble(message);
      },
    );
  }

  /// Build the text input field + send button
  Widget _buildMessageComposer() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          // Text Field
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Type a message',
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 4),
          // Send Button
          CircleAvatar(
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  /// Main build
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1), // Light grey background
      appBar: AppBar(
        title: Text(
          'Chat with ${widget.userName}'.toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 4.0,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(child: _buildMessageList()),
          // Composer
          _buildMessageComposer(),
        ],
      ),
    );
  }

  void _previewImage(String imageUrl) {
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: PhotoView(
            imageProvider: NetworkImage(imageUrl),
          ),
        ),
      ),
    );
  }

  Widget _buildImageMessage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        _previewImage(imageUrl);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) => Container(
            width: 200,
            height: 200,
            color: Colors.grey.shade200,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Icon(Icons.broken_image, color: Colors.red),
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
