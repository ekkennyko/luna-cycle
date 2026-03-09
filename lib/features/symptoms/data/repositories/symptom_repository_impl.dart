import 'package:drift/drift.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/features/symptoms/domain/repositories/i_symptom_repository.dart';

class SymptomRepositoryImpl implements ISymptomRepository {
  SymptomRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Symptom>> getAllSymptoms() =>
      (_db.select(_db.symptoms)
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  @override
  Future<List<Symptom>> getActiveSymptoms() =>
      (_db.select(_db.symptoms)
            ..where((t) => t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  @override
  Future<void> saveSymptom(SymptomsCompanion symptom) =>
      _db.into(_db.symptoms).insertOnConflictUpdate(symptom);

  @override
  Future<void> deleteSymptom(int id) =>
      (_db.delete(_db.symptoms)..where((t) => t.id.equals(id))).go();

  @override
  Future<List<SymptomLog>> getLogsForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day).toUtc();
    final next = day.add(const Duration(days: 1));
    return (_db.select(_db.symptomLogs)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(day) &
              t.date.isSmallerThanValue(next)))
        .get();
  }

  @override
  Future<List<SymptomLog>> getLogsBetween(DateTime from, DateTime to) =>
      (_db.select(_db.symptomLogs)
            ..where((t) => t.date.isBetweenValues(from, to))
            ..orderBy([(t) => OrderingTerm.asc(t.date)]))
          .get();

  @override
  Future<void> saveLog(SymptomLogsCompanion log) =>
      _db.into(_db.symptomLogs).insertOnConflictUpdate(log);

  @override
  Future<void> deleteLog(int id) =>
      (_db.delete(_db.symptomLogs)..where((t) => t.id.equals(id))).go();

  @override
  Future<void> deleteLogsForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day).toUtc();
    final next = day.add(const Duration(days: 1));
    return (_db.delete(_db.symptomLogs)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(day) &
              t.date.isSmallerThanValue(next)))
        .go();
  }

  @override
  Stream<List<SymptomLog>> watchLogsForDate(DateTime date) {
    final day = DateTime(date.year, date.month, date.day).toUtc();
    final next = day.add(const Duration(days: 1));
    return (_db.select(_db.symptomLogs)
          ..where((t) =>
              t.date.isBiggerOrEqualValue(day) &
              t.date.isSmallerThanValue(next)))
        .watch();
  }
}
