import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  final String channelId;
  final String channelName;
  final String channelDescription;
  final Importance importance;
  final Priority priority;

  late FlutterLocalNotificationsPlugin localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationHelper(
      {required this.channelId,
      required this.channelName,
      this.channelDescription = '',
      this.importance = Importance.defaultImportance,
      this.priority = Priority.defaultPriority});

  void sendAndroidNotification(int id, String title, String? body,
      {bool onlyAlertOnce = false, StyleInformation? styleInformation}) {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channelId, channelName,
            channelDescription: channelDescription,
            importance: importance,
            priority: priority,
            onlyAlertOnce: onlyAlertOnce,
            styleInformation: styleInformation);

    localNotificationsPlugin.show(id, title, body,
        NotificationDetails(android: androidNotificationDetails));
  }

  void sendAndroidProgressNotification(int id, String title, String? body,
      {bool onlyAlertOnce = false, StyleInformation? styleInformation}) {
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(channelId, channelName,
            channelDescription: channelDescription,
            importance: importance,
            priority: priority,
            showProgress: true,
            indeterminate: true,
            onlyAlertOnce: onlyAlertOnce,
            styleInformation: styleInformation);

    localNotificationsPlugin.show(id, title, body,
        NotificationDetails(android: androidNotificationDetails));
  }

  void sendIOSNotification(int id, String title, String? body,
      {String? subTitle,
      String? threadIdentifier,
      bool presentAlert = false,
      bool presentBadge = false,
      bool presentSound = false}) {
    DarwinNotificationDetails notificationDetails = DarwinNotificationDetails(
      presentAlert: presentAlert,
      presentBadge: presentBadge,
      presentSound: presentSound,
      subtitle: subTitle,
      threadIdentifier: threadIdentifier,
    );

    localNotificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(iOS: notificationDetails),
    );
  }

  void cancelNotification(int id) {
    localNotificationsPlugin.cancel(id);
  }
}
