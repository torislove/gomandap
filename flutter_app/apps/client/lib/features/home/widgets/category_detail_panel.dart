import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/category_model.dart';
import 'package:go_router/go_router.dart';
import '../home_notifier.dart';
import '../../auth/location_notifier.dart';
import '../../../core/i18n/tr_widget.dart';

/// Panel showing selected category details — dynamically reveals inline below the matching grid row chunk.
class CategoryDetailPanel extends ConsumerStatefulWidget {
  final String categoryId;

  const CategoryDetailPanel({
    super.key,
    required this.categoryId,
  });

  @override
  ConsumerState<CategoryDetailPanel> createState() => _CategoryDetailPanelState();
}

class _CategoryDetailPanelState extends ConsumerState<CategoryDetailPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.fastOutSlowIn,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(covariant CategoryDetailPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId) {
      // Re-trigger the slide-down reveal if switching between active category items
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);

    // Find the matching category from the master list
    final category = weddingCategoriesList
        .where((c) => c.id.toString() == widget.categoryId)
        .firstOrNull;
    if (category == null) return const SizedBox.shrink();

    final isVenueCategory = category.name.contains('Halls') ||
        category.name.contains('Mandapams') ||
        category.name.contains('Lawns') ||
        category.name == 'Banquet Halls' ||
        category.name == 'Kalyana Mandapams' ||
        category.name == 'Open Lawns';

    // Count matching vendors
    final allVendors = [...homeState.trendingVenues, ...homeState.eliteServices];
    final vendorCount = allVendors.where((v) {
      if (isVenueCategory) return v.category == 'Venue';
      return v.category != 'Venue';
    }).length;

    final city = locationState is LocationSuccess ? locationState.city : homeState.selectedCity;
    final locality = locationState is LocationSuccess ? locationState.locality : homeState.selectedLocality;

    return SizeTransition(
      sizeFactor: _expandAnimation,
      alignment: Alignment.centerLeft,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: Container(
          margin: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                GomandapTokens.royalNavy,
                Color(0xFF1E293B),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: GomandapTokens.royalNavy.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: category.accent.withValues(alpha: 0.06),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: category.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(category.fallbackIcon, color: category.accent, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 10, color: GomandapTokens.champagneGoldStart),
                                const SizedBox(width: 4),
                                Text(
                                  '$locality, $city',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: GomandapTokens.emeraldGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Tr(
                                    'category.vendors_count',
                                    placeholders: {'count': '$vendorCount'},
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: GomandapTokens.emeraldGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // "View Full" button → navigates to full screen
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref.read(homeNotifierProvider.notifier).setActiveCategory(null);
                          context.push('/category/${category.id}');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: const Row(
                            children: [
                              Tr('category.view_full',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded, size: 8, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Sub-services chips
                  SizedBox(
                    height: 28,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: category.subServices.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 6),
                      itemBuilder: (_, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                          ),
                          child: Text(
                            category.subServices[index],
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Deep filter keys
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: category.deepFilterKeys.take(3).map((key) => Text(
                      key,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded, size: 10, color: GomandapTokens.champagneGoldStart),
                        const SizedBox(width: 4),
                        Tr(
                          'category.booked_count',
                          placeholders: {'count': '$vendorCount'},
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: GomandapTokens.champagneGoldStart,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
