

import 'package:astrologerapp/Home/tab_item.dart';

abstract class TabEvent {}

class TabChanged extends TabEvent {
  final TabItem tab;

  TabChanged(this.tab);
}
