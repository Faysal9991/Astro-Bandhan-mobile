import 'dart:developer';
import 'package:astrologerapp/helper/left_to_right.dart';
import 'package:astrologerapp/helper/right_to_left.dart';
import 'package:flutter/material.dart';

showLog(message) {
  log("APP SAYS: $message");
}

class Helper {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static toScreen(screen) {
    Navigator.push(
        navigatorKey.currentState!.context, SlideRightToLeft(page: screen));
  }

  static back() {
    Navigator.of(navigatorKey.currentState!.context).pop();
  }

  static toReplacementScreenSlideRightToLeft(screen) {
    Navigator.pushReplacement(
        navigatorKey.currentState!.context, SlideRightToLeft(page: screen));
  }

  static toReplacementScreenSlideLeftToRight(screen) {
    Navigator.pushReplacement(
        navigatorKey.currentState!.context, SlideLeftToRight(page: screen));
  }

  static toRemoveUntilScreen(screen) {
    Navigator.pushAndRemoveUntil(navigatorKey.currentState!.context,
        SlideRightToLeft(page: screen), (route) => false);
  }

  static onWillPop(screen) {
    Navigator.pushAndRemoveUntil(navigatorKey.currentState!.context,
        SlideRightToLeft(page: screen), (route) => false);
  }

  static showSnack(context, message,
      {color = Colors.blue, duration = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        backgroundColor: color,
        duration: Duration(seconds: duration)));
  }

  static circularProgress(context) {
    const Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.blue)));
  }

  static boxDecoration(Color color, double radius) {
    BoxDecoration(
        color: color, borderRadius: BorderRadius.all(Radius.circular(radius)));
  }
}
