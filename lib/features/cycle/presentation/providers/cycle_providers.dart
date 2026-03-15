import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/constants/entry_types.dart';
import 'package:luna/core/constants/pref_keys.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';
import 'package:luna/features/cycle/domain/cycle_predictor.dart';
import 'package:luna/features/cycle/domain/repositories/i_cycle_repository.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Debug time offset in days (0 = today). Only used in debug builds.
class _DebugDayOffset extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
  void reset() => state = 0;
}

final debugDayOffsetProvider = NotifierProvider<_DebugDayOffset, int>(_DebugDayOffset.new);

// The effective "today" for all cycle calculations — respects debug offset.
final effectiveTodayProvider = Provider<DateTime>((ref) {
  final offset = ref.watch(debugDayOffsetProvider);
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).add(Duration(days: offset));
});

// All active symptoms except mood entries.
final activeSymptomsProvider = FutureProvider<List<Symptom>>((ref) async {
  final all = await ref.read(symptomRepositoryProvider).getActiveSymptoms();
  return all.where((s) => s.category != 'mood').toList();
});

final cycleEntriesProvider = StreamProvider<List<CycleEntry>>((ref) {
  return ref.watch(cycleRepositoryProvider).watchAllEntries();
});

// The most recent period_start entry, or null if none exists.
final lastPeriodStartProvider = FutureProvider<CycleEntry?>((ref) async {
  ref.watch(cycleEntriesProvider);
  return ref.read(cycleRepositoryProvider).getLastPeriodStart();
});

// The most recent period_end entry, or null if none exists.
final lastPeriodEndProvider = FutureProvider<CycleEntry?>((ref) async {
  ref.watch(cycleEntriesProvider);
  return ref.read(cycleRepositoryProvider).getLastPeriodEnd();
});

// Period length saved during onboarding or settings. Falls back to the app default.
final userPeriodLengthProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(PrefKeys.userPeriodLength) ?? AppConstants.defaultPeriodLength;
});

// Whether the current period is still ongoing.
// True only when a period_start exists with no subsequent period_end.
final isPeriodActiveProvider = FutureProvider<bool>((ref) async {
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return false;

  final end = await ref.watch(lastPeriodEndProvider.future);
  if (end != null && !end.date.isBefore(start.date)) return false;

  return true;
});

// Current day number within the active period (1-based). Null if no period is active.
final activePeriodDayProvider = FutureProvider<int?>((ref) async {
  final isActive = await ref.watch(isPeriodActiveProvider.future);
  if (!isActive) return null;
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return null;
  return ref.watch(effectiveTodayProvider).difference(start.date).inDays + 1;
});

// All period_start entries in chronological order.
final allPeriodStartsProvider = FutureProvider<List<CycleEntry>>((ref) async {
  ref.watch(cycleEntriesProvider);
  return ref.read(cycleRepositoryProvider).getAllPeriodStarts();
});

// All completed cycle lengths in chronological order (oldest → newest).
final cycleLengthsProvider = FutureProvider<List<int>>((ref) async {
  final starts = await ref.watch(allPeriodStartsProvider.future);
  if (starts.length < 2) return [];
  return [
    for (int i = 1; i < starts.length; i++) starts[i].date.difference(starts[i - 1].date).inDays,
  ];
});

// All completed period lengths in chronological order (oldest → newest).
final completedPeriodLengthsProvider = FutureProvider<List<int>>((ref) async {
  ref.watch(cycleEntriesProvider);
  final entries = await ref.read(cycleRepositoryProvider).getAllEntries();
  final starts = entries.where((e) => e.type == EntryTypes.periodStart).toList()..sort((a, b) => a.date.compareTo(b.date));
  final ends = entries.where((e) => e.type == EntryTypes.periodEnd).toList()..sort((a, b) => a.date.compareTo(b.date));

  final lengths = <int>[];
  for (final s in starts) {
    for (final e in ends) {
      if (!e.date.isBefore(s.date)) {
        lengths.add(e.date.difference(s.date).inDays + 1);
        break;
      }
    }
  }
  return lengths;
});

// Predicted period length using weighted average.
// Falls back to userPeriodLengthProvider when no completed periods exist.
final averagePeriodLengthProvider = FutureProvider<int>((ref) async {
  final lengths = await ref.watch(completedPeriodLengthsProvider.future);
  if (lengths.isEmpty) return await ref.watch(userPeriodLengthProvider.future);
  return CyclePredictor.predictNextCycleLength(lengths);
});

// Predicted cycle length using weighted average with outlier trimming.
// Falls back to the app default when no completed cycles exist.
final averageCycleLengthProvider = FutureProvider<int>((ref) async {
  final lengths = await ref.watch(cycleLengthsProvider.future);
  if (lengths.isEmpty) return AppConstants.defaultCycleLength;
  return CyclePredictor.predictNextCycleLength(lengths);
});

// Duration of the last completed cycle in days. Null when fewer than two cycles exist.
final cycleLengthProvider = FutureProvider<int?>((ref) async {
  final starts = await ref.watch(allPeriodStartsProvider.future);
  if (starts.length < 2) return null;
  final last = starts[starts.length - 1];
  final prev = starts[starts.length - 2];
  return last.date.difference(prev.date).inDays;
});

// Duration of the current or most recent period in days.
// Returns the recorded actual length if the period has a period_end,
// otherwise returns the expected length from settings.
final periodLengthProvider = FutureProvider<int?>((ref) async {
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return null;

  final end = await ref.watch(lastPeriodEndProvider.future);
  if (end != null && !end.date.isBefore(start.date)) {
    return end.date.difference(start.date).inDays + 1;
  }

  return await ref.watch(userPeriodLengthProvider.future);
});

// Predicted cycle length, or null when fewer than two cycles exist.
final avgCycleLengthNullableProvider = FutureProvider<int?>((ref) async {
  final lengths = await ref.watch(cycleLengthsProvider.future);
  if (lengths.isEmpty) return null;
  return CyclePredictor.predictNextCycleLength(lengths);
});

// Predicted start date of the next period based on the average cycle length.
final nextPeriodDateProvider = FutureProvider<DateTime?>((ref) async {
  final last = await ref.watch(lastPeriodStartProvider.future);
  if (last == null) return null;
  final avgLen = await ref.watch(averageCycleLengthProvider.future);
  return last.date.add(Duration(days: avgLen));
});

// Current day number within the cycle (1-based, counting from the last period start).
final currentCycleDayProvider = FutureProvider<int?>((ref) async {
  final last = await ref.watch(lastPeriodStartProvider.future);
  if (last == null) return null;
  return ref.watch(effectiveTodayProvider).difference(last.date).inDays + 1;
});

enum PeriodStatus { active, expected, late, upcoming }

final currentPhaseProvider = FutureProvider<PhaseResult?>((ref) async {
  final lastStart = await ref.watch(lastPeriodStartProvider.future);
  if (lastStart == null) return null;

  final lastEnd = await ref.watch(lastPeriodEndProvider.future);
  final periodEnd = (lastEnd != null && !lastEnd.date.isBefore(lastStart.date)) ? lastEnd.date : null;

  final periodLen = await ref.watch(userPeriodLengthProvider.future);
  final cycleLen = await ref.watch(averageCycleLengthProvider.future);

  return CyclePhaseCalculator.calculate(
    periodStart: lastStart.date,
    periodLength: periodLen,
    cycleLength: cycleLen,
    today: ref.watch(effectiveTodayProvider),
    periodEnd: periodEnd,
  );
});

// (PeriodStatus, daysLate) — daysLate > 0 only when status is late.
final periodStatusProvider = FutureProvider<(PeriodStatus, int)>((ref) async {
  final isPeriodActive = await ref.watch(isPeriodActiveProvider.future);
  if (isPeriodActive) return (PeriodStatus.active, 0);

  final phaseResult = await ref.watch(currentPhaseProvider.future);
  if (phaseResult == null) return (PeriodStatus.upcoming, 0);

  final d = phaseResult.daysUntilNextPeriod;
  if (d < 0) return (PeriodStatus.late, -d);
  if (d == 0) return (PeriodStatus.expected, 0);
  return (PeriodStatus.upcoming, 0);
});

// Phase name string for consumers that need a plain string (e.g. nav bar color).
final currentCyclePhaseProvider = FutureProvider<String?>((ref) async {
  final result = await ref.watch(currentPhaseProvider.future);
  if (result == null) return null;
  return CyclePhaseCalculator.phaseName(result.phase).toLowerCase();
});

class CycleNotifier extends AsyncNotifier<void> {
  ICycleRepository get _repo => ref.read(cycleRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> logPeriodStart(DateTime date, {int flowIntensity = 2}) async {
    final day = DateTime(date.year, date.month, date.day).toUtc();
    final existing = await _repo.getEntryForDate(date);
    if (existing != null) {
      await _repo.saveEntry(
        existing.toCompanion(true).copyWith(
              type: const Value(EntryTypes.periodStart),
              flowIntensity: Value(flowIntensity),
            ),
      );
    } else {
      await _repo.saveEntry(
        CycleEntriesCompanion.insert(
          date: day,
          type: EntryTypes.periodStart,
          flowIntensity: Value(flowIntensity),
        ),
      );
    }
  }

  Future<void> saveMood(DateTime date, int mood) => _repo.saveMood(date, mood);

  Future<void> endPeriod(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day).toUtc();
    final existing = await _repo.getEntryForDate(date);
    if (existing != null) {
      await _repo.updateEntryType(existing.id, EntryTypes.periodEnd);
    } else {
      await _repo.saveEntry(
        CycleEntriesCompanion.insert(date: day, type: EntryTypes.periodEnd),
      );
    }
  }

  Future<void> deleteEntry(int id) => _repo.deleteEntry(id);
}

final cycleNotifierProvider = AsyncNotifierProvider<CycleNotifier, void>(CycleNotifier.new);

// Mood value (1-5) logged for today. Null if no mood has been recorded today.
final todayMoodProvider = Provider<int?>((ref) {
  final entries = ref.watch(cycleEntriesProvider).when(
        data: (v) => v,
        loading: () => <CycleEntry>[],
        error: (_, __) => <CycleEntry>[],
      );
  final today = ref.watch(effectiveTodayProvider);
  final todayUtc = DateTime(today.year, today.month, today.day).toUtc();
  final nextUtc = todayUtc.add(const Duration(days: 1));
  for (final e in entries) {
    if (!e.date.isBefore(todayUtc) && e.date.isBefore(nextUtc)) {
      return e.mood;
    }
  }
  return null;
});

final todaySymptomLogsProvider = StreamProvider<List<SymptomLog>>((ref) {
  final today = ref.watch(effectiveTodayProvider);
  return ref.read(symptomRepositoryProvider).watchLogsForDate(today);
});

String dateKey(DateTime d) {
  final local = d.toLocal();
  return '${local.year}-${local.month}-${local.day}';
}

/// All period ranges: [{start, end}] derived from DB entries.
final periodRangesProvider = FutureProvider<List<({DateTime start, DateTime end})>>((ref) async {
  ref.watch(cycleEntriesProvider);
  final entries = await ref.read(cycleRepositoryProvider).getAllEntries();
  final starts = entries.where((e) => e.type == EntryTypes.periodStart).toList()..sort((a, b) => a.date.compareTo(b.date));
  final ends = entries.where((e) => e.type == EntryTypes.periodEnd).toList()..sort((a, b) => a.date.compareTo(b.date));

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

/// All mood entries as Map of dateKey to int.
final allMoodsProvider = Provider<Map<String, int>>((ref) {
  final entries = ref.watch(cycleEntriesProvider).when(
        data: (v) => v,
        loading: () => <CycleEntry>[],
        error: (_, __) => <CycleEntry>[],
      );
  final map = <String, int>{};
  for (final e in entries) {
    if (e.mood != null) {
      map[dateKey(e.date)] = e.mood!;
    }
  }
  return map;
});

/// All symptom logs as Map of dateKey to symptom name list.
final allSymptomLogsProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  ref.watch(cycleEntriesProvider);
  final from = DateTime.now().subtract(const Duration(days: 365));
  final to = DateTime.now().add(const Duration(days: 1));
  final logs = await ref.read(symptomRepositoryProvider).getLogsBetween(from, to);
  final symptoms = await ref.read(symptomRepositoryProvider).getAllSymptoms();
  final nameMap = {for (final s in symptoms) s.id: s.name};
  final map = <String, List<String>>{};
  for (final log in logs) {
    final key = dateKey(log.date);
    map.putIfAbsent(key, () => []);
    final name = nameMap[log.symptomId];
    if (name != null) map[key]!.add(name);
  }
  return map;
});
