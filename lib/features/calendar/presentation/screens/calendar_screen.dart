import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/theme/app_colors.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:luna/shared/widgets/common_sheet.dart';

const _bg = AppColors.appBackground;
const _accent = AppColors.phaseMenstrual;

const _phaseColors = {
  CyclePhase.menstrual: AppColors.phaseMenstrual,
  CyclePhase.follicular: AppColors.phaseFolicular,
  CyclePhase.ovulation: AppColors.phaseOvulation,
  CyclePhase.luteal: AppColors.phaseLuteal,
};

const _phaseBgs = {
  CyclePhase.menstrual: AppColors.phaseMenstrualBg,
  CyclePhase.follicular: AppColors.phaseFolicularBg,
  CyclePhase.ovulation: AppColors.phaseOvulationBg,
  CyclePhase.luteal: AppColors.phaseLutealBg,
};

const _moodEmojis = ['😔', '😐', '🙂', '😊', '🤩'];
const _moodLabels = ['Low', 'Okay', 'Good', 'Happy', 'Amazing'];

/// All period ranges: [{start, end}] derived from DB entries.
final periodRangesProvider = FutureProvider<List<({DateTime start, DateTime end})>>((ref) async {
  ref.watch(cycleEntriesProvider);
  final entries = await ref.read(cycleRepositoryProvider).getAllEntries();
  final starts = entries.where((e) => e.type == 'period_start').toList()..sort((a, b) => a.date.compareTo(b.date));
  final ends = entries.where((e) => e.type == 'period_end').toList()..sort((a, b) => a.date.compareTo(b.date));

  final ranges = <({DateTime start, DateTime end})>[];
  for (final s in starts) {
    DateTime? endDate;
    for (final e in ends) {
      if (!e.date.isBefore(s.date)) {
        endDate = e.date;
        break;
      }
    }
    if (endDate != null) {
      ranges.add((start: s.date, end: endDate));
    }
  }
  return ranges;
});

final predictedPeriodsProvider = FutureProvider<List<({DateTime start, DateTime end})>>(
  (ref) async {
    final lastStart = await ref.watch(lastPeriodStartProvider.future);
    if (lastStart == null) return [];
    final predictedCycleLen = await ref.watch(averageCycleLengthProvider.future);
    final periodLen = await ref.watch(averagePeriodLengthProvider.future);
    final now = DateTime.now();
    final endOfCalendar = DateTime(now.year, now.month + 14, 0);

    final predictions = <({DateTime start, DateTime end})>[];
    var nextStart = lastStart.date.add(Duration(days: predictedCycleLen));
    while (nextStart.isBefore(endOfCalendar)) {
      predictions.add((
        start: nextStart,
        end: nextStart.add(Duration(days: periodLen - 1)),
      ));
      nextStart = nextStart.add(Duration(days: predictedCycleLen));
    }
    return predictions;
  },
);

// All mood entries as Map of dateKey to int.
final allMoodsProvider = Provider<Map<String, int>>((ref) {
  final entries = ref.watch(cycleEntriesProvider).when(
        data: (v) => v,
        loading: () => <CycleEntry>[],
        error: (_, __) => <CycleEntry>[],
      );
  final map = <String, int>{};
  for (final e in entries) {
    if (e.mood != null) {
      map[_dateKey(e.date)] = e.mood!;
    }
  }
  return map;
});

// All symptom logs as Map of dateKey to symptom name list.
final allSymptomLogsProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  ref.watch(cycleEntriesProvider);
  final from = DateTime.now().subtract(const Duration(days: 365));
  final to = DateTime.now().add(const Duration(days: 1));
  final logs = await ref.read(symptomRepositoryProvider).getLogsBetween(from, to);
  final symptoms = await ref.read(symptomRepositoryProvider).getAllSymptoms();
  final nameMap = {for (final s in symptoms) s.id: s.name};
  final map = <String, List<String>>{};
  for (final log in logs) {
    final key = _dateKey(log.date);
    map.putIfAbsent(key, () => []);
    final name = nameMap[log.symptomId];
    if (name != null) map[key]!.add(name);
  }
  return map;
});

String _dateKey(DateTime d) {
  final local = d.toLocal();
  return '${local.year}-${local.month}-${local.day}';
}

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  final _scrollController = ScrollController();
  DateTime? _selectedDay;
  bool _hasScrolled = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ranges = ref.watch(periodRangesProvider).asData?.value ?? [];
    final predicted = ref.watch(predictedPeriodsProvider).asData?.value ?? [];
    final moods = ref.watch(allMoodsProvider);
    final symptomLogs = ref.watch(allSymptomLogsProvider).asData?.value ?? {};
    final allStarts = ref.watch(allPeriodStartsProvider).asData?.value ?? [];
    final periodLen = ref.watch(userPeriodLengthProvider).asData?.value ?? 5;
    final cycleLen = ref.watch(averageCycleLengthProvider).asData?.value ?? 28;
    final today = ref.watch(effectiveTodayProvider);

    final now = DateTime.now();
    final DateTime startMonth;
    if (allStarts.isNotEmpty) {
      final earliest = allStarts.first.date.toLocal();
      startMonth = DateTime(earliest.year, earliest.month);
    } else {
      startMonth = DateTime(now.year, now.month);
    }
    final endMonth = DateTime(now.year, now.month + 13);

    final months = <({int year, int month})>[];
    var cursor = startMonth;
    while (!cursor.isAfter(endMonth)) {
      months.add((year: cursor.year, month: cursor.month));
      cursor = DateTime(cursor.year, cursor.month + 1);
    }

    final currentMonthIndex = months.indexWhere(
      (m) => m.year == now.year && m.month == now.month,
    );

    if (!_hasScrolled && currentMonthIndex >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hasScrolled && _scrollController.hasClients) {
          const monthHeight = 332.0;
          final offset = currentMonthIndex * monthHeight;
          _scrollController.jumpTo(
            offset.clamp(0, _scrollController.position.maxScrollExtent),
          );
          _hasScrolled = true;
        }
      });
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          // Ambient glow
          Positioned(
            top: -60,
            left: 0,
            right: 0,
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.8,
                  colors: [Color(0x18E05A7A), Colors.transparent],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calendar',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const Text(
                        'CYCLE HISTORY',
                        style: TextStyle(
                          fontSize: 11,
                          color: _accent,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Legend
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      _LegendItem(color: _accent, label: 'Period'),
                      _LegendItem(
                        color: Color(0x40E05A7A),
                        label: 'Predicted',
                        dashed: true,
                      ),
                      _LegendItem(color: Color(0x1AF4A261), label: 'Follicular'),
                      _LegendItem(color: Color(0x1AA8DADC), label: 'Ovulation'),
                      _LegendItem(color: Color(0x1A9B72CF), label: 'Luteal'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Scrollable months
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                    itemCount: months.length,
                    itemBuilder: (context, i) {
                      final m = months[i];
                      return _MonthGrid(
                        year: m.year,
                        month: m.month,
                        today: today,
                        ranges: ranges,
                        predicted: predicted,
                        allStarts: allStarts,
                        moods: moods,
                        symptomLogs: symptomLogs,
                        periodLen: periodLen,
                        cycleLen: cycleLen,
                        onDayTap: (d) => setState(() => _selectedDay = d),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Bottom sheet overlay
          if (_selectedDay != null) ...[
            GestureDetector(
              onTap: () => setState(() => _selectedDay = null),
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _DayDetailSheet(
                date: _selectedDay!,
                ranges: ranges,
                predicted: predicted,
                allStarts: allStarts,
                moods: moods,
                symptomLogs: symptomLogs,
                periodLen: periodLen,
                cycleLen: cycleLen,
                onClose: () => setState(() => _selectedDay = null),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.year,
    required this.month,
    required this.today,
    required this.ranges,
    required this.predicted,
    required this.allStarts,
    required this.moods,
    required this.symptomLogs,
    required this.periodLen,
    required this.cycleLen,
    required this.onDayTap,
  });

  final int year;
  final int month;
  final DateTime today;
  final List<({DateTime start, DateTime end})> ranges;
  final List<({DateTime start, DateTime end})> predicted;
  final List<CycleEntry> allStarts;
  final Map<String, int> moods;
  final Map<String, List<String>> symptomLogs;
  final int periodLen;
  final int cycleLen;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startDow = firstDay.weekday % 7; // Su=0

    final days = <DateTime?>[];
    for (int i = 0; i < startDow; i++) {
      days.add(null);
    }
    for (int d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(year, month, d));
    }

    final monthName = DateFormat('MMMM yyyy').format(firstDay);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month header
          Text(
            monthName,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Weekday headers
          Row(
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.25),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Day cells
          ...List.generate(
            (days.length / 7).ceil(),
            (row) {
              return Row(
                children: List.generate(7, (col) {
                  final idx = row * 7 + col;
                  final date = idx < days.length ? days[idx] : null;
                  if (date == null) return const Expanded(child: SizedBox(height: 38));
                  return Expanded(
                    child: _DayCell(
                      date: date,
                      today: today,
                      ranges: ranges,
                      predicted: predicted,
                      allStarts: allStarts,
                      moods: moods,
                      symptomLogs: symptomLogs,
                      periodLen: periodLen,
                      cycleLen: cycleLen,
                      onTap: () => onDayTap(date),
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.today,
    required this.ranges,
    required this.predicted,
    required this.allStarts,
    required this.moods,
    required this.symptomLogs,
    required this.periodLen,
    required this.cycleLen,
    required this.onTap,
  });

  final DateTime date;
  final DateTime today;
  final List<({DateTime start, DateTime end})> ranges;
  final List<({DateTime start, DateTime end})> predicted;
  final List<CycleEntry> allStarts;
  final Map<String, int> moods;
  final Map<String, List<String>> symptomLogs;
  final int periodLen;
  final int cycleLen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final todayNorm = DateTime(today.year, today.month, today.day);
    final dateNorm = DateTime(date.year, date.month, date.day);
    final isToday = dateNorm == todayNorm;
    final isFuture = dateNorm.isAfter(todayNorm);

    final periodPos = _getPeriodPosition(dateNorm, ranges);
    final isPeriod = periodPos != null;
    final predPos = !isPeriod ? _getPredictedPosition(dateNorm, predicted) : null;
    final isPredicted = predPos != null;
    final phase = _getPhaseForDay(dateNorm, allStarts, cycleLen, periodLen, ranges);
    final key = _dateKey(dateNorm);
    final hasMood = moods.containsKey(key);
    final hasSymptoms = symptomLogs.containsKey(key);
    final hasData = hasMood || hasSymptoms;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 38,
        child: Stack(
          children: [
            // Phase background
            if (phase != null && !isPeriod)
              Positioned(
                top: 2,
                bottom: 2,
                left: 1,
                right: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _phaseBgs[phase],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),

            // Period background
            if (isPeriod)
              Positioned(
                top: 2,
                bottom: 2,
                left: periodPos.isFirst ? _cellInset(context) : 0,
                right: periodPos.isLast ? _cellInset(context) : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: _rangeBorderRadius(periodPos),
                  ),
                ),
              ),

            // Predicted period background
            if (isPredicted)
              Positioned(
                top: 2,
                bottom: 2,
                left: predPos.isFirst ? _cellInset(context) : 0,
                right: predPos.isLast ? _cellInset(context) : 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0x40E05A7A),
                    border: Border.all(
                      color: const Color(0x99E05A7A),
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                    borderRadius: _rangeBorderRadius(predPos),
                  ),
                ),
              ),

            // Today ring
            if (isToday)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

            // Day number + dot
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                      color: isPeriod
                          ? Colors.white
                          : isToday
                              ? Colors.white
                              : isFuture
                                  ? Colors.white.withValues(alpha: 0.35)
                                  : Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  if (hasData)
                    Container(
                      width: 3,
                      height: 3,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPeriod ? Colors.white.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.4),
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

  double _cellInset(BuildContext context) => 4;

  BorderRadius _rangeBorderRadius(_RangePos pos) {
    if (pos.isSingle) return BorderRadius.circular(50);
    if (pos.isFirst) return const BorderRadius.horizontal(left: Radius.circular(50));
    if (pos.isLast) return const BorderRadius.horizontal(right: Radius.circular(50));
    return BorderRadius.zero;
  }
}

class _RangePos {
  const _RangePos({required this.isFirst, required this.isLast});
  final bool isFirst;
  final bool isLast;
  bool get isSingle => isFirst && isLast;
}

_RangePos? _getPeriodPosition(
  DateTime date,
  List<({DateTime start, DateTime end})> ranges,
) {
  for (final r in ranges) {
    final s = DateTime(r.start.toLocal().year, r.start.toLocal().month, r.start.toLocal().day);
    final e = DateTime(r.end.toLocal().year, r.end.toLocal().month, r.end.toLocal().day);
    if (!date.isBefore(s) && !date.isAfter(e)) {
      return _RangePos(isFirst: date == s, isLast: date == e);
    }
  }
  return null;
}

_RangePos? _getPredictedPosition(
  DateTime date,
  List<({DateTime start, DateTime end})> predictions,
) {
  for (final pred in predictions) {
    final s = DateTime(pred.start.toLocal().year, pred.start.toLocal().month, pred.start.toLocal().day);
    final e = DateTime(pred.end.toLocal().year, pred.end.toLocal().month, pred.end.toLocal().day);
    if (!date.isBefore(s) && !date.isAfter(e)) {
      return _RangePos(isFirst: date == s, isLast: date == e);
    }
  }
  return null;
}

CyclePhase? _getPhaseForDay(
  DateTime date,
  List<CycleEntry> allStarts,
  int cycleLength,
  int periodLength,
  List<({DateTime start, DateTime end})> ranges,
) {
  if (allStarts.isEmpty) return null;

  CycleEntry? lastStart;
  for (final s in allStarts) {
    final sNorm = DateTime(s.date.toLocal().year, s.date.toLocal().month, s.date.toLocal().day);
    if (!sNorm.isAfter(date)) {
      lastStart = s;
    } else {
      break;
    }
  }
  if (lastStart == null) return null;

  final sLocal = lastStart.date.toLocal();
  final start = DateTime(sLocal.year, sLocal.month, sLocal.day);
  final dayOfCycle = date.difference(start).inDays + 1;
  if (dayOfCycle < 1 || dayOfCycle > cycleLength) return null;

  int effectivePeriodLen = periodLength;
  for (final r in ranges) {
    final rs = DateTime(r.start.toLocal().year, r.start.toLocal().month, r.start.toLocal().day);
    if (rs == start) {
      final re = DateTime(r.end.toLocal().year, r.end.toLocal().month, r.end.toLocal().day);
      effectivePeriodLen = re.difference(start).inDays + 1;
      break;
    }
  }

  final ovDay = cycleLength - 14;
  if (dayOfCycle <= effectivePeriodLen) return CyclePhase.menstrual;
  if (dayOfCycle < ovDay - 2) return CyclePhase.follicular;
  if (dayOfCycle <= ovDay + 2) return CyclePhase.ovulation;
  return CyclePhase.luteal;
}

class _DayDetailSheet extends StatelessWidget {
  const _DayDetailSheet({
    required this.date,
    required this.ranges,
    required this.predicted,
    required this.allStarts,
    required this.moods,
    required this.symptomLogs,
    required this.periodLen,
    required this.cycleLen,
    required this.onClose,
  });

  final DateTime date;
  final List<({DateTime start, DateTime end})> ranges;
  final List<({DateTime start, DateTime end})> predicted;
  final List<CycleEntry> allStarts;
  final Map<String, int> moods;
  final Map<String, List<String>> symptomLogs;
  final int periodLen;
  final int cycleLen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final dateNorm = DateTime(date.year, date.month, date.day);
    final isPeriod = _getPeriodPosition(dateNorm, ranges) != null;
    final isPredicted = !isPeriod && _getPredictedPosition(dateNorm, predicted) != null;
    final phase = _getPhaseForDay(dateNorm, allStarts, cycleLen, periodLen, ranges);
    final key = _dateKey(dateNorm);
    final mood = moods[key];
    final symptoms = symptomLogs[key];
    final hasAnyData = isPeriod || mood != null || symptoms != null;

    return AppSheet(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DragHandle(),
          const SizedBox(height: 20),

          // Date header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM d').format(date),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (phase != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${CyclePhaseCalculator.phaseName(phase)} phase',
                        style: TextStyle(
                          fontSize: 12,
                          color: _phaseColors[phase],
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  if (isPredicted)
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        'Predicted period',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0x99E05A7A),
                        ),
                      ),
                    ),
                ],
              ),
              if (isPeriod)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x33E05A7A),
                    border: Border.all(color: const Color(0x66E05A7A)),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    '🩸 Period',
                    style: TextStyle(
                      fontSize: 12,
                      color: _accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Empty state
          if (!hasAnyData && !isPredicted)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Nothing logged this day',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),

          // Mood card
          if (mood != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkCardBg,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Row(
                children: [
                  Text(_moodEmojis[mood - 1], style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MOOD',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkHint,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _moodLabels[mood - 1],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Symptoms card
          if (symptoms != null && symptoms.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkCardBg,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.darkCardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SYMPTOMS',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.darkHint,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: symptoms
                        .map(
                          (s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0x26E05A7A),
                              border: Border.all(color: const Color(0x4DE05A7A)),
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 12, color: _accent),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(3),
            border: dashed ? Border.all(color: const Color(0x99E05A7A)) : null,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.35),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
