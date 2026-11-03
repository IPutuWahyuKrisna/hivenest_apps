import '../../domain/entities/home_stats.dart';

class HomeStatsModel extends HomeStats {
  const HomeStatsModel({
    required super.hives,
    required super.harvests,
    required super.productivity,
  });

  factory HomeStatsModel.fromJson(Map<String, dynamic> json) => HomeStatsModel(
        hives: HiveStatsModel.fromJson(
          json['hives'] as Map<String, dynamic>,
        ),
        harvests: HarvestStatsModel.fromJson(
          json['harvests'] as Map<String, dynamic>,
        ),
        productivity: ProductivityStatsModel.fromJson(
          json['productivity'] as Map<String, dynamic>,
        ),
      );
}

class HiveStatsModel extends HiveStats {
  const HiveStatsModel({
    required super.total,
    required super.harvestedThisMonth,
    required super.harvestedLastMonth,
    required super.trendPercent,
  });

  factory HiveStatsModel.fromJson(Map<String, dynamic> json) => HiveStatsModel(
        total: json['total'] as int? ?? 0,
        harvestedThisMonth: json['harvested_this_month'] as int? ?? 0,
        harvestedLastMonth: json['harvested_last_month'] as int? ?? 0,
        trendPercent: (json['trend_percent'] as num?)?.toInt() ?? 0,
      );
}

class HarvestStatsModel extends HarvestStats {
  const HarvestStatsModel({
    required super.totalCurrentMonth,
    required super.totalVolumeMlCurrentMonth,
    required super.topHives,
  });

  factory HarvestStatsModel.fromJson(Map<String, dynamic> json) =>
      HarvestStatsModel(
        totalCurrentMonth:
            int.tryParse(json['total_current_month']?.toString() ?? '') ?? 0,
        totalVolumeMlCurrentMonth: int.tryParse(
              json['total_volume_ml_current_month']?.toString() ?? '',
            ) ??
            0,
        topHives: (json['top_hives'] as List<dynamic>? ?? [])
            .map((e) => TopHiveModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TopHiveModel extends TopHive {
  const TopHiveModel({
    required super.hiveId,
    required super.hiveName,
    required super.totalWeightKg,
  });

  factory TopHiveModel.fromJson(Map<String, dynamic> json) => TopHiveModel(
        hiveId: json['hive_id'] as String? ?? '',
        hiveName: json['hive_name'] as String? ?? '',
        totalWeightKg: (json['total_weight_kg'] as num?)?.toDouble() ?? 0.0,
      );
}

class ProductivityStatsModel extends ProductivityStats {
  const ProductivityStatsModel({required super.percent});

  factory ProductivityStatsModel.fromJson(Map<String, dynamic> json) =>
      ProductivityStatsModel(
        percent: (json['percent'] as num?)?.toInt() ?? 0,
      );
}
