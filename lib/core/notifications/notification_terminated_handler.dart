import 'package:firebase_messaging/firebase_messaging.dart';

/// Handler untuk kondisi app TERMINATED (di-close / tidak berjalan sama sekali).
///
/// Saat user tap notifikasi dari state terminated, OS akan membuka app dari awal.
/// `getInitialMessage()` menangkap pesan tersebut setelah app selesai init.
///
/// Saat background dan user tap notifikasi, `onMessageOpenedApp` yang menangkap.
class NotificationTerminatedHandler {
  NotificationTerminatedHandler._();

  /// Panggil sekali saat app selesai init (setelah Firebase.initializeApp).
  /// Menangkap notifikasi yang men-trigger launch app dari state terminated.
  static Future<void> handle(FirebaseMessaging messaging) async {
    // Terminated: app dibuka pertama kali karena user tap notifikasi
    final message = await messaging.getInitialMessage();
    if (message != null) {
      _processMessage(message, source: 'terminated');
    }

    // Background: app sudah jalan di background, user tap notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _processMessage(message, source: 'background'),
    );
  }

  static void _processMessage(RemoteMessage message, {required String source}) {
    // Tambahkan logika navigasi di sini berdasarkan isi data payload.
    // Contoh:
    //
    // final route = message.data['route'];
    // if (route == 'harvest') {
    //   navigatorKey.currentState?.pushNamed('/harvest');
    // }
    //
    // Gunakan GlobalKey<NavigatorState> atau GoRouter untuk navigasi.
  }
}
