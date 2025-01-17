import 'package:astrologerapp/Agora/VideoCallScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../Agora/AudioCallScreen.dart';
import '../NotificationService.dart';
import '../chatting/ChatListBloc.dart';
import '../dio/Constant.dart';
import 'audiocall/call_bloc.dart'; // Import CallBloc
import 'audiocall/call_event.dart'; // Import CallEvent

class SocketService {

  late IO.Socket socket;

  final NotificationService notificationService;
  final CallBloc callBloc; // Add CallBloc as a dependency

  SocketService(String astrologerId, this.notificationService, this.callBloc) {
    socket = IO.io(Base_url, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': {'astrologerId': astrologerId},
    });
  }

  void connect(String astrologerId, BuildContext context) {

      socket.connect();

      socket.on('connect', (_) {
        print('Socket connected');
        set_user_id(astrologerId);
      });

      // Catch-all listener for debugging
      socket.onAny((event, data) {
        print('Event: $event, Data: $data');
      });

      socket.on('newChatRoom', (data) {
        print(data);

        notificationService.showNotification(
          'New Chat Room',
          'User ${data['userId']} has created a chat room.',
        );

        Provider.of<ChatListBloc>(context, listen: false).add(FetchChatList());
      });

      // socket.on('endChat', (data) {
      //   print('Chat Ended: ${data['chatRoomId']}');
      //   Provider.of<ChatListBloc>(context, listen: false).add(FetchChatList());
      // });

      socket.on('startaudiocall', (data) {

        print('Audio Call Started: ${data['channleid']}');

        callBloc.add(ChatEndedEvent(data['channleid']));

        if(data['callType'] == "video"){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoCallScreen(
                channleid: data['channleid'],
                token:data["token"],
                userId:data["userId"],
                astrologerId :data['astrologerId'],
                uid :data['uid'],
                // callId:data['callId']
              ),
            ),
          );

        }else{

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AudioCallScreen(
                channleid: data['channleid'],
                token:data["token"],
                userId:data["userId"],
                astrologerId :data['astrologerId'],
                uid :data['uid'],
                // callId:data['callId']
              ),
            ),
          );

        }

      });

      // socket.on('chatEnded', (data) {
      //   print('Chat Ended: ${data['chatRoomId']}');
      // });

      socket.on('error', (error) {
        print('Error: $error');
      });

      socket.onDisconnect((_) {
        print('Socket disconnected');
      });
  }

  void sendMessage(String chatRoomId, String message, String senderId) {
    socket.emit('sendMessage', {
      'senderId': senderId,
      'message': message,
      'chatRoomId': chatRoomId,
    });
  }


  void disconnect() {
    socket.disconnect();
  }

  void set_user_id(String userId) {
    socket.emit('set_user_id', userId);
  }

  Future<String?> getChatRoomId(String userId, String astrologerId) async {
    final prefs = await SharedPreferences.getInstance();
    String compositeKey = 'chat_${userId}_$astrologerId';
    return prefs.getString(compositeKey);
  }

  Future<void> removeChatRoomId(String userId, String astrologerId) async {
    final prefs = await SharedPreferences.getInstance();
    String compositeKey = 'chat_${userId}_$astrologerId';
    await prefs.remove(compositeKey);
  }

  Future<void> saveChatRoomId(String chatRoomId, String userId, String astrologerId) async {
    final prefs = await SharedPreferences.getInstance();
    String compositeKey = 'chat_${userId}_$astrologerId';
    prefs.setString(compositeKey, chatRoomId);
  }
}
