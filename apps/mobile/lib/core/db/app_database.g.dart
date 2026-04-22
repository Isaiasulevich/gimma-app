// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, ExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerUserIdMeta = const VerificationMeta(
    'ownerUserId',
  );
  @override
  late final GeneratedColumn<String> ownerUserId = GeneratedColumn<String>(
    'owner_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceRefMeta = const VerificationMeta(
    'sourceRef',
  );
  @override
  late final GeneratedColumn<String> sourceRef = GeneratedColumn<String>(
    'source_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _photoUrlMeta = const VerificationMeta(
    'photoUrl',
  );
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
    'photo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPhotoPathMeta = const VerificationMeta(
    'localPhotoPath',
  );
  @override
  late final GeneratedColumn<String> localPhotoPath = GeneratedColumn<String>(
    'local_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _primaryMuscleMeta = const VerificationMeta(
    'primaryMuscle',
  );
  @override
  late final GeneratedColumn<String> primaryMuscle = GeneratedColumn<String>(
    'primary_muscle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String>
  secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<List<String>>($ExercisesTable.$convertersecondaryMuscles);
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUnilateralMeta = const VerificationMeta(
    'isUnilateral',
  );
  @override
  late final GeneratedColumn<bool> isUnilateral = GeneratedColumn<bool>(
    'is_unilateral',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unilateral" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    clientDefault: () => DateTime.now().toUtc(),
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
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerUserId,
    source,
    sourceRef,
    name,
    description,
    photoUrl,
    localPhotoPath,
    primaryMuscle,
    secondaryMuscles,
    equipment,
    isUnilateral,
    isArchived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_user_id')) {
      context.handle(
        _ownerUserIdMeta,
        ownerUserId.isAcceptableOrUnknown(
          data['owner_user_id']!,
          _ownerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_ref')) {
      context.handle(
        _sourceRefMeta,
        sourceRef.isAcceptableOrUnknown(data['source_ref']!, _sourceRefMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('photo_url')) {
      context.handle(
        _photoUrlMeta,
        photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta),
      );
    }
    if (data.containsKey('local_photo_path')) {
      context.handle(
        _localPhotoPathMeta,
        localPhotoPath.isAcceptableOrUnknown(
          data['local_photo_path']!,
          _localPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('primary_muscle')) {
      context.handle(
        _primaryMuscleMeta,
        primaryMuscle.isAcceptableOrUnknown(
          data['primary_muscle']!,
          _primaryMuscleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryMuscleMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('is_unilateral')) {
      context.handle(
        _isUnilateralMeta,
        isUnilateral.isAcceptableOrUnknown(
          data['is_unilateral']!,
          _isUnilateralMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_user_id'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ref'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      photoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_url'],
      ),
      localPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_photo_path'],
      ),
      primaryMuscle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_muscle'],
      )!,
      secondaryMuscles: $ExercisesTable.$convertersecondaryMuscles.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}secondary_muscles'],
        )!,
      ),
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      isUnilateral: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unilateral'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertersecondaryMuscles =
      const StringListConverter();
}

class ExerciseRow extends DataClass implements Insertable<ExerciseRow> {
  final String id;
  final String? ownerUserId;
  final String source;
  final String? sourceRef;
  final String name;
  final String description;
  final String? photoUrl;
  final String? localPhotoPath;
  final String primaryMuscle;
  final List<String> secondaryMuscles;
  final String equipment;
  final bool isUnilateral;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ExerciseRow({
    required this.id,
    this.ownerUserId,
    required this.source,
    this.sourceRef,
    required this.name,
    required this.description,
    this.photoUrl,
    this.localPhotoPath,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.isUnilateral,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || ownerUserId != null) {
      map['owner_user_id'] = Variable<String>(ownerUserId);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || sourceRef != null) {
      map['source_ref'] = Variable<String>(sourceRef);
    }
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || localPhotoPath != null) {
      map['local_photo_path'] = Variable<String>(localPhotoPath);
    }
    map['primary_muscle'] = Variable<String>(primaryMuscle);
    {
      map['secondary_muscles'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscles.toSql(secondaryMuscles),
      );
    }
    map['equipment'] = Variable<String>(equipment);
    map['is_unilateral'] = Variable<bool>(isUnilateral);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      ownerUserId: ownerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerUserId),
      source: Value(source),
      sourceRef: sourceRef == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceRef),
      name: Value(name),
      description: Value(description),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      localPhotoPath: localPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localPhotoPath),
      primaryMuscle: Value(primaryMuscle),
      secondaryMuscles: Value(secondaryMuscles),
      equipment: Value(equipment),
      isUnilateral: Value(isUnilateral),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      ownerUserId: serializer.fromJson<String?>(json['ownerUserId']),
      source: serializer.fromJson<String>(json['source']),
      sourceRef: serializer.fromJson<String?>(json['sourceRef']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      localPhotoPath: serializer.fromJson<String?>(json['localPhotoPath']),
      primaryMuscle: serializer.fromJson<String>(json['primaryMuscle']),
      secondaryMuscles: serializer.fromJson<List<String>>(
        json['secondaryMuscles'],
      ),
      equipment: serializer.fromJson<String>(json['equipment']),
      isUnilateral: serializer.fromJson<bool>(json['isUnilateral']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerUserId': serializer.toJson<String?>(ownerUserId),
      'source': serializer.toJson<String>(source),
      'sourceRef': serializer.toJson<String?>(sourceRef),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'localPhotoPath': serializer.toJson<String?>(localPhotoPath),
      'primaryMuscle': serializer.toJson<String>(primaryMuscle),
      'secondaryMuscles': serializer.toJson<List<String>>(secondaryMuscles),
      'equipment': serializer.toJson<String>(equipment),
      'isUnilateral': serializer.toJson<bool>(isUnilateral),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ExerciseRow copyWith({
    String? id,
    Value<String?> ownerUserId = const Value.absent(),
    String? source,
    Value<String?> sourceRef = const Value.absent(),
    String? name,
    String? description,
    Value<String?> photoUrl = const Value.absent(),
    Value<String?> localPhotoPath = const Value.absent(),
    String? primaryMuscle,
    List<String>? secondaryMuscles,
    String? equipment,
    bool? isUnilateral,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ExerciseRow(
    id: id ?? this.id,
    ownerUserId: ownerUserId.present ? ownerUserId.value : this.ownerUserId,
    source: source ?? this.source,
    sourceRef: sourceRef.present ? sourceRef.value : this.sourceRef,
    name: name ?? this.name,
    description: description ?? this.description,
    photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
    localPhotoPath: localPhotoPath.present
        ? localPhotoPath.value
        : this.localPhotoPath,
    primaryMuscle: primaryMuscle ?? this.primaryMuscle,
    secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    equipment: equipment ?? this.equipment,
    isUnilateral: isUnilateral ?? this.isUnilateral,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return ExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      ownerUserId: data.ownerUserId.present
          ? data.ownerUserId.value
          : this.ownerUserId,
      source: data.source.present ? data.source.value : this.source,
      sourceRef: data.sourceRef.present ? data.sourceRef.value : this.sourceRef,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      localPhotoPath: data.localPhotoPath.present
          ? data.localPhotoPath.value
          : this.localPhotoPath,
      primaryMuscle: data.primaryMuscle.present
          ? data.primaryMuscle.value
          : this.primaryMuscle,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      isUnilateral: data.isUnilateral.present
          ? data.isUnilateral.value
          : this.isUnilateral,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRow(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('localPhotoPath: $localPhotoPath, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('equipment: $equipment, ')
          ..write('isUnilateral: $isUnilateral, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerUserId,
    source,
    sourceRef,
    name,
    description,
    photoUrl,
    localPhotoPath,
    primaryMuscle,
    secondaryMuscles,
    equipment,
    isUnilateral,
    isArchived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRow &&
          other.id == this.id &&
          other.ownerUserId == this.ownerUserId &&
          other.source == this.source &&
          other.sourceRef == this.sourceRef &&
          other.name == this.name &&
          other.description == this.description &&
          other.photoUrl == this.photoUrl &&
          other.localPhotoPath == this.localPhotoPath &&
          other.primaryMuscle == this.primaryMuscle &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.equipment == this.equipment &&
          other.isUnilateral == this.isUnilateral &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseRow> {
  final Value<String> id;
  final Value<String?> ownerUserId;
  final Value<String> source;
  final Value<String?> sourceRef;
  final Value<String> name;
  final Value<String> description;
  final Value<String?> photoUrl;
  final Value<String?> localPhotoPath;
  final Value<String> primaryMuscle;
  final Value<List<String>> secondaryMuscles;
  final Value<String> equipment;
  final Value<bool> isUnilateral;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.ownerUserId = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceRef = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    this.primaryMuscle = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.equipment = const Value.absent(),
    this.isUnilateral = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    this.ownerUserId = const Value.absent(),
    required String source,
    this.sourceRef = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.localPhotoPath = const Value.absent(),
    required String primaryMuscle,
    required List<String> secondaryMuscles,
    required String equipment,
    this.isUnilateral = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       source = Value(source),
       name = Value(name),
       primaryMuscle = Value(primaryMuscle),
       secondaryMuscles = Value(secondaryMuscles),
       equipment = Value(equipment);
  static Insertable<ExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? ownerUserId,
    Expression<String>? source,
    Expression<String>? sourceRef,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? photoUrl,
    Expression<String>? localPhotoPath,
    Expression<String>? primaryMuscle,
    Expression<String>? secondaryMuscles,
    Expression<String>? equipment,
    Expression<bool>? isUnilateral,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerUserId != null) 'owner_user_id': ownerUserId,
      if (source != null) 'source': source,
      if (sourceRef != null) 'source_ref': sourceRef,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (localPhotoPath != null) 'local_photo_path': localPhotoPath,
      if (primaryMuscle != null) 'primary_muscle': primaryMuscle,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (equipment != null) 'equipment': equipment,
      if (isUnilateral != null) 'is_unilateral': isUnilateral,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String?>? ownerUserId,
    Value<String>? source,
    Value<String?>? sourceRef,
    Value<String>? name,
    Value<String>? description,
    Value<String?>? photoUrl,
    Value<String?>? localPhotoPath,
    Value<String>? primaryMuscle,
    Value<List<String>>? secondaryMuscles,
    Value<String>? equipment,
    Value<bool>? isUnilateral,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      source: source ?? this.source,
      sourceRef: sourceRef ?? this.sourceRef,
      name: name ?? this.name,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      equipment: equipment ?? this.equipment,
      isUnilateral: isUnilateral ?? this.isUnilateral,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerUserId.present) {
      map['owner_user_id'] = Variable<String>(ownerUserId.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceRef.present) {
      map['source_ref'] = Variable<String>(sourceRef.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (localPhotoPath.present) {
      map['local_photo_path'] = Variable<String>(localPhotoPath.value);
    }
    if (primaryMuscle.present) {
      map['primary_muscle'] = Variable<String>(primaryMuscle.value);
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscles.toSql(
          secondaryMuscles.value,
        ),
      );
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (isUnilateral.present) {
      map['is_unilateral'] = Variable<bool>(isUnilateral.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('ownerUserId: $ownerUserId, ')
          ..write('source: $source, ')
          ..write('sourceRef: $sourceRef, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('localPhotoPath: $localPhotoPath, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('equipment: $equipment, ')
          ..write('isUnilateral: $isUnilateral, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataTable extends SyncMetadata
    with TableInfo<$SyncMetadataTable, SyncMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _queuedAtMeta = const VerificationMeta(
    'queuedAt',
  );
  @override
  late final GeneratedColumn<DateTime> queuedAt = GeneratedColumn<DateTime>(
    'queued_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entityTable,
    operation,
    queuedAt,
    attemptCount,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('queued_at')) {
      context.handle(
        _queuedAtMeta,
        queuedAt.isAcceptableOrUnknown(data['queued_at']!, _queuedAtMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id, entityTable};
  @override
  SyncMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      queuedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}queued_at'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $SyncMetadataTable createAlias(String alias) {
    return $SyncMetadataTable(attachedDatabase, alias);
  }
}

class SyncMetadataRow extends DataClass implements Insertable<SyncMetadataRow> {
  final String id;
  final String entityTable;
  final String operation;
  final DateTime queuedAt;
  final int attemptCount;
  final String? lastError;
  const SyncMetadataRow({
    required this.id,
    required this.entityTable,
    required this.operation,
    required this.queuedAt,
    required this.attemptCount,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['operation'] = Variable<String>(operation);
    map['queued_at'] = Variable<DateTime>(queuedAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncMetadataCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      operation: Value(operation),
      queuedAt: Value(queuedAt),
      attemptCount: Value(attemptCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataRow(
      id: serializer.fromJson<String>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      operation: serializer.fromJson<String>(json['operation']),
      queuedAt: serializer.fromJson<DateTime>(json['queuedAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'operation': serializer.toJson<String>(operation),
      'queuedAt': serializer.toJson<DateTime>(queuedAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncMetadataRow copyWith({
    String? id,
    String? entityTable,
    String? operation,
    DateTime? queuedAt,
    int? attemptCount,
    Value<String?> lastError = const Value.absent(),
  }) => SyncMetadataRow(
    id: id ?? this.id,
    entityTable: entityTable ?? this.entityTable,
    operation: operation ?? this.operation,
    queuedAt: queuedAt ?? this.queuedAt,
    attemptCount: attemptCount ?? this.attemptCount,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  SyncMetadataRow copyWithCompanion(SyncMetadataCompanion data) {
    return SyncMetadataRow(
      id: data.id.present ? data.id.value : this.id,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      operation: data.operation.present ? data.operation.value : this.operation,
      queuedAt: data.queuedAt.present ? data.queuedAt.value : this.queuedAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataRow(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('operation: $operation, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entityTable,
    operation,
    queuedAt,
    attemptCount,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataRow &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.operation == this.operation &&
          other.queuedAt == this.queuedAt &&
          other.attemptCount == this.attemptCount &&
          other.lastError == this.lastError);
}

class SyncMetadataCompanion extends UpdateCompanion<SyncMetadataRow> {
  final Value<String> id;
  final Value<String> entityTable;
  final Value<String> operation;
  final Value<DateTime> queuedAt;
  final Value<int> attemptCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncMetadataCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.operation = const Value.absent(),
    this.queuedAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataCompanion.insert({
    required String id,
    required String entityTable,
    required String operation,
    this.queuedAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       entityTable = Value(entityTable),
       operation = Value(operation);
  static Insertable<SyncMetadataRow> custom({
    Expression<String>? id,
    Expression<String>? entityTable,
    Expression<String>? operation,
    Expression<DateTime>? queuedAt,
    Expression<int>? attemptCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (operation != null) 'operation': operation,
      if (queuedAt != null) 'queued_at': queuedAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataCompanion copyWith({
    Value<String>? id,
    Value<String>? entityTable,
    Value<String>? operation,
    Value<DateTime>? queuedAt,
    Value<int>? attemptCount,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return SyncMetadataCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      operation: operation ?? this.operation,
      queuedAt: queuedAt ?? this.queuedAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (queuedAt.present) {
      map['queued_at'] = Variable<DateTime>(queuedAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('operation: $operation, ')
          ..write('queuedAt: $queuedAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlansTable extends Plans with TableInfo<$PlansTable, PlanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<String> packId = GeneratedColumn<String>(
    'pack_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _splitTypeMeta = const VerificationMeta(
    'splitType',
  );
  @override
  late final GeneratedColumn<String> splitType = GeneratedColumn<String>(
    'split_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _daysPerWeekMeta = const VerificationMeta(
    'daysPerWeek',
  );
  @override
  late final GeneratedColumn<int> daysPerWeek = GeneratedColumn<int>(
    'days_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedByAiMeta = const VerificationMeta(
    'generatedByAi',
  );
  @override
  late final GeneratedColumn<bool> generatedByAi = GeneratedColumn<bool>(
    'generated_by_ai',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("generated_by_ai" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _aiReasoningMeta = const VerificationMeta(
    'aiReasoning',
  );
  @override
  late final GeneratedColumn<String> aiReasoning = GeneratedColumn<String>(
    'ai_reasoning',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    clientDefault: () => DateTime.now().toUtc(),
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
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    goal,
    packId,
    splitType,
    daysPerWeek,
    generatedByAi,
    aiReasoning,
    isActive,
    startedAt,
    endedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    }
    if (data.containsKey('split_type')) {
      context.handle(
        _splitTypeMeta,
        splitType.isAcceptableOrUnknown(data['split_type']!, _splitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_splitTypeMeta);
    }
    if (data.containsKey('days_per_week')) {
      context.handle(
        _daysPerWeekMeta,
        daysPerWeek.isAcceptableOrUnknown(
          data['days_per_week']!,
          _daysPerWeekMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_daysPerWeekMeta);
    }
    if (data.containsKey('generated_by_ai')) {
      context.handle(
        _generatedByAiMeta,
        generatedByAi.isAcceptableOrUnknown(
          data['generated_by_ai']!,
          _generatedByAiMeta,
        ),
      );
    }
    if (data.containsKey('ai_reasoning')) {
      context.handle(
        _aiReasoningMeta,
        aiReasoning.isAcceptableOrUnknown(
          data['ai_reasoning']!,
          _aiReasoningMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pack_id'],
      ),
      splitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}split_type'],
      )!,
      daysPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days_per_week'],
      )!,
      generatedByAi: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}generated_by_ai'],
      )!,
      aiReasoning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_reasoning'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlansTable createAlias(String alias) {
    return $PlansTable(attachedDatabase, alias);
  }
}

class PlanRow extends DataClass implements Insertable<PlanRow> {
  final String id;
  final String userId;
  final String name;
  final String goal;
  final String? packId;
  final String splitType;
  final int daysPerWeek;
  final bool generatedByAi;
  final String? aiReasoning;
  final bool isActive;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlanRow({
    required this.id,
    required this.userId,
    required this.name,
    required this.goal,
    this.packId,
    required this.splitType,
    required this.daysPerWeek,
    required this.generatedByAi,
    this.aiReasoning,
    required this.isActive,
    this.startedAt,
    this.endedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['goal'] = Variable<String>(goal);
    if (!nullToAbsent || packId != null) {
      map['pack_id'] = Variable<String>(packId);
    }
    map['split_type'] = Variable<String>(splitType);
    map['days_per_week'] = Variable<int>(daysPerWeek);
    map['generated_by_ai'] = Variable<bool>(generatedByAi);
    if (!nullToAbsent || aiReasoning != null) {
      map['ai_reasoning'] = Variable<String>(aiReasoning);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlansCompanion toCompanion(bool nullToAbsent) {
    return PlansCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      goal: Value(goal),
      packId: packId == null && nullToAbsent
          ? const Value.absent()
          : Value(packId),
      splitType: Value(splitType),
      daysPerWeek: Value(daysPerWeek),
      generatedByAi: Value(generatedByAi),
      aiReasoning: aiReasoning == null && nullToAbsent
          ? const Value.absent()
          : Value(aiReasoning),
      isActive: Value(isActive),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      goal: serializer.fromJson<String>(json['goal']),
      packId: serializer.fromJson<String?>(json['packId']),
      splitType: serializer.fromJson<String>(json['splitType']),
      daysPerWeek: serializer.fromJson<int>(json['daysPerWeek']),
      generatedByAi: serializer.fromJson<bool>(json['generatedByAi']),
      aiReasoning: serializer.fromJson<String?>(json['aiReasoning']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'goal': serializer.toJson<String>(goal),
      'packId': serializer.toJson<String?>(packId),
      'splitType': serializer.toJson<String>(splitType),
      'daysPerWeek': serializer.toJson<int>(daysPerWeek),
      'generatedByAi': serializer.toJson<bool>(generatedByAi),
      'aiReasoning': serializer.toJson<String?>(aiReasoning),
      'isActive': serializer.toJson<bool>(isActive),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlanRow copyWith({
    String? id,
    String? userId,
    String? name,
    String? goal,
    Value<String?> packId = const Value.absent(),
    String? splitType,
    int? daysPerWeek,
    bool? generatedByAi,
    Value<String?> aiReasoning = const Value.absent(),
    bool? isActive,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => PlanRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    goal: goal ?? this.goal,
    packId: packId.present ? packId.value : this.packId,
    splitType: splitType ?? this.splitType,
    daysPerWeek: daysPerWeek ?? this.daysPerWeek,
    generatedByAi: generatedByAi ?? this.generatedByAi,
    aiReasoning: aiReasoning.present ? aiReasoning.value : this.aiReasoning,
    isActive: isActive ?? this.isActive,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlanRow copyWithCompanion(PlansCompanion data) {
    return PlanRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      goal: data.goal.present ? data.goal.value : this.goal,
      packId: data.packId.present ? data.packId.value : this.packId,
      splitType: data.splitType.present ? data.splitType.value : this.splitType,
      daysPerWeek: data.daysPerWeek.present
          ? data.daysPerWeek.value
          : this.daysPerWeek,
      generatedByAi: data.generatedByAi.present
          ? data.generatedByAi.value
          : this.generatedByAi,
      aiReasoning: data.aiReasoning.present
          ? data.aiReasoning.value
          : this.aiReasoning,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('goal: $goal, ')
          ..write('packId: $packId, ')
          ..write('splitType: $splitType, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('generatedByAi: $generatedByAi, ')
          ..write('aiReasoning: $aiReasoning, ')
          ..write('isActive: $isActive, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    goal,
    packId,
    splitType,
    daysPerWeek,
    generatedByAi,
    aiReasoning,
    isActive,
    startedAt,
    endedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.goal == this.goal &&
          other.packId == this.packId &&
          other.splitType == this.splitType &&
          other.daysPerWeek == this.daysPerWeek &&
          other.generatedByAi == this.generatedByAi &&
          other.aiReasoning == this.aiReasoning &&
          other.isActive == this.isActive &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlansCompanion extends UpdateCompanion<PlanRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> goal;
  final Value<String?> packId;
  final Value<String> splitType;
  final Value<int> daysPerWeek;
  final Value<bool> generatedByAi;
  final Value<String?> aiReasoning;
  final Value<bool> isActive;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> endedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlansCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.goal = const Value.absent(),
    this.packId = const Value.absent(),
    this.splitType = const Value.absent(),
    this.daysPerWeek = const Value.absent(),
    this.generatedByAi = const Value.absent(),
    this.aiReasoning = const Value.absent(),
    this.isActive = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlansCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required String goal,
    this.packId = const Value.absent(),
    required String splitType,
    required int daysPerWeek,
    this.generatedByAi = const Value.absent(),
    this.aiReasoning = const Value.absent(),
    this.isActive = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       goal = Value(goal),
       splitType = Value(splitType),
       daysPerWeek = Value(daysPerWeek);
  static Insertable<PlanRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? goal,
    Expression<String>? packId,
    Expression<String>? splitType,
    Expression<int>? daysPerWeek,
    Expression<bool>? generatedByAi,
    Expression<String>? aiReasoning,
    Expression<bool>? isActive,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (goal != null) 'goal': goal,
      if (packId != null) 'pack_id': packId,
      if (splitType != null) 'split_type': splitType,
      if (daysPerWeek != null) 'days_per_week': daysPerWeek,
      if (generatedByAi != null) 'generated_by_ai': generatedByAi,
      if (aiReasoning != null) 'ai_reasoning': aiReasoning,
      if (isActive != null) 'is_active': isActive,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlansCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? goal,
    Value<String?>? packId,
    Value<String>? splitType,
    Value<int>? daysPerWeek,
    Value<bool>? generatedByAi,
    Value<String?>? aiReasoning,
    Value<bool>? isActive,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? endedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PlansCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      goal: goal ?? this.goal,
      packId: packId ?? this.packId,
      splitType: splitType ?? this.splitType,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      generatedByAi: generatedByAi ?? this.generatedByAi,
      aiReasoning: aiReasoning ?? this.aiReasoning,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<String>(packId.value);
    }
    if (splitType.present) {
      map['split_type'] = Variable<String>(splitType.value);
    }
    if (daysPerWeek.present) {
      map['days_per_week'] = Variable<int>(daysPerWeek.value);
    }
    if (generatedByAi.present) {
      map['generated_by_ai'] = Variable<bool>(generatedByAi.value);
    }
    if (aiReasoning.present) {
      map['ai_reasoning'] = Variable<String>(aiReasoning.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlansCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('goal: $goal, ')
          ..write('packId: $packId, ')
          ..write('splitType: $splitType, ')
          ..write('daysPerWeek: $daysPerWeek, ')
          ..write('generatedByAi: $generatedByAi, ')
          ..write('aiReasoning: $aiReasoning, ')
          ..write('isActive: $isActive, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanDaysTable extends PlanDays
    with TableInfo<$PlanDaysTable, PlanDayRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayNumberMeta = const VerificationMeta(
    'dayNumber',
  );
  @override
  late final GeneratedColumn<int> dayNumber = GeneratedColumn<int>(
    'day_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _focusMeta = const VerificationMeta('focus');
  @override
  late final GeneratedColumn<String> focus = GeneratedColumn<String>(
    'focus',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, planId, dayNumber, name, focus];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_days';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanDayRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('day_number')) {
      context.handle(
        _dayNumberMeta,
        dayNumber.isAcceptableOrUnknown(data['day_number']!, _dayNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_dayNumberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('focus')) {
      context.handle(
        _focusMeta,
        focus.isAcceptableOrUnknown(data['focus']!, _focusMeta),
      );
    } else if (isInserting) {
      context.missing(_focusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanDayRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanDayRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_id'],
      )!,
      dayNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      focus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}focus'],
      )!,
    );
  }

  @override
  $PlanDaysTable createAlias(String alias) {
    return $PlanDaysTable(attachedDatabase, alias);
  }
}

class PlanDayRow extends DataClass implements Insertable<PlanDayRow> {
  final String id;
  final String planId;
  final int dayNumber;
  final String name;
  final String focus;
  const PlanDayRow({
    required this.id,
    required this.planId,
    required this.dayNumber,
    required this.name,
    required this.focus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['day_number'] = Variable<int>(dayNumber);
    map['name'] = Variable<String>(name);
    map['focus'] = Variable<String>(focus);
    return map;
  }

  PlanDaysCompanion toCompanion(bool nullToAbsent) {
    return PlanDaysCompanion(
      id: Value(id),
      planId: Value(planId),
      dayNumber: Value(dayNumber),
      name: Value(name),
      focus: Value(focus),
    );
  }

  factory PlanDayRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanDayRow(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      dayNumber: serializer.fromJson<int>(json['dayNumber']),
      name: serializer.fromJson<String>(json['name']),
      focus: serializer.fromJson<String>(json['focus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'dayNumber': serializer.toJson<int>(dayNumber),
      'name': serializer.toJson<String>(name),
      'focus': serializer.toJson<String>(focus),
    };
  }

  PlanDayRow copyWith({
    String? id,
    String? planId,
    int? dayNumber,
    String? name,
    String? focus,
  }) => PlanDayRow(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    dayNumber: dayNumber ?? this.dayNumber,
    name: name ?? this.name,
    focus: focus ?? this.focus,
  );
  PlanDayRow copyWithCompanion(PlanDaysCompanion data) {
    return PlanDayRow(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      dayNumber: data.dayNumber.present ? data.dayNumber.value : this.dayNumber,
      name: data.name.present ? data.name.value : this.name,
      focus: data.focus.present ? data.focus.value : this.focus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanDayRow(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('name: $name, ')
          ..write('focus: $focus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, dayNumber, name, focus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanDayRow &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.dayNumber == this.dayNumber &&
          other.name == this.name &&
          other.focus == this.focus);
}

class PlanDaysCompanion extends UpdateCompanion<PlanDayRow> {
  final Value<String> id;
  final Value<String> planId;
  final Value<int> dayNumber;
  final Value<String> name;
  final Value<String> focus;
  final Value<int> rowid;
  const PlanDaysCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.dayNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.focus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanDaysCompanion.insert({
    required String id,
    required String planId,
    required int dayNumber,
    required String name,
    required String focus,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planId = Value(planId),
       dayNumber = Value(dayNumber),
       name = Value(name),
       focus = Value(focus);
  static Insertable<PlanDayRow> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<int>? dayNumber,
    Expression<String>? name,
    Expression<String>? focus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (dayNumber != null) 'day_number': dayNumber,
      if (name != null) 'name': name,
      if (focus != null) 'focus': focus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanDaysCompanion copyWith({
    Value<String>? id,
    Value<String>? planId,
    Value<int>? dayNumber,
    Value<String>? name,
    Value<String>? focus,
    Value<int>? rowid,
  }) {
    return PlanDaysCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      dayNumber: dayNumber ?? this.dayNumber,
      name: name ?? this.name,
      focus: focus ?? this.focus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (dayNumber.present) {
      map['day_number'] = Variable<int>(dayNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (focus.present) {
      map['focus'] = Variable<String>(focus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanDaysCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('dayNumber: $dayNumber, ')
          ..write('name: $name, ')
          ..write('focus: $focus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanPrescriptionsTable extends PlanPrescriptions
    with TableInfo<$PlanPrescriptionsTable, PlanPrescriptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanPrescriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planDayIdMeta = const VerificationMeta(
    'planDayId',
  );
  @override
  late final GeneratedColumn<String> planDayId = GeneratedColumn<String>(
    'plan_day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetRepsMinMeta = const VerificationMeta(
    'targetRepsMin',
  );
  @override
  late final GeneratedColumn<int> targetRepsMin = GeneratedColumn<int>(
    'target_reps_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetRepsMaxMeta = const VerificationMeta(
    'targetRepsMax',
  );
  @override
  late final GeneratedColumn<int> targetRepsMax = GeneratedColumn<int>(
    'target_reps_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetRirMeta = const VerificationMeta(
    'targetRir',
  );
  @override
  late final GeneratedColumn<int> targetRir = GeneratedColumn<int>(
    'target_rir',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetRestSecondsMeta = const VerificationMeta(
    'targetRestSeconds',
  );
  @override
  late final GeneratedColumn<int> targetRestSeconds = GeneratedColumn<int>(
    'target_rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    planDayId,
    exerciseId,
    order,
    targetSets,
    targetRepsMin,
    targetRepsMax,
    targetRir,
    targetRestSeconds,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_prescriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanPrescriptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_day_id')) {
      context.handle(
        _planDayIdMeta,
        planDayId.isAcceptableOrUnknown(data['plan_day_id']!, _planDayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planDayIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    } else if (isInserting) {
      context.missing(_targetSetsMeta);
    }
    if (data.containsKey('target_reps_min')) {
      context.handle(
        _targetRepsMinMeta,
        targetRepsMin.isAcceptableOrUnknown(
          data['target_reps_min']!,
          _targetRepsMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetRepsMinMeta);
    }
    if (data.containsKey('target_reps_max')) {
      context.handle(
        _targetRepsMaxMeta,
        targetRepsMax.isAcceptableOrUnknown(
          data['target_reps_max']!,
          _targetRepsMaxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetRepsMaxMeta);
    }
    if (data.containsKey('target_rir')) {
      context.handle(
        _targetRirMeta,
        targetRir.isAcceptableOrUnknown(data['target_rir']!, _targetRirMeta),
      );
    } else if (isInserting) {
      context.missing(_targetRirMeta);
    }
    if (data.containsKey('target_rest_seconds')) {
      context.handle(
        _targetRestSecondsMeta,
        targetRestSeconds.isAcceptableOrUnknown(
          data['target_rest_seconds']!,
          _targetRestSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetRestSecondsMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanPrescriptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanPrescriptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      planDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_day_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      )!,
      targetRepsMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps_min'],
      )!,
      targetRepsMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps_max'],
      )!,
      targetRir: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_rir'],
      )!,
      targetRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_rest_seconds'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $PlanPrescriptionsTable createAlias(String alias) {
    return $PlanPrescriptionsTable(attachedDatabase, alias);
  }
}

class PlanPrescriptionRow extends DataClass
    implements Insertable<PlanPrescriptionRow> {
  final String id;
  final String planDayId;
  final String exerciseId;
  final int order;
  final int targetSets;
  final int targetRepsMin;
  final int targetRepsMax;
  final int targetRir;
  final int targetRestSeconds;
  final String? notes;
  const PlanPrescriptionRow({
    required this.id,
    required this.planDayId,
    required this.exerciseId,
    required this.order,
    required this.targetSets,
    required this.targetRepsMin,
    required this.targetRepsMax,
    required this.targetRir,
    required this.targetRestSeconds,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_day_id'] = Variable<String>(planDayId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order'] = Variable<int>(order);
    map['target_sets'] = Variable<int>(targetSets);
    map['target_reps_min'] = Variable<int>(targetRepsMin);
    map['target_reps_max'] = Variable<int>(targetRepsMax);
    map['target_rir'] = Variable<int>(targetRir);
    map['target_rest_seconds'] = Variable<int>(targetRestSeconds);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PlanPrescriptionsCompanion toCompanion(bool nullToAbsent) {
    return PlanPrescriptionsCompanion(
      id: Value(id),
      planDayId: Value(planDayId),
      exerciseId: Value(exerciseId),
      order: Value(order),
      targetSets: Value(targetSets),
      targetRepsMin: Value(targetRepsMin),
      targetRepsMax: Value(targetRepsMax),
      targetRir: Value(targetRir),
      targetRestSeconds: Value(targetRestSeconds),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory PlanPrescriptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanPrescriptionRow(
      id: serializer.fromJson<String>(json['id']),
      planDayId: serializer.fromJson<String>(json['planDayId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      order: serializer.fromJson<int>(json['order']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      targetRepsMin: serializer.fromJson<int>(json['targetRepsMin']),
      targetRepsMax: serializer.fromJson<int>(json['targetRepsMax']),
      targetRir: serializer.fromJson<int>(json['targetRir']),
      targetRestSeconds: serializer.fromJson<int>(json['targetRestSeconds']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planDayId': serializer.toJson<String>(planDayId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'order': serializer.toJson<int>(order),
      'targetSets': serializer.toJson<int>(targetSets),
      'targetRepsMin': serializer.toJson<int>(targetRepsMin),
      'targetRepsMax': serializer.toJson<int>(targetRepsMax),
      'targetRir': serializer.toJson<int>(targetRir),
      'targetRestSeconds': serializer.toJson<int>(targetRestSeconds),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  PlanPrescriptionRow copyWith({
    String? id,
    String? planDayId,
    String? exerciseId,
    int? order,
    int? targetSets,
    int? targetRepsMin,
    int? targetRepsMax,
    int? targetRir,
    int? targetRestSeconds,
    Value<String?> notes = const Value.absent(),
  }) => PlanPrescriptionRow(
    id: id ?? this.id,
    planDayId: planDayId ?? this.planDayId,
    exerciseId: exerciseId ?? this.exerciseId,
    order: order ?? this.order,
    targetSets: targetSets ?? this.targetSets,
    targetRepsMin: targetRepsMin ?? this.targetRepsMin,
    targetRepsMax: targetRepsMax ?? this.targetRepsMax,
    targetRir: targetRir ?? this.targetRir,
    targetRestSeconds: targetRestSeconds ?? this.targetRestSeconds,
    notes: notes.present ? notes.value : this.notes,
  );
  PlanPrescriptionRow copyWithCompanion(PlanPrescriptionsCompanion data) {
    return PlanPrescriptionRow(
      id: data.id.present ? data.id.value : this.id,
      planDayId: data.planDayId.present ? data.planDayId.value : this.planDayId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      order: data.order.present ? data.order.value : this.order,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      targetRepsMin: data.targetRepsMin.present
          ? data.targetRepsMin.value
          : this.targetRepsMin,
      targetRepsMax: data.targetRepsMax.present
          ? data.targetRepsMax.value
          : this.targetRepsMax,
      targetRir: data.targetRir.present ? data.targetRir.value : this.targetRir,
      targetRestSeconds: data.targetRestSeconds.present
          ? data.targetRestSeconds.value
          : this.targetRestSeconds,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanPrescriptionRow(')
          ..write('id: $id, ')
          ..write('planDayId: $planDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('order: $order, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetRepsMin: $targetRepsMin, ')
          ..write('targetRepsMax: $targetRepsMax, ')
          ..write('targetRir: $targetRir, ')
          ..write('targetRestSeconds: $targetRestSeconds, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    planDayId,
    exerciseId,
    order,
    targetSets,
    targetRepsMin,
    targetRepsMax,
    targetRir,
    targetRestSeconds,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanPrescriptionRow &&
          other.id == this.id &&
          other.planDayId == this.planDayId &&
          other.exerciseId == this.exerciseId &&
          other.order == this.order &&
          other.targetSets == this.targetSets &&
          other.targetRepsMin == this.targetRepsMin &&
          other.targetRepsMax == this.targetRepsMax &&
          other.targetRir == this.targetRir &&
          other.targetRestSeconds == this.targetRestSeconds &&
          other.notes == this.notes);
}

class PlanPrescriptionsCompanion extends UpdateCompanion<PlanPrescriptionRow> {
  final Value<String> id;
  final Value<String> planDayId;
  final Value<String> exerciseId;
  final Value<int> order;
  final Value<int> targetSets;
  final Value<int> targetRepsMin;
  final Value<int> targetRepsMax;
  final Value<int> targetRir;
  final Value<int> targetRestSeconds;
  final Value<String?> notes;
  final Value<int> rowid;
  const PlanPrescriptionsCompanion({
    this.id = const Value.absent(),
    this.planDayId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.order = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetRepsMin = const Value.absent(),
    this.targetRepsMax = const Value.absent(),
    this.targetRir = const Value.absent(),
    this.targetRestSeconds = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanPrescriptionsCompanion.insert({
    required String id,
    required String planDayId,
    required String exerciseId,
    required int order,
    required int targetSets,
    required int targetRepsMin,
    required int targetRepsMax,
    required int targetRir,
    required int targetRestSeconds,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       planDayId = Value(planDayId),
       exerciseId = Value(exerciseId),
       order = Value(order),
       targetSets = Value(targetSets),
       targetRepsMin = Value(targetRepsMin),
       targetRepsMax = Value(targetRepsMax),
       targetRir = Value(targetRir),
       targetRestSeconds = Value(targetRestSeconds);
  static Insertable<PlanPrescriptionRow> custom({
    Expression<String>? id,
    Expression<String>? planDayId,
    Expression<String>? exerciseId,
    Expression<int>? order,
    Expression<int>? targetSets,
    Expression<int>? targetRepsMin,
    Expression<int>? targetRepsMax,
    Expression<int>? targetRir,
    Expression<int>? targetRestSeconds,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planDayId != null) 'plan_day_id': planDayId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (order != null) 'order': order,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetRepsMin != null) 'target_reps_min': targetRepsMin,
      if (targetRepsMax != null) 'target_reps_max': targetRepsMax,
      if (targetRir != null) 'target_rir': targetRir,
      if (targetRestSeconds != null) 'target_rest_seconds': targetRestSeconds,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanPrescriptionsCompanion copyWith({
    Value<String>? id,
    Value<String>? planDayId,
    Value<String>? exerciseId,
    Value<int>? order,
    Value<int>? targetSets,
    Value<int>? targetRepsMin,
    Value<int>? targetRepsMax,
    Value<int>? targetRir,
    Value<int>? targetRestSeconds,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return PlanPrescriptionsCompanion(
      id: id ?? this.id,
      planDayId: planDayId ?? this.planDayId,
      exerciseId: exerciseId ?? this.exerciseId,
      order: order ?? this.order,
      targetSets: targetSets ?? this.targetSets,
      targetRepsMin: targetRepsMin ?? this.targetRepsMin,
      targetRepsMax: targetRepsMax ?? this.targetRepsMax,
      targetRir: targetRir ?? this.targetRir,
      targetRestSeconds: targetRestSeconds ?? this.targetRestSeconds,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planDayId.present) {
      map['plan_day_id'] = Variable<String>(planDayId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetRepsMin.present) {
      map['target_reps_min'] = Variable<int>(targetRepsMin.value);
    }
    if (targetRepsMax.present) {
      map['target_reps_max'] = Variable<int>(targetRepsMax.value);
    }
    if (targetRir.present) {
      map['target_rir'] = Variable<int>(targetRir.value);
    }
    if (targetRestSeconds.present) {
      map['target_rest_seconds'] = Variable<int>(targetRestSeconds.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanPrescriptionsCompanion(')
          ..write('id: $id, ')
          ..write('planDayId: $planDayId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('order: $order, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetRepsMin: $targetRepsMin, ')
          ..write('targetRepsMax: $targetRepsMax, ')
          ..write('targetRir: $targetRir, ')
          ..write('targetRestSeconds: $targetRestSeconds, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _planDayIdMeta = const VerificationMeta(
    'planDayId',
  );
  @override
  late final GeneratedColumn<String> planDayId = GeneratedColumn<String>(
    'plan_day_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('in_progress'),
  );
  static const VerificationMeta _bodyweightMeta = const VerificationMeta(
    'bodyweight',
  );
  @override
  late final GeneratedColumn<double> bodyweight = GeneratedColumn<double>(
    'bodyweight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heartRateAvgMeta = const VerificationMeta(
    'heartRateAvg',
  );
  @override
  late final GeneratedColumn<int> heartRateAvg = GeneratedColumn<int>(
    'heart_rate_avg',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heartRateMaxMeta = const VerificationMeta(
    'heartRateMax',
  );
  @override
  late final GeneratedColumn<int> heartRateMax = GeneratedColumn<int>(
    'heart_rate_max',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _caloriesEstMeta = const VerificationMeta(
    'caloriesEst',
  );
  @override
  late final GeneratedColumn<int> caloriesEst = GeneratedColumn<int>(
    'calories_est',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
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
    clientDefault: () => DateTime.now().toUtc(),
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
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    planDayId,
    startedAt,
    endedAt,
    status,
    bodyweight,
    heartRateAvg,
    heartRateMax,
    caloriesEst,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('plan_day_id')) {
      context.handle(
        _planDayIdMeta,
        planDayId.isAcceptableOrUnknown(data['plan_day_id']!, _planDayIdMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('bodyweight')) {
      context.handle(
        _bodyweightMeta,
        bodyweight.isAcceptableOrUnknown(data['bodyweight']!, _bodyweightMeta),
      );
    }
    if (data.containsKey('heart_rate_avg')) {
      context.handle(
        _heartRateAvgMeta,
        heartRateAvg.isAcceptableOrUnknown(
          data['heart_rate_avg']!,
          _heartRateAvgMeta,
        ),
      );
    }
    if (data.containsKey('heart_rate_max')) {
      context.handle(
        _heartRateMaxMeta,
        heartRateMax.isAcceptableOrUnknown(
          data['heart_rate_max']!,
          _heartRateMaxMeta,
        ),
      );
    }
    if (data.containsKey('calories_est')) {
      context.handle(
        _caloriesEstMeta,
        caloriesEst.isAcceptableOrUnknown(
          data['calories_est']!,
          _caloriesEstMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      planDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_day_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      bodyweight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}bodyweight'],
      ),
      heartRateAvg: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate_avg'],
      ),
      heartRateMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heart_rate_max'],
      ),
      caloriesEst: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calories_est'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String id;
  final String userId;
  final String? planDayId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String status;
  final double? bodyweight;
  final int? heartRateAvg;
  final int? heartRateMax;
  final int? caloriesEst;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SessionRow({
    required this.id,
    required this.userId,
    this.planDayId,
    required this.startedAt,
    this.endedAt,
    required this.status,
    this.bodyweight,
    this.heartRateAvg,
    this.heartRateMax,
    this.caloriesEst,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || planDayId != null) {
      map['plan_day_id'] = Variable<String>(planDayId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || bodyweight != null) {
      map['bodyweight'] = Variable<double>(bodyweight);
    }
    if (!nullToAbsent || heartRateAvg != null) {
      map['heart_rate_avg'] = Variable<int>(heartRateAvg);
    }
    if (!nullToAbsent || heartRateMax != null) {
      map['heart_rate_max'] = Variable<int>(heartRateMax);
    }
    if (!nullToAbsent || caloriesEst != null) {
      map['calories_est'] = Variable<int>(caloriesEst);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      planDayId: planDayId == null && nullToAbsent
          ? const Value.absent()
          : Value(planDayId),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      status: Value(status),
      bodyweight: bodyweight == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyweight),
      heartRateAvg: heartRateAvg == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRateAvg),
      heartRateMax: heartRateMax == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRateMax),
      caloriesEst: caloriesEst == null && nullToAbsent
          ? const Value.absent()
          : Value(caloriesEst),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      planDayId: serializer.fromJson<String?>(json['planDayId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      status: serializer.fromJson<String>(json['status']),
      bodyweight: serializer.fromJson<double?>(json['bodyweight']),
      heartRateAvg: serializer.fromJson<int?>(json['heartRateAvg']),
      heartRateMax: serializer.fromJson<int?>(json['heartRateMax']),
      caloriesEst: serializer.fromJson<int?>(json['caloriesEst']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'planDayId': serializer.toJson<String?>(planDayId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'status': serializer.toJson<String>(status),
      'bodyweight': serializer.toJson<double?>(bodyweight),
      'heartRateAvg': serializer.toJson<int?>(heartRateAvg),
      'heartRateMax': serializer.toJson<int?>(heartRateMax),
      'caloriesEst': serializer.toJson<int?>(caloriesEst),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SessionRow copyWith({
    String? id,
    String? userId,
    Value<String?> planDayId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    String? status,
    Value<double?> bodyweight = const Value.absent(),
    Value<int?> heartRateAvg = const Value.absent(),
    Value<int?> heartRateMax = const Value.absent(),
    Value<int?> caloriesEst = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SessionRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    planDayId: planDayId.present ? planDayId.value : this.planDayId,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    status: status ?? this.status,
    bodyweight: bodyweight.present ? bodyweight.value : this.bodyweight,
    heartRateAvg: heartRateAvg.present ? heartRateAvg.value : this.heartRateAvg,
    heartRateMax: heartRateMax.present ? heartRateMax.value : this.heartRateMax,
    caloriesEst: caloriesEst.present ? caloriesEst.value : this.caloriesEst,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      planDayId: data.planDayId.present ? data.planDayId.value : this.planDayId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      status: data.status.present ? data.status.value : this.status,
      bodyweight: data.bodyweight.present
          ? data.bodyweight.value
          : this.bodyweight,
      heartRateAvg: data.heartRateAvg.present
          ? data.heartRateAvg.value
          : this.heartRateAvg,
      heartRateMax: data.heartRateMax.present
          ? data.heartRateMax.value
          : this.heartRateMax,
      caloriesEst: data.caloriesEst.present
          ? data.caloriesEst.value
          : this.caloriesEst,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('planDayId: $planDayId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('bodyweight: $bodyweight, ')
          ..write('heartRateAvg: $heartRateAvg, ')
          ..write('heartRateMax: $heartRateMax, ')
          ..write('caloriesEst: $caloriesEst, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    planDayId,
    startedAt,
    endedAt,
    status,
    bodyweight,
    heartRateAvg,
    heartRateMax,
    caloriesEst,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.planDayId == this.planDayId &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.status == this.status &&
          other.bodyweight == this.bodyweight &&
          other.heartRateAvg == this.heartRateAvg &&
          other.heartRateMax == this.heartRateMax &&
          other.caloriesEst == this.caloriesEst &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String?> planDayId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String> status;
  final Value<double?> bodyweight;
  final Value<int?> heartRateAvg;
  final Value<int?> heartRateMax;
  final Value<int?> caloriesEst;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.planDayId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.bodyweight = const Value.absent(),
    this.heartRateAvg = const Value.absent(),
    this.heartRateMax = const Value.absent(),
    this.caloriesEst = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    required String userId,
    this.planDayId = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.bodyweight = const Value.absent(),
    this.heartRateAvg = const Value.absent(),
    this.heartRateMax = const Value.absent(),
    this.caloriesEst = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       startedAt = Value(startedAt);
  static Insertable<SessionRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? planDayId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? status,
    Expression<double>? bodyweight,
    Expression<int>? heartRateAvg,
    Expression<int>? heartRateMax,
    Expression<int>? caloriesEst,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (planDayId != null) 'plan_day_id': planDayId,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (status != null) 'status': status,
      if (bodyweight != null) 'bodyweight': bodyweight,
      if (heartRateAvg != null) 'heart_rate_avg': heartRateAvg,
      if (heartRateMax != null) 'heart_rate_max': heartRateMax,
      if (caloriesEst != null) 'calories_est': caloriesEst,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String?>? planDayId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<String>? status,
    Value<double?>? bodyweight,
    Value<int?>? heartRateAvg,
    Value<int?>? heartRateMax,
    Value<int?>? caloriesEst,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planDayId: planDayId ?? this.planDayId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      status: status ?? this.status,
      bodyweight: bodyweight ?? this.bodyweight,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      heartRateMax: heartRateMax ?? this.heartRateMax,
      caloriesEst: caloriesEst ?? this.caloriesEst,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (planDayId.present) {
      map['plan_day_id'] = Variable<String>(planDayId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (bodyweight.present) {
      map['bodyweight'] = Variable<double>(bodyweight.value);
    }
    if (heartRateAvg.present) {
      map['heart_rate_avg'] = Variable<int>(heartRateAvg.value);
    }
    if (heartRateMax.present) {
      map['heart_rate_max'] = Variable<int>(heartRateMax.value);
    }
    if (caloriesEst.present) {
      map['calories_est'] = Variable<int>(caloriesEst.value);
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('planDayId: $planDayId, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('status: $status, ')
          ..write('bodyweight: $bodyweight, ')
          ..write('heartRateAvg: $heartRateAvg, ')
          ..write('heartRateMax: $heartRateMax, ')
          ..write('caloriesEst: $caloriesEst, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionExercisesTable extends SessionExercises
    with TableInfo<$SessionExercisesTable, SessionExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
    'order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _skipReasonMeta = const VerificationMeta(
    'skipReason',
  );
  @override
  late final GeneratedColumn<String> skipReason = GeneratedColumn<String>(
    'skip_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    exerciseId,
    order,
    status,
    skipReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
        _orderMeta,
        order.isAcceptableOrUnknown(data['order']!, _orderMeta),
      );
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('skip_reason')) {
      context.handle(
        _skipReasonMeta,
        skipReason.isAcceptableOrUnknown(data['skip_reason']!, _skipReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      order: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      skipReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skip_reason'],
      ),
    );
  }

  @override
  $SessionExercisesTable createAlias(String alias) {
    return $SessionExercisesTable(attachedDatabase, alias);
  }
}

class SessionExerciseRow extends DataClass
    implements Insertable<SessionExerciseRow> {
  final String id;
  final String sessionId;
  final String exerciseId;
  final int order;
  final String status;
  final String? skipReason;
  const SessionExerciseRow({
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.order,
    required this.status,
    this.skipReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order'] = Variable<int>(order);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || skipReason != null) {
      map['skip_reason'] = Variable<String>(skipReason);
    }
    return map;
  }

  SessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return SessionExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      order: Value(order),
      status: Value(status),
      skipReason: skipReason == null && nullToAbsent
          ? const Value.absent()
          : Value(skipReason),
    );
  }

  factory SessionExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      order: serializer.fromJson<int>(json['order']),
      status: serializer.fromJson<String>(json['status']),
      skipReason: serializer.fromJson<String?>(json['skipReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'order': serializer.toJson<int>(order),
      'status': serializer.toJson<String>(status),
      'skipReason': serializer.toJson<String?>(skipReason),
    };
  }

  SessionExerciseRow copyWith({
    String? id,
    String? sessionId,
    String? exerciseId,
    int? order,
    String? status,
    Value<String?> skipReason = const Value.absent(),
  }) => SessionExerciseRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    order: order ?? this.order,
    status: status ?? this.status,
    skipReason: skipReason.present ? skipReason.value : this.skipReason,
  );
  SessionExerciseRow copyWithCompanion(SessionExercisesCompanion data) {
    return SessionExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      order: data.order.present ? data.order.value : this.order,
      status: data.status.present ? data.status.value : this.status,
      skipReason: data.skipReason.present
          ? data.skipReason.value
          : this.skipReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExerciseRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('order: $order, ')
          ..write('status: $status, ')
          ..write('skipReason: $skipReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, exerciseId, order, status, skipReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExerciseRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.order == this.order &&
          other.status == this.status &&
          other.skipReason == this.skipReason);
}

class SessionExercisesCompanion extends UpdateCompanion<SessionExerciseRow> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> exerciseId;
  final Value<int> order;
  final Value<String> status;
  final Value<String?> skipReason;
  final Value<int> rowid;
  const SessionExercisesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.order = const Value.absent(),
    this.status = const Value.absent(),
    this.skipReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionExercisesCompanion.insert({
    required String id,
    required String sessionId,
    required String exerciseId,
    required int order,
    this.status = const Value.absent(),
    this.skipReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       order = Value(order);
  static Insertable<SessionExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<int>? order,
    Expression<String>? status,
    Expression<String>? skipReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (order != null) 'order': order,
      if (status != null) 'status': status,
      if (skipReason != null) 'skip_reason': skipReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? exerciseId,
    Value<int>? order,
    Value<String>? status,
    Value<String?>? skipReason,
    Value<int>? rowid,
  }) {
    return SessionExercisesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      order: order ?? this.order,
      status: status ?? this.status,
      skipReason: skipReason ?? this.skipReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (skipReason.present) {
      map['skip_reason'] = Variable<String>(skipReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercisesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('order: $order, ')
          ..write('status: $status, ')
          ..write('skipReason: $skipReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SetsTable extends Sets with TableInfo<$SetsTable, SetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionExerciseIdMeta = const VerificationMeta(
    'sessionExerciseId',
  );
  @override
  late final GeneratedColumn<String> sessionExerciseId =
      GeneratedColumn<String>(
        'session_exercise_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rirMeta = const VerificationMeta('rir');
  @override
  late final GeneratedColumn<int> rir = GeneratedColumn<int>(
    'rir',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tempoMeta = const VerificationMeta('tempo');
  @override
  late final GeneratedColumn<String> tempo = GeneratedColumn<String>(
    'tempo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isUnilateralLeftMeta = const VerificationMeta(
    'isUnilateralLeft',
  );
  @override
  late final GeneratedColumn<bool> isUnilateralLeft = GeneratedColumn<bool>(
    'is_unilateral_left',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unilateral_left" IN (0, 1))',
    ),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loggedAtMeta = const VerificationMeta(
    'loggedAt',
  );
  @override
  late final GeneratedColumn<DateTime> loggedAt = GeneratedColumn<DateTime>(
    'logged_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionExerciseId,
    setNumber,
    weight,
    reps,
    rir,
    restSeconds,
    tempo,
    isUnilateralLeft,
    notes,
    loggedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_exercise_id')) {
      context.handle(
        _sessionExerciseIdMeta,
        sessionExerciseId.isAcceptableOrUnknown(
          data['session_exercise_id']!,
          _sessionExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionExerciseIdMeta);
    }
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('rir')) {
      context.handle(
        _rirMeta,
        rir.isAcceptableOrUnknown(data['rir']!, _rirMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    if (data.containsKey('tempo')) {
      context.handle(
        _tempoMeta,
        tempo.isAcceptableOrUnknown(data['tempo']!, _tempoMeta),
      );
    }
    if (data.containsKey('is_unilateral_left')) {
      context.handle(
        _isUnilateralLeftMeta,
        isUnilateralLeft.isAcceptableOrUnknown(
          data['is_unilateral_left']!,
          _isUnilateralLeftMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('logged_at')) {
      context.handle(
        _loggedAtMeta,
        loggedAt.isAcceptableOrUnknown(data['logged_at']!, _loggedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_exercise_id'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      rir: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rir'],
      ),
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      ),
      tempo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tempo'],
      ),
      isUnilateralLeft: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unilateral_left'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      loggedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}logged_at'],
      )!,
    );
  }

  @override
  $SetsTable createAlias(String alias) {
    return $SetsTable(attachedDatabase, alias);
  }
}

class SetRow extends DataClass implements Insertable<SetRow> {
  final String id;
  final String sessionExerciseId;
  final int setNumber;
  final double? weight;
  final int reps;
  final int? rir;
  final int? restSeconds;
  final String? tempo;
  final bool? isUnilateralLeft;
  final String? notes;
  final DateTime loggedAt;
  const SetRow({
    required this.id,
    required this.sessionExerciseId,
    required this.setNumber,
    this.weight,
    required this.reps,
    this.rir,
    this.restSeconds,
    this.tempo,
    this.isUnilateralLeft,
    this.notes,
    required this.loggedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_exercise_id'] = Variable<String>(sessionExerciseId);
    map['set_number'] = Variable<int>(setNumber);
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    map['reps'] = Variable<int>(reps);
    if (!nullToAbsent || rir != null) {
      map['rir'] = Variable<int>(rir);
    }
    if (!nullToAbsent || restSeconds != null) {
      map['rest_seconds'] = Variable<int>(restSeconds);
    }
    if (!nullToAbsent || tempo != null) {
      map['tempo'] = Variable<String>(tempo);
    }
    if (!nullToAbsent || isUnilateralLeft != null) {
      map['is_unilateral_left'] = Variable<bool>(isUnilateralLeft);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['logged_at'] = Variable<DateTime>(loggedAt);
    return map;
  }

  SetsCompanion toCompanion(bool nullToAbsent) {
    return SetsCompanion(
      id: Value(id),
      sessionExerciseId: Value(sessionExerciseId),
      setNumber: Value(setNumber),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      reps: Value(reps),
      rir: rir == null && nullToAbsent ? const Value.absent() : Value(rir),
      restSeconds: restSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(restSeconds),
      tempo: tempo == null && nullToAbsent
          ? const Value.absent()
          : Value(tempo),
      isUnilateralLeft: isUnilateralLeft == null && nullToAbsent
          ? const Value.absent()
          : Value(isUnilateralLeft),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      loggedAt: Value(loggedAt),
    );
  }

  factory SetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetRow(
      id: serializer.fromJson<String>(json['id']),
      sessionExerciseId: serializer.fromJson<String>(json['sessionExerciseId']),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      weight: serializer.fromJson<double?>(json['weight']),
      reps: serializer.fromJson<int>(json['reps']),
      rir: serializer.fromJson<int?>(json['rir']),
      restSeconds: serializer.fromJson<int?>(json['restSeconds']),
      tempo: serializer.fromJson<String?>(json['tempo']),
      isUnilateralLeft: serializer.fromJson<bool?>(json['isUnilateralLeft']),
      notes: serializer.fromJson<String?>(json['notes']),
      loggedAt: serializer.fromJson<DateTime>(json['loggedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'sessionExerciseId': serializer.toJson<String>(sessionExerciseId),
      'setNumber': serializer.toJson<int>(setNumber),
      'weight': serializer.toJson<double?>(weight),
      'reps': serializer.toJson<int>(reps),
      'rir': serializer.toJson<int?>(rir),
      'restSeconds': serializer.toJson<int?>(restSeconds),
      'tempo': serializer.toJson<String?>(tempo),
      'isUnilateralLeft': serializer.toJson<bool?>(isUnilateralLeft),
      'notes': serializer.toJson<String?>(notes),
      'loggedAt': serializer.toJson<DateTime>(loggedAt),
    };
  }

  SetRow copyWith({
    String? id,
    String? sessionExerciseId,
    int? setNumber,
    Value<double?> weight = const Value.absent(),
    int? reps,
    Value<int?> rir = const Value.absent(),
    Value<int?> restSeconds = const Value.absent(),
    Value<String?> tempo = const Value.absent(),
    Value<bool?> isUnilateralLeft = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? loggedAt,
  }) => SetRow(
    id: id ?? this.id,
    sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
    setNumber: setNumber ?? this.setNumber,
    weight: weight.present ? weight.value : this.weight,
    reps: reps ?? this.reps,
    rir: rir.present ? rir.value : this.rir,
    restSeconds: restSeconds.present ? restSeconds.value : this.restSeconds,
    tempo: tempo.present ? tempo.value : this.tempo,
    isUnilateralLeft: isUnilateralLeft.present
        ? isUnilateralLeft.value
        : this.isUnilateralLeft,
    notes: notes.present ? notes.value : this.notes,
    loggedAt: loggedAt ?? this.loggedAt,
  );
  SetRow copyWithCompanion(SetsCompanion data) {
    return SetRow(
      id: data.id.present ? data.id.value : this.id,
      sessionExerciseId: data.sessionExerciseId.present
          ? data.sessionExerciseId.value
          : this.sessionExerciseId,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      rir: data.rir.present ? data.rir.value : this.rir,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      tempo: data.tempo.present ? data.tempo.value : this.tempo,
      isUnilateralLeft: data.isUnilateralLeft.present
          ? data.isUnilateralLeft.value
          : this.isUnilateralLeft,
      notes: data.notes.present ? data.notes.value : this.notes,
      loggedAt: data.loggedAt.present ? data.loggedAt.value : this.loggedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetRow(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('rir: $rir, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('tempo: $tempo, ')
          ..write('isUnilateralLeft: $isUnilateralLeft, ')
          ..write('notes: $notes, ')
          ..write('loggedAt: $loggedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionExerciseId,
    setNumber,
    weight,
    reps,
    rir,
    restSeconds,
    tempo,
    isUnilateralLeft,
    notes,
    loggedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetRow &&
          other.id == this.id &&
          other.sessionExerciseId == this.sessionExerciseId &&
          other.setNumber == this.setNumber &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.rir == this.rir &&
          other.restSeconds == this.restSeconds &&
          other.tempo == this.tempo &&
          other.isUnilateralLeft == this.isUnilateralLeft &&
          other.notes == this.notes &&
          other.loggedAt == this.loggedAt);
}

class SetsCompanion extends UpdateCompanion<SetRow> {
  final Value<String> id;
  final Value<String> sessionExerciseId;
  final Value<int> setNumber;
  final Value<double?> weight;
  final Value<int> reps;
  final Value<int?> rir;
  final Value<int?> restSeconds;
  final Value<String?> tempo;
  final Value<bool?> isUnilateralLeft;
  final Value<String?> notes;
  final Value<DateTime> loggedAt;
  final Value<int> rowid;
  const SetsCompanion({
    this.id = const Value.absent(),
    this.sessionExerciseId = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.rir = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.tempo = const Value.absent(),
    this.isUnilateralLeft = const Value.absent(),
    this.notes = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SetsCompanion.insert({
    required String id,
    required String sessionExerciseId,
    required int setNumber,
    this.weight = const Value.absent(),
    required int reps,
    this.rir = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.tempo = const Value.absent(),
    this.isUnilateralLeft = const Value.absent(),
    this.notes = const Value.absent(),
    this.loggedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionExerciseId = Value(sessionExerciseId),
       setNumber = Value(setNumber),
       reps = Value(reps);
  static Insertable<SetRow> custom({
    Expression<String>? id,
    Expression<String>? sessionExerciseId,
    Expression<int>? setNumber,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<int>? rir,
    Expression<int>? restSeconds,
    Expression<String>? tempo,
    Expression<bool>? isUnilateralLeft,
    Expression<String>? notes,
    Expression<DateTime>? loggedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionExerciseId != null) 'session_exercise_id': sessionExerciseId,
      if (setNumber != null) 'set_number': setNumber,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (rir != null) 'rir': rir,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (tempo != null) 'tempo': tempo,
      if (isUnilateralLeft != null) 'is_unilateral_left': isUnilateralLeft,
      if (notes != null) 'notes': notes,
      if (loggedAt != null) 'logged_at': loggedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SetsCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionExerciseId,
    Value<int>? setNumber,
    Value<double?>? weight,
    Value<int>? reps,
    Value<int?>? rir,
    Value<int?>? restSeconds,
    Value<String?>? tempo,
    Value<bool?>? isUnilateralLeft,
    Value<String?>? notes,
    Value<DateTime>? loggedAt,
    Value<int>? rowid,
  }) {
    return SetsCompanion(
      id: id ?? this.id,
      sessionExerciseId: sessionExerciseId ?? this.sessionExerciseId,
      setNumber: setNumber ?? this.setNumber,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      rir: rir ?? this.rir,
      restSeconds: restSeconds ?? this.restSeconds,
      tempo: tempo ?? this.tempo,
      isUnilateralLeft: isUnilateralLeft ?? this.isUnilateralLeft,
      notes: notes ?? this.notes,
      loggedAt: loggedAt ?? this.loggedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionExerciseId.present) {
      map['session_exercise_id'] = Variable<String>(sessionExerciseId.value);
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (rir.present) {
      map['rir'] = Variable<int>(rir.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (tempo.present) {
      map['tempo'] = Variable<String>(tempo.value);
    }
    if (isUnilateralLeft.present) {
      map['is_unilateral_left'] = Variable<bool>(isUnilateralLeft.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (loggedAt.present) {
      map['logged_at'] = Variable<DateTime>(loggedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetsCompanion(')
          ..write('id: $id, ')
          ..write('sessionExerciseId: $sessionExerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('rir: $rir, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('tempo: $tempo, ')
          ..write('isUnilateralLeft: $isUnilateralLeft, ')
          ..write('notes: $notes, ')
          ..write('loggedAt: $loggedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HydrationMetadataTable extends HydrationMetadata
    with TableInfo<$HydrationMetadataTable, HydrationMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HydrationMetadataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta(
    'lastPulledAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPulledAt = GeneratedColumn<DateTime>(
    'last_pulled_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [entityTable, lastPulledAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hydration_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<HydrationMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(
          data['last_pulled_at']!,
          _lastPulledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPulledAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entityTable};
  @override
  HydrationMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HydrationMetadataRow(
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pulled_at'],
      )!,
    );
  }

  @override
  $HydrationMetadataTable createAlias(String alias) {
    return $HydrationMetadataTable(attachedDatabase, alias);
  }
}

class HydrationMetadataRow extends DataClass
    implements Insertable<HydrationMetadataRow> {
  final String entityTable;
  final DateTime lastPulledAt;
  const HydrationMetadataRow({
    required this.entityTable,
    required this.lastPulledAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity_table'] = Variable<String>(entityTable);
    map['last_pulled_at'] = Variable<DateTime>(lastPulledAt);
    return map;
  }

  HydrationMetadataCompanion toCompanion(bool nullToAbsent) {
    return HydrationMetadataCompanion(
      entityTable: Value(entityTable),
      lastPulledAt: Value(lastPulledAt),
    );
  }

  factory HydrationMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HydrationMetadataRow(
      entityTable: serializer.fromJson<String>(json['entityTable']),
      lastPulledAt: serializer.fromJson<DateTime>(json['lastPulledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entityTable': serializer.toJson<String>(entityTable),
      'lastPulledAt': serializer.toJson<DateTime>(lastPulledAt),
    };
  }

  HydrationMetadataRow copyWith({
    String? entityTable,
    DateTime? lastPulledAt,
  }) => HydrationMetadataRow(
    entityTable: entityTable ?? this.entityTable,
    lastPulledAt: lastPulledAt ?? this.lastPulledAt,
  );
  HydrationMetadataRow copyWithCompanion(HydrationMetadataCompanion data) {
    return HydrationMetadataRow(
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HydrationMetadataRow(')
          ..write('entityTable: $entityTable, ')
          ..write('lastPulledAt: $lastPulledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entityTable, lastPulledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HydrationMetadataRow &&
          other.entityTable == this.entityTable &&
          other.lastPulledAt == this.lastPulledAt);
}

class HydrationMetadataCompanion extends UpdateCompanion<HydrationMetadataRow> {
  final Value<String> entityTable;
  final Value<DateTime> lastPulledAt;
  final Value<int> rowid;
  const HydrationMetadataCompanion({
    this.entityTable = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HydrationMetadataCompanion.insert({
    required String entityTable,
    required DateTime lastPulledAt,
    this.rowid = const Value.absent(),
  }) : entityTable = Value(entityTable),
       lastPulledAt = Value(lastPulledAt);
  static Insertable<HydrationMetadataRow> custom({
    Expression<String>? entityTable,
    Expression<DateTime>? lastPulledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entityTable != null) 'entity_table': entityTable,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HydrationMetadataCompanion copyWith({
    Value<String>? entityTable,
    Value<DateTime>? lastPulledAt,
    Value<int>? rowid,
  }) {
    return HydrationMetadataCompanion(
      entityTable: entityTable ?? this.entityTable,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HydrationMetadataCompanion(')
          ..write('entityTable: $entityTable, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $SyncMetadataTable syncMetadata = $SyncMetadataTable(this);
  late final $PlansTable plans = $PlansTable(this);
  late final $PlanDaysTable planDays = $PlanDaysTable(this);
  late final $PlanPrescriptionsTable planPrescriptions =
      $PlanPrescriptionsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionExercisesTable sessionExercises = $SessionExercisesTable(
    this,
  );
  late final $SetsTable sets = $SetsTable(this);
  late final $HydrationMetadataTable hydrationMetadata =
      $HydrationMetadataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercises,
    syncMetadata,
    plans,
    planDays,
    planPrescriptions,
    sessions,
    sessionExercises,
    sets,
    hydrationMetadata,
  ];
}

typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      required String id,
      Value<String?> ownerUserId,
      required String source,
      Value<String?> sourceRef,
      required String name,
      Value<String> description,
      Value<String?> photoUrl,
      Value<String?> localPhotoPath,
      required String primaryMuscle,
      required List<String> secondaryMuscles,
      required String equipment,
      Value<bool> isUnilateral,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<String> id,
      Value<String?> ownerUserId,
      Value<String> source,
      Value<String?> sourceRef,
      Value<String> name,
      Value<String> description,
      Value<String?> photoUrl,
      Value<String?> localPhotoPath,
      Value<String> primaryMuscle,
      Value<List<String>> secondaryMuscles,
      Value<String> equipment,
      Value<bool> isUnilateral,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryMuscle => $composableBuilder(
    column: $table.primaryMuscle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnilateral => $composableBuilder(
    column: $table.isUnilateral,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceRef => $composableBuilder(
    column: $table.sourceRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoUrl => $composableBuilder(
    column: $table.photoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscle => $composableBuilder(
    column: $table.primaryMuscle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnilateral => $composableBuilder(
    column: $table.isUnilateral,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerUserId => $composableBuilder(
    column: $table.ownerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceRef =>
      $composableBuilder(column: $table.sourceRef, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<String> get localPhotoPath => $composableBuilder(
    column: $table.localPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryMuscle => $composableBuilder(
    column: $table.primaryMuscle,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<String>, String> get secondaryMuscles =>
      $composableBuilder(
        column: $table.secondaryMuscles,
        builder: (column) => column,
      );

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<bool> get isUnilateral => $composableBuilder(
    column: $table.isUnilateral,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          ExerciseRow,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (
            ExerciseRow,
            BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow>,
          ),
          ExerciseRow,
          PrefetchHooks Function()
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> ownerUserId = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> sourceRef = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> localPhotoPath = const Value.absent(),
                Value<String> primaryMuscle = const Value.absent(),
                Value<List<String>> secondaryMuscles = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<bool> isUnilateral = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                ownerUserId: ownerUserId,
                source: source,
                sourceRef: sourceRef,
                name: name,
                description: description,
                photoUrl: photoUrl,
                localPhotoPath: localPhotoPath,
                primaryMuscle: primaryMuscle,
                secondaryMuscles: secondaryMuscles,
                equipment: equipment,
                isUnilateral: isUnilateral,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> ownerUserId = const Value.absent(),
                required String source,
                Value<String?> sourceRef = const Value.absent(),
                required String name,
                Value<String> description = const Value.absent(),
                Value<String?> photoUrl = const Value.absent(),
                Value<String?> localPhotoPath = const Value.absent(),
                required String primaryMuscle,
                required List<String> secondaryMuscles,
                required String equipment,
                Value<bool> isUnilateral = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                ownerUserId: ownerUserId,
                source: source,
                sourceRef: sourceRef,
                name: name,
                description: description,
                photoUrl: photoUrl,
                localPhotoPath: localPhotoPath,
                primaryMuscle: primaryMuscle,
                secondaryMuscles: secondaryMuscles,
                equipment: equipment,
                isUnilateral: isUnilateral,
                isArchived: isArchived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      ExerciseRow,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (
        ExerciseRow,
        BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow>,
      ),
      ExerciseRow,
      PrefetchHooks Function()
    >;
typedef $$SyncMetadataTableCreateCompanionBuilder =
    SyncMetadataCompanion Function({
      required String id,
      required String entityTable,
      required String operation,
      Value<DateTime> queuedAt,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$SyncMetadataTableUpdateCompanionBuilder =
    SyncMetadataCompanion Function({
      Value<String> id,
      Value<String> entityTable,
      Value<String> operation,
      Value<DateTime> queuedAt,
      Value<int> attemptCount,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$SyncMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get queuedAt => $composableBuilder(
    column: $table.queuedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetadataTable> {
  $$SyncMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<DateTime> get queuedAt =>
      $composableBuilder(column: $table.queuedAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetadataTable,
          SyncMetadataRow,
          $$SyncMetadataTableFilterComposer,
          $$SyncMetadataTableOrderingComposer,
          $$SyncMetadataTableAnnotationComposer,
          $$SyncMetadataTableCreateCompanionBuilder,
          $$SyncMetadataTableUpdateCompanionBuilder,
          (
            SyncMetadataRow,
            BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataRow>,
          ),
          SyncMetadataRow,
          PrefetchHooks Function()
        > {
  $$SyncMetadataTableTableManager(_$AppDatabase db, $SyncMetadataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetadataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<DateTime> queuedAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion(
                id: id,
                entityTable: entityTable,
                operation: operation,
                queuedAt: queuedAt,
                attemptCount: attemptCount,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String entityTable,
                required String operation,
                Value<DateTime> queuedAt = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetadataCompanion.insert(
                id: id,
                entityTable: entityTable,
                operation: operation,
                queuedAt: queuedAt,
                attemptCount: attemptCount,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetadataTable,
      SyncMetadataRow,
      $$SyncMetadataTableFilterComposer,
      $$SyncMetadataTableOrderingComposer,
      $$SyncMetadataTableAnnotationComposer,
      $$SyncMetadataTableCreateCompanionBuilder,
      $$SyncMetadataTableUpdateCompanionBuilder,
      (
        SyncMetadataRow,
        BaseReferences<_$AppDatabase, $SyncMetadataTable, SyncMetadataRow>,
      ),
      SyncMetadataRow,
      PrefetchHooks Function()
    >;
typedef $$PlansTableCreateCompanionBuilder =
    PlansCompanion Function({
      required String id,
      required String userId,
      required String name,
      required String goal,
      Value<String?> packId,
      required String splitType,
      required int daysPerWeek,
      Value<bool> generatedByAi,
      Value<String?> aiReasoning,
      Value<bool> isActive,
      Value<DateTime?> startedAt,
      Value<DateTime?> endedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$PlansTableUpdateCompanionBuilder =
    PlansCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> goal,
      Value<String?> packId,
      Value<String> splitType,
      Value<int> daysPerWeek,
      Value<bool> generatedByAi,
      Value<String?> aiReasoning,
      Value<bool> isActive,
      Value<DateTime?> startedAt,
      Value<DateTime?> endedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PlansTableFilterComposer extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get splitType => $composableBuilder(
    column: $table.splitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get generatedByAi => $composableBuilder(
    column: $table.generatedByAi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiReasoning => $composableBuilder(
    column: $table.aiReasoning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlansTableOrderingComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packId => $composableBuilder(
    column: $table.packId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get splitType => $composableBuilder(
    column: $table.splitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get generatedByAi => $composableBuilder(
    column: $table.generatedByAi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiReasoning => $composableBuilder(
    column: $table.aiReasoning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlansTable> {
  $$PlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get packId =>
      $composableBuilder(column: $table.packId, builder: (column) => column);

  GeneratedColumn<String> get splitType =>
      $composableBuilder(column: $table.splitType, builder: (column) => column);

  GeneratedColumn<int> get daysPerWeek => $composableBuilder(
    column: $table.daysPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get generatedByAi => $composableBuilder(
    column: $table.generatedByAi,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiReasoning => $composableBuilder(
    column: $table.aiReasoning,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlansTable,
          PlanRow,
          $$PlansTableFilterComposer,
          $$PlansTableOrderingComposer,
          $$PlansTableAnnotationComposer,
          $$PlansTableCreateCompanionBuilder,
          $$PlansTableUpdateCompanionBuilder,
          (PlanRow, BaseReferences<_$AppDatabase, $PlansTable, PlanRow>),
          PlanRow,
          PrefetchHooks Function()
        > {
  $$PlansTableTableManager(_$AppDatabase db, $PlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<String?> packId = const Value.absent(),
                Value<String> splitType = const Value.absent(),
                Value<int> daysPerWeek = const Value.absent(),
                Value<bool> generatedByAi = const Value.absent(),
                Value<String?> aiReasoning = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion(
                id: id,
                userId: userId,
                name: name,
                goal: goal,
                packId: packId,
                splitType: splitType,
                daysPerWeek: daysPerWeek,
                generatedByAi: generatedByAi,
                aiReasoning: aiReasoning,
                isActive: isActive,
                startedAt: startedAt,
                endedAt: endedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required String goal,
                Value<String?> packId = const Value.absent(),
                required String splitType,
                required int daysPerWeek,
                Value<bool> generatedByAi = const Value.absent(),
                Value<String?> aiReasoning = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlansCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                goal: goal,
                packId: packId,
                splitType: splitType,
                daysPerWeek: daysPerWeek,
                generatedByAi: generatedByAi,
                aiReasoning: aiReasoning,
                isActive: isActive,
                startedAt: startedAt,
                endedAt: endedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlansTable,
      PlanRow,
      $$PlansTableFilterComposer,
      $$PlansTableOrderingComposer,
      $$PlansTableAnnotationComposer,
      $$PlansTableCreateCompanionBuilder,
      $$PlansTableUpdateCompanionBuilder,
      (PlanRow, BaseReferences<_$AppDatabase, $PlansTable, PlanRow>),
      PlanRow,
      PrefetchHooks Function()
    >;
typedef $$PlanDaysTableCreateCompanionBuilder =
    PlanDaysCompanion Function({
      required String id,
      required String planId,
      required int dayNumber,
      required String name,
      required String focus,
      Value<int> rowid,
    });
typedef $$PlanDaysTableUpdateCompanionBuilder =
    PlanDaysCompanion Function({
      Value<String> id,
      Value<String> planId,
      Value<int> dayNumber,
      Value<String> name,
      Value<String> focus,
      Value<int> rowid,
    });

class $$PlanDaysTableFilterComposer
    extends Composer<_$AppDatabase, $PlanDaysTable> {
  $$PlanDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanDaysTable> {
  $$PlanDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planId => $composableBuilder(
    column: $table.planId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayNumber => $composableBuilder(
    column: $table.dayNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get focus => $composableBuilder(
    column: $table.focus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanDaysTable> {
  $$PlanDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<int> get dayNumber =>
      $composableBuilder(column: $table.dayNumber, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get focus =>
      $composableBuilder(column: $table.focus, builder: (column) => column);
}

class $$PlanDaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanDaysTable,
          PlanDayRow,
          $$PlanDaysTableFilterComposer,
          $$PlanDaysTableOrderingComposer,
          $$PlanDaysTableAnnotationComposer,
          $$PlanDaysTableCreateCompanionBuilder,
          $$PlanDaysTableUpdateCompanionBuilder,
          (
            PlanDayRow,
            BaseReferences<_$AppDatabase, $PlanDaysTable, PlanDayRow>,
          ),
          PlanDayRow,
          PrefetchHooks Function()
        > {
  $$PlanDaysTableTableManager(_$AppDatabase db, $PlanDaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planId = const Value.absent(),
                Value<int> dayNumber = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> focus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanDaysCompanion(
                id: id,
                planId: planId,
                dayNumber: dayNumber,
                name: name,
                focus: focus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planId,
                required int dayNumber,
                required String name,
                required String focus,
                Value<int> rowid = const Value.absent(),
              }) => PlanDaysCompanion.insert(
                id: id,
                planId: planId,
                dayNumber: dayNumber,
                name: name,
                focus: focus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanDaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanDaysTable,
      PlanDayRow,
      $$PlanDaysTableFilterComposer,
      $$PlanDaysTableOrderingComposer,
      $$PlanDaysTableAnnotationComposer,
      $$PlanDaysTableCreateCompanionBuilder,
      $$PlanDaysTableUpdateCompanionBuilder,
      (PlanDayRow, BaseReferences<_$AppDatabase, $PlanDaysTable, PlanDayRow>),
      PlanDayRow,
      PrefetchHooks Function()
    >;
typedef $$PlanPrescriptionsTableCreateCompanionBuilder =
    PlanPrescriptionsCompanion Function({
      required String id,
      required String planDayId,
      required String exerciseId,
      required int order,
      required int targetSets,
      required int targetRepsMin,
      required int targetRepsMax,
      required int targetRir,
      required int targetRestSeconds,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$PlanPrescriptionsTableUpdateCompanionBuilder =
    PlanPrescriptionsCompanion Function({
      Value<String> id,
      Value<String> planDayId,
      Value<String> exerciseId,
      Value<int> order,
      Value<int> targetSets,
      Value<int> targetRepsMin,
      Value<int> targetRepsMax,
      Value<int> targetRir,
      Value<int> targetRestSeconds,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$PlanPrescriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanPrescriptionsTable> {
  $$PlanPrescriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planDayId => $composableBuilder(
    column: $table.planDayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRepsMin => $composableBuilder(
    column: $table.targetRepsMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRepsMax => $composableBuilder(
    column: $table.targetRepsMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRir => $composableBuilder(
    column: $table.targetRir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRestSeconds => $composableBuilder(
    column: $table.targetRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanPrescriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanPrescriptionsTable> {
  $$PlanPrescriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planDayId => $composableBuilder(
    column: $table.planDayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRepsMin => $composableBuilder(
    column: $table.targetRepsMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRepsMax => $composableBuilder(
    column: $table.targetRepsMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRir => $composableBuilder(
    column: $table.targetRir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRestSeconds => $composableBuilder(
    column: $table.targetRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanPrescriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanPrescriptionsTable> {
  $$PlanPrescriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planDayId =>
      $composableBuilder(column: $table.planDayId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetRepsMin => $composableBuilder(
    column: $table.targetRepsMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetRepsMax => $composableBuilder(
    column: $table.targetRepsMax,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetRir =>
      $composableBuilder(column: $table.targetRir, builder: (column) => column);

  GeneratedColumn<int> get targetRestSeconds => $composableBuilder(
    column: $table.targetRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$PlanPrescriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanPrescriptionsTable,
          PlanPrescriptionRow,
          $$PlanPrescriptionsTableFilterComposer,
          $$PlanPrescriptionsTableOrderingComposer,
          $$PlanPrescriptionsTableAnnotationComposer,
          $$PlanPrescriptionsTableCreateCompanionBuilder,
          $$PlanPrescriptionsTableUpdateCompanionBuilder,
          (
            PlanPrescriptionRow,
            BaseReferences<
              _$AppDatabase,
              $PlanPrescriptionsTable,
              PlanPrescriptionRow
            >,
          ),
          PlanPrescriptionRow,
          PrefetchHooks Function()
        > {
  $$PlanPrescriptionsTableTableManager(
    _$AppDatabase db,
    $PlanPrescriptionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanPrescriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanPrescriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanPrescriptionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> planDayId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int> targetRepsMin = const Value.absent(),
                Value<int> targetRepsMax = const Value.absent(),
                Value<int> targetRir = const Value.absent(),
                Value<int> targetRestSeconds = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanPrescriptionsCompanion(
                id: id,
                planDayId: planDayId,
                exerciseId: exerciseId,
                order: order,
                targetSets: targetSets,
                targetRepsMin: targetRepsMin,
                targetRepsMax: targetRepsMax,
                targetRir: targetRir,
                targetRestSeconds: targetRestSeconds,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String planDayId,
                required String exerciseId,
                required int order,
                required int targetSets,
                required int targetRepsMin,
                required int targetRepsMax,
                required int targetRir,
                required int targetRestSeconds,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanPrescriptionsCompanion.insert(
                id: id,
                planDayId: planDayId,
                exerciseId: exerciseId,
                order: order,
                targetSets: targetSets,
                targetRepsMin: targetRepsMin,
                targetRepsMax: targetRepsMax,
                targetRir: targetRir,
                targetRestSeconds: targetRestSeconds,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanPrescriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanPrescriptionsTable,
      PlanPrescriptionRow,
      $$PlanPrescriptionsTableFilterComposer,
      $$PlanPrescriptionsTableOrderingComposer,
      $$PlanPrescriptionsTableAnnotationComposer,
      $$PlanPrescriptionsTableCreateCompanionBuilder,
      $$PlanPrescriptionsTableUpdateCompanionBuilder,
      (
        PlanPrescriptionRow,
        BaseReferences<
          _$AppDatabase,
          $PlanPrescriptionsTable,
          PlanPrescriptionRow
        >,
      ),
      PlanPrescriptionRow,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      required String id,
      required String userId,
      Value<String?> planDayId,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<double?> bodyweight,
      Value<int?> heartRateAvg,
      Value<int?> heartRateMax,
      Value<int?> caloriesEst,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String?> planDayId,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<String> status,
      Value<double?> bodyweight,
      Value<int?> heartRateAvg,
      Value<int?> heartRateMax,
      Value<int?> caloriesEst,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planDayId => $composableBuilder(
    column: $table.planDayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bodyweight => $composableBuilder(
    column: $table.bodyweight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRateAvg => $composableBuilder(
    column: $table.heartRateAvg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heartRateMax => $composableBuilder(
    column: $table.heartRateMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get caloriesEst => $composableBuilder(
    column: $table.caloriesEst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planDayId => $composableBuilder(
    column: $table.planDayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bodyweight => $composableBuilder(
    column: $table.bodyweight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRateAvg => $composableBuilder(
    column: $table.heartRateAvg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heartRateMax => $composableBuilder(
    column: $table.heartRateMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get caloriesEst => $composableBuilder(
    column: $table.caloriesEst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get planDayId =>
      $composableBuilder(column: $table.planDayId, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get bodyweight => $composableBuilder(
    column: $table.bodyweight,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heartRateAvg => $composableBuilder(
    column: $table.heartRateAvg,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heartRateMax => $composableBuilder(
    column: $table.heartRateMax,
    builder: (column) => column,
  );

  GeneratedColumn<int> get caloriesEst => $composableBuilder(
    column: $table.caloriesEst,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (
            SessionRow,
            BaseReferences<_$AppDatabase, $SessionsTable, SessionRow>,
          ),
          SessionRow,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> planDayId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> bodyweight = const Value.absent(),
                Value<int?> heartRateAvg = const Value.absent(),
                Value<int?> heartRateMax = const Value.absent(),
                Value<int?> caloriesEst = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                userId: userId,
                planDayId: planDayId,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                bodyweight: bodyweight,
                heartRateAvg: heartRateAvg,
                heartRateMax: heartRateMax,
                caloriesEst: caloriesEst,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String?> planDayId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> bodyweight = const Value.absent(),
                Value<int?> heartRateAvg = const Value.absent(),
                Value<int?> heartRateMax = const Value.absent(),
                Value<int?> caloriesEst = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                userId: userId,
                planDayId: planDayId,
                startedAt: startedAt,
                endedAt: endedAt,
                status: status,
                bodyweight: bodyweight,
                heartRateAvg: heartRateAvg,
                heartRateMax: heartRateMax,
                caloriesEst: caloriesEst,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, BaseReferences<_$AppDatabase, $SessionsTable, SessionRow>),
      SessionRow,
      PrefetchHooks Function()
    >;
typedef $$SessionExercisesTableCreateCompanionBuilder =
    SessionExercisesCompanion Function({
      required String id,
      required String sessionId,
      required String exerciseId,
      required int order,
      Value<String> status,
      Value<String?> skipReason,
      Value<int> rowid,
    });
typedef $$SessionExercisesTableUpdateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<String> exerciseId,
      Value<int> order,
      Value<String> status,
      Value<String?> skipReason,
      Value<int> rowid,
    });

class $$SessionExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get order => $composableBuilder(
    column: $table.order,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get skipReason => $composableBuilder(
    column: $table.skipReason,
    builder: (column) => column,
  );
}

class $$SessionExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionExercisesTable,
          SessionExerciseRow,
          $$SessionExercisesTableFilterComposer,
          $$SessionExercisesTableOrderingComposer,
          $$SessionExercisesTableAnnotationComposer,
          $$SessionExercisesTableCreateCompanionBuilder,
          $$SessionExercisesTableUpdateCompanionBuilder,
          (
            SessionExerciseRow,
            BaseReferences<
              _$AppDatabase,
              $SessionExercisesTable,
              SessionExerciseRow
            >,
          ),
          SessionExerciseRow,
          PrefetchHooks Function()
        > {
  $$SessionExercisesTableTableManager(
    _$AppDatabase db,
    $SessionExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> order = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> skipReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExercisesCompanion(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                order: order,
                status: status,
                skipReason: skipReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required String exerciseId,
                required int order,
                Value<String> status = const Value.absent(),
                Value<String?> skipReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExercisesCompanion.insert(
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                order: order,
                status: status,
                skipReason: skipReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionExercisesTable,
      SessionExerciseRow,
      $$SessionExercisesTableFilterComposer,
      $$SessionExercisesTableOrderingComposer,
      $$SessionExercisesTableAnnotationComposer,
      $$SessionExercisesTableCreateCompanionBuilder,
      $$SessionExercisesTableUpdateCompanionBuilder,
      (
        SessionExerciseRow,
        BaseReferences<
          _$AppDatabase,
          $SessionExercisesTable,
          SessionExerciseRow
        >,
      ),
      SessionExerciseRow,
      PrefetchHooks Function()
    >;
typedef $$SetsTableCreateCompanionBuilder =
    SetsCompanion Function({
      required String id,
      required String sessionExerciseId,
      required int setNumber,
      Value<double?> weight,
      required int reps,
      Value<int?> rir,
      Value<int?> restSeconds,
      Value<String?> tempo,
      Value<bool?> isUnilateralLeft,
      Value<String?> notes,
      Value<DateTime> loggedAt,
      Value<int> rowid,
    });
typedef $$SetsTableUpdateCompanionBuilder =
    SetsCompanion Function({
      Value<String> id,
      Value<String> sessionExerciseId,
      Value<int> setNumber,
      Value<double?> weight,
      Value<int> reps,
      Value<int?> rir,
      Value<int?> restSeconds,
      Value<String?> tempo,
      Value<bool?> isUnilateralLeft,
      Value<String?> notes,
      Value<DateTime> loggedAt,
      Value<int> rowid,
    });

class $$SetsTableFilterComposer extends Composer<_$AppDatabase, $SetsTable> {
  $$SetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionExerciseId => $composableBuilder(
    column: $table.sessionExerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tempo => $composableBuilder(
    column: $table.tempo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnilateralLeft => $composableBuilder(
    column: $table.isUnilateralLeft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SetsTableOrderingComposer extends Composer<_$AppDatabase, $SetsTable> {
  $$SetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionExerciseId => $composableBuilder(
    column: $table.sessionExerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rir => $composableBuilder(
    column: $table.rir,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tempo => $composableBuilder(
    column: $table.tempo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnilateralLeft => $composableBuilder(
    column: $table.isUnilateralLeft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get loggedAt => $composableBuilder(
    column: $table.loggedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetsTable> {
  $$SetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionExerciseId => $composableBuilder(
    column: $table.sessionExerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get rir =>
      $composableBuilder(column: $table.rir, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tempo =>
      $composableBuilder(column: $table.tempo, builder: (column) => column);

  GeneratedColumn<bool> get isUnilateralLeft => $composableBuilder(
    column: $table.isUnilateralLeft,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get loggedAt =>
      $composableBuilder(column: $table.loggedAt, builder: (column) => column);
}

class $$SetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetsTable,
          SetRow,
          $$SetsTableFilterComposer,
          $$SetsTableOrderingComposer,
          $$SetsTableAnnotationComposer,
          $$SetsTableCreateCompanionBuilder,
          $$SetsTableUpdateCompanionBuilder,
          (SetRow, BaseReferences<_$AppDatabase, $SetsTable, SetRow>),
          SetRow,
          PrefetchHooks Function()
        > {
  $$SetsTableTableManager(_$AppDatabase db, $SetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionExerciseId = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int?> rir = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<String?> tempo = const Value.absent(),
                Value<bool?> isUnilateralLeft = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetsCompanion(
                id: id,
                sessionExerciseId: sessionExerciseId,
                setNumber: setNumber,
                weight: weight,
                reps: reps,
                rir: rir,
                restSeconds: restSeconds,
                tempo: tempo,
                isUnilateralLeft: isUnilateralLeft,
                notes: notes,
                loggedAt: loggedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionExerciseId,
                required int setNumber,
                Value<double?> weight = const Value.absent(),
                required int reps,
                Value<int?> rir = const Value.absent(),
                Value<int?> restSeconds = const Value.absent(),
                Value<String?> tempo = const Value.absent(),
                Value<bool?> isUnilateralLeft = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> loggedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SetsCompanion.insert(
                id: id,
                sessionExerciseId: sessionExerciseId,
                setNumber: setNumber,
                weight: weight,
                reps: reps,
                rir: rir,
                restSeconds: restSeconds,
                tempo: tempo,
                isUnilateralLeft: isUnilateralLeft,
                notes: notes,
                loggedAt: loggedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetsTable,
      SetRow,
      $$SetsTableFilterComposer,
      $$SetsTableOrderingComposer,
      $$SetsTableAnnotationComposer,
      $$SetsTableCreateCompanionBuilder,
      $$SetsTableUpdateCompanionBuilder,
      (SetRow, BaseReferences<_$AppDatabase, $SetsTable, SetRow>),
      SetRow,
      PrefetchHooks Function()
    >;
typedef $$HydrationMetadataTableCreateCompanionBuilder =
    HydrationMetadataCompanion Function({
      required String entityTable,
      required DateTime lastPulledAt,
      Value<int> rowid,
    });
typedef $$HydrationMetadataTableUpdateCompanionBuilder =
    HydrationMetadataCompanion Function({
      Value<String> entityTable,
      Value<DateTime> lastPulledAt,
      Value<int> rowid,
    });

class $$HydrationMetadataTableFilterComposer
    extends Composer<_$AppDatabase, $HydrationMetadataTable> {
  $$HydrationMetadataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HydrationMetadataTableOrderingComposer
    extends Composer<_$AppDatabase, $HydrationMetadataTable> {
  $$HydrationMetadataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HydrationMetadataTableAnnotationComposer
    extends Composer<_$AppDatabase, $HydrationMetadataTable> {
  $$HydrationMetadataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => column,
  );
}

class $$HydrationMetadataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HydrationMetadataTable,
          HydrationMetadataRow,
          $$HydrationMetadataTableFilterComposer,
          $$HydrationMetadataTableOrderingComposer,
          $$HydrationMetadataTableAnnotationComposer,
          $$HydrationMetadataTableCreateCompanionBuilder,
          $$HydrationMetadataTableUpdateCompanionBuilder,
          (
            HydrationMetadataRow,
            BaseReferences<
              _$AppDatabase,
              $HydrationMetadataTable,
              HydrationMetadataRow
            >,
          ),
          HydrationMetadataRow,
          PrefetchHooks Function()
        > {
  $$HydrationMetadataTableTableManager(
    _$AppDatabase db,
    $HydrationMetadataTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HydrationMetadataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HydrationMetadataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HydrationMetadataTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> entityTable = const Value.absent(),
                Value<DateTime> lastPulledAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HydrationMetadataCompanion(
                entityTable: entityTable,
                lastPulledAt: lastPulledAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entityTable,
                required DateTime lastPulledAt,
                Value<int> rowid = const Value.absent(),
              }) => HydrationMetadataCompanion.insert(
                entityTable: entityTable,
                lastPulledAt: lastPulledAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HydrationMetadataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HydrationMetadataTable,
      HydrationMetadataRow,
      $$HydrationMetadataTableFilterComposer,
      $$HydrationMetadataTableOrderingComposer,
      $$HydrationMetadataTableAnnotationComposer,
      $$HydrationMetadataTableCreateCompanionBuilder,
      $$HydrationMetadataTableUpdateCompanionBuilder,
      (
        HydrationMetadataRow,
        BaseReferences<
          _$AppDatabase,
          $HydrationMetadataTable,
          HydrationMetadataRow
        >,
      ),
      HydrationMetadataRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$SyncMetadataTableTableManager get syncMetadata =>
      $$SyncMetadataTableTableManager(_db, _db.syncMetadata);
  $$PlansTableTableManager get plans =>
      $$PlansTableTableManager(_db, _db.plans);
  $$PlanDaysTableTableManager get planDays =>
      $$PlanDaysTableTableManager(_db, _db.planDays);
  $$PlanPrescriptionsTableTableManager get planPrescriptions =>
      $$PlanPrescriptionsTableTableManager(_db, _db.planPrescriptions);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(_db, _db.sessionExercises);
  $$SetsTableTableManager get sets => $$SetsTableTableManager(_db, _db.sets);
  $$HydrationMetadataTableTableManager get hydrationMetadata =>
      $$HydrationMetadataTableTableManager(_db, _db.hydrationMetadata);
}
