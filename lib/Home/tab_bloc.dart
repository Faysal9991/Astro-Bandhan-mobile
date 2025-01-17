import 'package:astrologerapp/Home/tab_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'tab_state.dart';
import 'tab_event.dart';

class TabBloc extends Bloc<TabEvent, TabState> {
  TabBloc() : super(TabState(TabItem.home)) {
    // Register event handlers
    on<TabChanged>((event, emit) {
      emit(TabState(event.tab)); // Update state based on the tab in the event
    });
  }
}
