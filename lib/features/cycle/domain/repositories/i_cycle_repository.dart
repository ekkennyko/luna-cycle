import 'package:luna/core/database/app_database.dart';

abstract interface class ICycleRepository {
  Future<List<CycleEntry>> getAllEntries();
  Future<List<CycleEntry>> getEntriesBetween(DateTime from, DateTime to);
  Future<CycleEntry?> getEntryForDate(DateTime date);
  Future<void> saveEntry(CycleEntriesCompanion entry);
  Future<void> updateEntryType(int id, String type);
  Future<void> deleteEntry(int id);
  Future<CycleEntry?> getLastPeriodStart();
  Future<CycleEntry?> getLastPeriodEnd();
  Future<void> saveMood(DateTime date, int mood);
  Future<List<CycleEntry>> getAllPeriodStarts();
  Stream<List<CycleEntry>> watchAllEntries();
}
