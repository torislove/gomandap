import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../domain/models/vendor.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../local/vendor_database.dart';

class OfflineFirstVendorRepository implements VendorRepository {
  final SupabaseClient? _supabaseClient;
  final VendorDatabase _localDb;

  OfflineFirstVendorRepository(this._supabaseClient, this._localDb);

  Vendor _mapRowToVendor(Map<String, dynamic> row) {
    final type = row['type']?.toString() ?? 'Banquet';
    final category = type == 'Banquet' ? 'Venue' : type;

    // Handle primary image
    String? primaryImage;
    if (row['cover_photo_url'] != null && row['cover_photo_url'].toString().isNotEmpty) {
      primaryImage = row['cover_photo_url'].toString();
    } else {
      final photos = row['photos'] as List<dynamic>?;
      if (photos != null && photos.isNotEmpty) {
        primaryImage = photos.first.toString();
      }
    }

    final List<String> portfolio = (row['photos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    // pricingPackages
    final Map<String, dynamic> pricing = {};
    if (row['base_price'] != null) {
      final basePrice = double.tryParse(row['base_price'].toString()) ?? 0.0;
      pricing['base_price'] = basePrice;
      pricing['package_price'] = basePrice * 300; // estimated fallback
    }

    final Map<String, dynamic> policies = {};
    if (row['cancellation_policy'] != null) {
      policies['cancellation'] = row['cancellation_policy'];
    }

    return Vendor(
      id: row['id']?.toString() ?? '',
      businessName: row['name']?.toString() ?? '',
      category: category,
      rating: double.tryParse(row['rating']?.toString() ?? '') ?? 4.8,
      reviewCount: 12,
      primaryImage: primaryImage,
      portfolioImages: portfolio,
      pricingPackages: pricing,
      policies: policies,
      latitude: double.tryParse(row['latitude']?.toString() ?? ''),
      longitude: double.tryParse(row['longitude']?.toString() ?? ''),
    );
  }

  Future<void> _prepopulateIfEmpty(String category) async {
    final cached = await _localDb.getVendorsByCategory(category);
    if (cached.isNotEmpty) return;

    List<Vendor> seed = [];
    if (category == 'Venue') {
      seed = [
        const Vendor(
          id: 'seed-venue-1',
          businessName: 'The Royal Mandapam & Gardens',
          category: 'Venue',
          rating: 4.9,
          reviewCount: 32,
          primaryImage: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          portfolioImages: ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'],
          pricingPackages: {'base_price': 1800, 'package_price': 650000},
        ),
        const Vendor(
          id: 'seed-venue-2',
          businessName: 'Grand Imperial Convention Hall',
          category: 'Venue',
          rating: 4.8,
          reviewCount: 24,
          primaryImage: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
          portfolioImages: ['https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'],
          pricingPackages: {'base_price': 2200, 'package_price': 850000},
        ),
      ];
    } else if (category == 'Catering') {
      seed = [
        const Vendor(
          id: 'seed-catering-1',
          businessName: 'Spices of India Catering',
          category: 'Catering',
          rating: 4.8,
          reviewCount: 41,
          primaryImage: 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
          portfolioImages: ['https://images.unsplash.com/photo-1555244162-803834f70033?w=800'],
          pricingPackages: {'base_price': 800, 'package_price': 240000},
        ),
      ];
    } else if (category == 'Photography') {
      seed = [
        const Vendor(
          id: 'seed-photo-1',
          businessName: 'Pixel Perfect Wedding Films',
          category: 'Photography',
          rating: 4.9,
          reviewCount: 65,
          primaryImage: 'https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800',
          portfolioImages: ['https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800'],
          pricingPackages: {'base_price': 80000, 'package_price': 150000},
        ),
      ];
    } else if (category == 'Decorator') {
      seed = [
        const Vendor(
          id: 'seed-decor-1',
          businessName: 'Elite Marigold Decorators',
          category: 'Decorator',
          rating: 4.7,
          reviewCount: 19,
          primaryImage: 'https://images.unsplash.com/photo-1519225495810-7512c696505a?w=800',
          portfolioImages: ['https://images.unsplash.com/photo-1519225495810-7512c696505a?w=800'],
          pricingPackages: {'base_price': 120000, 'package_price': 250000},
        ),
      ];
    }

    for (final v in seed) {
      await _localDb.upsertVendor(CachedVendor(
        id: v.id,
        businessName: v.businessName,
        category: v.category,
        rating: v.rating,
        reviewCount: v.reviewCount,
        primaryImage: v.primaryImage,
        rawJson: jsonEncode(v.toJson()),
        lastUpdated: DateTime.now(),
      ));
    }
  }

  @override
  Future<List<Vendor>> getVendorsByCategory(String category) async {
    final client = _supabaseClient;
    String dbType = category;
    if (category == 'Venue') {
      dbType = 'Banquet';
    }

    if (client == null) {
      debugPrint('ℹ️ Supabase Client is NULL. Falling back to local premium offline mock cards.');
      await _prepopulateIfEmpty(category);
      final cached = await _localDb.getVendorsByCategory(category);
      return cached.map((c) => Vendor.fromJson(jsonDecode(c.rawJson))).toList();
    }
    try {
      debugPrint('🚀 Querying live Supabase vendors table for category: $dbType...');
      final response = await client
          .from('vendors')
          .select()
          .eq('type', dbType);

      final List rows = response as List;
      debugPrint('✅ Live Supabase fetch succeeded. Found ${rows.length} rows.');

      final vendors = rows.map((v) => _mapRowToVendor(v)).toList();

      // If we are live and have fetched data from Supabase, let's cache them and return them.
      if (vendors.isNotEmpty) {
        for (final v in vendors) {
          await _localDb.upsertVendor(CachedVendor(
            id: v.id,
            businessName: v.businessName,
            category: v.category,
            rating: v.rating,
            reviewCount: v.reviewCount,
            primaryImage: v.primaryImage,
            rawJson: jsonEncode(v.toJson()),
            lastUpdated: DateTime.now(),
          ));
        }
        return vendors;
      } else {
        debugPrint('⚠️ Supabase returned 0 rows for category "$dbType". The database is currently empty.');
        // If empty, return local DB entries but explicitly warn that the remote table is empty.
        final cached = await _localDb.getVendorsByCategory(category);
        return cached.map((c) => Vendor.fromJson(jsonDecode(c.rawJson))).toList();
      }
    } catch (e) {
      debugPrint('❌ Live Supabase query failed: $e');
      debugPrint('👉 Fallback: serving local cached offline cards.');
      await _prepopulateIfEmpty(category);
      final cached = await _localDb.getVendorsByCategory(category);
      return cached.map((c) => Vendor.fromJson(jsonDecode(c.rawJson))).toList();
    }
  }

  @override
  Stream<List<Vendor>> watchVendorsByCategory(String category) {
    final client = _supabaseClient;
    String dbType = category;
    if (category == 'Venue') {
      dbType = 'Banquet';
    }

    if (client == null) {
      debugPrint('ℹ️ Supabase Client is NULL. Falling back to local offline stream.');
      return Stream.fromFuture(() async {
        await _prepopulateIfEmpty(category);
        final cached = await _localDb.getVendorsByCategory(category);
        return cached.map((c) => Vendor.fromJson(jsonDecode(c.rawJson))).toList();
      }());
    }

    try {
      return client
          .from('vendors')
          .stream(primaryKey: ['id'])
          .eq('type', dbType)
          .map((rows) {
            final vendors = rows.map((row) => _mapRowToVendor(row)).toList();
            // Fire-and-forget sync to local DB for offline fallback
            for (final v in vendors) {
              _localDb.upsertVendor(CachedVendor(
                id: v.id,
                businessName: v.businessName,
                category: v.category,
                rating: v.rating,
                reviewCount: v.reviewCount,
                primaryImage: v.primaryImage,
                rawJson: jsonEncode(v.toJson()),
                lastUpdated: DateTime.now(),
              ));
            }
            return vendors;
          })
          .handleError((e) {
             debugPrint('❌ Live Supabase stream failed: $e');
             throw e;
          });
    } catch (e) {
      debugPrint('❌ Stream setup failed: $e');
      return Stream.value([]);
    }
  }

  @override
  Future<Vendor?> getVendorById(String id) async {
    final client = _supabaseClient;
    if (client == null) {
      final cachedList = await (_localDb.select(_localDb.cachedVendors)..where((t) => t.id.equals(id))).get();
      if (cachedList.isNotEmpty) {
        return Vendor.fromJson(jsonDecode(cachedList.first.rawJson));
      }
      return null;
    }
    try {
      final response = await client.from('vendors').select().eq('id', id).single();
      final vendor = _mapRowToVendor(response);

      await _localDb.upsertVendor(CachedVendor(
        id: vendor.id,
        businessName: vendor.businessName,
        category: vendor.category,
        rating: vendor.rating,
        reviewCount: vendor.reviewCount,
        primaryImage: vendor.primaryImage,
        rawJson: jsonEncode(vendor.toJson()),
        lastUpdated: DateTime.now(),
      ));

      return vendor;
    } catch (e) {
      // Fallback
      final cachedList = await (_localDb.select(_localDb.cachedVendors)..where((t) => t.id.equals(id))).get();
      if (cachedList.isNotEmpty) {
        return Vendor.fromJson(jsonDecode(cachedList.first.rawJson));
      }
      return null;
    }
  }

  @override
  Future<void> saveVendor(Vendor vendor) async {
    final client = _supabaseClient;
    if (client != null) {
      // Map to snake_case DB columns for Supabase upsert
      String dbType = vendor.category;
      if (vendor.category == 'Venue') {
        dbType = 'Banquet';
      }
      final dbRow = {
        'id': vendor.id,
        'name': vendor.businessName,
        'type': dbType,
        'rating': vendor.rating,
        'cover_photo_url': vendor.primaryImage,
        'photos': vendor.portfolioImages,
        'base_price': vendor.pricingPackages['base_price'] ?? 0.0,
        'latitude': vendor.latitude,
        'longitude': vendor.longitude,
      };
      await client.from('vendors').upsert(dbRow);
    }
    // 2. Cache locally
    await _localDb.upsertVendor(CachedVendor(
      id: vendor.id,
      businessName: vendor.businessName,
      category: vendor.category,
      rating: vendor.rating,
      reviewCount: vendor.reviewCount,
      primaryImage: vendor.primaryImage,
      rawJson: jsonEncode(vendor.toJson()),
      lastUpdated: DateTime.now(),
    ));
  }

  @override
  Future<List<Vendor>> getVendorsByCategoryAndProximity({
    required String category,
    required double latitude,
    required double longitude,
    double? maxDistanceKm,
  }) async {
    final allVendors = await getVendorsByCategory(category);
    final List<Vendor> results = [];
    
    for (final v in allVendors) {
      if (v.latitude != null && v.longitude != null) {
        final dist = _calculateDistance(latitude, longitude, v.latitude!, v.longitude!);
        if (maxDistanceKm == null || dist <= maxDistanceKm) {
          results.add(v);
        }
      } else {
        if (maxDistanceKm == null) {
          results.add(v);
        }
      }
    }
    
    results.sort((a, b) {
      final distA = (a.latitude != null && a.longitude != null)
          ? _calculateDistance(latitude, longitude, a.latitude!, a.longitude!)
          : 999999.0;
      final distB = (b.latitude != null && b.longitude != null)
          ? _calculateDistance(latitude, longitude, b.latitude!, b.longitude!)
          : 999999.0;
      return distA.compareTo(distB);
    });
    
    return results;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) *
        (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }
}

// ─── Riverpod Providers ───────────────────────────────────────────────────────

final vendorDatabaseProvider = Provider<VendorDatabase>((ref) {
  final db = VendorDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final db = ref.watch(vendorDatabaseProvider);
  return OfflineFirstVendorRepository(client, db);
});
