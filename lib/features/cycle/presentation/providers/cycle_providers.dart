import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';
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
  return prefs.getInt('user_period_length') ?? AppConstants.defaultPeriodLength;
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

// Average cycle length across all recorded cycles. Falls back to the app default
// when fewer than two period starts exist.
final averageCycleLengthProvider = FutureProvider<int>((ref) async {
  final starts = await ref.watch(allPeriodStartsProvider.future);
  if (starts.length < 2) return AppConstants.defaultCycleLength;
  int totalDays = 0;
  for (int i = 1; i < starts.length; i++) {
    totalDays += starts[i].date.difference(starts[i - 1].date).inDays;
  }
  return totalDays ~/ (starts.length - 1);
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

// Average cycle length across all completed cycles. Null when fewer than two cycles exist.
final avgCycleLengthNullableProvider = FutureProvider<int?>((ref) async {
  final starts = await ref.watch(allPeriodStartsProvider.future);
  if (starts.length < 2) return null;
  int total = 0;
  for (int i = 1; i < starts.length; i++) {
    total += starts[i].date.difference(starts[i - 1].date).inDays;
  }
  return total ~/ (starts.length - 1);
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
              type: const Value('period_start'),
              flowIntensity: Value(flowIntensity),
            ),
      );
    } else {
      await _repo.saveEntry(
        CycleEntriesCompanion.insert(
          date: day,
          type: 'period_start',
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
      await _repo.updateEntryType(existing.id, 'period_end');
    } else {
      await _repo.saveEntry(
        CycleEntriesCompanion.insert(date: day, type: 'period_end'),
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
  final now = DateTime.now();
  final todayUtc = DateTime(now.year, now.month, now.day).toUtc();
  final nextUtc = todayUtc.add(const Duration(days: 1));
  for (final e in entries) {
    if (!e.date.isBefore(todayUtc) && e.date.isBefore(nextUtc)) {
      return e.mood;
    }
  }
  return null;
});

final todaySymptomLogsProvider = StreamProvider<List<SymptomLog>>((ref) {
  return ref.read(symptomRepositoryProvider).watchLogsForDate(DateTime.now());
});
