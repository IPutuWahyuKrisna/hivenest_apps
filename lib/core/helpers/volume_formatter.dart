/// Mengubah volume madu dalam mililiter menjadi teks yang enak dibaca.
///
/// Server menyimpan semuanya dalam mililiter (`volume_ml`, `total_volume_ml`),
/// tapi angka seperti 8500 lebih mudah dicerna sebagai "8,5 L". Helper ini
/// dipakai di semua tempat yang menampilkan volume supaya formatnya seragam.
class VolumeFormatter {
  VolumeFormatter._();

  static const int _mlPerLiter = 1000;

  /// Di bawah 1 liter tetap ditampilkan sebagai mililiter, selebihnya
  /// dikonversi ke liter dengan satu angka di belakang koma.
  ///
  /// Contoh: `500` → "500 ml", `8500` → "8,5 L", `9000` → "9 L".
  static String format(int? volumeMl) {
    final value = volumeMl ?? 0;
    if (value < _mlPerLiter) return '$value ml';

    final liters = value / _mlPerLiter;
    // Buang ",0" supaya 9000 ml tampil "9 L", bukan "9,0 L".
    final text = liters
        .toStringAsFixed(1)
        .replaceFirst(RegExp(r'\.0$'), '')
        .replaceAll('.', ',');
    return '$text L';
  }
}
