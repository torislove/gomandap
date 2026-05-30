import 'package:drift/drift.dart';
import 'connection_stub.dart'
  if (dart.library.html) 'connection_web.dart'
  if (dart.library.io) 'connection_mobile.dart' as conn;

part 'vendor_database.g.dart';

// Drift Table for Cached Vendors
class CachedVendors extends Table {
  TextColumn get id => text()();
  TextColumn get businessName => text()();
  TextColumn get category => text()();
  RealColumn get rating => real().withDefault(const Constant(0.0))();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  TextColumn get primaryImage => text().nullable()();
  TextColumn get rawJson => text().named('raw_json')(); // Store full JSON for easy mapping
  DateTimeColumn get lastUpdated => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [CachedVendors])
class VendorDatabase extends _$VendorDatabase {
  VendorDatabase() : super(conn.openConnection());

  @override
  int get schemaVersion => 1;

  // Insert or Update vendor
  Future<void> upsertVendor(CachedVendor vendor) {
    return into(cachedVendors).insertOnConflictUpdate(vendor);
  }

  // Get all cached vendors by category
  Future<List<CachedVendor>> getVendorsByCategory(String category) {
    return (select(cachedVendors)..where((tbl) => tbl.category.equals(category))).get();
  }

  // Clear cache
  Future<void> clearCache() {
    return delete(cachedVendors).go();
  }
}

