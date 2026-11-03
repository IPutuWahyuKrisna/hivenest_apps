import '../../domain/entities/hive_schedule.dart';

class HiveScheduleModel extends HiveSchedule {
  const HiveScheduleModel({
    required super.id,
    required super.hiveId,
    required super.scheduledAt,
    required super.status,
    super.notes,
    required super.creatorName,
    super.cancelledAt,
    super.cancellationReason,
    super.cancelledByName,
  });

  factory HiveScheduleModel.fromJson(Map<String, dynamic> json) {
    return HiveScheduleModel(
      id: json['id']?.toString() ?? '',
      hiveId: json['hive_id']?.toString() ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
      creatorName: json['creator_name']?.toString() ?? '-',
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      cancelledByName: json['cancelled_by_name'] as String?,
    );
  }
}
