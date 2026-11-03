import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, User>> login({
    required String username,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(const NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      final userModel = await remoteDataSource.login(
        username: username,
        password: password,
      );
      await localDataSource.cacheUser(userModel);
      if (userModel.token.isNotEmpty) {
        apiClient.setAuthToken(userModel.token);
      }
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    // Panggilan ke server bersifat best-effort. Kalau gagal (offline, server
    // error, token sudah invalid), logout tetap dianggap berhasil dari sisi
    // user: sesi lokal dibersihkan dan user diarahkan ke halaman login.
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Silent fail — jangan blokir logout hanya karena server tidak terjangkau.
    }

    // Selalu dijalankan, apapun hasil panggilan di atas.
    await localDataSource.clearUser();
    apiClient.clearAuthToken();
    return const Right(null);
  }

  @override
  Future<void> clearLocalSession() async {
    await localDataSource.clearUser();
    apiClient.clearAuthToken();
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      if (userModel == null) {
        return Left(const CacheFailure(message: 'Sesi tidak ditemukan'));
      }
      if (userModel.token.isNotEmpty) {
        apiClient.setAuthToken(userModel.token);
      }
      return Right(userModel);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    try {
      await remoteDataSource.updateFcmToken(token);
    } catch (_) {
      // Silent fail — tidak blokir login jika gagal
    }
  }
}
