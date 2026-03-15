import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luna/core/constants/pref_keys.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/shared/data/mood_data.dart';
import 'package:luna/shared/data/phase_data.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:luna/shared/widgets/dark_date_picker.dart';
import 'package:luna/shared/widgets/sheet_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _intensityLabels = ['Light', 'Medium', 'Heavy', 'Very Heavy'];
const _intensityColors = [
  AppColors.phaseFolicular,
  Color(0xFFE07A5F),
  AppColors.phaseMenstrual,
  Color(0xFFB5179E),
];

const _symptomNames = [
  'Cramps',
  'Bloating',
  'Headache',
  'Fatigue',
  'Breast tenderness',
  'Mood swings',
  'Spotting',
  'Nausea',
  'Back pain',
  'Acne',
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _ringController;
  late final AnimationController _pulseController;
  late final Animation<double> _floatAnim;
  late final Animation<double> _ringAnim;
  late final Animation<double> _pulseAnim;

  double _ringFrom = 0.0;
  double _ringTo = 0.0;

  DateTime? _bannerHiddenUntil;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _ringController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _floatAnim = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Cubic(0.34, 1.56, 0.64, 1),
      ),
    );
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final result = ref.read(currentPhaseProvider).asData?.value;
      if (result != null) {
        final target = _progressFromPhase(result);
        _animateRingTo(target);
      }
      final statusData = ref.read(periodStatusProvider).asData;
      if (statusData != null && statusData.value.$1 == PeriodStatus.late) {
        _pulseController.repeat(reverse: true);
      }
    });

    _loadBannerDismissState();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _ringController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadBannerDismissState() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(PrefKeys.lateBannerDismissedAt);
    if (ts != null && mounted) {
      setState(() {
        _bannerHiddenUntil = DateTime.fromMillisecondsSinceEpoch(ts).add(const Duration(hours: 24));
      });
    }
  }

  Future<void> _dismissBannerFor24Hours() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefKeys.lateBannerDismissedAt, DateTime.now().millisecondsSinceEpoch);
    if (mounted) {
      setState(() => _bannerHiddenUntil = DateTime.now().add(const Duration(hours: 24)));
    }
  }

  double _progressFromPhase(PhaseResult result) {
    return result.dayOfCycle > 0 ? (result.dayOfCycle / result.cycleLength).clamp(0.0, 1.0) : 0.0;
  }

  void _animateRingTo(double target) {
    _ringFrom = _ringFrom + (_ringTo - _ringFrom) * _ringAnim.value;
    _ringTo = target;
    _ringController.forward(from: 0);
  }

  void _openPeriodSheet({required bool isPeriodActive}) {
    if (isPeriodActive) {
      _openEndPeriodSheet();
    } else {
      _openStartPeriodSheet();
    }
  }

  void _openStartPeriodSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PeriodSheet(
        onStart: (intensity) async {
          final today = ref.read(effectiveTodayProvider);
          await ref.read(cycleNotifierProvider.notifier).logPeriodStart(today, flowIntensity: intensity);
        },
      ),
    );
  }

  void _openEndPeriodSheet() {
    final periodStart = ref.read(lastPeriodStartProvider).asData?.value?.date;
    final periodLength = ref.read(averagePeriodLengthProvider).asData?.value ?? 5;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EndPeriodSheet(
        effectiveToday: ref.read(effectiveTodayProvider),
        periodStart: periodStart,
        periodLength: periodLength,
        onEnd: (date) async {
          await ref.read(cycleNotifierProvider.notifier).endPeriod(date);
        },
      ),
    );
  }

  void _openMoodSheet(PhaseStyle phase) {
    final todayMood = ref.read(todayMoodProvider);
    final currentIdx = (todayMood != null && todayMood >= 1 && todayMood <= 5) ? todayMood - 1 : null;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoodSheet(
        phase: phase,
        currentMoodIdx: currentIdx,
        onSelect: (idx) async {
          final today = ref.read(effectiveTodayProvider);
          await ref.read(cycleNotifierProvider.notifier).saveMood(today, idx + 1);
        },
      ),
    );
  }

  Future<void> _openSymptomsSheet(PhaseStyle phase) async {
    final logs = ref.read(todaySymptomLogsProvider).asData?.value ?? [];
    final allSymptoms = await ref.read(activeSymptomsProvider.future);
    final nameById = {for (final s in allSymptoms) s.id: s.name};
    final currentNames = logs.map((l) => nameById[l.symptomId]).whereType<String>().toSet();

    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SymptomsSheet(
        phase: phase,
        initialSelected: currentNames,
        onSave: (selected) async {
          final repo = ref.read(symptomRepositoryProvider);
          final today = ref.read(effectiveTodayProvider);
          await repo.deleteLogsForDate(today);
          final syms = await ref.read(activeSymptomsProvider.future);
          final day = DateTime(today.year, today.month, today.day).toUtc();
          for (final sym in syms) {
            if (selected.contains(sym.name)) {
              await repo.saveLog(
                SymptomLogsCompanion.insert(date: day, symptomId: sym.id),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<PhaseResult?>>(currentPhaseProvider, (prev, next) {
      final result = next.asData?.value;
      if (result == null) return;
      _animateRingTo(_progressFromPhase(result));
    });

    ref.listen<AsyncValue<(PeriodStatus, int)>>(periodStatusProvider, (prev, next) {
      final status = next.asData?.value.$1;
      if (status == PeriodStatus.late) {
        if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.value = 1.0;
      }
    });

    final phaseResult = ref.watch(currentPhaseProvider).asData?.value;
    final (periodStatus, daysLate) = ref.watch(periodStatusProvider).asData?.value ?? (PeriodStatus.upcoming, 0);
    final isPeriodActive = periodStatus == PeriodStatus.active;
    final isLate = periodStatus == PeriodStatus.late;
    final cycleLen = ref.watch(cycleLengthProvider).asData?.value;
    final periodLen = ref.watch(averagePeriodLengthProvider).asData?.value;
    final avgLenNullable = ref.watch(avgCycleLengthNullableProvider).asData?.value;
    final todayMood = ref.watch(todayMoodProvider);
    final todayLogs = ref.watch(todaySymptomLogsProvider).asData?.value ?? const <SymptomLog>[];

    final displayDay = phaseResult?.dayOfCycle ?? 0;
    final phase = phaseResult != null ? PhaseStyle.forPhase(phaseResult.phase) : PhaseStyle.menstrual;

    final lastStart = ref.watch(lastPeriodStartProvider);
    final isEmpty = lastStart.asData != null && lastStart.asData!.value == null;

    final activePeriodDay = ref.watch(activePeriodDayProvider).asData?.value;
    final String periodLabel = switch (periodStatus) {
      PeriodStatus.active => activePeriodDay != null && periodLen != null
          ? 'Day $activePeriodDay of $periodLen'
          : activePeriodDay != null
              ? 'Day $activePeriodDay'
              : 'Period active',
      PeriodStatus.late => '$daysLate day${daysLate == 1 ? '' : 's'} late',
      PeriodStatus.expected => 'Period expected today',
      PeriodStatus.upcoming => phaseResult != null ? 'Period in ${phaseResult.daysUntilNextPeriod} day${phaseResult.daysUntilNextPeriod == 1 ? '' : 's'}' : '',
    };

    final now = DateTime.now();
    final isBannerVisible = isLate && (_bannerHiddenUntil == null || now.isAfter(_bannerHiddenUntil!));
    final isLongerThanUsual = isPeriodActive && activePeriodDay != null && periodLen != null && activePeriodDay > periodLen + 2;

    final moodIdx = (todayMood != null && todayMood >= 1 && todayMood <= 5) ? todayMood - 1 : null;
    final symptomsCount = todayLogs.length;

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.0,
                  colors: [
                    phase.color.withValues(alpha: 0.13),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(phase),
                  _buildRingSection(
                    phase: phase,
                    displayDay: displayDay,
                    isPeriodActive: isPeriodActive,
                    periodLabel: periodLabel,
                    isLate: isLate,
                    isEmpty: isEmpty,
                  ),
                  if (isBannerVisible) _buildLateBanner(daysLate),
                  if (isLongerThanUsual) _buildLongerThanUsualHint(),
                  const SizedBox(height: 16),
                  _buildQuickChips(
                    phase: phase,
                    isPeriodActive: isPeriodActive,
                    moodIdx: moodIdx,
                    symptomsCount: symptomsCount,
                    isEmpty: isEmpty,
                  ),
                  _buildInsightCard(phase),
                  _buildMiniStats(
                    cycleLen: cycleLen,
                    periodLen: periodLen,
                    avgLen: avgLenNullable,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(PhaseStyle phase) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Luna',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(
                'CYCLE TRACKER',
                style: TextStyle(
                  fontSize: 11,
                  color: phase.color,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (kDebugMode) ...[
                GestureDetector(
                  onTap: () {
                    ref.read(debugDayOffsetProvider.notifier).increment();
                  },
                  onLongPress: () {
                    ref.read(debugDayOffsetProvider.notifier).reset();
                  },
                  child: Consumer(
                    builder: (_, ref, __) {
                      final offset = ref.watch(debugDayOffsetProvider);
                      return Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.phaseLuteal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.phaseLuteal.withValues(alpha: 0.35),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          offset == 0 ? '+1d' : '+${offset}d',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.phaseLuteal,
                            letterSpacing: 0.5,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: const Center(
                  child: Text('🔔', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRingSection({
    required PhaseStyle phase,
    required int displayDay,
    required bool isPeriodActive,
    required String periodLabel,
    required bool isLate,
    required bool isEmpty,
  }) {
    return Column(
      children: [
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: Listenable.merge([_floatAnim, _ringAnim, _pulseAnim]),
          builder: (_, __) {
            final progress = _ringFrom + (_ringTo - _ringFrom) * _ringAnim.value;
            final ringColor = isLate
                ? Color.lerp(
                    phase.color.withValues(alpha: 0.3),
                    phase.color,
                    _pulseAnim.value,
                  )!
                : phase.color;
            return Transform.translate(
              offset: Offset(0, _floatAnim.value),
              child: SizedBox(
                width: 310,
                height: 310,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(310, 310),
                      painter: _CycleRingPainter(
                        progress: progress,
                        phaseColor: ringColor,
                        phaseBgColor: phase.bgColor,
                        isPeriodActive: isPeriodActive,
                      ),
                    ),

                    // Center labels
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEmpty) ...[
                          const Text('🩸', style: TextStyle(fontSize: 32)),
                          const SizedBox(height: 10),
                          Text(
                            'Tap to log',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'your first period',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ] else ...[
                          Text(
                            'DAY',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.5),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            displayDay > 0 ? '$displayDay' : '–',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 72,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              height: 1,
                              shadows: [
                                Shadow(
                                  color: phase.color.withValues(alpha: 0.53),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            phase.name,
                            style: TextStyle(
                              fontSize: 17,
                              color: phase.color,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (periodLabel.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                              child: Text(
                                periodLabel,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickChips({
    required PhaseStyle phase,
    required bool isPeriodActive,
    required int? moodIdx,
    required int symptomsCount,
    required bool isEmpty,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Row(
        children: [
          // Period / End Period
          Expanded(
            child: _QuickChip(
              icon: '🩸',
              label: isPeriodActive ? 'End Period' : (isEmpty ? 'Log period' : 'Period'),
              active: isPeriodActive || isEmpty,
              activeColor: isPeriodActive ? phase.color : AppColors.phaseMenstrual,
              onTap: () => _openPeriodSheet(isPeriodActive: isPeriodActive),
            ),
          ),
          const SizedBox(width: 10),
          // Mood
          Expanded(
            child: _QuickChip(
              icon: moodIdx != null ? moodEmojis[moodIdx] : '💭',
              label: moodIdx != null ? moodLabels[moodIdx] : 'Mood',
              onTap: () => _openMoodSheet(phase),
            ),
          ),
          const SizedBox(width: 10),
          // Symptoms
          Expanded(
            child: _QuickChip(
              icon: '✦',
              label: symptomsCount > 0 ? '$symptomsCount symptoms' : 'Symptoms',
              onTap: () => _openSymptomsSheet(phase),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(PhaseStyle phase) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      ),
      child: Container(
        key: ValueKey(phase.name),
        margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [phase.bgColor, Colors.white.withValues(alpha: 0.02)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: phase.color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: phase.color.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      '✦',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${phase.name.toUpperCase()} PHASE',
                  style: TextStyle(
                    fontSize: 11,
                    color: phase.color,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              phase.tip,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStats({
    required int? cycleLen,
    required int? periodLen,
    required int? avgLen,
  }) {
    // Cycle length: last completed cycle, or avg as fallback, or '--'
    final cycleLenStr = cycleLen != null ? '${cycleLen}d' : (avgLen != null ? '~${avgLen}d' : '--');
    final stats = [
      ('Cycle length', cycleLenStr),
      ('Period', periodLen != null ? '${periodLen}d' : '--'),
      ('Avg length', avgLen != null ? '${avgLen}d' : '--'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Row(
        children: List.generate(stats.length, (i) {
          final (label, value) = stats[i];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: i == 0 ? 0 : 5,
                right: i == stats.length - 1 ? 0 : 5,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      value,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.4),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLongerThanUsualHint() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            const Text('🌿', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your period is longer than usual.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLateBanner(int daysLate) {
    const color = AppColors.phaseMenstrual;
    final body =
        daysLate >= 7 ? 'Your period is $daysLate days late. This is normal — cycles vary.' : 'Did your period start? Log it to keep predictions accurate.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x30E05A7A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              body,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openStartPeriodSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: color.withValues(alpha: 0.40)),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Log period',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.phaseMenstrual,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _dismissBannerFor24Hours,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Not yet',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.activeColor,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.30),
                    color.withValues(alpha: 0.15),
                  ],
                )
              : null,
          color: active ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? color.withValues(alpha: 0.50) : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  const _CycleRingPainter({
    required this.progress,
    required this.phaseColor,
    required this.phaseBgColor,
    this.isPeriodActive = false,
  });

  final double progress;
  final Color phaseColor;
  final Color phaseBgColor;
  final bool isPeriodActive;

  static const _stroke = 19.0;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);
    final r = (size.width - _stroke * 2) / 2; // 136 at 310px

    // 1. Outer decorative dashed ring (r + 20)
    _drawDashedRing(canvas, center, r + 20, phaseColor.withValues(alpha: 0.15));

    // 2. Background track
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..color = const Color(0x08FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );

    // 3. Inner glow fill circle
    canvas.drawCircle(center, r - 40, Paint()..color = phaseBgColor);

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;
    final rect = Rect.fromCircle(center: center, radius: r);

    // 4a. Glow layer behind arc
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..color = phaseColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke + 8
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 4b. Progress arc with linear gradient
    final arcColor2 = isPeriodActive ? const Color(0xFFFF6B9D) : phaseColor.withValues(alpha: 0.7);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweepAngle,
      false,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [phaseColor, arcColor2],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );

    // 5. Dot indicator at end of arc
    final endAngle = 2 * math.pi * progress - math.pi / 2;
    final dotPos = Offset(cx + r * math.cos(endAngle), cy + r * math.sin(endAngle));

    // Dot glow
    canvas.drawCircle(
      dotPos,
      10,
      Paint()
        ..color = phaseColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Dot fill
    canvas.drawCircle(dotPos, 9, Paint()..color = phaseColor);
    // Dot white center
    canvas.drawCircle(dotPos, 4, Paint()..color = Colors.white);
  }

  void _drawDashedRing(
    Canvas canvas,
    Offset center,
    double radius,
    Color color,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final circumference = 2 * math.pi * radius;
    const dashLen = 4.0;
    const gapLen = 8.0;
    final count = (circumference / (dashLen + gapLen)).floor();
    final angleDash = (dashLen / circumference) * 2 * math.pi;
    final angleStep = ((dashLen + gapLen) / circumference) * 2 * math.pi;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    double angle = -math.pi / 2;
    for (int i = 0; i < count; i++) {
      canvas.drawArc(rect, angle, angleDash, false, paint);
      angle += angleStep;
    }
  }

  @override
  bool shouldRepaint(_CycleRingPainter old) =>
      old.progress != progress || old.phaseColor != phaseColor || old.phaseBgColor != phaseBgColor || old.isPeriodActive != isPeriodActive;
}



class _PeriodSheet extends StatefulWidget {
  const _PeriodSheet({required this.onStart});

  final Future<void> Function(int intensity) onStart;

  @override
  State<_PeriodSheet> createState() => _PeriodSheetState();
}

class _PeriodSheetState extends State<_PeriodSheet> {
  int _intensity = 1; // 0–3 index
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      title: 'Log Period',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flow intensity label
          Text(
            'FLOW INTENSITY',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Intensity buttons
          Row(
            children: List.generate(4, (i) {
              final selected = i == _intensity;
              final color = _intensityColors[i];
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0 : 4,
                    right: i == 3 ? 0 : 4,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _intensity = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          width: 1.5,
                          color: selected ? color : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '●' * (i + 1),
                            style: TextStyle(
                              color: selected ? color : Colors.white.withValues(alpha: 0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _intensityLabels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: selected ? color : Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          // Start period button
          GestureDetector(
            onTap: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    final nav = Navigator.of(context);
                    await widget.onStart(_intensity + 1); // 0-3 → 1-4
                    if (!mounted) return;
                    nav.pop();
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.phaseMenstrual, Color(0xFFB5179E)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.phaseMenstrual.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🩸 Start Period',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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

enum _PickMode { yesterday, today, custom }

class _EndPeriodSheet extends StatefulWidget {
  const _EndPeriodSheet({
    required this.effectiveToday,
    required this.onEnd,
    required this.periodStart,
    required this.periodLength,
  });

  final DateTime effectiveToday;
  final Future<void> Function(DateTime date) onEnd;
  final DateTime? periodStart;
  final int periodLength;

  @override
  State<_EndPeriodSheet> createState() => _EndPeriodSheetState();
}

class _EndPeriodSheetState extends State<_EndPeriodSheet> {
  bool _saving = false;
  late _PickMode _mode;
  DateTime? _customDate;

  @override
  void initState() {
    super.initState();
    _mode = DateTime.now().hour >= 12 ? _PickMode.today : _PickMode.yesterday;
  }

  bool get _showPickDate {
    final start = widget.periodStart;
    if (start == null) return false;
    final today = widget.effectiveToday;
    final startNorm = DateTime(start.year, start.month, start.day);
    return today.difference(startNorm).inDays >= widget.periodLength + 2;
  }

  Future<void> _pickCustomDate(DateTime today) async {
    final start = widget.periodStart;
    final firstDate = start != null ? DateTime(start.year, start.month, start.day) : today.subtract(const Duration(days: 90));
    final picked = await showDarkDatePicker(
      context,
      initial: _customDate ?? today.subtract(const Duration(days: 3)),
      firstDate: firstDate,
      lastDate: today,
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _mode = _PickMode.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = widget.effectiveToday;
    final yesterday = today.subtract(const Duration(days: 1));

    final selectedDate = switch (_mode) {
      _PickMode.yesterday => yesterday,
      _PickMode.today => today,
      _PickMode.custom => _customDate ?? today,
    };

    return SheetContainer(
      title: 'End Period?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'When did your period end?',
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _DateChip(
                label: 'Yesterday',
                dateLabel: DateFormat('MMM d').format(yesterday),
                selected: _mode == _PickMode.yesterday,
                onTap: () => setState(() => _mode = _PickMode.yesterday),
              ),
              const SizedBox(width: 10),
              _DateChip(
                label: 'Today',
                dateLabel: DateFormat('MMM d').format(today),
                selected: _mode == _PickMode.today,
                onTap: () => setState(() => _mode = _PickMode.today),
              ),
            ],
          ),
          if (_showPickDate) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                _DateChip(
                  label: 'Pick a date',
                  dateLabel: _customDate != null ? DateFormat('MMM d').format(_customDate!) : 'Tap to select',
                  selected: _mode == _PickMode.custom,
                  onTap: () => _pickCustomDate(today),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              // Cancel
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: const Center(
                      child: Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 14)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // End Period
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          final nav = Navigator.of(context);
                          await widget.onEnd(selectedDate);
                          if (!mounted) return;
                          nav.pop();
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.phaseLuteal, Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.phaseLuteal.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _saving ? 'Saving…' : '✓ End Period',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.dateLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String dateLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.phaseMenstrual;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              width: 1.5,
              color: selected ? accent.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1.5,
                        color: selected ? accent : Colors.white.withValues(alpha: 0.3),
                      ),
                      color: selected ? accent : Colors.transparent,
                    ),
                    child: selected ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? accent : Colors.white.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodSheet extends StatefulWidget {
  const _MoodSheet({
    required this.phase,
    required this.currentMoodIdx,
    required this.onSelect,
  });

  final PhaseStyle phase;
  final int? currentMoodIdx;
  final Future<void> Function(int idx) onSelect;

  @override
  State<_MoodSheet> createState() => _MoodSheetState();
}

class _MoodSheetState extends State<_MoodSheet> {
  late int? _mood;

  @override
  void initState() {
    super.initState();
    _mood = widget.currentMoodIdx;
  }

  @override
  Widget build(BuildContext context) {
    return SheetContainer(
      title: 'How are you feeling?',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (i) {
          final selected = _mood == i;
          return GestureDetector(
            onTap: () async {
              setState(() => _mood = i);
              final nav = Navigator.of(context);
              await widget.onSelect(i);
              await Future<void>.delayed(const Duration(milliseconds: 400));
              if (!mounted) return;
              nav.pop();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: const Cubic(0.34, 1.56, 0.64, 1),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  AnimatedScale(
                    scale: selected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      moodEmojis[i],
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    moodLabels[i].toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SymptomsSheet extends StatefulWidget {
  const _SymptomsSheet({
    required this.phase,
    required this.initialSelected,
    required this.onSave,
  });

  final PhaseStyle phase;
  final Set<String> initialSelected;
  final Future<void> Function(Set<String> selected) onSave;

  @override
  State<_SymptomsSheet> createState() => _SymptomsSheetState();
}

class _SymptomsSheetState extends State<_SymptomsSheet> {
  late final Set<String> _selected;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  @override
  Widget build(BuildContext context) {
    final phase = widget.phase;
    return SheetContainer(
      title: 'Log Symptoms',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _symptomNames.map((sym) {
              final active = _selected.contains(sym);
              return GestureDetector(
                onTap: () => setState(() {
                  if (active) {
                    _selected.remove(sym);
                  } else {
                    _selected.add(sym);
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: active ? phase.color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: active ? phase.color.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    sym,
                    style: TextStyle(
                      fontSize: 12,
                      color: active ? phase.color : Colors.white.withValues(alpha: 0.7),
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Save button
          GestureDetector(
            onTap: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    final nav = Navigator.of(context);
                    await widget.onSave(Set.from(_selected));
                    if (!mounted) return;
                    nav.pop();
                  },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [phase.color, phase.color.withValues(alpha: 0.8)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: phase.color.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _selected.isNotEmpty ? 'Save (${_selected.length} selected)' : 'Save',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
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
