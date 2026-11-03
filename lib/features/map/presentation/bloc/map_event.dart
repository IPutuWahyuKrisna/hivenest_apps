import 'package:equatable/equatable.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapHivesLoadRequested extends MapEvent {
  const MapHivesLoadRequested();
}

/// Refresh data sarang di background (polling), tanpa menampilkan
/// loading spinner full-screen dan tanpa mengganggu detail yang sedang dibuka.
class MapHivesRefreshRequested extends MapEvent {
  const MapHivesRefreshRequested();
}

class MapHiveDetailRequested extends MapEvent {
  final String hiveId;
  const MapHiveDetailRequested(this.hiveId);

  @override
  List<Object?> get props => [hiveId];
}
