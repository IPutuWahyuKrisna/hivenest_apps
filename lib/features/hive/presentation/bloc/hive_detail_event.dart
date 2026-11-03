import 'package:equatable/equatable.dart';

abstract class HiveDetailEvent extends Equatable {
  const HiveDetailEvent();

  @override
  List<Object?> get props => [];
}

class HiveDetailLoadRequested extends HiveDetailEvent {
  final String hiveId;
  const HiveDetailLoadRequested(this.hiveId);

  @override
  List<Object?> get props => [hiveId];
}

class HiveDeleteRequested extends HiveDetailEvent {
  final String hiveId;
  const HiveDeleteRequested(this.hiveId);

  @override
  List<Object?> get props => [hiveId];
}

/// Mencatat hasil panen. Foto masih berupa file lokal — uploadnya dijalankan
/// bloc saat event ini diproses, sama seperti alur tambah dan edit sarang.
class HiveHarvestRecordRequested extends HiveDetailEvent {
  final String hiveId;
  final String scheduleId;
  final int volumeMl;
  final String notes;
  final String localImagePath;
  final String fileName;

  const HiveHarvestRecordRequested({
    required this.hiveId,
    required this.scheduleId,
    required this.volumeMl,
    required this.notes,
    required this.localImagePath,
    required this.fileName,
  });

  @override
  List<Object?> get props =>
      [hiveId, scheduleId, volumeMl, notes, localImagePath, fileName];
}

class HiveScheduleHarvestRequested extends HiveDetailEvent {
  final String hiveId;
  final DateTime scheduledAt;
  final String notes;
  const HiveScheduleHarvestRequested({
    required this.hiveId,
    required this.scheduledAt,
    required this.notes,
  });

  @override
  List<Object?> get props => [hiveId, scheduledAt, notes];
}
