package com.gomandap.app.presentation.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily

// ─── GoMandap Color Tokens ───────────────────────────────────────────────────
val RoyalNavy        = Color(0xFF0F172A)   // Primary luxury
val EmeraldGreen     = Color(0xFF10B981)   // CTA / verified / success
val ChampagneGold    = Color(0xFFDFBA73)   // Celebratory accent
val DarkGold         = Color(0xFFC59A48)   // Dark variant of gold
val PearlWhite       = Color(0xFFF8F9FA)   // Neutral bg
val CreamBg          = Color(0xFFFBFAEE)   // Alt warm bg
val SlateGray        = Color(0xFF64748B)   // Secondary text
val LightSlate       = Color(0xFFE2E8F0)   // Dividers / placeholders
val RoseRed          = Color(0xFFE11D48)   // Heart / urgency
val ShimmerBase      = Color(0xFFEEEEEE)
val ShimmerHighlight = Color(0xFFF5E3B5)
val SoftMist         = Color(0xFFF1F5F9)
val DeepSky          = Color(0xFF1E3A5F)
val WarmPeach        = Color(0xFFFFE5D1)
// Legacy alias kept for backward compat with existing screens:
val LightGrayBg      = PearlWhite          // same as PearlWhite #F8F9FA

private val GomandapColorScheme = lightColorScheme(
    primary          = RoyalNavy,
    onPrimary        = Color.White,
    secondary        = EmeraldGreen,
    onSecondary      = Color.White,
    tertiary         = ChampagneGold,
    background       = SoftMist,
    onBackground     = RoyalNavy,
    surface          = Color.White,
    onSurface        = RoyalNavy,
    surfaceVariant   = CreamBg,
    outline          = LightSlate,
    error            = RoseRed
)

private val GomandapTypography = Typography().copy(
    displayLarge = Typography().displayLarge.copy(fontFamily = FontFamily.SansSerif),
    displayMedium = Typography().displayMedium.copy(fontFamily = FontFamily.SansSerif),
    displaySmall = Typography().displaySmall.copy(fontFamily = FontFamily.SansSerif),
    headlineLarge = Typography().headlineLarge.copy(fontFamily = FontFamily.SansSerif),
    headlineMedium = Typography().headlineMedium.copy(fontFamily = FontFamily.SansSerif),
    headlineSmall = Typography().headlineSmall.copy(fontFamily = FontFamily.SansSerif),
    titleLarge = Typography().titleLarge.copy(fontFamily = FontFamily.SansSerif),
    titleMedium = Typography().titleMedium.copy(fontFamily = FontFamily.SansSerif),
    titleSmall = Typography().titleSmall.copy(fontFamily = FontFamily.SansSerif),
    bodyLarge = Typography().bodyLarge.copy(fontFamily = FontFamily.SansSerif),
    bodyMedium = Typography().bodyMedium.copy(fontFamily = FontFamily.SansSerif),
    bodySmall = Typography().bodySmall.copy(fontFamily = FontFamily.SansSerif),
    labelLarge = Typography().labelLarge.copy(fontFamily = FontFamily.SansSerif),
    labelMedium = Typography().labelMedium.copy(fontFamily = FontFamily.SansSerif),
    labelSmall = Typography().labelSmall.copy(fontFamily = FontFamily.SansSerif)
)

@Composable
fun GomandapTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = GomandapColorScheme,
        typography = GomandapTypography,
        content = content
    )
}
