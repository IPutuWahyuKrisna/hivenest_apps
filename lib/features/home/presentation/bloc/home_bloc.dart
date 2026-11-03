import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_home_stats.dart';
import '../../domain/usecases/get_nearest_harvests.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeStats getHomeStats;
  final GetNearestHarvests getNearestHarvests;

  HomeBloc({required this.getHomeStats, required this.getNearestHarvests})
      : super(const HomeInitial()) {
    on<HomeStatsLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    HomeStatsLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    final statsFuture = getHomeStats(const GetHomeStatsParams());
    final harvestsFuture = getNearestHarvests();
    final statsResult = await statsFuture;
    final harvestsResult = await harvestsFuture;

    statsResult.fold(
      (failure) => emit(HomeFailure(failure.message)),
      (stats) => harvestsResult.fold(
        (failure) => emit(HomeFailure(failure.message)),
        (harvests) => emit(HomeLoaded(stats, harvests)),
      ),
    );
  }
}
