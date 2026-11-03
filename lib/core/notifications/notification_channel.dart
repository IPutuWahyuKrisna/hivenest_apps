import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Konstanta channel notifikasi — dipakai bersama oleh semua handler
/// agar ID channel selalu konsisten.
class NotificationChannel {
  NotificationChannel._();

  static const channelId = 'hivenest_default';
  static const channelName = 'HiveNest Notifications';
  static const channelDesc =
      'Notifikasi sarang, jadwal, dan estimasi panen dari HiveNest';

  static const android = AndroidNotificationChannel(
    channelId,
    channelName,
    description: channelDesc,
    importance: Importance.high,
  );

  static const androidDetails = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDesc,
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
  );

  static const details = NotificationDetails(android: androidDetails);
}
