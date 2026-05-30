// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_database.dart';

// ignore_for_file: type=lint
class $CachedVendorsTable extends CachedVendors
    with TableInfo<$CachedVendorsTable, CachedVendor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedVendorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _businessNameMeta =
      const VerificationMeta('businessName');
  @override
  late final GeneratedColumn<String> businessName = GeneratedColumn<String>(
      'business_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
      'rating', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _reviewCountMeta =
      const VerificationMeta('reviewCount');
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
      'review_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _primaryImageMeta =
      const VerificationMeta('primaryImage');
  @override
  late final GeneratedColumn<String> primaryImage = GeneratedColumn<String>(
      'primary_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rawJsonMeta =
      const VerificationMeta('rawJson');
  @override
  late final GeneratedColumn<String> rawJson = GeneratedColumn<String>(
      'raw_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        businessName,
        category,
        rating,
        reviewCount,
        primaryImage,
        rawJson,
        lastUpdated
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_vendors';
  @override
  VerificationContext validateIntegrity(Insertable<CachedVendor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('business_name')) {
      context.handle(
          _businessNameMeta,
          businessName.isAcceptableOrUnknown(
              data['business_name']!, _businessNameMeta));
    } else if (isInserting) {
      context.missing(_businessNameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(_ratingMeta,
          rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta));
    }
    if (data.containsKey('review_count')) {
      context.handle(
          _reviewCountMeta,
          reviewCount.isAcceptableOrUnknown(
              data['review_count']!, _reviewCountMeta));
    }
    if (data.containsKey('primary_image')) {
      context.handle(
          _primaryImageMeta,
          primaryImage.isAcceptableOrUnknown(
              data['primary_image']!, _primaryImageMeta));
    }
    if (data.containsKey('raw_json')) {
      context.handle(_rawJsonMeta,
          rawJson.isAcceptableOrUnknown(data['raw_json']!, _rawJsonMeta));
    } else if (isInserting) {
      context.missing(_rawJsonMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedVendor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedVendor(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      businessName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}business_name'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      rating: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}rating'])!,
      reviewCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}review_count'])!,
      primaryImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}primary_image']),
      rawJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_json'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated']),
    );
  }

  @override
  $CachedVendorsTable createAlias(String alias) {
    return $CachedVendorsTable(attachedDatabase, alias);
  }
}

class CachedVendor extends DataClass implements Insertable<CachedVendor> {
  final String id;
  final String businessName;
  final String category;
  final double rating;
  final int reviewCount;
  final String? primaryImage;
  final String rawJson;
  final DateTime? lastUpdated;
  const CachedVendor(
      {required this.id,
      required this.businessName,
      required this.category,
      required this.rating,
      required this.reviewCount,
      this.primaryImage,
      required this.rawJson,
      this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['business_name'] = Variable<String>(businessName);
    map['category'] = Variable<String>(category);
    map['rating'] = Variable<double>(rating);
    map['review_count'] = Variable<int>(reviewCount);
    if (!nullToAbsent || primaryImage != null) {
      map['primary_image'] = Variable<String>(primaryImage);
    }
    map['raw_json'] = Variable<String>(rawJson);
    if (!nullToAbsent || lastUpdated != null) {
      map['last_updated'] = Variable<DateTime>(lastUpdated);
    }
    return map;
  }

  CachedVendorsCompanion toCompanion(bool nullToAbsent) {
    return CachedVendorsCompanion(
      id: Value(id),
      businessName: Value(businessName),
      category: Value(category),
      rating: Value(rating),
      reviewCount: Value(reviewCount),
      primaryImage: primaryImage == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryImage),
      rawJson: Value(rawJson),
      lastUpdated: lastUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdated),
    );
  }

  factory CachedVendor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedVendor(
      id: serializer.fromJson<String>(json['id']),
      businessName: serializer.fromJson<String>(json['businessName']),
      category: serializer.fromJson<String>(json['category']),
      rating: serializer.fromJson<double>(json['rating']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      primaryImage: serializer.fromJson<String?>(json['primaryImage']),
      rawJson: serializer.fromJson<String>(json['rawJson']),
      lastUpdated: serializer.fromJson<DateTime?>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'businessName': serializer.toJson<String>(businessName),
      'category': serializer.toJson<String>(category),
      'rating': serializer.toJson<double>(rating),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'primaryImage': serializer.toJson<String?>(primaryImage),
      'rawJson': serializer.toJson<String>(rawJson),
      'lastUpdated': serializer.toJson<DateTime?>(lastUpdated),
    };
  }

  CachedVendor copyWith(
          {String? id,
          String? businessName,
          String? category,
          double? rating,
          int? reviewCount,
          Value<String?> primaryImage = const Value.absent(),
          String? rawJson,
          Value<DateTime?> lastUpdated = const Value.absent()}) =>
      CachedVendor(
        id: id ?? this.id,
        businessName: businessName ?? this.businessName,
        category: category ?? this.category,
        rating: rating ?? this.rating,
        reviewCount: reviewCount ?? this.reviewCount,
        primaryImage:
            primaryImage.present ? primaryImage.value : this.primaryImage,
        rawJson: rawJson ?? this.rawJson,
        lastUpdated: lastUpdated.present ? lastUpdated.value : this.lastUpdated,
      );
  CachedVendor copyWithCompanion(CachedVendorsCompanion data) {
    return CachedVendor(
      id: data.id.present ? data.id.value : this.id,
      businessName: data.businessName.present
          ? data.businessName.value
          : this.businessName,
      category: data.category.present ? data.category.value : this.category,
      rating: data.rating.present ? data.rating.value : this.rating,
      reviewCount:
          data.reviewCount.present ? data.reviewCount.value : this.reviewCount,
      primaryImage: data.primaryImage.present
          ? data.primaryImage.value
          : this.primaryImage,
      rawJson: data.rawJson.present ? data.rawJson.value : this.rawJson,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedVendor(')
          ..write('id: $id, ')
          ..write('businessName: $businessName, ')
          ..write('category: $category, ')
          ..write('rating: $rating, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('primaryImage: $primaryImage, ')
          ..write('rawJson: $rawJson, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, businessName, category, rating,
      reviewCount, primaryImage, rawJson, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedVendor &&
          other.id == this.id &&
          other.businessName == this.businessName &&
          other.category == this.category &&
          other.rating == this.rating &&
          other.reviewCount == this.reviewCount &&
          other.primaryImage == this.primaryImage &&
          other.rawJson == this.rawJson &&
          other.lastUpdated == this.lastUpdated);
}

class CachedVendorsCompanion extends UpdateCompanion<CachedVendor> {
  final Value<String> id;
  final Value<String> businessName;
  final Value<String> category;
  final Value<double> rating;
  final Value<int> reviewCount;
  final Value<String?> primaryImage;
  final Value<String> rawJson;
  final Value<DateTime?> lastUpdated;
  final Value<int> rowid;
  const CachedVendorsCompanion({
    this.id = const Value.absent(),
    this.businessName = const Value.absent(),
    this.category = const Value.absent(),
    this.rating = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.primaryImage = const Value.absent(),
    this.rawJson = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedVendorsCompanion.insert({
    required String id,
    required String businessName,
    required String category,
    this.rating = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.primaryImage = const Value.absent(),
    required String rawJson,
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        businessName = Value(businessName),
        category = Value(category),
        rawJson = Value(rawJson);
  static Insertable<CachedVendor> custom({
    Expression<String>? id,
    Expression<String>? businessName,
    Expression<String>? category,
    Expression<double>? rating,
    Expression<int>? reviewCount,
    Expression<String>? primaryImage,
    Expression<String>? rawJson,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessName != null) 'business_name': businessName,
      if (category != null) 'category': category,
      if (rating != null) 'rating': rating,
      if (reviewCount != null) 'review_count': reviewCount,
      if (primaryImage != null) 'primary_image': primaryImage,
      if (rawJson != null) 'raw_json': rawJson,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedVendorsCompanion copyWith(
      {Value<String>? id,
      Value<String>? businessName,
      Value<String>? category,
      Value<double>? rating,
      Value<int>? reviewCount,
      Value<String?>? primaryImage,
      Value<String>? rawJson,
      Value<DateTime?>? lastUpdated,
      Value<int>? rowid}) {
    return CachedVendorsCompanion(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      primaryImage: primaryImage ?? this.primaryImage,
      rawJson: rawJson ?? this.rawJson,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (businessName.present) {
      map['business_name'] = Variable<String>(businessName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (primaryImage.present) {
      map['primary_image'] = Variable<String>(primaryImage.value);
    }
    if (rawJson.present) {
      map['raw_json'] = Variable<String>(rawJson.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedVendorsCompanion(')
          ..write('id: $id, ')
          ..write('businessName: $businessName, ')
          ..write('category: $category, ')
          ..write('rating: $rating, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('primaryImage: $primaryImage, ')
          ..write('rawJson: $rawJson, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$VendorDatabase extends GeneratedDatabase {
  _$VendorDatabase(QueryExecutor e) : super(e);
  $VendorDatabaseManager get managers => $VendorDatabaseManager(this);
  late final $CachedVendorsTable cachedVendors = $CachedVendorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cachedVendors];
}

typedef $$CachedVendorsTableCreateCompanionBuilder = CachedVendorsCompanion
    Function({
  required String id,
  required String businessName,
  required String category,
  Value<double> rating,
  Value<int> reviewCount,
  Value<String?> primaryImage,
  required String rawJson,
  Value<DateTime?> lastUpdated,
  Value<int> rowid,
});
typedef $$CachedVendorsTableUpdateCompanionBuilder = CachedVendorsCompanion
    Function({
  Value<String> id,
  Value<String> businessName,
  Value<String> category,
  Value<double> rating,
  Value<int> reviewCount,
  Value<String?> primaryImage,
  Value<String> rawJson,
  Value<DateTime?> lastUpdated,
  Value<int> rowid,
});

class $$CachedVendorsTableFilterComposer
    extends Composer<_$VendorDatabase, $CachedVendorsTable> {
  $$CachedVendorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get businessName => $composableBuilder(
      column: $table.businessName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get primaryImage => $composableBuilder(
      column: $table.primaryImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$CachedVendorsTableOrderingComposer
    extends Composer<_$VendorDatabase, $CachedVendorsTable> {
  $$CachedVendorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get businessName => $composableBuilder(
      column: $table.businessName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rating => $composableBuilder(
      column: $table.rating, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primaryImage => $composableBuilder(
      column: $table.primaryImage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawJson => $composableBuilder(
      column: $table.rawJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$CachedVendorsTableAnnotationComposer
    extends Composer<_$VendorDatabase, $CachedVendorsTable> {
  $$CachedVendorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get businessName => $composableBuilder(
      column: $table.businessName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => column);

  GeneratedColumn<String> get primaryImage => $composableBuilder(
      column: $table.primaryImage, builder: (column) => column);

  GeneratedColumn<String> get rawJson =>
      $composableBuilder(column: $table.rawJson, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);
}

class $$CachedVendorsTableTableManager extends RootTableManager<
    _$VendorDatabase,
    $CachedVendorsTable,
    CachedVendor,
    $$CachedVendorsTableFilterComposer,
    $$CachedVendorsTableOrderingComposer,
    $$CachedVendorsTableAnnotationComposer,
    $$CachedVendorsTableCreateCompanionBuilder,
    $$CachedVendorsTableUpdateCompanionBuilder,
    (
      CachedVendor,
      BaseReferences<_$VendorDatabase, $CachedVendorsTable, CachedVendor>
    ),
    CachedVendor,
    PrefetchHooks Function()> {
  $$CachedVendorsTableTableManager(
      _$VendorDatabase db, $CachedVendorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedVendorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedVendorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedVendorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> businessName = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<double> rating = const Value.absent(),
            Value<int> reviewCount = const Value.absent(),
            Value<String?> primaryImage = const Value.absent(),
            Value<String> rawJson = const Value.absent(),
            Value<DateTime?> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedVendorsCompanion(
            id: id,
            businessName: businessName,
            category: category,
            rating: rating,
            reviewCount: reviewCount,
            primaryImage: primaryImage,
            rawJson: rawJson,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String businessName,
            required String category,
            Value<double> rating = const Value.absent(),
            Value<int> reviewCount = const Value.absent(),
            Value<String?> primaryImage = const Value.absent(),
            required String rawJson,
            Value<DateTime?> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CachedVendorsCompanion.insert(
            id: id,
            businessName: businessName,
            category: category,
            rating: rating,
            reviewCount: reviewCount,
            primaryImage: primaryImage,
            rawJson: rawJson,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CachedVendorsTableProcessedTableManager = ProcessedTableManager<
    _$VendorDatabase,
    $CachedVendorsTable,
    CachedVendor,
    $$CachedVendorsTableFilterComposer,
    $$CachedVendorsTableOrderingComposer,
    $$CachedVendorsTableAnnotationComposer,
    $$CachedVendorsTableCreateCompanionBuilder,
    $$CachedVendorsTableUpdateCompanionBuilder,
    (
      CachedVendor,
      BaseReferences<_$VendorDatabase, $CachedVendorsTable, CachedVendor>
    ),
    CachedVendor,
    PrefetchHooks Function()>;

class $VendorDatabaseManager {
  final _$VendorDatabase _db;
  $VendorDatabaseManager(this._db);
  $$CachedVendorsTableTableManager get cachedVendors =>
      $$CachedVendorsTableTableManager(_db, _db.cachedVendors);
}
