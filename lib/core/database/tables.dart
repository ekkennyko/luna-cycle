import 'package:drift/drift.dart';

class CycleEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Stored as UTC midnight for accurate date comparison.
  DateTimeColumn get date => dateTime()();

  /// 'period_start' | 'period_day' | 'ovulation' | 'fertile' | 'safe'
  TextColumn get type => text()();

  /// 1=spotting 2=light 3=heavy 4=very heavy
  IntColumn get flowIntensity => integer().nullable()();

  /// 1=very sad … 5=very happy
  IntColumn get mood => integer().nullable()();

  /// Encrypted via EncryptionService.
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {date}
      ];
}

class Symptoms extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().unique()();

  /// Material icon codepoint.
  IntColumn get iconCode => integer()();

  /// 'mood' | 'body' | 'energy' | 'digestion' | 'skin' | 'other'
  TextColumn get category => text()();

  /// false = built-in, true = user-created (Premium).
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class SymptomLogs extends Table {
  IntColumn get id => integer().autoIncrement()();

  DateTimeColumn get date => dateTime()();

  IntColumn get symptomId => integer().references(Symptoms, #id)();

  /// 1=mild 2=moderate 3=severe
  IntColumn get intensity => integer().withDefault(const Constant(1))();

  TextColumn get note => text().nullable()();
}

class Pregnancies extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Last menstrual period (LMP) — gestational age reference point.
  DateTimeColumn get lastMenstrualPeriod => dateTime()();

  DateTimeColumn get dueDate => dateTime().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  TextColumn get notes => text().nullable()();
}
