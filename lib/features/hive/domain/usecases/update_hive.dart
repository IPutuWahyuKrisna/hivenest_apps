import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/hive_repository.dart';

class UpdateHiveParams {
  final String id;
  final String name;
  final String block;
  final String beeSpecies;
  final String honeyType;
  final double latitude;
  final double longitude;
  final String imageUrl;

  const UpdateHiveParams({
    required this.id,
    required this.name,
    required this.block,
    required this.beeSpecies,
    required this.honeyType,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
  });
}

class UpdateHive {
  final HiveRepository repository;
  UpdateHive(this.repository);

  Future<Either<Failure, void>> call(UpdateHiveParams params) =>
      repository.updateHive(
        id: params.id,
        name: params.name,
        block: params.block,
        beeSpecies: params.beeSpecies,
        honeyType: params.honeyType,
        latitude: params.latitude,
        longitude: params.longitude,
        imageUrl: params.imageUrl,
      );
}
