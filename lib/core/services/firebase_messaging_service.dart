import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../notifications/notification_channel.dart';
import '../notifications/notification_foreground_handler.dart';
import '../notifications/notification_terminated_handler.dart';

class FirebaseMessagingService {
  FirebaseMessagingService(
    this._messaging,
    this._localNotifications,
    this._prefs,
    this._apiClient,
  );

  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final SharedPreferences _prefs;
  final ApiClient _apiClient;

  Future<void> init() async {
    await _setupLocalNotifications();
    await _setupNotificationChannel();

    // Simpan token ke SharedPreferences saat pertama kali
    await _saveToken();

    // Perbarui token jika OS me-refresh (token bisa berubah kapan saja)
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    // Foreground — app sedang dibuka
    NotificationForegroundHandler(_localNotifications).listen();

    // Background tap + Terminated tap
    await NotificationTerminatedHandler.handle(_messaging);

    // iOS: pastikan notifikasi muncul saat foreground
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _saveToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _prefs.setString(AppConstants.fcmTokenKey, token);
      }
    } catch (_) {
      // Silent fail — token akan didapat lagi lewat onTokenRefresh atau saat init berikutnya
    }
  }

  Future<void> _onTokenRefresh(String token) async {
    await _prefs.setString(AppConstants.fcmTokenKey, token);
    try {
      await _apiClient.dio.put(
        '/auth/me/fcm-token',
        data: {'fcm_token': token},
      );
    } catch (_) {
      // Silent fail — token sudah tersimpan lokal, akan dikirim saat login berikutnya
    }
  }

  /// Baca token yang sudah tersimpan di lokal
  String? getSavedToken() => _prefs.getString(AppConstants.fcmTokenKey);

  /// Minta izin notifikasi ke user. Dipanggil dari splash screen supaya
  /// dialog izin muncul di atas UI, bukan di layar kosong sebelum Flutter render.
  Future<void> requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _setupLocalNotifications() async {
    await _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  Future<void> _setupNotificationChannel() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(NotificationChannel.android);
  }

  Future<void> deleteToken() => _messaging.deleteToken();
}
