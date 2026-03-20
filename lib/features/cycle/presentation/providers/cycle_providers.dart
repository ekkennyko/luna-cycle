import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/extensions/date_time_ext.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/core/notifications/notification_service.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';
import 'package:luna/features/cycle/domain/cycle_predictor.dart';
import 'package:luna/features/cycle/domain/repositories/i_cycle_repository.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:luna/core/constants/prefs_keys.dart';
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

final activeSymptomsProvider = FutureProvider<List<Symptom>>((ref) async {
  final all = await ref.read(symptomRepositoryProvider).getActiveSymptoms();
  return all.where((s) => s.category != 'mood').toList();
});

final cycleEntriesProvider = StreamProvider<List<CycleEntry>>((ref) {
  return ref.watch(cycleRepositoryProvider).watchAllEntries();
});

final lastPeriodStartProvider = FutureProvider<CycleEntry?>((ref) async {
  ref.watch(cycleEntriesProvider);
  return ref.read(cycleRepositoryProvider).getLastPeriodStart();
});

final lastPeriodEndProvider = FutureProvider<CycleEntry?>((ref) async {
  ref.watch(cycleEntriesProvider);
  return ref.read(cycleRepositoryProvider).getLastPeriodEnd();
});

final userPeriodLengthProvider = FutureProvider<int>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt(PrefsKeys.userPeriodLength) ?? AppConstants.defaultPeriodLength;
});

final isPeriodActiveProvider = FutureProvider<bool>((ref) async {
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return false;

  final end = await ref.watch(lastPeriodEndProvider.future);
  if (end != null && !end.date.isBefore(start.date)) return false;

  return true;
});

final activePeriodDayProvider = FutureProvider<int?>((ref) async {
  final isActive = await ref.watch(isPeriodActiveProvider.future);
  if (!isActive) return null;
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return null;
  return ref.watch(effectiveTodayProvider).difference(start.date).inDays + 1;
});

final allPeriodStartsProvider = FutureProvider<List<CycleEntry>>((ref) async {
  ref.watch(cycleEntriesProvider);
  return ref.read(cycleRepositoryProvider).getAllPeriodStarts();
});

final cycleLengthsProvider = FutureProvider<List<int>>((ref) async {
  final starts = await ref.watch(allPeriodStartsProvider.future);
  if (starts.length < 2) return [];
  return [
    for (int i = 1; i < starts.length; i++) starts[i].date.difference(starts[i - 1].date).inDays,
  ];
});

List<({DateTime start, DateTime end})> matchPeriodRanges(List<CycleEntry> entries) {
  final starts = entries.where((e) => e.type == 'period_start').toList()..sort((a, b) => a.date.compareTo(b.date));
  final ends = entries.where((e) => e.type == 'period_end').toList()..sort((a, b) => a.date.compareTo(b.date));

  final ranges = <({DateTime start, DateTime end})>[];
  for (final s in starts) {
    for (final e in ends) {
      if (!e.date.isBefore(s.date)) {
        ranges.add((start: s.date, end: e.date));
        break;
      }
    }
  }
  return ranges;
}

final completedPeriodLengthsProvider = FutureProvider<List<int>>((ref) async {
  ref.watch(cycleEntriesProvider);
  final entries = await ref.read(cycleRepositoryProvider).getAllEntries();
  return matchPeriodRanges(entries).map((r) => r.end.difference(r.start).inDays + 1).toList();
});

final averagePeriodLengthProvider = FutureProvider<int>((ref) async {
  final lengths = await ref.watch(completedPeriodLengthsProvider.future);
  if (lengths.isEmpty) return await ref.watch(userPeriodLengthProvider.future);
  return CyclePredictor.predictNextCycleLength(lengths);
});

final averageCycleLengthProvider = FutureProvider<int>((ref) async {
  final lengths = await ref.watch(cycleLengthsProvider.future);
  if (lengths.isEmpty) return AppConstants.defaultCycleLength;
  return CyclePredictor.predictNextCycleLength(lengths);
});

final cycleLengthProvider = FutureProvider<int?>((ref) async {
  final starts = await ref.watch(allPeriodStartsProvider.future);
  if (starts.length < 2) return null;
  final last = starts[starts.length - 1];
  final prev = starts[starts.length - 2];
  return last.date.difference(prev.date).inDays;
});

final periodLengthProvider = FutureProvider<int?>((ref) async {
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return null;

  final end = await ref.watch(lastPeriodEndProvider.future);
  if (end != null && !end.date.isBefore(start.date)) {
    return end.date.difference(start.date).inDays + 1;
  }

  return await ref.watch(userPeriodLengthProvider.future);
});

final avgCycleLengthNullableProvider = FutureProvider<int?>((ref) async {
  final lengths = await ref.watch(cycleLengthsProvider.future);
  if (lengths.isEmpty) return null;
  return CyclePredictor.predictNextCycleLength(lengths);
});

final nextPeriodDateProvider = FutureProvider<DateTime?>((ref) async {
  final last = await ref.watch(lastPeriodStartProvider.future);
  if (last == null) return null;
  final avgLen = await ref.watch(averageCycleLengthProvider.future);
  return last.date.add(Duration(days: avgLen));
});

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
  return result.phase.name;
});

class CycleNotifier extends AsyncNotifier<void> {
  ICycleRepository get _repo => ref.read(cycleRepositoryProvider);

  @override
  Future<void> build() async {}

  Future<void> logPeriodStart(DateTime date, {int flowIntensity = 2}) async {
    final day = date.dateOnly;
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
    await _rescheduleNotifications();
  }

  Future<void> saveMood(DateTime date, int mood) => _repo.saveMood(date, mood);

  Future<void> endPeriod(DateTime date) async {
    final day = date.dateOnly;
    final existing = await _repo.getEntryForDate(date);
    if (existing != null) {
      await _repo.updateEntryType(existing.id, 'period_end');
    } else {
      await _repo.saveEntry(
        CycleEntriesCompanion.insert(date: day, type: 'period_end'),
      );
    }
    await _rescheduleNotifications();
  }

  Future<void> _rescheduleNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final periodEnabled = prefs.getBool(PrefsKeys.notificationsPeriodEnabled) ?? true;
      final periodDays = prefs.getInt(PrefsKeys.notificationsPeriodDays) ?? 2;
      final fertileEnabled = prefs.getBool(PrefsKeys.notificationsFertileEnabled) ?? true;
      final lateEnabled = prefs.getBool(PrefsKeys.notificationsLateEnabled) ?? true;

      final lastStart = await _repo.getLastPeriodStart();
      if (lastStart == null) return;

      final allStarts = await _repo.getAllPeriodStarts();
      final lengths = allStarts.length < 2 ? <int>[] : [for (int i = 1; i < allStarts.length; i++) allStarts[i].date.difference(allStarts[i - 1].date).inDays];
      final avgCycleLen = lengths.isEmpty ? AppConstants.defaultCycleLength : CyclePredictor.predictNextCycleLength(lengths);

      final nextPeriod = lastStart.date.add(Duration(days: avgCycleLen));

      final lastEnd = await _repo.getLastPeriodEnd();
      final periodEnd = (lastEnd != null && !lastEnd.date.isBefore(lastStart.date)) ? lastEnd.date : null;

      final userPeriodLen = prefs.getInt(PrefsKeys.userPeriodLength) ?? AppConstants.defaultPeriodLength;
      final today = ref.read(effectiveTodayProvider);
      final phase = CyclePhaseCalculator.calculate(
        periodStart: lastStart.date,
        periodLength: userPeriodLen,
        cycleLength: avgCycleLen,
        today: today,
        periodEnd: periodEnd,
      );

      final daysLate = (periodEnd == null && phase.daysUntilNextPeriod < 0) ? -phase.daysUntilNextPeriod : 0;

      await NotificationService.rescheduleAll(
        nextPeriodDate: nextPeriod,
        fertileWindowStart: phase.fertileWindow.start,
        periodReminderEnabled: periodEnabled,
        periodReminderDays: periodDays,
        fertileWindowEnabled: fertileEnabled,
        latePeriodEnabled: lateEnabled,
        daysLate: daysLate,
        appLockEnabled: false,
      );
    } catch (_) {
      // Notification scheduling is best-effort
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
  final todayUtc = today.dateOnly;
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
