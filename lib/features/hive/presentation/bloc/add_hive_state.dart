import 'package:equatable/equatable.dart';

abstract class AddHiveState extends Equatable {
  const AddHiveState();
  @override
  List<Object?> get props => [];
}

class AddHiveInitial extends AddHiveState {
  const AddHiveInitial();
}

/// Foto sudah dipilih dan dikompres, tapi belum diupload.
/// [imageUrl] baru terisi kalau upload sudah pernah berhasil pada percobaan
/// submit sebelumnya — dipakai supaya retry tidak mengupload ulang.
class AddHiveImageReady extends AddHiveState {
  final String localImagePath;
  final String fileName;
  final String? imageUrl;

  const AddHiveImageReady({
    required this.localImagePath,
    required this.fileName,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [localImagePath, fileName, imageUrl];
}

/// Tahap 1 setelah tombol Simpan ditekan: foto sedang diupload.
class AddHiveImageUploading extends AddHiveState {
  final String localImagePath;

  const AddHiveImageUploading({required this.localImagePath});

  @override
  List<Object?> get props => [localImagePath];
}

/// Tahap 2: foto sudah punya URL, data sarang sedang dikirim.
class AddHiveSubmitting extends AddHiveState {
  final String localImagePath;
  final String imageUrl;

  const AddHiveSubmitting({
    required this.localImagePath,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [localImagePath, imageUrl];
}

class AddHiveSuccess extends AddHiveState {
  const AddHiveSuccess();
}

/// Membawa kembali data foto supaya user bisa langsung menekan Simpan lagi
/// tanpa memilih ulang foto, dan tanpa upload ulang kalau [imageUrl] sudah ada.
class AddHiveFailure extends AddHiveState {
  final String message;
  final String? localImagePath;
  final String? fileName;
  final String? imageUrl;

  const AddHiveFailure({
    required this.message,
    this.localImagePath,
    this.fileName,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [message, localImagePath, fileName, imageUrl];
}
