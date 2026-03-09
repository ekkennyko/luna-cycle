import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/shared/providers/core_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ringController;
  late final AnimationController _pulseController;
  late final Animation<double> _ringAnimation;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _ringAnimation = CurvedAnimation(
      parent: _ringController,
      curve: Curves.easeOut,
    );
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _showStartPeriodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _StartPeriodSheet(),
    );
  }

  void _showMoodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _MoodBottomSheet(),
    );
  }

  void _showSymptomsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SymptomsBottomSheet(),
    );
  }

  void _showEndPeriodSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EndPeriodSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<int?>>(currentCycleDayProvider, (prev, next) {
      final hadData = prev?.hasValue == true && prev?.value != null;
      final hasData = next.hasValue && next.value != null;
      if (!hadData && hasData) _ringController.forward(from: 0);
    });

    final cycleDay = ref.watch(currentCycleDayProvider).when(
          data: (v) => v,
          loading: () => null,
          error: (_, __) => null,
        );
    final phase = ref.watch(currentCyclePhaseProvider).when(
          data: (v) => v,
          loading: () => null,
          error: (_, __) => null,
        );
    final avgLen = ref.watch(averageCycleLengthProvider).when(
          data: (v) => v,
          loading: () => 28,
          error: (_, __) => 28,
        );
    final nextPeriod = ref.watch(nextPeriodDateProvider).when(
          data: (v) => v,
          loading: () => null,
          error: (_, __) => null,
        );
    final isPeriodActive = ref.watch(isPeriodActiveProvider).when(
          data: (v) => v,
          loading: () => false,
          error: (_, __) => false,
        );
    final periodDay = ref.watch(activePeriodDayProvider).when(
          data: (v) => v,
          loading: () => null,
          error: (_, __) => null,
        );

    final hasData = cycleDay != null;

    final Color ringColor;
    final double progress;
    final String centerDay;
    final String centerSub;

    if (isPeriodActive && periodDay != null) {
      ringColor = AppColors.phaseMenstrual;
      progress = 1.0;
      centerDay = 'Day $periodDay';
      centerSub = 'of period';
    } else {
      ringColor = _phaseColor(phase);
      final day = cycleDay ?? 0;
      progress = hasData ? (day / avgLen).clamp(0.0, 1.0).toDouble() : 0.0;
      centerDay = hasData ? 'Day $day' : '';
      centerSub = _phaseName(phase);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              'Luna',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.35),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: isPeriodActive ? _showEndPeriodSheet : _showStartPeriodSheet,
              child: hasData
                  ? AnimatedBuilder(
                      animation: _ringAnimation,
                      builder: (_, __) => _CycleRing(
                        progress: progress * _ringAnimation.value,
                        color: ringColor,
                        centerDay: centerDay,
                        centerSub: centerSub,
                        subtitle: isPeriodActive
                            ? null
                            : _ringSubtitle(nextPeriod),
                      ),
                    )
                  : AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (_, __) => Transform.scale(
                        scale: _pulseAnimation.value,
                        child: const _CycleRingEmpty(),
                      ),
                    ),
            ),
            const SizedBox(height: 32),
            _QuickLogRow(
              isPeriodActive: isPeriodActive,
              onPeriodTap: _showStartPeriodSheet,
              onEndPeriodTap: _showEndPeriodSheet,
              onMoodTap: _showMoodSheet,
              onSymptomsTap: _showSymptomsSheet,
            ),
            const SizedBox(height: 12),
            const _TodayDataRow(),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _PhaseInfoCard(phase: phase, hasData: hasData),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  static Color _phaseColor(String? phase) => switch (phase) {
        'menstrual' => AppColors.phaseMenstrual,
        'follicular' => AppColors.phaseFolicular,
        'ovulation' => AppColors.phaseOvulation,
        'luteal' => AppColors.phaseLuteal,
        _ => AppColors.primary,
      };

  static String _phaseName(String? phase) => switch (phase) {
        'menstrual' => 'Menstrual',
        'follicular' => 'Follicular',
        'ovulation' => 'Ovulation',
        'luteal' => 'Luteal',
        _ => '',
      };

  static String? _ringSubtitle(DateTime? nextPeriod) {
    if (nextPeriod == null) return null;
    final diff = nextPeriod.difference(DateTime.now()).inDays;
    if (diff > 0) return 'Period in $diff days';
    if (diff == 0) return 'Period expected today';
    return 'Period started ${-diff} days ago';
  }
}

// ── Cycle ring (with data) ────────────────────────────────────────────────────

class _CycleRing extends StatelessWidget {
  const _CycleRing({
    required this.progress,
    required this.color,
    required this.centerDay,
    required this.centerSub,
    this.subtitle,
  });

  final double progress;
  final Color color;
  final String centerDay;
  final String centerSub;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter: _RingPainter(progress: progress, color: color),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (centerDay.isNotEmpty)
                Text(
                  centerDay,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              if (centerSub.isNotEmpty)
                Text(
                  centerSub,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ── Cycle ring (empty state) ──────────────────────────────────────────────────

class _CycleRingEmpty extends StatelessWidget {
  const _CycleRingEmpty();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: CustomPaint(
        painter:
            _DashedRingPainter(color: AppColors.primary.withValues(alpha: 0.3)),
        child: Center(
          child: Text(
            'Tap to begin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.35),
                ),
          ),
        ),
      ),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  const _DashedRingPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const dashCount = 24;
    const dashLen = 0.18;
    const gapLen = 0.08;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < dashCount; i++) {
      final start = -math.pi / 2 + i * (dashLen + gapLen);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashLen,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}

// ── Quick log row ─────────────────────────────────────────────────────────────

class _QuickLogRow extends StatelessWidget {
  const _QuickLogRow({
    required this.isPeriodActive,
    required this.onPeriodTap,
    required this.onEndPeriodTap,
    required this.onMoodTap,
    required this.onSymptomsTap,
  });

  final bool isPeriodActive;
  final VoidCallback onPeriodTap;
  final VoidCallback onEndPeriodTap;
  final VoidCallback onMoodTap;
  final VoidCallback onSymptomsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isPeriodActive)
          _QuickChip(
            icon: Icons.stop_circle_outlined,
            label: 'End period',
            accent: true,
            onTap: onEndPeriodTap,
          )
        else
          _QuickChip(
            icon: Icons.water_drop_outlined,
            label: 'Period',
            onTap: onPeriodTap,
          ),
        const SizedBox(width: 12),
        _QuickChip(icon: Icons.mood_outlined, label: 'Mood', onTap: onMoodTap),
        const SizedBox(width: 12),
        _QuickChip(icon: Icons.favorite_border, label: 'Symptoms', onTap: onSymptomsTap),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    this.accent = false,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppColors.phaseMenstrual : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: accent
              ? AppColors.phaseMenstrual.withValues(alpha: 0.12)
              : Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
          border: accent
              ? Border.all(color: AppColors.phaseMenstrual.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Phase info card ───────────────────────────────────────────────────────────

class _PhaseInfoCard extends StatelessWidget {
  const _PhaseInfoCard({required this.phase, required this.hasData});

  final String? phase;
  final bool hasData;

  static const _hints = {
    'menstrual': 'Rest and warmth help during menstruation',
    'follicular': 'Good time for new projects — energy is rising',
    'ovulation': 'Energy tends to peak around ovulation',
    'luteal': 'Slow down and listen to your body',
  };

  @override
  Widget build(BuildContext context) {
    final text = hasData
        ? (_hints[phase] ?? '')
        : 'Log your first day to start tracking';

    if (text.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── Start period bottom sheet ─────────────────────────────────────────────────

class _StartPeriodSheet extends ConsumerStatefulWidget {
  const _StartPeriodSheet();

  @override
  ConsumerState<_StartPeriodSheet> createState() => _StartPeriodSheetState();
}

class _StartPeriodSheetState extends ConsumerState<_StartPeriodSheet> {
  int _flowIntensity = 2;
  int? _mood;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('MMMM d').format(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(formatted, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          const _Label('Flow intensity'),
          const SizedBox(height: 8),
          _FlowRow(
            value: _flowIntensity,
            onChanged: (v) => setState(() => _flowIntensity = v),
          ),
          const SizedBox(height: 20),
          const _Label('Mood'),
          const SizedBox(height: 8),
          _MoodRow(
            value: _mood,
            onChanged: (v) => setState(() => _mood = _mood == v ? null : v),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Text('Start period'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final today = DateTime.now();
    final notifier = ref.read(cycleNotifierProvider.notifier);
    await notifier.logPeriodStart(today);
    if (_flowIntensity != 2) {
      await notifier.updateFlowIntensity(today, _flowIntensity);
    }
    if (mounted) Navigator.of(context).pop();
  }
}

// ── Mood bottom sheet ─────────────────────────────────────────────────────────

class _MoodBottomSheet extends ConsumerStatefulWidget {
  const _MoodBottomSheet();

  @override
  ConsumerState<_MoodBottomSheet> createState() => _MoodBottomSheetState();
}

class _MoodBottomSheetState extends ConsumerState<_MoodBottomSheet> {
  int? _mood;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            DateFormat('MMMM d').format(DateTime.now()),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          const _Label('Mood'),
          const SizedBox(height: 12),
          _MoodRow(
            value: _mood,
            onChanged: (v) => setState(() => _mood = _mood == v ? null : v),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_mood == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    await ref
        .read(cycleNotifierProvider.notifier)
        .saveMood(DateTime.now(), _mood!);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Mood saved')));
    }
  }
}

// ── Symptoms bottom sheet ─────────────────────────────────────────────────────

class _SymptomsBottomSheet extends ConsumerStatefulWidget {
  const _SymptomsBottomSheet();

  @override
  ConsumerState<_SymptomsBottomSheet> createState() =>
      _SymptomsBottomSheetState();
}

class _SymptomsBottomSheetState extends ConsumerState<_SymptomsBottomSheet> {
  final _selectedIds = <int>{};
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final symptomsAsync = ref.watch(activeSymptomsProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            DateFormat('MMMM d').format(DateTime.now()),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          const _Label('Symptoms'),
          const SizedBox(height: 12),
          symptomsAsync.when(
            data: (symptoms) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: symptoms.map((s) {
                final selected = _selectedIds.contains(s.id);
                return GestureDetector(
                  onTap: () => setState(() => selected
                      ? _selectedIds.remove(s.id)
                      : _selectedIds.add(s.id)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            selected ? AppColors.primary : AppColors.outline,
                      ),
                    ),
                    child: Text(
                      s.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedIds.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day).toUtc();
    final repo = ref.read(symptomRepositoryProvider);
    await repo.deleteLogsForDate(today);
    for (final id in _selectedIds) {
      await repo.saveLog(SymptomLogsCompanion.insert(date: day, symptomId: id));
    }
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Symptoms saved')));
    }
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.labelLarge);
  }
}

class _FlowRow extends StatelessWidget {
  const _FlowRow({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = ['', 'Spotting', 'Light', 'Heavy', 'Very\nheavy'];
  static const _icons = [
    null,
    Icons.water_drop_outlined,
    Icons.water_drop,
    Icons.opacity,
    Icons.waves,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (i) {
        final v = i + 1;
        final selected = v == value;
        return GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.outline,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _icons[v],
                  size: 20,
                  color:
                      selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  _labels[v],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _MoodRow extends StatelessWidget {
  const _MoodRow({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int> onChanged;

  static const _moods = ['😢', '😕', '😐', '🙂', '😊'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (i) {
        final v = i + 1;
        final selected = v == value;
        return GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.primary : Colors.transparent,
              ),
            ),
            child: Text(
              _moods[i],
              style: TextStyle(fontSize: selected ? 28 : 24),
            ),
          ),
        );
      }),
    );
  }
}

// ── Today's saved data ────────────────────────────────────────────────────────

class _TodayDataRow extends ConsumerWidget {
  const _TodayDataRow();

  static const _moodEmoji = ['😢', '😕', '😐', '🙂', '😊'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mood = ref.watch(todayMoodProvider);
    final logs = ref.watch(todaySymptomLogsProvider).when(
          data: (v) => v,
          loading: () => <SymptomLog>[],
          error: (_, __) => <SymptomLog>[],
        );
    final symptoms = ref.watch(activeSymptomsProvider).when(
          data: (v) => v,
          loading: () => <Symptom>[],
          error: (_, __) => <Symptom>[],
        );

    if (mood == null && logs.isEmpty) return const SizedBox.shrink();

    final nameById = {for (final s in symptoms) s.id: s.name};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          if (mood != null && mood >= 1 && mood <= 5)
            _DataChip(label: _moodEmoji[mood - 1]),
          for (final log in logs)
            if (nameById.containsKey(log.symptomId))
              _DataChip(label: nameById[log.symptomId]!),
        ],
      ),
    );
  }
}

class _DataChip extends StatelessWidget {
  const _DataChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── End period bottom sheet ───────────────────────────────────────────────────

class _EndPeriodSheet extends ConsumerWidget {
  const _EndPeriodSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat('MMMM d').format(DateTime.now()),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 20),
          Icon(
            Icons.stop_circle_outlined,
            size: 48,
            color: AppColors.phaseMenstrual.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 16),
          Text(
            'End period today?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'This will mark today as the last day of your period.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.phaseMenstrual,
            ),
            onPressed: () async {
              await ref
                  .read(cycleNotifierProvider.notifier)
                  .endPeriod(DateTime.now());
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('End period today'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
