import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/helpers/api_error_handler.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
  Future<void> logout();
  Future<void> updateFcmToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/sign-in/username',
        data: {'username': username, 'password': password},
      );

      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] ?? body) as Map<String, dynamic>;
      final token = (data['access_token'] ?? data['token'] ?? '') as String;
      final userMap = (data['user'] ?? data) as Map<String, dynamic>;

      return UserModel(
        id: userMap['id']?.toString() ?? '',
        username: userMap['username'] as String? ?? username,
        name:
            userMap['name'] as String? ??
            userMap['fullName'] as String? ??
            userMap['full_name'] as String? ??
            username,
        email: userMap['email'] as String? ?? '',
        image: userMap['image'] as String? ?? '',
        role: userMap['role'] as String? ?? '',
        token: token,
      );
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.dio.post('/auth/sign-out');
    } on DioException catch (e) {
      throw ServerException(
        message: ApiErrorHandler.handleError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    await apiClient.dio.put('/auth/me/fcm-token', data: {'fcm_token': token});
  }
}
