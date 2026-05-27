import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/vendor_login_screen.dart';
import 'features/auth/vendor_registration_screen.dart';
import 'presentation/dashboard/vendor_dashboard_screen.dart';
import 'presentation/bookings/vendor_bookings_screen.dart';
import 'presentation/calendar/vendor_calendar_screen.dart';
import 'presentation/catalog/vendor_catalog_screen.dart';

// Auth state — false means start from login (mock OTP: 123456)
bool _vendorAuthenticated = false;

class VendorApp extends StatelessWidget {
  const VendorApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final path = state.uri.path;
      if (!_vendorAuthenticated && path != '/login') return '/login';
      return null;
    },
    routes: [
      // Login screen — always first
      GoRoute(
        path: '/login',
        builder: (context, state) => VendorLoginScreen(
          onSuccess: () {
            _vendorAuthenticated = true;
            GoRouter.of(context).go('/dashboard');
          },
        ),
      ),

      // Registration wizard — for new vendor partners
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final prefillPhone = state.extra as String? ?? '';
          return VendorRegistrationScreen(prefillPhone: prefillPhone);
        },
      ),

      // Main vendor screens
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const VendorDashboardScreen(),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const VendorBookingsScreen(),
      ),
      GoRoute(
        path: '/calendar',
        builder: (context, state) => const VendorCalendarScreen(),
      ),
      GoRoute(
        path: '/catalog',
        builder: (context, state) => const VendorCatalogScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GoMandap Vendor Suite',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GomandapTokens.royalNavy,
        primaryColor: GomandapTokens.champagneGoldStart,
        fontFamily: GoogleFonts.outfit().fontFamily,
        colorScheme: const ColorScheme.dark(
          primary: GomandapTokens.champagneGoldStart,
          secondary: GomandapTokens.champagneGoldEnd,
          surface: GomandapTokens.royalNavyLight,
          error: GomandapTokens.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: GomandapTokens.royalNavy,
          elevation: 0,
        ),
      ),
    );
  }
}
