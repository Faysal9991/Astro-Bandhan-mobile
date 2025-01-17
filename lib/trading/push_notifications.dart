import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    try {
      await _notificationsPlugin.initialize(initializationSettings);
      print('Notifications initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  Future<void> showNotification(String title, String body) async {

    try {
      const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'chat_channel',
        'Chat Notifications',
        importance: Importance.high,
      );

      const NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        0, // Notification ID
        title,
        body,
        notificationDetails,
      );

    } catch (e) {
      print('Error showing notification: $e');
    }

  }

}
