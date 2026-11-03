import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/home_stats.dart';
import '../entities/nearest_harvest.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeStats>> getStats({int topLimit = 5});
  Future<Either<Failure, List<NearestHarvest>>> getNearestHarvests();
}
