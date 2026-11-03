import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hive_location.dart';
import '../repositories/map_repository.dart';

class GetHives implements UseCaseNoParams<List<HiveLocation>> {
  final MapRepository repository;
  GetHives(this.repository);

  @override
  Future<Either<Failure, List<HiveLocation>>> call() => repository.getHives();
}
