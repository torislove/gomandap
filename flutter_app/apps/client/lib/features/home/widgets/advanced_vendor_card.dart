import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../home_notifier.dart';

class AdvancedVendorCard extends StatefulWidget {
  final VendorSummary vendor;
  final bool isSponsored;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;
  final VoidCallback? onChat;
  final VoidCallback? onWishlist;

  const AdvancedVendorCard({
    super.key,
    required this.vendor,
    this.isSponsored = false,
    this.onTap,
    this.onBookNow,
    this.onChat,
    this.onWishlist,
  });

  @override
  State<AdvancedVendorCard> createState() => _AdvancedVendorCardState();
}

class _AdvancedVendorCardState extends State<AdvancedVendorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPerPlate = true;
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.forward();
  void _onTapUp(TapUpDetails _) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        child: Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSponsored
                  ? GomandapTokens.champagneGoldStart.withValues(alpha: 0.8)
                  : const Color(0x140F172A),
              width: widget.isSponsored ? 1.5 : 1.0,
            ),
            boxShadow: widget.isSponsored
                ? [
                    BoxShadow(
                      color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : GomandapTokens.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Section ──────────────────────────────────────────
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      widget.vendor.imageUrls.first,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 100,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.image, color: Color(0xFF94A3B8), size: 32),
                      ),
                    ),
                  ),
                  // Badge row
                  Positioned(
                    top: 8, left: 8,
                    child: Row(
                      children: [
                        if (widget.vendor.isEscrowProtected) _buildBadge(
                          icon: Icons.shield_outlined,
                          label: 'Escrow',
                          iconColor: GomandapTokens.emeraldGreen,
                          borderColor: const Color(0xFFA7F3D0),
                        ),
                        if (widget.vendor.isFastFilling) ...[
                          const SizedBox(width: 4),
                          _buildGoldBadge('🔥 FAST'),
                        ],
                      ],
                    ),
                  ),
                  // Sponsored badge
                  if (widget.isSponsored)
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: GomandapTokens.royalNavy,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Sponsored',
                          style: TextStyle(color: GomandapTokens.champagneGoldStart, fontSize: 8, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  // Wishlist heart
                  Positioned(
                    bottom: 8, right: 8,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        setState(() => _isWishlisted = !_isWishlisted);
                        widget.onWishlist?.call();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: _isWishlisted
                              ? const Color(0xFFFEE2E2)
                              : Colors.white.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)],
                        ),
                        child: Icon(
                          _isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: _isWishlisted ? const Color(0xFFE11D48) : GomandapTokens.slateGray,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Details Section ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.vendor.name,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: GomandapTokens.royalNavy,
                            ),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.vendor.isVerified) ...[
                          const SizedBox(width: 2),
                          const Icon(Icons.verified, size: 14, color: GomandapTokens.emeraldGreen),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Rating + locality
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 12, color: GomandapTokens.champagneGoldStart),
                        const SizedBox(width: 2),
                        Text(
                          '${widget.vendor.rating}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: GomandapTokens.royalNavy,
                          ),
                        ),
                        Text(
                          ' (${widget.vendor.reviewCount})',
                          style: GoogleFonts.inter(fontSize: 9, color: GomandapTokens.slateGray),
                        ),
                        Text(
                          ' · ',
                          style: GoogleFonts.inter(color: GomandapTokens.slateGray, fontSize: 10),
                        ),
                        Expanded(
                          child: Text(
                            widget.vendor.locality,
                            style: GoogleFonts.inter(fontSize: 10, color: GomandapTokens.slateGray),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price toggle row
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: GomandapTokens.softMist,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPerPlate
                                    ? '₹${widget.vendor.basePlatePrice.toInt()}/plate'
                                    : '₹${widget.vendor.packagePrice.toInt()} pkg',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: GomandapTokens.royalNavy,
                                ),
                              ),
                              Text(
                                _isPerPlate ? 'Plate Price' : 'Base Pkg',
                                style: GoogleFonts.inter(
                                  fontSize: 8,
                                  color: GomandapTokens.slateGray,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _isPerPlate = !_isPerPlate);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: GomandapTokens.champagneGoldStart, width: 1),
                              ),
                              child: Text(
                                _isPerPlate ? 'Package' : 'Per Plate',
                                style: const TextStyle(
                                  fontSize: 8, fontWeight: FontWeight.w700,
                                  color: GomandapTokens.champagneGoldEnd,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Footer actions
                    Row(
                      children: [
                        _buildIconAction(Icons.chat_bubble_outline_rounded, () {
                          HapticFeedback.lightImpact();
                          widget.onChat?.call();
                        }),
                        const SizedBox(width: 6),
                        _buildIconAction(Icons.ios_share_rounded, () {
                          HapticFeedback.lightImpact();
                        }),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            widget.onBookNow?.call();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: GomandapTokens.emeraldGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Book Now',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
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
      ),
    );
  }

  Widget _buildBadge({required IconData icon, required String label, required Color iconColor, required Color borderColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor),
          const SizedBox(width: 3),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: GomandapTokens.royalNavy)),
        ],
      ),
    );
  }

  Widget _buildGoldBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: GomandapTokens.champagneGoldStart,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
      ),
      child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
    );
  }

  Widget _buildIconAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34, height: 34,
        decoration: const BoxDecoration(
          color: GomandapTokens.softMist,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: GomandapTokens.royalNavy),
      ),
    );
  }
}

