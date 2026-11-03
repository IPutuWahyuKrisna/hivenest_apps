import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/hive_detail.dart';
import '../entities/hive_location.dart';

abstract class MapRepository {
  Future<Either<Failure, List<HiveLocation>>> getHives();
  Future<Either<Failure, HiveDetail>> getHiveDetail(String id);
}
