import 'package:equatable/equatable.dart';

class HiveLocation extends Equatable {
  final String id;
  final String name;
  final String block;
  final String beeSpecies;
  final String honeyType;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String creatorName;

  const HiveLocation({
    required this.id,
    required this.name,
    required this.block,
    required this.beeSpecies,
    required this.honeyType,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.creatorName,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        block,
        beeSpecies,
        honeyType,
        latitude,
        longitude,
        imageUrl,
        creatorName,
      ];
}
