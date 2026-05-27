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
import 'widgets/city_parallax_row.dart';
import 'widgets/sponsorship_ad_card.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_footer.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import '../onboarding/onboarding_notifier.dart';
import '../onboarding/client_onboarding_wizard.dart';


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

    ref.listen(onboardingNotifierProvider, (previous, next) {
      if (next.isLocationSuccess &&
          (previous == null || !previous.isLocationSuccess || previous.detectedLocality != next.detectedLocality)) {
        ref.read(homeNotifierProvider.notifier).setLocation(next.detectedCity, next.detectedLocality);
      }
    });

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
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
                const SizedBox(height: 8),

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
                  loading: () => HeroCarousel(items: defaultHeroBanners),
                  error: (_, __) => HeroCarousel(items: defaultHeroBanners),
                ),

                const SizedBox(height: 16),

                // 2. Category Grid Header
                const _SectionHeader(title: 'Browse Categories', showViewAll: false),
                const SizedBox(height: 8),
                CategorySuperGrid(
                  onCategoryTap: (cat) => showCategorySheet(context, cat),
                ),

                const SizedBox(height: 16),

                // 3. Trending Venues Shelf
                const _SectionHeader(title: 'Trending Venues Near You'),
                const SizedBox(height: 8),
                _VendorScrollShelf(
                  vendors: homeState.trendingVenues,
                  isLoading: homeState.isLoading,
                  onVendorTap: (v) => context.push('/vendor/${v.id}'),
                  sponsoredEvery: 4,
                ),

                const SizedBox(height: 8),

                // 4. Mid-page Sponsorship Ad Card
                const SponsorshipAdCard(),

                const SizedBox(height: 16),

                // 5. Elite Services Shelf
                const _SectionHeader(title: 'Elite Services'),
                const SizedBox(height: 8),
                _VendorScrollShelf(
                  vendors: homeState.eliteServices,
                  isLoading: homeState.isLoading,
                  onVendorTap: (v) => context.push('/vendor/${v.id}'),
                  sponsoredEvery: 0,
                ),

                const SizedBox(height: 16),

                // 6. Cities Row
                const _SectionHeader(title: 'Explore by City'),
                const SizedBox(height: 8),
                const CityParallaxRow(),

                const SizedBox(height: 20),

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
    final onboardingState = ref.watch(onboardingNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    final cities = ['Hyderabad', 'Chennai', 'Bengaluru', 'Mumbai', 'Delhi', 'Pune', 'Kochi', 'Coimbatore'];

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
                const Text(
                  'Select Booking Location',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
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

            // 1. Auto-location radar trigger container (Frosted Card)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  if (onboardingState.isLocationSearching) ...[
                    const SizedBox(
                      height: 120,
                      child: Center(
                        child: LocationRadarPulse(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const LocationSearchLoader(),
                  ] else ...[
                    Row(
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
                              const Text(
                                'Auto-Detect Current Location',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
                              ),
                              Text(
                                onboardingState.isLocationSuccess
                                    ? 'Current geofence: ${onboardingState.detectedLocality}'
                                    : 'Scan coordinates via GPS satellites',
                                style: const TextStyle(fontSize: 11, color: GomandapTokens.slateGray),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            final onboardingNotifier = ref.read(onboardingNotifierProvider.notifier);
                            await onboardingNotifier.detectCurrentLocation();
                            final freshOnboardingState = ref.read(onboardingNotifierProvider);
                            if (freshOnboardingState.isLocationSuccess) {
                              ref.read(homeNotifierProvider.notifier).setLocation(
                                freshOnboardingState.detectedCity,
                                freshOnboardingState.detectedLocality,
                              );
                              if (context.mounted) {
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
                          child: const Text('Detect', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Custom Locality Input search (with gold active outline)
            const Text(
              'Or search manual Locality',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GomandapTokens.slateGray),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  HapticFeedback.selectionClick();
                  ref.read(homeNotifierProvider.notifier).setLocation(homeState.selectedCity, value.trim());
                  Navigator.pop(context);
                }
              },
              decoration: InputDecoration(
                hintText: 'Enter locality (e.g. Madhapur, Indiranagar)',
                hintStyle: const TextStyle(fontSize: 13, color: GomandapTokens.slateGray),
                prefixIcon: const Icon(Icons.search_rounded, color: GomandapTokens.slateGray, size: 18),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_circle_right_rounded, color: Color(0xFFDFBA73)),
                  onPressed: () {
                    final value = _searchController.text.trim();
                    if (value.isNotEmpty) {
                      HapticFeedback.selectionClick();
                      ref.read(homeNotifierProvider.notifier).setLocation(homeState.selectedCity, value);
                      Navigator.pop(context);
                    }
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: GomandapTokens.softMist,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: GomandapTokens.lightSlate),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Color(0xFFDFBA73), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Quick metropolitan hubs
            const Text(
              'Metropolitan Booking Hubs',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: GomandapTokens.slateGray),
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
                  child: Text(
                    'Search Banquets, Resorts...',
                    style: TextStyle(color: GomandapTokens.slateGray.withValues(alpha: 0.8), fontSize: 14),
                  ),
                ),
                Container(width: 1, height: 24, color: GomandapTokens.lightSlate),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: GomandapTokens.emeraldGreen),
                      SizedBox(width: 4),
                      Text('Dates',
                        style: TextStyle(color: GomandapTokens.emeraldGreen, fontWeight: FontWeight.w700, fontSize: 12)),
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

// ─── Section Header ───────────────────────────────────────────────────────────

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
              child: const Text('View All',
                style: TextStyle(color: GomandapTokens.emeraldGreen, fontWeight: FontWeight.w700, fontSize: 13)),
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
        child: Center(child: Text('No vendors available', style: TextStyle(color: GomandapTokens.slateGray))),
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



