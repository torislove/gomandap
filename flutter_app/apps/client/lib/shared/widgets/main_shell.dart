import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import '../../core/i18n/i18n_notifier.dart';
import '../../features/auth/location_notifier.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Do not auto-detect location here. It is handled in Onboarding.
  }

  List<_NavTab> _tabs(WidgetRef r) {
    final t = r.watch(i18nProvider).t;
    return [
      _NavTab(path: '/home', icon: Icons.home_rounded, label: t('nav.home')),
      _NavTab(path: '/search', icon: Icons.search_rounded, label: t('nav.explore')),
      _NavTab(path: '/bookings', icon: Icons.receipt_long_rounded, label: t('nav.bookings')),
      _NavTab(path: '/profile', icon: Icons.person_rounded, label: t('nav.profile')),
    ];
  }

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    if (_currentIndex == index) return;
    final tabs = _tabs(ref);
    setState(() => _currentIndex = index);
    context.go(tabs[index].path);
  }

  @override
  Widget build(BuildContext context) {
    // Watch i18n so the shell rebuilds when language changes
    ref.watch(i18nProvider);
    final locationState = ref.watch(locationNotifierProvider);
    final tabs = _tabs(ref);
    
    String displayLocation = 'Hyderabad Hub';
    String shortLocality = 'Hyderabad';
    if (locationState is LocationSuccess) {
      displayLocation = '${locationState.locality}, ${locationState.city}';
      shortLocality = locationState.locality;
    }

    // Sync index from current route
    final location = GoRouterState.of(context).uri.path;
    final routeIndex = tabs.indexWhere((t) => location.startsWith(t.path));
    if (routeIndex >= 0 && routeIndex != _currentIndex) {
      _currentIndex = routeIndex;
    }

    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Mobile Viewport Layout
    if (screenWidth <= 800) {
      return Scaffold(
        body: widget.child,
        bottomNavigationBar: _GomandapBottomNav(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          tabs: tabs,
        ),
      );
    }

    // Desktop/Web Split-Pane Layout (Visual Bezel Device Simulation + Concierge Panel)
    return Scaffold(
      backgroundColor: GomandapTokens.pearlWhite,
      body: Stack(
        children: [
          // 1. Filigree Backdrop
          Positioned.fill(
            child: CustomPaint(
              painter: EthnicFiligreePainter(color: const Color(0x10DFBA73)),
            ),
          ),

          // 2. Main content split view
          Row(
            children: [
              // Left Pane: Premium physical smartphone mockup frame
              Expanded(
                flex: 4,
                child: Center(
                  child: Container(
                    width: 385,
                    height: 800,
                    margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(42),
                      border: Border.all(
                        color: const Color(0xFFDFBA73), // Glowing luxury gold frame bezel
                        width: 11,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: const Color(0xFFDFBA73).withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Smartphone Inner Content
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(31),
                            child: Scaffold(
                              body: widget.child,
                              bottomNavigationBar: _GomandapBottomNav(
                                currentIndex: _currentIndex,
                                onTap: _onTabTapped,
                                tabs: tabs,
                              ),
                            ),
                          ),
                        ),

                        // Physical Camera Notch / Island cutout
                        Positioned(
                          top: 14,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 110,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1E293B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 32,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF334155),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Divider Line
              Container(
                width: 1.5,
                height: double.infinity,
                color: const Color(0xFFDFBA73).withValues(alpha: 0.2),
              ),

              // Right Pane: Spacious, beautiful GoMandap Concierge & Directories Dashboard
              Expanded(
                flex: 6,
                child: Container(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded, color: GomandapTokens.champagneGoldStart, size: 30),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GoMandap Elite Web Concierge',
                                style: TextStyle(
                                  fontFamily: 'Outfit',
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'India\'s Premium Portal for Events · Live $displayLocation',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Row 1: Premium Local Metrics Cards
                      Row(
                        children: [
                          _buildConciergeStatCard(
                            icon: Icons.account_balance_rounded,
                            label: 'Verified Mandap Hubs',
                            value: '142 Active',
                          ),
                          const SizedBox(width: 16),
                          _buildConciergeStatCard(
                            icon: Icons.shield_rounded,
                            label: 'Escrow Vault Secured',
                            value: '₹2.4 Cr Protected',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Row 2: Large Concierge Directory Search Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: GomandapTokens.royalNavyLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFDFBA73).withValues(alpha: 0.25)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'QUICK CONCIERGE SEARCH',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: GomandapTokens.champagneGoldStart,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search premium decorators, caters, and venues instantly. Tapping items inside the mobile bezel automatically navigates the directory database.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.5),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              decoration: BoxDecoration(
                                color: GomandapTokens.royalNavy,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: TextField(
                                style: const TextStyle(color: Colors.white, fontSize: 12.5),
                                decoration: InputDecoration(
                                  icon: const Icon(Icons.search_rounded, color: GomandapTokens.champagneGoldStart, size: 18),
                                  hintText: 'e.g. $shortLocality Banquet Halls with AC rooms...',
                                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 12.5),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Row 3: Simulated Active Chat Assistant widget
                      _buildSimulatedChatWidget(shortLocality),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConciergeStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: GomandapTokens.royalNavyLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: GomandapTokens.champagneGoldStart.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: GomandapTokens.champagneGoldStart, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulatedChatWidget(String shortLocality) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GomandapTokens.royalNavyLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline_rounded, color: GomandapTokens.emeraldGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                'Elite Live Assistant (Active Concierge)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GomandapTokens.royalNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_circle, color: GomandapTokens.champagneGoldStart, size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'GoMandap Assistant',
                      style: TextStyle(fontSize: 9.5, color: GomandapTokens.champagneGoldStart, fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    Text(
                      'Just now',
                      style: TextStyle(fontSize: 8.5, color: Colors.white.withValues(alpha: 0.3)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Hello Manoj! Welcome to GoMandap $shortLocality. I see you are looking for banquet halls with >500 capacity. Would you like a direct introduction with the $shortLocality Grand Ballroom manager?',
                  style: const TextStyle(fontSize: 11, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: GomandapTokens.royalNavy,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: const Text(
                    'Yes, request direct introduction...',
                    style: TextStyle(color: Colors.white60, fontSize: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: GomandapTokens.goldLeafGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: GomandapTokens.royalNavy, size: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  final String path;
  final IconData icon;
  final String label;
  const _NavTab({required this.path, required this.icon, required this.label});
}

class _GomandapBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final List<_NavTab> tabs;

  const _GomandapBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: GomandapTokens.royalNavy.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isActive = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon with animated indicator pill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: isActive ? 16 : 0,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? GomandapTokens.emeraldGreen.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            tab.icon,
                            color: isActive
                                ? GomandapTokens.emeraldGreen
                                : GomandapTokens.slateGray,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive
                                ? GomandapTokens.emeraldGreen
                                : GomandapTokens.slateGray,
                          ),
                          child: Text(tab.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

