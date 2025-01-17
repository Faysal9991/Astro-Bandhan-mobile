import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../ChatScreen.dart';
import '../Home/SocketService.dart';
import 'ChatListBloc.dart';

class ChatListScreen extends StatefulWidget {
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    // socketService.socket.on('chatEnded', (data) {
    //
    //   print('Chat Endedxxxx: ${data['chatRoomId']}');
    //
    //   context.read<ChatListBloc>().add(FetchChatList());
    //
    //   Navigator.pop(context);
    // });

    final chatListBloc = BlocProvider.of<ChatListBloc>(context);

    return Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            context.read<ChatListBloc>().add(FetchChatList());
          },
          child: StreamBuilder<ChatListState>(
            stream: chatListBloc.stream, // Listen to the Bloc's state stream
            initialData: chatListBloc.state, // Provide the initial state
            builder: (context, snapshot) {
              final state = snapshot.data;
              print("--------------------->>>>>>${state}");
              if (state is ChatListLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is ChatListLoaded) {
                print("Building UI with chatRooms: ${state.chatRooms}");

                return ListView.builder(
                  key: ValueKey(state.chatRooms),
                  itemCount: state.chatRooms.length,
                  itemBuilder: (context, index) {
                    final chat = state.chatRooms[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                            ),
                          ),
                          title: Text('${chat['username']}'.toUpperCase()),
                          subtitle: Text('${formatDate(chat['createdAt'])}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  print(
                                      "Joining chat room: ${chat['chatRoomId']}");
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
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: chat['isAstrologerJoined']
                                      ? Colors.yellow
                                      : Colors.green,
                                  minimumSize: Size(70, 30),
                                ),
                                child: Text(
                                  chat['isAstrologerJoined']
                                      ? 'Join'
                                      : 'Accept',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: chat['isAstrologerJoined']
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  print(
                                      "Declining/Ending chat room: ${chat['chatRoomId']}");
                                  try {
                                    context
                                        .read<ChatListBloc>()
                                        .add(FetchChatList());
                                    socketService.socket.emit("endChat", {
                                      'userId': chat['user'],
                                      'astrologerId': chat['astrologer'],
                                      'chatRoomId': chat['chatRoomId'],
                                    });
                                    socketService.removeChatRoomId(
                                        chat['user'], chat['astrologer']);
                                  } catch (e) {
                                    print("Error emitting endChat: $e");
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  minimumSize: Size(70, 30),
                                ),
                                child: Text(
                                  chat['isAstrologerJoined']
                                      ? 'End Chat'
                                      : 'Decline',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
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
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            color: Colors.grey.withOpacity(0.3),
                            thickness: 1,
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else if (state is ChatListError) {
                // if(state.message == "No chat rooms found."){
                //   context.read<ChatListBloc>().add(FetchChatList());
                // }
                // Show error message with a refresh option
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChatListBloc>().add(FetchChatList());
                        },
                        child: Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              return Center(child: Text('Unexpected State'));
            },
          ),
        ));
  }

  String formatDate(String utcDate) {
    // Parse the UTC string into a DateTime object
    DateTime dateTime = DateTime.parse(utcDate);

    // Format the date-time in the desired Indian Standard Time (IST) format
    final DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
    return formatter.format(dateTime.toLocal()); // Converts to local timezone
  }
}
