import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hive_detail.dart';
import '../repositories/map_repository.dart';

class GetHiveDetail implements UseCase<HiveDetail, String> {
  final MapRepository repository;
  GetHiveDetail(this.repository);

  @override
  Future<Either<Failure, HiveDetail>> call(String params) =>
      repository.getHiveDetail(params);
}
