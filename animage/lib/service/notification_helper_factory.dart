import 'package:animage/service/notification_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelperFactory {
  static NotificationHelper get illustrationDownloadNotificationHelper =>
      NotificationHelper(
          channelId: 'illustration',
          channelName: 'Illustration download',
          channelDescription:
              'For notifications about downloading illustrations',
          importance: Importance.high,
          priority: Priority.high);
}
