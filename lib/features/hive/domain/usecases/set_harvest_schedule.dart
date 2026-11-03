import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/hive_repository.dart';

class SetHarvestSchedule {
  final HiveRepository repository;
  SetHarvestSchedule(this.repository);

  Future<Either<Failure, void>> call({
    required String hiveId,
    required DateTime scheduledAt,
    required String notes,
  }) =>
      repository.setHarvestSchedule(
        hiveId: hiveId,
        scheduledAt: scheduledAt,
        notes: notes,
      );
}
