import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/harvest_schedule.dart';
import '../repositories/schedule_repository.dart';

class GetHarvestSchedules implements UseCase<List<HarvestSchedule>, String?> {
  final ScheduleRepository repository;
  GetHarvestSchedules(this.repository);

  @override
  Future<Either<Failure, List<HarvestSchedule>>> call(String? params) =>
      repository.getHarvestSchedules(params);
}
