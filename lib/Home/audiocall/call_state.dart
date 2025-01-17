abstract class CallState {}

class CallInitialState extends CallState {}

class ChatEndedState extends CallState {
  final String chatRoomId;

  ChatEndedState(this.chatRoomId);
}
