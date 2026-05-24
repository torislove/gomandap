package com.gomandap.common.ui.navigation

import androidx.compose.runtime.CompositionLocal
import androidx.compose.runtime.MutableState
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.mutableStateOf

/**
 * Set of route patterns that identify authentication and onboarding screens.
 * Bottom navigation and side drawers should be hidden on these screens.
 *
 * Routes are matched using [isAuthOrOnboardingRoute] which checks if the
 * current route contains any of these patterns (case-insensitive).
 */
val AUTH_ONBOARDING_ROUTES: Set<String> = setOf(
    "login",
    "otp",
    "register",
    "signup",
    "onboarding",
    "forgot_password",
    "reset_password",
    "verify"
)

/**
 * Determines whether the bottom navigation bar should be shown for the given route.
 *
 * Returns `false` for authentication and onboarding screens (login, OTP, register,
 * onboarding flows), and `true` for all other screens. This logic is app-type agnostic
 * and works consistently across Admin, Vendor, and Client apps.
 *
 * @param currentRoute The current navigation route string. If null or blank, defaults to showing the nav bar.
 * @return `true` if the bottom navigation bar should be visible, `false` if it should be hidden.
 */
fun shouldShowBottomNav(currentRoute: String?): Boolean {
    if (currentRoute.isNullOrBlank()) return true
    val routeLower = currentRoute.lowercase()
    return AUTH_ONBOARDING_ROUTES.none { pattern ->
        routeLower.contains(pattern)
    }
}

/**
 * Checks whether the given route corresponds to an authentication or onboarding screen.
 *
 * @param route The navigation route to check.
 * @return `true` if the route is an auth/onboarding screen, `false` otherwise.
 */
fun isAuthOrOnboardingRoute(route: String?): Boolean {
    return !shouldShowBottomNav(route)
}

/**
 * State holder for navigation bar visibility that can be consumed by the AppShell.
 *
 * This allows screens or navigation logic to imperatively control bottom nav visibility
 * beyond the route-based automatic detection.
 *
 * @property isVisible Mutable state indicating whether the bottom nav bar is currently visible.
 */
class NavBarVisibilityState(
    val isVisible: MutableState<Boolean> = mutableStateOf(true)
) {
    /**
     * Updates visibility based on the current route using the standard auth/onboarding detection.
     *
     * @param currentRoute The current navigation route.
     */
    fun updateForRoute(currentRoute: String?) {
        isVisible.value = shouldShowBottomNav(currentRoute)
    }

    /**
     * Explicitly show the bottom navigation bar.
     */
    fun show() {
        isVisible.value = true
    }

    /**
     * Explicitly hide the bottom navigation bar.
     */
    fun hide() {
        isVisible.value = false
    }
}

/**
 * CompositionLocal providing [NavBarVisibilityState] to the composition tree.
 *
 * The AppShell should provide this at the top level so that any composable in the tree
 * can read or modify the bottom navigation bar visibility.
 *
 * Usage in AppShell:
 * ```kotlin
 * val navBarVisibility = remember { NavBarVisibilityState() }
 * CompositionLocalProvider(LocalNavBarVisibility provides navBarVisibility) {
 *     // App content
 * }
 * ```
 *
 * Usage in screens:
 * ```kotlin
 * val navBarVisibility = LocalNavBarVisibility.current
 * // Read: navBarVisibility.isVisible.value
 * // Write: navBarVisibility.hide() or navBarVisibility.show()
 * ```
 */
val LocalNavBarVisibility: CompositionLocal<NavBarVisibilityState> =
    compositionLocalOf { NavBarVisibilityState() }
