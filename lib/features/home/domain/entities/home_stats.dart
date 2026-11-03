import 'package:equatable/equatable.dart';

class HomeStats extends Equatable {
  final HiveStats hives;
  final HarvestStats harvests;
  final ProductivityStats productivity;

  const HomeStats({
    required this.hives,
    required this.harvests,
    required this.productivity,
  });

  @override
  List<Object> get props => [hives, harvests, productivity];
}

class HiveStats extends Equatable {
  final int total;
  final int harvestedThisMonth;
  final int harvestedLastMonth;
  final int trendPercent;

  const HiveStats({
    required this.total,
    required this.harvestedThisMonth,
    required this.harvestedLastMonth,
    required this.trendPercent,
  });

  @override
  List<Object> get props => [
        total,
        harvestedThisMonth,
        harvestedLastMonth,
        trendPercent,
      ];
}

class HarvestStats extends Equatable {
  /// Berapa kali panen dilakukan bulan ini.
  final int totalCurrentMonth;

  /// Server mengirimnya sebagai `total_volume_ml_current_month` — mililiter.
  final int totalVolumeMlCurrentMonth;

  final List<TopHive> topHives;

  const HarvestStats({
    required this.totalCurrentMonth,
    required this.totalVolumeMlCurrentMonth,
    required this.topHives,
  });

  @override
  List<Object> get props => [
        totalCurrentMonth,
        totalVolumeMlCurrentMonth,
        topHives,
      ];
}

class TopHive extends Equatable {
  final String hiveId;
  final String hiveName;
  final double totalWeightKg;

  const TopHive({
    required this.hiveId,
    required this.hiveName,
    required this.totalWeightKg,
  });

  @override
  List<Object> get props => [hiveId, hiveName, totalWeightKg];
}

class ProductivityStats extends Equatable {
  final int percent;

  const ProductivityStats({required this.percent});

  @override
  List<Object> get props => [percent];
}
