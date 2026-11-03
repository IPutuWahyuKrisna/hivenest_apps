import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/harvest_schedule.dart';

abstract class ScheduleRepository {
  Future<Either<Failure, List<HarvestSchedule>>> getHarvestSchedules(
      String? tab);
}
