import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/nearest_harvest.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';

class PanenTerdekatSection extends StatelessWidget {
  final List<NearestHarvest> harvests;

  /// Beranda hanya menampilkan yang paling mendesak. Sisanya di tab Jadwal.
  static const int maxItems = 5;

  const PanenTerdekatSection({super.key, required this.harvests});

  /// Menyisakan jadwal dalam 30 hari ke depan, diurutkan dari yang paling
  /// dekat, lalu dipotong maksimal [maxItems].
  List<NearestHarvest> get _visibleHarvests {
    final filtered = harvests.where((h) => h.isDueSoon).toList()
      ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));
    return filtered.take(maxItems).toList();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleHarvests;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Panen Terdekat',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Tombol "Lihat Semua" dinonaktifkan: /schedule adalah cabang
            // StatefulShellRoute, jadi kalau di-push halamannya tidak punya
            // jalan kembali ke beranda.
            // GestureDetector(
            //   onTap: () => context.push('/schedule'),
            //   child: const Text(
            //     'Lihat Semua',
            //     style: TextStyle(
            //       color: AppColors.primary,
            //       fontSize: 13,
            //       fontWeight: FontWeight.w600,
            //     ),
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Text(
              'Belum ada jadwal panen terdekat',
              style: TextStyle(color: AppColors.textGray, fontSize: 13),
            ),
          )
        else
          ...visible.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PanenCard(item: item),
            ),
          ),
      ],
    );
  }
}

class _PanenCard extends StatelessWidget {
  final NearestHarvest item;

  const _PanenCard({required this.item});

  @override
  Widget build(BuildContext context) {
    // Aturan ambangnya tinggal di entity supaya sama dengan halaman detail.
    final isReady = item.isReady;
    final status = item.statusLabel;
    final daysLeft = item.daysUntilLabel;
    final date =
        '${item.scheduledAt.day}/${item.scheduledAt.month}/${item.scheduledAt.year}';

    return GestureDetector(
      // Kalau id sarangnya kosong, kartu dibiarkan tidak bisa ditekan
      // daripada membuka rute /hive/ yang tidak valid.
      onTap: item.hive.id.isEmpty ? null : () => _openHiveDetail(context),
      child: _buildCard(isReady, status, daysLeft, date),
    );
  }

  Future<void> _openHiveDetail(BuildContext context) async {
    final bloc = context.read<HomeBloc>();
    final changed = await context.push<bool>('/hive/${item.hive.id}');
    // Sarang bisa saja diubah atau dipanen di halaman detail, jadi statistik
    // beranda ditarik ulang begitu kembali.
    if (changed == true) {
      bloc.add(const HomeStatsLoadRequested());
    }
  }

  Widget _buildCard(
    bool isReady,
    String status,
    String daysLeft,
    String date,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🐝', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.hive.name,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 13,
                      color: AppColors.textGray,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      item.hive.block,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 13,
                      color: AppColors.textGray,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      date,
                      style: const TextStyle(
                        color: AppColors.textGray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isReady
                      ? AppColors.statusGreenBg
                      : AppColors.statusAmberBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: isReady
                        ? AppColors.statusGreenText
                        : AppColors.statusAmberText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.statusAmberBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  daysLeft,
                  style: const TextStyle(
                    color: AppColors.statusAmberText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
