import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/category_model.dart';
import 'package:go_router/go_router.dart';
import '../home_notifier.dart';
import '../../auth/location_notifier.dart';
import '../../../core/i18n/i18n_notifier.dart';
import 'category_detail_panel.dart';

typedef CategoryItem = CategoryDetails;

class CategorySuperGrid extends ConsumerWidget {
  final void Function(CategoryItem category) onCategoryTap;

  const CategorySuperGrid({super.key, required this.onCategoryTap});

  List<List<CategoryItem>> _chunkList(List<CategoryItem> list, int chunkSize) {
    List<List<CategoryItem>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  Widget _buildRowSection({
    required List<CategoryItem> categories,
    required int columns,
    required String? activeCategoryId,
    required void Function(CategoryItem) onCategoryTap,
  }) {
    final chunks = _chunkList(categories, columns);

    return Column(
      children: chunks.map((chunk) {
        // Find if active category is in this row chunk
        final activeInRow = chunk.where((cat) => cat.id.toString() == activeCategoryId).firstOrNull;

        return Column(
          children: [
            Row(
              children: List.generate(columns, (colIndex) {
                if (colIndex < chunk.length) {
                  final cat = chunk[colIndex];
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      child: AspectRatio(
                        aspectRatio: 1.15,
                        child: _CategoryGridItem(
                          category: cat,
                          onTap: () => onCategoryTap(cat),
                        ),
                      ),
                    ),
                  );
                } else {
                  return const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      child: SizedBox(),
                    ),
                  );
                }
              }),
            ),
            if (activeInRow != null)
              CategoryDetailPanel(categoryId: activeInRow.id.toString()),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final activeCategoryId = homeState.activeCategoryId;

    // Separate Venues from Other Categories
    final venueCategories = weddingCategoriesList
        .where((cat) => cat.name == 'Banquet Halls' ||
                        cat.name == 'Kalyana Mandapams' ||
                        cat.name == 'Open Lawns')
        .toList();

    final otherCategories = weddingCategoriesList
        .where((cat) => cat.name != 'Banquet Halls' &&
                        cat.name != 'Kalyana Mandapams' &&
                        cat.name != 'Open Lawns')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Venues & Mandapams Section
        _buildSectionHeader(ref.t('home.venue_types'), ref.t('home.venue_types_sub')),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _buildRowSection(
            categories: venueCategories,
            columns: 3,
            activeCategoryId: activeCategoryId,
            onCategoryTap: onCategoryTap,
          ),
        ),

        // 2. GoMandap Trust Shelf (Explain core pillars in minimal space)
        const SizedBox(height: 8),
        const _GomandapTrustShelf(),
        const SizedBox(height: 4),

        // 3. Other Categories Section
        _buildSectionHeader(ref.t('home.other_services'), ref.t('home.other_services_sub')),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _buildRowSection(
            categories: otherCategories,
            columns: 4,
            activeCategoryId: activeCategoryId,
            onCategoryTap: onCategoryTap,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFBA73), // Gold vertical bar indicator
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.royalNavy,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 9),
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: GomandapTokens.slateGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GomandapTrustShelf extends StatelessWidget {
  const _GomandapTrustShelf();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: GomandapTokens.royalNavy.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pill 1: Milestone Escrow
            Expanded(
              child: Consumer(
                builder: (context, r, _) => _buildTrustPill(
                  icon: Icons.shield_outlined,
                  title: r.t('category.milestone_escrow'),
                  desc: r.t('category.milestone_desc'),
                  accent: const Color(0xFFDFBA73),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 28,
              color: GomandapTokens.royalNavy.withValues(alpha: 0.08),
              margin: const EdgeInsets.symmetric(horizontal: 6),
            ),
            // Pill 2: Verified Partners
            Expanded(
              child: Consumer(
                builder: (context, r, _) => _buildTrustPill(
                  icon: Icons.verified_user_outlined,
                  title: r.t('category.verified_partners'),
                  desc: r.t('category.verified_desc'),
                  accent: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustPill({
    required IconData icon,
    required String title,
    required String desc,
    required Color accent,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 14),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: GomandapTokens.royalNavy,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 8,
                  color: GomandapTokens.slateGray,
                  fontWeight: FontWeight.w500,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryGridItem extends StatefulWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const _CategoryGridItem({required this.category, required this.onTap});

  @override
  State<_CategoryGridItem> createState() => _CategoryGridItemState();
}

class _CategoryGridItemState extends State<_CategoryGridItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: GomandapTokens.royalNavy.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
              // Gold-leaf outlines glow effect
              BoxShadow(
                color: const Color(0xFFDFBA73).withValues(alpha: 0.08),
                blurRadius: 15,
                spreadRadius: -1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Category Cover Photo
                Image.network(
                  widget.category.imageUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Vignette gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
                // 3D Glassmorphic Floating Title Plate
                Positioned(
                  bottom: 5,
                  left: 5,
                  right: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.category.name,
                          style: const TextStyle(
                            fontSize: 9.0,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ─── Intelligent Category Bottom Sheet ────────────────────────────────────────

void showCategorySheet(BuildContext context, CategoryItem category) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryBottomSheet(category: category),
  );
}

class _CategoryBottomSheet extends ConsumerWidget {
  final CategoryItem category;
  const _CategoryBottomSheet({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);

    // Combine trending venues and elite services to find matching listings
    final List<VendorSummary> allVendors = [
      ...homeState.trendingVenues,
      ...homeState.eliteServices,
    ];

    // Filter by type: Venues vs Other services
    final isVenueCategory = category.name.contains('Halls') ||
                            category.name.contains('Mandapams') ||
                            category.name.contains('Lawns') ||
                            category.name == 'Banquet Halls' ||
                            category.name == 'Kalyana Mandapams' ||
                            category.name == 'Open Lawns';

    final categoryVendors = allVendors.where((v) {
      if (isVenueCategory) {
        return v.category == 'Venue';
      }
      return v.category != 'Venue';
    }).toList();

    // Sort: prioritizes vendors matching the active selected locality or geofence
    final detectedLocality = locationState is LocationSuccess
        ? locationState.locality
        : homeState.selectedLocality;
    final activeLocality = homeState.selectedLocality;
    categoryVendors.sort((a, b) {
      final aMatch = a.locality.toLowerCase().contains(activeLocality.toLowerCase()) ||
                     a.locality.toLowerCase().contains(detectedLocality.toLowerCase());
      final bMatch = b.locality.toLowerCase().contains(activeLocality.toLowerCase()) ||
                     b.locality.toLowerCase().contains(detectedLocality.toLowerCase());
      if (aMatch && !bMatch) return -1;
      if (!aMatch && bMatch) return 1;
      return 0;
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: GomandapTokens.pearlWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              height: 4, width: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: category.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.fallbackIcon, color: category.accent, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                        Text('Bookings active in ${homeState.selectedLocality}, ${homeState.selectedCity}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: GomandapTokens.slateGray),
                  ),
                ],
              ),
            ),
            const Divider(height: 20),
            // Quick filter chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: ['category.all_nearby', 'category.highest_rated', 'category.budget_package', 'category.escrow_releases', 'category.verified']
                    .map((label) => Consumer(
                        builder: (context, r, _) => _FilterChipPill(
                          label: r.t(label),
                          isActive: label == 'All Nearby',
                        ),
                      ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Active results scroll list
            Expanded(
              child: categoryVendors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.near_me_disabled_rounded, size: 48, color: GomandapTokens.slateGray.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Consumer(
                            builder: (context, r, _) => Text(
                              r.t('category.no_listing'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Consumer(
                            builder: (context, r, _) => Text(
                              r.t('category.try_other_locality'),
                              style: TextStyle(fontSize: 11, color: GomandapTokens.slateGray.withValues(alpha: 0.7)),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: controller,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: categoryVendors.length,
                      itemBuilder: (_, index) {
                        final vendor = categoryVendors[index];
                        return _CategoryVendorCard(
                          vendor: vendor,
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                            context.push('/vendor/${vendor.id}');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryVendorCard extends StatelessWidget {
  final VendorSummary vendor;
  final VoidCallback onTap;

  const _CategoryVendorCard({required this.vendor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              // 1. Cover image with glass badge overlays
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
                      // Small glass escrow badge
                      if (vendor.isEscrowProtected)
                        Positioned(
                          top: 8,
                          left: 8,
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
                                Text(
                                  'ESCROW',
                                  style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 2. Info details
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Locality text
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: GomandapTokens.emeraldGreen.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.15)),
                                ),
                                child: Text(
                                  vendor.locality,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: GomandapTokens.emeraldGreen,
                                  ),
                                ),
                              ),
                              // Rating
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFDFBA73)),
                                  const SizedBox(width: 2),
                                  Text(
                                    vendor.rating.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: GomandapTokens.royalNavy,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            vendor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: GomandapTokens.royalNavy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildPolymorphicFooter(context),
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

  Widget _buildPolymorphicFooter(BuildContext context) {
    final cat = vendor.category.toLowerCase();
    final bool isVenue = cat.contains('hall') || cat.contains('mandapam') || cat.contains('lawn') || cat == 'venue';
    final bool isPhoto = cat.contains('photo') || cat.contains('camera');
    final bool isMakeup = cat.contains('makeup') || cat.contains('brush');
    final bool isCatering = cat.contains('cater');
    final bool isDecor = cat.contains('decor') || cat.contains('canopy');

    Widget row1;
    Widget row2;

    if (isVenue) {
      final veg = vendor.specs.vegPlatePrice ?? vendor.basePlatePrice;
      final nonVeg = vendor.specs.nonVegPlatePrice ?? (vendor.basePlatePrice * 1.25);
      final cap = vendor.specs.guestCapacity ?? 600;
      final rooms = vendor.specs.roomsAvailable ?? 12;

      row1 = Row(
        children: [
          _buildBullet(Colors.green),
          const SizedBox(width: 4),
          Text('Veg: ₹${veg.toInt()}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(width: 10),
          _buildBullet(Colors.red),
          const SizedBox(width: 4),
          Text('Non-Veg: ₹${nonVeg.toInt()}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        ],
      );

      row2 = Row(
        children: [
          const Icon(Icons.people_alt_outlined, size: 12, color: GomandapTokens.slateGray),
          const SizedBox(width: 4),
          Text('$cap Pax', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
          const SizedBox(width: 14),
          const Icon(Icons.meeting_room_outlined, size: 12, color: GomandapTokens.slateGray),
          const SizedBox(width: 4),
          Text('$rooms Rooms AC', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
        ],
      );
    } else if (isPhoto) {
      final photo = vendor.specs.candidDayRate ?? vendor.basePlatePrice;
      final video = vendor.specs.videoDayRate ?? vendor.packagePrice;
      final days = vendor.specs.deliveryTimelineDays ?? 45;
      final brand = vendor.specs.equipmentBrand ?? 'Sony/Canon';

      row1 = Row(
        children: [
          const Icon(Icons.camera_alt_outlined, size: 12, color: GomandapTokens.royalNavy),
          const SizedBox(width: 4),
          Text('Photo: ₹${photo.toInt()}/day', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(width: 10),
          const Icon(Icons.videocam_outlined, size: 12, color: GomandapTokens.royalNavy),
          const SizedBox(width: 4),
          Text('Video: ₹${video.toInt()}/day', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        ],
      );

      row2 = Row(
        children: [
          const Icon(Icons.timer_outlined, size: 12, color: GomandapTokens.slateGray),
          const SizedBox(width: 4),
          Text('⏱ Deliver: $days Days', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
          const SizedBox(width: 14),
          const Icon(Icons.bolt_outlined, size: 12, color: GomandapTokens.slateGray),
          const SizedBox(width: 4),
          Text(brand, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
        ],
      );
    } else if (isCatering) {
      final veg = vendor.specs.cateringVegPrice ?? vendor.basePlatePrice;
      final nonVeg = vendor.specs.cateringNonVegPrice ?? (vendor.basePlatePrice * 1.3);
      final minPlates = vendor.specs.minPlatesBooking ?? 150;

      row1 = Row(
        children: [
          _buildBullet(Colors.green),
          const SizedBox(width: 4),
          Text('Veg: ₹${veg.toInt()}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(width: 10),
          _buildBullet(Colors.red),
          const SizedBox(width: 4),
          Text('Non-Veg: ₹${nonVeg.toInt()}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        ],
      );

      row2 = Row(
        children: [
          const Icon(Icons.restaurant_outlined, size: 12, color: GomandapTokens.slateGray),
          const SizedBox(width: 4),
          Text('Min Booking: $minPlates plates', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
        ],
      );
    } else if (isMakeup) {
      final bridal = vendor.specs.bridalMakeupPrice ?? vendor.basePlatePrice;
      final family = vendor.specs.familyMakeupPrice ?? 4000;
      final brand = vendor.specs.makeupBrandTier ?? 'MAC / Huda';
      final trial = (vendor.specs.trialSessionAvailable ?? true) ? 'Trial Session Available' : 'No Trials';

      row1 = Row(
        children: [
          const Icon(Icons.brush_outlined, size: 12, color: GomandapTokens.royalNavy),
          const SizedBox(width: 4),
          Text('Bridal: ₹${bridal.toInt()}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(width: 10),
          const Icon(Icons.people_outlined, size: 12, color: GomandapTokens.royalNavy),
          const SizedBox(width: 4),
          Text('Family: ₹${family.toInt()}/pax', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        ],
      );

      row2 = Row(
        children: [
          const Icon(Icons.spa_outlined, size: 12, color: GomandapTokens.slateGray),
          const SizedBox(width: 4),
          Text(brand, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
          const SizedBox(width: 12),
          const Icon(Icons.check_circle_outline_rounded, size: 11, color: GomandapTokens.emeraldGreen),
          const SizedBox(width: 3),
          Text(trial, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.emeraldGreen)),
        ],
      );
    } else if (isDecor) {
      final indoor = vendor.specs.indoorDecorPrice ?? vendor.basePlatePrice;
      final outdoor = vendor.specs.outdoorStagePrice ?? vendor.packagePrice;
      final setup = vendor.specs.setupHours ?? 8;
      final flora = vendor.specs.floralGrade ?? 'Fresh Flowers';

      row1 = Row(
        children: [
          const Icon(Icons.home_outlined, size: 12, color: GomandapTokens.royalNavy),
          const SizedBox(width: 4),
          Text('Indoor: ₹${indoor.toInt()}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          const SizedBox(width: 10),
          const Icon(Icons.park_outlined, size: 12, color: GomandapTokens.royalNavy),
          const SizedBox(width: 4),
          Text('Outdoor: ₹${outdoor.toInt()}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        ],
      );

      row2 = Row(
        children: [
          const Icon(Icons.timer_outlined, size: 12, color: GomandapTokens.slateGray),
          const SizedBox(width: 4),
          Text('⏱ Setup: $setup Hrs', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
          const SizedBox(width: 12),
          const Icon(Icons.local_florist_outlined, size: 12, color: GomandapTokens.slateGray),
          const SizedBox(width: 4),
          Text(flora, style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
        ],
      );
    } else {
      row1 = Row(
        children: [
          const Icon(Icons.celebration_outlined, size: 12, color: GomandapTokens.royalNavy),
          const SizedBox(width: 4),
          Text('Starting: ₹${vendor.packagePrice.toInt()}/event', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
        ],
      );

      row2 = Row(
        children: [
          const Icon(Icons.gavel_outlined, size: 12, color: GomandapTokens.slateGray),
          const SizedBox(width: 4),
          Text('Cancellation policy applies', style: GoogleFonts.inter(fontSize: 9.5, fontWeight: FontWeight.w600, color: GomandapTokens.slateGray)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: GomandapTokens.softMist,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                row1,
                const SizedBox(height: 6),
                row2,
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: GomandapTokens.royalNavy,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: GomandapTokens.royalNavy.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(
                  'Book',
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(Icons.arrow_forward_ios_rounded, size: 7, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String label;
  final bool isActive;
  const _FilterChipPill({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? GomandapTokens.royalNavy : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? GomandapTokens.royalNavy : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : GomandapTokens.slateGray,
        ),
      ),
    );
  }
}

