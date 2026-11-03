import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/hive_detail.dart';
import '../repositories/hive_repository.dart';

class GetHiveDetail implements UseCase<HiveDetail, String> {
  final HiveRepository repository;
  GetHiveDetail(this.repository);

  @override
  Future<Either<Failure, HiveDetail>> call(String params) =>
      repository.getHiveDetail(params);
}
