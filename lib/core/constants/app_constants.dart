class AppConstants {
  AppConstants._();

  static const String appName = 'HiveNest';
  static const String fcmTokenKey = 'fcm_token';

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://v1.honeysibetan.web.id/api',
  );

  static String get imageBaseUrl => baseUrl.replaceAll('/api', '');

  static bool get isDevelopment => appEnv == 'development';
  static bool get isProduction => appEnv == 'production';
}
