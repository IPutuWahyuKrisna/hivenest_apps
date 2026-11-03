import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/hive_detail.dart';
import '../../domain/entities/hive_harvester.dart';
import '../../domain/entities/hive_schedule.dart';
import '../../domain/repositories/hive_repository.dart';
import '../datasources/hive_remote_datasource.dart';

class HiveRepositoryImpl implements HiveRepository {
  final HiveRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HiveRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, HiveDetail>> getHiveDetail(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      return Right(await remoteDataSource.getHiveDetail(id));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // Jaring pengaman untuk kesalahan tak terduga, misalnya format JSON dari
      // server berubah. Tanpa ini, error lolos keluar dari bloc dan UI
      // menggantung di layar loading tanpa pesan apa pun.
      return Left(ServerFailure(message: 'Gagal memproses data: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HiveHarvester>>> getHiveHarvesters(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      return Right(await remoteDataSource.getHiveHarvesters(id));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // Jaring pengaman untuk kesalahan tak terduga, misalnya format JSON dari
      // server berubah. Tanpa ini, error lolos keluar dari bloc dan UI
      // menggantung di layar loading tanpa pesan apa pun.
      return Left(ServerFailure(message: 'Gagal memproses data: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HiveSchedule>>> getHiveSchedules(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      return Right(await remoteDataSource.getHiveSchedules(id));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // Jaring pengaman untuk kesalahan tak terduga, misalnya format JSON dari
      // server berubah. Tanpa ini, error lolos keluar dari bloc dan UI
      // menggantung di layar loading tanpa pesan apa pun.
      return Left(ServerFailure(message: 'Gagal memproses data: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(String imagePath, String fileName) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      final url = await remoteDataSource.uploadImage(imagePath, fileName);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // Jaring pengaman untuk kesalahan tak terduga, misalnya format JSON dari
      // server berubah. Tanpa ini, error lolos keluar dari bloc dan UI
      // menggantung di layar loading tanpa pesan apa pun.
      return Left(ServerFailure(message: 'Gagal memproses data: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> addHive({
    required String name,
    required String block,
    required String beeSpecies,
    required String honeyType,
    required double latitude,
    required double longitude,
    required String imageUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      final id = await remoteDataSource.addHive(
        name: name,
        block: block,
        beeSpecies: beeSpecies,
        honeyType: honeyType,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
      );
      return Right(id);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // Jaring pengaman untuk kesalahan tak terduga, misalnya format JSON dari
      // server berubah. Tanpa ini, error lolos keluar dari bloc dan UI
      // menggantung di layar loading tanpa pesan apa pun.
      return Left(ServerFailure(message: 'Gagal memproses data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateHive({
    required String id,
    required String name,
    required String block,
    required String beeSpecies,
    required String honeyType,
    required double latitude,
    required double longitude,
    required String imageUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      await remoteDataSource.updateHive(
        id: id,
        name: name,
        block: block,
        beeSpecies: beeSpecies,
        honeyType: honeyType,
        latitude: latitude,
        longitude: longitude,
        imageUrl: imageUrl,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // Jaring pengaman untuk kesalahan tak terduga, misalnya format JSON dari
      // server berubah. Tanpa ini, error lolos keluar dari bloc dan UI
      // menggantung di layar loading tanpa pesan apa pun.
      return Left(ServerFailure(message: 'Gagal memproses data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHive(String id) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      await remoteDataSource.deleteHive(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // Jaring pengaman untuk kesalahan tak terduga, misalnya format JSON dari
      // server berubah. Tanpa ini, error lolos keluar dari bloc dan UI
      // menggantung di layar loading tanpa pesan apa pun.
      return Left(ServerFailure(message: 'Gagal memproses data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setHarvestSchedule({
    required String hiveId,
    required DateTime scheduledAt,
    required String notes,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      await remoteDataSource.setHarvestSchedule(
        hiveId: hiveId,
        scheduledAt: scheduledAt,
        notes: notes,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // Jaring pengaman untuk kesalahan tak terduga, misalnya format JSON dari
      // server berubah. Tanpa ini, error lolos keluar dari bloc dan UI
      // menggantung di layar loading tanpa pesan apa pun.
      return Left(ServerFailure(message: 'Gagal memproses data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> recordHarvest({
    required String scheduleId,
    required int volumeMl,
    required String notes,
    required String imageUrl,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Tidak ada koneksi internet'));
    }
    try {
      await remoteDataSource.recordHarvest(
        scheduleId: scheduleId,
        volumeMl: volumeMl,
        notes: notes,
        imageUrl: imageUrl,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      // Jaring pengaman untuk kesalahan tak terduga, misalnya format JSON dari
      // server berubah. Tanpa ini, error lolos keluar dari bloc dan UI
      // menggantung di layar loading tanpa pesan apa pun.
      return Left(ServerFailure(message: 'Gagal memproses data: $e'));
    }
  }
}
