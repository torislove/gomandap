package com.gomandap.common.ui.security

import android.view.WindowManager
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.ui.platform.LocalView

/**
 * Set of route patterns identifying screens that display sensitive data
 * (vendor financial data, contact details, commission configuration, bank details, or PII).
 *
 * FLAG_SECURE should be applied on these screens to prevent screenshots and screen recording.
 *
 * Routes are matched using [isSensitiveRoute] which checks if the current route
 * contains any of these patterns (case-insensitive).
 */
val SENSITIVE_SCREEN_ROUTES: Set<String> = setOf(
    // Vendor financial data screens
    "vendor_edit",
    "vendor_financial",
    "vendor_bank",
    "vendor_payout",
    "earnings",
    // Vendor contact details screens
    "vendor_contact",
    "crm_contacts",
    "crm_interactions",
    // Commission configuration
    "commission",
    // Screens showing bank details or PII
    "bank_details",
    "escrow",
    "payment",
    "pii"
)

/**
 * Determines whether the given route corresponds to a sensitive screen
 * that should have FLAG_SECURE applied.
 *
 * @param route The current navigation route string.
 * @return `true` if the route is a sensitive screen, `false` otherwise.
 */
fun isSensitiveRoute(route: String?): Boolean {
    if (route.isNullOrBlank()) return false
    val routeLower = route.lowercase()
    return SENSITIVE_SCREEN_ROUTES.any { pattern ->
        routeLower.contains(pattern)
    }
}

/**
 * Composable effect that sets FLAG_SECURE on the current window when it enters
 * composition and clears it when it leaves composition.
 *
 * This prevents screenshots and screen recording on the screen where this effect is active.
 *
 * Usage:
 * ```kotlin
 * @Composable
 * fun VendorFinancialScreen() {
 *     SecureScreenEffect()
 *     // ... screen content
 * }
 * ```
 */
@Composable
fun SecureScreenEffect() {
    val view = LocalView.current
    DisposableEffect(view) {
        val window = (view.context as? android.app.Activity)?.window
        window?.addFlags(WindowManager.LayoutParams.FLAG_SECURE)

        onDispose {
            window?.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}

/**
 * Composable effect that conditionally applies FLAG_SECURE based on the current route.
 *
 * This can be placed at the navigation level to automatically secure sensitive screens
 * without requiring each screen to manually include [SecureScreenEffect].
 *
 * @param currentRoute The current navigation route. If it matches a sensitive route pattern,
 *                     FLAG_SECURE will be applied.
 */
@Composable
fun SecureScreenForRoute(currentRoute: String?) {
    if (isSensitiveRoute(currentRoute)) {
        SecureScreenEffect()
    }
}
