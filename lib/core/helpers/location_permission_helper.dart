import 'package:geolocator/geolocator.dart';

/// Minta izin akses lokasi ke user. Dipanggil sekali di splash screen,
/// sebelum user sampai ke halaman login, supaya izin sudah tersedia
/// saat user mulai pakai fitur Peta/Tambah Sarang.
class LocationPermissionHelper {
  static Future<void> request() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }
}
