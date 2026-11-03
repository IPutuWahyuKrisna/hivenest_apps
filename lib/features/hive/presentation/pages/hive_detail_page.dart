import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/helpers/image_compress_helper.dart';
import '../../../../../core/helpers/snackbar_helper.dart';
import '../../../../../core/helpers/volume_formatter.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/hive_detail.dart';
import '../../domain/entities/hive_harvester.dart';
import '../../domain/entities/hive_schedule.dart';
import '../bloc/hive_detail_bloc.dart';
import '../bloc/hive_detail_event.dart';
import '../bloc/hive_detail_state.dart';

class HiveDetailPage extends StatelessWidget {
  final String hiveId;

  const HiveDetailPage({super.key, required this.hiveId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<HiveDetailBloc>()..add(HiveDetailLoadRequested(hiveId)),
      child: _HiveDetailView(hiveId: hiveId),
    );
  }
}

class _HiveDetailView extends StatefulWidget {
  final String hiveId;
  const _HiveDetailView({required this.hiveId});

  @override
  State<_HiveDetailView> createState() => _HiveDetailViewState();
}

class _HiveDetailViewState extends State<_HiveDetailView> {
  bool _mutated = false;

  /// Aktif sejak panen berhasil dicatat sampai jadwal panen berikutnya
  /// tersimpan. Selama true, dialog jadwal terus dibuka ulang kalau gagal.
  bool _mustSetNextSchedule = false;

  String get hiveId => widget.hiveId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HiveDetailBloc, HiveDetailState>(
      listenWhen: (previous, current) =>
          current is HiveDetailDeleteSuccess ||
          current is HiveDetailDeleteFailure ||
          current is HiveScheduleFailure ||
          current is HiveHarvestFailure ||
          current is HiveHarvestSuccess ||
          (previous is HiveScheduleSubmitting && current is HiveDetailLoaded),
      listener: (context, state) {
        if (state is HiveDetailDeleteSuccess) {
          context.pop(true);
        } else if (state is HiveDetailDeleteFailure) {
          SnackbarHelper.showError(context, state.message);
        } else if (state is HiveScheduleFailure) {
          SnackbarHelper.showError(context, state.message);
          // Gagal menyimpan jadwal wajib — buka lagi formnya supaya peternak
          // bisa langsung mencoba ulang.
          if (_mustSetNextSchedule) {
            _showScheduleHarvestDialog(context, state.detail,
                isMandatory: true);
          }
        } else if (state is HiveHarvestFailure) {
          SnackbarHelper.showError(context, state.message);
        } else if (state is HiveHarvestSuccess) {
          _mutated = true;
          _mustSetNextSchedule = true;
          SnackbarHelper.showSuccess(context, 'Hasil panen berhasil dicatat');
          _showScheduleHarvestDialog(context, state.detail, isMandatory: true);
        } else if (state is HiveDetailLoaded) {
          _mustSetNextSchedule = false;
          SnackbarHelper.showSuccess(context, 'Jadwal panen berhasil disimpan');
        }
      },
      builder: (context, state) {
        if (state is HiveDetailLoading || state is HiveDetailInitial) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                _buildLoadingHeader(context),
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          );
        }

        if (state is HiveDetailFailure) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Column(
              children: [
                _buildLoadingHeader(context),
                Expanded(child: _buildError(context, state.message)),
              ],
            ),
          );
        }

        if (state is HiveDetailLoaded) {
          return _buildLoaded(context, state.detail, state.harvesters, state.schedules);
        }

        if (state is HiveDetailDeleting) {
          return _buildLoaded(
            context, state.detail, state.harvesters, state.schedules,
            isBusy: true,
          );
        }

        if (state is HiveDetailDeleteFailure) {
          return _buildLoaded(
            context, state.detail, state.harvesters, state.schedules,
          );
        }

        if (state is HiveScheduleSubmitting) {
          return _buildLoaded(
            context, state.detail, state.harvesters, state.schedules,
            isBusy: true,
          );
        }

        if (state is HiveScheduleFailure) {
          return _buildLoaded(
            context, state.detail, state.harvesters, state.schedules,
          );
        }

        if (state is HiveHarvestSubmitting) {
          return _buildLoaded(
            context, state.detail, state.harvesters, state.schedules,
            isBusy: true,
            busyLabel: state.isUploadingImage
                ? 'Mengupload foto...'
                : 'Menyimpan hasil panen...',
          );
        }

        if (state is HiveHarvestFailure) {
          return _buildLoaded(
            context, state.detail, state.harvesters, state.schedules,
          );
        }

        if (state is HiveHarvestSuccess) {
          return _buildLoaded(
            context, state.detail, state.harvesters, state.schedules,
          );
        }

        return const Scaffold();
      },
    );
  }

  Future<void> _onEditTapped(BuildContext context, HiveDetail detail) async {
    final reloaded = await context.push<bool>(
      '/edit-hive/${detail.id}',
      extra: detail,
    );
    if (reloaded == true && context.mounted) {
      setState(() => _mutated = true);
      context.read<HiveDetailBloc>().add(HiveDetailLoadRequested(hiveId));
    }
  }

  void _showDeleteDialog(BuildContext context, HiveDetail detail) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Hapus Sarang'),
        content: Text(
          'Yakin ingin menghapus "${detail.name}"?\nTindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<HiveDetailBloc>().add(HiveDeleteRequested(detail.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _showScheduleHarvestDialog(
    BuildContext context,
    HiveDetail detail, {
    bool isMandatory = false,
  }) async {
    final bloc = context.read<HiveDetailBloc>();
    final result = await showDialog<_ScheduleHarvestResult>(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (_) => _ScheduleHarvestDialog(
        hiveName: detail.name,
        isMandatory: isMandatory,
      ),
    );

    if (result == null) {
      // Dalam mode wajib dialog tidak menyediakan jalan keluar, tapi kalau
      // sampai tertutup juga, buka lagi supaya sarang tidak tertinggal
      // tanpa jadwal panen berikutnya.
      if (isMandatory && mounted) {
        await _showScheduleHarvestDialog(context, detail, isMandatory: true);
      }
      return;
    }

    bloc.add(HiveScheduleHarvestRequested(
      hiveId: detail.id,
      scheduledAt: result.scheduledAt,
      notes: result.notes,
    ));
  }

  Future<void> _showRecordHarvestDialog(
    BuildContext context,
    HiveDetail detail,
    HiveSchedule schedule,
  ) async {
    final bloc = context.read<HiveDetailBloc>();
    final result = await showDialog<_RecordHarvestResult>(
      context: context,
      builder: (_) => _RecordHarvestDialog(
        hiveName: detail.name,
        scheduledDate: schedule.formattedDate,
      ),
    );
    if (result != null) {
      bloc.add(HiveHarvestRecordRequested(
        hiveId: detail.id,
        scheduleId: schedule.id,
        volumeMl: result.volumeMl,
        notes: result.notes,
        localImagePath: result.localImagePath,
        fileName: result.fileName,
      ));
    }
  }

  Widget _buildLoadingHeader(BuildContext context) {
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
            onPressed: () => context.pop(_mutated),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Text(
            'Detail Sarang',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.textGray),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context
                  .read<HiveDetailBloc>()
                  .add(HiveDetailLoadRequested(
                      (context.read<HiveDetailBloc>().state as HiveDetailFailure)
                          .message)),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    HiveDetail detail,
    List<HiveHarvester> harvesters,
    List<HiveSchedule> schedules, {
    bool isBusy = false,
    String? busyLabel,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(context, detail, isBusy: isBusy),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfoSection(context, detail, harvesters, schedules),
                    const SizedBox(height: 20),
                    _buildHarvestersSection(harvesters),
                    const SizedBox(height: 20),
                    _buildSchedulesSection(
                      context,
                      detail,
                      schedules,
                      isBusy: isBusy,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
          if (isBusy)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      if (busyLabel != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          busyLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    HiveDetail detail, {
    bool isBusy = false,
  }) {
    final statusColor = _statusTextColor(detail.harvestStatus);
    final statusBg = _statusBgColor(detail.harvestStatus);

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
        right: 4,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(_mutated),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  detail.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  detail.harvestStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                enabled: !isBusy,
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) {
                  if (value == 'edit') {
                    _onEditTapped(context, detail);
                  } else if (value == 'delete') {
                    _showDeleteDialog(context, detail);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [
                      Icon(Icons.edit_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Edit Sarang'),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Hapus Sarang', style: TextStyle(color: Colors.red)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  detail.block,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.local_florist_outlined, size: 14, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  detail.beeSpecies,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    HiveDetail detail,
    List<HiveHarvester> harvesters,
    List<HiveSchedule> schedules,
  ) {
    final isOverdue = detail.nextHarvestAt != null &&
        detail.nextHarvestAt!.isBefore(DateTime.now());
    final nextHarvestNotes = _findNextHarvestNotes(detail, schedules);

    // Dihitung dari daftar pemanen, bukan dari `detail`. Endpoint /hives/{id}
    // tidak mengirim total volume, sedangkan /harvesters sudah memuat rincian
    // per orang — menjumlahkannya lebih akurat daripada menampilkan 0.
    final totalVolumeMl = harvesters.fold<int>(
      0,
      (sum, h) => sum + h.totalVolumeMl,
    );
    final totalHarvests = harvesters.fold<int>(
      0,
      (sum, h) => sum + h.totalHarvests,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Informasi Sarang'),
        const SizedBox(height: 12),
        _ScheduleHarvestButton(
          label: detail.nextHarvestAt == null
              ? 'Atur Jadwal Panen'
              : isOverdue
                  ? 'Jadwal Panen Sudah Lewat — Atur Ulang'
                  : 'Ubah Jadwal Panen',
          onTap: () => _showScheduleHarvestDialog(context, detail),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(
              icon: Icons.inventory_2_outlined,
              label: 'Total Panen',
              value: '${totalHarvests}x',
            ),
            const SizedBox(width: 12),
            _StatCard(
              icon: Icons.water_drop_outlined,
              label: 'Total Hasil',
              value: VolumeFormatter.format(totalVolumeMl),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatCard(
              icon: Icons.water_drop_outlined,
              label: 'Jenis Madu',
              value: detail.honeyType,
            ),
            const SizedBox(width: 12),
            _StatCard(
              icon: Icons.person_outlined,
              label: 'Dibuat oleh',
              value: detail.creatorName,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _NextHarvestBanner(
          formattedDate: detail.formattedNextHarvest,
          notes: nextHarvestNotes,
        ),
      ],
    );
  }

  /// Cari notes jadwal panen berikutnya dengan mencocokkan tanggal
  /// `detail.nextHarvestAt` terhadap jadwal aktif (belum dibatalkan/selesai)
  /// dari list yang sudah di-fetch, tanpa perlu panggilan API tambahan.
  String? _findNextHarvestNotes(
    HiveDetail detail,
    List<HiveSchedule> schedules,
  ) {
    final target = detail.nextHarvestAt;
    if (target == null) return null;
    for (final s in schedules) {
      if (s.status != 'completed' &&
          s.status != 'cancelled' &&
          s.scheduledAt.year == target.year &&
          s.scheduledAt.month == target.month &&
          s.scheduledAt.day == target.day) {
        return s.notes;
      }
    }
    return null;
  }

  Widget _buildHarvestersSection(List<HiveHarvester> harvesters) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Pemanen'),
        const SizedBox(height: 12),
        if (harvesters.isEmpty)
          _EmptyState(
            icon: Icons.people_outline,
            message: 'Belum ada data pemanen',
          )
        else
          ...harvesters.map(
            (h) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HarvesterCard(harvester: h),
            ),
          ),
      ],
    );
  }

  Widget _buildSchedulesSection(
    BuildContext context,
    HiveDetail detail,
    List<HiveSchedule> schedules, {
    required bool isBusy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Riwayat Jadwal'),
        const SizedBox(height: 12),
        if (schedules.isEmpty)
          _EmptyState(
            icon: Icons.calendar_today_outlined,
            message: 'Belum ada riwayat jadwal',
          )
        else
          ...schedules.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ScheduleCard(
                schedule: s,
                // Panen hanya bisa dicatat untuk jadwal yang belum selesai
                // dan belum dibatalkan.
                onRecordHarvest:
                    (s.status == 'completed' || s.status == 'cancelled' || isBusy)
                        ? null
                        : () => _showRecordHarvestDialog(context, detail, s),
              ),
            ),
          ),
      ],
    );
  }

  Color _statusTextColor(String status) {
    switch (status) {
      case 'Siap Panen':
        return AppColors.statusGreenText;
      case 'Hampir Siap':
        return AppColors.statusAmberText;
      default:
        return AppColors.statusGrayText;
    }
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Siap Panen':
        return AppColors.statusGreenBg;
      case 'Hampir Siap':
        return AppColors.statusAmberBg;
      default:
        return AppColors.statusGrayBg;
    }
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

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

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Schedule harvest button ──────────────────────────────────────────────────

class _ScheduleHarvestButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ScheduleHarvestButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.event_available_outlined,
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Schedule harvest dialog ───────────────────────────────────────────────────

class _ScheduleHarvestResult {
  final DateTime scheduledAt;
  final String notes;
  const _ScheduleHarvestResult(this.scheduledAt, this.notes);
}

// ── Dialog catat panen ────────────────────────────────────────────────────────

class _RecordHarvestResult {
  final int volumeMl;
  final String notes;
  final String localImagePath;
  final String fileName;
  const _RecordHarvestResult({
    required this.volumeMl,
    required this.notes,
    required this.localImagePath,
    required this.fileName,
  });
}

class _RecordHarvestDialog extends StatefulWidget {
  final String hiveName;
  final String scheduledDate;

  const _RecordHarvestDialog({
    required this.hiveName,
    required this.scheduledDate,
  });

  @override
  State<_RecordHarvestDialog> createState() => _RecordHarvestDialogState();
}

class _RecordHarvestDialogState extends State<_RecordHarvestDialog> {
  final _volumeController = TextEditingController();
  final _notesController = TextEditingController();

  String? _localImagePath;
  String? _fileName;
  bool _isCompressingImage = false;

  @override
  void initState() {
    super.initState();
    _volumeController.addListener(() => setState(() {}));
    _notesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _volumeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Foto hanya dipilih dan dikompres di sini. Uploadnya dijalankan bloc
  /// setelah dialog ditutup, mengikuti pola tambah dan edit sarang.
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file == null || !mounted) return;

    setState(() => _isCompressingImage = true);
    final compressedPath =
        await ImageCompressHelper.compressUnderLimit(file.path);
    if (!mounted) return;
    setState(() {
      _isCompressingImage = false;
      _localImagePath = compressedPath;
      _fileName = file.name;
    });
  }

  int? get _volumeMl {
    final raw = _volumeController.text.trim();
    if (raw.isEmpty) return null;
    final parsed = int.tryParse(raw);
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  @override
  Widget build(BuildContext context) {
    final volume = _volumeMl;
    final hasNotes = _notesController.text.trim().isNotEmpty;
    final hasImage = _localImagePath != null && _fileName != null;
    final canSubmit =
        volume != null && hasNotes && hasImage && !_isCompressingImage;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.water_drop_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Catat Hasil Panen',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.hiveName} · ${widget.scheduledDate}',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textGray),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── Foto hasil panen ────────────────────────────────────────
              const _DialogFieldLabel('Foto Hasil Panen'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _isCompressingImage ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: hasImage
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: _isCompressingImage
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                    color: AppColors.primary),
                                SizedBox(height: 10),
                                Text(
                                  'Mengompres foto...',
                                  style: TextStyle(
                                      color: AppColors.textGray, fontSize: 12),
                                ),
                              ],
                            ),
                          )
                        : hasImage
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(_localImagePath!),
                                    fit: BoxFit.cover,
                                  ),
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
                                              color: Colors.white, size: 13),
                                          SizedBox(width: 4),
                                          Text(
                                            'Ganti Foto',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_photo_alternate_outlined,
                                        size: 28, color: AppColors.primary),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap untuk pilih foto',
                                      style: TextStyle(
                                          color: AppColors.textGray,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Volume ──────────────────────────────────────────────────
              const _DialogFieldLabel('Volume Madu (ml)'),
              const SizedBox(height: 8),
              TextField(
                controller: _volumeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: 'Contoh: 8500',
                  filled: true,
                  fillColor: AppColors.fieldBg,
                  prefixIcon: const Icon(Icons.science_outlined,
                      size: 20, color: AppColors.textGray),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // ── Catatan ─────────────────────────────────────────────────
              const _DialogFieldLabel('Catatan'),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Contoh: kualitas madu bagus, warna pekat',
                  filled: true,
                  fillColor: AppColors.fieldBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        foregroundColor: AppColors.textGray,
                      ),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canSubmit
                          ? () => Navigator.of(context).pop(
                                _RecordHarvestResult(
                                  volumeMl: volume,
                                  notes: _notesController.text.trim(),
                                  localImagePath: _localImagePath!,
                                  fileName: _fileName!,
                                ),
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.fieldBg,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                          color:
                              canSubmit ? Colors.white : AppColors.textGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogFieldLabel extends StatelessWidget {
  final String text;
  const _DialogFieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
    );
  }
}

class _ScheduleHarvestDialog extends StatefulWidget {
  final String hiveName;

  /// Mode wajib dipakai tepat setelah panen tercatat: tombol Batal
  /// disembunyikan dan dialog tidak bisa ditutup lewat tombol back.
  final bool isMandatory;

  const _ScheduleHarvestDialog({
    required this.hiveName,
    this.isMandatory = false,
  });

  @override
  State<_ScheduleHarvestDialog> createState() => _ScheduleHarvestDialogState();
}

class _ScheduleHarvestDialogState extends State<_ScheduleHarvestDialog> {
  DateTime? _selectedDate;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String get _formattedDate {
    if (_selectedDate == null) return 'Pilih tanggal panen';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final d = _selectedDate!;
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = _selectedDate != null;
    final hasNotes = _notesController.text.trim().isNotEmpty;
    final canSubmit = hasDate && hasNotes;

    return PopScope(
      // Dalam mode wajib, tombol back sistem tidak menutup dialog.
      canPop: !widget.isMandatory,
      child: Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.event_available_outlined,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isMandatory
                            ? 'Atur Jadwal Panen Berikutnya'
                            : 'Atur Jadwal Panen',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.hiveName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGray),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.isMandatory) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Panen sudah tercatat. Tentukan jadwal panen berikutnya '
                        'agar sarang ini tidak terlewat.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            const Text(
              'Tanggal Panen',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.fieldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: hasDate
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.5))
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
                        _formattedDate,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              hasDate ? FontWeight.w600 : FontWeight.normal,
                          color:
                              hasDate ? AppColors.textDark : AppColors.textGray,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        size: 18, color: AppColors.textGray),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Catatan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'contoh: estimasi yield 8-9 kg',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: canSubmit
                    ? () => Navigator.of(context).pop(
                          _ScheduleHarvestResult(
                            _selectedDate!,
                            _notesController.text.trim(),
                          ),
                        )
                    : null,
                child: const Text('Simpan Jadwal'),
              ),
            ),
            if (!widget.isMandatory) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
            ],
          ],
        ),
      ),
      ),
    );
  }
}

// ── Next harvest banner ───────────────────────────────────────────────────────

class _NextHarvestBanner extends StatelessWidget {
  final String formattedDate;
  final String? notes;
  const _NextHarvestBanner({required this.formattedDate, this.notes});

  @override
  Widget build(BuildContext context) {
    final hasNotes = notes != null && notes!.trim().isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.agriculture_outlined,
                    size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panen Berikutnya',
                    style:
                        TextStyle(fontSize: 11, color: AppColors.textGray),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasNotes) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.primary.withValues(alpha: 0.15)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.notes_outlined,
                    size: 14, color: AppColors.textGray),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    notes!,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGray),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Harvester card ────────────────────────────────────────────────────────────

class _HarvesterCard extends StatelessWidget {
  final HiveHarvester harvester;
  const _HarvesterCard({required this.harvester});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_outline,
                size: 22, color: AppColors.textGray),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  harvester.harvesterName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${harvester.totalHarvests}x panen',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textGray),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusGreenBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              VolumeFormatter.format(harvester.totalVolumeMl),
              style: const TextStyle(
                color: AppColors.statusGreenText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Schedule card ─────────────────────────────────────────────────────────────

class _ScheduleCard extends StatelessWidget {
  final HiveSchedule schedule;

  /// Null berarti jadwal ini tidak bisa dipanen — sudah selesai, dibatalkan,
  /// atau sedang ada proses lain berjalan.
  final VoidCallback? onRecordHarvest;

  const _ScheduleCard({required this.schedule, this.onRecordHarvest});

  Color get _statusTextColor {
    switch (schedule.status) {
      case 'completed':
        return AppColors.statusGreenText;
      case 'cancelled':
        return AppColors.statusGrayText;
      default:
        return AppColors.statusAmberText;
    }
  }

  Color get _statusBgColor {
    switch (schedule.status) {
      case 'completed':
        return AppColors.statusGreenBg;
      case 'cancelled':
        return AppColors.statusGrayBg;
      default:
        return AppColors.statusAmberBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_month_outlined,
                      size: 20, color: AppColors.textGray),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.formattedDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Oleh ${schedule.creatorName}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGray),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusBgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    schedule.statusLabel,
                    style: TextStyle(
                      color: _statusTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (schedule.notes != null) ...[
            const Divider(height: 1, color: AppColors.fieldBg),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_outlined,
                      size: 14, color: AppColors.textGray),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      schedule.notes!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGray),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (schedule.status == 'cancelled' &&
              schedule.cancellationReason != null) ...[
            const Divider(height: 1, color: AppColors.fieldBg),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.cancel_outlined,
                      size: 14, color: AppColors.statusGrayText),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      schedule.cancellationReason!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.statusGrayText),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onRecordHarvest != null) ...[
            const Divider(height: 1, color: AppColors.fieldBg),
            InkWell(
              onTap: onRecordHarvest,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.water_drop_outlined,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Catat Panen',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textGray),
          const SizedBox(height: 8),
          Text(
            message,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}
