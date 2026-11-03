import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Kompres foto sarang sebelum diupload karena server menolak file > 400 KB.
class ImageCompressHelper {
  static const int maxSizeBytes = 400 * 1024;

  static const _attempts = [
    (quality: 90, dimension: 1600),
    (quality: 80, dimension: 1280),
    (quality: 70, dimension: 1024),
    (quality: 60, dimension: 800),
    (quality: 45, dimension: 640),
    (quality: 30, dimension: 480),
  ];

  /// Mengembalikan path file yang sudah dikompres di bawah [maxSizeBytes].
  /// Jika file asli sudah cukup kecil, path aslinya dikembalikan apa adanya.
  static Future<String> compressUnderLimit(String sourcePath) async {
    final sourceFile = File(sourcePath);
    if (await sourceFile.length() <= maxSizeBytes) return sourcePath;

    final tempDir = await getTemporaryDirectory();
    String? bestResultPath;

    for (final attempt in _attempts) {
      final targetPath = path.join(
        tempDir.path,
        'hive_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );

      final compressed = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: attempt.quality,
        minWidth: attempt.dimension,
        minHeight: attempt.dimension,
        format: CompressFormat.jpeg,
      );
      if (compressed == null) continue;

      bestResultPath = compressed.path;
      if (await File(compressed.path).length() <= maxSizeBytes) {
        return compressed.path;
      }
    }

    return bestResultPath ?? sourcePath;
  }
}
