import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_notifier.dart';

class SearchUiState {
  final String searchQuery;
  final String selectedCategory; // 'All' or specific category name from weddingCategoriesList
  final RangeValues priceRange;
  final RangeValues capacityRange;
  final List<String> selectedVenueTypes;
  final List<String> selectedDietary;
  final List<String> selectedSubServices;
  final bool? isAcPreferred;
  final bool? hasParking;
  final bool? allowsAlcohol;
  final String sortBy; // 'Popularity', 'PriceLowToHigh', 'PriceHighToLow', 'Rating'
  final List<VendorSummary> results;
  final bool isLoading;

  const SearchUiState({
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.priceRange = const RangeValues(200, 3000), // Default per-plate price range
    this.capacityRange = const RangeValues(100, 2000),
    this.selectedVenueTypes = const [],
    this.selectedDietary = const [],
    this.selectedSubServices = const [],
    this.isAcPreferred,
    this.hasParking,
    this.allowsAlcohol,
    this.sortBy = 'Popularity',
    this.results = const [],
    this.isLoading = false,
  });

  int get activeFiltersCount {
    int count = 0;
    if (priceRange.start > 200 || priceRange.end < 3000) count++;
    if (capacityRange.start > 100 || capacityRange.end < 2000) count++;
    if (selectedVenueTypes.isNotEmpty) count++;
    if (selectedDietary.isNotEmpty) count++;
    if (selectedSubServices.isNotEmpty) count++;
    if (isAcPreferred == true) count++;
    if (hasParking == true) count++;
    if (allowsAlcohol == true) count++;
    return count;
  }

  SearchUiState copyWith({
    String? searchQuery,
    String? selectedCategory,
    RangeValues? priceRange,
    RangeValues? capacityRange,
    List<String>? selectedVenueTypes,
    List<String>? selectedDietary,
    List<String>? selectedSubServices,
    bool? isAcPreferred,
    bool? hasParking,
    bool? allowsAlcohol,
    String? sortBy,
    List<VendorSummary>? results,
    bool? isLoading,
  }) {
    return SearchUiState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      priceRange: priceRange ?? this.priceRange,
      capacityRange: capacityRange ?? this.capacityRange,
      selectedVenueTypes: selectedVenueTypes ?? this.selectedVenueTypes,
      selectedDietary: selectedDietary ?? this.selectedDietary,
      selectedSubServices: selectedSubServices ?? this.selectedSubServices,
      isAcPreferred: isAcPreferred == null ? this.isAcPreferred : (isAcPreferred ? true : null),
      hasParking: hasParking == null ? this.hasParking : (hasParking ? true : null),
      allowsAlcohol: allowsAlcohol == null ? this.allowsAlcohol : (allowsAlcohol ? true : null),
      sortBy: sortBy ?? this.sortBy,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  SearchUiState clearFilters() {
    return SearchUiState(
      searchQuery: searchQuery,
      selectedCategory: selectedCategory,
      sortBy: sortBy,
      results: results,
      isLoading: isLoading,
    );
  }
}

// ─── Comprehensive 20 Category Mock Data ───────────────────────────────────────

final List<VendorSummary> allMockVendors = [
  // 1. Banquet Halls
  const VendorSummary(
    id: 'v1', name: 'Elite Heritage Grand Resort', locality: 'Jubilee Hills',
    rating: 4.9, reviewCount: 182, basePlatePrice: 1600, packagePrice: 500000,
    imageUrls: ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Banquet Halls',
    subServices: ['Luxury Banquets', 'AC Banquet Halls', 'Destination Ballroom'],
    specs: VendorCategorySpecs(
      vegPlatePrice: 1600,
      nonVegPlatePrice: 2000,
      guestCapacity: 1200,
      roomsAvailable: 25,
    ),
  ),
  // 2. Kalyana Mandapams
  const VendorSummary(
    id: 'v2', name: 'Royal Pearl Kalyana Mandapam', locality: 'Madhapur',
    rating: 4.7, reviewCount: 95, basePlatePrice: 1200, packagePrice: 380000,
    imageUrls: ['https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Kalyana Mandapams',
    subServices: ['Traditional Marriage Halls', 'Vedic Kalyana Mandapams'],
    specs: VendorCategorySpecs(
      vegPlatePrice: 1200,
      nonVegPlatePrice: 1500,
      guestCapacity: 800,
      roomsAvailable: 15,
    ),
  ),
  // 3. Open Lawns
  const VendorSummary(
    id: 'v3', name: 'Lotus Green Garden Lawns', locality: 'Hitech City',
    rating: 4.6, reviewCount: 78, basePlatePrice: 850, packagePrice: 250000,
    imageUrls: ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Open Lawns',
    subServices: ['Marriage Gardens', 'Farmhouses', 'Lakeside Lawns'],
    specs: VendorCategorySpecs(
      vegPlatePrice: 850,
      nonVegPlatePrice: 1100,
      guestCapacity: 2000,
      roomsAvailable: 4,
    ),
  ),
  
  // 4. Photographers
  const VendorSummary(
    id: 'p1', name: 'Lux Wedding Cinema & Studios', locality: 'Jubilee Hills',
    rating: 4.9, reviewCount: 240, basePlatePrice: 80000, packagePrice: 80000,
    imageUrls: ['https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Photographers',
    subServices: ['Candid Photography', 'Cinematography', 'Drone Coverage'],
    specs: VendorCategorySpecs(
      candidDayRate: 80000,
      videoDayRate: 100000,
      deliveryTimelineDays: 45,
      equipmentBrand: 'Sony A1 & FX6',
    ),
  ),
  const VendorSummary(
    id: 'p2', name: 'Stories by Pixel Magic', locality: 'Gachibowli',
    rating: 4.8, reviewCount: 112, basePlatePrice: 50000, packagePrice: 50000,
    imageUrls: ['https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Photographers',
    subServices: ['Traditional Shoots', 'Pre-Wedding Shoot'],
    specs: VendorCategorySpecs(
      candidDayRate: 50000,
      videoDayRate: 65000,
      deliveryTimelineDays: 30,
      equipmentBrand: 'Canon EOS R5',
    ),
  ),

  // 5. Bridal Makeup
  const VendorSummary(
    id: 'm1', name: 'Bridal Artistry by Anisha', locality: 'Banjara Hills',
    rating: 4.9, reviewCount: 195, basePlatePrice: 30000, packagePrice: 30000,
    imageUrls: ['https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Bridal Makeup',
    subServices: ['Bridal Makeup Artist', 'HD Makeup', 'Airbrush Specialists'],
    specs: VendorCategorySpecs(
      bridalMakeupPrice: 30000,
      familyMakeupPrice: 5000,
      makeupBrandTier: 'HD - Huda Beauty & MAC',
      trialSessionAvailable: true,
    ),
  ),

  // 6. Decorators
  const VendorSummary(
    id: 'd1', name: 'Grand Canopy Design Studio', locality: 'Secunderabad',
    rating: 4.8, reviewCount: 88, basePlatePrice: 120000, packagePrice: 120000,
    imageUrls: ['https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Decorators',
    subServices: ['Floral Mandap Decor', 'Fairy Lights Setup', 'Acrylic Glass Mandaps'],
    specs: VendorCategorySpecs(
      indoorDecorPrice: 120000,
      outdoorStagePrice: 180000,
      setupHours: 8,
      floralGrade: 'Premium Fresh Flowers',
    ),
  ),

  // 7. Catering
  const VendorSummary(
    id: 'c1', name: 'Saffron Royal Catering Service', locality: 'Madhapur',
    rating: 4.8, reviewCount: 154, basePlatePrice: 1400, packagePrice: 140000,
    imageUrls: ['https://images.unsplash.com/photo-1555244162-803834f70033?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Catering',
    subServices: ['Pure Veg Buffets', 'Multi-Cuisine Catering', 'Live Chaat Counters'],
    specs: VendorCategorySpecs(
      cateringVegPrice: 1400,
      cateringNonVegPrice: 1800,
      minPlatesBooking: 150,
    ),
  ),

  // 8. Mehndi Art
  const VendorSummary(
    id: 'h1', name: 'Traditional Mehndi by Riya', locality: 'Begumpet',
    rating: 4.7, reviewCount: 64, basePlatePrice: 8000, packagePrice: 8000,
    imageUrls: ['https://images.unsplash.com/photo-1562322140-8baeececf3df?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Mehndi Art',
    subServices: ['Traditional Indian Bridal', 'Arabic Intricate Designs'],
  ),

  // 9. Invitations
  const VendorSummary(
    id: 'i1', name: 'Royal Scroll Luxury Cards', locality: 'Abids',
    rating: 4.6, reviewCount: 48, basePlatePrice: 150, packagePrice: 15000,
    imageUrls: ['https://images.unsplash.com/photo-1512909006721-3d6018887383?w=800'],
    isEscrowProtected: false, isFastFilling: false, isVerified: true, category: 'Invitations',
    subServices: ['Physical Cards & Scrolls', 'Luxury Boxed Invites', 'Digital E-cards'],
  ),

  // 10. Jewellery
  const VendorSummary(
    id: 'j1', name: 'Heritage Gold & Diamonds', locality: 'Somajiguda',
    rating: 4.9, reviewCount: 310, basePlatePrice: 200000, packagePrice: 500000,
    imageUrls: ['https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Jewellery',
    subServices: ['Antique Temple Gold', 'Kundan & Polki Sets', 'Precious Diamond Bridal'],
  ),

  // 11. DJ & Sound
  const VendorSummary(
    id: 'dj1', name: 'DJ Sound Blast & Light Show', locality: 'Secunderabad',
    rating: 4.8, reviewCount: 120, basePlatePrice: 40000, packagePrice: 40000,
    imageUrls: ['https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'DJ & Sound',
    subServices: ['Elite Sangeet DJs', 'Baraat Mobil Sound', 'Visual Laser Lighting'],
  ),

  // 12. Bridal Wear
  const VendorSummary(
    id: 'bw1', name: 'Ananya Couture Bridal Lehengas', locality: 'Banjara Hills',
    rating: 4.9, reviewCount: 96, basePlatePrice: 150000, packagePrice: 150000,
    imageUrls: ['https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Bridal Wear',
    subServices: ['Bridal Lehengas', 'Reception Gowns', 'Custom Designer Wear'],
  ),

  // 13. Luxury Cars
  const VendorSummary(
    id: 'car1', name: 'Royal Vintage Car Rental', locality: 'Kondapur',
    rating: 4.7, reviewCount: 42, basePlatePrice: 25000, packagePrice: 25000,
    imageUrls: ['https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Luxury Cars',
    subServices: ['Vintage Wedding Cars', 'Convertible Baraat Cars', 'Luxury Guest Coaches'],
  ),

  // 14. Entertainment
  const VendorSummary(
    id: 'ent1', name: 'Jugalbandi Live Sufi Band', locality: 'Gachibowli',
    rating: 4.8, reviewCount: 75, basePlatePrice: 60000, packagePrice: 60000,
    imageUrls: ['https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Entertainment',
    subServices: ['Celebrity Musicians', 'Live Instrumentalists', 'Themed Photobooths'],
  ),

  // 15. Choreography
  const VendorSummary(
    id: 'cho1', name: 'Sangeet Choreography by Vicky', locality: 'Madhapur',
    rating: 4.9, reviewCount: 110, basePlatePrice: 35000, packagePrice: 35000,
    imageUrls: ['https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Choreography',
    subServices: ['Sangeet Group Dance', 'Couple Entry Routines', 'Flash Mob Styling'],
  ),

  // 16. Gifts & Hampers
  const VendorSummary(
    id: 'gift1', name: 'The Hamper Boutique & Favors', locality: 'Begumpet',
    rating: 4.5, reviewCount: 30, basePlatePrice: 800, packagePrice: 24000,
    imageUrls: ['https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=800'],
    isEscrowProtected: false, isFastFilling: false, isVerified: false, category: 'Gifts & Hampers',
    subServices: ['Trousseau Packaging', 'Personalized Hampers', 'Mehndi Return Favors'],
  ),

  // 17. Pandits & Priests
  const VendorSummary(
    id: 'pan1', name: 'Pandit Shastri Ji (Vedic Rituals)', locality: 'Secunderabad',
    rating: 4.9, reviewCount: 165, basePlatePrice: 15000, packagePrice: 15000,
    imageUrls: ['https://images.unsplash.com/photo-1583939003579-730e3918a45a?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Pandits & Priests',
    subServices: ['Vedic Marriage Priests', 'Homam Specialists', 'Multi-Lingual Pandits'],
  ),

  // 18. Honeymoon Travel
  const VendorSummary(
    id: 'hon1', name: 'Honeymoon Bliss Travel & Tours', locality: 'Somajiguda',
    rating: 4.8, reviewCount: 55, basePlatePrice: 120000, packagePrice: 120000,
    imageUrls: ['https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Honeymoon Travel',
    subServices: ['Romantic Getaways', 'International Packages', 'Domestic Retreats'],
  ),

  // 19. Planners
  const VendorSummary(
    id: 'pla1', name: 'Celestial Weddings & Planners', locality: 'Jubilee Hills',
    rating: 4.9, reviewCount: 140, basePlatePrice: 250000, packagePrice: 250000,
    imageUrls: ['https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Planners',
    subServices: ['Full Event Execution', 'Partial Coordination', 'Logistics & Travel Planners'],
  ),
];

// ─── Search Notifier ──────────────────────────────────────────────────────────

class SearchNotifier extends StateNotifier<SearchUiState> {
  SearchNotifier() : super(const SearchUiState()) {
    _performSearch();
  }

  void updateQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _performSearch();
  }

  void selectCategory(String category) {
    // When switching category, reset the selected subservices
    state = state.copyWith(
      selectedCategory: category,
      selectedSubServices: const [],
    );
    _performSearch();
  }

  void updatePriceRange(RangeValues newRange) {
    state = state.copyWith(priceRange: newRange);
    _performSearch();
  }

  void updateCapacityRange(RangeValues newRange) {
    state = state.copyWith(capacityRange: newRange);
    _performSearch();
  }

  void toggleVenueType(String type) {
    final list = List<String>.from(state.selectedVenueTypes);
    if (list.contains(type)) {
      list.remove(type);
    } else {
      list.add(type);
    }
    state = state.copyWith(selectedVenueTypes: list);
    _performSearch();
  }

  void toggleDietary(String pref) {
    final list = List<String>.from(state.selectedDietary);
    if (list.contains(pref)) {
      list.remove(pref);
    } else {
      list.add(pref);
    }
    state = state.copyWith(selectedDietary: list);
    _performSearch();
  }

  void toggleSubService(String subService) {
    final list = List<String>.from(state.selectedSubServices);
    if (list.contains(subService)) {
      list.remove(subService);
    } else {
      list.add(subService);
    }
    state = state.copyWith(selectedSubServices: list);
    _performSearch();
  }

  void setAcPreferred(bool? value) {
    state = state.copyWith(isAcPreferred: value);
    _performSearch();
  }

  void setParking(bool? value) {
    state = state.copyWith(hasParking: value);
    _performSearch();
  }

  void setAlcohol(bool? value) {
    state = state.copyWith(allowsAlcohol: value);
    _performSearch();
  }

  void setSortBy(String sort) {
    state = state.copyWith(sortBy: sort);
    _performSearch();
  }

  void clearAllFilters() {
    state = state.clearFilters().copyWith(
      selectedSubServices: const [],
      selectedVenueTypes: const [],
      selectedDietary: const [],
    );
    _performSearch();
  }

  Future<void> _performSearch() async {
    state = state.copyWith(isLoading: true);
    
    // Simulate slight network delay for high-fidelity feel
    await Future.delayed(const Duration(milliseconds: 250));

    var filtered = allMockVendors.where((vendor) {
      // 1. Category Filter
      if (state.selectedCategory != 'All' && vendor.category != state.selectedCategory) {
        return false;
      }

      // 2. Query Filter (Name or Locality)
      if (state.searchQuery.isNotEmpty) {
        final query = state.searchQuery.toLowerCase();
        if (!vendor.name.toLowerCase().contains(query) &&
            !vendor.locality.toLowerCase().contains(query)) {
          return false;
        }
      }

      // 3. Price Filter (Dynamic plate price for per-plate categories, package price for others)
      final isPerPlateCategory = vendor.category == 'Banquet Halls' ||
          vendor.category == 'Kalyana Mandapams' ||
          vendor.category == 'Open Lawns' ||
          vendor.category == 'Catering';
          
      final price = isPerPlateCategory
          ? vendor.basePlatePrice
          : vendor.packagePrice;
      
      if (isPerPlateCategory) {
        if (price < state.priceRange.start || price > state.priceRange.end) {
          return false;
        }
      }

      // 4. Sub-services Filter
      if (state.selectedSubServices.isNotEmpty) {
        final vendorSubServices = vendor.subServices ?? [];
        bool matchesSubService = false;
        for (final sub in state.selectedSubServices) {
          if (vendorSubServices.contains(sub) ||
              vendor.name.toLowerCase().contains(sub.toLowerCase())) {
            matchesSubService = true;
            break;
          }
        }
        if (!matchesSubService) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    if (state.sortBy == 'PriceLowToHigh') {
      filtered.sort((a, b) {
        final isPerPlateA = a.category == 'Banquet Halls' || a.category == 'Kalyana Mandapams' || a.category == 'Open Lawns' || a.category == 'Catering';
        final isPerPlateB = b.category == 'Banquet Halls' || b.category == 'Kalyana Mandapams' || b.category == 'Open Lawns' || b.category == 'Catering';
        final priceA = isPerPlateA ? a.basePlatePrice : a.packagePrice;
        final priceB = isPerPlateB ? b.basePlatePrice : b.packagePrice;
        return priceA.compareTo(priceB);
      });
    } else if (state.sortBy == 'PriceHighToLow') {
      filtered.sort((a, b) {
        final isPerPlateA = a.category == 'Banquet Halls' || a.category == 'Kalyana Mandapams' || a.category == 'Open Lawns' || a.category == 'Catering';
        final isPerPlateB = b.category == 'Banquet Halls' || b.category == 'Kalyana Mandapams' || b.category == 'Open Lawns' || b.category == 'Catering';
        final priceA = isPerPlateA ? a.basePlatePrice : a.packagePrice;
        final priceB = isPerPlateB ? b.basePlatePrice : b.packagePrice;
        return priceB.compareTo(priceA);
      });
    } else if (state.sortBy == 'Rating') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      // Popularity (Default)
      filtered.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }

    state = state.copyWith(
      results: filtered,
      isLoading: false,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final searchNotifierProvider = StateNotifierProvider<SearchNotifier, SearchUiState>(
  (ref) => SearchNotifier(),
);
