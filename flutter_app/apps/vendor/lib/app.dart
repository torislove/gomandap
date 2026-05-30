import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gomandap_common/theme/gomandap_tokens.dart';
import 'package:gomandap_common/core/supabase/supabase_client.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/vendor_login_screen.dart';
import 'features/auth/vendor_registration_screen.dart';
import 'presentation/dashboard/vendor_dashboard_screen.dart';
import 'presentation/bookings/vendor_bookings_screen.dart';
import 'presentation/calendar/vendor_calendar_screen.dart';
import 'presentation/catalog/vendor_catalog_screen.dart';

final vendorRouterProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final isAuthenticated = client?.auth.currentUser != null;

  return GoRouter(
    initialLocation: isAuthenticated ? '/dashboard' : '/login',
    redirect: (context, state) {
      final path = state.uri.path;
      final isLoggingIn = path == '/login' || path == '/register';
      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && path == '/login') return '/dashboard';
      return null;
    },
    routes: [
      // Login screen
      GoRoute(
        path: '/login',
        builder: (context, state) => VendorLoginScreen(
          onSuccess: () {
            GoRouter.of(context).go('/dashboard');
          },
        ),
      ),

      // Registration wizard
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
});

class VendorApp extends ConsumerWidget {
  const VendorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(vendorRouterProvider);

    return MaterialApp.router(
      title: 'GoMandap Vendor Suite',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: GomandapTokens.pearlWhite,
        primaryColor: GomandapTokens.champagneGoldStart,
        fontFamily: GoogleFonts.outfit().fontFamily,
        colorScheme: const ColorScheme.light(
          primary: GomandapTokens.champagneGoldStart,
          secondary: GomandapTokens.champagneGoldEnd,
          surface: GomandapTokens.glassBackground,
          error: GomandapTokens.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: GomandapTokens.pearlWhite,
          elevation: 0,
        ),
      ),
    );
  }
}
