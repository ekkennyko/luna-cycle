import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';
import 'package:luna/features/cycle/domain/repositories/i_cycle_repository.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
// If no period_end exists and the expected window has passed, closes the period automatically.
final isPeriodActiveProvider = FutureProvider<bool>((ref) async {
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return false;

  final end = await ref.watch(lastPeriodEndProvider.future);
  if (end != null && !end.date.isBefore(start.date)) return false;

  final periodLen = await ref.watch(userPeriodLengthProvider.future);
  final now = DateTime.now();
  final todayUtc = DateTime(now.year, now.month, now.day).toUtc();
  final overdueThreshold = start.date.add(Duration(days: periodLen));

  if (!todayUtc.isBefore(overdueThreshold)) {
    final expectedEnd = start.date.add(Duration(days: periodLen - 1));
    await ref.read(cycleNotifierProvider.notifier).endPeriod(expectedEnd);
    return false;
  }

  return true;
});

// Current day number within the active period (1-based). Null if no period is active.
final activePeriodDayProvider = FutureProvider<int?>((ref) async {
  final isActive = await ref.watch(isPeriodActiveProvider.future);
  if (!isActive) return null;
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return null;
  return DateTime.now().difference(start.date).inDays + 1;
});

// All period_start entries in chronological order.
final allPeriodStartsProvider = FutureProvider<List<CycleEntry>>((ref) {
  return ref.watch(cycleRepositoryProvider).getAllPeriodStarts();
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
// Returns the recorded length if the period is complete, the settings length if
// the window has passed without a period_end, or the number of days elapsed if
// the period is still ongoing. Null if no period has ever been started.
final periodLengthProvider = FutureProvider<int?>((ref) async {
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return null;

  final end = await ref.watch(lastPeriodEndProvider.future);
  if (end != null && !end.date.isBefore(start.date)) {
    return end.date.difference(start.date).inDays + 1;
  }

  final periodLen = await ref.watch(userPeriodLengthProvider.future);
  final now = DateTime.now();
  final todayUtc = DateTime(now.year, now.month, now.day).toUtc();
  final overdueThreshold = start.date.add(Duration(days: periodLen));

  if (!todayUtc.isBefore(overdueThreshold)) return periodLen;

  return todayUtc.difference(start.date).inDays + 1;
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
  return DateTime.now().difference(last.date).inDays + 1;
});

final currentPhaseProvider = FutureProvider<PhaseResult?>((ref) async {
  final lastStart = await ref.watch(lastPeriodStartProvider.future);
  if (lastStart == null) return null;

  final periodLen = await ref.watch(userPeriodLengthProvider.future);
  final cycleLen = await ref.watch(averageCycleLengthProvider.future);

  return CyclePhaseCalculator.calculate(
    periodStart: lastStart.date,
    periodLength: periodLen,
    cycleLength: cycleLen,
    today: DateTime.now().toUtc(),
  );
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
