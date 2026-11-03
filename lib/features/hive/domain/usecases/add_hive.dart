import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/hive_repository.dart';

class AddHiveParams {
  final String name;
  final String block;
  final String beeSpecies;
  final String honeyType;
  final double latitude;
  final double longitude;
  final String imageUrl;

  const AddHiveParams({
    required this.name,
    required this.block,
    required this.beeSpecies,
    required this.honeyType,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });
}

class AddHive {
  final HiveRepository repository;
  AddHive(this.repository);

  Future<Either<Failure, String>> call(AddHiveParams params) =>
      repository.addHive(
        name: params.name,
        block: params.block,
        beeSpecies: params.beeSpecies,
        honeyType: params.honeyType,
        latitude: params.latitude,
        longitude: params.longitude,
        imageUrl: params.imageUrl,
      );
}
