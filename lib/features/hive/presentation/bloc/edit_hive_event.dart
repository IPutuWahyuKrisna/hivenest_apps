import 'package:equatable/equatable.dart';

abstract class EditHiveEvent extends Equatable {
  const EditHiveEvent();
  @override
  List<Object?> get props => [];
}

class EditHiveImageSelected extends EditHiveEvent {
  final String imagePath;
  final String fileName;
  const EditHiveImageSelected({required this.imagePath, required this.fileName});
  @override
  List<Object?> get props => [imagePath, fileName];
}

/// Foto tidak dikirim lewat event. Bloc yang menentukan sendiri: pakai foto
/// lama, atau upload foto baru yang sudah dipilih user.
class EditHiveSubmitted extends EditHiveEvent {
  final String id;
  final String name;
  final String block;
  final String beeSpecies;
  final String honeyType;
  final double latitude;
  final double longitude;

  const EditHiveSubmitted({
    required this.id,
    required this.name,
    required this.block,
    required this.beeSpecies,
    required this.honeyType,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props =>
      [id, name, block, beeSpecies, honeyType, latitude, longitude];
}
