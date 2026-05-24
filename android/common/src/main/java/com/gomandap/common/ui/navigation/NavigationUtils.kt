package com.gomandap.common.ui.navigation

import android.net.Uri

/**
 * Centralized navigation utilities for the GoMandap platform.
 *
 * Defines route constants for all screens across Admin, Vendor, and Client apps,
 * maintains a navigation graph mapping each route to its parent/back route,
 * and provides helper functions for back navigation, root screen detection,
 * and deep link parsing.
 *
 * Uses tokens from [com.gomandap.common.design.GomandapTokens] for any
 * navigation-related theming decisions.
 */

// ─── Route Constants ─────────────────────────────────────────────────────────

/**
 * Route constants for the Admin app screens.
 */
object AdminRoutes {
    const val LOGIN = "admin_login"
    const val DASHBOARD = "admin_dashboard"
    const val VENDOR_LIST = "admin_vendors"
    const val VENDOR_EDIT = "admin_vendor_edit/{vendorId}"
    const val VENDOR_ONBOARDING = "admin_vendor_onboarding"
    const val VENDOR_APPROVAL = "admin_vendor_approval"
    const val COMMISSION_CONFIG = "admin_commission_config"
    const val CRM_CONTACTS = "admin_crm_contacts"
    const val CRM_INTERACTIONS = "admin_crm_interactions"
    const val CATEGORIES = "admin_categories"
    const val CATEGORY_BUILDER = "admin_category_builder"
    const val BOOKING_LIST = "admin_bookings"
    const val ANALYTICS = "admin_analytics"

    /** Creates a vendor edit route with the given vendor ID. */
    fun vendorEditRoute(vendorId: String): String = "admin_vendor_edit/$vendorId"
}

/**
 * Route constants for the Vendor app screens.
 */
object VendorRoutes {
    const val LOGIN = "vendor_login"
    const val ONBOARDING = "vendor_onboarding"
    const val DASHBOARD = "vendor_dashboard"
    const val BOOKINGS = "vendor_bookings"
    const val BOOKING_DETAIL = "vendor_booking_detail/{bookingId}"
    const val EARNINGS = "vendor_earnings"
    const val CALENDAR = "vendor_calendar"
    const val PROFILE = "vendor_profile"
    const val PROFILE_EDIT = "vendor_profile_edit"
    const val REVIEWS = "vendor_reviews"

    /** Creates a booking detail route with the given booking ID. */
    fun bookingDetailRoute(bookingId: String): String = "vendor_booking_detail/$bookingId"
}

/**
 * Route constants for the Client app screens.
 */
object ClientRoutes {
    const val LOGIN = "client_login"
    const val OTP_VERIFICATION = "client_otp_verification"
    const val ONBOARDING = "client_onboarding"
    const val HOME = "client_home"
    const val SEARCH = "client_search"
    const val VENDOR_DETAIL = "client_vendor_detail/{vendorId}"
    const val BOOKINGS = "client_bookings"
    const val BOOKING_DETAIL = "client_booking_detail/{bookingId}"
    const val BOOKING_CHECKOUT = "client_booking_checkout/{vendorId}"
    const val ESCROW_TRACKER = "client_escrow_tracker/{bookingId}"
    const val PROFILE = "client_profile"
    const val WISHLIST = "client_wishlist"
    const val CART = "client_cart"
    const val CHAT = "client_chat"
    const val CHAT_DETAIL = "client_chat_detail/{chatId}"

    /** Creates a vendor detail route with the given vendor ID. */
    fun vendorDetailRoute(vendorId: String): String = "client_vendor_detail/$vendorId"

    /** Creates a booking detail route with the given booking ID. */
    fun bookingDetailRoute(bookingId: String): String = "client_booking_detail/$bookingId"

    /** Creates a booking checkout route with the given vendor ID. */
    fun bookingCheckoutRoute(vendorId: String): String = "client_booking_checkout/$vendorId"

    /** Creates an escrow tracker route with the given booking ID. */
    fun escrowTrackerRoute(bookingId: String): String = "client_escrow_tracker/$bookingId"

    /** Creates a chat detail route with the given chat ID. */
    fun chatDetailRoute(chatId: String): String = "client_chat_detail/$chatId"
}

// ─── Navigation Graph ────────────────────────────────────────────────────────

/**
 * Navigation graph that maps each route to its parent/back route.
 *
 * Every screen has a defined back-navigation path leading to a root screen,
 * ensuring no dead-end screens exist. Root screens (Dashboard/Home) return null,
 * indicating exit confirmation should be shown.
 */
object NavigationGraph {

    /**
     * Maps each route to its back/parent route.
     * A null value indicates the route is a root screen (exit confirmation on back).
     */
    private val backNavigationMap: Map<String, String?> = mapOf(
        // ─── Admin App ───────────────────────────────────────────
        AdminRoutes.LOGIN to null,
        AdminRoutes.DASHBOARD to null, // Root screen — exit confirmation
        AdminRoutes.VENDOR_LIST to AdminRoutes.DASHBOARD,
        AdminRoutes.VENDOR_EDIT to AdminRoutes.VENDOR_LIST,
        AdminRoutes.VENDOR_ONBOARDING to AdminRoutes.VENDOR_LIST,
        AdminRoutes.VENDOR_APPROVAL to AdminRoutes.VENDOR_LIST,
        AdminRoutes.COMMISSION_CONFIG to AdminRoutes.VENDOR_LIST,
        AdminRoutes.CRM_CONTACTS to AdminRoutes.DASHBOARD,
        AdminRoutes.CRM_INTERACTIONS to AdminRoutes.CRM_CONTACTS,
        AdminRoutes.CATEGORIES to AdminRoutes.DASHBOARD,
        AdminRoutes.CATEGORY_BUILDER to AdminRoutes.CATEGORIES,
        AdminRoutes.BOOKING_LIST to AdminRoutes.DASHBOARD,
        AdminRoutes.ANALYTICS to AdminRoutes.DASHBOARD,

        // ─── Vendor App ──────────────────────────────────────────
        VendorRoutes.LOGIN to null,
        VendorRoutes.ONBOARDING to VendorRoutes.LOGIN,
        VendorRoutes.DASHBOARD to null, // Root screen — exit confirmation
        VendorRoutes.BOOKINGS to VendorRoutes.DASHBOARD,
        VendorRoutes.BOOKING_DETAIL to VendorRoutes.BOOKINGS,
        VendorRoutes.EARNINGS to VendorRoutes.DASHBOARD,
        VendorRoutes.CALENDAR to VendorRoutes.DASHBOARD,
        VendorRoutes.PROFILE to VendorRoutes.DASHBOARD,
        VendorRoutes.PROFILE_EDIT to VendorRoutes.PROFILE,
        VendorRoutes.REVIEWS to VendorRoutes.DASHBOARD,

        // ─── Client App ──────────────────────────────────────────
        ClientRoutes.LOGIN to null,
        ClientRoutes.OTP_VERIFICATION to ClientRoutes.LOGIN,
        ClientRoutes.ONBOARDING to null, // Cannot go back from onboarding
        ClientRoutes.HOME to null, // Root screen — exit confirmation
        ClientRoutes.SEARCH to ClientRoutes.HOME,
        ClientRoutes.VENDOR_DETAIL to ClientRoutes.SEARCH,
        ClientRoutes.BOOKINGS to ClientRoutes.HOME,
        ClientRoutes.BOOKING_DETAIL to ClientRoutes.BOOKINGS,
        ClientRoutes.BOOKING_CHECKOUT to ClientRoutes.VENDOR_DETAIL,
        ClientRoutes.ESCROW_TRACKER to ClientRoutes.BOOKING_DETAIL,
        ClientRoutes.PROFILE to ClientRoutes.HOME,
        ClientRoutes.WISHLIST to ClientRoutes.HOME,
        ClientRoutes.CART to ClientRoutes.HOME,
        ClientRoutes.CHAT to ClientRoutes.HOME,
        ClientRoutes.CHAT_DETAIL to ClientRoutes.CHAT
    )

    /**
     * Set of all root screens that should show exit confirmation on back press.
     */
    private val rootScreens: Set<String> = setOf(
        AdminRoutes.DASHBOARD,
        VendorRoutes.DASHBOARD,
        ClientRoutes.HOME
    )

    /**
     * Set of authentication and onboarding screens where navigation bars should be hidden.
     */
    val authScreens: Set<String> = setOf(
        AdminRoutes.LOGIN,
        VendorRoutes.LOGIN,
        VendorRoutes.ONBOARDING,
        ClientRoutes.LOGIN,
        ClientRoutes.OTP_VERIFICATION,
        ClientRoutes.ONBOARDING
    )

    /**
     * Returns the back/parent route for the given current route.
     *
     * For parameterized routes (e.g., "admin_vendor_edit/123"), the route template
     * is matched by stripping the parameter segment.
     *
     * @param currentRoute The current screen route (may include path parameters).
     * @return The parent route to navigate back to, or null if the current route
     *         is a root screen (indicating exit confirmation should be shown).
     */
    fun getBackRoute(currentRoute: String): String? {
        // Direct match first
        if (backNavigationMap.containsKey(currentRoute)) {
            return backNavigationMap[currentRoute]
        }

        // Try matching parameterized routes by finding the template
        val templateRoute = findTemplateRoute(currentRoute)
        if (templateRoute != null && backNavigationMap.containsKey(templateRoute)) {
            return backNavigationMap[templateRoute]
        }

        // Unknown route — default to null (treat as root/exit)
        return null
    }

    /**
     * Returns whether the given route is a root screen.
     *
     * Root screens show exit confirmation instead of navigating back.
     *
     * @param route The route to check.
     * @return true if the route is a root screen, false otherwise.
     */
    fun isRootScreen(route: String): Boolean {
        return rootScreens.contains(route)
    }

    /**
     * Returns whether the given route is an authentication or onboarding screen.
     *
     * Auth screens should hide the bottom navigation bar and side drawer.
     *
     * @param route The route to check.
     * @return true if the route is an auth/onboarding screen, false otherwise.
     */
    fun isAuthScreen(route: String): Boolean {
        return authScreens.contains(route)
    }

    /**
     * Parses a deep link URI and returns the corresponding app route.
     *
     * Supported deep link patterns:
     * - gomandap://admin/dashboard → admin_dashboard
     * - gomandap://admin/vendors → admin_vendors
     * - gomandap://admin/vendor/{vendorId} → admin_vendor_edit/{vendorId}
     * - gomandap://vendor/dashboard → vendor_dashboard
     * - gomandap://vendor/bookings → vendor_bookings
     * - gomandap://vendor/booking/{bookingId} → vendor_booking_detail/{bookingId}
     * - gomandap://client/home → client_home
     * - gomandap://client/vendor/{vendorId} → client_vendor_detail/{vendorId}
     * - gomandap://client/booking/{bookingId} → client_booking_detail/{bookingId}
     * - gomandap://client/search → client_search
     *
     * @param uri The deep link URI string to parse.
     * @return The corresponding route string, or null if the URI is not recognized.
     */
    fun getDeepLinkRoute(uri: String): String? {
        val parsed = try {
            Uri.parse(uri)
        } catch (_: Exception) {
            return null
        }

        val scheme = parsed.scheme ?: return null
        if (scheme != DEEP_LINK_SCHEME) return null

        val host = parsed.host ?: return null
        val pathSegments = parsed.pathSegments ?: return null

        return when (host) {
            "admin" -> resolveAdminDeepLink(pathSegments)
            "vendor" -> resolveVendorDeepLink(pathSegments)
            "client" -> resolveClientDeepLink(pathSegments)
            else -> null
        }
    }

    /**
     * Returns all registered routes in the navigation graph.
     */
    fun getAllRoutes(): Set<String> = backNavigationMap.keys

    // ─── Private Helpers ─────────────────────────────────────────

    private const val DEEP_LINK_SCHEME = "gomandap"

    private fun resolveAdminDeepLink(segments: List<String>): String? {
        return when {
            segments.isEmpty() -> AdminRoutes.DASHBOARD
            segments[0] == "dashboard" -> AdminRoutes.DASHBOARD
            segments[0] == "vendors" -> AdminRoutes.VENDOR_LIST
            segments[0] == "vendor" && segments.size >= 2 ->
                AdminRoutes.vendorEditRoute(segments[1])
            segments[0] == "bookings" -> AdminRoutes.BOOKING_LIST
            segments[0] == "crm" -> AdminRoutes.CRM_CONTACTS
            segments[0] == "categories" -> AdminRoutes.CATEGORIES
            segments[0] == "analytics" -> AdminRoutes.ANALYTICS
            else -> null
        }
    }

    private fun resolveVendorDeepLink(segments: List<String>): String? {
        return when {
            segments.isEmpty() -> VendorRoutes.DASHBOARD
            segments[0] == "dashboard" -> VendorRoutes.DASHBOARD
            segments[0] == "bookings" -> VendorRoutes.BOOKINGS
            segments[0] == "booking" && segments.size >= 2 ->
                VendorRoutes.bookingDetailRoute(segments[1])
            segments[0] == "earnings" -> VendorRoutes.EARNINGS
            segments[0] == "calendar" -> VendorRoutes.CALENDAR
            segments[0] == "profile" -> VendorRoutes.PROFILE
            segments[0] == "reviews" -> VendorRoutes.REVIEWS
            else -> null
        }
    }

    private fun resolveClientDeepLink(segments: List<String>): String? {
        return when {
            segments.isEmpty() -> ClientRoutes.HOME
            segments[0] == "home" -> ClientRoutes.HOME
            segments[0] == "search" -> ClientRoutes.SEARCH
            segments[0] == "vendor" && segments.size >= 2 ->
                ClientRoutes.vendorDetailRoute(segments[1])
            segments[0] == "booking" && segments.size >= 2 ->
                ClientRoutes.bookingDetailRoute(segments[1])
            segments[0] == "bookings" -> ClientRoutes.BOOKINGS
            segments[0] == "wishlist" -> ClientRoutes.WISHLIST
            segments[0] == "cart" -> ClientRoutes.CART
            segments[0] == "chat" -> ClientRoutes.CHAT
            segments[0] == "profile" -> ClientRoutes.PROFILE
            else -> null
        }
    }

    /**
     * Attempts to find the route template for a parameterized route.
     *
     * For example, "admin_vendor_edit/abc123" matches template "admin_vendor_edit/{vendorId}".
     */
    private fun findTemplateRoute(actualRoute: String): String? {
        return backNavigationMap.keys.firstOrNull { template ->
            matchesTemplate(template, actualRoute)
        }
    }

    /**
     * Checks if an actual route matches a template route with path parameters.
     *
     * A template like "admin_vendor_edit/{vendorId}" matches "admin_vendor_edit/abc123".
     */
    private fun matchesTemplate(template: String, actual: String): Boolean {
        if (template == actual) return true
        if (!template.contains("{")) return false

        val templateParts = template.split("/")
        val actualParts = actual.split("/")

        if (templateParts.size != actualParts.size) return false

        return templateParts.zip(actualParts).all { (tPart, aPart) ->
            tPart == aPart || (tPart.startsWith("{") && tPart.endsWith("}"))
        }
    }
}
