import 'package:equatable/equatable.dart';

class HiveHarvester extends Equatable {
  final String harvesterId;
  final String harvesterName;
  final int totalHarvests;

  /// Server mengirimnya sebagai `total_volume_ml` — mililiter, bukan kilogram.
  final int totalVolumeMl;

  const HiveHarvester({
    required this.harvesterId,
    required this.harvesterName,
    required this.totalHarvests,
    required this.totalVolumeMl,
  });

  @override
  List<Object?> get props =>
      [harvesterId, harvesterName, totalHarvests, totalVolumeMl];
}
