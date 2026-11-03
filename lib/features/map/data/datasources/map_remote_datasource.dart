import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/helpers/api_error_handler.dart';
import '../../../../core/network/api_client.dart';
import '../models/hive_detail_model.dart';
import '../models/hive_location_model.dart';

abstract class MapRemoteDataSource {
  Future<List<HiveLocationModel>> getHives();
  Future<HiveDetailModel> getHiveDetail(String id);
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final ApiClient apiClient;
  MapRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<HiveLocationModel>> getHives() async {
    try {
      final response = await apiClient.dio.get(
        '/hives',
        queryParameters: {'type': 'all'},
      );
      final data = response.data['data'] as List<dynamic>;
      return data
          .map((e) => HiveLocationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

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
}
