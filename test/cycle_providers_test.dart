import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luna/core/constants/entry_types.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/core/extensions/date_time_ext.dart';
import 'package:luna/features/cycle/domain/cycle_phase_calculator.dart';
import 'package:luna/features/cycle/presentation/providers/cycle_providers.dart';
import 'package:luna/shared/providers/core_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  ProviderContainer container(DateTime today) {
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        effectiveTodayProvider.overrideWithValue(DateTime(today.year, today.month, today.day)),
      ],
    );
    addTearDown(c.dispose);
    // Screens keep the entries stream alive; without a listener Riverpod pauses it.
    c.listen(cycleEntriesProvider, (_, __) {});
    return c;
  }

  Future<void> start(int month, int day) =>
      db.into(db.cycleEntries).insert(CycleEntriesCompanion.insert(date: DateTime(2026, month, day).dateOnly, type: EntryTypes.periodStart));

  Future<void> end(int month, int day) =>
      db.into(db.cycleEntries).insert(CycleEntriesCompanion.insert(date: DateTime(2026, month, day).dateOnly, type: EntryTypes.periodEnd));

  Future<void> mood(int month, int day, int value) => db.into(db.cycleEntries).insert(
        CycleEntriesCompanion.insert(date: DateTime(2026, month, day).dateOnly, type: EntryTypes.moodLog, mood: Value(value)),
      );

  group('period status', () {
    test('no data', () async {
      final c = container(DateTime(2026, 3, 10));
      expect(await c.read(periodStatusProvider.future), (PeriodStatus.upcoming, 0));
      expect(await c.read(currentCycleDayProvider.future), isNull);
      expect(await c.read(averageCycleLengthProvider.future), 28);
    });

    test('active while the period has no end', () async {
      await start(3, 1);
      final c = container(DateTime(2026, 3, 3));
      expect(await c.read(periodStatusProvider.future), (PeriodStatus.active, 0));
      expect(await c.read(activePeriodDayProvider.future), 3);
    });

    test('upcoming after the period ended', () async {
      await start(3, 1);
      await end(3, 5);
      final c = container(DateTime(2026, 3, 10));
      expect(await c.read(periodStatusProvider.future), (PeriodStatus.upcoming, 0));
      expect(await c.read(isPeriodActiveProvider.future), isFalse);
      expect(await c.read(currentCycleDayProvider.future), 10);
      expect(await c.read(currentCyclePhaseProvider.future), CyclePhase.follicular);
    });

    test('expected on the predicted day', () async {
      await start(3, 1);
      await end(3, 5);
      final c = container(DateTime(2026, 3, 29));
      expect((await c.read(nextPeriodDateProvider.future))!.isAtSameMomentAs(DateTime(2026, 3, 29)), isTrue);
      expect(await c.read(periodStatusProvider.future), (PeriodStatus.expected, 0));
    });

    test('late after the predicted day', () async {
      await start(3, 1);
      await end(3, 5);
      final c = container(DateTime(2026, 4, 2));
      expect(await c.read(periodStatusProvider.future), (PeriodStatus.late, 4));
    });

    test('end logged before the start does not close the period', () async {
      await end(2, 28);
      await start(3, 1);
      final c = container(DateTime(2026, 3, 2));
      expect(await c.read(isPeriodActiveProvider.future), isTrue);
    });
  });

  group('cycle and period lengths', () {
    test('cycle lengths come from consecutive starts', () async {
      await start(1, 1);
      await start(1, 29);
      await start(2, 28);
      final c = container(DateTime(2026, 3, 1));
      expect(await c.read(cycleLengthsProvider.future), [28, 30]);
      expect(await c.read(cycleLengthProvider.future), 30);
      expect(await c.read(averageCycleLengthProvider.future), 29);
    });

    test('period length includes both start and end day', () async {
      await start(3, 1);
      await end(3, 5);
      final c = container(DateTime(2026, 3, 10));
      expect(await c.read(completedPeriodLengthsProvider.future), [5]);
      expect(await c.read(periodLengthProvider.future), 5);
    });

    test('ongoing period falls back to the length from onboarding', () async {
      SharedPreferences.setMockInitialValues({'user_period_length': 6});
      await start(3, 1);
      final c = container(DateTime(2026, 3, 2));
      expect(await c.read(periodLengthProvider.future), 6);
      expect(await c.read(averagePeriodLengthProvider.future), 6);
    });

    test('a period without an end is not matched to the next period end', () async {
      await start(1, 1);
      await start(1, 29);
      await end(2, 2);
      final c = container(DateTime(2026, 2, 10));
      expect(await c.read(completedPeriodLengthsProvider.future), [5]);
    });
  });

  group('health warnings', () {
    Future<List<WarningType>> warnings(DateTime today) async => (await container(today).read(healthWarningsProvider.future)).map((w) => w.type).toList();

    test('regular cycles give no warnings', () async {
      await start(1, 1);
      await end(1, 5);
      await start(1, 29);
      await end(2, 2);
      expect(await warnings(DateTime(2026, 2, 10)), isEmpty);
    });

    test('long last cycle', () async {
      await start(1, 1);
      await start(2, 9);
      expect(await warnings(DateTime(2026, 2, 10)), [WarningType.longCycle]);
    });

    test('short last cycle', () async {
      await start(1, 1);
      await start(1, 22);
      expect(await warnings(DateTime(2026, 1, 25)), [WarningType.shortCycle]);
    });

    test('irregular recent cycles', () async {
      await start(1, 1);
      await start(1, 26);
      await start(3, 4);
      await start(3, 30);
      expect(await warnings(DateTime(2026, 4, 1)), contains(WarningType.irregularity));
    });

    test('long period', () async {
      await start(3, 1);
      await end(3, 10);
      expect(await warnings(DateTime(2026, 3, 12)), [WarningType.longPeriod]);
    });
  });

  test('mood is averaged per cycle phase', () async {
    await start(3, 1);
    await end(3, 5);
    await mood(3, 2, 2);
    await mood(3, 3, 4);
    await mood(3, 14, 5);
    await mood(3, 20, 3);
    final result = await container(DateTime(2026, 3, 25)).read(moodByPhaseProvider.future);
    expect(result, {CyclePhase.menstrual: 3.0, CyclePhase.ovulation: 5.0, CyclePhase.luteal: 3.0});
  });

  test('top symptoms are counted and assigned to the most common phase', () async {
    await start(3, 1);
    await end(3, 5);
    final cramps = (await (db.select(db.symptoms)..where((s) => s.name.equals('Cramps'))).getSingle()).id;
    final fatigue = (await (db.select(db.symptoms)..where((s) => s.name.equals('Fatigue'))).getSingle()).id;
    for (final day in [1, 2, 3]) {
      await db.into(db.symptomLogs).insert(SymptomLogsCompanion.insert(date: DateTime(2026, 3, day).dateOnly, symptomId: cramps));
    }
    await db.into(db.symptomLogs).insert(SymptomLogsCompanion.insert(date: DateTime(2026, 3, 22).dateOnly, symptomId: fatigue));

    final result = await container(DateTime(2026, 3, 25)).read(topSymptomsProvider.future);
    expect(result.map((s) => (s.name, s.count, s.phase)), [
      ('Cramps', 3, CyclePhase.menstrual),
      ('Fatigue', 1, CyclePhase.luteal),
    ]);
  });
}
