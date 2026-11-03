import '../../domain/entities/hive_location.dart';

class HiveLocationModel extends HiveLocation {
  const HiveLocationModel({
    required super.id,
    required super.name,
    required super.block,
    required super.beeSpecies,
    required super.honeyType,
    required super.latitude,
    required super.longitude,
    super.imageUrl,
    required super.creatorName,
  });

  factory HiveLocationModel.fromJson(Map<String, dynamic> json) {
    return HiveLocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      block: json['block'] as String,
      beeSpecies: json['bee_species'] as String? ?? '-',
      honeyType: json['honey_type'] as String? ?? '-',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      creatorName: json['creator_name'] as String,
    );
  }
}
