import 'package:drift/drift.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/core/extensions/date_time_ext.dart';
import 'package:luna/core/constants/entry_types.dart';
import 'package:luna/features/cycle/domain/repositories/i_cycle_repository.dart';

class CycleRepositoryImpl implements ICycleRepository {
  CycleRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<CycleEntry>> getAllEntries() => (_db.select(_db.cycleEntries)..orderBy([(t) => OrderingTerm.desc(t.date)])).get();

  @override
  Future<List<CycleEntry>> getEntriesBetween(DateTime from, DateTime to) => (_db.select(_db.cycleEntries)
        ..where((t) => t.date.isBetweenValues(from, to))
        ..orderBy([(t) => OrderingTerm.asc(t.date)]))
      .get();

  @override
  Future<CycleEntry?> getEntryForDate(DateTime date) {
    final day = date.dateOnly;
    final next = day.add(const Duration(days: 1));
    return (_db.select(_db.cycleEntries)..where((t) => t.date.isBiggerOrEqualValue(day) & t.date.isSmallerThanValue(next))).getSingleOrNull();
  }

  @override
  Future<void> saveEntry(CycleEntriesCompanion entry) => _db.into(_db.cycleEntries).insertOnConflictUpdate(entry);

  @override
  Future<void> updateEntryType(int id, String type) =>
      (_db.update(_db.cycleEntries)..where((t) => t.id.equals(id))).write(CycleEntriesCompanion(type: Value(type)));

  @override
  Future<void> deleteEntry(int id) => (_db.delete(_db.cycleEntries)..where((t) => t.id.equals(id))).go();

  @override
  Future<CycleEntry?> getLastPeriodStart() => (_db.select(_db.cycleEntries)
        ..where((t) => t.type.equals(EntryTypes.periodStart))
        ..orderBy([(t) => OrderingTerm.desc(t.date)])
        ..limit(1))
      .getSingleOrNull();

  @override
  Future<void> saveMood(DateTime date, int mood) async {
    final day = date.dateOnly;
    final existing = await getEntryForDate(date);
    if (existing != null) {
      await saveEntry(existing.toCompanion(true).copyWith(mood: Value(mood)));
    } else {
      await saveEntry(CycleEntriesCompanion.insert(
        date: day,
        type: EntryTypes.moodLog,
        mood: Value(mood),
      ));
    }
  }

  @override
  Future<CycleEntry?> getLastPeriodEnd() => (_db.select(_db.cycleEntries)
        ..where((t) => t.type.equals(EntryTypes.periodEnd))
        ..orderBy([(t) => OrderingTerm.desc(t.date)])
        ..limit(1))
      .getSingleOrNull();

  @override
  Future<List<CycleEntry>> getAllPeriodStarts() => (_db.select(_db.cycleEntries)
        ..where((t) => t.type.equals(EntryTypes.periodStart))
        ..orderBy([(t) => OrderingTerm.asc(t.date)]))
      .get();

  @override
  Stream<List<CycleEntry>> watchAllEntries() => (_db.select(_db.cycleEntries)..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
}
