import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/constants/bee_species_options.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/helpers/image_compress_helper.dart';
import '../../../../../core/helpers/snackbar_helper.dart';
import '../../../../../core/pages/map_picker_page.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/widgets/bee_species_dropdown.dart';
import '../bloc/add_hive_bloc.dart';
import '../bloc/add_hive_event.dart';
import '../bloc/add_hive_state.dart';

class AddHivePage extends StatelessWidget {
  const AddHivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddHiveBloc>(),
      child: const _AddHiveView(),
    );
  }
}

class _AddHiveView extends StatefulWidget {
  const _AddHiveView();

  @override
  State<_AddHiveView> createState() => _AddHiveViewState();
}

class _AddHiveViewState extends State<_AddHiveView> {
  final _nameController = TextEditingController();
  final _blockController = TextEditingController();
  final _notesController = TextEditingController();

  /// Jenis madu tidak dipilih terpisah — ikut dari opsi yang dipilih di sini.
  BeeSpeciesOption? _selectedSpecies;

  double? _lat;
  double? _lng;
  DateTime? _scheduledAt;
  bool _isLoadingGps = false;
  bool _isCompressingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _blockController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduledDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledAt ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _scheduledAt = picked);
  }

  String get _formattedScheduledDate {
    if (_scheduledAt == null) return 'Pilih tanggal panen';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final d = _scheduledAt!;
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _buildScheduleHarvestPicker() {
    final hasDate = _scheduledAt != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _pickScheduledDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
              border: hasDate
                  ? Border.all(color: AppColors.primary.withValues(alpha: 0.5))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: hasDate ? AppColors.primary : AppColors.textGray,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formattedScheduledDate,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                      color: hasDate ? AppColors.textDark : AppColors.textGray,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: AppColors.textGray),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _notesController,
          hint: 'Catatan (contoh: estimasi yield 8-9 kg)',
          icon: Icons.notes_outlined,
        ),
      ],
    );
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
          initialLatLng: (_lat != null && _lng != null)
              ? LatLng(_lat!, _lng!)
              : null,
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
        // Coordinate display card
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
              Icon(
                Icons.location_on,
                color: hasLocation ? AppColors.primary : AppColors.textGray,
                size: 20,
              ),
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
        // Two action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isLoadingGps ? null : _useCurrentLocation,
                icon: _isLoadingGps
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(_isLoadingGps ? 'Memuat...' : 'Lokasi Saat Ini'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;

    setState(() => _isCompressingImage = true);
    final compressedPath = await ImageCompressHelper.compressUnderLimit(file.path);
    if (!mounted) return;
    setState(() => _isCompressingImage = false);

    context.read<AddHiveBloc>().add(AddHiveImageSelected(
          imagePath: compressedPath,
          fileName: file.name,
        ));
  }

  void _submit() {
    final name = _nameController.text.trim();
    final block = _blockController.text.trim();
    final species = _selectedSpecies;
    final notes = _notesController.text.trim();

    if (name.isEmpty ||
        block.isEmpty ||
        species == null ||
        notes.isEmpty ||
        _lat == null ||
        _lng == null ||
        _scheduledAt == null) {
      SnackbarHelper.showWarning(context, 'Lengkapi semua field terlebih dahulu');
      return;
    }

    context.read<AddHiveBloc>().add(AddHiveSubmitted(
          name: name,
          block: block,
          beeSpecies: species.beeSpecies,
          honeyType: species.honeyType,
          latitude: _lat!,
          longitude: _lng!,
          scheduledAt: _scheduledAt!,
          notes: notes,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddHiveBloc, AddHiveState>(
      listener: (context, state) {
        if (state is AddHiveSuccess) {
          SnackbarHelper.showSuccess(context, 'Sarang berhasil ditambahkan');
          context.pop(true);
        } else if (state is AddHiveFailure) {
          SnackbarHelper.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<AddHiveBloc, AddHiveState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImagePicker(context, state),
                        const SizedBox(height: 24),
                        const _SectionLabel('Informasi Sarang'),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Nama Sarang',
                          icon: Icons.hive_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _blockController,
                          hint: 'Blok / Lokasi',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 12),
                        _buildBeeSpeciesDropdown(),
                        const SizedBox(height: 12),
                        _buildHoneyTypeField(),
                        const SizedBox(height: 24),
                        const _SectionLabel('Koordinat'),
                        const SizedBox(height: 12),
                        _buildLocationPicker(),
                        const SizedBox(height: 24),
                        const _SectionLabel('Jadwal Panen Pertama'),
                        const SizedBox(height: 12),
                        _buildScheduleHarvestPicker(),
                        const SizedBox(height: 32),
                        _buildSubmitButton(context, state),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _isLoading(state)
                                ? null
                                : () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textGray,
                              side: const BorderSide(color: AppColors.fieldBg),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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

  bool _isLoading(AddHiveState state) =>
      state is AddHiveImageUploading || state is AddHiveSubmitting;

  /// Path foto lokal dari state manapun yang masih memegangnya, termasuk
  /// setelah submit gagal supaya preview tidak hilang saat user mencoba lagi.
  String? _localImagePath(AddHiveState state) {
    if (state is AddHiveImageReady) return state.localImagePath;
    if (state is AddHiveImageUploading) return state.localImagePath;
    if (state is AddHiveSubmitting) return state.localImagePath;
    if (state is AddHiveFailure) return state.localImagePath;
    return null;
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
        left: 8,
        right: 20,
        bottom: 20,
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
              Text(
                'Tambah Sarang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Daftarkan sarang lebah baru',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context, AddHiveState state) {
    final localPath = _localImagePath(state);
    final hasImage = localPath != null && localPath.isNotEmpty;

    return GestureDetector(
      onTap: _isLoading(state) || _isCompressingImage ? null : _pickImage,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: _isCompressingImage
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 12),
                      Text(
                        'Mengompres foto...',
                        style:
                            TextStyle(color: AppColors.textGray, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : hasImage
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(localPath!), fit: BoxFit.cover),
                        // Upload berjalan setelah tombol Simpan ditekan, jadi
                        // foto tetap terlihat dengan overlay progres di atasnya.
                        if (state is AddHiveImageUploading)
                          Container(
                            color: Colors.black45,
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                      color: Colors.white),
                                  SizedBox(height: 12),
                                  Text(
                                    'Mengupload foto...',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (!_isLoading(state))
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit,
                                      color: Colors.white, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    'Ganti Foto',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tap untuk pilih foto sarang',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Foto wajib diisi, diupload saat menyimpan',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildBeeSpeciesDropdown() {
    return BeeSpeciesDropdown(
      value: _selectedSpecies,
      onChanged: (option) => setState(() => _selectedSpecies = option),
    );
  }

  Widget _buildHoneyTypeField() {
    return HoneyTypeField(honeyType: _selectedSpecies?.honeyType);
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textGray, size: 20),
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, AddHiveState state) {
    // Tombol aktif begitu foto lokal sudah dipilih — uploadnya baru dijalankan
    // setelah tombol ini ditekan, jadi tidak perlu menunggu imageUrl.
    final hasPickedImage = _localImagePath(state) != null;
    final isBusy = _isLoading(state);
    final canSubmit = hasPickedImage && !isBusy && !_isCompressingImage;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: canSubmit ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.fieldBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isBusy
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    state is AddHiveImageUploading
                        ? 'Mengupload foto...'
                        : 'Menyimpan...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                hasPickedImage ? 'Simpan Sarang' : 'Pilih foto dulu',
                style: TextStyle(
                  color: hasPickedImage ? Colors.white : AppColors.textGray,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
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
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
