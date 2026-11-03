import '../../domain/entities/harvest_schedule.dart';

class HiveInfoModel extends HiveInfo {
  const HiveInfoModel({
    required super.name,
    required super.block,
    required super.beeSpecies,
    required super.honeyType,
  });

  factory HiveInfoModel.fromJson(Map<String, dynamic> json) {
    return HiveInfoModel(
      name: json['name'] as String,
      block: json['block'] as String,
      beeSpecies: json['bee_species'] as String? ?? '-',
      honeyType: json['honey_type'] as String? ?? '-',
    );
  }
}

class HarvestScheduleModel extends HarvestSchedule {
  const HarvestScheduleModel({
    required super.id,
    required super.hiveId,
    required super.scheduledAt,
    required super.notes,
    required super.createdAt,
    required super.hive,
  });

  factory HarvestScheduleModel.fromJson(Map<String, dynamic> json) {
    return HarvestScheduleModel(
      id: json['id'] as String,
      hiveId: json['hive_id'] as String,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      notes: json['notes'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      hive: HiveInfoModel.fromJson(json['hive'] as Map<String, dynamic>),
    );
  }
}
