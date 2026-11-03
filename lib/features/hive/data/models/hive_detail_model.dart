import '../../domain/entities/hive_detail.dart';

class HiveDetailModel extends HiveDetail {
  const HiveDetailModel({
    required super.id,
    required super.name,
    required super.block,
    required super.beeSpecies,
    required super.honeyType,
    required super.latitude,
    required super.longitude,
    super.imageUrl,
    required super.creatorName,
    required super.totalHarvests,
    required super.totalWeightKg,
    super.nextHarvestAt,
  });

  factory HiveDetailModel.fromJson(Map<String, dynamic> json) {
    DateTime? nextHarvest;
    if (json['next_harvest_at'] != null) {
      nextHarvest = DateTime.parse(json['next_harvest_at'] as String);
    }
    return HiveDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      block: json['block'] as String,
      beeSpecies: json['bee_species'] as String? ?? '-',
      honeyType: json['honey_type'] as String? ?? '-',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      creatorName: json['creator_name'] as String,
      totalHarvests: json['total_harvests'] as int? ?? 0,
      totalWeightKg: double.tryParse(json['total_weight_kg']?.toString() ?? '') ?? 0.0,
      nextHarvestAt: nextHarvest,
    );
  }
}
