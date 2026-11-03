import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/hive_repository.dart';

class DeleteHive {
  final HiveRepository repository;
  DeleteHive(this.repository);

  Future<Either<Failure, void>> call(String id) => repository.deleteHive(id);
}
