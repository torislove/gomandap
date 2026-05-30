import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';

class VendorResponsiveShell extends ConsumerWidget {
  final Widget child;
  final String activePath;

  const VendorResponsiveShell({
    super.key,
    required this.child,
    required this.activePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double bottomPadding = MediaQuery.paddingOf(context).bottom;

    // Mobile Viewport Layout (Floated bottom nav overlay with dynamic safearea bottom spacing)
    if (screenWidth <= 800) {
      return Scaffold(
        backgroundColor: GomandapTokens.pearlWhite,
        body: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                top: false,
                bottom: true,
                child: child,
              ),
            ),
            Positioned(
              bottom: 16 + bottomPadding,
              left: 16,
              right: 16,
              child: _buildMobileFloatedNavBar(context),
            ),
          ],
        ),
      );
    }

    // Desktop/Web Viewport Layout (Adaptive Collapsing Left Sidebar + Wide Workspace Grid)
    final bool showLabels = screenWidth > 1080;
    final double sidebarWidth = showLabels ? 250 : 80;

    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      body: Row(
        children: [
          // Left persistent dark luxury sidebar (animated transition for premium feel)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: sidebarWidth,
            child: _buildDesktopSidebar(context, ref, showLabels),
          ),

          // Divider
          Container(
            width: 1.5,
            height: double.infinity,
            color: const Color(0xFFDFBA73).withValues(alpha: 0.15),
          ),

          // Main expanded view container
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, WidgetRef ref, bool showLabels) {
    return Container(
      color: GomandapTokens.pearlWhite,
      padding: EdgeInsets.symmetric(vertical: 24, horizontal: showLabels ? 16 : 8),
      child: Column(
        crossAxisAlignment: showLabels ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          // Logo & Branding Area
          Row(
            mainAxisAlignment: showLabels ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              const Icon(Icons.workspace_premium_rounded, color: GomandapTokens.champagneGoldStart, size: 24),
              if (showLabels) ...[
                const SizedBox(width: 8),
                Text(
                  'GoMandap',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: GomandapTokens.royalNavy,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ],
          ),
          if (showLabels) ...[
            const SizedBox(height: 2),
            Text(
              'Vendor Suite · Enterprise Console',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: GomandapTokens.slateGray,
              ),
            ),
            const SizedBox(height: 10),
            ref.watch(supabaseConnectedProvider).when(
                  data: (connected) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: connected
                          ? GomandapTokens.emeraldGreen.withValues(alpha: 0.1)
                          : GomandapTokens.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: connected
                            ? GomandapTokens.emeraldGreen.withValues(alpha: 0.25)
                            : GomandapTokens.error.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          connected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                          size: 12,
                          color: connected ? GomandapTokens.emeraldGreen : GomandapTokens.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          connected ? 'SUPABASE LIVE ENGINE' : 'LOCAL OFFLINE CACHE',
                          style: GoogleFonts.inter(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            color: connected ? GomandapTokens.emeraldGreen : GomandapTokens.error,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: GomandapTokens.champagneGoldStart),
                  ),
                  error: (_, __) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: GomandapTokens.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('ERROR', style: TextStyle(fontSize: 8.5, color: GomandapTokens.error)),
                  ),
                ),
          ],

          const SizedBox(height: 28),

          // Jubilee Hills Hub Active Pill / Collapsed Dot
          if (showLabels)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: GomandapTokens.emeraldGreen),
                  const SizedBox(width: 8),
                  Text(
                    'Jubilee Hills Hub',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: GomandapTokens.royalNavy,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: GomandapTokens.emeraldGreen,
                shape: BoxShape.circle,
              ),
            ),

          const SizedBox(height: 32),

          // Navigation Links list
          _buildSidebarNavItem(
            context,
            icon: Icons.dashboard_rounded,
            label: 'Console Home',
            path: '/dashboard',
            isActive: activePath == '/dashboard',
            showLabel: showLabels,
          ),
          const SizedBox(height: 12),
          _buildSidebarNavItem(
            context,
            icon: Icons.book_online_rounded,
            label: 'Escrow Bookings',
            path: '/bookings',
            isActive: activePath == '/bookings',
            showLabel: showLabels,
          ),
          const SizedBox(height: 12),
          _buildSidebarNavItem(
            context,
            icon: Icons.calendar_month_rounded,
            label: 'Interactive Slots',
            path: '/calendar',
            isActive: activePath == '/calendar',
            showLabel: showLabels,
          ),
          const SizedBox(height: 12),
          _buildSidebarNavItem(
            context,
            icon: Icons.inventory_2_rounded,
            label: 'Specs Catalog',
            path: '/catalog',
            isActive: activePath == '/catalog',
            showLabel: showLabels,
          ),

          const Spacer(),

          // Footer Profile Row
          if (showLabels)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GomandapTokens.softMist,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GomandapTokens.lightSlate),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: GomandapTokens.champagneGoldStart,
                    radius: 16,
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jubilee Grand Mandap',
                          style: TextStyle(color: GomandapTokens.royalNavy, fontSize: 10, fontWeight: FontWeight.w800),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Verified Vendor',
                          style: TextStyle(color: GomandapTokens.slateGray, fontSize: 8, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          else
            const CircleAvatar(
              backgroundColor: GomandapTokens.champagneGoldStart,
              radius: 16,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String path,
    required bool isActive,
    required bool showLabel,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (!isActive) {
          context.push(path);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: showLabel ? 14 : 0, vertical: 10),
        alignment: showLabel ? Alignment.centerLeft : Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? GomandapTokens.champagneGoldStart.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFFDFBA73).withValues(alpha: 0.25) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: showLabel ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? GomandapTokens.champagneGoldStart : GomandapTokens.royalNavy,
            ),
            if (showLabel) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                  color: isActive ? GomandapTokens.champagneGoldStart : GomandapTokens.royalNavy,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFloatedNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: GomandapTokens.softMist.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: GomandapTokens.lightSlate, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMobileNavPill(context, Icons.dashboard_rounded, 'Home', '/dashboard', activePath == '/dashboard'),
          _buildMobileNavPill(context, Icons.book_online_rounded, 'Bookings', '/bookings', activePath == '/bookings'),
          _buildMobileNavPill(context, Icons.calendar_month_rounded, 'Slots', '/calendar', activePath == '/calendar'),
          _buildMobileNavPill(context, Icons.inventory_2_rounded, 'Specs', '/catalog', activePath == '/catalog'),
        ],
      ),
    );
  }

  Widget _buildMobileNavPill(
    BuildContext context,
    IconData icon,
    String label,
    String path,
    bool isActive,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (!isActive) {
          context.push(path);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? GomandapTokens.champagneGoldStart.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? GomandapTokens.champagneGoldStart : GomandapTokens.royalNavy,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: GomandapTokens.champagneGoldStart,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
