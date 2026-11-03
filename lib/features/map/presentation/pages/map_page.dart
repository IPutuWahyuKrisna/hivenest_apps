import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/hive_detail.dart';
import '../../domain/entities/hive_location.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const MapHivesLoadRequested()),
      child: const _MapView(),
    );
  }
}

class _MapView extends StatefulWidget {
  const _MapView();

  @override
  State<_MapView> createState() => _MapViewState();
}

class _MapViewState extends State<_MapView> {
  final _mapController = MapController();
  String? _selectedHiveId;
  LatLng? _myLocation;
  bool _isLoadingLocation = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadMyLocation();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => context.read<MapBloc>().add(const MapHivesRefreshRequested()),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadMyLocation({bool moveCamera = false}) async {
    setState(() => _isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() => _myLocation = latLng);
      if (moveCamera) _mapController.move(latLng, 15);
    } catch (_) {
      // Lokasi bersifat opsional di peta ini, abaikan jika gagal.
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _onMarkerTap(HiveLocation hive) {
    setState(() => _selectedHiveId = hive.id);
    _mapController.move(LatLng(hive.latitude, hive.longitude), 13);
    context.read<MapBloc>().add(MapHiveDetailRequested(hive.id));
    _showHiveSheet();
  }

  void _showHiveSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => BlocProvider.value(
        value: context.read<MapBloc>(),
        child: const _HiveBottomSheet(),
      ),
    ).then((_) => setState(() => _selectedHiveId = null));
  }

  List<HiveLocation> _hivesFromState(MapState state) {
    if (state is MapHivesLoaded) return state.hives;
    if (state is MapDetailLoading) return state.hives;
    if (state is MapDetailLoaded) return state.hives;
    if (state is MapDetailFailure) return state.hives;
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapBloc, MapState>(
      listener: (context, state) {
        if (state is MapHivesLoaded && state.hives.length > 1) {
          final points = state.hives
              .map((h) => LatLng(h.latitude, h.longitude))
              .toList();
          _mapController.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(points),
              padding: const EdgeInsets.fromLTRB(48, 120, 48, 80),
            ),
          );
        }
      },
      child: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          final hives = _hivesFromState(state);
          return Scaffold(
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(-8.4095, 115.1889),
                    initialZoom: 9.5,
                    minZoom: 7,
                    maxZoom: 18,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.hivenest.app',
                    ),
                    if (_myLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _myLocation!,
                            width: 24,
                            height: 24,
                            child: const _MyLocationMarker(),
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: hives.map((hive) {
                        final isSelected = _selectedHiveId == hive.id;
                        return Marker(
                          point: LatLng(hive.latitude, hive.longitude),
                          width: isSelected ? 56 : 48,
                          height: isSelected ? 56 : 48,
                          child: GestureDetector(
                            onTap: () => _onMarkerTap(hive),
                            child: _HiveMarker(isSelected: isSelected),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                _buildHeader(context, state, hives.length),
                if (state is MapHivesLoading)
                  const Center(child: CircularProgressIndicator()),
                if (state is MapFailure)
                  _buildErrorOverlay(context, state.message),
                _buildLegend(),
                _buildLocateMeButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MapState state, int hiveCount) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.95),
              AppColors.primary.withValues(alpha: 0),
            ],
            stops: const [0, 0.75, 1],
          ),
        ),
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20,
          right: 20,
          bottom: 32,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Peta Sarang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state is MapHivesLoading
                        ? 'Memuat data...'
                        : '$hiveCount lokasi terdaftar',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hive, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$hiveCount Sarang',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(BuildContext context, String message) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 48, color: AppColors.textGray),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<MapBloc>().add(const MapHivesLoadRequested()),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 16,
      left: 16,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Keterangan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            _LegendItem(
                color: AppColors.statusGreenText, label: 'Siap Panen'),
            const SizedBox(height: 4),
            _LegendItem(
                color: AppColors.statusAmberText, label: 'Hampir Siap'),
            const SizedBox(height: 4),
            _LegendItem(
                color: AppColors.statusGrayText, label: 'Monitoring'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocateMeButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: _isLoadingLocation
              ? null
              : () => _loadMyLocation(moveCamera: true),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _isLoadingLocation
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(
                    Icons.my_location,
                    color: AppColors.primary,
                    size: 22,
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Marker ────────────────────────────────────────────────────────────────────

class _MyLocationMarker extends StatelessWidget {
  const _MyLocationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.statusBlueText.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.statusBlueText,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HiveMarker extends StatelessWidget {
  final bool isSelected;

  const _HiveMarker({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSelected ? 44 : 38,
            height: isSelected ? 44 : 38,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: isSelected ? 12 : 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Text('🐝', style: TextStyle(fontSize: 18)),
            ),
          ),
          CustomPaint(
            size: const Size(10, 6),
            painter: _MarkerTailPainter(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _MarkerTailPainter extends CustomPainter {
  final Color color;
  const _MarkerTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Bottom Sheet ──────────────────────────────────────────────────────────────

class _HiveBottomSheet extends StatelessWidget {
  const _HiveBottomSheet();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state is MapDetailLoaded) {
          return _buildContent(context, state.detail);
        }
        if (state is MapDetailFailure) {
          return _buildError(context, state.message);
        }
        return _buildLoading();
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 40, color: AppColors.textGray),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: AppColors.textGray, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HiveDetail detail) {
    final statusColor = _statusColor(detail.harvestStatus);
    final statusBg = _statusBg(detail.harvestStatus);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.fieldBg,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child:
                    const Center(child: Text('🐝', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 13, color: AppColors.textGray),
                        const SizedBox(width: 2),
                        Text(
                          detail.block,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textGray),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  detail.harvestStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.fieldBg, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _InfoTile(
                icon: Icons.local_florist_outlined,
                label: 'Jenis Lebah',
                value: detail.beeSpecies,
              ),
              const SizedBox(width: 12),
              _InfoTile(
                icon: Icons.water_drop_outlined,
                label: 'Jenis Madu',
                value: detail.honeyType,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoTile(
                icon: Icons.inventory_2_outlined,
                label: 'Total Panen',
                value: '${detail.totalHarvests}x',
              ),
              const SizedBox(width: 12),
              _InfoTile(
                icon: Icons.scale_outlined,
                label: 'Total Berat',
                value: '${detail.totalWeightKg} kg',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.agriculture_outlined,
                        size: 20, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Panen Berikutnya',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textGray),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.formattedNextHarvest,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async {
                final mapBloc = context.read<MapBloc>();
                final router = GoRouter.of(context);
                Navigator.pop(context);
                final refreshed = await router.push<bool>('/hive/${detail.id}');
                if (refreshed == true) {
                  mapBloc.add(const MapHivesLoadRequested());
                }
              },
              icon: const Icon(Icons.info_outline, size: 18),
              label: const Text('Lihat Detail Sarang'),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Siap Panen':
        return AppColors.statusGreenText;
      case 'Hampir Siap':
        return AppColors.statusAmberText;
      default:
        return AppColors.statusGrayText;
    }
  }

  Color _statusBg(String status) {
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

// ── Helpers ───────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.fieldBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textGray),
                  ),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style:
              const TextStyle(fontSize: 11, color: AppColors.textDark),
        ),
      ],
    );
  }
}
