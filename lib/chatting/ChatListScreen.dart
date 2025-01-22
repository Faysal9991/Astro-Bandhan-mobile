import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../ChatScreen.dart';
import '../Home/SocketService.dart';
import 'ChatListBloc.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late SocketService socketService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatListBloc>().add(FetchChatList());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    socketService = Provider.of<SocketService>(context, listen: false);
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final events = ['newChat', 'chatEnded', 'chatStatusUpdate'];
    for (var event in events) {
      socketService.socket.on(event, (_) {
        if (mounted) {
          context.read<ChatListBloc>().add(FetchChatList());
        }
      });
    }
  }

  @override
  void dispose() {
    final events = ['newChat', 'chatEnded', 'chatStatusUpdate'];
    for (var event in events) {
      socketService.socket.off(event);
    }
    super.dispose();
  }

  Future<void> _handleEndChat(Map<String, dynamic> chat) async {
    try {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('End Chat'),
          content: const Text('Are you sure you want to end this chat?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                socketService.socket.emit("endChat", {
                  'userId': chat['user'],
                  'astrologerId': chat['astrologer'],
                  'chatRoomId': chat['chatRoomId'],
                });
                await socketService.removeChatRoomId(
                    chat['user'], chat['astrologer']);
                if (mounted) {
                  context.read<ChatListBloc>().add(FetchChatList());
                }
              },
              child:
                  const Text('End Chat', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to end chat. Please try again.'),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Active Chats'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ChatListBloc>().add(FetchChatList());
        },
        child: BlocBuilder<ChatListBloc, ChatListState>(
          builder: (context, state) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildContent(state),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(ChatListState state) {
    if (state is ChatListLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading chats...'),
          ],
        ),
      );
    }

    if (state is ChatListError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ChatListBloc>().add(FetchChatList());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is ChatListLoaded && state.chatRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Active Chats',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'When users start new chats,\nthey will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (state is ChatListLoaded) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.chatRooms.length,
        itemBuilder: (context, index) {
          final chat = state.chatRooms[index];
          return _buildChatListItem(chat);
        },
      );
    }

    return const Center(child: Text('Something went wrong'));
  }

  Widget _buildChatListItem(Map<String, dynamic> chat) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToChatScreen(chat),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                radius: 24,
                child: Text(
                  chat['username'][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${chat['username']}'.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(chat['createdAt']),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _navigateToChatScreen(chat),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: chat['isAstrologerJoined']
                          ? Colors.amber
                          : Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(
                      chat['isAstrologerJoined'] ? 'Join' : 'Accept',
                      style: TextStyle(
                        color: chat['isAstrologerJoined']
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _handleEndChat(chat),
                    icon: const Icon(Icons.close),
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToChatScreen(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          chatRoomId: chat['chatRoomId'],
          astrologer_id: chat['astrologer'],
          userId: chat['user'],
          userName: chat['username'],
        ),
      ),
    );
  }

  String formatDate(String utcDate) {
    final DateTime dateTime = DateTime.parse(utcDate);
    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');
    return formatter.format(dateTime.toLocal());
  }
}
