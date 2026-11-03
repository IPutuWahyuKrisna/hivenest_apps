import 'package:equatable/equatable.dart';
import '../../domain/entities/hive_detail.dart';
import '../../domain/entities/hive_location.dart';

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapInitial extends MapState {
  const MapInitial();
}

class MapHivesLoading extends MapState {
  const MapHivesLoading();
}

class MapHivesLoaded extends MapState {
  final List<HiveLocation> hives;
  const MapHivesLoaded(this.hives);

  @override
  List<Object?> get props => [hives];
}

class MapDetailLoading extends MapState {
  final List<HiveLocation> hives;
  const MapDetailLoading(this.hives);

  @override
  List<Object?> get props => [hives];
}

class MapDetailLoaded extends MapState {
  final List<HiveLocation> hives;
  final HiveDetail detail;
  const MapDetailLoaded(this.hives, this.detail);

  @override
  List<Object?> get props => [hives, detail];
}

class MapDetailFailure extends MapState {
  final List<HiveLocation> hives;
  final String message;
  const MapDetailFailure(this.hives, this.message);

  @override
  List<Object?> get props => [hives, message];
}

class MapFailure extends MapState {
  final String message;
  const MapFailure(this.message);

  @override
  List<Object?> get props => [message];
}
