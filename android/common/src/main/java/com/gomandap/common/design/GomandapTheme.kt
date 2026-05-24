package com.gomandap.common.design

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily

/**
 * GoMandap Design System Theme.
 *
 * Single entry-point theme composable shared across Admin, Vendor, and Client apps.
 * Uses [GomandapTokens] as the source of truth for all color values.
 */

private val GomandapColorScheme = lightColorScheme(
    primary          = GomandapTokens.Colors.royalNavy,
    onPrimary        = Color.White,
    secondary        = GomandapTokens.Colors.emeraldGreen,
    onSecondary      = Color.White,
    tertiary         = GomandapTokens.Colors.champagneGold,
    background       = GomandapTokens.Colors.softMist,
    onBackground     = GomandapTokens.Colors.royalNavy,
    surface          = Color.White,
    onSurface        = GomandapTokens.Colors.royalNavy,
    surfaceVariant   = GomandapTokens.Colors.pearlWhite,
    outline          = GomandapTokens.Colors.lightSlate,
    error            = GomandapTokens.Colors.error
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
