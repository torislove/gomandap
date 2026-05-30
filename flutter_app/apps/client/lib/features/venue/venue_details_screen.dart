import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:gomandap_common/domain/models/vendor_inventory.dart';
import 'package:gomandap_common/data/repository_impl/vendor_inventory_repository.dart';
import '../home/home_notifier.dart';
import 'widgets/package_calculator.dart';
import 'widgets/availability_calendar.dart';
import 'widgets/specs_accordion.dart';
import 'widgets/review_panel.dart';
import 'widgets/sticky_action_bar.dart';

class VendorDetailScreen extends ConsumerStatefulWidget {
  final String vendorId;

  const VendorDetailScreen({
    super.key,
    required this.vendorId,
  });

  @override
  ConsumerState<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends ConsumerState<VendorDetailScreen> {
  bool _isWishlisted = false;
  double _calculatedPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    // Try to find the vendor in the home state data
    final homeState = ref.watch(homeNotifierProvider);
    final allVendors = [...homeState.trendingVenues, ...homeState.eliteServices];
    final vendor = allVendors.where((v) => v.id == widget.vendorId).firstOrNull;

    if (vendor == null) {
      return Scaffold(
        backgroundColor: GomandapTokens.pearlWhite,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: GomandapTokens.royalNavy),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 64, color: GomandapTokens.slateGray.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              const Text(
                'Vendor not found',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: GomandapTokens.royalNavy),
              ),
              const SizedBox(height: 8),
              const Text(
                'This vendor may no longer be available.',
                style: TextStyle(fontSize: 14, color: GomandapTokens.slateGray),
              ),
            ],
          ),
        ),
      );
    }

    // Base price depending on category
    final double basePrice = (vendor.category == 'Venue' || vendor.category == 'Catering')
        ? vendor.basePlatePrice.toDouble()
        : vendor.packagePrice.toDouble();
    // initialise price if still zero
    if (_calculatedPrice == 0.0) _calculatedPrice = basePrice;

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      body: Stack(
        children: [
          // ── Scrollable Immersive Body ────────────────────────────────────────
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 360,
                  pinned: true,
                  stretch: true,
                  elevation: 0,
                  backgroundColor: GomandapTokens.royalNavy,
                  leading: const SizedBox.shrink(),
                  actions: const [],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'vendor-image-${vendor.id}',
                          child: Image.network(
                            vendor.imageUrls.isNotEmpty
                                ? vendor.imageUrls[0]
                                : 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.5, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Overview Information Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: GomandapTokens.emeraldGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: GomandapTokens.emeraldGreen.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shield_rounded, size: 12, color: GomandapTokens.emeraldGreen),
                            const SizedBox(width: 4),
                            Text(
                              '${vendor.category} · Escrow Protected',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: GomandapTokens.emeraldGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (vendor.isFastFilling)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt, size: 12, color: Colors.redAccent),
                              SizedBox(width: 2),
                              Text(
                                'Filling Fast',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Vendor Name
                  Text(
                    vendor.name,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: GomandapTokens.royalNavy,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Locality Info
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: GomandapTokens.emeraldGreen),
                      const SizedBox(width: 4),
                      Text(
                        vendor.locality,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: GomandapTokens.slateGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Rating Stats Pill
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: GomandapTokens.softMist,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: GomandapTokens.lightSlate),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: GomandapTokens.champagneGoldEnd),
                            const SizedBox(width: 4),
                            Text(
                              '${vendor.rating}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: GomandapTokens.royalNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '(${vendor.reviewCount} verified client reviews)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: GomandapTokens.slateGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 2. Availability Calendar Widget
                  const AvailabilityCalendar(),

                  const SizedBox(height: 36),

                  // 3. Package Calculator (dynamic pricing)
                  FutureBuilder<List<VendorInventory>>(
                    future: ref.read(inventoryRepositoryProvider).getInventoryForVendor(vendor.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return PackageCalculator(
                        packages: snapshot.data ?? [],
                        onSelectionChanged: (newPrice, selectedPackage) {
                          setState(() => _calculatedPrice = newPrice);
                        },
                        onAddToCart: () {
                          // Insert into Supabase bookings/cart (simplified placeholder)
                          final cartItem = {
                            'vendor_id': vendor.id,
                            'price': _calculatedPrice,
                            'details': 'Commodity booked',
                          };
                          final client = ref.read(supabaseClientProvider);
                          if (client != null) {
                            client.from('cart_items').insert(cartItem).then((_) {});
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart via Escrow'), backgroundColor: GomandapTokens.emeraldGreen),
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // 4. Technical Specifications Accordions
                  SpecsAccordion(
                    category: vendor.category,
                    specs: vendor.specs,
                  ),

                  const SizedBox(height: 36),

                  // 5. Verified Client Reviews
                  const ReviewPanel(),

                  // Extra spacing for floating bottom bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // ── Floated Header Action Row (Back, Heart, Share) ──────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeaderCircleButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => context.pop(),
                ),
                Row(
                  children: [
                    _buildHeaderCircleButton(
                      icon: _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      iconColor: _isWishlisted ? Colors.redAccent : GomandapTokens.royalNavy,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _isWishlisted = !_isWishlisted);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _isWishlisted
                                  ? '${vendor.name} added to your wishlist ❤️'
                                  : '${vendor.name} removed from your wishlist',
                            ),
                            backgroundColor: GomandapTokens.royalNavy,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildHeaderCircleButton(
                      icon: Icons.share_rounded,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharable details link copied to clipboard!'),
                            backgroundColor: GomandapTokens.emeraldGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Floating Sticky Bottom Action Bar ──────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: StickyActionBar(
              price: _calculatedPrice,
              category: vendor.category,
              onBookPressed: () {
                // Direct navigation to cart; price already stored via calculator
                context.push('/cart');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCircleButton({
    required IconData icon,
    Color iconColor = GomandapTokens.royalNavy,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
