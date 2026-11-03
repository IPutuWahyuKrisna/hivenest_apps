import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/harvest_schedule.dart';
import '../../domain/repositories/schedule_repository.dart';
import '../datasources/schedule_remote_datasource.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<HarvestSchedule>>> getHarvestSchedules(
      String? tab) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      return Right(await remoteDataSource.getHarvestSchedules(tab));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
