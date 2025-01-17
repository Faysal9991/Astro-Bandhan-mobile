import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<Map<String, dynamic>> activeChats = [];

  void addChat(Map<String, dynamic> chatRoom) {
    activeChats.add(chatRoom);
    notifyListeners();
  }

  void removeChat(String chatRoomId) {
    activeChats.removeWhere((chat) => chat['chatRoomId'] == chatRoomId);
    notifyListeners();
  }
}
