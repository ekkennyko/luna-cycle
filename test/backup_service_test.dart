import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luna/core/constants/entry_types.dart';
import 'package:luna/core/constants/prefs_keys.dart';
import 'package:luna/core/database/app_database.dart';
import 'package:luna/features/backup/data/backup_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;
  late BackupService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({PrefsKeys.userPeriodLength: 6});
    db = AppDatabase(NativeDatabase.memory());
    service = BackupService(db);
  });

  tearDown(() => db.close());

  Future<void> seed() async {
    await db.into(db.cycleEntries).insert(
          CycleEntriesCompanion.insert(date: DateTime.utc(2026, 3, 1), type: EntryTypes.periodStart, mood: const Value(4)),
        );
    await db.into(db.cycleEntries).insert(CycleEntriesCompanion.insert(date: DateTime.utc(2026, 3, 5), type: EntryTypes.periodEnd));
    await db.into(db.symptomLogs).insert(SymptomLogsCompanion.insert(date: DateTime.utc(2026, 3, 2), symptomId: 5));
  }

  test('restore brings back data that was changed after the backup', () async {
    await seed();
    final entries = await db.select(db.cycleEntries).get();
    final symptoms = await db.select(db.symptoms).get();
    final logs = await db.select(db.symptomLogs).get();

    final backup = await service.create('secret');
    expect(BackupService.isBackup(backup), isTrue);

    await db.resetAllData();
    await db.into(db.cycleEntries).insert(CycleEntriesCompanion.insert(date: DateTime.utc(2026, 5, 1), type: EntryTypes.periodStart));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.userPeriodLength, 3);

    expect(await service.restore(backup, 'secret'), isTrue);
    expect(await db.select(db.cycleEntries).get(), entries);
    expect(await db.select(db.symptoms).get(), symptoms);
    expect(await db.select(db.symptomLogs).get(), logs);
    expect(prefs.getInt(PrefsKeys.userPeriodLength), 6);
  });

  test('wrong password leaves current data untouched', () async {
    await seed();
    final backup = await service.create('secret');
    await db.into(db.cycleEntries).insert(CycleEntriesCompanion.insert(date: DateTime.utc(2026, 5, 1), type: EntryTypes.periodStart));

    expect(await service.restore(backup, 'other'), isFalse);
    expect(await db.select(db.cycleEntries).get(), hasLength(3));
  });

  test('damaged file is rejected', () async {
    final backup = await service.create('secret');
    backup[backup.length - 1] ^= 1;
    expect(await service.restore(backup, 'secret'), isFalse);
  });

  test('backup does not contain plaintext', () async {
    await seed();
    final backup = await service.create('secret');
    expect(String.fromCharCodes(backup).contains(EntryTypes.periodStart), isFalse);
  });

  test('foreign files are not recognised as backups', () {
    expect(BackupService.isBackup(Uint8List.fromList('not a backup at all, just some text that is long enough'.codeUnits)), isFalse);
    expect(BackupService.isBackup(Uint8List(3)), isFalse);
  });
}
