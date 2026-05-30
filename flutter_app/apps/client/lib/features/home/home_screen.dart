import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'home_notifier.dart';
import 'widgets/advanced_vendor_card.dart';
import 'widgets/hero_carousel.dart';
import 'widgets/category_grid.dart';
import 'widgets/sponsorship_ad_card.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_footer.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import '../auth/location_notifier.dart';
import '../../core/i18n/i18n_notifier.dart';
import '../../core/i18n/tr_widget.dart';
import '../search/widgets/address_autocomplete_overlay.dart';
import '../planning/planning_board_screen.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeNotifierProvider);
    final bannersAsyncValue = ref.watch(heroCarouselsFutureProvider);

    // Sync detected location from onboarding into home state
    ref.listen(locationNotifierProvider, (previous, next) {
      if (next is LocationSuccess) {
        ref.read(homeNotifierProvider.notifier).setLocation(next.city, next.locality);
      }
    });

    return GomandapScreen(
      backgroundColor: GomandapTokens.pearlWhite,
      useHorizontalPadding: false,
      useSafeAreaTop: false,
      useSafeAreaBottom: false,
      body: RefreshIndicator(
        color: GomandapTokens.emeraldGreen,
        onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ── Persistent Top Bar + Sticky Search Bar ─────────────────
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: true,
              expandedHeight: 0,
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 2,
              surfaceTintColor: Colors.white,
              title: Row(
                children: [
                  const Icon(Icons.celebration_rounded, color: GomandapTokens.champagneGoldStart, size: 24),
                  const SizedBox(width: 8),
                  Text('GoMandap',
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                  const SizedBox(width: 4),
                  // Redesigned Location Pill
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showLocationSelector(context, ref),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: GomandapTokens.softMist,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 13, color: GomandapTokens.emeraldGreen),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${homeState.selectedLocality}, ${homeState.selectedCity}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: GomandapTokens.royalNavy,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: GomandapTokens.slateGray),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                // Cart badge
                GestureDetector(
                  onTap: () => context.push('/cart'),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, color: GomandapTokens.royalNavy, size: 26),
                        Positioned(
                          top: -4, right: -4,
                          child: Container(
                            width: 16, height: 16,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE11D48),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('2', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => context.push('/profile'),
                  child: const CircleAvatar(
                    radius: 16,
                    backgroundColor: GomandapTokens.softMist,
                    child: Icon(Icons.person_rounded, size: 18, color: GomandapTokens.royalNavy),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _GlassmorphicSearchBar(
                    onTap: () => context.push('/search'),
                  ),
                ),
              ),
            ),

            // ── Scrollable Body ────────────────────────────────────────
            SliverList(
              delegate: SliverChildListDelegate([
                CustomPaint(
                  size: const Size(double.infinity, 16),
                  painter: MarigoldGarlandPainter(),
                ),
                const SizedBox(height: 16),
                
                // Planning Board Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const PlanningBoardScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [GomandapTokens.royalNavy, Color(0xFF1E3A5F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: GomandapTokens.cardShadow,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Collaborative Planning', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                                const SizedBox(height: 4),
                                Text('Invite your family & plan together.', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.groups_rounded, color: GomandapTokens.champagneGoldEnd, size: 24),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Hero Carousel
                bannersAsyncValue.when(
                  data: (banners) => HeroCarousel(
                    items: banners.map((b) => HeroBannerItem(
                      title: b['title'] ?? '',
                      subtitle: b['subtitle'] ?? '',
                      imageUrl: b['image_url'] ?? '',
                      badge: '🏆 DYNAMIC',
                    )).toList(),
                  ),
                  loading: () => const SizedBox(height: 200),
                  error: (_, __) => const SizedBox(height: 200),
                ),

                const SizedBox(height: 16),

                // 5. Category Grid Header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Tr('home.browse_categories',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                ),
                const SizedBox(height: 16),

                CategorySuperGrid(
                  onCategoryTap: (cat) {
                    HapticFeedback.selectionClick();
                    final catId = cat.id.toString();
                    if (homeState.activeCategoryId == catId) {
                      // Deselect if already selected
                      ref.read(homeNotifierProvider.notifier).setActiveCategory(null);
                    } else {
                      // Select category — shows detail panel
                      ref.read(homeNotifierProvider.notifier).setActiveCategory(catId);
                    }
                  },
                ),

                const SizedBox(height: 16),

                // 6. Trending Venues Shelf
                _SectionHeader(title: ref.t('home.trending_venues'), showViewAll: true),
                const SizedBox(height: 8),
                _VendorScrollShelf(
                  vendors: homeState.trendingVenues,
                  isLoading: homeState.isLoading,
                  onVendorTap: (v) => context.push('/vendor/${v.id}'),
                  sponsoredEvery: 4,
                ),

                const SizedBox(height: 8),                  // 7. Mid-page Sponsorship Ad Card
                const SponsorshipAdCard(),

                const SizedBox(height: 16),

                // 8. Elite Services Shelf
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Tr('home.elite_services',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
                ),
                const SizedBox(height: 8),
                _VendorScrollShelf(
                  vendors: homeState.eliteServices,
                  isLoading: homeState.isLoading,
                  onVendorTap: (v) => context.push('/vendor/${v.id}'),
                  sponsoredEvery: 0,
                ),

                const SizedBox(height: 16),

                // 9. Cities Marquee (decorative auto-scroll strip)
                const _CityMarqueeStrip(),

                const SizedBox(height: 20),

                const SizedBox(height: 8),

                // Premium Shared Footer
                GomandapFooter(
                  onNavigate: (context, route) {
                    if (route == '/become-vendor') {
                      context.push(route);
                    } else {
                      context.go(route);
                    }
                  },
                ),

                // Bottom padding for nav bar
                const SizedBox(height: 90),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationSelector(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const LocationSelectorSheet(),
    );
  }
}

// ─── Location Picker Sheet ────────────────────────────────────────────────────

class LocationSelectorSheet extends ConsumerStatefulWidget {
  const LocationSelectorSheet({super.key});

  @override
  ConsumerState<LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends ConsumerState<LocationSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    final cities = ['Hyderabad', 'Chennai', 'Bengaluru', 'Mumbai', 'Delhi', 'Pune', 'Kochi', 'Coimbatore'];
    final detectedLocality = locationState is LocationSuccess ? locationState.locality : homeState.selectedLocality;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ref.t('home.select_location'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: GomandapTokens.softMist,
                    child: Icon(Icons.close_rounded, size: 16, color: GomandapTokens.slateGray),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 1. Auto-location radar trigger container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GomandapTokens.emeraldGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location_rounded, color: GomandapTokens.emeraldGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.t('home.auto_detect'),
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                        ),
                        Text(
                          locationState is LocationSuccess
                              ? ref.t('home.geofence', {'locality': detectedLocality})
                              : ref.t('home.scan_gps'),
                          style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.mediumImpact();
                      final locNotifier = ref.read(locationNotifierProvider.notifier);
                      await locNotifier.detectCurrentLocation();
                      if (context.mounted) {
                        final freshState = ref.read(locationNotifierProvider);
                        if (freshState is LocationSuccess) {
                          ref.read(homeNotifierProvider.notifier).setLocation(freshState.city, freshState.locality);
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GomandapTokens.emeraldGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(ref.t('home.detect'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Custom Locality Input search
            Text(
              ref.t('home.search_locality'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GomandapTokens.slateGray),
            ),
            const SizedBox(height: 8),
            AddressAutocompleteOverlay(
              hintText: ref.t('home.search_locality_hint'),
              onLocationSelected: (coords) {
                ref.read(homeNotifierProvider.notifier).setLocation(coords.city, coords.locality);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),

            // 3. Quick metropolitan hubs
            Text(
              ref.t('home.metropolitan_hubs'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GomandapTokens.slateGray),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cities.map((city) {
                final isSelected = homeState.selectedCity == city;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(homeNotifierProvider.notifier).setLocation(city, 'Central Hub');
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? GomandapTokens.royalNavy : GomandapTokens.softMist,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? GomandapTokens.royalNavy : GomandapTokens.lightSlate,
                      ),
                    ),
                    child: Text(
                      city,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : GomandapTokens.royalNavy,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Glassmorphic Search Bar ──────────────────────────────────────────────────

class _GlassmorphicSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _GlassmorphicSearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: GomandapTokens.royalNavy.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.search_rounded, color: GomandapTokens.slateGray, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, _) {
                      final hint = ref.watch(i18nProvider).t('home.search_hint');
                      return Text(
                        hint,
                        style: TextStyle(color: GomandapTokens.slateGray.withValues(alpha: 0.8), fontSize: 14),
                      );
                    },
                  ),
                ),
            Container(width: 1, height: 24, color: GomandapTokens.lightSlate),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: GomandapTokens.emeraldGreen),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Consumer(
                      builder: (context, r, _) => Text(
                        r.watch(i18nProvider).t('home.dates_filter'),
                        style: const TextStyle(color: GomandapTokens.emeraldGreen, fontWeight: FontWeight.w700, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showViewAll;

  const _SectionHeader({required this.title, this.showViewAll = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
          if (showViewAll)
            GestureDetector(
              onTap: () => context.push('/search'),
              child: Consumer(
                builder: (context, r, _) => Text(
                  r.watch(i18nProvider).t('home.view_all'),
                  style: const TextStyle(color: GomandapTokens.emeraldGreen, fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Vendor Scroll Shelf ──────────────────────────────────────────────────────

class _VendorScrollShelf extends StatelessWidget {
  final List<VendorSummary> vendors;
  final bool isLoading;
  final void Function(VendorSummary) onVendorTap;
  final int sponsoredEvery;

  const _VendorScrollShelf({
    required this.vendors,
    required this.isLoading,
    required this.onVendorTap,
    this.sponsoredEvery = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 245,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (_, __) => _SkeletonCard(),
        ),
      );
    }

    if (vendors.isEmpty) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: Tr('home.no_vendors',
            style: TextStyle(color: GomandapTokens.slateGray)),
        ),
      );
    }

    return SizedBox(
      height: 245,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: vendors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, index) {
          final isSponsored = sponsoredEvery > 0 && (index + 1) % sponsoredEvery == 0;
          return AdvancedVendorCard(
            vendor: vendors[index],
            isSponsored: isSponsored,
            onTap: () => onVendorTap(vendors[index]),
            onBookNow: () => onVendorTap(vendors[index]),
          );
        },
      ),
    );
  }
}

// ─── City Marquee Strip (decorative auto-scroll, does nothing) ──────────────

class _CityMarqueeStrip extends StatefulWidget {
  const _CityMarqueeStrip();

  @override
  State<_CityMarqueeStrip> createState() => _CityMarqueeStripState();
}

class _CityMarqueeStripState extends State<_CityMarqueeStrip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  final List<String> _cities = [
    'Hyderabad', 'Bengaluru', 'Chennai', 'Mumbai', 'Delhi',
    'Pune', 'Kochi', 'Coimbatore', 'Kolkata', 'Jaipur',
    'Ahmedabad', 'Lucknow', 'Chandigarh', 'Goa', 'Vizag',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
    _animation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: const Offset(-1.0, 0),
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: GomandapTokens.royalNavy,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return ClipRect(
            child: Stack(
              children: [
                Positioned(
                  left: _animation.value.dx * MediaQuery.of(context).size.width,
                  top: 0,
                  bottom: 0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_cities.length * 2, (i) {
                      final city = _cities[i % _cities.length];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_rounded,
                              size: 11, color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.7)),
                            const SizedBox(width: 4),
                            Text(
                              city,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) {
        final shimmerColor = Color.lerp(
          const Color(0xFFE2E8F0),
          const Color(0xFFF1F5F9),
          _shimmerController.value,
        )!;
        return Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(height: 100, decoration: BoxDecoration(color: shimmerColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(16)))),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: 140, color: shimmerColor, margin: const EdgeInsets.only(bottom: 6)),
                    Container(height: 8, width: 80, color: shimmerColor, margin: const EdgeInsets.only(bottom: 12)),
                    Container(height: 30, decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(8))),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



