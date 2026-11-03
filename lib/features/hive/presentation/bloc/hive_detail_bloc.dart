import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/hive_detail.dart';
import '../../domain/entities/hive_harvester.dart';
import '../../domain/entities/hive_schedule.dart';
import '../../domain/usecases/get_hive_detail.dart';
import '../../domain/usecases/get_hive_harvesters.dart';
import '../../domain/usecases/get_hive_schedules.dart';
import '../../domain/usecases/delete_hive.dart';
import '../../domain/usecases/set_harvest_schedule.dart';
import '../../domain/usecases/record_harvest.dart';
import '../../domain/usecases/upload_image.dart';
import 'hive_detail_event.dart';
import 'hive_detail_state.dart';

class HiveDetailBloc extends Bloc<HiveDetailEvent, HiveDetailState> {
  final GetHiveDetail getHiveDetail;
  final GetHiveHarvesters getHiveHarvesters;
  final GetHiveSchedules getHiveSchedules;
  final DeleteHive deleteHive;
  final SetHarvestSchedule setHarvestSchedule;
  final RecordHarvest recordHarvest;
  final UploadImage uploadImage;

  HiveDetailBloc({
    required this.getHiveDetail,
    required this.getHiveHarvesters,
    required this.getHiveSchedules,
    required this.deleteHive,
    required this.setHarvestSchedule,
    required this.recordHarvest,
    required this.uploadImage,
  }) : super(const HiveDetailInitial()) {
    on<HiveDetailLoadRequested>(_onLoadRequested);
    on<HiveDeleteRequested>(_onDeleteRequested);
    on<HiveScheduleHarvestRequested>(_onScheduleHarvestRequested);
    on<HiveHarvestRecordRequested>(_onHarvestRecordRequested);
  }

  Future<void> _onLoadRequested(
    HiveDetailLoadRequested event,
    Emitter<HiveDetailState> emit,
  ) async {
    emit(const HiveDetailLoading());
    await _fetchAndEmit(event.hiveId, emit);
  }

  Future<void> _fetchAndEmit(
    String hiveId,
    Emitter<HiveDetailState> emit,
  ) async {
    final detailFuture = getHiveDetail(hiveId);
    final harvestersFuture = getHiveHarvesters(hiveId);
    final schedulesFuture = getHiveSchedules(hiveId);

    final Either<Failure, HiveDetail> detailResult = await detailFuture;
    final Either<Failure, List<HiveHarvester>> harvestersResult =
        await harvestersFuture;
    final Either<Failure, List<HiveSchedule>> schedulesResult =
        await schedulesFuture;

    if (detailResult.isLeft()) {
      emit(HiveDetailFailure(
        detailResult.fold((f) => f.message, (_) => 'Terjadi kesalahan'),
      ));
      return;
    }

    emit(HiveDetailLoaded(
      detail: detailResult.getOrElse(() => throw StateError('unreachable')),
      harvesters: harvestersResult.getOrElse(() => []),
      schedules: schedulesResult.getOrElse(() => []),
    ));
  }

  Future<void> _onScheduleHarvestRequested(
    HiveScheduleHarvestRequested event,
    Emitter<HiveDetailState> emit,
  ) async {
    final snapshot = _loadedSnapshot(state);
    if (snapshot == null) return;

    emit(HiveScheduleSubmitting(
      detail: snapshot.detail,
      harvesters: snapshot.harvesters,
      schedules: snapshot.schedules,
    ));

    final result = await setHarvestSchedule(
      hiveId: event.hiveId,
      scheduledAt: event.scheduledAt,
      notes: event.notes,
    );

    if (result.isLeft()) {
      emit(HiveScheduleFailure(
        message: result.fold((f) => f.message, (_) => 'Terjadi kesalahan'),
        detail: snapshot.detail,
        harvesters: snapshot.harvesters,
        schedules: snapshot.schedules,
      ));
      return;
    }

    await _fetchAndEmit(event.hiveId, emit);
  }

  Future<void> _onHarvestRecordRequested(
    HiveHarvestRecordRequested event,
    Emitter<HiveDetailState> emit,
  ) async {
    final snapshot = _loadedSnapshot(state);
    if (snapshot == null) return;

    // ── Tahap 1: upload foto hasil panen ────────────────────────────────
    emit(HiveHarvestSubmitting(
      detail: snapshot.detail,
      harvesters: snapshot.harvesters,
      schedules: snapshot.schedules,
      isUploadingImage: true,
    ));

    final uploadResult = await uploadImage(
      event.localImagePath,
      event.fileName,
    );
    final imageUrl = uploadResult.fold<String?>((_) => null, (url) => url);
    if (imageUrl == null) {
      emit(HiveHarvestFailure(
        message: uploadResult.fold((f) => f.message, (_) => ''),
        detail: snapshot.detail,
        harvesters: snapshot.harvesters,
        schedules: snapshot.schedules,
      ));
      return;
    }

    // ── Tahap 2: kirim data panen ───────────────────────────────────────
    emit(HiveHarvestSubmitting(
      detail: snapshot.detail,
      harvesters: snapshot.harvesters,
      schedules: snapshot.schedules,
      isUploadingImage: false,
    ));

    final result = await recordHarvest(
      scheduleId: event.scheduleId,
      volumeMl: event.volumeMl,
      notes: event.notes,
      imageUrl: imageUrl,
    );

    if (result.isLeft()) {
      emit(HiveHarvestFailure(
        message: result.fold((f) => f.message, (_) => 'Terjadi kesalahan'),
        detail: snapshot.detail,
        harvesters: snapshot.harvesters,
        schedules: snapshot.schedules,
      ));
      return;
    }

    // Panen tercatat. Data ditarik ulang supaya total panen, daftar pemanen,
    // dan status jadwal ikut terbarui.
    await _fetchAndEmit(event.hiveId, emit);

    final refreshed = _loadedSnapshot(state);
    if (refreshed != null) {
      emit(HiveHarvestSuccess(
        detail: refreshed.detail,
        harvesters: refreshed.harvesters,
        schedules: refreshed.schedules,
      ));
    }
  }

  ({HiveDetail detail, List<HiveHarvester> harvesters, List<HiveSchedule> schedules})?
      _loadedSnapshot(HiveDetailState s) {
    if (s is HiveDetailLoaded) {
      return (detail: s.detail, harvesters: s.harvesters, schedules: s.schedules);
    }
    if (s is HiveScheduleFailure) {
      return (detail: s.detail, harvesters: s.harvesters, schedules: s.schedules);
    }
    if (s is HiveHarvestFailure) {
      return (detail: s.detail, harvesters: s.harvesters, schedules: s.schedules);
    }
    if (s is HiveHarvestSuccess) {
      return (detail: s.detail, harvesters: s.harvesters, schedules: s.schedules);
    }
    return null;
  }

  Future<void> _onDeleteRequested(
    HiveDeleteRequested event,
    Emitter<HiveDetailState> emit,
  ) async {
    final current = state;
    if (current is! HiveDetailLoaded) return;

    emit(HiveDetailDeleting(
      detail: current.detail,
      harvesters: current.harvesters,
      schedules: current.schedules,
    ));

    final result = await deleteHive(event.hiveId);
    result.fold(
      (failure) => emit(HiveDetailDeleteFailure(
        message: failure.message,
        detail: current.detail,
        harvesters: current.harvesters,
        schedules: current.schedules,
      )),
      (_) => emit(const HiveDetailDeleteSuccess()),
    );
  }
}
