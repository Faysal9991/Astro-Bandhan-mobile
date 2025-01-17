abstract class CallEvent {}

class ChatEndedEvent extends CallEvent {
  final String chatRoomId;

  ChatEndedEvent(this.chatRoomId);
}
