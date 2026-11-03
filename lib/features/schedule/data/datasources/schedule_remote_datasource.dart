import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/helpers/api_error_handler.dart';
import '../../../../core/network/api_client.dart';
import '../models/harvest_schedule_model.dart';

abstract class ScheduleRemoteDataSource {
  Future<List<HarvestScheduleModel>> getHarvestSchedules(String? tab);
}

class ScheduleRemoteDataSourceImpl implements ScheduleRemoteDataSource {
  final ApiClient apiClient;
  ScheduleRemoteDataSourceImpl(this.apiClient);

  /// Tanpa parameter ini server memakai ukuran halaman bawaannya yang kecil,
  /// sehingga tab Jadwal hanya menampilkan sebagian data.
  ///
  /// Plafon sementara — cukup untuk ~70 sarang yang direncanakan. Kalau
  /// suatu saat jumlah jadwal melewati angka ini, peringatan akan tercatat
  /// di log lewat pengecekan `meta.total` di bawah.
  static const int _pageLimit = 99;

  @override
  Future<List<HarvestScheduleModel>> getHarvestSchedules(String? tab) async {
    try {
      final queryParameters = <String, dynamic>{'limit': '$_pageLimit'};
      if (tab != null) queryParameters['tab'] = tab;

      final response = await apiClient.dio.get(
        '/harvest-schedules',
        queryParameters: queryParameters,
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final datas = data['datas'] as List<dynamic>;

      _warnIfTruncated(data['meta'], datas.length);

      return datas
          .map((e) => HarvestScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Menandai kalau server masih menyimpan jadwal yang tidak ikut terambil.
  /// Sengaja hanya dicatat ke log, tidak mengganggu tampilan — ini isyarat
  /// untuk developer bahwa sudah waktunya beralih ke paginasi sungguhan.
  void _warnIfTruncated(dynamic meta, int fetchedCount) {
    if (meta is! Map) return;
    final total = int.tryParse(meta['total']?.toString() ?? '');
    if (total != null && total > fetchedCount) {
      log(
        'Jadwal panen terpotong: $fetchedCount dari $total terambil. '
        'Naikkan _pageLimit atau terapkan paginasi.',
        name: 'ScheduleRemoteDataSource',
      );
    }
  }
}
