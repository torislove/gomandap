package com.gomandap.common.ui.components.domain

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.TrendingDown
import androidx.compose.material.icons.filled.TrendingUp
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.gomandap.common.components.CardVariant
import com.gomandap.common.components.GomandapCard
import com.gomandap.common.design.GomandapTokens

/**
 * Represents the direction of a trend indicator.
 */
enum class TrendDirection { Up, Down, Neutral }

/**
 * A stat card component for dashboard grids (2-column layout).
 *
 * Displays a title, numeric value, optional subtitle, optional trend indicator,
 * and optional icon with accent color background circle.
 *
 * Uses [GomandapCard] with [CardVariant.Filled] as the container.
 *
 * @param title The label for the stat (max 40 characters recommended).
 * @param value The numeric or string value to display prominently.
 * @param subtitle Optional secondary text below the value.
 * @param trend Optional trend direction indicator (Up, Down, Neutral).
 * @param trendValue Optional text to display alongside the trend icon (e.g., "+12%").
 * @param icon Optional icon displayed in the top-left with accent color background.
 * @param accentColor The accent color for the icon background and trend up indicator.
 */
@Composable
fun StatCard(
    title: String,
    value: String,
    subtitle: String? = null,
    trend: TrendDirection? = null,
    trendValue: String? = null,
    icon: ImageVector? = null,
    accentColor: Color = GomandapTokens.Colors.emeraldGreen,
    modifier: Modifier = Modifier
) {
    GomandapCard(
        modifier = modifier,
        variant = CardVariant.Filled
    ) {
        // Optional icon with accent color background circle
        if (icon != null) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .background(
                        color = accentColor.copy(alpha = 0.12f),
                        shape = CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = accentColor,
                    modifier = Modifier.size(20.dp)
                )
            }
            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))
        }

        // Title: labelMedium, slateGray
        Text(
            text = title,
            style = GomandapTokens.Typography.labelMedium,
            color = GomandapTokens.Colors.slateGray,
            maxLines = 1
        )

        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xxs))

        // Value: headlineLarge, royalNavy, bold
        Text(
            text = value,
            style = GomandapTokens.Typography.headlineLarge.copy(
                fontWeight = FontWeight.Bold
            ),
            color = GomandapTokens.Colors.royalNavy,
            maxLines = 1
        )

        // Subtitle: bodySmall, slateGray
        if (subtitle != null) {
            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xxs))
            Text(
                text = subtitle,
                style = GomandapTokens.Typography.bodySmall,
                color = GomandapTokens.Colors.slateGray,
                maxLines = 1
            )
        }

        // Trend indicator
        if (trend != null) {
            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Start
            ) {
                val trendColor = when (trend) {
                    TrendDirection.Up -> GomandapTokens.Colors.emeraldGreen
                    TrendDirection.Down -> GomandapTokens.Colors.error
                    TrendDirection.Neutral -> GomandapTokens.Colors.slateGray
                }

                val trendIcon = when (trend) {
                    TrendDirection.Up -> Icons.Filled.TrendingUp
                    TrendDirection.Down -> Icons.Filled.TrendingDown
                    TrendDirection.Neutral -> Icons.Filled.Remove
                }

                Icon(
                    imageVector = trendIcon,
                    contentDescription = when (trend) {
                        TrendDirection.Up -> "Trending up"
                        TrendDirection.Down -> "Trending down"
                        TrendDirection.Neutral -> "No change"
                    },
                    tint = trendColor,
                    modifier = Modifier.size(16.dp)
                )

                if (trendValue != null) {
                    Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xxs))
                    Text(
                        text = trendValue,
                        style = GomandapTokens.Typography.labelSmall,
                        color = trendColor,
                        maxLines = 1
                    )
                }
            }
        }
    }
}
