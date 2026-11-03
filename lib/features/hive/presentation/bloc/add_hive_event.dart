import 'package:equatable/equatable.dart';

abstract class AddHiveEvent extends Equatable {
  const AddHiveEvent();
  @override
  List<Object?> get props => [];
}

class AddHiveImageSelected extends AddHiveEvent {
  final String imagePath;
  final String fileName;
  const AddHiveImageSelected({required this.imagePath, required this.fileName});
  @override
  List<Object?> get props => [imagePath, fileName];
}

/// Foto tidak lagi dikirim lewat event. Path lokalnya sudah tersimpan di state
/// sejak dipilih, dan uploadnya dijalankan oleh bloc saat event ini diproses.
class AddHiveSubmitted extends AddHiveEvent {
  final String name;
  final String block;
  final String beeSpecies;
  final String honeyType;
  final double latitude;
  final double longitude;
  final DateTime scheduledAt;
  final String notes;

  const AddHiveSubmitted({
    required this.name,
    required this.block,
    required this.beeSpecies,
    required this.honeyType,
    required this.latitude,
    required this.longitude,
    required this.scheduledAt,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        name,
        block,
        beeSpecies,
        honeyType,
        latitude,
        longitude,
        scheduledAt,
        notes,
      ];
}
