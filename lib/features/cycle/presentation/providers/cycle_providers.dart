import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luna/core/constants/app_constants.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/features/cycle/domain/repositories/i_cycle_repository.dart';
import 'package:luna/shared/providers/core_providers.dart';

final cycleEntriesProvider = StreamProvider<List<CycleEntry>>((ref) {
  return ref.watch(cycleRepositoryProvider).watchAllEntries();
});

final lastPeriodStartProvider = FutureProvider<CycleEntry?>((ref) {
  return ref.watch(cycleRepositoryProvider).getLastPeriodStart();
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

  Future<void> logPeriodStart(DateTime date) async {
    final day = DateTime(date.year, date.month, date.day).toUtc();
    await _repo.saveEntry(
      CycleEntriesCompanion.insert(
        date: day,
        type: 'period_start',
        flowIntensity: const Value(2),
      ),
    );
  }

  Future<void> updateFlowIntensity(DateTime date, int intensity) async {
    final existing = await _repo.getEntryForDate(date);
    if (existing == null) return;
    await _repo.saveEntry(
      existing.toCompanion(true).copyWith(flowIntensity: Value(intensity)),
    );
  }

  Future<void> deleteEntry(int id) => _repo.deleteEntry(id);
}

final cycleNotifierProvider =
    AsyncNotifierProvider<CycleNotifier, void>(CycleNotifier.new);
