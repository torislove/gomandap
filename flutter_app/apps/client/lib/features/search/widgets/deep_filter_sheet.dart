import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/presentation/widgets/antigravity_range_slider.dart';
import 'package:gomandap_common/presentation/widgets/antigravity_bouncy_switch.dart';
import 'package:gomandap_common/domain/models/category_model.dart';
import '../search_notifier.dart';
import 'live_count_apply_button.dart';

class DeepFilterSheet extends ConsumerWidget {
  const DeepFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    CategoryDetails? currentCategory;
    for (final cat in weddingCategoriesList) {
      if (cat.name == searchState.selectedCategory) {
        currentCategory = cat;
        break;
      }
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Header Drag Handle Indicator
              const SizedBox(height: 12),
              Container(
                width: 48, height: 5,
                decoration: BoxDecoration(
                  color: GomandapTokens.lightSlate,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: GomandapTokens.champagneGoldEnd),
                        const SizedBox(width: 6),
                        Text(
                          'Deep Filters: ${searchState.selectedCategory}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: GomandapTokens.royalNavy,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        notifier.clearAllFilters();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                      child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              const Divider(color: GomandapTokens.lightSlate),

              // Scrollable Filter Settings
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Sorting Method
                    const Text(
                      'Sort By',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                    ),
                    const SizedBox(height: 10),
                    _SortSelector(
                      currentSort: searchState.sortBy,
                      onSortChanged: (sort) => notifier.setSortBy(sort),
                    ),
                    const SizedBox(height: 28),

                    // Polymorphic Filters based on Category selection
                    if (searchState.selectedCategory == 'Banquet Halls' ||
                        searchState.selectedCategory == 'Kalyana Mandapams' ||
                        searchState.selectedCategory == 'Open Lawns') ...[
                      // Per-Plate Price Range Slider
                      AntigravityRangeSlider(
                        min: 200,
                        max: 3000,
                        values: searchState.priceRange,
                        onChanged: (values) => notifier.updatePriceRange(values),
                        labelFormatter: (val) => '₹${val.toInt()}/plate',
                      ),
                      const SizedBox(height: 28),

                      // Capacity Range Slider
                      AntigravityRangeSlider(
                        min: 100,
                        max: 2000,
                        values: searchState.capacityRange,
                        onChanged: (values) => notifier.updateCapacityRange(values),
                        labelFormatter: (val) => '${val.toInt()} Pax',
                      ),
                      const SizedBox(height: 28),

                      // Dynamic Sub-Services list
                      if (currentCategory != null && currentCategory.subServices.isNotEmpty) ...[
                        Text(
                          'Sub-Services in ${currentCategory.name}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: currentCategory.subServices.map((subService) {
                            final isSelected = searchState.selectedSubServices.contains(subService);
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                notifier.toggleSubService(subService);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? GomandapTokens.emeraldGreen : GomandapTokens.softMist,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : GomandapTokens.lightSlate,
                                  ),
                                ),
                                child: Text(
                                  subService,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? Colors.white : GomandapTokens.royalNavy,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Switches/Amenities
                      const Text(
                        'Key Requirements',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                      ),
                      const SizedBox(height: 8),
                      AntigravityBouncySwitch(
                        value: searchState.isAcPreferred ?? false,
                        onChanged: (val) => notifier.setAcPreferred(val),
                        title: 'Fully Air Conditioned',
                        subtitle: 'Venues with comprehensive AC installation',
                        icon: Icons.ac_unit,
                      ),
                      const Divider(color: GomandapTokens.lightSlate, height: 1),
                      AntigravityBouncySwitch(
                        value: searchState.hasParking ?? false,
                        onChanged: (val) => notifier.setParking(val),
                        title: 'Valet & Ample Parking',
                        subtitle: 'Has dedicated parking bays for 100+ cars',
                        icon: Icons.local_parking_rounded,
                      ),
                      const Divider(color: GomandapTokens.lightSlate, height: 1),
                      AntigravityBouncySwitch(
                        value: searchState.allowsAlcohol ?? false,
                        onChanged: (val) => notifier.setAlcohol(val),
                        title: 'Allows Alcohol',
                        subtitle: 'Has bar license / allows custom outside bars',
                        icon: Icons.local_bar_rounded,
                      ),
                    ] else if (searchState.selectedCategory == 'Catering') ...[
                      // Price range for catering
                      AntigravityRangeSlider(
                        min: 200,
                        max: 3000,
                        values: searchState.priceRange,
                        onChanged: (values) => notifier.updatePriceRange(values),
                        labelFormatter: (val) => '₹${val.toInt()}/plate',
                      ),
                      const SizedBox(height: 28),

                      // Dynamic Sub-Services list
                      if (currentCategory != null && currentCategory.subServices.isNotEmpty) ...[
                        Text(
                          'Sub-Services in ${currentCategory.name}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: currentCategory.subServices.map((subService) {
                            final isSelected = searchState.selectedSubServices.contains(subService);
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                notifier.toggleSubService(subService);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? GomandapTokens.emeraldGreen : GomandapTokens.softMist,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : GomandapTokens.lightSlate,
                                  ),
                                ),
                                child: Text(
                                  subService,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? Colors.white : GomandapTokens.royalNavy,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Catering Dietary Preference
                      const Text(
                        'Dietary Preference',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: ['Pure Veg Only', 'Non-Veg Allowed', 'Jain Food Available'].map((pref) {
                          final isSelected = searchState.selectedDietary.contains(pref);
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.toggleDietary(pref);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? GomandapTokens.emeraldGreen : GomandapTokens.softMist,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : GomandapTokens.lightSlate,
                                ),
                              ),
                              child: Text(
                                pref,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? Colors.white : GomandapTokens.royalNavy,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      // Generic Standard Package Budget slider for services
                      const Text(
                        'Budget Range (Package)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                      ),
                      const SizedBox(height: 12),
                      AntigravityRangeSlider(
                        min: 200,
                        max: 3000, // Reuse state value for simplicity
                        values: searchState.priceRange,
                        onChanged: (values) => notifier.updatePriceRange(values),
                        labelFormatter: (val) => '₹${(val * 150).toInt()}',
                      ),
                      const SizedBox(height: 28),

                      // Dynamic Sub-Services list
                      if (currentCategory != null && currentCategory.subServices.isNotEmpty) ...[
                        Text(
                          'Sub-Services in ${currentCategory.name}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8, runSpacing: 8,
                          children: currentCategory.subServices.map((subService) {
                            final isSelected = searchState.selectedSubServices.contains(subService);
                            return GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                notifier.toggleSubService(subService);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? GomandapTokens.emeraldGreen : GomandapTokens.softMist,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : GomandapTokens.lightSlate,
                                  ),
                                ),
                                child: Text(
                                  subService,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? Colors.white : GomandapTokens.royalNavy,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Bottom Live Count Apply Overlay
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LiveCountApplyButton(
                    count: searchState.results.length,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SortSelector extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  const _SortSelector({
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final sortOptions = [
      {'id': 'Popularity', 'label': 'Popular ⚡'},
      {'id': 'Rating', 'label': 'Highly Rated ⭐'},
      {'id': 'PriceLowToHigh', 'label': 'Price: Low → High'},
      {'id': 'PriceHighToLow', 'label': 'Price: High → Low'},
    ];

    return Wrap(
      spacing: 8, runSpacing: 8,
      children: sortOptions.map((opt) {
        final isSelected = currentSort == opt['id'];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onSortChanged(opt['id']!);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? GomandapTokens.royalNavy : GomandapTokens.softMist,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? Colors.transparent : GomandapTokens.lightSlate,
              ),
            ),
            child: Text(
              opt['label']!,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : GomandapTokens.royalNavy,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
