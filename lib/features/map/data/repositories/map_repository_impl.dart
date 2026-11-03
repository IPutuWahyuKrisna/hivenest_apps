import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/hive_detail.dart';
import '../../domain/entities/hive_location.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/map_remote_datasource.dart';

class MapRepositoryImpl implements MapRepository {
  final MapRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MapRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<HiveLocation>>> getHives() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      final hives = await remoteDataSource.getHives();
      return Right(hives);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, HiveDetail>> getHiveDetail(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      final detail = await remoteDataSource.getHiveDetail(id);
      return Right(detail);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
