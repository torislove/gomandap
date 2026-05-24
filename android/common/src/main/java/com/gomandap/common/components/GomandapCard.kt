package com.gomandap.common.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Card variant options for the GoMandap design system.
 */
enum class CardVariant {
    /** Pearl White background, medium elevation (4dp), medium shape (12dp corners) */
    Elevated,
    /** Pearl White background, no elevation, 1dp lightSlate border, medium shape */
    Outlined,
    /** Soft Mist background, no elevation, medium shape */
    Filled,
    /** Pearl White with 0.85f alpha background, low elevation (1dp), medium shape */
    Glass
}

/**
 * A card component for the GoMandap design system.
 *
 * Supports 4 variants: Elevated, Outlined, Filled, and Glass.
 * When [onClick] is provided, the card becomes clickable with a ripple effect
 * and ensures a minimum touch target of 48dp × 48dp.
 *
 * All cards use [GomandapTokens.Spacing.md] (16dp) for content padding
 * and [GomandapTokens.Shapes.medium] (12dp corners) for shape.
 *
 * @param modifier Modifier to be applied to the card.
 * @param variant The visual variant of the card.
 * @param onClick Optional click handler. When provided, the card becomes clickable with ripple.
 * @param content The content to display inside the card, scoped to [ColumnScope].
 */
@Composable
fun GomandapCard(
    modifier: Modifier = Modifier,
    variant: CardVariant = CardVariant.Elevated,
    onClick: (() -> Unit)? = null,
    content: @Composable ColumnScope.() -> Unit
) {
    val shape = GomandapTokens.Shapes.medium
    val contentPadding = GomandapTokens.Spacing.md

    val colors = when (variant) {
        CardVariant.Elevated -> CardDefaults.cardColors(
            containerColor = GomandapTokens.Colors.pearlWhite
        )
        CardVariant.Outlined -> CardDefaults.cardColors(
            containerColor = GomandapTokens.Colors.pearlWhite
        )
        CardVariant.Filled -> CardDefaults.cardColors(
            containerColor = GomandapTokens.Colors.softMist
        )
        CardVariant.Glass -> CardDefaults.cardColors(
            containerColor = GomandapTokens.Colors.pearlWhite.copy(alpha = 0.85f)
        )
    }

    val elevation = when (variant) {
        CardVariant.Elevated -> CardDefaults.cardElevation(
            defaultElevation = GomandapTokens.Elevation.medium
        )
        CardVariant.Outlined -> CardDefaults.cardElevation(
            defaultElevation = GomandapTokens.Elevation.none
        )
        CardVariant.Filled -> CardDefaults.cardElevation(
            defaultElevation = GomandapTokens.Elevation.none
        )
        CardVariant.Glass -> CardDefaults.cardElevation(
            defaultElevation = GomandapTokens.Elevation.low
        )
    }

    val border = when (variant) {
        CardVariant.Outlined -> BorderStroke(
            width = 1.dp,
            color = GomandapTokens.Colors.lightSlate
        )
        else -> null
    }

    // Ensure minimum touch target of 48dp for clickable cards
    val touchTargetModifier = if (onClick != null) {
        modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)
    } else {
        modifier
    }

    if (onClick != null) {
        Card(
            onClick = onClick,
            modifier = touchTargetModifier,
            shape = shape,
            colors = colors,
            elevation = elevation,
            border = border
        ) {
            Column(
                modifier = Modifier.padding(contentPadding),
                content = content
            )
        }
    } else {
        Card(
            modifier = touchTargetModifier,
            shape = shape,
            colors = colors,
            elevation = elevation,
            border = border
        ) {
            Column(
                modifier = Modifier.padding(contentPadding),
                content = content
            )
        }
    }
}
