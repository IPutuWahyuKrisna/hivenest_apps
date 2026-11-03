import '../../domain/entities/nearest_harvest.dart';

class NearestHarvestModel extends NearestHarvest {
  const NearestHarvestModel({
    required super.id,
    required super.scheduledAt,
    required super.daysUntil,
    required super.hive,
    required super.notes,
  });

  factory NearestHarvestModel.fromJson(Map<String, dynamic> json) {
    return NearestHarvestModel(
      id: json['id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      daysUntil: (json['days_until'] as num?)?.toInt() ?? 0,
      hive: NearestHarvestHiveModel.fromJson(
        json['hive'] as Map<String, dynamic>,
      ),
      notes: json['notes'] as String? ?? '',
    );
  }
}

class NearestHarvestHiveModel extends NearestHarvestHive {
  const NearestHarvestHiveModel({
    required super.id,
    required super.name,
    required super.block,
    required super.beeSpecies,
    required super.honeyType,
  });

  factory NearestHarvestHiveModel.fromJson(Map<String, dynamic> json) {
    return NearestHarvestHiveModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      block: json['block'] as String? ?? '',
      beeSpecies: json['bee_species'] as String? ?? '',
      honeyType: json['honey_type'] as String? ?? '',
    );
  }
}
