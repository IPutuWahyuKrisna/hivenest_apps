import 'package:equatable/equatable.dart';
import '../../domain/entities/hive_detail.dart';
import '../../domain/entities/hive_harvester.dart';
import '../../domain/entities/hive_schedule.dart';

abstract class HiveDetailState extends Equatable {
  const HiveDetailState();

  @override
  List<Object?> get props => [];
}

class HiveDetailInitial extends HiveDetailState {
  const HiveDetailInitial();
}

class HiveDetailLoading extends HiveDetailState {
  const HiveDetailLoading();
}

class HiveDetailLoaded extends HiveDetailState {
  final HiveDetail detail;
  final List<HiveHarvester> harvesters;
  final List<HiveSchedule> schedules;

  const HiveDetailLoaded({
    required this.detail,
    required this.harvesters,
    required this.schedules,
  });

  @override
  List<Object?> get props => [detail, harvesters, schedules];
}

class HiveDetailFailure extends HiveDetailState {
  final String message;
  const HiveDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class HiveDetailDeleting extends HiveDetailState {
  final HiveDetail detail;
  final List<HiveHarvester> harvesters;
  final List<HiveSchedule> schedules;
  const HiveDetailDeleting({
    required this.detail,
    required this.harvesters,
    required this.schedules,
  });
  @override
  List<Object?> get props => [detail, harvesters, schedules];
}

class HiveDetailDeleteSuccess extends HiveDetailState {
  const HiveDetailDeleteSuccess();
}

class HiveDetailDeleteFailure extends HiveDetailState {
  final String message;
  final HiveDetail detail;
  final List<HiveHarvester> harvesters;
  final List<HiveSchedule> schedules;
  const HiveDetailDeleteFailure({
    required this.message,
    required this.detail,
    required this.harvesters,
    required this.schedules,
  });
  @override
  List<Object?> get props => [message, detail, harvesters, schedules];
}

class HiveScheduleSubmitting extends HiveDetailState {
  final HiveDetail detail;
  final List<HiveHarvester> harvesters;
  final List<HiveSchedule> schedules;
  const HiveScheduleSubmitting({
    required this.detail,
    required this.harvesters,
    required this.schedules,
  });
  @override
  List<Object?> get props => [detail, harvesters, schedules];
}

class HiveScheduleFailure extends HiveDetailState {
  final String message;
  final HiveDetail detail;
  final List<HiveHarvester> harvesters;
  final List<HiveSchedule> schedules;
  const HiveScheduleFailure({
    required this.message,
    required this.detail,
    required this.harvesters,
    required this.schedules,
  });
  @override
  List<Object?> get props => [message, detail, harvesters, schedules];
}

/// [isUploadingImage] membedakan tahap upload foto dari tahap kirim data,
/// supaya label progres di layar bisa menyebut yang sedang berlangsung.
class HiveHarvestSubmitting extends HiveDetailState {
  final HiveDetail detail;
  final List<HiveHarvester> harvesters;
  final List<HiveSchedule> schedules;
  final bool isUploadingImage;
  const HiveHarvestSubmitting({
    required this.detail,
    required this.harvesters,
    required this.schedules,
    required this.isUploadingImage,
  });
  @override
  List<Object?> get props =>
      [detail, harvesters, schedules, isUploadingImage];
}

class HiveHarvestFailure extends HiveDetailState {
  final String message;
  final HiveDetail detail;
  final List<HiveHarvester> harvesters;
  final List<HiveSchedule> schedules;
  const HiveHarvestFailure({
    required this.message,
    required this.detail,
    required this.harvesters,
    required this.schedules,
  });
  @override
  List<Object?> get props => [message, detail, harvesters, schedules];
}

class HiveHarvestSuccess extends HiveDetailState {
  final HiveDetail detail;
  final List<HiveHarvester> harvesters;
  final List<HiveSchedule> schedules;
  const HiveHarvestSuccess({
    required this.detail,
    required this.harvesters,
    required this.schedules,
  });
  @override
  List<Object?> get props => [detail, harvesters, schedules];
}
