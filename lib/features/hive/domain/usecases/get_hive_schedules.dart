import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hive_schedule.dart';
import '../repositories/hive_repository.dart';

class GetHiveSchedules implements UseCase<List<HiveSchedule>, String> {
  final HiveRepository repository;
  GetHiveSchedules(this.repository);

  @override
  Future<Either<Failure, List<HiveSchedule>>> call(String params) =>
      repository.getHiveSchedules(params);
}
