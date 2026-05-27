import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────

class VendorCategorySpecs {
  // Venue & Mandapam specs
  final double? vegPlatePrice;
  final double? nonVegPlatePrice;
  final int? guestCapacity;
  final int? roomsAvailable;

  // Photographer specs
  final double? candidDayRate;
  final double? videoDayRate;
  final int? deliveryTimelineDays;
  final String? equipmentBrand;

  // Catering specs
  final double? cateringVegPrice;
  final double? cateringNonVegPrice;
  final int? minPlatesBooking;

  // Makeup specs
  final double? bridalMakeupPrice;
  final double? familyMakeupPrice;
  final String? makeupBrandTier;
  final bool? trialSessionAvailable;

  // Decorator specs
  final double? indoorDecorPrice;
  final double? outdoorStagePrice;
  final int? setupHours;
  final String? floralGrade;

  const VendorCategorySpecs({
    this.vegPlatePrice,
    this.nonVegPlatePrice,
    this.guestCapacity,
    this.roomsAvailable,
    this.candidDayRate,
    this.videoDayRate,
    this.deliveryTimelineDays,
    this.equipmentBrand,
    this.cateringVegPrice,
    this.cateringNonVegPrice,
    this.minPlatesBooking,
    this.bridalMakeupPrice,
    this.familyMakeupPrice,
    this.makeupBrandTier,
    this.trialSessionAvailable,
    this.indoorDecorPrice,
    this.outdoorStagePrice,
    this.setupHours,
    this.floralGrade,
  });

  factory VendorCategorySpecs.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const VendorCategorySpecs();
    return VendorCategorySpecs(
      vegPlatePrice: double.tryParse(json['vegPlatePrice']?.toString() ?? ''),
      nonVegPlatePrice: double.tryParse(json['nonVegPlatePrice']?.toString() ?? ''),
      guestCapacity: int.tryParse(json['guestCapacity']?.toString() ?? ''),
      roomsAvailable: int.tryParse(json['roomsAvailable']?.toString() ?? ''),
      candidDayRate: double.tryParse(json['candidDayRate']?.toString() ?? ''),
      videoDayRate: double.tryParse(json['videoDayRate']?.toString() ?? ''),
      deliveryTimelineDays: int.tryParse(json['deliveryTimelineDays']?.toString() ?? ''),
      equipmentBrand: json['equipmentBrand']?.toString(),
      cateringVegPrice: double.tryParse(json['cateringVegPrice']?.toString() ?? ''),
      cateringNonVegPrice: double.tryParse(json['cateringNonVegPrice']?.toString() ?? ''),
      minPlatesBooking: int.tryParse(json['minPlatesBooking']?.toString() ?? ''),
      bridalMakeupPrice: double.tryParse(json['bridalMakeupPrice']?.toString() ?? ''),
      familyMakeupPrice: double.tryParse(json['familyMakeupPrice']?.toString() ?? ''),
      makeupBrandTier: json['makeupBrandTier']?.toString(),
      trialSessionAvailable: json['trialSessionAvailable'] as bool? ?? json['trialSessionAvailable']?.toString() == 'true',
      indoorDecorPrice: double.tryParse(json['indoorDecorPrice']?.toString() ?? ''),
      outdoorStagePrice: double.tryParse(json['outdoorStagePrice']?.toString() ?? ''),
      setupHours: int.tryParse(json['setupHours']?.toString() ?? ''),
      floralGrade: json['floralGrade']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vegPlatePrice': vegPlatePrice,
      'nonVegPlatePrice': nonVegPlatePrice,
      'guestCapacity': guestCapacity,
      'roomsAvailable': roomsAvailable,
      'candidDayRate': candidDayRate,
      'videoDayRate': videoDayRate,
      'deliveryTimelineDays': deliveryTimelineDays,
      'equipmentBrand': equipmentBrand,
      'cateringVegPrice': cateringVegPrice,
      'cateringNonVegPrice': cateringNonVegPrice,
      'minPlatesBooking': minPlatesBooking,
      'bridalMakeupPrice': bridalMakeupPrice,
      'familyMakeupPrice': familyMakeupPrice,
      'makeupBrandTier': makeupBrandTier,
      'trialSessionAvailable': trialSessionAvailable,
      'indoorDecorPrice': indoorDecorPrice,
      'outdoorStagePrice': outdoorStagePrice,
      'setupHours': setupHours,
      'floralGrade': floralGrade,
    };
  }
}

class VendorSummary {
  final String id;
  final String name;
  final String locality;
  final double rating;
  final int reviewCount;
  final double basePlatePrice;
  final double packagePrice;
  final List<String> imageUrls;
  final String? videoUrl;
  final bool isEscrowProtected;
  final bool isFastFilling;
  final bool isVerified;
  final bool isPreferred;
  final String category;
  final List<String>? subServices;
  final VendorCategorySpecs specs;

  const VendorSummary({
    required this.id,
    required this.name,
    required this.locality,
    required this.rating,
    required this.reviewCount,
    required this.basePlatePrice,
    required this.packagePrice,
    required this.imageUrls,
    this.videoUrl,
    this.isEscrowProtected = true,
    this.isFastFilling = false,
    this.isVerified = true,
    this.isPreferred = false,
    required this.category,
    this.subServices,
    this.specs = const VendorCategorySpecs(),
  });
}

class HomeUiState {
  final String selectedCity;
  final String selectedLocality;
  final String searchQuery;
  final int activeCarouselIndex;
  final bool isCategorySheetOpen;
  final String? activeCategoryId;
  final List<VendorSummary> trendingVenues;
  final List<VendorSummary> eliteServices;
  final bool isLoading;
  final String? errorMessage;

  const HomeUiState({
    this.selectedCity = 'Hyderabad',
    this.selectedLocality = 'Jubilee Hills',
    this.searchQuery = '',
    this.activeCarouselIndex = 0,
    this.isCategorySheetOpen = false,
    this.activeCategoryId,
    this.trendingVenues = const [],
    this.eliteServices = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  HomeUiState copyWith({
    String? selectedCity,
    String? selectedLocality,
    String? searchQuery,
    int? activeCarouselIndex,
    bool? isCategorySheetOpen,
    String? activeCategoryId,
    List<VendorSummary>? trendingVenues,
    List<VendorSummary>? eliteServices,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HomeUiState(
      selectedCity: selectedCity ?? this.selectedCity,
      selectedLocality: selectedLocality ?? this.selectedLocality,
      searchQuery: searchQuery ?? this.searchQuery,
      activeCarouselIndex: activeCarouselIndex ?? this.activeCarouselIndex,
      isCategorySheetOpen: isCategorySheetOpen ?? this.isCategorySheetOpen,
      activeCategoryId: activeCategoryId ?? this.activeCategoryId,
      trendingVenues: trendingVenues ?? this.trendingVenues,
      eliteServices: eliteServices ?? this.eliteServices,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ─── Mock Data ───────────────────────────────────────────────────────────────

final _mockVenues = [
  const VendorSummary(
    id: '1', name: 'The Heritage Gala Resort', locality: 'Jubilee Hills',
    rating: 4.9, reviewCount: 128, basePlatePrice: 1500, packagePrice: 450000,
    imageUrls: ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Venue',
  ),
  const VendorSummary(
    id: '2', name: 'Royal Orchid Convention', locality: 'Banjara Hills',
    rating: 4.7, reviewCount: 94, basePlatePrice: 1200, packagePrice: 360000,
    imageUrls: ['https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Venue',
  ),
  const VendorSummary(
    id: '3', name: 'Majestic Garden Lawns', locality: 'Hitech City',
    rating: 4.8, reviewCount: 76, basePlatePrice: 900, packagePrice: 270000,
    imageUrls: ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Venue',
  ),
  const VendorSummary(
    id: '4', name: 'Golden Pavilion Banquet', locality: 'Secunderabad',
    rating: 4.6, reviewCount: 52, basePlatePrice: 1800, packagePrice: 540000,
    imageUrls: ['https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Venue',
  ),
  const VendorSummary(
    id: '5', name: 'Pearl Grand Halls', locality: 'Madhapur',
    rating: 4.5, reviewCount: 41, basePlatePrice: 1100, packagePrice: 330000,
    imageUrls: ['https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: false, category: 'Venue',
  ),
];

final _mockServices = [
  const VendorSummary(
    id: 'p1', name: 'Lens & Light Studio', locality: 'Jubilee Hills',
    rating: 4.9, reviewCount: 218, basePlatePrice: 55000, packagePrice: 55000,
    imageUrls: ['https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Photography',
  ),
  const VendorSummary(
    id: 'm1', name: 'Glam Studio by Priya', locality: 'Banjara Hills',
    rating: 4.8, reviewCount: 164, basePlatePrice: 25000, packagePrice: 25000,
    imageUrls: ['https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Makeup',
  ),
  const VendorSummary(
    id: 'd1', name: 'Bloom Floral Decor', locality: 'Madhapur',
    rating: 4.7, reviewCount: 89, basePlatePrice: 75000, packagePrice: 75000,
    imageUrls: ['https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Decor',
  ),
];

// ─── Notifier (manual, no code-gen) ──────────────────────────────────────────

class HomeNotifier extends StateNotifier<HomeUiState> {
  final Ref _ref;

  HomeNotifier(this._ref) : super(const HomeUiState(isLoading: true)) {
    _loadData();
  }

  Future<void> _loadData() async {
    final client = _ref.read(supabaseClientProvider);
    if (client == null) {
      await Future.delayed(const Duration(milliseconds: 600));
      state = state.copyWith(
        isLoading: false,
        trendingVenues: _mockVenues,
        eliteServices: _mockServices,
      );
      return;
    }

    try {
      final venueRes = await client.from('vendor_profiles').select().eq('category_id', 1).limit(5);
      final serviceRes = await client.from('vendor_profiles').select().neq('category_id', 1).limit(5);

      final venues = venueRes.map<VendorSummary>((row) => _mapRowToSummary(row)).toList();
      final services = serviceRes.map<VendorSummary>((row) => _mapRowToSummary(row)).toList();

      state = state.copyWith(
        isLoading: false,
        trendingVenues: venues.isEmpty ? _mockVenues : venues,
        eliteServices: services.isEmpty ? _mockServices : services,
      );
    } catch (e) {
      debugPrint('Supabase dynamic load error (falling back to offline mocks): $e');
      state = state.copyWith(
        isLoading: false,
        trendingVenues: _mockVenues,
        eliteServices: _mockServices,
      );
    }
  }

  VendorSummary _mapRowToSummary(Map<String, dynamic> row) {
    final gallery = row['gallery_urls'] as List<dynamic>?;
    final images = gallery?.map((e) => e.toString()).toList() ?? [];
    
    Map<String, dynamic>? rawSpecs;
    if (row['category_specs'] != null) {
      if (row['category_specs'] is Map) {
        rawSpecs = Map<String, dynamic>.from(row['category_specs'] as Map);
      }
    }

    return VendorSummary(
      id: row['id']?.toString() ?? '',
      name: row['business_name']?.toString() ?? '',
      locality: row['locality']?.toString() ?? '',
      rating: double.tryParse(row['rating']?.toString() ?? '') ?? 4.8,
      reviewCount: int.tryParse(row['review_count']?.toString() ?? '') ?? 12,
      basePlatePrice: double.tryParse(row['base_price']?.toString() ?? '') ?? 1500,
      packagePrice: double.tryParse(row['base_price']?.toString() ?? '') ?? 450000,
      imageUrls: images.isEmpty ? ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'] : images,
      videoUrl: row['video_url']?.toString(),
      isEscrowProtected: row['is_escrow_protected'] as bool? ?? true,
      isFastFilling: false,
      isVerified: row['is_verified'] as bool? ?? true,
      category: row['category_id']?.toString() == '1' ? 'Venue' : 'Service',
      specs: VendorCategorySpecs.fromJson(rawSpecs),
    );
  }

  void setCity(String city) => state = state.copyWith(selectedCity: city, selectedLocality: 'Central Hub');

  void setLocation(String city, String locality) =>
      state = state.copyWith(selectedCity: city, selectedLocality: locality);

  void setCarouselIndex(int index) => state = state.copyWith(activeCarouselIndex: index);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    await _loadData();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final homeNotifierProvider = StateNotifierProvider<HomeNotifier, HomeUiState>(
  (ref) => HomeNotifier(ref),
);

final cartCountProvider = StateProvider<int>((_) => 0);
