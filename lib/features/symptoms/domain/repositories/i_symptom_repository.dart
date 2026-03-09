import 'package:luna/core/database/app_database.dart';

abstract interface class ISymptomRepository {
  Future<List<Symptom>> getAllSymptoms();
  Future<List<Symptom>> getActiveSymptoms();
  Future<void> saveSymptom(SymptomsCompanion symptom);
  Future<void> deleteSymptom(int id);

  Future<List<SymptomLog>> getLogsForDate(DateTime date);
  Future<List<SymptomLog>> getLogsBetween(DateTime from, DateTime to);
  Future<void> saveLog(SymptomLogsCompanion log);
  Future<void> deleteLog(int id);

  Stream<List<SymptomLog>> watchLogsForDate(DateTime date);
}
