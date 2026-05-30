
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gomandap_common/data/repository_impl/offline_first_vendor_repository.dart';
import 'package:gomandap_common/domain/models/vendor.dart' as dom;

import 'dart:async';
import '../auth/location_notifier.dart';

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

  factory VendorSummary.fromJson(Map<String, dynamic> json) {
    return VendorSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      locality: json['locality'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      basePlatePrice: (json['basePlatePrice'] as num).toDouble(),
      packagePrice: (json['packagePrice'] as num).toDouble(),
      imageUrls: (json['imageUrls'] as List).map((e) => e as String).toList(),
      videoUrl: json['videoUrl'] as String?,
      isEscrowProtected: json['isEscrowProtected'] as bool? ?? true,
      isFastFilling: json['isFastFilling'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? true,
      isPreferred: json['isPreferred'] as bool? ?? false,
      category: json['category'] as String,
      subServices: (json['subServices'] as List?)?.map((e) => e as String).toList(),
      specs: VendorCategorySpecs.fromJson(json['specs'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'locality': locality,
      'rating': rating,
      'reviewCount': reviewCount,
      'basePlatePrice': basePlatePrice,
      'packagePrice': packagePrice,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'isEscrowProtected': isEscrowProtected,
      'isFastFilling': isFastFilling,
      'isVerified': isVerified,
      'isPreferred': isPreferred,
      'category': category,
      'subServices': subServices,
      'specs': specs.toJson(),
    };
  }
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
    this.selectedLocality = 'Hyderabad',
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
// ─── Notifier (manual, no code-gen) ──────────────────────────────────────────

class HomeNotifier extends Notifier<HomeUiState> {
  StreamSubscription? _venueSub;
  StreamSubscription? _caterSub;
  StreamSubscription? _photoSub;
  StreamSubscription? _decorSub;

  List<VendorSummary> _caters = [];
  List<VendorSummary> _photos = [];
  List<VendorSummary> _decors = [];

  @override
  HomeUiState build() {
    final locationState = ref.watch(locationNotifierProvider);
    String city = 'Hyderabad';
    String locality = 'Hyderabad';
    
    if (locationState is LocationSuccess) {
      city = locationState.city;
      locality = locationState.locality;
    }

    ref.onDispose(() {
      _venueSub?.cancel();
      _caterSub?.cancel();
      _photoSub?.cancel();
      _decorSub?.cancel();
    });

    _subscribeToLiveFeeds();
    
    return HomeUiState(
      isLoading: true,
      selectedCity: city,
      selectedLocality: locality,
    );
  }

  void _subscribeToLiveFeeds() {
    final repository = ref.read(vendorRepositoryProvider);
    
    _venueSub?.cancel();
    _venueSub = repository.watchVendorsByCategory('Venue').listen((venues) {
      final mapped = venues.map((v) => _mapDomainToSummary(v, 'Venue')).toList();
      state = state.copyWith(
        trendingVenues: mapped.isEmpty ? _getFallbackVenues() : mapped,
        isLoading: false,
      );
    });

    _caterSub?.cancel();
    _caterSub = repository.watchVendorsByCategory('Catering').listen((list) {
      _caters = list.map((v) => _mapDomainToSummary(v, 'Catering')).toList();
      _updateServices();
    });

    _photoSub?.cancel();
    _photoSub = repository.watchVendorsByCategory('Photography').listen((list) {
      _photos = list.map((v) => _mapDomainToSummary(v, 'Photography')).toList();
      _updateServices();
    });

    _decorSub?.cancel();
    _decorSub = repository.watchVendorsByCategory('Decorator').listen((list) {
      _decors = list.map((v) => _mapDomainToSummary(v, 'Decorator')).toList();
      _updateServices();
    });
  }

  void _updateServices() {
    final services = [..._caters, ..._photos, ..._decors];
    state = state.copyWith(
      eliteServices: services.isEmpty ? _getFallbackServices() : services,
    );
  }

  VendorSummary _mapDomainToSummary(dom.Vendor v, String category) {
    return VendorSummary(
      id: v.id,
      name: v.businessName,
      locality: 'Central Hub',
      rating: v.rating,
      reviewCount: v.reviewCount,
      basePlatePrice: double.tryParse(v.pricingPackages['base_price']?.toString() ?? '') ?? 1500,
      packagePrice: double.tryParse(v.pricingPackages['package_price']?.toString() ?? '') ?? 450000,
      imageUrls: v.primaryImage != null && v.primaryImage!.isNotEmpty
          ? [v.primaryImage!]
          : (v.portfolioImages.isNotEmpty ? v.portfolioImages : ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800']),
      category: category,
      specs: const VendorCategorySpecs(
        guestCapacity: 500,
        roomsAvailable: 12,
      ),
    );
  }

  List<VendorSummary> _getFallbackVenues() {
    return const [
      VendorSummary(
        id: 'mock-venue-1',
        name: 'The Royal Mandapam & Gardens',
        locality: 'Gachibowli, Hyderabad',
        rating: 4.9,
        reviewCount: 32,
        basePlatePrice: 1800,
        packagePrice: 650000,
        imageUrls: ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'],
        category: 'Venue',
        isPreferred: true,
      ),
      VendorSummary(
        id: 'mock-venue-2',
        name: 'Grand Imperial Convention Hall',
        locality: 'Banjara Hills, Hyderabad',
        rating: 4.8,
        reviewCount: 24,
        basePlatePrice: 2200,
        packagePrice: 850000,
        imageUrls: ['https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'],
        category: 'Venue',
      ),
    ];
  }

  List<VendorSummary> _getFallbackServices() {
    return const [
      VendorSummary(
        id: 'mock-service-1',
        name: 'Golden Brush Bridal Studio',
        locality: 'Jubilee Hills',
        rating: 4.9,
        reviewCount: 45,
        basePlatePrice: 0,
        packagePrice: 35000,
        imageUrls: ['https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800'],
        category: 'Bridal Makeup',
      ),
      VendorSummary(
        id: 'mock-service-2',
        name: 'Elite Marigold Decorators',
        locality: 'Secunderabad',
        rating: 4.7,
        reviewCount: 19,
        basePlatePrice: 0,
        packagePrice: 250000,
        imageUrls: ['https://images.unsplash.com/photo-1519225495810-7512c696505a?w=800'],
        category: 'Decorators',
      ),
    ];
  }


  void setCity(String city) => state = state.copyWith(selectedCity: city, selectedLocality: 'Central Hub');

  void setLocation(String city, String locality) =>
      state = state.copyWith(selectedCity: city, selectedLocality: locality);

  void setCarouselIndex(int index) => state = state.copyWith(activeCarouselIndex: index);

  void setActiveCategory(String? categoryId) =>
      state = state.copyWith(activeCategoryId: categoryId);

  void toggleCategorySheet() =>
      state = state.copyWith(isCategorySheetOpen: !state.isCategorySheetOpen);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    _subscribeToLiveFeeds();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────

final homeNotifierProvider = NotifierProvider<HomeNotifier, HomeUiState>(
  HomeNotifier.new,
);

class CartCountNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void updateCount(int c) => state = c;
}
final cartCountProvider = NotifierProvider<CartCountNotifier, int>(CartCountNotifier.new);
