package com.gomandap.common.ui.navigation

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class NavBarVisibilityTest {

    // ── shouldShowBottomNav: Auth screens should hide nav ──────────────────────

    @Test
    fun `login route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("login"))
    }

    @Test
    fun `admin_login route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("admin_login"))
    }

    @Test
    fun `otp route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("otp"))
    }

    @Test
    fun `otp_verification route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("otp_verification"))
    }

    @Test
    fun `register route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("register"))
    }

    @Test
    fun `signup route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("signup"))
    }

    @Test
    fun `onboarding_category route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("onboarding_category"))
    }

    @Test
    fun `onboarding_date route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("onboarding_date"))
    }

    @Test
    fun `vendor_onboarding route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("vendor_onboarding"))
    }

    @Test
    fun `forgot_password route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("forgot_password"))
    }

    @Test
    fun `reset_password route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("reset_password"))
    }

    @Test
    fun `verify route hides bottom nav`() {
        assertFalse(shouldShowBottomNav("verify"))
    }

    // ── shouldShowBottomNav: Non-auth screens should show nav ──────────────────

    @Test
    fun `home route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("home"))
    }

    @Test
    fun `dashboard route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("dashboard"))
    }

    @Test
    fun `admin_dashboard route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("admin_dashboard"))
    }

    @Test
    fun `bookings route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("bookings"))
    }

    @Test
    fun `profile route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("profile"))
    }

    @Test
    fun `search route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("search"))
    }

    @Test
    fun `vendor_details route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("vendor_details/123"))
    }

    @Test
    fun `earnings route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("earnings"))
    }

    @Test
    fun `calendar route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("calendar"))
    }

    // ── shouldShowBottomNav: Edge cases ───────────────────────────────────────

    @Test
    fun `null route shows bottom nav`() {
        assertTrue(shouldShowBottomNav(null))
    }

    @Test
    fun `empty route shows bottom nav`() {
        assertTrue(shouldShowBottomNav(""))
    }

    @Test
    fun `blank route shows bottom nav`() {
        assertTrue(shouldShowBottomNav("   "))
    }

    @Test
    fun `case insensitive matching - LOGIN hides bottom nav`() {
        assertFalse(shouldShowBottomNav("LOGIN"))
    }

    @Test
    fun `case insensitive matching - Onboarding hides bottom nav`() {
        assertFalse(shouldShowBottomNav("Onboarding_Step1"))
    }

    // ── isAuthOrOnboardingRoute ───────────────────────────────────────────────

    @Test
    fun `isAuthOrOnboardingRoute returns true for login`() {
        assertTrue(isAuthOrOnboardingRoute("login"))
    }

    @Test
    fun `isAuthOrOnboardingRoute returns false for home`() {
        assertFalse(isAuthOrOnboardingRoute("home"))
    }

    @Test
    fun `isAuthOrOnboardingRoute returns false for null`() {
        assertFalse(isAuthOrOnboardingRoute(null))
    }

    // ── NavBarVisibilityState ─────────────────────────────────────────────────

    @Test
    fun `NavBarVisibilityState defaults to visible`() {
        val state = NavBarVisibilityState()
        assertTrue(state.isVisible.value)
    }

    @Test
    fun `NavBarVisibilityState hide sets invisible`() {
        val state = NavBarVisibilityState()
        state.hide()
        assertFalse(state.isVisible.value)
    }

    @Test
    fun `NavBarVisibilityState show sets visible`() {
        val state = NavBarVisibilityState()
        state.hide()
        state.show()
        assertTrue(state.isVisible.value)
    }

    @Test
    fun `NavBarVisibilityState updateForRoute hides on auth route`() {
        val state = NavBarVisibilityState()
        state.updateForRoute("login")
        assertFalse(state.isVisible.value)
    }

    @Test
    fun `NavBarVisibilityState updateForRoute shows on normal route`() {
        val state = NavBarVisibilityState()
        state.hide()
        state.updateForRoute("home")
        assertTrue(state.isVisible.value)
    }

    @Test
    fun `NavBarVisibilityState updateForRoute handles null`() {
        val state = NavBarVisibilityState()
        state.updateForRoute(null)
        assertTrue(state.isVisible.value)
    }

    // ── Works regardless of AppType ───────────────────────────────────────────

    @Test
    fun `admin login route hides nav - app type agnostic`() {
        assertFalse(shouldShowBottomNav("admin_login"))
    }

    @Test
    fun `vendor onboarding route hides nav - app type agnostic`() {
        assertFalse(shouldShowBottomNav("vendor_onboarding_step1"))
    }

    @Test
    fun `client login route hides nav - app type agnostic`() {
        assertFalse(shouldShowBottomNav("client_login"))
    }
}
