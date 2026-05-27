import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../home/home_notifier.dart';
import '../search/search_notifier.dart';
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
  late VendorSummary _vendor;
  bool _isWishlisted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  void _loadVendorData() {
    // Attempt to search in our comprehensive mock database
    final found = allMockVendors.firstWhere(
      (v) => v.id == widget.vendorId,
      orElse: () => VendorSummary(
        id: widget.vendorId,
        name: 'The Royal Mandap Heritage',
        locality: 'Gachibowli, Hyderabad',
        rating: 4.8,
        reviewCount: 145,
        basePlatePrice: 1350,
        packagePrice: 350000,
        category: 'Venue',
        imageUrls: const [
          'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
          'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
        ],
      ),
    );

    setState(() {
      _vendor = found;
      _isLoading = false;
    });
  }

  void _toggleWishlist() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isWishlisted = !_isWishlisted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isWishlisted
              ? '${_vendor.name} added to your wishlist ❤️'
              : '${_vendor.name} removed from your wishlist',
        ),
        backgroundColor: GomandapTokens.royalNavy,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: GomandapTokens.champagneGoldStart,
          onPressed: () {
            setState(() {
              _isWishlisted = !_isWishlisted;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: GomandapTokens.pearlWhite,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(GomandapTokens.emeraldGreen),
          ),
        ),
      );
    }

    final price = _vendor.category == 'Venue' || _vendor.category == 'Catering'
        ? _vendor.basePlatePrice
        : _vendor.packagePrice;

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
                  leading: const SizedBox.shrink(), // Custom back button is floated
                  actions: const [],
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.blurBackground,
                    ],
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Main Immersive Photo Gallery
                        Image.network(
                          _vendor.imageUrls.isNotEmpty
                              ? _vendor.imageUrls[0]
                              : 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
                          fit: BoxFit.cover,
                        ),
                        // Soft dark bottom gradient for header texts
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
                              '${_vendor.category} · Escrow Protected',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: GomandapTokens.emeraldGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_vendor.isFastFilling)
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
                    _vendor.name,
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
                        _vendor.locality,
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
                              '${_vendor.rating}',
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
                        '(${_vendor.reviewCount} verified client reviews)',
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

                  // 3. Technical Specifications Accordions
                  SpecsAccordion(
                    category: _vendor.category,
                    specs: _vendor.specs,
                  ),

                  const SizedBox(height: 36),

                  // 4. Verified Client Reviews
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
                      onTap: _toggleWishlist,
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
              price: price,
              category: _vendor.category,
              onBookPressed: () {
                // Book directly launches our escrow checkout flow
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
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

