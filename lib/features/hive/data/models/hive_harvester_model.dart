import '../../domain/entities/hive_harvester.dart';

class HiveHarvesterModel extends HiveHarvester {
  const HiveHarvesterModel({
    required super.harvesterId,
    required super.harvesterName,
    required super.totalHarvests,
    required super.totalVolumeMl,
  });

  /// Bentuk response `GET /hives/{id}/harvesters`:
  /// ```json
  /// { "harvester_id": "...", "harvester_name": "...",
  ///   "total_harvests": 1, "total_volume_ml": 500 }
  /// ```
  /// Angka dibaca lewat `toString()` lalu `tryParse` supaya tetap aman kalau
  /// server mengirimnya sebagai string.
  factory HiveHarvesterModel.fromJson(Map<String, dynamic> json) {
    return HiveHarvesterModel(
      harvesterId: json['harvester_id']?.toString() ?? '',
      harvesterName: json['harvester_name']?.toString() ?? '-',
      totalHarvests:
          int.tryParse(json['total_harvests']?.toString() ?? '') ?? 0,
      totalVolumeMl:
          int.tryParse(json['total_volume_ml']?.toString() ?? '') ?? 0,
    );
  }
}
