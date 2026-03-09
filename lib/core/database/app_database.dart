import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:luna/core/database/tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CycleEntries, Symptoms, SymptomLogs, Pregnancies])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaultSymptoms();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(cycleEntries, cycleEntries.mood);
          }
        },
      );

  Future<void> resetAllData() async {
    await delete(symptomLogs).go();
    await delete(cycleEntries).go();
    await delete(pregnancies).go();
  }

  Future<void> _seedDefaultSymptoms() async {
    const defaults = [
      (name: 'Happy', iconCode: 0xe5f0, category: 'mood', sort: 0),
      (name: 'Irritable', iconCode: 0xe5b3, category: 'mood', sort: 1),
      (name: 'Anxious', iconCode: 0xe5b4, category: 'mood', sort: 2),
      (name: 'Sad', iconCode: 0xe5b5, category: 'mood', sort: 3),
      (name: 'Cramps', iconCode: 0xe3f4, category: 'body', sort: 10),
      (name: 'Headache', iconCode: 0xe3f5, category: 'body', sort: 11),
      (name: 'Breast tenderness', iconCode: 0xe3f6, category: 'body', sort: 12),
      (name: 'Bloating', iconCode: 0xe3f7, category: 'body', sort: 13),
      (name: 'Back pain', iconCode: 0xe3f8, category: 'body', sort: 14),
      (name: 'High energy', iconCode: 0xe556, category: 'energy', sort: 20),
      (name: 'Fatigue', iconCode: 0xe557, category: 'energy', sort: 21),
      (name: 'Insomnia', iconCode: 0xe558, category: 'energy', sort: 22),
      (name: 'Nausea', iconCode: 0xe3fd, category: 'digestion', sort: 30),
      (name: 'Diarrhea', iconCode: 0xe3fe, category: 'digestion', sort: 31),
      (name: 'Constipation', iconCode: 0xe3ff, category: 'digestion', sort: 32),
      (name: 'Acne', iconCode: 0xe31e, category: 'skin', sort: 40),
      (name: 'Dry skin', iconCode: 0xe31f, category: 'skin', sort: 41),
    ];

    await batch((b) {
      b.insertAll(
        symptoms,
        defaults.map(
          (s) => SymptomsCompanion.insert(
            name: s.name,
            iconCode: s.iconCode,
            category: s.category,
            sortOrder: Value(s.sort),
          ),
        ),
      );
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'luna_db');
}
