import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/home_stats.dart';
import '../../domain/entities/nearest_harvest.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, HomeStats>> getStats({int topLimit = 5}) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      final stats = await remoteDataSource.getStats(topLimit: topLimit);
      return Right(stats);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<NearestHarvest>>> getNearestHarvests() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      final harvests = await remoteDataSource.getNearestHarvests();
      return Right(harvests);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
