package com.gomandap.app.presentation.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

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
val LightGrayBg      = PearlWhite
val SoftMist         = Color(0xFFF4F7FB)

private val GomandapColorScheme = lightColorScheme(
    primary          = RoyalNavy,
    onPrimary        = Color.White,
    secondary        = EmeraldGreen,
    onSecondary      = Color.White,
    tertiary         = ChampagneGold,
    background       = PearlWhite,
    onBackground     = RoyalNavy,
    surface          = Color.White,
    onSurface        = RoyalNavy,
    surfaceVariant   = CreamBg,
    outline          = LightSlate,
    error            = RoseRed
)

@Composable
fun GomandapTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = GomandapColorScheme,
        content     = content
    )
}
