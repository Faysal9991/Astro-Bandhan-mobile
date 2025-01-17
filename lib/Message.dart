class Message {
  final String senderType;
  final String senderId;
  final String message;
  final DateTime timestamp;
  final String messageType;


  Message({
    required this.senderType,
    required this.senderId,
    required this.message,
    required this.timestamp,
    required this.messageType
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderType: json['senderType'],
      senderId: json['senderId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      messageType: json['messageType'],
    );
  }
}

class ChatRoom {
  final String id;
  final String chatRoomId;
  final List<Message> messages;

  ChatRoom({
    required this.id,
    required this.chatRoomId,
    required this.messages,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['_id'],
      chatRoomId: json['chatRoomId'],
      messages: (json['messages'] as List<dynamic>)
          .map((msg) => Message.fromJson(msg))
          .toList(),
    );
  }

}
