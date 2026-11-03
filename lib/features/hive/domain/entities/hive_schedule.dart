import 'package:equatable/equatable.dart';

class HiveSchedule extends Equatable {
  final String id;
  final String hiveId;
  final DateTime scheduledAt;
  final String status;
  final String? notes;
  final String creatorName;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? cancelledByName;

  const HiveSchedule({
    required this.id,
    required this.hiveId,
    required this.scheduledAt,
    required this.status,
    this.notes,
    required this.creatorName,
    this.cancelledAt,
    this.cancellationReason,
    this.cancelledByName,
  });

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${scheduledAt.day} ${months[scheduledAt.month - 1]} ${scheduledAt.year}';
  }

  String get statusLabel {
    switch (status) {
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Dijadwalkan';
    }
  }

  @override
  List<Object?> get props => [
        id, hiveId, scheduledAt, status, notes,
        creatorName, cancelledAt, cancellationReason, cancelledByName,
      ];
}
