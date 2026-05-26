import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    _NavTab(path: '/home', icon: Icons.home_rounded, label: 'Home'),
    _NavTab(path: '/search', icon: Icons.search_rounded, label: 'Explore'),
    _NavTab(path: '/bookings', icon: Icons.receipt_long_rounded, label: 'Bookings'),
    _NavTab(path: '/profile', icon: Icons.person_rounded, label: 'Profile'),
  ];

  void _onTabTapped(int index) {
    HapticFeedback.selectionClick();
    if (_currentIndex == index) {
      // Scroll to top behavior (handled via GoRouter)
      return;
    }
    setState(() => _currentIndex = index);
    context.go(_tabs[index].path);
  }

  @override
  Widget build(BuildContext context) {
    // Sync index from current route
    final location = GoRouterState.of(context).uri.path;
    final routeIndex = _tabs.indexWhere((t) => location.startsWith(t.path));
    if (routeIndex >= 0 && routeIndex != _currentIndex) {
      _currentIndex = routeIndex;
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _GomandapBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        tabs: _tabs,
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

