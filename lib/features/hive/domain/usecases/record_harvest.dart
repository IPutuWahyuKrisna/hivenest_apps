import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/hive_repository.dart';

/// Mencatat hasil panen untuk sebuah jadwal panen.
///
/// Jadwal panen berikutnya tidak dibuat di sini — peternak mengaturnya sendiri
/// lewat "Atur Jadwal Panen" di halaman detail sarang setelah panen tercatat.
class RecordHarvest {
  final HiveRepository repository;
  RecordHarvest(this.repository);

  Future<Either<Failure, void>> call({
    required String scheduleId,
    required int volumeMl,
    required String notes,
    required String imageUrl,
  }) =>
      repository.recordHarvest(
        scheduleId: scheduleId,
        volumeMl: volumeMl,
        notes: notes,
        imageUrl: imageUrl,
      );
}
