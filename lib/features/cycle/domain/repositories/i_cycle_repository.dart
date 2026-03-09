import 'package:luna/core/database/app_database.dart';

abstract interface class ICycleRepository {
  Future<List<CycleEntry>> getAllEntries();
  Future<List<CycleEntry>> getEntriesBetween(DateTime from, DateTime to);
  Future<CycleEntry?> getEntryForDate(DateTime date);
  Future<void> saveEntry(CycleEntriesCompanion entry);
  Future<void> deleteEntry(int id);
  Future<CycleEntry?> getLastPeriodStart();
  Future<List<CycleEntry>> getAllPeriodStarts();
  Stream<List<CycleEntry>> watchAllEntries();
}
