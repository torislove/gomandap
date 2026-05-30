import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/profile/budget_planner_screen.dart';
import '../../features/bookings/bookings_screen.dart';
import '../../features/bookings/booking_detail_screen.dart';
import '../../features/escrow/escrow_tracker_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/vendor_onboarding_wizard.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/venue/venue_details_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../shared/widgets/main_shell.dart';
import '../../features/onboarding/client_onboarding_wizard.dart';
import '../../features/home/widgets/category_detail_screen.dart';

// Auth state — false = start from login screen (mock OTP: 123456 bypasses real auth)
bool _isAuthenticated = false;

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login', // Always start from the premium login screen
    redirect: (context, state) {
      final isLoginRoute = state.uri.path == '/login';
      final isOnboardingRoute = state.uri.path == '/onboarding';
      if (!_isAuthenticated && !isLoginRoute && !isOnboardingRoute) return '/login';
      return null;
    },

    routes: [
      // Auth routes (no bottom nav)
      GoRoute(
        path: '/budget-planner',
        builder: (context, state) => const BudgetPlannerScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const ClientLoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const ClientOnboardingWizard(),
      ),

      // Main shell with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const ClientHomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/bookings',
            builder: (context, state) => const BookingsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/become-vendor',
        builder: (context, state) => const VendorOnboardingWizard(),
      ),
      GoRoute(
        path: '/vendor/:id',
        builder: (context, state) => VendorDetailScreen(
          vendorId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/booking/:id',
        builder: (context, state) => BookingDetailScreen(
          bookingId: state.pathParameters['id'] ?? '',
        ),
      ),
      GoRoute(
        path: '/escrow/:bookingId',
        builder: (context, state) => EscrowTrackerScreen(
          bookingId: state.pathParameters['bookingId'] ?? '',
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/category/:categoryId',
        builder: (context, state) => CategoryDetailScreen(
          categoryId: state.pathParameters['categoryId'] ?? '',
        ),
      ),
    ],
  );

  /// Call this after successful login to update auth state
  static void onLoginSuccess() {
    _isAuthenticated = true;
  }
}
