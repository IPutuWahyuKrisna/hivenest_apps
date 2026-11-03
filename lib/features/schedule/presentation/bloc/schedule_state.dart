import 'package:equatable/equatable.dart';
import '../../domain/entities/harvest_schedule.dart';

abstract class ScheduleState extends Equatable {
  const ScheduleState();

  @override
  List<Object?> get props => [];
}

class ScheduleInitial extends ScheduleState {
  const ScheduleInitial();
}

class ScheduleLoading extends ScheduleState {
  const ScheduleLoading();
}

class ScheduleLoaded extends ScheduleState {
  final List<HarvestSchedule> schedules;
  const ScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleFailure extends ScheduleState {
  final String message;
  const ScheduleFailure(this.message);

  @override
  List<Object?> get props => [message];
}
