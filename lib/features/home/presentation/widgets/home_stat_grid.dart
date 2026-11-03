import 'package:flutter/material.dart';
import '../../../../../core/helpers/volume_formatter.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/home_stats.dart';

class HomeStatGrid extends StatelessWidget {
  final HomeStats stats;

  const HomeStatGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem(
        emoji: '🐝',
        label: 'Total Sarang',
        value: '${stats.hives.total}',
        accentColor: const Color(0xFFF5A623),
        accentBg: const Color(0xFFFFF3CD),
      ),
      _StatItem(
        emoji: '📅',
        label: 'Panen Bulan Ini',
        // Jumlah panen yang dilakukan, bukan jumlah sarang yang dipanen.
        value: '${stats.harvests.totalCurrentMonth}',
        trend: '${stats.hives.trendPercent > 0 ? '+' : ''}${stats.hives.trendPercent}% dari bulan lalu',
        trendUp: stats.hives.trendPercent >= 0,
        accentColor: const Color(0xFF4A90D9),
        accentBg: const Color(0xFFE3F2FD),
      ),
      _StatItem(
        emoji: '🍯',
        label: 'Total Panen',
        value: VolumeFormatter.format(
          stats.harvests.totalVolumeMlCurrentMonth,
        ),
        accentColor: const Color(0xFF34C759),
        accentBg: const Color(0xFFE8F8ED),
      ),
      _StatItem(
        emoji: '📈',
        label: 'Produktivitas',
        value: '${stats.productivity.percent}%',
        accentColor: const Color(0xFFAF52DE),
        accentBg: const Color(0xFFF3E5F5),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _StatCard(item: items[i]),
    );
  }
}

class _StatItem {
  final String emoji;
  final String label;
  final String value;
  final String? trend;
  final bool trendUp;
  final Color accentColor;
  final Color accentBg;

  const _StatItem({
    required this.emoji,
    required this.label,
    required this.value,
    this.trend,
    this.trendUp = true,
    required this.accentColor,
    required this.accentBg,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.accentBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.label,
                style: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.value,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (item.trend != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      item.trendUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 11,
                      color: item.trendUp
                          ? const Color(0xFF34C759)
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        item.trend!,
                        style: TextStyle(
                          fontSize: 10,
                          color: item.trendUp
                              ? const Color(0xFF34C759)
                              : Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
