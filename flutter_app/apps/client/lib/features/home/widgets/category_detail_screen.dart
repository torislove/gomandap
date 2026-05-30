import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/category_model.dart';
import '../home_notifier.dart';
import '../../auth/location_notifier.dart';
import '../../../core/i18n/i18n_notifier.dart';
import '../../../core/i18n/tr_widget.dart';

/// Full-screen rectangular category detail view.
class CategoryDetailScreen extends ConsumerStatefulWidget {
  final String categoryId;
  const CategoryDetailScreen({super.key, required this.categoryId});

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);

    final category = weddingCategoriesList.where((c) => c.id.toString() == widget.categoryId).firstOrNull;
    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Category not found')),
        body: const Center(child: Text('Category not found')),
      );
    }

    final isVenueCategory = category.name.contains('Halls') ||
        category.name.contains('Mandapams') ||
        category.name.contains('Lawns') ||
        category.name == 'Banquet Halls' ||
        category.name == 'Kalyana Mandapams' ||
        category.name == 'Open Lawns';

    final allVendors = [...homeState.trendingVenues, ...homeState.eliteServices];
    final categoryVendors = allVendors.where((v) {
      if (isVenueCategory) return v.category == 'Venue';
      return v.category != 'Venue';
    }).toList();

    final city = locationState is LocationSuccess ? locationState.city : homeState.selectedCity;
    final locality = locationState is LocationSuccess ? locationState.locality : homeState.selectedLocality;

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      body: CustomScrollView(
        slivers: [
          // Large rectangular hero header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: GomandapTokens.royalNavy,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Hero image
                  Image.network(
                    category.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: GomandapTokens.royalNavy,
                      child: Icon(category.fallbackIcon, size: 80, color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.3)),
                    ),
                  ),
                  // Dark overlays for readability
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.3),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  // Content overlay
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: category.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(category.fallbackIcon, color: category.accent, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, size: 12, color: GomandapTokens.champagneGoldStart),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$locality, $city',
                                        style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: GomandapTokens.emeraldGreen.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${categoryVendors.length} vendors',
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: GomandapTokens.emeraldGreen),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(4),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),

          // Body content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sub-services grid (rectangular cards)
                  const Tr(
                    'category.sub_services',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
                  ),
                  const SizedBox(height: 12),
                  ...category.subServices.map((service) => _buildSubServiceCard(service, category.accent)),

                  const SizedBox(height: 24),

                  // Deep filters
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: GomandapTokens.royalNavy.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Tr(
                          'category.available_filters',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: category.deepFilterKeys.map((key) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: GomandapTokens.softMist,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Text(
                                key,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Recommended vendors section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Tr(
                        'category.recommended',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_fire_department_rounded, size: 12, color: GomandapTokens.champagneGoldStart),
                            const SizedBox(width: 4),                              Text(
                                ref.t('category.vendors_count', {'count': '${categoryVendors.length}'}),
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.champagneGoldStart),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Vendor listing
                  ...categoryVendors.map((vendor) => _buildVendorCard(vendor, category.accent, context)),

                  if (categoryVendors.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, size: 48, color: GomandapTokens.slateGray.withValues(alpha: 0.4)),
                            const SizedBox(height: 12),
                            const Tr(
                              'category.no_vendors_yet',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 90), // bottom nav padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubServiceCard(String service, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: GomandapTokens.royalNavy.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.check_circle_outline_rounded, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                ),
                const SizedBox(height: 2),
                Text(
                  'Explore options available',
                  style: const TextStyle(fontSize: 9, color: GomandapTokens.slateGray),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: GomandapTokens.slateGray),
        ],
      ),
    );
  }

  Widget _buildVendorCard(VendorSummary vendor, Color accent, BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        context.push('/vendor/${vendor.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: GomandapTokens.royalNavy.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 100,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        vendor.imageUrls.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: GomandapTokens.softMist,
                          child: const Icon(Icons.broken_image_rounded, color: GomandapTokens.slateGray),
                        ),
                      ),
                      if (vendor.isEscrowProtected)
                        Positioned(
                          top: 8, left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: GomandapTokens.royalNavy.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.shield_rounded, size: 9, color: Color(0xFFDFBA73)),
                                SizedBox(width: 2),
                                Text('ESCROW', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 10, color: GomandapTokens.slateGray),
                              const SizedBox(width: 4),
                              Text(vendor.locality, style: const TextStyle(fontSize: 9, color: GomandapTokens.slateGray, fontWeight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              const Icon(Icons.star_rounded, size: 10, color: Color(0xFFDFBA73)),
                              const SizedBox(width: 2),
                              Text(vendor.rating.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: GomandapTokens.royalNavy,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Tr(
                                  'general.view',
                                  style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 6, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
