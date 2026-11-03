import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeStatsLoadRequested extends HomeEvent {
  const HomeStatsLoadRequested();
}
