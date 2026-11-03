import 'package:equatable/equatable.dart';

abstract class ScheduleEvent extends Equatable {
  const ScheduleEvent();

  @override
  List<Object?> get props => [];
}

class ScheduleLoadRequested extends ScheduleEvent {
  final String? tab;
  const ScheduleLoadRequested({this.tab});

  @override
  List<Object?> get props => [tab];
}
