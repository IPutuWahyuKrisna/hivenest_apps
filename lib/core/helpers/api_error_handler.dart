import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';

/// Mengubah [DioException] menjadi pesan error yang ramah untuk ditampilkan ke user.
class ApiErrorHandler {
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Koneksi ke server terlalu lama. Periksa jaringan internet Anda.';
      case DioExceptionType.sendTimeout:
        return 'Pengiriman data terlalu lama. Pastikan koneksi internet Anda stabil.';
      case DioExceptionType.receiveTimeout:
        return 'Server terlalu lama merespons. Silakan coba lagi sesaat lagi.';
      case DioExceptionType.badCertificate:
        return 'Terjadi masalah keamanan pada koneksi. Silakan hubungi support.';
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.connectionError:
        return 'Tidak dapat terhubung ke server. Periksa jaringan internet Anda.';
      case DioExceptionType.unknown:
        log(error.error.toString());
        return _handleUnknownError(error);
    }
  }

  static String _handleBadResponse(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      final serverMessage = _extractServerMessage(data);
      if (serverMessage != null) {
        return serverMessage;
      }

      switch (statusCode) {
        case 400:
          return 'Permintaan tidak valid. Periksa kembali data yang Anda masukkan.';
        case 401:
          return 'Sesi Anda telah berakhir. Silakan masuk kembali.';
        case 403:
          return 'Anda tidak memiliki izin untuk mengakses fitur ini.';
        case 404:
          return 'Data yang Anda cari tidak ditemukan.';
        case 409:
          return 'Data ini sudah ada atau sedang digunakan.';
        case 422:
          return 'Sebagian data yang dikirim tidak valid.';
        case 429:
          return 'Terlalu banyak percobaan. Silakan tunggu sesaat sebelum mencoba lagi.';
        case 500:
          return 'Terjadi kesalahan pada server. Tim kami sedang menanganinya.';
        case 502:
          return 'Bad gateway. Silakan coba lagi dalam beberapa menit.';
        case 503:
          return 'Server sedang tidak tersedia. Silakan coba lagi nanti.';
        case 504:
          return 'Server terlalu lama merespons. Silakan coba lagi.';
        default:
          return 'Terjadi kesalahan teknis. Silakan coba lagi nanti.';
      }
    }
    return 'Terjadi masalah pada respons server. Silakan coba lagi.';
  }

  static String? _extractServerMessage(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        if (data['message'] != null && data['message'].toString().isNotEmpty) {
          return data['message'].toString();
        }

        if (data['error'] != null && data['error'] is List) {
          final errors = data['error'] as List;
          if (errors.isNotEmpty) {
            return errors.first.toString();
          }
        }

        // Format error validasi bergaya Laravel
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map<String, dynamic>;
          if (errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
          }
        }
      }
      return null;
    } catch (e) {
      log('Error parsing server message: $e');
      return null;
    }
  }

  static String _handleUnknownError(DioException error) {
    if (error.error is SocketException) {
      return 'Sepertinya Anda sedang offline. Periksa Wi-Fi atau data seluler Anda.';
    } else if (error.error is FormatException) {
      return 'Format data yang diterima tidak sesuai. Akan segera kami perbaiki.';
    } else if (error.error.toString().contains('Certificate')) {
      return 'Koneksi aman tidak dapat dibuat. Silakan hubungi support.';
    } else {
      return 'Terjadi kesalahan. Silakan coba lagi dalam beberapa saat.';
    }
  }
}
