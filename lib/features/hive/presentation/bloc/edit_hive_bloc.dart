import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/update_hive.dart';
import '../../domain/usecases/upload_image.dart';
import 'edit_hive_event.dart';
import 'edit_hive_state.dart';

/// Kondisi foto saat ini, dikumpulkan dari state manapun yang memegangnya.
typedef _ImageSnapshot = ({
  String? imageUrl,
  String? localImagePath,
  String? fileName,
  bool needsUpload,
});

class EditHiveBloc extends Bloc<EditHiveEvent, EditHiveState> {
  final UploadImage uploadImage;
  final UpdateHive updateHive;

  EditHiveBloc({
    required this.uploadImage,
    required this.updateHive,
    String? initialImageUrl,
  }) : super(EditHiveIdle(imageUrl: initialImageUrl)) {
    on<EditHiveImageSelected>(_onImageSelected);
    on<EditHiveSubmitted>(_onSubmitted);
  }

  /// Foto baru hanya dicatat, belum diupload. Foto lama tetap dipegang di
  /// [EditHiveIdle.imageUrl] supaya kalau upload nanti gagal, sarang tidak
  /// kehilangan foto yang sudah ada.
  Future<void> _onImageSelected(
    EditHiveImageSelected event,
    Emitter<EditHiveState> emit,
  ) async {
    final current = _imageSnapshot(state);

    emit(EditHiveIdle(
      imageUrl: current.imageUrl,
      localImagePath: event.imagePath,
      fileName: event.fileName,
      needsUpload: true,
    ));
  }

  Future<void> _onSubmitted(
    EditHiveSubmitted event,
    Emitter<EditHiveState> emit,
  ) async {
    final image = _imageSnapshot(state);

    // ── Tahap 1: upload foto baru kalau ada ─────────────────────────────
    final String? resolvedUrl;
    if (image.needsUpload &&
        image.localImagePath != null &&
        image.fileName != null) {
      emit(EditHiveImageUploading(
        currentImageUrl: image.imageUrl,
        localImagePath: image.localImagePath,
      ));

      final uploadResult = await uploadImage(
        image.localImagePath!,
        image.fileName!,
      );

      final uploadedUrl = uploadResult.fold<String?>((_) => null, (url) => url);
      if (uploadedUrl == null) {
        emit(EditHiveFailure(
          message: uploadResult.fold((f) => f.message, (_) => ''),
          imageUrl: image.imageUrl,
          localImagePath: image.localImagePath,
          fileName: image.fileName,
          needsUpload: true, // masih perlu diupload saat dicoba lagi
        ));
        return;
      }
      resolvedUrl = uploadedUrl;
    } else {
      resolvedUrl = image.imageUrl;
    }

    if (resolvedUrl == null) {
      emit(const EditHiveFailure(message: 'Foto sarang wajib diisi'));
      return;
    }

    // ── Tahap 2: simpan perubahan ───────────────────────────────────────
    emit(EditHiveSubmitting(
      imageUrl: resolvedUrl,
      localImagePath: image.localImagePath,
    ));

    final result = await updateHive(UpdateHiveParams(
      id: event.id,
      name: event.name,
      block: event.block,
      beeSpecies: event.beeSpecies,
      honeyType: event.honeyType,
      latitude: event.latitude,
      longitude: event.longitude,
      imageUrl: resolvedUrl,
    ));

    result.fold(
      (failure) => emit(EditHiveFailure(
        message: failure.message,
        imageUrl: resolvedUrl,
        localImagePath: image.localImagePath,
        fileName: image.fileName,
        // Foto sudah terupload, jangan diupload ulang saat user coba lagi.
        needsUpload: false,
      )),
      (_) => emit(const EditHiveSuccess()),
    );
  }

  _ImageSnapshot _imageSnapshot(EditHiveState s) {
    if (s is EditHiveIdle) {
      return (
        imageUrl: s.imageUrl,
        localImagePath: s.localImagePath,
        fileName: s.fileName,
        needsUpload: s.needsUpload,
      );
    }
    if (s is EditHiveFailure) {
      return (
        imageUrl: s.imageUrl,
        localImagePath: s.localImagePath,
        fileName: s.fileName,
        needsUpload: s.needsUpload,
      );
    }
    return (
      imageUrl: null,
      localImagePath: null,
      fileName: null,
      needsUpload: false,
    );
  }
}
