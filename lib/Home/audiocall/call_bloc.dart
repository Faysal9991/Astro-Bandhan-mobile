import 'package:flutter_bloc/flutter_bloc.dart';
import 'call_event.dart';
import 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallState> {
  CallBloc() : super(CallInitialState()) {
    on<ChatEndedEvent>((event, emit) {
      emit(ChatEndedState(event.chatRoomId));
    });
  }
}
