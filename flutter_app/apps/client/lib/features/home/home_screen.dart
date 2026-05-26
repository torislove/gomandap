import 'dart:ui';
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
                  const Text('GoMandap',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: GomandapTokens.royalNavy)),
                  const SizedBox(width: 8),
                  // City pill
                  GestureDetector(
                    onTap: () => _showCitySelector(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GomandapTokens.softMist,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: GomandapTokens.lightSlate),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 12, color: GomandapTokens.emeraldGreen),
                          const SizedBox(width: 3),
                          Text(homeState.selectedCity,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy)),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: GomandapTokens.slateGray),
                        ],
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
                const GomandapFooter(),

                // Bottom padding for nav bar
                const SizedBox(height: 90),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  void _showCitySelector(BuildContext context, WidgetRef ref) {
    final cities = ['Hyderabad', 'Chennai', 'Bengaluru', 'Mumbai', 'Delhi', 'Pune', 'Kochi', 'Coimbatore'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select City', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: cities.map((city) => GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(homeNotifierProvider.notifier).setCity(city);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: GomandapTokens.softMist,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: GomandapTokens.lightSlate),
                  ),
                  child: Text(city, style: const TextStyle(fontWeight: FontWeight.w600, color: GomandapTokens.royalNavy)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
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
        height: 300,
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
      height: 300,
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
          width: 240,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Container(height: 140, decoration: BoxDecoration(color: shimmerColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(16)))),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 180, color: shimmerColor, margin: const EdgeInsets.only(bottom: 8)),
                    Container(height: 10, width: 100, color: shimmerColor, margin: const EdgeInsets.only(bottom: 16)),
                    Container(height: 40, decoration: BoxDecoration(color: shimmerColor, borderRadius: BorderRadius.circular(8))),
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



