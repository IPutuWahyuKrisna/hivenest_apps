import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/bee_species_options.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/helpers/image_compress_helper.dart';
import '../../../../../core/helpers/snackbar_helper.dart';
import '../../../../../core/pages/map_picker_page.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bee_species_dropdown.dart';
import '../../domain/entities/hive_detail.dart';
import '../bloc/edit_hive_bloc.dart';
import '../bloc/edit_hive_event.dart';
import '../bloc/edit_hive_state.dart';

class EditHivePage extends StatelessWidget {
  final HiveDetail detail;
  const EditHivePage({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditHiveBloc(
        uploadImage: sl(),
        updateHive: sl(),
        initialImageUrl: detail.imageUrl,
      ),
      child: _EditHiveView(detail: detail),
    );
  }
}

class _EditHiveView extends StatefulWidget {
  final HiveDetail detail;
  const _EditHiveView({required this.detail});

  @override
  State<_EditHiveView> createState() => _EditHiveViewState();
}

class _EditHiveViewState extends State<_EditHiveView> {
  late final TextEditingController _nameController;
  late final TextEditingController _blockController;

  BeeSpeciesOption? _selectedSpecies;

  /// Jenis lebah lama yang tidak ada di daftar pilihan — data dari sebelum
  /// form ini memakai dropdown. Disimpan hanya untuk ditampilkan sebagai
  /// peringatan; peternak tetap wajib memilih ulang.
  String? _unrecognizedSpecies;

  double? _lat;
  double? _lng;
  bool _isLoadingGps = false;
  bool _isCompressingImage = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.detail.name);
    _blockController = TextEditingController(text: widget.detail.block);

    _selectedSpecies =
        BeeSpeciesOptions.findByBeeSpecies(widget.detail.beeSpecies);
    if (_selectedSpecies == null &&
        widget.detail.beeSpecies.trim().isNotEmpty) {
      _unrecognizedSpecies = widget.detail.beeSpecies.trim();
    }

    _lat = widget.detail.latitude;
    _lng = widget.detail.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _blockController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoadingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          SnackbarHelper.showWarning(context, 'Aktifkan layanan lokasi di pengaturan HP');
        }
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            SnackbarHelper.showWarning(context, 'Izin lokasi ditolak');
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          SnackbarHelper.showWarning(
            context,
            'Izin lokasi ditolak permanen. Aktifkan di Pengaturan.',
          );
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) setState(() { _lat = pos.latitude; _lng = pos.longitude; });
    } finally {
      if (mounted) setState(() => _isLoadingGps = false);
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => MapPickerPage(
          initialLatLng: (_lat != null && _lng != null) ? LatLng(_lat!, _lng!) : null,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() { _lat = result.latitude; _lng = result.longitude; });
    }
  }

  Widget _buildLocationPicker() {
    final hasLocation = _lat != null && _lng != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.fieldBg,
            borderRadius: BorderRadius.circular(12),
            border: hasLocation
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
                : null,
          ),
          child: Row(
            children: [
              Icon(Icons.location_on,
                  color: hasLocation ? AppColors.primary : AppColors.textGray, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hasLocation
                      ? 'Lat: ${_lat!.toStringAsFixed(6)}\nLng: ${_lng!.toStringAsFixed(6)}'
                      : 'Lokasi belum dipilih',
                  style: TextStyle(
                    fontSize: 13,
                    color: hasLocation ? AppColors.textDark : AppColors.textGray,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoadingGps ? null : _useCurrentLocation,
                icon: _isLoadingGps
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(_isLoadingGps ? 'Memuat...' : 'Lokasi Saat Ini'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openMapPicker,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Pilih di Peta'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null || !mounted) return;

    setState(() => _isCompressingImage = true);
    final compressedPath = await ImageCompressHelper.compressUnderLimit(file.path);
    if (!mounted) return;
    setState(() => _isCompressingImage = false);

    context.read<EditHiveBloc>().add(EditHiveImageSelected(
      imagePath: compressedPath,
      fileName: file.name,
    ));
  }

  void _submit() {
    final name = _nameController.text.trim();
    final block = _blockController.text.trim();
    final species = _selectedSpecies;

    if (name.isEmpty || block.isEmpty || species == null ||
        _lat == null || _lng == null) {
      SnackbarHelper.showWarning(context, 'Lengkapi semua field terlebih dahulu');
      return;
    }

    context.read<EditHiveBloc>().add(EditHiveSubmitted(
      id: widget.detail.id,
      name: name,
      block: block,
      beeSpecies: species.beeSpecies,
      honeyType: species.honeyType,
      latitude: _lat!,
      longitude: _lng!,
    ));
  }

  bool _isLoading(EditHiveState state) =>
      state is EditHiveImageUploading || state is EditHiveSubmitting;

  String? _resolveImageUrl(EditHiveState state) {
    if (state is EditHiveIdle) return state.imageUrl;
    if (state is EditHiveSubmitting) return state.imageUrl;
    if (state is EditHiveFailure) return state.imageUrl;
    if (state is EditHiveImageUploading) return state.currentImageUrl;
    return null;
  }

  String? _resolveLocalPath(EditHiveState state) {
    if (state is EditHiveIdle) return state.localImagePath;
    if (state is EditHiveImageUploading) return state.localImagePath;
    if (state is EditHiveSubmitting) return state.localImagePath;
    if (state is EditHiveFailure) return state.localImagePath;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditHiveBloc, EditHiveState>(
      listener: (context, state) {
        if (state is EditHiveSuccess) {
          SnackbarHelper.showSuccess(context, 'Sarang berhasil diperbarui');
          context.pop(true);
        } else if (state is EditHiveFailure) {
          SnackbarHelper.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<EditHiveBloc, EditHiveState>(
          builder: (context, state) {
            final imageUrl = _resolveImageUrl(state);
            final localPath = _resolveLocalPath(state);
            final isUploading = state is EditHiveImageUploading;
            final isSubmitting = state is EditHiveSubmitting;
            final hasImage = localPath != null || imageUrl != null;

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImagePicker(
                          isUploading: isUploading,
                          isSubmitting: isSubmitting,
                          localPath: localPath,
                          networkUrl: localPath == null ? imageUrl : null,
                        ),
                        const SizedBox(height: 24),
                        const _SectionLabel('Informasi Sarang'),
                        const SizedBox(height: 12),
                        _buildTextField(controller: _nameController, hint: 'Nama Sarang', icon: Icons.hive_outlined),
                        const SizedBox(height: 12),
                        _buildTextField(controller: _blockController, hint: 'Blok / Lokasi', icon: Icons.location_on_outlined),
                        const SizedBox(height: 12),
                        BeeSpeciesDropdown(
                          value: _selectedSpecies,
                          onChanged: (option) =>
                              setState(() => _selectedSpecies = option),
                          warning: _selectedSpecies == null &&
                                  _unrecognizedSpecies != null
                              ? 'Jenis lebah lama "$_unrecognizedSpecies" tidak ada '
                                  'di daftar. Silakan pilih ulang sebelum menyimpan.'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        HoneyTypeField(
                          honeyType: _selectedSpecies?.honeyType,
                        ),
                        const SizedBox(height: 24),
                        const _SectionLabel('Koordinat'),
                        const SizedBox(height: 12),
                        _buildLocationPicker(),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            // Cukup ada foto — lama dari server atau baru dari
                            // galeri. Uploadnya dijalankan setelah ditekan.
                            // Jenis lebah wajib terpilih, termasuk untuk data
                            // lama yang nilainya di luar daftar.
                            onPressed: (hasImage &&
                                    _selectedSpecies != null &&
                                    !_isLoading(state))
                                ? _submit
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.fieldBg,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading(state)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20, height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        isUploading ? 'Mengupload foto...' : 'Menyimpan...',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    !hasImage
                                        ? 'Pilih foto dulu'
                                        : _selectedSpecies == null
                                            ? 'Pilih jenis lebah dulu'
                                            : 'Simpan Perubahan',
                                    style: TextStyle(
                                      color: (hasImage && _selectedSpecies != null)
                                          ? Colors.white
                                          : AppColors.textGray,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _isLoading(state) ? null : () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textGray,
                              side: const BorderSide(color: AppColors.fieldBg),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Batal'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 8, right: 20, bottom: 20,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Sarang', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('Perbarui informasi sarang lebah', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker({
    required bool isUploading,
    required bool isSubmitting,
    required String? localPath,
    required String? networkUrl,
  }) {
    final hasImage = localPath != null || networkUrl != null;
    return GestureDetector(
      onTap: isUploading || isSubmitting || _isCompressingImage ? null : _pickImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasImage ? AppColors.primary : AppColors.fieldBg,
            width: hasImage ? 2 : 1,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _isCompressingImage
              ? const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 12),
                    Text('Mengompres foto...', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                  ]),
                )
              : localPath != null
                  ? _imageWithEditBadge(
                      Image.file(File(localPath), fit: BoxFit.cover),
                      isUploading: isUploading,
                      isBusy: isUploading || isSubmitting,
                    )
                  : networkUrl != null
                      ? _imageWithEditBadge(
                          Image.network(
                            '${AppConstants.imageBaseUrl}$networkUrl',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(Icons.broken_image_outlined, size: 40, color: AppColors.textGray),
                            ),
                          ),
                          isUploading: isUploading,
                          isBusy: isUploading || isSubmitting,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56, height: 56,
                              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.primary),
                            ),
                            const SizedBox(height: 12),
                            const Text('Tap untuk pilih foto', style: TextStyle(color: AppColors.textGray, fontSize: 13)),
                          ],
                        ),
        ),
      ),
    );
  }

  Widget _imageWithEditBadge(
    Widget image, {
    required bool isUploading,
    required bool isBusy,
  }) {
    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        // Foto tetap terlihat selama proses, hanya diredupkan.
        if (isBusy)
          Container(
            color: Colors.black45,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    isUploading ? 'Mengupload foto...' : 'Menyimpan...',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        if (!isBusy)
          Positioned(
            bottom: 8, right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.edit, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text('Ganti Foto', style: TextStyle(color: Colors.white, fontSize: 12)),
              ]),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textGray, size: 20),
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(color: AppColors.textDark, fontSize: 15, fontWeight: FontWeight.bold));
  }
}
