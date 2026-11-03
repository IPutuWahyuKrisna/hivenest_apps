import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_hive.dart';
import '../../domain/usecases/set_harvest_schedule.dart';
import '../../domain/usecases/upload_image.dart';
import 'add_hive_event.dart';
import 'add_hive_state.dart';

/// Data foto yang dibawa lintas state selama proses tambah sarang.
typedef _ImageSnapshot = ({
  String localImagePath,
  String fileName,
  String? imageUrl,
});

class AddHiveBloc extends Bloc<AddHiveEvent, AddHiveState> {
  final UploadImage uploadImage;
  final AddHive addHive;
  final SetHarvestSchedule setHarvestSchedule;

  AddHiveBloc({
    required this.uploadImage,
    required this.addHive,
    required this.setHarvestSchedule,
  }) : super(const AddHiveInitial()) {
    on<AddHiveImageSelected>(_onImageSelected);
    on<AddHiveSubmitted>(_onSubmitted);
  }

  /// Memilih foto hanya menyimpan path lokalnya. Upload sengaja ditunda sampai
  /// tombol Simpan ditekan supaya tidak ada file yatim di server kalau user
  /// membatalkan pengisian form.
  Future<void> _onImageSelected(
    AddHiveImageSelected event,
    Emitter<AddHiveState> emit,
  ) async {
    emit(AddHiveImageReady(
      localImagePath: event.imagePath,
      fileName: event.fileName,
    ));
  }

  Future<void> _onSubmitted(
    AddHiveSubmitted event,
    Emitter<AddHiveState> emit,
  ) async {
    final image = _imageSnapshot(state);
    if (image == null) return; // Foto wajib, tombol Simpan mestinya nonaktif.

    // ── Tahap 1: upload foto ────────────────────────────────────────────
    // Dilewati kalau percobaan submit sebelumnya sudah berhasil mengupload,
    // supaya retry tidak menghasilkan file duplikat di server.
    final String imageUrl;
    final existingUrl = image.imageUrl;
    if (existingUrl != null) {
      imageUrl = existingUrl;
    } else {
      emit(AddHiveImageUploading(localImagePath: image.localImagePath));

      final uploadResult = await uploadImage(
        image.localImagePath,
        image.fileName,
      );

      final uploadedUrl = uploadResult.fold<String?>((_) => null, (url) => url);
      if (uploadedUrl == null) {
        emit(AddHiveFailure(
          message: uploadResult.fold((f) => f.message, (_) => ''),
          localImagePath: image.localImagePath,
          fileName: image.fileName,
        ));
        return;
      }
      imageUrl = uploadedUrl;
    }

    // ── Tahap 2: simpan data sarang ─────────────────────────────────────
    emit(AddHiveSubmitting(
      localImagePath: image.localImagePath,
      imageUrl: imageUrl,
    ));

    final addResult = await addHive(AddHiveParams(
      name: event.name,
      block: event.block,
      beeSpecies: event.beeSpecies,
      honeyType: event.honeyType,
      latitude: event.latitude,
      longitude: event.longitude,
      imageUrl: imageUrl,
    ));

    final hiveId = addResult.fold<String?>((_) => null, (id) => id);
    if (hiveId == null) {
      emit(_failureKeepingImage(
        addResult.fold((f) => f.message, (_) => ''),
        image,
        imageUrl,
      ));
      return;
    }

    // ── Tahap 3: jadwal panen pertama ───────────────────────────────────
    final scheduleResult = await setHarvestSchedule(
      hiveId: hiveId,
      scheduledAt: event.scheduledAt,
      notes: event.notes,
    );

    scheduleResult.fold(
      (failure) => emit(_failureKeepingImage(failure.message, image, imageUrl)),
      (_) => emit(const AddHiveSuccess()),
    );
  }

  AddHiveFailure _failureKeepingImage(
    String message,
    _ImageSnapshot image,
    String imageUrl,
  ) {
    return AddHiveFailure(
      message: message,
      localImagePath: image.localImagePath,
      fileName: image.fileName,
      imageUrl: imageUrl,
    );
  }

  /// Mengambil data foto dari state manapun yang masih memegangnya.
  _ImageSnapshot? _imageSnapshot(AddHiveState s) {
    if (s is AddHiveImageReady) {
      return (
        localImagePath: s.localImagePath,
        fileName: s.fileName,
        imageUrl: s.imageUrl,
      );
    }
    if (s is AddHiveFailure &&
        s.localImagePath != null &&
        s.fileName != null) {
      return (
        localImagePath: s.localImagePath!,
        fileName: s.fileName!,
        imageUrl: s.imageUrl,
      );
    }
    return null;
  }
}
