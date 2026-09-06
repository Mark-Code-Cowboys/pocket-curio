// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
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
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CollectionKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CollectionKind>($CollectionsTable.$converterkind);
  static const VerificationMeta _otherLabelMeta = const VerificationMeta(
    'otherLabel',
  );
  @override
  late final GeneratedColumn<String> otherLabel = GeneratedColumn<String>(
    'other_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPhotoPathMeta = const VerificationMeta(
    'coverPhotoPath',
  );
  @override
  late final GeneratedColumn<String> coverPhotoPath = GeneratedColumn<String>(
    'cover_photo_path',
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
    id,
    name,
    kind,
    otherLabel,
    coverPhotoPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
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
    if (data.containsKey('other_label')) {
      context.handle(
        _otherLabelMeta,
        otherLabel.isAcceptableOrUnknown(data['other_label']!, _otherLabelMeta),
      );
    }
    if (data.containsKey('cover_photo_path')) {
      context.handle(
        _coverPhotoPathMeta,
        coverPhotoPath.isAcceptableOrUnknown(
          data['cover_photo_path']!,
          _coverPhotoPathMeta,
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
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $CollectionsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      otherLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}other_label'],
      ),
      coverPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_photo_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CollectionKind, String, String> $converterkind =
      const EnumNameConverter<CollectionKind>(CollectionKind.values);
}

class Collection extends DataClass implements Insertable<Collection> {
  final int id;
  final String name;
  final CollectionKind kind;
  final String? otherLabel;
  final String? coverPhotoPath;
  final DateTime createdAt;
  const Collection({
    required this.id,
    required this.name,
    required this.kind,
    this.otherLabel,
    this.coverPhotoPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $CollectionsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || otherLabel != null) {
      map['other_label'] = Variable<String>(otherLabel);
    }
    if (!nullToAbsent || coverPhotoPath != null) {
      map['cover_photo_path'] = Variable<String>(coverPhotoPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      otherLabel: otherLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(otherLabel),
      coverPhotoPath: coverPhotoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPhotoPath),
      createdAt: Value(createdAt),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: $CollectionsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      otherLabel: serializer.fromJson<String?>(json['otherLabel']),
      coverPhotoPath: serializer.fromJson<String?>(json['coverPhotoPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $CollectionsTable.$converterkind.toJson(kind),
      ),
      'otherLabel': serializer.toJson<String?>(otherLabel),
      'coverPhotoPath': serializer.toJson<String?>(coverPhotoPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Collection copyWith({
    int? id,
    String? name,
    CollectionKind? kind,
    Value<String?> otherLabel = const Value.absent(),
    Value<String?> coverPhotoPath = const Value.absent(),
    DateTime? createdAt,
  }) => Collection(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    otherLabel: otherLabel.present ? otherLabel.value : this.otherLabel,
    coverPhotoPath: coverPhotoPath.present
        ? coverPhotoPath.value
        : this.coverPhotoPath,
    createdAt: createdAt ?? this.createdAt,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      otherLabel: data.otherLabel.present
          ? data.otherLabel.value
          : this.otherLabel,
      coverPhotoPath: data.coverPhotoPath.present
          ? data.coverPhotoPath.value
          : this.coverPhotoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('otherLabel: $otherLabel, ')
          ..write('coverPhotoPath: $coverPhotoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, kind, otherLabel, coverPhotoPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.otherLabel == this.otherLabel &&
          other.coverPhotoPath == this.coverPhotoPath &&
          other.createdAt == this.createdAt);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<int> id;
  final Value<String> name;
  final Value<CollectionKind> kind;
  final Value<String?> otherLabel;
  final Value<String?> coverPhotoPath;
  final Value<DateTime> createdAt;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.otherLabel = const Value.absent(),
    this.coverPhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required CollectionKind kind,
    this.otherLabel = const Value.absent(),
    this.coverPhotoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind);
  static Insertable<Collection> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? otherLabel,
    Expression<String>? coverPhotoPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (otherLabel != null) 'other_label': otherLabel,
      if (coverPhotoPath != null) 'cover_photo_path': coverPhotoPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CollectionsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<CollectionKind>? kind,
    Value<String?>? otherLabel,
    Value<String?>? coverPhotoPath,
    Value<DateTime>? createdAt,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      otherLabel: otherLabel ?? this.otherLabel,
      coverPhotoPath: coverPhotoPath ?? this.coverPhotoPath,
      createdAt: createdAt ?? this.createdAt,
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
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CollectionsTable.$converterkind.toSql(kind.value),
      );
    }
    if (otherLabel.present) {
      map['other_label'] = Variable<String>(otherLabel.value);
    }
    if (coverPhotoPath.present) {
      map['cover_photo_path'] = Variable<String>(coverPhotoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('otherLabel: $otherLabel, ')
          ..write('coverPhotoPath: $coverPhotoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppJournalEntriesTable extends AppJournalEntries
    with TableInfo<$AppJournalEntriesTable, JournalEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppJournalEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    check: () => ComparableExpr(rating).isBetweenValues(1, 5),
    type: DriftSqlType.int,
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
  List<GeneratedColumn> get $columns => [id, notes, rating, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
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
  JournalEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AppJournalEntriesTable createAlias(String alias) {
    return $AppJournalEntriesTable(attachedDatabase, alias);
  }
}

class AppJournalEntriesCompanion extends UpdateCompanion<JournalEntry> {
  final Value<int> id;
  final Value<String?> notes;
  final Value<int?> rating;
  final Value<DateTime> createdAt;
  const AppJournalEntriesCompanion({
    this.id = const Value.absent(),
    this.notes = const Value.absent(),
    this.rating = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AppJournalEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.notes = const Value.absent(),
    this.rating = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<JournalEntry> custom({
    Expression<int>? id,
    Expression<String>? notes,
    Expression<int>? rating,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notes != null) 'notes': notes,
      if (rating != null) 'rating': rating,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AppJournalEntriesCompanion copyWith({
    Value<int>? id,
    Value<String?>? notes,
    Value<int?>? rating,
    Value<DateTime>? createdAt,
  }) {
    return AppJournalEntriesCompanion(
      id: id ?? this.id,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppJournalEntriesCompanion(')
          ..write('id: $id, ')
          ..write('notes: $notes, ')
          ..write('rating: $rating, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<int> collectionId = GeneratedColumn<int>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 160,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateAcquiredMeta = const VerificationMeta(
    'dateAcquired',
  );
  @override
  late final GeneratedColumn<DateTime> dateAcquired = GeneratedColumn<DateTime>(
    'date_acquired',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tripOrOccasionMeta = const VerificationMeta(
    'tripOrOccasion',
  );
  @override
  late final GeneratedColumn<String> tripOrOccasion = GeneratedColumn<String>(
    'trip_or_occasion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _whoGaveItMeta = const VerificationMeta(
    'whoGaveIt',
  );
  @override
  late final GeneratedColumn<String> whoGaveIt = GeneratedColumn<String>(
    'who_gave_it',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
  static const VerificationMeta _journalEntryIdMeta = const VerificationMeta(
    'journalEntryId',
  );
  @override
  late final GeneratedColumn<int> journalEntryId = GeneratedColumn<int>(
    'journal_entry_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    collectionId,
    photoPath,
    place,
    city,
    state,
    country,
    dateAcquired,
    tripOrOccasion,
    whoGaveIt,
    lat,
    lng,
    createdAt,
    journalEntryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<Item> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    } else if (isInserting) {
      context.missing(_photoPathMeta);
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    } else if (isInserting) {
      context.missing(_placeMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('date_acquired')) {
      context.handle(
        _dateAcquiredMeta,
        dateAcquired.isAcceptableOrUnknown(
          data['date_acquired']!,
          _dateAcquiredMeta,
        ),
      );
    }
    if (data.containsKey('trip_or_occasion')) {
      context.handle(
        _tripOrOccasionMeta,
        tripOrOccasion.isAcceptableOrUnknown(
          data['trip_or_occasion']!,
          _tripOrOccasionMeta,
        ),
      );
    }
    if (data.containsKey('who_gave_it')) {
      context.handle(
        _whoGaveItMeta,
        whoGaveIt.isAcceptableOrUnknown(data['who_gave_it']!, _whoGaveItMeta),
      );
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('journal_entry_id')) {
      context.handle(
        _journalEntryIdMeta,
        journalEntryId.isAcceptableOrUnknown(
          data['journal_entry_id']!,
          _journalEntryIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collection_id'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      )!,
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      dateAcquired: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_acquired'],
      ),
      tripOrOccasion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_or_occasion'],
      ),
      whoGaveIt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}who_gave_it'],
      ),
      lat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lat'],
      ),
      lng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}lng'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      journalEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}journal_entry_id'],
      ),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final int id;
  final int collectionId;
  final String photoPath;
  final String place;
  final String? city;
  final String? state;
  final String? country;
  final DateTime? dateAcquired;
  final String? tripOrOccasion;
  final String? whoGaveIt;
  final double? lat;
  final double? lng;
  final DateTime createdAt;
  final int? journalEntryId;
  const Item({
    required this.id,
    required this.collectionId,
    required this.photoPath,
    required this.place,
    this.city,
    this.state,
    this.country,
    this.dateAcquired,
    this.tripOrOccasion,
    this.whoGaveIt,
    this.lat,
    this.lng,
    required this.createdAt,
    this.journalEntryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['collection_id'] = Variable<int>(collectionId);
    map['photo_path'] = Variable<String>(photoPath);
    map['place'] = Variable<String>(place);
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || dateAcquired != null) {
      map['date_acquired'] = Variable<DateTime>(dateAcquired);
    }
    if (!nullToAbsent || tripOrOccasion != null) {
      map['trip_or_occasion'] = Variable<String>(tripOrOccasion);
    }
    if (!nullToAbsent || whoGaveIt != null) {
      map['who_gave_it'] = Variable<String>(whoGaveIt);
    }
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || journalEntryId != null) {
      map['journal_entry_id'] = Variable<int>(journalEntryId);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      photoPath: Value(photoPath),
      place: Value(place),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      dateAcquired: dateAcquired == null && nullToAbsent
          ? const Value.absent()
          : Value(dateAcquired),
      tripOrOccasion: tripOrOccasion == null && nullToAbsent
          ? const Value.absent()
          : Value(tripOrOccasion),
      whoGaveIt: whoGaveIt == null && nullToAbsent
          ? const Value.absent()
          : Value(whoGaveIt),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
      createdAt: Value(createdAt),
      journalEntryId: journalEntryId == null && nullToAbsent
          ? const Value.absent()
          : Value(journalEntryId),
    );
  }

  factory Item.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<int>(json['id']),
      collectionId: serializer.fromJson<int>(json['collectionId']),
      photoPath: serializer.fromJson<String>(json['photoPath']),
      place: serializer.fromJson<String>(json['place']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      country: serializer.fromJson<String?>(json['country']),
      dateAcquired: serializer.fromJson<DateTime?>(json['dateAcquired']),
      tripOrOccasion: serializer.fromJson<String?>(json['tripOrOccasion']),
      whoGaveIt: serializer.fromJson<String?>(json['whoGaveIt']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      journalEntryId: serializer.fromJson<int?>(json['journalEntryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'collectionId': serializer.toJson<int>(collectionId),
      'photoPath': serializer.toJson<String>(photoPath),
      'place': serializer.toJson<String>(place),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'country': serializer.toJson<String?>(country),
      'dateAcquired': serializer.toJson<DateTime?>(dateAcquired),
      'tripOrOccasion': serializer.toJson<String?>(tripOrOccasion),
      'whoGaveIt': serializer.toJson<String?>(whoGaveIt),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'journalEntryId': serializer.toJson<int?>(journalEntryId),
    };
  }

  Item copyWith({
    int? id,
    int? collectionId,
    String? photoPath,
    String? place,
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<DateTime?> dateAcquired = const Value.absent(),
    Value<String?> tripOrOccasion = const Value.absent(),
    Value<String?> whoGaveIt = const Value.absent(),
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    DateTime? createdAt,
    Value<int?> journalEntryId = const Value.absent(),
  }) => Item(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    photoPath: photoPath ?? this.photoPath,
    place: place ?? this.place,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    country: country.present ? country.value : this.country,
    dateAcquired: dateAcquired.present ? dateAcquired.value : this.dateAcquired,
    tripOrOccasion: tripOrOccasion.present
        ? tripOrOccasion.value
        : this.tripOrOccasion,
    whoGaveIt: whoGaveIt.present ? whoGaveIt.value : this.whoGaveIt,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    createdAt: createdAt ?? this.createdAt,
    journalEntryId: journalEntryId.present
        ? journalEntryId.value
        : this.journalEntryId,
  );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      place: data.place.present ? data.place.value : this.place,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      country: data.country.present ? data.country.value : this.country,
      dateAcquired: data.dateAcquired.present
          ? data.dateAcquired.value
          : this.dateAcquired,
      tripOrOccasion: data.tripOrOccasion.present
          ? data.tripOrOccasion.value
          : this.tripOrOccasion,
      whoGaveIt: data.whoGaveIt.present ? data.whoGaveIt.value : this.whoGaveIt,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      journalEntryId: data.journalEntryId.present
          ? data.journalEntryId.value
          : this.journalEntryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('photoPath: $photoPath, ')
          ..write('place: $place, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('country: $country, ')
          ..write('dateAcquired: $dateAcquired, ')
          ..write('tripOrOccasion: $tripOrOccasion, ')
          ..write('whoGaveIt: $whoGaveIt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('createdAt: $createdAt, ')
          ..write('journalEntryId: $journalEntryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    collectionId,
    photoPath,
    place,
    city,
    state,
    country,
    dateAcquired,
    tripOrOccasion,
    whoGaveIt,
    lat,
    lng,
    createdAt,
    journalEntryId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.photoPath == this.photoPath &&
          other.place == this.place &&
          other.city == this.city &&
          other.state == this.state &&
          other.country == this.country &&
          other.dateAcquired == this.dateAcquired &&
          other.tripOrOccasion == this.tripOrOccasion &&
          other.whoGaveIt == this.whoGaveIt &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.createdAt == this.createdAt &&
          other.journalEntryId == this.journalEntryId);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<int> id;
  final Value<int> collectionId;
  final Value<String> photoPath;
  final Value<String> place;
  final Value<String?> city;
  final Value<String?> state;
  final Value<String?> country;
  final Value<DateTime?> dateAcquired;
  final Value<String?> tripOrOccasion;
  final Value<String?> whoGaveIt;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<DateTime> createdAt;
  final Value<int?> journalEntryId;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.place = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.country = const Value.absent(),
    this.dateAcquired = const Value.absent(),
    this.tripOrOccasion = const Value.absent(),
    this.whoGaveIt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.journalEntryId = const Value.absent(),
  });
  ItemsCompanion.insert({
    this.id = const Value.absent(),
    required int collectionId,
    required String photoPath,
    required String place,
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.country = const Value.absent(),
    this.dateAcquired = const Value.absent(),
    this.tripOrOccasion = const Value.absent(),
    this.whoGaveIt = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.journalEntryId = const Value.absent(),
  }) : collectionId = Value(collectionId),
       photoPath = Value(photoPath),
       place = Value(place);
  static Insertable<Item> custom({
    Expression<int>? id,
    Expression<int>? collectionId,
    Expression<String>? photoPath,
    Expression<String>? place,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? country,
    Expression<DateTime>? dateAcquired,
    Expression<String>? tripOrOccasion,
    Expression<String>? whoGaveIt,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<DateTime>? createdAt,
    Expression<int>? journalEntryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (photoPath != null) 'photo_path': photoPath,
      if (place != null) 'place': place,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (dateAcquired != null) 'date_acquired': dateAcquired,
      if (tripOrOccasion != null) 'trip_or_occasion': tripOrOccasion,
      if (whoGaveIt != null) 'who_gave_it': whoGaveIt,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (createdAt != null) 'created_at': createdAt,
      if (journalEntryId != null) 'journal_entry_id': journalEntryId,
    });
  }

  ItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? collectionId,
    Value<String>? photoPath,
    Value<String>? place,
    Value<String?>? city,
    Value<String?>? state,
    Value<String?>? country,
    Value<DateTime?>? dateAcquired,
    Value<String?>? tripOrOccasion,
    Value<String?>? whoGaveIt,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<DateTime>? createdAt,
    Value<int?>? journalEntryId,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      photoPath: photoPath ?? this.photoPath,
      place: place ?? this.place,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      dateAcquired: dateAcquired ?? this.dateAcquired,
      tripOrOccasion: tripOrOccasion ?? this.tripOrOccasion,
      whoGaveIt: whoGaveIt ?? this.whoGaveIt,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      createdAt: createdAt ?? this.createdAt,
      journalEntryId: journalEntryId ?? this.journalEntryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<int>(collectionId.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (dateAcquired.present) {
      map['date_acquired'] = Variable<DateTime>(dateAcquired.value);
    }
    if (tripOrOccasion.present) {
      map['trip_or_occasion'] = Variable<String>(tripOrOccasion.value);
    }
    if (whoGaveIt.present) {
      map['who_gave_it'] = Variable<String>(whoGaveIt.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (journalEntryId.present) {
      map['journal_entry_id'] = Variable<int>(journalEntryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('photoPath: $photoPath, ')
          ..write('place: $place, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('country: $country, ')
          ..write('dateAcquired: $dateAcquired, ')
          ..write('tripOrOccasion: $tripOrOccasion, ')
          ..write('whoGaveIt: $whoGaveIt, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('createdAt: $createdAt, ')
          ..write('journalEntryId: $journalEntryId')
          ..write(')'))
        .toString();
  }
}

class $AppJournalPhotosTable extends AppJournalPhotos
    with TableInfo<$AppJournalPhotosTable, JournalPhoto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppJournalPhotosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _captionMeta = const VerificationMeta(
    'caption',
  );
  @override
  late final GeneratedColumn<String> caption = GeneratedColumn<String>(
    'caption',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, entryId, path, caption];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalPhoto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('caption')) {
      context.handle(
        _captionMeta,
        caption.isAcceptableOrUnknown(data['caption']!, _captionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JournalPhoto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalPhoto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      caption: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}caption'],
      ),
    );
  }

  @override
  $AppJournalPhotosTable createAlias(String alias) {
    return $AppJournalPhotosTable(attachedDatabase, alias);
  }
}

class AppJournalPhotosCompanion extends UpdateCompanion<JournalPhoto> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<String> path;
  final Value<String?> caption;
  const AppJournalPhotosCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.path = const Value.absent(),
    this.caption = const Value.absent(),
  });
  AppJournalPhotosCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required String path,
    this.caption = const Value.absent(),
  }) : entryId = Value(entryId),
       path = Value(path);
  static Insertable<JournalPhoto> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? path,
    Expression<String>? caption,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (path != null) 'path': path,
      if (caption != null) 'caption': caption,
    });
  }

  AppJournalPhotosCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<String>? path,
    Value<String?>? caption,
  }) {
    return AppJournalPhotosCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      path: path ?? this.path,
      caption: caption ?? this.caption,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (caption.present) {
      map['caption'] = Variable<String>(caption.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppJournalPhotosCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('path: $path, ')
          ..write('caption: $caption')
          ..write(')'))
        .toString();
  }
}

class $AppJournalTagsTable extends AppJournalTags
    with TableInfo<$AppJournalTagsTable, JournalTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppJournalTagsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagMeta = const VerificationMeta('tag');
  @override
  late final GeneratedColumn<String> tag = GeneratedColumn<String>(
    'tag',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, entryId, tag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'journal_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<JournalTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('tag')) {
      context.handle(
        _tagMeta,
        tag.isAcceptableOrUnknown(data['tag']!, _tagMeta),
      );
    } else if (isInserting) {
      context.missing(_tagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entryId, tag},
  ];
  @override
  JournalTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JournalTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      tag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag'],
      )!,
    );
  }

  @override
  $AppJournalTagsTable createAlias(String alias) {
    return $AppJournalTagsTable(attachedDatabase, alias);
  }
}

class AppJournalTagsCompanion extends UpdateCompanion<JournalTag> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<String> tag;
  const AppJournalTagsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.tag = const Value.absent(),
  });
  AppJournalTagsCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required String tag,
  }) : entryId = Value(entryId),
       tag = Value(tag);
  static Insertable<JournalTag> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<String>? tag,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (tag != null) 'tag': tag,
    });
  }

  AppJournalTagsCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<String>? tag,
  }) {
    return AppJournalTagsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      tag: tag ?? this.tag,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (tag.present) {
      map['tag'] = Variable<String>(tag.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppJournalTagsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('tag: $tag')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $AppJournalEntriesTable appJournalEntries =
      $AppJournalEntriesTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $AppJournalPhotosTable appJournalPhotos = $AppJournalPhotosTable(
    this,
  );
  late final $AppJournalTagsTable appJournalTags = $AppJournalTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    collections,
    appJournalEntries,
    items,
    appJournalPhotos,
    appJournalTags,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'collections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      required String name,
      required CollectionKind kind,
      Value<String?> otherLabel,
      Value<String?> coverPhotoPath,
      Value<DateTime> createdAt,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<CollectionKind> kind,
      Value<String?> otherLabel,
      Value<String?> coverPhotoPath,
      Value<DateTime> createdAt,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemsTable, List<Item>> _itemsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.items,
    aliasName: 'collections__id__items__collection_id',
  );

  $$ItemsTableProcessedTableManager get itemsRefs {
    final manager = $$ItemsTableTableManager(
      $_db,
      $_db.items,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CollectionKind, CollectionKind, String>
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get otherLabel => $composableBuilder(
    column: $table.otherLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPhotoPath => $composableBuilder(
    column: $table.coverPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> itemsRefs(
    Expression<bool> Function($$ItemsTableFilterComposer f) f,
  ) {
    final $$ItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableFilterComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get otherLabel => $composableBuilder(
    column: $table.otherLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPhotoPath => $composableBuilder(
    column: $table.coverPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<CollectionKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get otherLabel => $composableBuilder(
    column: $table.otherLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPhotoPath => $composableBuilder(
    column: $table.coverPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> itemsRefs<T extends Object>(
    Expression<T> Function($$ItemsTableAnnotationComposer a) f,
  ) {
    final $$ItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.items,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.items,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (Collection, $$CollectionsTableReferences),
          Collection,
          PrefetchHooks Function({bool itemsRefs})
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<CollectionKind> kind = const Value.absent(),
                Value<String?> otherLabel = const Value.absent(),
                Value<String?> coverPhotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                kind: kind,
                otherLabel: otherLabel,
                coverPhotoPath: coverPhotoPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required CollectionKind kind,
                Value<String?> otherLabel = const Value.absent(),
                Value<String?> coverPhotoPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                otherLabel: otherLabel,
                coverPhotoPath: coverPhotoPath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, Collection>(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemsRefs) db.items],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemsRefs)
                    await $_getPrefetchedData<
                      Collection,
                      $CollectionsTable,
                      Item
                    >(
                      currentTable: table,
                      referencedTable: $$CollectionsTableReferences
                          ._itemsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CollectionsTableReferences(db, table, p0).itemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.collectionId == item.id,
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

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (Collection, $$CollectionsTableReferences),
      Collection,
      PrefetchHooks Function({bool itemsRefs})
    >;
typedef $$AppJournalEntriesTableCreateCompanionBuilder =
    AppJournalEntriesCompanion Function({
      Value<int> id,
      Value<String?> notes,
      Value<int?> rating,
      Value<DateTime> createdAt,
    });
typedef $$AppJournalEntriesTableUpdateCompanionBuilder =
    AppJournalEntriesCompanion Function({
      Value<int> id,
      Value<String?> notes,
      Value<int?> rating,
      Value<DateTime> createdAt,
    });

class $$AppJournalEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppJournalEntriesTable> {
  $$AppJournalEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppJournalEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppJournalEntriesTable> {
  $$AppJournalEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppJournalEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppJournalEntriesTable> {
  $$AppJournalEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AppJournalEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppJournalEntriesTable,
          JournalEntry,
          $$AppJournalEntriesTableFilterComposer,
          $$AppJournalEntriesTableOrderingComposer,
          $$AppJournalEntriesTableAnnotationComposer,
          $$AppJournalEntriesTableCreateCompanionBuilder,
          $$AppJournalEntriesTableUpdateCompanionBuilder,
          (
            JournalEntry,
            BaseReferences<
              _$AppDatabase,
              $AppJournalEntriesTable,
              JournalEntry
            >,
          ),
          JournalEntry,
          PrefetchHooks Function()
        > {
  $$AppJournalEntriesTableTableManager(
    _$AppDatabase db,
    $AppJournalEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppJournalEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppJournalEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppJournalEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppJournalEntriesCompanion(
                id: id,
                notes: notes,
                rating: rating,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppJournalEntriesCompanion.insert(
                id: id,
                notes: notes,
                rating: rating,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppJournalEntriesTable, JournalEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppJournalEntriesTable,
                    JournalEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppJournalEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppJournalEntriesTable,
      JournalEntry,
      $$AppJournalEntriesTableFilterComposer,
      $$AppJournalEntriesTableOrderingComposer,
      $$AppJournalEntriesTableAnnotationComposer,
      $$AppJournalEntriesTableCreateCompanionBuilder,
      $$AppJournalEntriesTableUpdateCompanionBuilder,
      (
        JournalEntry,
        BaseReferences<_$AppDatabase, $AppJournalEntriesTable, JournalEntry>,
      ),
      JournalEntry,
      PrefetchHooks Function()
    >;
typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      required int collectionId,
      required String photoPath,
      required String place,
      Value<String?> city,
      Value<String?> state,
      Value<String?> country,
      Value<DateTime?> dateAcquired,
      Value<String?> tripOrOccasion,
      Value<String?> whoGaveIt,
      Value<double?> lat,
      Value<double?> lng,
      Value<DateTime> createdAt,
      Value<int?> journalEntryId,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<int> id,
      Value<int> collectionId,
      Value<String> photoPath,
      Value<String> place,
      Value<String?> city,
      Value<String?> state,
      Value<String?> country,
      Value<DateTime?> dateAcquired,
      Value<String?> tripOrOccasion,
      Value<String?> whoGaveIt,
      Value<double?> lat,
      Value<double?> lng,
      Value<DateTime> createdAt,
      Value<int?> journalEntryId,
    });

final class $$ItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemsTable, Item> {
  $$ItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias('items__collection_id__collections__id');

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<int>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateAcquired => $composableBuilder(
    column: $table.dateAcquired,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripOrOccasion => $composableBuilder(
    column: $table.tripOrOccasion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get whoGaveIt => $composableBuilder(
    column: $table.whoGaveIt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnFilters(column),
  );

  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateAcquired => $composableBuilder(
    column: $table.dateAcquired,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripOrOccasion => $composableBuilder(
    column: $table.tripOrOccasion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get whoGaveIt => $composableBuilder(
    column: $table.whoGaveIt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<DateTime> get dateAcquired => $composableBuilder(
    column: $table.dateAcquired,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tripOrOccasion => $composableBuilder(
    column: $table.tripOrOccasion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get whoGaveIt =>
      $composableBuilder(column: $table.whoGaveIt, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get journalEntryId => $composableBuilder(
    column: $table.journalEntryId,
    builder: (column) => column,
  );

  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          Item,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (Item, $$ItemsTableReferences),
          Item,
          PrefetchHooks Function({bool collectionId})
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> collectionId = const Value.absent(),
                Value<String> photoPath = const Value.absent(),
                Value<String> place = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<DateTime?> dateAcquired = const Value.absent(),
                Value<String?> tripOrOccasion = const Value.absent(),
                Value<String?> whoGaveIt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> journalEntryId = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                collectionId: collectionId,
                photoPath: photoPath,
                place: place,
                city: city,
                state: state,
                country: country,
                dateAcquired: dateAcquired,
                tripOrOccasion: tripOrOccasion,
                whoGaveIt: whoGaveIt,
                lat: lat,
                lng: lng,
                createdAt: createdAt,
                journalEntryId: journalEntryId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int collectionId,
                required String photoPath,
                required String place,
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<DateTime?> dateAcquired = const Value.absent(),
                Value<String?> tripOrOccasion = const Value.absent(),
                Value<String?> whoGaveIt = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> journalEntryId = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                collectionId: collectionId,
                photoPath: photoPath,
                place: place,
                city: city,
                state: state,
                country: country,
                dateAcquired: dateAcquired,
                tripOrOccasion: tripOrOccasion,
                whoGaveIt: whoGaveIt,
                lat: lat,
                lng: lng,
                createdAt: createdAt,
                journalEntryId: journalEntryId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItemsTable, Item>(table),
                  $$ItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false}) {
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
                    if (collectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.collectionId,
                                referencedTable: $$ItemsTableReferences
                                    ._collectionIdTable(db),
                                referencedColumn: $$ItemsTableReferences
                                    ._collectionIdTable(db)
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

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      Item,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (Item, $$ItemsTableReferences),
      Item,
      PrefetchHooks Function({bool collectionId})
    >;
typedef $$AppJournalPhotosTableCreateCompanionBuilder =
    AppJournalPhotosCompanion Function({
      Value<int> id,
      required int entryId,
      required String path,
      Value<String?> caption,
    });
typedef $$AppJournalPhotosTableUpdateCompanionBuilder =
    AppJournalPhotosCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<String> path,
      Value<String?> caption,
    });

class $$AppJournalPhotosTableFilterComposer
    extends Composer<_$AppDatabase, $AppJournalPhotosTable> {
  $$AppJournalPhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppJournalPhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $AppJournalPhotosTable> {
  $$AppJournalPhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get caption => $composableBuilder(
    column: $table.caption,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppJournalPhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppJournalPhotosTable> {
  $$AppJournalPhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get caption =>
      $composableBuilder(column: $table.caption, builder: (column) => column);
}

class $$AppJournalPhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppJournalPhotosTable,
          JournalPhoto,
          $$AppJournalPhotosTableFilterComposer,
          $$AppJournalPhotosTableOrderingComposer,
          $$AppJournalPhotosTableAnnotationComposer,
          $$AppJournalPhotosTableCreateCompanionBuilder,
          $$AppJournalPhotosTableUpdateCompanionBuilder,
          (
            JournalPhoto,
            BaseReferences<_$AppDatabase, $AppJournalPhotosTable, JournalPhoto>,
          ),
          JournalPhoto,
          PrefetchHooks Function()
        > {
  $$AppJournalPhotosTableTableManager(
    _$AppDatabase db,
    $AppJournalPhotosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppJournalPhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppJournalPhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppJournalPhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String?> caption = const Value.absent(),
              }) => AppJournalPhotosCompanion(
                id: id,
                entryId: entryId,
                path: path,
                caption: caption,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required String path,
                Value<String?> caption = const Value.absent(),
              }) => AppJournalPhotosCompanion.insert(
                id: id,
                entryId: entryId,
                path: path,
                caption: caption,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppJournalPhotosTable, JournalPhoto>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppJournalPhotosTable,
                    JournalPhoto
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppJournalPhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppJournalPhotosTable,
      JournalPhoto,
      $$AppJournalPhotosTableFilterComposer,
      $$AppJournalPhotosTableOrderingComposer,
      $$AppJournalPhotosTableAnnotationComposer,
      $$AppJournalPhotosTableCreateCompanionBuilder,
      $$AppJournalPhotosTableUpdateCompanionBuilder,
      (
        JournalPhoto,
        BaseReferences<_$AppDatabase, $AppJournalPhotosTable, JournalPhoto>,
      ),
      JournalPhoto,
      PrefetchHooks Function()
    >;
typedef $$AppJournalTagsTableCreateCompanionBuilder =
    AppJournalTagsCompanion Function({
      Value<int> id,
      required int entryId,
      required String tag,
    });
typedef $$AppJournalTagsTableUpdateCompanionBuilder =
    AppJournalTagsCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<String> tag,
    });

class $$AppJournalTagsTableFilterComposer
    extends Composer<_$AppDatabase, $AppJournalTagsTable> {
  $$AppJournalTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppJournalTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppJournalTagsTable> {
  $$AppJournalTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tag => $composableBuilder(
    column: $table.tag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppJournalTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppJournalTagsTable> {
  $$AppJournalTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get tag =>
      $composableBuilder(column: $table.tag, builder: (column) => column);
}

class $$AppJournalTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppJournalTagsTable,
          JournalTag,
          $$AppJournalTagsTableFilterComposer,
          $$AppJournalTagsTableOrderingComposer,
          $$AppJournalTagsTableAnnotationComposer,
          $$AppJournalTagsTableCreateCompanionBuilder,
          $$AppJournalTagsTableUpdateCompanionBuilder,
          (
            JournalTag,
            BaseReferences<_$AppDatabase, $AppJournalTagsTable, JournalTag>,
          ),
          JournalTag,
          PrefetchHooks Function()
        > {
  $$AppJournalTagsTableTableManager(
    _$AppDatabase db,
    $AppJournalTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppJournalTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppJournalTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppJournalTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<String> tag = const Value.absent(),
              }) => AppJournalTagsCompanion(id: id, entryId: entryId, tag: tag),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required String tag,
              }) => AppJournalTagsCompanion.insert(
                id: id,
                entryId: entryId,
                tag: tag,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppJournalTagsTable, JournalTag>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppJournalTagsTable,
                    JournalTag
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppJournalTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppJournalTagsTable,
      JournalTag,
      $$AppJournalTagsTableFilterComposer,
      $$AppJournalTagsTableOrderingComposer,
      $$AppJournalTagsTableAnnotationComposer,
      $$AppJournalTagsTableCreateCompanionBuilder,
      $$AppJournalTagsTableUpdateCompanionBuilder,
      (
        JournalTag,
        BaseReferences<_$AppDatabase, $AppJournalTagsTable, JournalTag>,
      ),
      JournalTag,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$AppJournalEntriesTableTableManager get appJournalEntries =>
      $$AppJournalEntriesTableTableManager(_db, _db.appJournalEntries);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$AppJournalPhotosTableTableManager get appJournalPhotos =>
      $$AppJournalPhotosTableTableManager(_db, _db.appJournalPhotos);
  $$AppJournalTagsTableTableManager get appJournalTags =>
      $$AppJournalTagsTableTableManager(_db, _db.appJournalTags);
}
