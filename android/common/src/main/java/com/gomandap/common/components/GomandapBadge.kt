package com.gomandap.common.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Badge variant options for the GoMandap design system.
 */
enum class BadgeVariant {
    /** Light Slate background, Royal Navy text */
    Default,
    /** Emerald Green Light background, Emerald Green Dark text */
    Success,
    /** Warning Light background, Warning (darkened) text */
    Warning,
    /** Error Light background, Error text */
    Error,
    /** Info Light background, Info text */
    Info,
    /** Champagne Gold Light background, Champagne Gold Dark text */
    Gold
}

/**
 * A pill-shaped badge component for displaying status labels, tags, and categories.
 *
 * @param text The label text displayed inside the badge.
 * @param variant The color variant determining background and text colors.
 * @param icon Optional leading icon displayed before the text.
 */
@Composable
fun GomandapBadge(
    text: String,
    variant: BadgeVariant = BadgeVariant.Default,
    icon: ImageVector? = null
) {
    val (backgroundColor, contentColor) = variantColors(variant)

    Row(
        modifier = Modifier
            .clip(RoundedCornerShape(50))
            .background(backgroundColor)
            .padding(
                horizontal = GomandapTokens.Spacing.xs,
                vertical = GomandapTokens.Spacing.xxs
            ),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (icon != null) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier
                    .size(14.dp)
                    .padding(end = GomandapTokens.Spacing.xxs),
                tint = contentColor
            )
        }

        Text(
            text = text,
            style = GomandapTokens.Typography.labelMedium,
            color = contentColor,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )
    }
}

/**
 * Returns the background and content (text/icon) color pair for a given badge variant.
 */
private fun variantColors(variant: BadgeVariant): Pair<Color, Color> {
    return when (variant) {
        BadgeVariant.Default -> GomandapTokens.Colors.lightSlate to GomandapTokens.Colors.royalNavy
        BadgeVariant.Success -> GomandapTokens.Colors.emeraldGreenLight to GomandapTokens.Colors.emeraldGreenDark
        BadgeVariant.Warning -> GomandapTokens.Colors.warningLight to GomandapTokens.Colors.warning
        BadgeVariant.Error -> GomandapTokens.Colors.errorLight to GomandapTokens.Colors.error
        BadgeVariant.Info -> GomandapTokens.Colors.infoLight to GomandapTokens.Colors.info
        BadgeVariant.Gold -> GomandapTokens.Colors.champagneGoldLight to GomandapTokens.Colors.champagneGoldDark
    }
}
