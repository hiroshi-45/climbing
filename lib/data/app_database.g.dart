// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GymsTable extends Gyms with TableInfo<$GymsTable, Gym> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    clientDefault: _uuid.v4,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeSystemMeta = const VerificationMeta(
    'gradeSystem',
  );
  @override
  late final GeneratedColumn<String> gradeSystem = GeneratedColumn<String>(
    'grade_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('grade'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    updatedAt,
    isDeleted,
    dirty,
    id,
    name,
    location,
    gradeSystem,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gyms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Gym> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('grade_system')) {
      context.handle(
        _gradeSystemMeta,
        gradeSystem.isAcceptableOrUnknown(
          data['grade_system']!,
          _gradeSystemMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gym map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gym(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      gradeSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GymsTable createAlias(String alias) {
    return $GymsTable(attachedDatabase, alias);
  }
}

class Gym extends DataClass implements Insertable<Gym> {
  final String syncId;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool dirty;
  final int id;
  final String name;
  final String? location;
  final String gradeSystem;
  final DateTime createdAt;
  const Gym({
    required this.syncId,
    required this.updatedAt,
    required this.isDeleted,
    required this.dirty,
    required this.id,
    required this.name,
    this.location,
    required this.gradeSystem,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['grade_system'] = Variable<String>(gradeSystem);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GymsCompanion toCompanion(bool nullToAbsent) {
    return GymsCompanion(
      syncId: Value(syncId),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      gradeSystem: Value(gradeSystem),
      createdAt: Value(createdAt),
    );
  }

  factory Gym.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gym(
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String?>(json['location']),
      gradeSystem: serializer.fromJson<String>(json['gradeSystem']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String?>(location),
      'gradeSystem': serializer.toJson<String>(gradeSystem),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Gym copyWith({
    String? syncId,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? dirty,
    int? id,
    String? name,
    Value<String?> location = const Value.absent(),
    String? gradeSystem,
    DateTime? createdAt,
  }) => Gym(
    syncId: syncId ?? this.syncId,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
    location: location.present ? location.value : this.location,
    gradeSystem: gradeSystem ?? this.gradeSystem,
    createdAt: createdAt ?? this.createdAt,
  );
  Gym copyWithCompanion(GymsCompanion data) {
    return Gym(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      gradeSystem: data.gradeSystem.present
          ? data.gradeSystem.value
          : this.gradeSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gym(')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('gradeSystem: $gradeSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    updatedAt,
    isDeleted,
    dirty,
    id,
    name,
    location,
    gradeSystem,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gym &&
          other.syncId == this.syncId &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.gradeSystem == this.gradeSystem &&
          other.createdAt == this.createdAt);
}

class GymsCompanion extends UpdateCompanion<Gym> {
  final Value<String> syncId;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> dirty;
  final Value<int> id;
  final Value<String> name;
  final Value<String?> location;
  final Value<String> gradeSystem;
  final Value<DateTime> createdAt;
  const GymsCompanion({
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.gradeSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  GymsCompanion.insert({
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    this.location = const Value.absent(),
    this.gradeSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Gym> custom({
    Expression<String>? syncId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? dirty,
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<String>? gradeSystem,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (gradeSystem != null) 'grade_system': gradeSystem,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  GymsCompanion copyWith({
    Value<String>? syncId,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? dirty,
    Value<int>? id,
    Value<String>? name,
    Value<String?>? location,
    Value<String>? gradeSystem,
    Value<DateTime>? createdAt,
  }) {
    return GymsCompanion(
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      gradeSystem: gradeSystem ?? this.gradeSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (gradeSystem.present) {
      map['grade_system'] = Variable<String>(gradeSystem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('gradeSystem: $gradeSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $WallTypesTable extends WallTypes
    with TableInfo<$WallTypesTable, WallType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WallTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    clientDefault: _uuid.v4,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    updatedAt,
    isDeleted,
    dirty,
    id,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wall_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<WallType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WallType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WallType(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $WallTypesTable createAlias(String alias) {
    return $WallTypesTable(attachedDatabase, alias);
  }
}

class WallType extends DataClass implements Insertable<WallType> {
  final String syncId;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool dirty;
  final int id;
  final String name;
  const WallType({
    required this.syncId,
    required this.updatedAt,
    required this.isDeleted,
    required this.dirty,
    required this.id,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  WallTypesCompanion toCompanion(bool nullToAbsent) {
    return WallTypesCompanion(
      syncId: Value(syncId),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      dirty: Value(dirty),
      id: Value(id),
      name: Value(name),
    );
  }

  factory WallType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WallType(
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  WallType copyWith({
    String? syncId,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? dirty,
    int? id,
    String? name,
  }) => WallType(
    syncId: syncId ?? this.syncId,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    name: name ?? this.name,
  );
  WallType copyWithCompanion(WallTypesCompanion data) {
    return WallType(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WallType(')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(syncId, updatedAt, isDeleted, dirty, id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WallType &&
          other.syncId == this.syncId &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.name == this.name);
}

class WallTypesCompanion extends UpdateCompanion<WallType> {
  final Value<String> syncId;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> dirty;
  final Value<int> id;
  final Value<String> name;
  const WallTypesCompanion({
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  WallTypesCompanion.insert({
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<WallType> custom({
    Expression<String>? syncId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? dirty,
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  WallTypesCompanion copyWith({
    Value<String>? syncId,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? dirty,
    Value<int>? id,
    Value<String>? name,
  }) {
    return WallTypesCompanion(
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WallTypesCompanion(')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ClimbsTable extends Climbs with TableInfo<$ClimbsTable, Climb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClimbsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    clientDefault: _uuid.v4,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _gymIdMeta = const VerificationMeta('gymId');
  @override
  late final GeneratedColumn<int> gymId = GeneratedColumn<int>(
    'gym_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gyms (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
    'grade',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wallTypeIdMeta = const VerificationMeta(
    'wallTypeId',
  );
  @override
  late final GeneratedColumn<int> wallTypeId = GeneratedColumn<int>(
    'wall_type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES wall_types (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isSentMeta = const VerificationMeta('isSent');
  @override
  late final GeneratedColumn<bool> isSent = GeneratedColumn<bool>(
    'is_sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_sent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    updatedAt,
    isDeleted,
    dirty,
    id,
    gymId,
    date,
    grade,
    wallTypeId,
    attempts,
    isSent,
    photoPath,
    memo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'climbs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Climb> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('gym_id')) {
      context.handle(
        _gymIdMeta,
        gymId.isAcceptableOrUnknown(data['gym_id']!, _gymIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gymIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
        _gradeMeta,
        grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('wall_type_id')) {
      context.handle(
        _wallTypeIdMeta,
        wallTypeId.isAcceptableOrUnknown(
          data['wall_type_id']!,
          _wallTypeIdMeta,
        ),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('is_sent')) {
      context.handle(
        _isSentMeta,
        isSent.isAcceptableOrUnknown(data['is_sent']!, _isSentMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Climb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Climb(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gymId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gym_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      grade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grade'],
      )!,
      wallTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wall_type_id'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      isSent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_sent'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClimbsTable createAlias(String alias) {
    return $ClimbsTable(attachedDatabase, alias);
  }
}

class Climb extends DataClass implements Insertable<Climb> {
  final String syncId;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool dirty;
  final int id;
  final int gymId;
  final DateTime date;
  final String grade;
  final int? wallTypeId;
  final int attempts;
  final bool isSent;
  final String? photoPath;
  final String? memo;
  final DateTime createdAt;
  const Climb({
    required this.syncId,
    required this.updatedAt,
    required this.isDeleted,
    required this.dirty,
    required this.id,
    required this.gymId,
    required this.date,
    required this.grade,
    this.wallTypeId,
    required this.attempts,
    required this.isSent,
    this.photoPath,
    this.memo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<int>(id);
    map['gym_id'] = Variable<int>(gymId);
    map['date'] = Variable<DateTime>(date);
    map['grade'] = Variable<String>(grade);
    if (!nullToAbsent || wallTypeId != null) {
      map['wall_type_id'] = Variable<int>(wallTypeId);
    }
    map['attempts'] = Variable<int>(attempts);
    map['is_sent'] = Variable<bool>(isSent);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClimbsCompanion toCompanion(bool nullToAbsent) {
    return ClimbsCompanion(
      syncId: Value(syncId),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      dirty: Value(dirty),
      id: Value(id),
      gymId: Value(gymId),
      date: Value(date),
      grade: Value(grade),
      wallTypeId: wallTypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(wallTypeId),
      attempts: Value(attempts),
      isSent: Value(isSent),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory Climb.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Climb(
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<int>(json['id']),
      gymId: serializer.fromJson<int>(json['gymId']),
      date: serializer.fromJson<DateTime>(json['date']),
      grade: serializer.fromJson<String>(json['grade']),
      wallTypeId: serializer.fromJson<int?>(json['wallTypeId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      isSent: serializer.fromJson<bool>(json['isSent']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<int>(id),
      'gymId': serializer.toJson<int>(gymId),
      'date': serializer.toJson<DateTime>(date),
      'grade': serializer.toJson<String>(grade),
      'wallTypeId': serializer.toJson<int?>(wallTypeId),
      'attempts': serializer.toJson<int>(attempts),
      'isSent': serializer.toJson<bool>(isSent),
      'photoPath': serializer.toJson<String?>(photoPath),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Climb copyWith({
    String? syncId,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? dirty,
    int? id,
    int? gymId,
    DateTime? date,
    String? grade,
    Value<int?> wallTypeId = const Value.absent(),
    int? attempts,
    bool? isSent,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
  }) => Climb(
    syncId: syncId ?? this.syncId,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    gymId: gymId ?? this.gymId,
    date: date ?? this.date,
    grade: grade ?? this.grade,
    wallTypeId: wallTypeId.present ? wallTypeId.value : this.wallTypeId,
    attempts: attempts ?? this.attempts,
    isSent: isSent ?? this.isSent,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
  );
  Climb copyWithCompanion(ClimbsCompanion data) {
    return Climb(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      gymId: data.gymId.present ? data.gymId.value : this.gymId,
      date: data.date.present ? data.date.value : this.date,
      grade: data.grade.present ? data.grade.value : this.grade,
      wallTypeId: data.wallTypeId.present
          ? data.wallTypeId.value
          : this.wallTypeId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      isSent: data.isSent.present ? data.isSent.value : this.isSent,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Climb(')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('gymId: $gymId, ')
          ..write('date: $date, ')
          ..write('grade: $grade, ')
          ..write('wallTypeId: $wallTypeId, ')
          ..write('attempts: $attempts, ')
          ..write('isSent: $isSent, ')
          ..write('photoPath: $photoPath, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    updatedAt,
    isDeleted,
    dirty,
    id,
    gymId,
    date,
    grade,
    wallTypeId,
    attempts,
    isSent,
    photoPath,
    memo,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Climb &&
          other.syncId == this.syncId &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.gymId == this.gymId &&
          other.date == this.date &&
          other.grade == this.grade &&
          other.wallTypeId == this.wallTypeId &&
          other.attempts == this.attempts &&
          other.isSent == this.isSent &&
          other.photoPath == this.photoPath &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class ClimbsCompanion extends UpdateCompanion<Climb> {
  final Value<String> syncId;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> dirty;
  final Value<int> id;
  final Value<int> gymId;
  final Value<DateTime> date;
  final Value<String> grade;
  final Value<int?> wallTypeId;
  final Value<int> attempts;
  final Value<bool> isSent;
  final Value<String?> photoPath;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  const ClimbsCompanion({
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.gymId = const Value.absent(),
    this.date = const Value.absent(),
    this.grade = const Value.absent(),
    this.wallTypeId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.isSent = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClimbsCompanion.insert({
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    required int gymId,
    required DateTime date,
    required String grade,
    this.wallTypeId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.isSent = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : gymId = Value(gymId),
       date = Value(date),
       grade = Value(grade);
  static Insertable<Climb> custom({
    Expression<String>? syncId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? dirty,
    Expression<int>? id,
    Expression<int>? gymId,
    Expression<DateTime>? date,
    Expression<String>? grade,
    Expression<int>? wallTypeId,
    Expression<int>? attempts,
    Expression<bool>? isSent,
    Expression<String>? photoPath,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (gymId != null) 'gym_id': gymId,
      if (date != null) 'date': date,
      if (grade != null) 'grade': grade,
      if (wallTypeId != null) 'wall_type_id': wallTypeId,
      if (attempts != null) 'attempts': attempts,
      if (isSent != null) 'is_sent': isSent,
      if (photoPath != null) 'photo_path': photoPath,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClimbsCompanion copyWith({
    Value<String>? syncId,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? dirty,
    Value<int>? id,
    Value<int>? gymId,
    Value<DateTime>? date,
    Value<String>? grade,
    Value<int?>? wallTypeId,
    Value<int>? attempts,
    Value<bool>? isSent,
    Value<String?>? photoPath,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
  }) {
    return ClimbsCompanion(
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      gymId: gymId ?? this.gymId,
      date: date ?? this.date,
      grade: grade ?? this.grade,
      wallTypeId: wallTypeId ?? this.wallTypeId,
      attempts: attempts ?? this.attempts,
      isSent: isSent ?? this.isSent,
      photoPath: photoPath ?? this.photoPath,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gymId.present) {
      map['gym_id'] = Variable<int>(gymId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (wallTypeId.present) {
      map['wall_type_id'] = Variable<int>(wallTypeId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (isSent.present) {
      map['is_sent'] = Variable<bool>(isSent.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClimbsCompanion(')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('gymId: $gymId, ')
          ..write('date: $date, ')
          ..write('grade: $grade, ')
          ..write('wallTypeId: $wallTypeId, ')
          ..write('attempts: $attempts, ')
          ..write('isSent: $isSent, ')
          ..write('photoPath: $photoPath, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ClimbPhotosTable extends ClimbPhotos
    with TableInfo<$ClimbPhotosTable, ClimbPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClimbPhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _syncIdMeta = const VerificationMeta('syncId');
  @override
  late final GeneratedColumn<String> syncId = GeneratedColumn<String>(
    'sync_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
    clientDefault: _uuid.v4,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _climbIdMeta = const VerificationMeta(
    'climbId',
  );
  @override
  late final GeneratedColumn<int> climbId = GeneratedColumn<int>(
    'climb_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES climbs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    syncId,
    updatedAt,
    isDeleted,
    dirty,
    id,
    climbId,
    path,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'climb_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClimbPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sync_id')) {
      context.handle(
        _syncIdMeta,
        syncId.isAcceptableOrUnknown(data['sync_id']!, _syncIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('climb_id')) {
      context.handle(
        _climbIdMeta,
        climbId.isAcceptableOrUnknown(data['climb_id']!, _climbIdMeta),
      );
    } else if (isInserting) {
      context.missing(_climbIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClimbPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClimbPhoto(
      syncId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_id'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      climbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}climb_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ClimbPhotosTable createAlias(String alias) {
    return $ClimbPhotosTable(attachedDatabase, alias);
  }
}

class ClimbPhoto extends DataClass implements Insertable<ClimbPhoto> {
  final String syncId;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool dirty;
  final int id;
  final int climbId;
  final String path;
  final int sortOrder;
  final DateTime createdAt;
  const ClimbPhoto({
    required this.syncId,
    required this.updatedAt,
    required this.isDeleted,
    required this.dirty,
    required this.id,
    required this.climbId,
    required this.path,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sync_id'] = Variable<String>(syncId);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['dirty'] = Variable<bool>(dirty);
    map['id'] = Variable<int>(id);
    map['climb_id'] = Variable<int>(climbId);
    map['path'] = Variable<String>(path);
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ClimbPhotosCompanion toCompanion(bool nullToAbsent) {
    return ClimbPhotosCompanion(
      syncId: Value(syncId),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      dirty: Value(dirty),
      id: Value(id),
      climbId: Value(climbId),
      path: Value(path),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory ClimbPhoto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClimbPhoto(
      syncId: serializer.fromJson<String>(json['syncId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      id: serializer.fromJson<int>(json['id']),
      climbId: serializer.fromJson<int>(json['climbId']),
      path: serializer.fromJson<String>(json['path']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'syncId': serializer.toJson<String>(syncId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'dirty': serializer.toJson<bool>(dirty),
      'id': serializer.toJson<int>(id),
      'climbId': serializer.toJson<int>(climbId),
      'path': serializer.toJson<String>(path),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ClimbPhoto copyWith({
    String? syncId,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? dirty,
    int? id,
    int? climbId,
    String? path,
    int? sortOrder,
    DateTime? createdAt,
  }) => ClimbPhoto(
    syncId: syncId ?? this.syncId,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    dirty: dirty ?? this.dirty,
    id: id ?? this.id,
    climbId: climbId ?? this.climbId,
    path: path ?? this.path,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  ClimbPhoto copyWithCompanion(ClimbPhotosCompanion data) {
    return ClimbPhoto(
      syncId: data.syncId.present ? data.syncId.value : this.syncId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      id: data.id.present ? data.id.value : this.id,
      climbId: data.climbId.present ? data.climbId.value : this.climbId,
      path: data.path.present ? data.path.value : this.path,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClimbPhoto(')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('climbId: $climbId, ')
          ..write('path: $path, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    syncId,
    updatedAt,
    isDeleted,
    dirty,
    id,
    climbId,
    path,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClimbPhoto &&
          other.syncId == this.syncId &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.dirty == this.dirty &&
          other.id == this.id &&
          other.climbId == this.climbId &&
          other.path == this.path &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class ClimbPhotosCompanion extends UpdateCompanion<ClimbPhoto> {
  final Value<String> syncId;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> dirty;
  final Value<int> id;
  final Value<int> climbId;
  final Value<String> path;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const ClimbPhotosCompanion({
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    this.climbId = const Value.absent(),
    this.path = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ClimbPhotosCompanion.insert({
    this.syncId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.dirty = const Value.absent(),
    this.id = const Value.absent(),
    required int climbId,
    required String path,
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : climbId = Value(climbId),
       path = Value(path);
  static Insertable<ClimbPhoto> custom({
    Expression<String>? syncId,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? dirty,
    Expression<int>? id,
    Expression<int>? climbId,
    Expression<String>? path,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (syncId != null) 'sync_id': syncId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (dirty != null) 'dirty': dirty,
      if (id != null) 'id': id,
      if (climbId != null) 'climb_id': climbId,
      if (path != null) 'path': path,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ClimbPhotosCompanion copyWith({
    Value<String>? syncId,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? dirty,
    Value<int>? id,
    Value<int>? climbId,
    Value<String>? path,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return ClimbPhotosCompanion(
      syncId: syncId ?? this.syncId,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      dirty: dirty ?? this.dirty,
      id: id ?? this.id,
      climbId: climbId ?? this.climbId,
      path: path ?? this.path,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (syncId.present) {
      map['sync_id'] = Variable<String>(syncId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (climbId.present) {
      map['climb_id'] = Variable<int>(climbId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClimbPhotosCompanion(')
          ..write('syncId: $syncId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('dirty: $dirty, ')
          ..write('id: $id, ')
          ..write('climbId: $climbId, ')
          ..write('path: $path, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GymsTable gyms = $GymsTable(this);
  late final $WallTypesTable wallTypes = $WallTypesTable(this);
  late final $ClimbsTable climbs = $ClimbsTable(this);
  late final $ClimbPhotosTable climbPhotos = $ClimbPhotosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gyms,
    wallTypes,
    climbs,
    climbPhotos,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'gyms',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('climbs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'wall_types',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('climbs', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'climbs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('climb_photos', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GymsTableCreateCompanionBuilder =
    GymsCompanion Function({
      Value<String> syncId,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> dirty,
      Value<int> id,
      required String name,
      Value<String?> location,
      Value<String> gradeSystem,
      Value<DateTime> createdAt,
    });
typedef $$GymsTableUpdateCompanionBuilder =
    GymsCompanion Function({
      Value<String> syncId,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> dirty,
      Value<int> id,
      Value<String> name,
      Value<String?> location,
      Value<String> gradeSystem,
      Value<DateTime> createdAt,
    });

final class $$GymsTableReferences
    extends BaseReferences<_$AppDatabase, $GymsTable, Gym> {
  $$GymsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClimbsTable, List<Climb>> _climbsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.climbs,
    aliasName: 'gyms__id__climbs__gym_id',
  );

  $$ClimbsTableProcessedTableManager get climbsRefs {
    final manager = $$ClimbsTableTableManager(
      $_db,
      $_db.climbs,
    ).filter((f) => f.gymId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_climbsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GymsTableFilterComposer extends Composer<_$AppDatabase, $GymsTable> {
  $$GymsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gradeSystem => $composableBuilder(
    column: $table.gradeSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> climbsRefs(
    Expression<bool> Function($$ClimbsTableFilterComposer f) f,
  ) {
    final $$ClimbsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.climbs,
      getReferencedColumn: (t) => t.gymId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClimbsTableFilterComposer(
            $db: $db,
            $table: $db.climbs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GymsTableOrderingComposer extends Composer<_$AppDatabase, $GymsTable> {
  $$GymsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gradeSystem => $composableBuilder(
    column: $table.gradeSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GymsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymsTable> {
  $$GymsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get gradeSystem => $composableBuilder(
    column: $table.gradeSystem,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> climbsRefs<T extends Object>(
    Expression<T> Function($$ClimbsTableAnnotationComposer a) f,
  ) {
    final $$ClimbsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.climbs,
      getReferencedColumn: (t) => t.gymId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClimbsTableAnnotationComposer(
            $db: $db,
            $table: $db.climbs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GymsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GymsTable,
          Gym,
          $$GymsTableFilterComposer,
          $$GymsTableOrderingComposer,
          $$GymsTableAnnotationComposer,
          $$GymsTableCreateCompanionBuilder,
          $$GymsTableUpdateCompanionBuilder,
          (Gym, $$GymsTableReferences),
          Gym,
          PrefetchHooks Function({bool climbsRefs})
        > {
  $$GymsTableTableManager(_$AppDatabase db, $GymsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> gradeSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GymsCompanion(
                syncId: syncId,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                dirty: dirty,
                id: id,
                name: name,
                location: location,
                gradeSystem: gradeSystem,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> location = const Value.absent(),
                Value<String> gradeSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => GymsCompanion.insert(
                syncId: syncId,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                dirty: dirty,
                id: id,
                name: name,
                location: location,
                gradeSystem: gradeSystem,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GymsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({climbsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (climbsRefs) db.climbs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (climbsRefs)
                    await $_getPrefetchedData<Gym, $GymsTable, Climb>(
                      currentTable: table,
                      referencedTable: $$GymsTableReferences._climbsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$GymsTableReferences(db, table, p0).climbsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.gymId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$GymsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GymsTable,
      Gym,
      $$GymsTableFilterComposer,
      $$GymsTableOrderingComposer,
      $$GymsTableAnnotationComposer,
      $$GymsTableCreateCompanionBuilder,
      $$GymsTableUpdateCompanionBuilder,
      (Gym, $$GymsTableReferences),
      Gym,
      PrefetchHooks Function({bool climbsRefs})
    >;
typedef $$WallTypesTableCreateCompanionBuilder =
    WallTypesCompanion Function({
      Value<String> syncId,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> dirty,
      Value<int> id,
      required String name,
    });
typedef $$WallTypesTableUpdateCompanionBuilder =
    WallTypesCompanion Function({
      Value<String> syncId,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> dirty,
      Value<int> id,
      Value<String> name,
    });

final class $$WallTypesTableReferences
    extends BaseReferences<_$AppDatabase, $WallTypesTable, WallType> {
  $$WallTypesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ClimbsTable, List<Climb>> _climbsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.climbs,
    aliasName: 'wall_types__id__climbs__wall_type_id',
  );

  $$ClimbsTableProcessedTableManager get climbsRefs {
    final manager = $$ClimbsTableTableManager(
      $_db,
      $_db.climbs,
    ).filter((f) => f.wallTypeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_climbsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WallTypesTableFilterComposer
    extends Composer<_$AppDatabase, $WallTypesTable> {
  $$WallTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> climbsRefs(
    Expression<bool> Function($$ClimbsTableFilterComposer f) f,
  ) {
    final $$ClimbsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.climbs,
      getReferencedColumn: (t) => t.wallTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClimbsTableFilterComposer(
            $db: $db,
            $table: $db.climbs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WallTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $WallTypesTable> {
  $$WallTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WallTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WallTypesTable> {
  $$WallTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> climbsRefs<T extends Object>(
    Expression<T> Function($$ClimbsTableAnnotationComposer a) f,
  ) {
    final $$ClimbsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.climbs,
      getReferencedColumn: (t) => t.wallTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClimbsTableAnnotationComposer(
            $db: $db,
            $table: $db.climbs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WallTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WallTypesTable,
          WallType,
          $$WallTypesTableFilterComposer,
          $$WallTypesTableOrderingComposer,
          $$WallTypesTableAnnotationComposer,
          $$WallTypesTableCreateCompanionBuilder,
          $$WallTypesTableUpdateCompanionBuilder,
          (WallType, $$WallTypesTableReferences),
          WallType,
          PrefetchHooks Function({bool climbsRefs})
        > {
  $$WallTypesTableTableManager(_$AppDatabase db, $WallTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WallTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WallTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WallTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => WallTypesCompanion(
                syncId: syncId,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                dirty: dirty,
                id: id,
                name: name,
              ),
          createCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String name,
              }) => WallTypesCompanion.insert(
                syncId: syncId,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                dirty: dirty,
                id: id,
                name: name,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WallTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({climbsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (climbsRefs) db.climbs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (climbsRefs)
                    await $_getPrefetchedData<WallType, $WallTypesTable, Climb>(
                      currentTable: table,
                      referencedTable: $$WallTypesTableReferences
                          ._climbsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WallTypesTableReferences(db, table, p0).climbsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.wallTypeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WallTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WallTypesTable,
      WallType,
      $$WallTypesTableFilterComposer,
      $$WallTypesTableOrderingComposer,
      $$WallTypesTableAnnotationComposer,
      $$WallTypesTableCreateCompanionBuilder,
      $$WallTypesTableUpdateCompanionBuilder,
      (WallType, $$WallTypesTableReferences),
      WallType,
      PrefetchHooks Function({bool climbsRefs})
    >;
typedef $$ClimbsTableCreateCompanionBuilder =
    ClimbsCompanion Function({
      Value<String> syncId,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> dirty,
      Value<int> id,
      required int gymId,
      required DateTime date,
      required String grade,
      Value<int?> wallTypeId,
      Value<int> attempts,
      Value<bool> isSent,
      Value<String?> photoPath,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });
typedef $$ClimbsTableUpdateCompanionBuilder =
    ClimbsCompanion Function({
      Value<String> syncId,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> dirty,
      Value<int> id,
      Value<int> gymId,
      Value<DateTime> date,
      Value<String> grade,
      Value<int?> wallTypeId,
      Value<int> attempts,
      Value<bool> isSent,
      Value<String?> photoPath,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });

final class $$ClimbsTableReferences
    extends BaseReferences<_$AppDatabase, $ClimbsTable, Climb> {
  $$ClimbsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GymsTable _gymIdTable(_$AppDatabase db) =>
      db.gyms.createAlias('climbs__gym_id__gyms__id');

  $$GymsTableProcessedTableManager get gymId {
    final $_column = $_itemColumn<int>('gym_id')!;

    final manager = $$GymsTableTableManager(
      $_db,
      $_db.gyms,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gymIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WallTypesTable _wallTypeIdTable(_$AppDatabase db) =>
      db.wallTypes.createAlias('climbs__wall_type_id__wall_types__id');

  $$WallTypesTableProcessedTableManager? get wallTypeId {
    final $_column = $_itemColumn<int>('wall_type_id');
    if ($_column == null) return null;
    final manager = $$WallTypesTableTableManager(
      $_db,
      $_db.wallTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_wallTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ClimbPhotosTable, List<ClimbPhoto>>
  _climbPhotosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.climbPhotos,
    aliasName: 'climbs__id__climb_photos__climb_id',
  );

  $$ClimbPhotosTableProcessedTableManager get climbPhotosRefs {
    final manager = $$ClimbPhotosTableTableManager(
      $_db,
      $_db.climbPhotos,
    ).filter((f) => f.climbId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_climbPhotosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClimbsTableFilterComposer
    extends Composer<_$AppDatabase, $ClimbsTable> {
  $$ClimbsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSent => $composableBuilder(
    column: $table.isSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GymsTableFilterComposer get gymId {
    final $$GymsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymId,
      referencedTable: $db.gyms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymsTableFilterComposer(
            $db: $db,
            $table: $db.gyms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WallTypesTableFilterComposer get wallTypeId {
    final $$WallTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wallTypeId,
      referencedTable: $db.wallTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WallTypesTableFilterComposer(
            $db: $db,
            $table: $db.wallTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> climbPhotosRefs(
    Expression<bool> Function($$ClimbPhotosTableFilterComposer f) f,
  ) {
    final $$ClimbPhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.climbPhotos,
      getReferencedColumn: (t) => t.climbId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClimbPhotosTableFilterComposer(
            $db: $db,
            $table: $db.climbPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClimbsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClimbsTable> {
  $$ClimbsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grade => $composableBuilder(
    column: $table.grade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSent => $composableBuilder(
    column: $table.isSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GymsTableOrderingComposer get gymId {
    final $$GymsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymId,
      referencedTable: $db.gyms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymsTableOrderingComposer(
            $db: $db,
            $table: $db.gyms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WallTypesTableOrderingComposer get wallTypeId {
    final $$WallTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wallTypeId,
      referencedTable: $db.wallTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WallTypesTableOrderingComposer(
            $db: $db,
            $table: $db.wallTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClimbsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClimbsTable> {
  $$ClimbsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<bool> get isSent =>
      $composableBuilder(column: $table.isSent, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GymsTableAnnotationComposer get gymId {
    final $$GymsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymId,
      referencedTable: $db.gyms,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymsTableAnnotationComposer(
            $db: $db,
            $table: $db.gyms,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WallTypesTableAnnotationComposer get wallTypeId {
    final $$WallTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.wallTypeId,
      referencedTable: $db.wallTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WallTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.wallTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> climbPhotosRefs<T extends Object>(
    Expression<T> Function($$ClimbPhotosTableAnnotationComposer a) f,
  ) {
    final $$ClimbPhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.climbPhotos,
      getReferencedColumn: (t) => t.climbId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClimbPhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.climbPhotos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClimbsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClimbsTable,
          Climb,
          $$ClimbsTableFilterComposer,
          $$ClimbsTableOrderingComposer,
          $$ClimbsTableAnnotationComposer,
          $$ClimbsTableCreateCompanionBuilder,
          $$ClimbsTableUpdateCompanionBuilder,
          (Climb, $$ClimbsTableReferences),
          Climb,
          PrefetchHooks Function({
            bool gymId,
            bool wallTypeId,
            bool climbPhotosRefs,
          })
        > {
  $$ClimbsTableTableManager(_$AppDatabase db, $ClimbsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClimbsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClimbsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClimbsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> gymId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> grade = const Value.absent(),
                Value<int?> wallTypeId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<bool> isSent = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClimbsCompanion(
                syncId: syncId,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                dirty: dirty,
                id: id,
                gymId: gymId,
                date: date,
                grade: grade,
                wallTypeId: wallTypeId,
                attempts: attempts,
                isSent: isSent,
                photoPath: photoPath,
                memo: memo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int gymId,
                required DateTime date,
                required String grade,
                Value<int?> wallTypeId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<bool> isSent = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClimbsCompanion.insert(
                syncId: syncId,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                dirty: dirty,
                id: id,
                gymId: gymId,
                date: date,
                grade: grade,
                wallTypeId: wallTypeId,
                attempts: attempts,
                isSent: isSent,
                photoPath: photoPath,
                memo: memo,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ClimbsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({gymId = false, wallTypeId = false, climbPhotosRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (climbPhotosRefs) db.climbPhotos,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (gymId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gymId,
                                    referencedTable: $$ClimbsTableReferences
                                        ._gymIdTable(db),
                                    referencedColumn: $$ClimbsTableReferences
                                        ._gymIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (wallTypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.wallTypeId,
                                    referencedTable: $$ClimbsTableReferences
                                        ._wallTypeIdTable(db),
                                    referencedColumn: $$ClimbsTableReferences
                                        ._wallTypeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (climbPhotosRefs)
                        await $_getPrefetchedData<
                          Climb,
                          $ClimbsTable,
                          ClimbPhoto
                        >(
                          currentTable: table,
                          referencedTable: $$ClimbsTableReferences
                              ._climbPhotosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ClimbsTableReferences(
                                db,
                                table,
                                p0,
                              ).climbPhotosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.climbId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ClimbsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClimbsTable,
      Climb,
      $$ClimbsTableFilterComposer,
      $$ClimbsTableOrderingComposer,
      $$ClimbsTableAnnotationComposer,
      $$ClimbsTableCreateCompanionBuilder,
      $$ClimbsTableUpdateCompanionBuilder,
      (Climb, $$ClimbsTableReferences),
      Climb,
      PrefetchHooks Function({
        bool gymId,
        bool wallTypeId,
        bool climbPhotosRefs,
      })
    >;
typedef $$ClimbPhotosTableCreateCompanionBuilder =
    ClimbPhotosCompanion Function({
      Value<String> syncId,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> dirty,
      Value<int> id,
      required int climbId,
      required String path,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });
typedef $$ClimbPhotosTableUpdateCompanionBuilder =
    ClimbPhotosCompanion Function({
      Value<String> syncId,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> dirty,
      Value<int> id,
      Value<int> climbId,
      Value<String> path,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
    });

final class $$ClimbPhotosTableReferences
    extends BaseReferences<_$AppDatabase, $ClimbPhotosTable, ClimbPhoto> {
  $$ClimbPhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClimbsTable _climbIdTable(_$AppDatabase db) =>
      db.climbs.createAlias('climb_photos__climb_id__climbs__id');

  $$ClimbsTableProcessedTableManager get climbId {
    final $_column = $_itemColumn<int>('climb_id')!;

    final manager = $$ClimbsTableTableManager(
      $_db,
      $_db.climbs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_climbIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ClimbPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $ClimbPhotosTable> {
  $$ClimbPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ClimbsTableFilterComposer get climbId {
    final $$ClimbsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.climbId,
      referencedTable: $db.climbs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClimbsTableFilterComposer(
            $db: $db,
            $table: $db.climbs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClimbPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $ClimbPhotosTable> {
  $$ClimbPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get syncId => $composableBuilder(
    column: $table.syncId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClimbsTableOrderingComposer get climbId {
    final $$ClimbsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.climbId,
      referencedTable: $db.climbs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClimbsTableOrderingComposer(
            $db: $db,
            $table: $db.climbs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClimbPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClimbPhotosTable> {
  $$ClimbPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get syncId =>
      $composableBuilder(column: $table.syncId, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ClimbsTableAnnotationComposer get climbId {
    final $$ClimbsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.climbId,
      referencedTable: $db.climbs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClimbsTableAnnotationComposer(
            $db: $db,
            $table: $db.climbs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ClimbPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClimbPhotosTable,
          ClimbPhoto,
          $$ClimbPhotosTableFilterComposer,
          $$ClimbPhotosTableOrderingComposer,
          $$ClimbPhotosTableAnnotationComposer,
          $$ClimbPhotosTableCreateCompanionBuilder,
          $$ClimbPhotosTableUpdateCompanionBuilder,
          (ClimbPhoto, $$ClimbPhotosTableReferences),
          ClimbPhoto,
          PrefetchHooks Function({bool climbId})
        > {
  $$ClimbPhotosTableTableManager(_$AppDatabase db, $ClimbPhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClimbPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClimbPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClimbPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> climbId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClimbPhotosCompanion(
                syncId: syncId,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                dirty: dirty,
                id: id,
                climbId: climbId,
                path: path,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<String> syncId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int climbId,
                required String path,
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ClimbPhotosCompanion.insert(
                syncId: syncId,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                dirty: dirty,
                id: id,
                climbId: climbId,
                path: path,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClimbPhotosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({climbId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (climbId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.climbId,
                                referencedTable: $$ClimbPhotosTableReferences
                                    ._climbIdTable(db),
                                referencedColumn: $$ClimbPhotosTableReferences
                                    ._climbIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ClimbPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClimbPhotosTable,
      ClimbPhoto,
      $$ClimbPhotosTableFilterComposer,
      $$ClimbPhotosTableOrderingComposer,
      $$ClimbPhotosTableAnnotationComposer,
      $$ClimbPhotosTableCreateCompanionBuilder,
      $$ClimbPhotosTableUpdateCompanionBuilder,
      (ClimbPhoto, $$ClimbPhotosTableReferences),
      ClimbPhoto,
      PrefetchHooks Function({bool climbId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GymsTableTableManager get gyms => $$GymsTableTableManager(_db, _db.gyms);
  $$WallTypesTableTableManager get wallTypes =>
      $$WallTypesTableTableManager(_db, _db.wallTypes);
  $$ClimbsTableTableManager get climbs =>
      $$ClimbsTableTableManager(_db, _db.climbs);
  $$ClimbPhotosTableTableManager get climbPhotos =>
      $$ClimbPhotosTableTableManager(_db, _db.climbPhotos);
}
