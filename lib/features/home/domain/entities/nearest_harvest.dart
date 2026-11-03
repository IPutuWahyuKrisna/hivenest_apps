import 'package:equatable/equatable.dart';

class NearestHarvest extends Equatable {
  final String id;
  final DateTime scheduledAt;
  final int daysUntil;
  final NearestHarvestHive hive;
  final String notes;

  const NearestHarvest({
    required this.id,
    required this.scheduledAt,
    required this.daysUntil,
    required this.hive,
    required this.notes,
  });

  /// Ambang batas ini sengaja disamakan dengan [HiveDetail.harvestStatus]
  /// supaya label di beranda dan di halaman detail sarang tidak berbeda.
  static const int readyThresholdDays = 7;
  static const int almostReadyThresholdDays = 30;

  /// Jadwal yang tanggalnya sudah lewat ikut dianggap siap panen.
  bool get isReady => daysUntil <= readyThresholdDays;

  bool get isOverdue => daysUntil < 0;

  /// Hanya jadwal dalam 30 hari ke depan yang layak tampil di beranda.
  /// Selebihnya masih bisa dilihat di tab Jadwal.
  bool get isDueSoon => daysUntil <= almostReadyThresholdDays;

  String get statusLabel => isReady ? 'Siap Panen' : 'Hampir Siap';

  String get daysUntilLabel {
    if (isOverdue) return 'Sudah lewat';
    if (daysUntil == 0) return 'Hari ini';
    return '$daysUntil hari lagi';
  }

  @override
  List<Object?> get props => [id, scheduledAt, daysUntil, hive, notes];
}

class NearestHarvestHive extends Equatable {
  final String id;
  final String name;
  final String block;
  final String beeSpecies;
  final String honeyType;

  const NearestHarvestHive({
    required this.id,
    required this.name,
    required this.block,
    required this.beeSpecies,
    required this.honeyType,
  });

  @override
  List<Object?> get props => [id, name, block, beeSpecies, honeyType];
}
