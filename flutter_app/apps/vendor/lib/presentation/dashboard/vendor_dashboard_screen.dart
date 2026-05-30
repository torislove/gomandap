import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/domain/models/vendor_application.dart';
import 'package:gomandap_common/data/repository_impl/vendor_application_repository.dart';
import '../shared/vendor_responsive_shell.dart';
import 'package:gomandap_common/presentation/widgets/gomandap_screen.dart';
import '../../application/vendor_bookings_provider.dart';

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
    final appAsync = ref.watch(myVendorApplicationProvider);

    return VendorResponsiveShell(
      activePath: '/dashboard',
      child: GomandapScreen(
        backgroundColor: GomandapTokens.royalNavy,
        useHorizontalPadding: false,
        useSafeAreaTop: true,
        useSafeAreaBottom: false,
        maxWidth: 1200.0,
        body: Stack(
          children: [
            // 1. Gold Filigree corners backdrop
            Positioned.fill(
              child: CustomPaint(
                painter: EthnicFiligreePainter(color: const Color(0x14DFBA73)),
              ),
            ),

            appAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: GomandapTokens.champagneGoldStart)),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
              data: (app) {
                if (app == null) {
                  return const Center(child: Text('No application found.', style: TextStyle(color: Colors.white)));
                }

                if (app.status == VendorAppStatus.approved) {
                  return _buildFullDashboard(app);
                } else if (app.status == VendorAppStatus.needsCorrection) {
                  return _buildCorrectionState(app);
                } else if (app.status == VendorAppStatus.rejected) {
                  return _buildRejectedState();
                } else {
                  return _buildPendingState();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── States ────────────────────────────────────────────────────────────────

  Widget _buildFullDashboard(VendorApplication app) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(app),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth <= 800;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEscrowAnalyticsCard(),
                    const SizedBox(height: 24),
                    _buildMetricsScorecards(),
                    const SizedBox(height: 24),
                    _buildRecentBookingsFeedHeader(),
                    const SizedBox(height: 12),
                    _buildProposalsFeed(),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRecentBookingsFeedHeader(),
                          const SizedBox(height: 12),
                          _buildProposalsFeed(),
                        ],
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCorrectionState(VendorApplication app) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 64, color: GomandapTokens.error),
            const SizedBox(height: 24),
            Text(
              'Corrections Required',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'GoMandap Admin flagged your application for corrections before approval.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GomandapTokens.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GomandapTokens.error.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please fix the following issues:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...app.correctionNotes.map((n) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.close_rounded, size: 16, color: GomandapTokens.error),
                        const SizedBox(width: 8),
                        Expanded(child: Text(n.message, style: const TextStyle(color: Colors.white))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.push('/register', extra: app.phone);
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text('Fix My Application', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: GomandapTokens.error,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(strokeWidth: 4, color: GomandapTokens.champagneGoldStart),
            ),
            const SizedBox(height: 32),
            Text(
              'Application Under Review',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Your vendor profile is currently being reviewed by the GoMandap team.\nThis typically takes up to 24 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel_outlined, size: 64, color: Colors.white54),
            const SizedBox(height: 24),
            Text(
              'Application Rejected',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Unfortunately, your application was not approved.\nPlease contact support@gomandap.com for more details.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
      ),
    );
  }

  // (Removed _buildCorrectionBanner, _buildApprovedBanner, _buildPendingChip, _buildRejectedBanner since they are full page now)

  Widget _buildHeaderRow(VendorApplication app) {

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
              'Vendor Suite · ${app.businessName}',
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
              const Icon(Icons.verified, size: 12, color: GomandapTokens.emeraldGreen),
              const SizedBox(width: 6),
              Text(
                'ID: ${app.city.length >= 3 ? app.city.substring(0, 3).toUpperCase() : app.city.toUpperCase()}-${app.id.substring(0, math.min(8, app.id.length))}',
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
        GestureDetector(
          onTap: () {
            context.push('/bookings');
          },
          child: Text(
            'View All',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProposalsFeed() {
    final bookingsAsync = ref.watch(vendorBookingsProvider);

    return bookingsAsync.when(
      data: (bookings) {
        final pending = bookings.where((b) => b.escrowStatus == 'Pending').take(3).toList();
        
        if (pending.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No pending proposals.', style: TextStyle(color: Colors.white54)),
          );
        }

        return Column(
          children: pending.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildBookingCard(
              id: b.id,
              clientName: b.clientName,
              date: b.eventDate,
              locality: 'Hyderabad',
              value: '₹${b.totalAmount.toString().replaceAllMapped(RegExp(r"(\d)(?=(\d{3})+(?!\d))"), (match) => "${match[1]},")}',
              isPending: true,
            ),
          )).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: GomandapTokens.champagneGoldStart)),
      error: (_, __) => const Text('Error loading proposals.', style: TextStyle(color: GomandapTokens.error)),
    );
  }

  Widget _buildBookingCard({
    required String id,
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
                        ref.read(vendorActionProvider.notifier).updateBookingStatus(id, 'Cancelled');
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
                        ref.read(vendorActionProvider.notifier).updateBookingStatus(id, 'Milestone 1 (Advance)');
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
