import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_channel.dart';

/// Handler untuk kondisi app FOREGROUND (app sedang dibuka user).
///
/// FCM tidak menampilkan notifikasi secara otomatis saat foreground,
/// jadi kita tampilkan manual lewat flutter_local_notifications.
class NotificationForegroundHandler {
  const NotificationForegroundHandler(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  /// Mulai mendengarkan pesan FCM saat foreground.
  void listen() {
    FirebaseMessaging.onMessage.listen(_onMessage);
  }

  void _onMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationChannel.details,
    );
  }
}
