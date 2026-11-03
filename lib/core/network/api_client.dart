import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/app_constants.dart';

typedef UnauthorizedCallback = void Function();

class ApiClient {
  late final Dio dio;
  UnauthorizedCallback? onUnauthorized;
  bool _handlingUnauthorized = false;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.addAll([
      _AuthInterceptor(this),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
      ),
    ]);
  }

  void setAuthToken(String token) {
    _handlingUnauthorized = false;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}

class _AuthInterceptor extends Interceptor {
  final ApiClient client;
  _AuthInterceptor(this.client);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401 && !client._handlingUnauthorized) {
      client._handlingUnauthorized = true;
      client.clearAuthToken();
      client.onUnauthorized?.call();
    }
    handler.next(err);
  }
}
