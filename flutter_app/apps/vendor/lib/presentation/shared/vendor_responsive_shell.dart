import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class VendorResponsiveShell extends StatelessWidget {
  final Widget child;
  final String activePath;

  const VendorResponsiveShell({
    super.key,
    required this.child,
    required this.activePath,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Mobile Viewport Layout (Floated bottom nav overlay)
    if (screenWidth <= 800) {
      return Scaffold(
        backgroundColor: GomandapTokens.royalNavy,
        body: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildMobileFloatedNavBar(context),
            ),
          ],
        ),
      );
    }

    // Desktop/Web Viewport Layout (Persistent Left Sidebar + Wide Workspace Grid)
    return Scaffold(
      backgroundColor: GomandapTokens.royalNavy,
      body: Row(
        children: [
          // Left persistent dark luxury sidebar
          _buildDesktopSidebar(context),

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

  Widget _buildDesktopSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: GomandapTokens.royalNavy,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Branding Area
          Row(
            children: [
              const Icon(Icons.workspace_premium_rounded, color: GomandapTokens.champagneGoldStart, size: 24),
              const SizedBox(width: 8),
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
            'Vendor Suite · Enterprise Console',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.45),
            ),
          ),

          const SizedBox(height: 28),

          // Jubilee Hills Hub Active Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: GomandapTokens.royalNavyLight,
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
                    color: Colors.white,
                  ),
                ),
              ],
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
          ),
          const SizedBox(height: 12),
          _buildSidebarNavItem(
            context,
            icon: Icons.book_online_rounded,
            label: 'Escrow Bookings',
            path: '/bookings',
            isActive: activePath == '/bookings',
          ),
          const SizedBox(height: 12),
          _buildSidebarNavItem(
            context,
            icon: Icons.calendar_month_rounded,
            label: 'Interactive Slots',
            path: '/calendar',
            isActive: activePath == '/calendar',
          ),
          const SizedBox(height: 12),
          _buildSidebarNavItem(
            context,
            icon: Icons.inventory_2_rounded,
            label: 'Specs Catalog',
            path: '/catalog',
            isActive: activePath == '/catalog',
          ),

          const Spacer(),

          // Footer Profile Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GomandapTokens.royalNavyLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: GomandapTokens.champagneGoldStart,
                  radius: 16,
                  child: Icon(Icons.person_rounded, color: GomandapTokens.royalNavy, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jubilee Grand Mandap',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Verified Vendor',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 8, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? GomandapTokens.champagneGoldStart.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFFDFBA73).withValues(alpha: 0.25) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? GomandapTokens.champagneGoldStart : Colors.white60,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                color: isActive ? GomandapTokens.champagneGoldStart : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileFloatedNavBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
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
              color: isActive ? GomandapTokens.champagneGoldStart : Colors.white60,
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
