// import 'package:astrologerapp/chat_history_model.dart';
// import 'package:bloc/bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:equatable/equatable.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;

// import '../dio/Constant.dart';
// import '../dio/dio_client.dart';

// class ChatHistoryState extends Equatable {
//   final bool isLoading;
//   final bool isSuccess;
//   final String? errorMessage;
//   final List<ChatHistory> chatHistory;
//   final bool isSocketConnected;

//   const ChatHistoryState({
//     this.isLoading = false,
//     this.isSuccess = false,
//     this.errorMessage,
//     this.chatHistory = const [],
//     this.isSocketConnected = false,
//   });

//   @override
//   List<Object?> get props =>
//       [isLoading, isSuccess, errorMessage, chatHistory, isSocketConnected];

//   ChatHistoryState copyWith({
//     bool? isLoading,
//     bool? isSuccess,
//     String? errorMessage,
//     List<ChatHistory>? chatHistory,
//     bool? isSocketConnected,
//   }) {
//     return ChatHistoryState(
//       isLoading: isLoading ?? this.isLoading,
//       isSuccess: isSuccess ?? this.isSuccess,
//       errorMessage: errorMessage ?? this.errorMessage,
//       chatHistory: chatHistory ?? this.chatHistory,
//       isSocketConnected: isSocketConnected ?? this.isSocketConnected,
//     );
//   }
// }

// class ChatHistoryCubit extends Cubit<ChatHistoryState> {
//   late IO.Socket socket;
//   final String chatRoomId;
//   final String userId;
//   final Dio dio;

//   ChatHistoryCubit({
//     required this.chatRoomId,
//     required this.userId,
//     required this.dio,
//   }) : super(const ChatHistoryState()) {
//     initializeSocket();
//     fetchInitialMessages();
//   }

//   void initializeSocket() {
//     // Initialize socket connection
//     socket = IO.io(Base_url, {
//       'transports': ['websocket'],
//       'autoConnect': true,
//       'query': {'chatRoomId': chatRoomId}
//     });

//     // Socket event listeners
//     socket.onConnect((_) {
//       print('Socket Connected');
//       emit(state.copyWith(isSocketConnected: true));
//     });

//     socket.onDisconnect((_) {
//       print('Socket Disconnected');
//       emit(state.copyWith(isSocketConnected: false));
//     });

//     // Listen for new messages
//     socket.on('newMessage', (data) {
//       handleNewMessage(data);
//     });

//     // Connect to socket
//     socket.connect();
//   }

//   void handleNewMessage(dynamic data) {
//     try {
//       final newMessage = ChatHistory.fromJson(data);
//       List<ChatHistory> updatedHistory = List.from(state.chatHistory)
//         ..add(newMessage);
//       emit(state.copyWith(chatHistory: updatedHistory));
//     } catch (e) {
//       print('Error handling new message: $e');
//     }
//   }

//   Future<void> fetchInitialMessages() async {
//     emit(state.copyWith(isLoading: true));
//     try {
//       final url = '${Base_url}astrobandhan/v1/user/get/chatsById';

//       final Map<String, dynamic> data = {
//         "chatRoomId": chatRoomId,
//       };

//       final response = await dio.post(url, data: data);
//       final responseData = response.data;

//       if (response.statusCode == 200) {
//         print("data ------->${response.data}");
//         List<ChatHistory> newChatHistory = [];
//         for (var element in responseData["messages"]) {
//           newChatHistory.add(ChatHistory.fromJson(element));
//         }

//         emit(state.copyWith(
//           isLoading: false,
//           isSuccess: true,
//           chatHistory: newChatHistory,
//         ));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           isSuccess: false,
//           errorMessage: responseData['message'],
//         ));
//       }
//     } catch (error) {
//       print('Error fetching messages: $error');
//       emit(state.copyWith(
//         isLoading: false,
//         isSuccess: false,
//         errorMessage: error.toString(),
//       ));
//     }
//   }

//   Future<void> sendMessage(
//     String message,
//     String chatRoomId,
//     String astrologer_id,
//   ) async {
//     if (!state.isSocketConnected) {
//       emit(state.copyWith(errorMessage: 'Socket not connected'));
//       return;
//     }

//     try {
//       final messageData = {
//         'chatRoomId': chatRoomId,
//         'senderId': astrologer_id,
//         'senderType': 'astrologer',
//         'message': message,
//         'timestamp': DateTime.now().toIso8601String(),
//         'messageType': 'text',
//       };

//       // Emit message through socket
//       socket.emit('sendMessage', messageData);

//       // Optimistic update
//       final newMessage = ChatHistory(
//         senderType: "astrologer",
//         message: message,
//         timestamp: DateTime.now(),
//         senderId: astrologer_id,
//       );

//       List<ChatHistory> updatedHistory = List.from(state.chatHistory)
//         ..add(newMessage);
//       emit(state.copyWith(chatHistory: updatedHistory));
//     } catch (error) {
//       print('Error sending message: $error');
//       emit(state.copyWith(
//         errorMessage: "Failed to send message: ${error.toString()}",
//       ));
//     }
//   }

//   @override
//   Future<void> close() {
//     socket.disconnect();
//     socket.dispose();
//     return super.close();
//   }
// }
