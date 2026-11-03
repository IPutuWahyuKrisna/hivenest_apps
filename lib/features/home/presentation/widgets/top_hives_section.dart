import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/home_stats.dart';

class TopHivesSection extends StatelessWidget {
  final List<TopHive> topHives;

  const TopHivesSection({super.key, required this.topHives});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Sarang Panen',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...topHives.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TopHiveCard(hive: e.value, rank: e.key + 1),
              ),
            ),
      ],
    );
  }
}

class _TopHiveCard extends StatelessWidget {
  final TopHive hive;
  final int rank;

  const _TopHiveCard({required this.hive, required this.rank});

  @override
  Widget build(BuildContext context) {
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
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hive.hiveName,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Total Panen',
                  style: TextStyle(color: AppColors.textGray, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusGreenBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${hive.totalWeightKg} kg',
              style: const TextStyle(
                color: AppColors.statusGreenText,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
