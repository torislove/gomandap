import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/category_model.dart';
import '../search_notifier.dart';
import 'deep_filter_sheet.dart';

class OmniFilterBar extends ConsumerWidget {
  const OmniFilterBar({super.key});

  List<String> get categories => [
        'All',
        ...weddingCategoriesList.map((cat) => cat.name),
      ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: GomandapTokens.lightSlate, width: 1),
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: categories.length + 1, // Add 1 for the advanced filter chip
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                // The "Filters ⚡" advanced trigger button
                final activeCount = searchState.activeFiltersCount;
                final hasFilters = activeCount > 0;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black.withValues(alpha: 0.5),
                      builder: (_) => const DeepFilterSheet(),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: hasFilters
                          ? const LinearGradient(
                              colors: [GomandapTokens.champagneGoldStart, GomandapTokens.champagneGoldEnd],
                            )
                          : null,
                      color: hasFilters ? null : GomandapTokens.royalNavy,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: hasFilters ? GomandapTokens.champagneGoldEnd : Colors.transparent,
                        width: 1,
                      ),
                      boxShadow: hasFilters
                          ? [
                              BoxShadow(
                                color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 14,
                          color: hasFilters ? Colors.white : Colors.white.withValues(alpha: 0.9),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasFilters ? 'Filters ($activeCount)' : 'Filters ⚡',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Normal Category Chips
              final category = categories[index - 1];
              final isSelected = searchState.selectedCategory == category;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  notifier.selectCategory(category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? GomandapTokens.emeraldGreen
                        : GomandapTokens.softMist,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : GomandapTokens.lightSlate,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      category == 'All' ? 'All Services' : category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? Colors.white : GomandapTokens.royalNavy,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

