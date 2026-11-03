import 'package:equatable/equatable.dart';
import '../../domain/entities/home_stats.dart';
import '../../domain/entities/nearest_harvest.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final HomeStats stats;
  final List<NearestHarvest> nearestHarvests;

  const HomeLoaded(this.stats, this.nearestHarvests);

  @override
  List<Object?> get props => [stats, nearestHarvests];
}

class HomeFailure extends HomeState {
  final String message;

  const HomeFailure(this.message);

  @override
  List<Object?> get props => [message];
}
