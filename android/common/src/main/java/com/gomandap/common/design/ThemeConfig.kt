package com.gomandap.common.design

import androidx.compose.ui.graphics.Color

/**
 * Theme mode options for the GoMandap design system.
 */
enum class ThemeMode {
    Light,
    Dark,
    System
}

/**
 * Configuration for the GoMandap theme.
 *
 * @property mode The theme mode (Light, Dark, or System).
 * @property brandAccent The brand accent color used for highlights.
 * @property primaryAction The primary action color used for CTAs.
 * @property fontScale The font scale multiplier. Must be between 0.8 and 1.4; defaults to 1.0 if outside range.
 * @property hapticEnabled Whether haptic feedback is enabled on interactions.
 * @property animationsEnabled Whether decorative animations are enabled.
 */
data class ThemeConfig(
    val mode: ThemeMode = ThemeMode.Light,
    val brandAccent: Color = GomandapTokens.Colors.champagneGold,
    val primaryAction: Color = GomandapTokens.Colors.emeraldGreen,
    val fontScale: Float = 1.0f,
    val hapticEnabled: Boolean = true,
    val animationsEnabled: Boolean = true
) {
    init {
        require(fontScale in FONT_SCALE_MIN..FONT_SCALE_MAX) {
            "fontScale must be between $FONT_SCALE_MIN and $FONT_SCALE_MAX, got $fontScale"
        }
    }

    companion object {
        const val FONT_SCALE_MIN = 0.8f
        const val FONT_SCALE_MAX = 1.4f
        const val FONT_SCALE_DEFAULT = 1.0f

        /**
         * Creates a ThemeConfig with validated font scale.
         * If the provided fontScale is outside the valid range [0.8, 1.4],
         * it defaults to 1.0 and logs a warning.
         */
        fun createWithValidation(
            mode: ThemeMode = ThemeMode.Light,
            brandAccent: Color = GomandapTokens.Colors.champagneGold,
            primaryAction: Color = GomandapTokens.Colors.emeraldGreen,
            fontScale: Float = FONT_SCALE_DEFAULT,
            hapticEnabled: Boolean = true,
            animationsEnabled: Boolean = true
        ): ThemeConfig {
            val validatedScale = if (fontScale in FONT_SCALE_MIN..FONT_SCALE_MAX) {
                fontScale
            } else {
                android.util.Log.w(
                    "ThemeConfig",
                    "fontScale $fontScale is outside valid range [$FONT_SCALE_MIN, $FONT_SCALE_MAX]. Defaulting to $FONT_SCALE_DEFAULT."
                )
                FONT_SCALE_DEFAULT
            }
            return ThemeConfig(
                mode = mode,
                brandAccent = brandAccent,
                primaryAction = primaryAction,
                fontScale = validatedScale,
                hapticEnabled = hapticEnabled,
                animationsEnabled = animationsEnabled
            )
        }
    }
}
