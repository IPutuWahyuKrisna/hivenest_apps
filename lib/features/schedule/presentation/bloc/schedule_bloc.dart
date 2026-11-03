import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_harvest_schedules.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  final GetHarvestSchedules getHarvestSchedules;

  ScheduleBloc({required this.getHarvestSchedules})
      : super(const ScheduleInitial()) {
    on<ScheduleLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    ScheduleLoadRequested event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    final result = await getHarvestSchedules(event.tab);
    result.fold(
      (failure) => emit(ScheduleFailure(failure.message)),
      (schedules) => emit(ScheduleLoaded(schedules)),
    );
  }
}
