import 'package:equatable/equatable.dart';

class HiveDetail extends Equatable {
  final String id;
  final String name;
  final String block;
  final String beeSpecies;
  final String honeyType;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String creatorName;
  final int totalHarvests;
  final double totalWeightKg;
  final DateTime? nextHarvestAt;

  const HiveDetail({
    required this.id,
    required this.name,
    required this.block,
    required this.beeSpecies,
    required this.honeyType,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.creatorName,
    required this.totalHarvests,
    required this.totalWeightKg,
    this.nextHarvestAt,
  });

  String get harvestStatus {
    if (nextHarvestAt == null) return 'Monitoring';
    final diff = nextHarvestAt!.difference(DateTime.now()).inDays;
    if (diff <= 7) return 'Siap Panen';
    if (diff <= 30) return 'Hampir Siap';
    return 'Monitoring';
  }

  String get formattedNextHarvest {
    if (nextHarvestAt == null) return '-';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final d = nextHarvestAt!;
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  List<Object?> get props => [
        id, name, block, beeSpecies, honeyType,
        latitude, longitude, imageUrl, creatorName,
        totalHarvests, totalWeightKg, nextHarvestAt,
      ];
}
