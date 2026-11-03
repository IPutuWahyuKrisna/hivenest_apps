import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/hive_repository.dart';

class UploadImage {
  final HiveRepository repository;
  UploadImage(this.repository);

  Future<Either<Failure, String>> call(String imagePath, String fileName) =>
      repository.uploadImage(imagePath, fileName);
}
