import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hive_harvester.dart';
import '../repositories/hive_repository.dart';

class GetHiveHarvesters implements UseCase<List<HiveHarvester>, String> {
  final HiveRepository repository;
  GetHiveHarvesters(this.repository);

  @override
  Future<Either<Failure, List<HiveHarvester>>> call(String params) =>
      repository.getHiveHarvesters(params);
}
