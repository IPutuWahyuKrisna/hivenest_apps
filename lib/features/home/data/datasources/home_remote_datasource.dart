import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/helpers/api_error_handler.dart';
import '../../../../core/network/api_client.dart';
import '../models/home_stats_model.dart';
import '../models/nearest_harvest_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeStatsModel> getStats({int topLimit = 5});
  Future<List<NearestHarvestModel>> getNearestHarvests();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final ApiClient apiClient;

  HomeRemoteDataSourceImpl(this.apiClient);

  @override
  Future<HomeStatsModel> getStats({int topLimit = 5}) async {
    try {
      final response = await apiClient.dio.get(
        '/stats',
        queryParameters: {'topLimit': topLimit.toString()},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      return HomeStatsModel.fromJson(data);
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<NearestHarvestModel>> getNearestHarvests() async {
    try {
      final response = await apiClient.dio.get('/harvest-schedules/nearest');
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => NearestHarvestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }
}
