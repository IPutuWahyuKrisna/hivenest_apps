import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_channel.dart';

/// Handler untuk kondisi app BACKGROUND.
///
/// Dijalankan di Dart isolate terpisah — tidak bisa akses Navigator, BLoC,
/// atau state app utama. Hanya boleh: show notifikasi, simpan ke storage,
/// atau panggil API ringan.
///
/// Wajib top-level function dan diberi @pragma('vm:entry-point').
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage message) async {
  // Isolate baru butuh init Firebase sendiri
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
  }

  await NotificationBackgroundHandler.show(message);
}

class NotificationBackgroundHandler {
  NotificationBackgroundHandler._();

  /// Tampilkan notifikasi lokal saat pesan FCM diterima di background.
  /// FCM otomatis menampilkan notifikasi dari `notification` payload,
  /// tapi ini memastikan data-only payload juga tampil.
  static Future<void> show(RemoteMessage message) async {
    final notification = message.notification;

    // Jika ada notification payload, FCM sudah handle tampilan otomatis.
    // Handle data-only message di sini agar tetap muncul.
    if (notification != null) return;

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    final title = message.data['title'] as String? ?? 'HiveNest';
    final body = message.data['body'] as String? ?? '';

    await plugin.show(
      message.hashCode,
      title,
      body,
      NotificationChannel.details,
    );
  }
}
