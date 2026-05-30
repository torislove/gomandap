import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
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

// ─── Notifier (manual, no code-gen) ──────────────────────────────────────────

class SearchNotifier extends Notifier<SearchUiState> {
  StreamSubscription? _searchSub;

  @override
  SearchUiState build() {
    ref.onDispose(() {
      _searchSub?.cancel();
      _debounceTimer?.cancel();
    });
    Future.microtask(_performSearch);
    return const SearchUiState();
  }

  // Existing methods ...

  // Compatibility wrappers for UI components expecting older method names
  void updateQuery(String query) => setSearchQuery(query);
  void selectCategory(String category) => setSelectedCategory(category);
  void updatePriceRange(RangeValues range) => setPriceRange(range);
  void updateCapacityRange(RangeValues range) => setCapacityRange(range);
  void setAcPreferred(bool value) => toggleAcPreferred(value);
  void setParking(bool value) => toggleParking(value);
  void setAlcohol(bool value) => toggleAlcohol(value);



  Timer? _debounceTimer;

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query, isLoading: true);
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch();
    });
  }

  void setSelectedCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    _performSearch();
  }

  void setPriceRange(RangeValues range) {
    state = state.copyWith(priceRange: range);
    _performSearch();
  }

  void setCapacityRange(RangeValues range) {
    state = state.copyWith(capacityRange: range);
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

  void toggleDietary(String diet) {
    final list = List<String>.from(state.selectedDietary);
    if (list.contains(diet)) {
      list.remove(diet);
    } else {
      list.add(diet);
    }
    state = state.copyWith(selectedDietary: list);
    _performSearch();
  }

  void toggleSubService(String sub) {
    final list = List<String>.from(state.selectedSubServices);
    if (list.contains(sub)) {
      list.remove(sub);
    } else {
      list.add(sub);
    }
    state = state.copyWith(selectedSubServices: list);
    _performSearch();
  }

  void toggleAcPreferred(bool active) {
    state = state.copyWith(isAcPreferred: active);
    _performSearch();
  }

  void toggleParking(bool active) {
    state = state.copyWith(hasParking: active);
    _performSearch();
  }

  void toggleAlcohol(bool active) {
    state = state.copyWith(allowsAlcohol: active);
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

  String _mapCategoryToDbType(String category) {
    switch (category) {
      case 'Banquet Halls':
      case 'Kalyana Mandapams':
      case 'Open Lawns':
        return 'Banquet';
      case 'Photographers':
        return 'Photography';
      case 'Decorators':
        return 'Decorator';
      case 'Catering':
        return 'Catering';
      case 'Bridal Makeup':
        return 'Makeup';
      default:
        if (category.contains('Photo')) return 'Photography';
        if (category.contains('Makeup')) return 'Makeup';
        if (category.contains('Decor')) return 'Decorator';
        if (category.contains('Cater')) return 'Catering';
        return 'Banquet';
    }
  }

  VendorSummary _mapRowToSummary(Map<String, dynamic> row) {
    final gallery = row['photos'] as List<dynamic>?;
    final images = gallery?.map((e) => e.toString()).toList() ?? [];
    if (images.isEmpty) {
      final cover = row['cover_photo_url']?.toString();
      if (cover != null && cover.isNotEmpty) {
        images.add(cover);
      }
    }
    
    Map<String, dynamic>? rawSpecs;
    if (row['type_data'] != null) {
      if (row['type_data'] is Map) {
        rawSpecs = Map<String, dynamic>.from(row['type_data'] as Map);
      }
    }

    final categoryName = row['type']?.toString() == 'Banquet' ? 'Venue' : (row['type']?.toString() ?? 'Service');

    return VendorSummary(
      id: row['id']?.toString() ?? '',
      name: row['name']?.toString() ?? '',
      locality: row['locality']?.toString() ?? '',
      rating: double.tryParse(row['rating']?.toString() ?? '') ?? 4.8,
      reviewCount: 18,
      basePlatePrice: double.tryParse(row['base_price']?.toString() ?? '') ?? 1500,
      packagePrice: double.tryParse(row['base_price']?.toString() ?? '') ?? 450000,
      imageUrls: images.isEmpty ? ['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'] : images,
      videoUrl: row['video_url']?.toString(),
      isEscrowProtected: row['is_escrow_protected'] as bool? ?? true,
      isFastFilling: row['is_fast_filling'] as bool? ?? false,
      isVerified: row['is_verified'] as bool? ?? true,
      category: categoryName,
      specs: VendorCategorySpecs.fromJson(rawSpecs),
    );
  }

  void _performSearch() {
    state = state.copyWith(isLoading: true);

    final client = ref.read(supabaseClientProvider);
    if (client == null) {
      state = state.copyWith(isLoading: false, results: const []);
      return;
    }

    _searchSub?.cancel();

    try {
      final baseQuery = client.from('vendors').stream(primaryKey: ['id']);
      Stream<List<Map<String, dynamic>>> stream;

      // 1. Category Filter via Stream
      if (state.selectedCategory != 'All') {
        final typeString = _mapCategoryToDbType(state.selectedCategory);
        stream = baseQuery.eq('type', typeString);
      } else {
        stream = baseQuery;
      }

      _searchSub = stream.listen((rows) {
        // 2. Filter approved & live
        var validRows = rows.where((row) => 
          row['approval_status'] == 'APPROVED' && row['is_live'] == true
        );

        // 3. Text query filter (Name or Locality) in-memory
        if (state.searchQuery.isNotEmpty) {
          final q = state.searchQuery.toLowerCase();
          validRows = validRows.where((row) {
            final name = (row['name']?.toString() ?? '').toLowerCase();
            final loc = (row['locality']?.toString() ?? '').toLowerCase();
            return name.contains(q) || loc.contains(q);
          });
        }

        var vendors = validRows.map<VendorSummary>((row) => _mapRowToSummary(row)).toList();

        // 4. Apply in-memory ranges
        vendors = vendors.where((vendor) {
          final isPerPlateCategory = vendor.category == 'Banquet Halls' ||
              vendor.category == 'Kalyana Mandapams' ||
              vendor.category == 'Open Lawns' ||
              vendor.category == 'Catering' ||
              vendor.category == 'Venue';
              
          final price = isPerPlateCategory ? vendor.basePlatePrice : vendor.packagePrice;
          
          if (isPerPlateCategory) {
            if (price < state.priceRange.start || price > state.priceRange.end) {
              return false;
            }
          }
          return true;
        }).toList();

        // 5. Sorting
        if (state.sortBy == 'PriceLowToHigh') {
          vendors.sort((a, b) {
            final isPerPlateA = ['Banquet Halls', 'Kalyana Mandapams', 'Open Lawns', 'Catering', 'Venue'].contains(a.category);
            final isPerPlateB = ['Banquet Halls', 'Kalyana Mandapams', 'Open Lawns', 'Catering', 'Venue'].contains(b.category);
            final priceA = isPerPlateA ? a.basePlatePrice : a.packagePrice;
            final priceB = isPerPlateB ? b.basePlatePrice : b.packagePrice;
            return priceA.compareTo(priceB);
          });
        } else if (state.sortBy == 'PriceHighToLow') {
          vendors.sort((a, b) {
            final isPerPlateA = ['Banquet Halls', 'Kalyana Mandapams', 'Open Lawns', 'Catering', 'Venue'].contains(a.category);
            final isPerPlateB = ['Banquet Halls', 'Kalyana Mandapams', 'Open Lawns', 'Catering', 'Venue'].contains(b.category);
            final priceA = isPerPlateA ? a.basePlatePrice : a.packagePrice;
            final priceB = isPerPlateB ? b.basePlatePrice : b.packagePrice;
            return priceB.compareTo(priceA);
          });
        } else if (state.sortBy == 'Rating') {
          vendors.sort((a, b) => b.rating.compareTo(a.rating));
        } else {
          vendors.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        }

        state = state.copyWith(
          results: vendors,
          isLoading: false,
        );
      });
    } catch (e) {
      debugPrint('Search error: $e');
      state = state.copyWith(isLoading: false, results: const []);
    }
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final searchNotifierProvider = NotifierProvider<SearchNotifier, SearchUiState>(
  SearchNotifier.new,
);
