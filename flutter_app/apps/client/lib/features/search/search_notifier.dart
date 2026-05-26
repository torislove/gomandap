import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_notifier.dart';

class SearchUiState {
  final String searchQuery;
  final String selectedCategory; // 'All' or specific category
  final RangeValues priceRange;
  final RangeValues capacityRange;
  final List<String> selectedVenueTypes;
  final List<String> selectedDietary;
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

// ─── Comprehensive 17 Category Mock Data ───────────────────────────────────────

final List<VendorSummary> allMockVendors = [
  // 1. Venues
  const VendorSummary(
    id: 'v1', name: 'Elite Heritage Grand resort', locality: 'Jubilee Hills',
    rating: 4.9, reviewCount: 182, basePlatePrice: 1600, packagePrice: 500000,
    imageUrls: ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Venue',
  ),
  const VendorSummary(
    id: 'v2', name: 'Royal Pearl Convention Hall', locality: 'Madhapur',
    rating: 4.7, reviewCount: 95, basePlatePrice: 1200, packagePrice: 380000,
    imageUrls: ['https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Venue',
  ),
  const VendorSummary(
    id: 'v3', name: 'Lotus Green Garden Lawns', locality: 'Hitech City',
    rating: 4.6, reviewCount: 78, basePlatePrice: 850, packagePrice: 250000,
    imageUrls: ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Venue',
  ),
  
  // 2. Photography
  const VendorSummary(
    id: 'p1', name: 'Lux Wedding Cinema & Studios', locality: 'Jubilee Hills',
    rating: 4.9, reviewCount: 240, basePlatePrice: 80000, packagePrice: 80000,
    imageUrls: ['https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Photography',
  ),
  const VendorSummary(
    id: 'p2', name: 'Stories by Pixel Magic', locality: 'Gachibowli',
    rating: 4.8, reviewCount: 112, basePlatePrice: 50000, packagePrice: 50000,
    imageUrls: ['https://images.unsplash.com/photo-1542038784456-1ea8e935640e?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Photography',
  ),

  // 3. Makeup
  const VendorSummary(
    id: 'm1', name: 'Bridal Artistry by Anisha', locality: 'Banjara Hills',
    rating: 4.9, reviewCount: 195, basePlatePrice: 30000, packagePrice: 30000,
    imageUrls: ['https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Makeup',
  ),

  // 4. Decor
  const VendorSummary(
    id: 'd1', name: 'Grand Canopy Design Studio', locality: 'Secunderabad',
    rating: 4.8, reviewCount: 88, basePlatePrice: 120000, packagePrice: 120000,
    imageUrls: ['https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Decor',
  ),

  // 5. Catering
  const VendorSummary(
    id: 'c1', name: 'Saffron Royal Catering Service', locality: 'Madhapur',
    rating: 4.8, reviewCount: 154, basePlatePrice: 1400, packagePrice: 140000,
    imageUrls: ['https://images.unsplash.com/photo-1555244162-803834f70033?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Catering',
  ),

  // 6. Mehndi
  const VendorSummary(
    id: 'h1', name: 'Traditional Mehndi by Riya', locality: 'Begumpet',
    rating: 4.7, reviewCount: 64, basePlatePrice: 8000, packagePrice: 8000,
    imageUrls: ['https://images.unsplash.com/photo-1562322140-8baeececf3df?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Mehndi',
  ),

  // 7. Invitations
  const VendorSummary(
    id: 'i1', name: 'Royal Scroll Luxury Cards', locality: 'Abids',
    rating: 4.6, reviewCount: 48, basePlatePrice: 150, packagePrice: 15000,
    imageUrls: ['https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?w=800'],
    isEscrowProtected: false, isFastFilling: false, isVerified: true, category: 'Invitations',
  ),

  // 8. Jewellery
  const VendorSummary(
    id: 'j1', name: 'Heritage Gold & Diamonds', locality: 'Somajiguda',
    rating: 4.9, reviewCount: 310, basePlatePrice: 200000, packagePrice: 500000,
    imageUrls: ['https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Jewellery',
  ),

  // 9. DJ
  const VendorSummary(
    id: 'dj1', name: 'DJ Sound Blast & Light Show', locality: 'Secunderabad',
    rating: 4.8, reviewCount: 120, basePlatePrice: 40000, packagePrice: 40000,
    imageUrls: ['https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'DJ',
  ),

  // 10. Bridal Wear
  const VendorSummary(
    id: 'bw1', name: 'Ananya Couture Bridal Lehengas', locality: 'Banjara Hills',
    rating: 4.9, reviewCount: 96, basePlatePrice: 150000, packagePrice: 150000,
    imageUrls: ['https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Bridal Wear',
  ),

  // 11. Cars
  const VendorSummary(
    id: 'car1', name: 'Royal Vintage Car Rental', locality: 'Kondapur',
    rating: 4.7, reviewCount: 42, basePlatePrice: 25000, packagePrice: 25000,
    imageUrls: ['https://images.unsplash.com/photo-1511919884226-fd3cad34687c?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Cars',
  ),

  // 12. Entertainment
  const VendorSummary(
    id: 'ent1', name: 'Jugalbandi Live Sufi Band', locality: 'Gachibowli',
    rating: 4.8, reviewCount: 75, basePlatePrice: 60000, packagePrice: 60000,
    imageUrls: ['https://images.unsplash.com/photo-1465847899084-d164df4dedc6?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Entertainment',
  ),

  // 13. Choreographers
  const VendorSummary(
    id: 'cho1', name: 'Sangeet Choreography by Vicky', locality: 'Madhapur',
    rating: 4.9, reviewCount: 110, basePlatePrice: 35000, packagePrice: 35000,
    imageUrls: ['https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Choreographers',
  ),

  // 14. Gifts
  const VendorSummary(
    id: 'gift1', name: 'The Hamper Boutique & Favors', locality: 'Begumpet',
    rating: 4.5, reviewCount: 30, basePlatePrice: 800, packagePrice: 24000,
    imageUrls: ['https://images.unsplash.com/photo-1549465220-1a8b9238cd48?w=800'],
    isEscrowProtected: false, isFastFilling: false, isVerified: false, category: 'Gifts',
  ),

  // 15. Pandits
  const VendorSummary(
    id: 'pan1', name: 'Pandit Shastri Ji (Vedic Rituals)', locality: 'Secunderabad',
    rating: 4.9, reviewCount: 165, basePlatePrice: 15000, packagePrice: 15000,
    imageUrls: ['https://images.unsplash.com/photo-1545128485-c400e7702796?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Pandits',
  ),

  // 16. Honeymoon
  const VendorSummary(
    id: 'hon1', name: 'Honeymoon Bliss Travel & Tours', locality: 'Somajiguda',
    rating: 4.8, reviewCount: 55, basePlatePrice: 120000, packagePrice: 120000,
    imageUrls: ['https://images.unsplash.com/photo-1506929562872-bb421503ef21?w=800'],
    isEscrowProtected: true, isFastFilling: false, isVerified: true, category: 'Honeymoon',
  ),

  // 17. Planners
  const VendorSummary(
    id: 'pla1', name: 'Celestial Weddings & Planners', locality: 'Jubilee Hills',
    rating: 4.9, reviewCount: 140, basePlatePrice: 250000, packagePrice: 250000,
    imageUrls: ['https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'],
    isEscrowProtected: true, isFastFilling: true, isVerified: true, category: 'Planners',
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
    state = state.copyWith(selectedCategory: category);
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
    state = state.clearFilters();
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

      // 3. Price Filter (Dynamic plate price for Venue/Catering, package price for others)
      final price = (vendor.category == 'Venue' || vendor.category == 'Catering')
          ? vendor.basePlatePrice
          : vendor.packagePrice;
      
      // If we are looking at Venues/Catering, we check per-plate price range.
      // For luxury packages, range expands dynamically or we bypass it for packages > 3000
      if (vendor.category == 'Venue' || vendor.category == 'Catering') {
        if (price < state.priceRange.start || price > state.priceRange.end) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    if (state.sortBy == 'PriceLowToHigh') {
      filtered.sort((a, b) => (a.category == 'Venue' ? a.basePlatePrice : a.packagePrice)
          .compareTo(b.category == 'Venue' ? b.basePlatePrice : b.packagePrice));
    } else if (state.sortBy == 'PriceHighToLow') {
      filtered.sort((a, b) => (b.category == 'Venue' ? b.basePlatePrice : b.packagePrice)
          .compareTo(a.category == 'Venue' ? a.basePlatePrice : a.packagePrice));
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
