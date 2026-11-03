import 'package:equatable/equatable.dart';

abstract class EditHiveState extends Equatable {
  const EditHiveState();
  @override
  List<Object?> get props => [];
}

/// [imageUrl] adalah URL yang sudah tersimpan di server — foto lama milik
/// sarang, atau hasil upload yang sudah berhasil.
///
/// [localImagePath] terisi kalau user memilih foto baru dari galeri.
/// [needsUpload] menandai foto baru itu belum diupload; kalau false berarti
/// [imageUrl] sudah mewakili foto yang terlihat di layar.
class EditHiveIdle extends EditHiveState {
  final String? imageUrl;
  final String? localImagePath;
  final String? fileName;
  final bool needsUpload;

  const EditHiveIdle({
    this.imageUrl,
    this.localImagePath,
    this.fileName,
    this.needsUpload = false,
  });

  @override
  List<Object?> get props => [imageUrl, localImagePath, fileName, needsUpload];
}

/// Tahap 1 setelah tombol Simpan ditekan: foto baru sedang diupload.
class EditHiveImageUploading extends EditHiveState {
  final String? currentImageUrl;
  final String? localImagePath;

  const EditHiveImageUploading({this.currentImageUrl, this.localImagePath});

  @override
  List<Object?> get props => [currentImageUrl, localImagePath];
}

/// Tahap 2: data sarang sedang dikirim.
class EditHiveSubmitting extends EditHiveState {
  final String imageUrl;
  final String? localImagePath;

  const EditHiveSubmitting({required this.imageUrl, this.localImagePath});

  @override
  List<Object?> get props => [imageUrl, localImagePath];
}

class EditHiveSuccess extends EditHiveState {
  const EditHiveSuccess();
}

class EditHiveFailure extends EditHiveState {
  final String message;
  final String? imageUrl;
  final String? localImagePath;
  final String? fileName;
  final bool needsUpload;

  const EditHiveFailure({
    required this.message,
    this.imageUrl,
    this.localImagePath,
    this.fileName,
    this.needsUpload = false,
  });

  @override
  List<Object?> get props =>
      [message, imageUrl, localImagePath, fileName, needsUpload];
}
