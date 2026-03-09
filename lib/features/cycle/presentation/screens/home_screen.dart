import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phaseAsync = ref.watch(currentCyclePhaseProvider);
    final cycleDayAsync = ref.watch(currentCycleDayProvider);
    final nextPeriodAsync = ref.watch(nextPeriodDateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Luna')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _PhaseCard(phaseAsync: phaseAsync, cycleDayAsync: cycleDayAsync),
            const SizedBox(height: 16),
            _NextPeriodCard(nextPeriodAsync: nextPeriodAsync),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final today = DateTime.now().toIso8601String().substring(0, 10);
          context.push('/log?date=$today');
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Log today'),
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({required this.phaseAsync, required this.cycleDayAsync});

  final AsyncValue<String?> phaseAsync;
  final AsyncValue<int?> cycleDayAsync;

  static const _phaseNames = {
    'menstrual': 'Menstrual phase',
    'follicular': 'Follicular phase',
    'ovulation': 'Ovulation',
    'luteal': 'Luteal phase',
  };

  static const _phaseColors = {
    'menstrual': AppColors.phaseMenstrual,
    'follicular': AppColors.phaseFolicular,
    'ovulation': AppColors.phaseOvulation,
    'luteal': AppColors.phaseLuteal,
  };

  @override
  Widget build(BuildContext context) {
    return phaseAsync.when(
      data: (phase) {
        final name = _phaseNames[phase] ?? 'No data';
        final color = _phaseColors[phase] ?? AppColors.primary;
        final day = cycleDayAsync.when(
          data: (v) => v,
          loading: () => null,
          error: (_, __) => null,
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (day != null)
                Text(
                  'Day $day',
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 4),
              Text(
                name,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: color),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _NextPeriodCard extends StatelessWidget {
  const _NextPeriodCard({required this.nextPeriodAsync});

  final AsyncValue<DateTime?> nextPeriodAsync;

  @override
  Widget build(BuildContext context) {
    return nextPeriodAsync.when(
      data: (date) {
        if (date == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Log your first period day to start tracking',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }
        final diff = date.difference(DateTime.now()).inDays;
        final formatted = DateFormat('MMMM d').format(date);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next period',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      '$formatted · in $diff days',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
