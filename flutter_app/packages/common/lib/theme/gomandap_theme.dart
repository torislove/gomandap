
import 'package:flutter/material.dart';
import 'gomandap_tokens.dart';
import 'gomandap_animations.dart';

class GomandapTheme {
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: GomandapTokens.pearlWhite,
    colorScheme: const ColorScheme.light(
      primary: GomandapTokens.royalNavy,
      secondary: GomandapTokens.emeraldGreen,
      surface: GomandapTokens.pearlWhite,
      error: GomandapTokens.error,
    ),
    // ── Smooth Page Transitions ──
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: _PremiumPageTransitionBuilder(),
        TargetPlatform.iOS: _PremiumPageTransitionBuilder(),
        TargetPlatform.windows: _PremiumPageTransitionBuilder(),
        TargetPlatform.macOS: _PremiumPageTransitionBuilder(),
        TargetPlatform.linux: _PremiumPageTransitionBuilder(),
      },
    ),
    // ── Snackbar Theme ──
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    // ── Elevated Button ──
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
    ),
    // ── Card Theme ──
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
    ),
    // ── Bottom Navigation Bar ──
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.transparent,
      selectedItemColor: GomandapTokens.emeraldGreen,
      unselectedItemColor: GomandapTokens.slateGray,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

/// A premium page transition that provides smooth slide-up + fade for all
/// route pushes, with a subtle scale effect on the incoming page.
class _PremiumPageTransitionBuilder extends PageTransitionsBuilder {
  const _PremiumPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.06),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: GomandapAnimations.springOut,
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: GomandapAnimations.springOut,
        ),
        child: child,
      ),
    );
  }
}
