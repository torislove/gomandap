package com.gomandap.common.design

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

/**
 * Single source of truth for all GoMandap design tokens.
 * Shared across Admin, Vendor, and Client apps.
 */
object GomandapTokens {

    // ─── Color Palette ───────────────────────────────────────────────
    object Colors {
        // Primary
        val royalNavy = Color(0xFF0F172A)
        val royalNavyLight = Color(0xFF1E293B)
        val royalNavySurface = Color(0xFF334155)

        // Accent
        val champagneGold = Color(0xFFDFBA73)
        val champagneGoldLight = Color(0xFFF5E6C8)
        val champagneGoldDark = Color(0xFFC59A48)

        // Success / CTA
        val emeraldGreen = Color(0xFF10B981)
        val emeraldGreenLight = Color(0xFFD1FAE5)
        val emeraldGreenDark = Color(0xFF059669)

        // Neutrals
        val pearlWhite = Color(0xFFF8F9FA)
        val softMist = Color(0xFFF1F5F9)
        val slateGray = Color(0xFF64748B)
        val lightSlate = Color(0xFFE2E8F0)

        // Semantic
        val error = Color(0xFFEF4444)
        val errorLight = Color(0xFFFEE2E2)
        val warning = Color(0xFFF59E0B)
        val warningLight = Color(0xFFFEF3C7)
        val info = Color(0xFF3B82F6)
        val infoLight = Color(0xFFDBEAFE)
    }

    // ─── Typography Scale ────────────────────────────────────────────
    object Typography {
        // Display: Splash, hero sections
        val displayLarge = TextStyle(
            fontSize = 36.sp,
            fontWeight = FontWeight.Black,
            letterSpacing = (-0.5).sp
        )
        val displayMedium = TextStyle(
            fontSize = 28.sp,
            fontWeight = FontWeight.Black,
            letterSpacing = (-0.25).sp
        )

        // Headings: Section titles, screen titles
        val headlineLarge = TextStyle(
            fontSize = 24.sp,
            fontWeight = FontWeight.Bold
        )
        val headlineMedium = TextStyle(
            fontSize = 20.sp,
            fontWeight = FontWeight.Bold
        )
        val headlineSmall = TextStyle(
            fontSize = 16.sp,
            fontWeight = FontWeight.SemiBold
        )

        // Body: Content, descriptions
        val bodyLarge = TextStyle(
            fontSize = 16.sp,
            fontWeight = FontWeight.Normal,
            lineHeight = 24.sp
        )
        val bodyMedium = TextStyle(
            fontSize = 14.sp,
            fontWeight = FontWeight.Normal,
            lineHeight = 20.sp
        )
        val bodySmall = TextStyle(
            fontSize = 12.sp,
            fontWeight = FontWeight.Normal,
            lineHeight = 16.sp
        )

        // Labels: Buttons, tags, badges
        val labelLarge = TextStyle(
            fontSize = 14.sp,
            fontWeight = FontWeight.SemiBold
        )
        val labelMedium = TextStyle(
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium
        )
        val labelSmall = TextStyle(
            fontSize = 10.sp,
            fontWeight = FontWeight.Medium
        )
    }

    // ─── Spacing Scale ───────────────────────────────────────────────
    object Spacing {
        val xxs = 4.dp
        val xs = 8.dp
        val sm = 12.dp
        val md = 16.dp
        val lg = 20.dp
        val xl = 24.dp
        val xxl = 32.dp
        val xxxl = 48.dp
    }

    // ─── Elevation ───────────────────────────────────────────────────
    object Elevation {
        val none = 0.dp
        val low = 1.dp
        val medium = 4.dp
        val high = 8.dp
        val overlay = 16.dp
    }

    // ─── Shapes ──────────────────────────────────────────────────────
    object Shapes {
        val small = RoundedCornerShape(8.dp)
        val medium = RoundedCornerShape(12.dp)
        val large = RoundedCornerShape(16.dp)
        val extraLarge = RoundedCornerShape(24.dp)
        val pill = RoundedCornerShape(50)
    }
}
