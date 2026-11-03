import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/nearest_harvest.dart';
import '../repositories/home_repository.dart';

class GetNearestHarvests implements UseCaseNoParams<List<NearestHarvest>> {
  final HomeRepository repository;
  GetNearestHarvests(this.repository);

  @override
  Future<Either<Failure, List<NearestHarvest>>> call() =>
      repository.getNearestHarvests();
}
