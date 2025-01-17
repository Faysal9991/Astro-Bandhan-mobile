import 'package:flutter/material.dart';

class NotificationHandler extends ChangeNotifier {
  bool triggerButton = false;

  void receiveNotification() {
    triggerButton = true;
    notifyListeners();
  }

  void resetTrigger() {
    triggerButton = false;
    notifyListeners();
  }
}