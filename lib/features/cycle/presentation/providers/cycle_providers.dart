import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/features/cycle/domain/repositories/i_cycle_repository.dart';
import 'package:luna/shared/providers/core_providers.dart';

// Symptoms available for logging (non-mood categories).
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

/// True when the most recent period_start has no period_end after it.
final isPeriodActiveProvider = FutureProvider<bool>((ref) async {
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return false;
  final end = await ref.watch(lastPeriodEndProvider.future);
  if (end == null) return true;
  return end.date.isBefore(start.date);
});

/// Day number within the active period (1-based), or null if not active.
final activePeriodDayProvider = FutureProvider<int?>((ref) async {
  final isActive = await ref.watch(isPeriodActiveProvider.future);
  if (!isActive) return null;
  final start = await ref.watch(lastPeriodStartProvider.future);
  if (start == null) return null;
  return DateTime.now().difference(start.date).inDays + 1;
});

final allPeriodStartsProvider = FutureProvider<List<CycleEntry>>((ref) {
  return ref.watch(cycleRepositoryProvider).getAllPeriodStarts();
});

final averageCycleLengthProvider = FutureProvider<int>((ref) async {
  final starts = await ref.watch(allPeriodStartsProvider.future);
  if (starts.length < 2) return AppConstants.defaultCycleLength;
  int totalDays = 0;
  for (int i = 1; i < starts.length; i++) {
    totalDays += starts[i].date.difference(starts[i - 1].date).inDays;
  }
  return totalDays ~/ (starts.length - 1);
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
  return DateTime.now().difference(last.date).inDays + 1;
});

final currentCyclePhaseProvider = FutureProvider<String?>((ref) async {
  final day = await ref.watch(currentCycleDayProvider.future);
  if (day == null) return null;
  final avgLen = await ref.watch(averageCycleLengthProvider.future);
  const avgPeriod = AppConstants.defaultPeriodLength;

  if (day <= avgPeriod) return 'menstrual';
  final ovulationDay = (avgLen / 2).round();
  if (day < ovulationDay - 2) return 'follicular';
  if (day <= ovulationDay + 1) return 'ovulation';
  return 'luteal';
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

/// Mood value (1–5) saved for today, derived from the entries stream.
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

/// Symptom logs saved for today.
final todaySymptomLogsProvider = StreamProvider<List<SymptomLog>>((ref) {
  return ref.read(symptomRepositoryProvider).watchLogsForDate(DateTime.now());
});
