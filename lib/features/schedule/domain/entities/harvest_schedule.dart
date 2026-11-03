import 'package:equatable/equatable.dart';

class HiveInfo extends Equatable {
  final String name;
  final String block;
  final String beeSpecies;
  final String honeyType;

  const HiveInfo({
    required this.name,
    required this.block,
    required this.beeSpecies,
    required this.honeyType,
  });

  @override
  List<Object?> get props => [name, block, beeSpecies, honeyType];
}

class HarvestSchedule extends Equatable {
  final String id;
  final String hiveId;
  final DateTime scheduledAt;
  final String notes;
  final DateTime createdAt;
  final HiveInfo hive;

  const HarvestSchedule({
    required this.id,
    required this.hiveId,
    required this.scheduledAt,
    required this.notes,
    required this.createdAt,
    required this.hive,
  });

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${scheduledAt.day} ${months[scheduledAt.month - 1]} ${scheduledAt.year}';
  }

  String get formattedTime {
    final h = scheduledAt.toLocal().hour.toString().padLeft(2, '0');
    final m = scheduledAt.toLocal().minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  List<Object?> get props => [id, hiveId, scheduledAt, notes, createdAt, hive];
}
