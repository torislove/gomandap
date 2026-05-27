import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/vendor_application.dart';
import 'package:gomandap_common/data/repository_impl/vendor_application_repository.dart';
import '../shared/vendor_responsive_shell.dart';

class VendorDashboardScreen extends ConsumerStatefulWidget {
  const VendorDashboardScreen({super.key});

  @override
  ConsumerState<VendorDashboardScreen> createState() => _VendorDashboardScreenState();
}

class _VendorDashboardScreenState extends ConsumerState<VendorDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radialController;
  late Animation<double> _radialAnimation;

  @override
  void initState() {
    super.initState();
    _radialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _radialAnimation = Tween<double>(begin: 0.0, end: 0.72).animate(
      CurvedAnimation(parent: _radialController, curve: Curves.easeOutBack),
    );
    _radialController.forward();
  }

  @override
  void dispose() {
    _radialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    return VendorResponsiveShell(
      activePath: '/dashboard',
      child: Scaffold(
        backgroundColor: GomandapTokens.royalNavy,
        body: Stack(
          children: [
            // 1. Gold Filigree corners backdrop
            Positioned.fill(
              child: CustomPaint(
                painter: EthnicFiligreePainter(color: const Color(0x14DFBA73)),
              ),
            ),

            // 2. Main Dashboard scroll container
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Application Status Banner (Realtime)
                    _buildApplicationStatusBanner(),

                    // Upper branding & Locality Pill
                    _buildHeaderRow(),
                    const SizedBox(height: 24),

                    // Responsive reflowing dashboard content
                    if (screenWidth <= 800) ...[
                      // Mobile stacked view
                      _buildEscrowAnalyticsCard(),
                      const SizedBox(height: 24),
                      _buildMetricsScorecards(),
                      const SizedBox(height: 24),
                      _buildRecentBookingsFeedHeader(),
                      const SizedBox(height: 12),
                      _buildBookingCard(
                        clientName: 'Manoj Kumar & Kavya (Muhurtham Wedding)',
                        date: '12th Oct 2026',
                        locality: 'Jubilee Hills, Hyderabad',
                        value: '₹3,50,000',
                        isPending: true,
                      ),
                      const SizedBox(height: 12),
                      _buildBookingCard(
                        clientName: 'Nikhil & Priya (Sangeet Reception)',
                        date: '18th Oct 2026',
                        locality: 'Banjara Hills, Hyderabad',
                        value: '₹1,20,000',
                        isPending: false,
                      ),
                    ] else ...[
                      // Desktop multi-column grid layout
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left side: Escrow progress & metrics cards
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildEscrowAnalyticsCard(),
                                const SizedBox(height: 24),
                                _buildMetricsScorecards(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          // Right side: Active feed timeline
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRecentBookingsFeedHeader(),
                                const SizedBox(height: 12),
                                _buildBookingCard(
                                  clientName: 'Manoj Kumar & Kavya (Muhurtham Wedding)',
                                  date: '12th Oct 2026',
                                  locality: 'Jubilee Hills, Hyderabad',
                                  value: '₹3,50,000',
                                  isPending: true,
                                ),
                                const SizedBox(height: 12),
                                _buildBookingCard(
                                  clientName: 'Nikhil & Priya (Sangeet Reception)',
                                  date: '18th Oct 2026',
                                  locality: 'Banjara Hills, Hyderabad',
                                  value: '₹1,20,000',
                                  isPending: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Application Status Banner ───────────────────────────────────────────────

  Widget _buildApplicationStatusBanner() {
    final appAsync = ref.watch(myVendorApplicationProvider);
    return appAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (app) {
        if (app == null) return const SizedBox.shrink();

        switch (app.status) {
          case VendorAppStatus.needsCorrection:
            return _buildCorrectionBanner(app);
          case VendorAppStatus.approved:
            return _buildApprovedBanner();
          case VendorAppStatus.pending:
          case VendorAppStatus.underReview:
            return _buildPendingChip();
          case VendorAppStatus.rejected:
            return _buildRejectedBanner();
        }
      },
    );
  }

  Widget _buildCorrectionBanner(VendorApplication app) {
    final notes = app.correctionNotes;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GomandapTokens.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GomandapTokens.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: GomandapTokens.error, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'GoMandap Admin flagged your application for corrections',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...notes.map((n) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_right_rounded,
                          size: 14, color: GomandapTokens.error),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          n.message,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/register', extra: app.phone);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: GomandapTokens.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Fix My Application →',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GomandapTokens.emeraldGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: GomandapTokens.emeraldGreen.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded,
              color: GomandapTokens.emeraldGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your GoMandap Vendor Profile is LIVE! 🎉',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Clients can now discover and book your services',
                  style: TextStyle(fontSize: 11, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingChip() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: GomandapTokens.champagneGoldStart,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              '📋 Application under GoMandap review — typically 24 hours',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.white60,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GomandapTokens.slateGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GomandapTokens.slateGray.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: Colors.white54),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your application was not approved. Contact support@gomandap.com',
              style: TextStyle(fontSize: 11, color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: GomandapTokens.champagneGoldStart, size: 22),
                const SizedBox(width: 6),
                Text(
                  'GoMandap',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Vendor Suite · Corporate Dashboard',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: GomandapTokens.royalNavyLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 6, color: GomandapTokens.emeraldGreen),
              const SizedBox(width: 6),
              Text(
                'Jubilee Hills Hub',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEscrowAnalyticsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular custom gauge
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90, height: 90,
                child: AnimatedBuilder(
                  animation: _radialAnimation,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _RadialEscrowGaugePainter(progress: _radialAnimation.value),
                    );
                  },
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '72%',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'SECURE',
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Analytical values list
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Escrow Vaults Performance',
                  style: GoogleFonts.outfit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your event payouts are locked in milestone reserves. Releases are instant on client milestone approval pin.',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsScorecards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Locked Escrow',
            value: '₹3,50,000',
            icon: Icons.lock_outline_rounded,
            accentColor: GomandapTokens.champagneGoldStart,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricTile(
            title: 'Cleared Payouts',
            value: '₹8,20,000',
            icon: Icons.check_circle_outline_rounded,
            accentColor: GomandapTokens.emeraldGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              Icon(icon, size: 14, color: accentColor),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Milestones Release Protected',
            style: TextStyle(
              fontSize: 8,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookingsFeedHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Active Booking Proposals',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          'View All (${2})',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard({
    required String clientName,
    required String date,
    required String locality,
    required String value,
    required bool isPending,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? GomandapTokens.champagneGoldStart.withValues(alpha: 0.25)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  clientName,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isPending
                      ? GomandapTokens.champagneGoldStart.withValues(alpha: 0.15)
                      : GomandapTokens.emeraldGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPending ? 'PENDING DECISION' : 'ESCROW LOCKED',
                  style: TextStyle(
                    fontSize: 7.5,
                    fontWeight: FontWeight.w900,
                    color: isPending
                        ? GomandapTokens.champagneGoldStart
                        : GomandapTokens.emeraldGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 10, color: Colors.white60),
              const SizedBox(width: 4),
              Text(date, style: const TextStyle(fontSize: 9.5, color: Colors.white60)),
              const SizedBox(width: 12),
              const Icon(Icons.location_on_rounded, size: 10, color: GomandapTokens.emeraldGreen),
              const SizedBox(width: 4),
              Text(locality, style: const TextStyle(fontSize: 9.5, color: Colors.white60)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimate Payout',
                    style: TextStyle(fontSize: 7.5, color: Colors.white.withValues(alpha: 0.45)),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (isPending)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Proposal declined.'), behavior: SnackBarBehavior.floating),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Decline',
                          style: TextStyle(color: Color(0xFFEF4444), fontSize: 9.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Escrow Proposal Accepted! Milestones locked in vault. 🏛'),
                            backgroundColor: GomandapTokens.emeraldGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [GomandapTokens.emeraldGreen, GomandapTokens.emeraldGreenDark],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: GomandapTokens.emeraldGreen.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Accept Proposal',
                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
        ),
    );
  }
}

class _RadialEscrowGaugePainter extends CustomPainter {
  final double progress;

  _RadialEscrowGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final center = Offset(radius, radius);

    // Track circle paint
    final paintTrack = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    // Progress gauge paint
    final paintProgress = Paint()
      ..color = GomandapTokens.champagneGoldStart
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - 4, paintTrack);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -1.57, // Start at top
      6.28 * progress, // Sweep angle
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
