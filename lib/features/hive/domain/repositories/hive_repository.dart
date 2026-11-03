import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/hive_detail.dart';
import '../entities/hive_harvester.dart';
import '../entities/hive_schedule.dart';

abstract class HiveRepository {
  Future<Either<Failure, HiveDetail>> getHiveDetail(String id);
  Future<Either<Failure, List<HiveHarvester>>> getHiveHarvesters(String id);
  Future<Either<Failure, List<HiveSchedule>>> getHiveSchedules(String id);
  Future<Either<Failure, String>> uploadImage(String imagePath, String fileName);
  Future<Either<Failure, String>> addHive({
    required String name,
    required String block,
    required String beeSpecies,
    required String honeyType,
    required double latitude,
    required double longitude,
    required String imageUrl,
  });
  Future<Either<Failure, void>> updateHive({
    required String id,
    required String name,
    required String block,
    required String beeSpecies,
    required String honeyType,
    required double latitude,
    required double longitude,
    required String imageUrl,
  });
  Future<Either<Failure, void>> deleteHive(String id);
  Future<Either<Failure, void>> setHarvestSchedule({
    required String hiveId,
    required DateTime scheduledAt,
    required String notes,
  });
  Future<Either<Failure, void>> recordHarvest({
    required String scheduleId,
    required int volumeMl,
    required String notes,
    required String imageUrl,
  });
}
