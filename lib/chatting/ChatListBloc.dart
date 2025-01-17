import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_repository.dart';

// Bloc States
abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<dynamic> chatRooms;
  final int version;

  const ChatListLoaded({required this.chatRooms, required this.version});

  @override
  List<Object?> get props => [chatRooms];
}

class ChatListError extends ChatListState {
  final String message;

  const ChatListError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc Events
abstract class ChatListEvent {
  const ChatListEvent();
}

class FetchChatList extends ChatListEvent {
  const FetchChatList();
}

// Bloc Implementation
class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository chatRepository;

  ChatListBloc(this.chatRepository) : super(ChatListInitial()) {
    on<FetchChatList>((event, emit) async {
      emit(ChatListLoading());

      try {
        await Future.delayed(Duration(seconds: 1));
        final chatRooms = await chatRepository.fetchChatRooms();
        emit(ChatListLoaded(
          chatRooms: List.from(chatRooms),
          version: DateTime.now().millisecondsSinceEpoch,
        )); // New instance
      } catch (e) {
        emit(ChatListError(e.toString()));
      }
    });
  }
}

 
  // Future<void> _onFetchChatList(FetchChatList event, Emitter<ChatListState> emit) async {
  //   print("FetchChatList event received in ChatListBloc.");
  //
  //   emit(ChatListLoading());
  //   try {
  //
  //     final chatRooms = await chatRepository.fetchChatRooms();
  //
  //     if (chatRooms.isNotEmpty) {
  //
  //       emit(ChatListLoaded(chatRooms: List.from(chatRooms)));
  //       print("ChatListLoaded state emitted with chatRooms: $chatRooms");
  //
  //     } else {
  //       emit(ChatListError("No chat rooms found."));
  //       print("ChatListError state emitted: No chat rooms found.");
  //     }
  //   } catch (e) {
  //     emit(ChatListError("Failed to load chat rooms: ${e.toString()}"));
  //     print("ChatListError state emitted: $e");
  //   }
  // }
// }
