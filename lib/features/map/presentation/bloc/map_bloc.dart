import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/hive_location.dart';
import '../../domain/usecases/get_hive_detail.dart';
import '../../domain/usecases/get_hives.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final GetHives getHives;
  final GetHiveDetail getHiveDetail;

  MapBloc({required this.getHives, required this.getHiveDetail})
      : super(const MapInitial()) {
    on<MapHivesLoadRequested>(_onHivesLoadRequested);
    on<MapHivesRefreshRequested>(_onHivesRefreshRequested);
    on<MapHiveDetailRequested>(_onHiveDetailRequested);
  }

  Future<void> _onHivesLoadRequested(
    MapHivesLoadRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(const MapHivesLoading());
    final result = await getHives();
    result.fold(
      (failure) => emit(MapFailure(failure.message)),
      (hives) => emit(MapHivesLoaded(hives)),
    );
  }

  Future<void> _onHivesRefreshRequested(
    MapHivesRefreshRequested event,
    Emitter<MapState> emit,
  ) async {
    final result = await getHives();
    result.fold(
      (failure) {
        // Silent fail — pertahankan data lama, tidak mengganggu tampilan.
      },
      (hives) {
        final current = state;
        if (current is MapDetailLoading) {
          emit(MapDetailLoading(hives));
        } else if (current is MapDetailLoaded) {
          emit(MapDetailLoaded(hives, current.detail));
        } else if (current is MapDetailFailure) {
          emit(MapDetailFailure(hives, current.message));
        } else {
          emit(MapHivesLoaded(hives));
        }
      },
    );
  }

  Future<void> _onHiveDetailRequested(
    MapHiveDetailRequested event,
    Emitter<MapState> emit,
  ) async {
    final hives = _currentHives;
    if (hives == null) return;

    emit(MapDetailLoading(hives));
    final result = await getHiveDetail(event.hiveId);
    result.fold(
      (failure) => emit(MapDetailFailure(hives, failure.message)),
      (detail) => emit(MapDetailLoaded(hives, detail)),
    );
  }

  List<HiveLocation>? get _currentHives {
    final s = state;
    if (s is MapHivesLoaded) return s.hives;
    if (s is MapDetailLoading) return s.hives;
    if (s is MapDetailLoaded) return s.hives;
    if (s is MapDetailFailure) return s.hives;
    return null;
  }
}
