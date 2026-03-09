// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CycleEntriesTable extends CycleEntries
    with TableInfo<$CycleEntriesTable, CycleEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _flowIntensityMeta =
      const VerificationMeta('flowIntensity');
  @override
  late final GeneratedColumn<int> flowIntensity = GeneratedColumn<int>(
      'flow_intensity', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<int> mood = GeneratedColumn<int>(
      'mood', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, type, flowIntensity, mood, notes, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_entries';
  @override
  VerificationContext validateIntegrity(Insertable<CycleEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('flow_intensity')) {
      context.handle(
          _flowIntensityMeta,
          flowIntensity.isAcceptableOrUnknown(
              data['flow_intensity']!, _flowIntensityMeta));
    }
    if (data.containsKey('mood')) {
      context.handle(
          _moodMeta, mood.isAcceptableOrUnknown(data['mood']!, _moodMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {date},
      ];
  @override
  CycleEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      flowIntensity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flow_intensity']),
      mood: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mood']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CycleEntriesTable createAlias(String alias) {
    return $CycleEntriesTable(attachedDatabase, alias);
  }
}

class CycleEntry extends DataClass implements Insertable<CycleEntry> {
  final int id;

  /// Stored as UTC midnight for accurate date comparison.
  final DateTime date;

  /// 'period_start' | 'period_day' | 'ovulation' | 'fertile' | 'safe'
  final String type;

  /// 1=spotting 2=light 3=heavy 4=very heavy
  final int? flowIntensity;

  /// 1=very sad … 5=very happy
  final int? mood;

  /// Encrypted via EncryptionService.
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CycleEntry(
      {required this.id,
      required this.date,
      required this.type,
      this.flowIntensity,
      this.mood,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || flowIntensity != null) {
      map['flow_intensity'] = Variable<int>(flowIntensity);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<int>(mood);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CycleEntriesCompanion toCompanion(bool nullToAbsent) {
    return CycleEntriesCompanion(
      id: Value(id),
      date: Value(date),
      type: Value(type),
      flowIntensity: flowIntensity == null && nullToAbsent
          ? const Value.absent()
          : Value(flowIntensity),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CycleEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      flowIntensity: serializer.fromJson<int?>(json['flowIntensity']),
      mood: serializer.fromJson<int?>(json['mood']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'flowIntensity': serializer.toJson<int?>(flowIntensity),
      'mood': serializer.toJson<int?>(mood),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CycleEntry copyWith(
          {int? id,
          DateTime? date,
          String? type,
          Value<int?> flowIntensity = const Value.absent(),
          Value<int?> mood = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CycleEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        type: type ?? this.type,
        flowIntensity:
            flowIntensity.present ? flowIntensity.value : this.flowIntensity,
        mood: mood.present ? mood.value : this.mood,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CycleEntry copyWithCompanion(CycleEntriesCompanion data) {
    return CycleEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      flowIntensity: data.flowIntensity.present
          ? data.flowIntensity.value
          : this.flowIntensity,
      mood: data.mood.present ? data.mood.value : this.mood,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('flowIntensity: $flowIntensity, ')
          ..write('mood: $mood, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, date, type, flowIntensity, mood, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.type == this.type &&
          other.flowIntensity == this.flowIntensity &&
          other.mood == this.mood &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CycleEntriesCompanion extends UpdateCompanion<CycleEntry> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<int?> flowIntensity;
  final Value<int?> mood;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CycleEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.flowIntensity = const Value.absent(),
    this.mood = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CycleEntriesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required String type,
    this.flowIntensity = const Value.absent(),
    this.mood = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : date = Value(date),
        type = Value(type);
  static Insertable<CycleEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? flowIntensity,
    Expression<int>? mood,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (flowIntensity != null) 'flow_intensity': flowIntensity,
      if (mood != null) 'mood': mood,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CycleEntriesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? type,
      Value<int?>? flowIntensity,
      Value<int?>? mood,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return CycleEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (flowIntensity.present) {
      map['flow_intensity'] = Variable<int>(flowIntensity.value);
    }
    if (mood.present) {
      map['mood'] = Variable<int>(mood.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('flowIntensity: $flowIntensity, ')
          ..write('mood: $mood, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SymptomsTable extends Symptoms with TableInfo<$SymptomsTable, Symptom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _iconCodeMeta =
      const VerificationMeta('iconCode');
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
      'icon_code', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, iconCode, category, isCustom, isActive, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptoms';
  @override
  VerificationContext validateIntegrity(Insertable<Symptom> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(_iconCodeMeta,
          iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta));
    } else if (isInserting) {
      context.missing(_iconCodeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Symptom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Symptom(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconCode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_code'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
    );
  }

  @override
  $SymptomsTable createAlias(String alias) {
    return $SymptomsTable(attachedDatabase, alias);
  }
}

class Symptom extends DataClass implements Insertable<Symptom> {
  final int id;
  final String name;

  /// Material icon codepoint.
  final int iconCode;

  /// 'mood' | 'body' | 'energy' | 'digestion' | 'skin' | 'other'
  final String category;

  /// false = built-in, true = user-created (Premium).
  final bool isCustom;
  final bool isActive;
  final int sortOrder;
  const Symptom(
      {required this.id,
      required this.name,
      required this.iconCode,
      required this.category,
      required this.isCustom,
      required this.isActive,
      required this.sortOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon_code'] = Variable<int>(iconCode);
    map['category'] = Variable<String>(category);
    map['is_custom'] = Variable<bool>(isCustom);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SymptomsCompanion toCompanion(bool nullToAbsent) {
    return SymptomsCompanion(
      id: Value(id),
      name: Value(name),
      iconCode: Value(iconCode),
      category: Value(category),
      isCustom: Value(isCustom),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory Symptom.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Symptom(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconCode: serializer.fromJson<int>(json['iconCode']),
      category: serializer.fromJson<String>(json['category']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconCode': serializer.toJson<int>(iconCode),
      'category': serializer.toJson<String>(category),
      'isCustom': serializer.toJson<bool>(isCustom),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Symptom copyWith(
          {int? id,
          String? name,
          int? iconCode,
          String? category,
          bool? isCustom,
          bool? isActive,
          int? sortOrder}) =>
      Symptom(
        id: id ?? this.id,
        name: name ?? this.name,
        iconCode: iconCode ?? this.iconCode,
        category: category ?? this.category,
        isCustom: isCustom ?? this.isCustom,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Symptom copyWithCompanion(SymptomsCompanion data) {
    return Symptom(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
      category: data.category.present ? data.category.value : this.category,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Symptom(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('category: $category, ')
          ..write('isCustom: $isCustom, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconCode, category, isCustom, isActive, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Symptom &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconCode == this.iconCode &&
          other.category == this.category &&
          other.isCustom == this.isCustom &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class SymptomsCompanion extends UpdateCompanion<Symptom> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> iconCode;
  final Value<String> category;
  final Value<bool> isCustom;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  const SymptomsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.category = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SymptomsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int iconCode,
    required String category,
    this.isCustom = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  })  : name = Value(name),
        iconCode = Value(iconCode),
        category = Value(category);
  static Insertable<Symptom> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? iconCode,
    Expression<String>? category,
    Expression<bool>? isCustom,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconCode != null) 'icon_code': iconCode,
      if (category != null) 'category': category,
      if (isCustom != null) 'is_custom': isCustom,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SymptomsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? iconCode,
      Value<String>? category,
      Value<bool>? isCustom,
      Value<bool>? isActive,
      Value<int>? sortOrder}) {
    return SymptomsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      category: category ?? this.category,
      isCustom: isCustom ?? this.isCustom,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconCode: $iconCode, ')
          ..write('category: $category, ')
          ..write('isCustom: $isCustom, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $SymptomLogsTable extends SymptomLogs
    with TableInfo<$SymptomLogsTable, SymptomLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SymptomLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _symptomIdMeta =
      const VerificationMeta('symptomId');
  @override
  late final GeneratedColumn<int> symptomId = GeneratedColumn<int>(
      'symptom_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES symptoms (id)'));
  static const VerificationMeta _intensityMeta =
      const VerificationMeta('intensity');
  @override
  late final GeneratedColumn<int> intensity = GeneratedColumn<int>(
      'intensity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, date, symptomId, intensity, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'symptom_logs';
  @override
  VerificationContext validateIntegrity(Insertable<SymptomLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('symptom_id')) {
      context.handle(_symptomIdMeta,
          symptomId.isAcceptableOrUnknown(data['symptom_id']!, _symptomIdMeta));
    } else if (isInserting) {
      context.missing(_symptomIdMeta);
    }
    if (data.containsKey('intensity')) {
      context.handle(_intensityMeta,
          intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SymptomLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SymptomLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      symptomId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}symptom_id'])!,
      intensity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}intensity'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $SymptomLogsTable createAlias(String alias) {
    return $SymptomLogsTable(attachedDatabase, alias);
  }
}

class SymptomLog extends DataClass implements Insertable<SymptomLog> {
  final int id;
  final DateTime date;
  final int symptomId;

  /// 1=mild 2=moderate 3=severe
  final int intensity;
  final String? note;
  const SymptomLog(
      {required this.id,
      required this.date,
      required this.symptomId,
      required this.intensity,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['symptom_id'] = Variable<int>(symptomId);
    map['intensity'] = Variable<int>(intensity);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SymptomLogsCompanion toCompanion(bool nullToAbsent) {
    return SymptomLogsCompanion(
      id: Value(id),
      date: Value(date),
      symptomId: Value(symptomId),
      intensity: Value(intensity),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory SymptomLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SymptomLog(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      symptomId: serializer.fromJson<int>(json['symptomId']),
      intensity: serializer.fromJson<int>(json['intensity']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'symptomId': serializer.toJson<int>(symptomId),
      'intensity': serializer.toJson<int>(intensity),
      'note': serializer.toJson<String?>(note),
    };
  }

  SymptomLog copyWith(
          {int? id,
          DateTime? date,
          int? symptomId,
          int? intensity,
          Value<String?> note = const Value.absent()}) =>
      SymptomLog(
        id: id ?? this.id,
        date: date ?? this.date,
        symptomId: symptomId ?? this.symptomId,
        intensity: intensity ?? this.intensity,
        note: note.present ? note.value : this.note,
      );
  SymptomLog copyWithCompanion(SymptomLogsCompanion data) {
    return SymptomLog(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      symptomId: data.symptomId.present ? data.symptomId.value : this.symptomId,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SymptomLog(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('symptomId: $symptomId, ')
          ..write('intensity: $intensity, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, symptomId, intensity, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SymptomLog &&
          other.id == this.id &&
          other.date == this.date &&
          other.symptomId == this.symptomId &&
          other.intensity == this.intensity &&
          other.note == this.note);
}

class SymptomLogsCompanion extends UpdateCompanion<SymptomLog> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<int> symptomId;
  final Value<int> intensity;
  final Value<String?> note;
  const SymptomLogsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.symptomId = const Value.absent(),
    this.intensity = const Value.absent(),
    this.note = const Value.absent(),
  });
  SymptomLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required int symptomId,
    this.intensity = const Value.absent(),
    this.note = const Value.absent(),
  })  : date = Value(date),
        symptomId = Value(symptomId);
  static Insertable<SymptomLog> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<int>? symptomId,
    Expression<int>? intensity,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (symptomId != null) 'symptom_id': symptomId,
      if (intensity != null) 'intensity': intensity,
      if (note != null) 'note': note,
    });
  }

  SymptomLogsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<int>? symptomId,
      Value<int>? intensity,
      Value<String?>? note}) {
    return SymptomLogsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      symptomId: symptomId ?? this.symptomId,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (symptomId.present) {
      map['symptom_id'] = Variable<int>(symptomId.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<int>(intensity.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SymptomLogsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('symptomId: $symptomId, ')
          ..write('intensity: $intensity, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PregnanciesTable extends Pregnancies
    with TableInfo<$PregnanciesTable, Pregnancy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PregnanciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _lastMenstrualPeriodMeta =
      const VerificationMeta('lastMenstrualPeriod');
  @override
  late final GeneratedColumn<DateTime> lastMenstrualPeriod =
      GeneratedColumn<DateTime>('last_menstrual_period', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, lastMenstrualPeriod, dueDate, isActive, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pregnancies';
  @override
  VerificationContext validateIntegrity(Insertable<Pregnancy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('last_menstrual_period')) {
      context.handle(
          _lastMenstrualPeriodMeta,
          lastMenstrualPeriod.isAcceptableOrUnknown(
              data['last_menstrual_period']!, _lastMenstrualPeriodMeta));
    } else if (isInserting) {
      context.missing(_lastMenstrualPeriodMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pregnancy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pregnancy(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      lastMenstrualPeriod: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_menstrual_period'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $PregnanciesTable createAlias(String alias) {
    return $PregnanciesTable(attachedDatabase, alias);
  }
}

class Pregnancy extends DataClass implements Insertable<Pregnancy> {
  final int id;

  /// Last menstrual period (LMP) — gestational age reference point.
  final DateTime lastMenstrualPeriod;
  final DateTime? dueDate;
  final bool isActive;
  final String? notes;
  const Pregnancy(
      {required this.id,
      required this.lastMenstrualPeriod,
      this.dueDate,
      required this.isActive,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['last_menstrual_period'] = Variable<DateTime>(lastMenstrualPeriod);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PregnanciesCompanion toCompanion(bool nullToAbsent) {
    return PregnanciesCompanion(
      id: Value(id),
      lastMenstrualPeriod: Value(lastMenstrualPeriod),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      isActive: Value(isActive),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory Pregnancy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pregnancy(
      id: serializer.fromJson<int>(json['id']),
      lastMenstrualPeriod:
          serializer.fromJson<DateTime>(json['lastMenstrualPeriod']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lastMenstrualPeriod': serializer.toJson<DateTime>(lastMenstrualPeriod),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'isActive': serializer.toJson<bool>(isActive),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Pregnancy copyWith(
          {int? id,
          DateTime? lastMenstrualPeriod,
          Value<DateTime?> dueDate = const Value.absent(),
          bool? isActive,
          Value<String?> notes = const Value.absent()}) =>
      Pregnancy(
        id: id ?? this.id,
        lastMenstrualPeriod: lastMenstrualPeriod ?? this.lastMenstrualPeriod,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        isActive: isActive ?? this.isActive,
        notes: notes.present ? notes.value : this.notes,
      );
  Pregnancy copyWithCompanion(PregnanciesCompanion data) {
    return Pregnancy(
      id: data.id.present ? data.id.value : this.id,
      lastMenstrualPeriod: data.lastMenstrualPeriod.present
          ? data.lastMenstrualPeriod.value
          : this.lastMenstrualPeriod,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pregnancy(')
          ..write('id: $id, ')
          ..write('lastMenstrualPeriod: $lastMenstrualPeriod, ')
          ..write('dueDate: $dueDate, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, lastMenstrualPeriod, dueDate, isActive, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pregnancy &&
          other.id == this.id &&
          other.lastMenstrualPeriod == this.lastMenstrualPeriod &&
          other.dueDate == this.dueDate &&
          other.isActive == this.isActive &&
          other.notes == this.notes);
}

class PregnanciesCompanion extends UpdateCompanion<Pregnancy> {
  final Value<int> id;
  final Value<DateTime> lastMenstrualPeriod;
  final Value<DateTime?> dueDate;
  final Value<bool> isActive;
  final Value<String?> notes;
  const PregnanciesCompanion({
    this.id = const Value.absent(),
    this.lastMenstrualPeriod = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
  });
  PregnanciesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime lastMenstrualPeriod,
    this.dueDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.notes = const Value.absent(),
  }) : lastMenstrualPeriod = Value(lastMenstrualPeriod);
  static Insertable<Pregnancy> custom({
    Expression<int>? id,
    Expression<DateTime>? lastMenstrualPeriod,
    Expression<DateTime>? dueDate,
    Expression<bool>? isActive,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lastMenstrualPeriod != null)
        'last_menstrual_period': lastMenstrualPeriod,
      if (dueDate != null) 'due_date': dueDate,
      if (isActive != null) 'is_active': isActive,
      if (notes != null) 'notes': notes,
    });
  }

  PregnanciesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? lastMenstrualPeriod,
      Value<DateTime?>? dueDate,
      Value<bool>? isActive,
      Value<String?>? notes}) {
    return PregnanciesCompanion(
      id: id ?? this.id,
      lastMenstrualPeriod: lastMenstrualPeriod ?? this.lastMenstrualPeriod,
      dueDate: dueDate ?? this.dueDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lastMenstrualPeriod.present) {
      map['last_menstrual_period'] =
          Variable<DateTime>(lastMenstrualPeriod.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PregnanciesCompanion(')
          ..write('id: $id, ')
          ..write('lastMenstrualPeriod: $lastMenstrualPeriod, ')
          ..write('dueDate: $dueDate, ')
          ..write('isActive: $isActive, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CycleEntriesTable cycleEntries = $CycleEntriesTable(this);
  late final $SymptomsTable symptoms = $SymptomsTable(this);
  late final $SymptomLogsTable symptomLogs = $SymptomLogsTable(this);
  late final $PregnanciesTable pregnancies = $PregnanciesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cycleEntries, symptoms, symptomLogs, pregnancies];
}

typedef $$CycleEntriesTableCreateCompanionBuilder = CycleEntriesCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required String type,
  Value<int?> flowIntensity,
  Value<int?> mood,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$CycleEntriesTableUpdateCompanionBuilder = CycleEntriesCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> type,
  Value<int?> flowIntensity,
  Value<int?> mood,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$CycleEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CycleEntriesTable> {
  $$CycleEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get flowIntensity => $composableBuilder(
      column: $table.flowIntensity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$CycleEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CycleEntriesTable> {
  $$CycleEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get flowIntensity => $composableBuilder(
      column: $table.flowIntensity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mood => $composableBuilder(
      column: $table.mood, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CycleEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CycleEntriesTable> {
  $$CycleEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get flowIntensity => $composableBuilder(
      column: $table.flowIntensity, builder: (column) => column);

  GeneratedColumn<int> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CycleEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CycleEntriesTable,
    CycleEntry,
    $$CycleEntriesTableFilterComposer,
    $$CycleEntriesTableOrderingComposer,
    $$CycleEntriesTableAnnotationComposer,
    $$CycleEntriesTableCreateCompanionBuilder,
    $$CycleEntriesTableUpdateCompanionBuilder,
    (CycleEntry, BaseReferences<_$AppDatabase, $CycleEntriesTable, CycleEntry>),
    CycleEntry,
    PrefetchHooks Function()> {
  $$CycleEntriesTableTableManager(_$AppDatabase db, $CycleEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int?> flowIntensity = const Value.absent(),
            Value<int?> mood = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CycleEntriesCompanion(
            id: id,
            date: date,
            type: type,
            flowIntensity: flowIntensity,
            mood: mood,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required String type,
            Value<int?> flowIntensity = const Value.absent(),
            Value<int?> mood = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              CycleEntriesCompanion.insert(
            id: id,
            date: date,
            type: type,
            flowIntensity: flowIntensity,
            mood: mood,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CycleEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CycleEntriesTable,
    CycleEntry,
    $$CycleEntriesTableFilterComposer,
    $$CycleEntriesTableOrderingComposer,
    $$CycleEntriesTableAnnotationComposer,
    $$CycleEntriesTableCreateCompanionBuilder,
    $$CycleEntriesTableUpdateCompanionBuilder,
    (CycleEntry, BaseReferences<_$AppDatabase, $CycleEntriesTable, CycleEntry>),
    CycleEntry,
    PrefetchHooks Function()>;
typedef $$SymptomsTableCreateCompanionBuilder = SymptomsCompanion Function({
  Value<int> id,
  required String name,
  required int iconCode,
  required String category,
  Value<bool> isCustom,
  Value<bool> isActive,
  Value<int> sortOrder,
});
typedef $$SymptomsTableUpdateCompanionBuilder = SymptomsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> iconCode,
  Value<String> category,
  Value<bool> isCustom,
  Value<bool> isActive,
  Value<int> sortOrder,
});

final class $$SymptomsTableReferences
    extends BaseReferences<_$AppDatabase, $SymptomsTable, Symptom> {
  $$SymptomsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SymptomLogsTable, List<SymptomLog>>
      _symptomLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.symptomLogs,
          aliasName:
              $_aliasNameGenerator(db.symptoms.id, db.symptomLogs.symptomId));

  $$SymptomLogsTableProcessedTableManager get symptomLogsRefs {
    final manager = $$SymptomLogsTableTableManager($_db, $_db.symptomLogs)
        .filter((f) => f.symptomId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_symptomLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SymptomsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconCode => $composableBuilder(
      column: $table.iconCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  Expression<bool> symptomLogsRefs(
      Expression<bool> Function($$SymptomLogsTableFilterComposer f) f) {
    final $$SymptomLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.symptomLogs,
        getReferencedColumn: (t) => t.symptomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SymptomLogsTableFilterComposer(
              $db: $db,
              $table: $db.symptomLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SymptomsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconCode => $composableBuilder(
      column: $table.iconCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));
}

class $$SymptomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomsTable> {
  $$SymptomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> symptomLogsRefs<T extends Object>(
      Expression<T> Function($$SymptomLogsTableAnnotationComposer a) f) {
    final $$SymptomLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.symptomLogs,
        getReferencedColumn: (t) => t.symptomId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SymptomLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.symptomLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SymptomsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SymptomsTable,
    Symptom,
    $$SymptomsTableFilterComposer,
    $$SymptomsTableOrderingComposer,
    $$SymptomsTableAnnotationComposer,
    $$SymptomsTableCreateCompanionBuilder,
    $$SymptomsTableUpdateCompanionBuilder,
    (Symptom, $$SymptomsTableReferences),
    Symptom,
    PrefetchHooks Function({bool symptomLogsRefs})> {
  $$SymptomsTableTableManager(_$AppDatabase db, $SymptomsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> iconCode = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              SymptomsCompanion(
            id: id,
            name: name,
            iconCode: iconCode,
            category: category,
            isCustom: isCustom,
            isActive: isActive,
            sortOrder: sortOrder,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int iconCode,
            required String category,
            Value<bool> isCustom = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
          }) =>
              SymptomsCompanion.insert(
            id: id,
            name: name,
            iconCode: iconCode,
            category: category,
            isCustom: isCustom,
            isActive: isActive,
            sortOrder: sortOrder,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SymptomsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({symptomLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (symptomLogsRefs) db.symptomLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (symptomLogsRefs)
                    await $_getPrefetchedData<Symptom, $SymptomsTable,
                            SymptomLog>(
                        currentTable: table,
                        referencedTable:
                            $$SymptomsTableReferences._symptomLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SymptomsTableReferences(db, table, p0)
                                .symptomLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.symptomId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SymptomsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SymptomsTable,
    Symptom,
    $$SymptomsTableFilterComposer,
    $$SymptomsTableOrderingComposer,
    $$SymptomsTableAnnotationComposer,
    $$SymptomsTableCreateCompanionBuilder,
    $$SymptomsTableUpdateCompanionBuilder,
    (Symptom, $$SymptomsTableReferences),
    Symptom,
    PrefetchHooks Function({bool symptomLogsRefs})>;
typedef $$SymptomLogsTableCreateCompanionBuilder = SymptomLogsCompanion
    Function({
  Value<int> id,
  required DateTime date,
  required int symptomId,
  Value<int> intensity,
  Value<String?> note,
});
typedef $$SymptomLogsTableUpdateCompanionBuilder = SymptomLogsCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<int> symptomId,
  Value<int> intensity,
  Value<String?> note,
});

final class $$SymptomLogsTableReferences
    extends BaseReferences<_$AppDatabase, $SymptomLogsTable, SymptomLog> {
  $$SymptomLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SymptomsTable _symptomIdTable(_$AppDatabase db) =>
      db.symptoms.createAlias(
          $_aliasNameGenerator(db.symptomLogs.symptomId, db.symptoms.id));

  $$SymptomsTableProcessedTableManager get symptomId {
    final $_column = $_itemColumn<int>('symptom_id')!;

    final manager = $$SymptomsTableTableManager($_db, $_db.symptoms)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_symptomIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SymptomLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SymptomLogsTable> {
  $$SymptomLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intensity => $composableBuilder(
      column: $table.intensity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  $$SymptomsTableFilterComposer get symptomId {
    final $$SymptomsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.symptomId,
        referencedTable: $db.symptoms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SymptomsTableFilterComposer(
              $db: $db,
              $table: $db.symptoms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SymptomLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SymptomLogsTable> {
  $$SymptomLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intensity => $composableBuilder(
      column: $table.intensity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  $$SymptomsTableOrderingComposer get symptomId {
    final $$SymptomsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.symptomId,
        referencedTable: $db.symptoms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SymptomsTableOrderingComposer(
              $db: $db,
              $table: $db.symptoms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SymptomLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SymptomLogsTable> {
  $$SymptomLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$SymptomsTableAnnotationComposer get symptomId {
    final $$SymptomsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.symptomId,
        referencedTable: $db.symptoms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SymptomsTableAnnotationComposer(
              $db: $db,
              $table: $db.symptoms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SymptomLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SymptomLogsTable,
    SymptomLog,
    $$SymptomLogsTableFilterComposer,
    $$SymptomLogsTableOrderingComposer,
    $$SymptomLogsTableAnnotationComposer,
    $$SymptomLogsTableCreateCompanionBuilder,
    $$SymptomLogsTableUpdateCompanionBuilder,
    (SymptomLog, $$SymptomLogsTableReferences),
    SymptomLog,
    PrefetchHooks Function({bool symptomId})> {
  $$SymptomLogsTableTableManager(_$AppDatabase db, $SymptomLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SymptomLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SymptomLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SymptomLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<int> symptomId = const Value.absent(),
            Value<int> intensity = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SymptomLogsCompanion(
            id: id,
            date: date,
            symptomId: symptomId,
            intensity: intensity,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime date,
            required int symptomId,
            Value<int> intensity = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SymptomLogsCompanion.insert(
            id: id,
            date: date,
            symptomId: symptomId,
            intensity: intensity,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SymptomLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({symptomId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (symptomId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.symptomId,
                    referencedTable:
                        $$SymptomLogsTableReferences._symptomIdTable(db),
                    referencedColumn:
                        $$SymptomLogsTableReferences._symptomIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SymptomLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SymptomLogsTable,
    SymptomLog,
    $$SymptomLogsTableFilterComposer,
    $$SymptomLogsTableOrderingComposer,
    $$SymptomLogsTableAnnotationComposer,
    $$SymptomLogsTableCreateCompanionBuilder,
    $$SymptomLogsTableUpdateCompanionBuilder,
    (SymptomLog, $$SymptomLogsTableReferences),
    SymptomLog,
    PrefetchHooks Function({bool symptomId})>;
typedef $$PregnanciesTableCreateCompanionBuilder = PregnanciesCompanion
    Function({
  Value<int> id,
  required DateTime lastMenstrualPeriod,
  Value<DateTime?> dueDate,
  Value<bool> isActive,
  Value<String?> notes,
});
typedef $$PregnanciesTableUpdateCompanionBuilder = PregnanciesCompanion
    Function({
  Value<int> id,
  Value<DateTime> lastMenstrualPeriod,
  Value<DateTime?> dueDate,
  Value<bool> isActive,
  Value<String?> notes,
});

class $$PregnanciesTableFilterComposer
    extends Composer<_$AppDatabase, $PregnanciesTable> {
  $$PregnanciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMenstrualPeriod => $composableBuilder(
      column: $table.lastMenstrualPeriod,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$PregnanciesTableOrderingComposer
    extends Composer<_$AppDatabase, $PregnanciesTable> {
  $$PregnanciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMenstrualPeriod => $composableBuilder(
      column: $table.lastMenstrualPeriod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$PregnanciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PregnanciesTable> {
  $$PregnanciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMenstrualPeriod => $composableBuilder(
      column: $table.lastMenstrualPeriod, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$PregnanciesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PregnanciesTable,
    Pregnancy,
    $$PregnanciesTableFilterComposer,
    $$PregnanciesTableOrderingComposer,
    $$PregnanciesTableAnnotationComposer,
    $$PregnanciesTableCreateCompanionBuilder,
    $$PregnanciesTableUpdateCompanionBuilder,
    (Pregnancy, BaseReferences<_$AppDatabase, $PregnanciesTable, Pregnancy>),
    Pregnancy,
    PrefetchHooks Function()> {
  $$PregnanciesTableTableManager(_$AppDatabase db, $PregnanciesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PregnanciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PregnanciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PregnanciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> lastMenstrualPeriod = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              PregnanciesCompanion(
            id: id,
            lastMenstrualPeriod: lastMenstrualPeriod,
            dueDate: dueDate,
            isActive: isActive,
            notes: notes,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime lastMenstrualPeriod,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<String?> notes = const Value.absent(),
          }) =>
              PregnanciesCompanion.insert(
            id: id,
            lastMenstrualPeriod: lastMenstrualPeriod,
            dueDate: dueDate,
            isActive: isActive,
            notes: notes,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PregnanciesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PregnanciesTable,
    Pregnancy,
    $$PregnanciesTableFilterComposer,
    $$PregnanciesTableOrderingComposer,
    $$PregnanciesTableAnnotationComposer,
    $$PregnanciesTableCreateCompanionBuilder,
    $$PregnanciesTableUpdateCompanionBuilder,
    (Pregnancy, BaseReferences<_$AppDatabase, $PregnanciesTable, Pregnancy>),
    Pregnancy,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CycleEntriesTableTableManager get cycleEntries =>
      $$CycleEntriesTableTableManager(_db, _db.cycleEntries);
  $$SymptomsTableTableManager get symptoms =>
      $$SymptomsTableTableManager(_db, _db.symptoms);
  $$SymptomLogsTableTableManager get symptomLogs =>
      $$SymptomLogsTableTableManager(_db, _db.symptomLogs);
  $$PregnanciesTableTableManager get pregnancies =>
      $$PregnanciesTableTableManager(_db, _db.pregnancies);
}
