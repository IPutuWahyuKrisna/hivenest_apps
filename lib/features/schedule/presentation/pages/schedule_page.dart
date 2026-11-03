import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../domain/entities/harvest_schedule.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScheduleBloc>()
        ..add(const ScheduleLoadRequested()),
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatefulWidget {
  const _ScheduleView();

  @override
  State<_ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<_ScheduleView> {
  int _selectedTab = 0;

  static const _tabs = [
    (label: 'Semua', value: null),
    (label: 'Due', value: 'due'),
    (label: 'Upcoming', value: 'upcoming'),
  ];

  void _onTabSelected(int index) {
    if (_selectedTab == index) return;
    setState(() => _selectedTab = index);
    context.read<ScheduleBloc>().add(
          ScheduleLoadRequested(tab: _tabs[index].value),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await context.push<bool>('/add-hive');
          if (added == true && context.mounted) {
            context.read<ScheduleBloc>().add(
              ScheduleLoadRequested(tab: _tabs[_selectedTab].value),
            );
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<ScheduleBloc, ScheduleState>(
              builder: (context, state) {
                if (state is ScheduleLoading || state is ScheduleInitial) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                if (state is ScheduleFailure) {
                  return _ErrorView(
                    message: state.message,
                    onRetry: () => context.read<ScheduleBloc>().add(
                          ScheduleLoadRequested(
                              tab: _tabs[_selectedTab].value),
                        ),
                  );
                }
                if (state is ScheduleLoaded) {
                  if (state.schedules.isEmpty) {
                    return _EmptyView(tab: _tabs[_selectedTab].label);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.schedules.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () async {
                          final refreshed = await ctx.push<bool>(
                            '/hive/${state.schedules[i].hiveId}',
                          );
                          if (refreshed == true && ctx.mounted) {
                            ctx.read<ScheduleBloc>().add(
                              ScheduleLoadRequested(tab: _tabs[_selectedTab].value),
                            );
                          }
                        },
                        child: _ScheduleCard(schedule: state.schedules[i]),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jadwal Panen',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Kelola jadwal panen sarang lebah',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              _tabs.length,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => _onTabSelected(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedTab == i
                          ? Colors.white
                          : Colors.transparent,
                      border: Border.all(
                        color: _selectedTab == i
                            ? Colors.white
                            : Colors.white54,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _tabs[i].label,
                      style: TextStyle(
                        color: _selectedTab == i
                            ? AppColors.textDark
                            : Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final HarvestSchedule schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('🐝', style: TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.hive.name,
                        style: const TextStyle(
                          color: AppColors.textDark,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: AppColors.textGray),
                          const SizedBox(width: 2),
                          Text(
                            schedule.hive.block,
                            style: const TextStyle(
                                color: AppColors.textGray, fontSize: 12),
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
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    schedule.hive.honeyType,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.fieldBg),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    icon: Icons.calendar_month,
                    label: 'Tanggal',
                    value: schedule.formattedDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _InfoChip(
                    icon: Icons.access_alarm,
                    label: 'Waktu',
                    value: schedule.formattedTime,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 14, right: 14, bottom: 12),
            child: Row(
              children: [
                const Icon(Icons.bug_report_outlined,
                    size: 13, color: AppColors.textGray),
                const SizedBox(width: 4),
                Text(
                  schedule.hive.beeSpecies,
                  style: const TextStyle(
                      color: AppColors.textGray, fontSize: 12),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    schedule.notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                        color: AppColors.textGray, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.fieldBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textGray),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    color: AppColors.textGray, fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String tab;
  const _EmptyView({required this.tab});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🍯', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Belum ada jadwal $tab',
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: AppColors.textGray),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.textGray, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
