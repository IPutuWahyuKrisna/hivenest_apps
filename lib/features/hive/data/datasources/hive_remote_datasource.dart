import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/helpers/api_error_handler.dart';
import '../../../../core/network/api_client.dart';
import '../models/hive_detail_model.dart';
import '../models/hive_harvester_model.dart';
import '../models/hive_schedule_model.dart';

abstract class HiveRemoteDataSource {
  Future<HiveDetailModel> getHiveDetail(String id);
  Future<List<HiveHarvesterModel>> getHiveHarvesters(String id);
  Future<List<HiveScheduleModel>> getHiveSchedules(String id);
  Future<String> uploadImage(String imagePath, String fileName);
  Future<String> addHive({
    required String name,
    required String block,
    required String beeSpecies,
    required String honeyType,
    required double latitude,
    required double longitude,
    required String imageUrl,
  });
  Future<void> updateHive({
    required String id,
    required String name,
    required String block,
    required String beeSpecies,
    required String honeyType,
    required double latitude,
    required double longitude,
    required String imageUrl,
  });
  Future<void> deleteHive(String id);
  Future<void> setHarvestSchedule({
    required String hiveId,
    required DateTime scheduledAt,
    required String notes,
  });
  Future<void> recordHarvest({
    required String scheduleId,
    required int volumeMl,
    required String notes,
    required String imageUrl,
  });
}

class HiveRemoteDataSourceImpl implements HiveRemoteDataSource {
  final ApiClient apiClient;
  HiveRemoteDataSourceImpl(this.apiClient);

  @override
  Future<HiveDetailModel> getHiveDetail(String id) async {
    try {
      final response = await apiClient.dio.get('/hives/$id');
      final data = response.data['data'] as Map<String, dynamic>;
      return HiveDetailModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<HiveHarvesterModel>> getHiveHarvesters(String id) async {
    try {
      final response = await apiClient.dio.get('/hives/$id/harvesters');
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => HiveHarvesterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<HiveScheduleModel>> getHiveSchedules(String id) async {
    try {
      final response = await apiClient.dio.get(
        '/hives/$id/schedules',
        queryParameters: {'page': '1', 'limit': '20'},
      );
      final datas = response.data['data']['datas'] as List<dynamic>;
      return datas
          .map((e) => HiveScheduleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> uploadImage(String imagePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath, filename: fileName),
      });
      final response = await apiClient.dio.post(
        '/uploads/image',
        data: formData,
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return data['url'] as String;
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<String> addHive({
    required String name,
    required String block,
    required String beeSpecies,
    required String honeyType,
    required double latitude,
    required double longitude,
    required String imageUrl,
  }) async {
    try {
      final response = await apiClient.dio.post('/hives', data: {
        'name': name,
        'block': block,
        'bee_species': beeSpecies,
        'honey_type': honeyType,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
      });
      final data = response.data['data'] as Map<String, dynamic>;
      return data['id'] as String;
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> updateHive({
    required String id,
    required String name,
    required String block,
    required String beeSpecies,
    required String honeyType,
    required double latitude,
    required double longitude,
    required String imageUrl,
  }) async {
    try {
      await apiClient.dio.put('/hives/$id', data: {
        'name': name,
        'block': block,
        'bee_species': beeSpecies,
        'honey_type': honeyType,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
      });
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> deleteHive(String id) async {
    try {
      await apiClient.dio.delete('/hives/$id');
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> setHarvestSchedule({
    required String hiveId,
    required DateTime scheduledAt,
    required String notes,
  }) async {
    try {
      final y = scheduledAt.year.toString().padLeft(4, '0');
      final m = scheduledAt.month.toString().padLeft(2, '0');
      final d = scheduledAt.day.toString().padLeft(2, '0');
      await apiClient.dio.post('/harvest-schedules', data: {
        'hiveId': hiveId,
        'scheduledAt': '$y-$m-$d',
        'notes': notes,
      });
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> recordHarvest({
    required String scheduleId,
    required int volumeMl,
    required String notes,
    required String imageUrl,
  }) async {
    try {
      await apiClient.dio.post(
        '/harvest-schedules/$scheduleId/harvest',
        data: {
          'volume_ml': volumeMl,
          'notes': notes,
          'image_url': imageUrl,
        },
      );
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
