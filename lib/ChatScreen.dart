import 'package:astrologerapp/chat_history_state.dart';
import 'package:astrologerapp/chatting/ChatListBloc.dart';
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
      // context.read<ChatHistoryCubit>().getChatHistory(widget.chatRoomId);
      socketService = Provider.of<SocketService>(context, listen: false);
      // messages.addAll(chathistory );
      _connectToChatRoom();
    });
  }

  /// Connect to chat room via SocketService
  Future<void> _connectToChatRoom() async {
    // Connect the socket with userId
    socketService.connect(widget.userId, context);

    // Try fetching any existing chatRoomId from local storage
    final chatRoomId =
        await socketService.getChatRoomId(widget.userId, widget.astrologer_id);

    if (chatRoomId == null) {
      socketService.saveChatRoomId(
          widget.chatRoomId, widget.userId, widget.astrologer_id);

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
      'senderId': widget.astrologer_id, // Astrologer ID
      'senderType': 'astrologer', // Mark as astrologer
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
    final minute =
        dateTime.minute < 10 ? '0${dateTime.minute}' : dateTime.minute;
    final amPm = dateTime.hour < 12 ? 'AM' : 'PM';

    return '$hour:$minute $amPm';
  }

  /// Build each chat bubble
  Widget _buildChatBubble(Message message) {
    // If the message senderType is 'astrologer', we treat it as "me"
    // (assuming you want astrologer messages on the right side)
    final bool isMe = (message.senderType == 'astrologer');

    // WhatsApp-like bubble colors
    final Color myBubbleColor = const Color(0xFFC6D6F8); // Light green
    final Color otherBubbleColor = Colors.white;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width * 0.75, // limit bubble width
        ),
        decoration: BoxDecoration(
          color: isMe ? myBubbleColor : otherBubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(16),
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
                : Text(message.message,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
                    )),

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
          errorWidget: (context, url, error) =>
              Icon(Icons.broken_image, color: Colors.red),
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

// import 'dart:async';
// import 'package:astrologerapp/chat_history_model.dart';
// import 'package:astrologerapp/chat_history_state.dart';
// import 'package:astrologerapp/dio/dio_client.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ChatScreen extends StatefulWidget {
//   final String chatRoomId;
//   final String userId;
//   final String astrologerId;
//   final String userName;

//   const ChatScreen({
//     super.key,
//     required this.chatRoomId,
//     required this.userId,
//     required this.astrologerId,
//      required this.userName,
//   });

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   Timer? _typingTimer;
//   bool isTyping = false;
//   late ChatHistoryCubit _chatCubit;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCubit();
//     _setupScrollListener();
//   }

//   void _initializeCubit() {
//     _chatCubit = ChatHistoryCubit(
//       chatRoomId: widget.chatRoomId,
//       userId: widget.userId,
//       dio: DioClient.instance.getDio(),
//     );
//   }

//   void _setupScrollListener() {
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.maxScrollExtent) {
//         // User has scrolled to bottom
//         // Could implement loading more messages here if needed
//       }
//     });
//   }

//   void _handleTyping() {
//     if (!isTyping) {
//       isTyping = true;
//       // _chatCubit.sendTypingStatus(true);
//     }

//     // Reset typing timer
//     _typingTimer?.cancel();
//     _typingTimer = Timer(const Duration(milliseconds: 1000), () {
//       isTyping = false;
//       // _chatCubit.sendTypingStatus(false);
//     });
//   }

//   void _handleSendMessage() {
//     final message = _messageController.text.trim();
//     if (message.isNotEmpty) {
//       _chatCubit.sendMessage(message,widget.chatRoomId,widget.astrologerId);
//       _messageController.clear();
//       _scrollToBottom();
//     }
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Future<bool> _onWillPop() async {
//     // await _chatCubit.endChat();
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: BlocProvider.value(
//         value: _chatCubit,
//         child: BlocConsumer<ChatHistoryCubit, ChatHistoryState>(
//           listener: (context, state) {
//             _handleStateChanges(state);
//           },
//           builder: (context, state) {
//             return Scaffold(
//               appBar: _buildAppBar(state),
//               body: _buildBody(state),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   AppBar _buildAppBar(ChatHistoryState state) {
//     return AppBar(
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.userName), // Replace with actual name
//           // Text(
//           //   state.isOtherUserTyping
//           //       ? 'typing...'
//           //       : state.isSocketConnected
//           //           ? 'Online'
//           //           : 'Offline',
//           //   style: TextStyle(
//           //     fontSize: 12,
//           //     color: state.isSocketConnected ? Colors.green : Colors.grey,
//           //   ),
//           // ),
//         ],
//       ),
//       actions: [
//         // if (!state.isChatEnded)
//         //   IconButton(
//         //     icon: const Icon(Icons.close),
//         //     onPressed: () => _showEndChatDialog(),
//         //   ),
//       ],
//     );
//   }

//   Widget _buildBody(ChatHistoryState state) {
//     return Column(
//       children: [
//         _buildConnectionStatus(state),
//         Expanded(
//           child: _buildMessageList(state),
//         ),
//         // if (!state.isChatEnded) _buildMessageInput(state),
//       ],
//     );
//   }

//   Widget _buildConnectionStatus(ChatHistoryState state) {
//     if (!state.isSocketConnected) {
//       return Container(
//         color: Colors.red[100],
//         padding: const EdgeInsets.all(8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(Icons.error_outline, color: Colors.red),
//             SizedBox(width: 8),
//             Text(
//               'Reconnecting...',
//               style: TextStyle(color: Colors.red),
//             ),
//           ],
//         ),
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   Widget _buildMessageList(ChatHistoryState state) {
//     if (state.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (state.chatHistory.isEmpty) {
//       return const Center(child: Text('No messages yet'));
//     }

//     return ListView.builder(
//       controller: _scrollController,
//       padding: const EdgeInsets.all(8),
//       itemCount: state.chatHistory.length,
//       itemBuilder: (context, index) {
//         final message = state.chatHistory[index];
//         return _buildMessageItem(message);
//       },
//     );
//   }

//   Widget _buildMessageItem(ChatHistory message) {
//     final isMe = message.senderId == widget.userId;
//     return MessageBubble(
//       message: message,
//       isMe: isMe,
//       onLongPress: () => _showMessageOptions(message),
//     );
//   }

//   Widget _buildMessageInput(ChatHistoryState state) {
//     return Container(
//       padding: const EdgeInsets.all(8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, -1),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _messageController,
//                 onChanged: (_) => _handleTyping(),
//                 decoration: InputDecoration(
//                   hintText: 'Type a message...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(24),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                 ),
//                 maxLines: null,
//               ),
//             ),
//             const SizedBox(width: 8),
//             IconButton(
//               icon: const Icon(Icons.send),
//               color: Theme.of(context).primaryColor,
//               onPressed: _handleSendMessage,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _handleStateChanges(ChatHistoryState state) {
//     // Handle error messages
//     if (state.errorMessage != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(state.errorMessage!),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }

//     // Handle chat ended state
//     // if (state.isChatEnded) {
//     //   _showChatEndedDialog();
//     // }

//     // Auto-scroll to bottom when new message arrives
//     if (state.chatHistory.isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _scrollToBottom();
//       });
//     }
//   }

//   void _showEndChatDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('End Chat'),
//         content: const Text('Are you sure you want to end this chat?'),
//         actions: [
//           TextButton(
//             child: const Text('Cancel'),
//             onPressed: () => Navigator.pop(context),
//           ),
//           TextButton(
//             child: const Text('End Chat'),
//             onPressed: () {
//               Navigator.pop(context);
//               // _chatCubit.endChat();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showChatEndedDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: const Text('Chat Ended'),
//         content: const Text('This chat session has ended.'),
//         actions: [
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () {
//               Navigator.pop(context); // Close dialog
//               Navigator.pop(context); // Return to previous screen
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showMessageOptions(ChatHistory message) {
//     if (message.senderId != widget.userId) return; // Only show for own messages

//     showModalBottomSheet(
//       context: context,
//       builder: (context) => Container(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.copy),
//               title: const Text('Copy Message'),
//               onTap: () {
//                 // Add copy functionality
//                 Navigator.pop(context);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _typingTimer?.cancel();
//     super.dispose();
//   }
// }

// class MessageBubble extends StatelessWidget {
//   final ChatHistory message;
//   final bool isMe;
//   final VoidCallback? onLongPress;

//   const MessageBubble({
//     Key? key,
//     required this.message,
//     required this.isMe,
//     this.onLongPress,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onLongPress: onLongPress,
//       child: Align(
//         alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
//         child: Container(
//           margin: EdgeInsets.only(
//             left: isMe ? 64 : 8,
//             right: isMe ? 8 : 64,
//             top: 4,
//             bottom: 4,
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           decoration: BoxDecoration(
//             color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             crossAxisAlignment:
//                 isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//             children: [
//               Text(
//                 message.message ?? "",
//                 style: TextStyle(
//                   color: isMe ? Colors.white : Colors.black87,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     _formatTime(message.timestamp.toString()),
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: isMe ? Colors.white70 : Colors.black54,
//                     ),
//                   ),
//                   if (isMe) ...[
//                     const SizedBox(width: 4),
//                     // _buildStatusIcon(message.),
//                   ],
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String _formatTime(String timestamp) {
//     final dateTime = DateTime.parse(timestamp);
//     return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }

//   Widget _buildStatusIcon(String status) {
//     switch (status) {
//       case 'sending':
//         return const Icon(Icons.access_time, size: 14, color: Colors.white70);
//       case 'sent':
//         return const Icon(Icons.check, size: 14, color: Colors.white70);
//       case 'delivered':
//         return const Icon(Icons.done_all, size: 14, color: Colors.white70);
//       case 'read':
//         return const Icon(Icons.done_all, size: 14, color: Colors.blue);
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }
