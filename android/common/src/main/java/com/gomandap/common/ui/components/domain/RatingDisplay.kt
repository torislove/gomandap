package com.gomandap.common.ui.components.domain

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarHalf
import androidx.compose.material.icons.outlined.StarOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Variants for the RatingDisplay component.
 */
enum class RatingVariant {
    /** Just the numeric rating (e.g., "4.5") with a small star icon, in labelMedium style. */
    Compact,
    /** Rating number + star icon + "(123 reviews)" text. */
    Expanded,
    /** 5 star icons (filled/half/unfilled based on rating value) + review count. */
    Stars
}

/**
 * A composable that displays a rating in one of three variants.
 *
 * - [RatingVariant.Compact]: Numeric rating with a small star icon using labelMedium typography.
 * - [RatingVariant.Expanded]: Rating number + star icon + "(Y reviews)" text.
 * - [RatingVariant.Stars]: 5 star icons (filled, half-filled, or unfilled) + review count.
 *
 * Star colors use champagneGold for filled and lightSlate for unfilled.
 * The component includes an accessibility content description:
 * "X out of 5 stars, Y reviews".
 *
 * @param rating The rating value from 0 to 5.
 * @param reviewCount The number of reviews.
 * @param variant The display variant to use.
 * @param modifier Modifier to be applied to the component.
 */
@Composable
fun RatingDisplay(
    rating: Float,
    reviewCount: Int,
    variant: RatingVariant = RatingVariant.Compact,
    modifier: Modifier = Modifier
) {
    val clampedRating = rating.coerceIn(0f, 5f)
    val accessibilityDescription = "$clampedRating out of 5 stars, $reviewCount reviews"

    Row(
        modifier = modifier.semantics {
            contentDescription = accessibilityDescription
        },
        verticalAlignment = Alignment.CenterVertically
    ) {
        when (variant) {
            RatingVariant.Compact -> CompactRating(clampedRating)
            RatingVariant.Expanded -> ExpandedRating(clampedRating, reviewCount)
            RatingVariant.Stars -> StarsRating(clampedRating, reviewCount)
        }
    }
}

@Composable
private fun CompactRating(rating: Float) {
    Text(
        text = formatRating(rating),
        style = GomandapTokens.Typography.labelMedium,
        color = GomandapTokens.Colors.royalNavy
    )
    Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xxs))
    Icon(
        imageVector = Icons.Filled.Star,
        contentDescription = null,
        modifier = Modifier.size(14.dp),
        tint = GomandapTokens.Colors.champagneGold
    )
}

@Composable
private fun ExpandedRating(rating: Float, reviewCount: Int) {
    Text(
        text = formatRating(rating),
        style = GomandapTokens.Typography.headlineSmall,
        color = GomandapTokens.Colors.royalNavy
    )
    Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xxs))
    Icon(
        imageVector = Icons.Filled.Star,
        contentDescription = null,
        modifier = Modifier.size(18.dp),
        tint = GomandapTokens.Colors.champagneGold
    )
    Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xs))
    Text(
        text = "($reviewCount reviews)",
        style = GomandapTokens.Typography.bodySmall,
        color = GomandapTokens.Colors.slateGray
    )
}

@Composable
private fun StarsRating(rating: Float, reviewCount: Int) {
    val fullStars = rating.toInt()
    val hasHalfStar = (rating - fullStars) >= 0.5f
    val emptyStars = 5 - fullStars - if (hasHalfStar) 1 else 0

    repeat(fullStars) {
        Icon(
            imageVector = Icons.Filled.Star,
            contentDescription = null,
            modifier = Modifier.size(18.dp),
            tint = GomandapTokens.Colors.champagneGold
        )
    }
    if (hasHalfStar) {
        Icon(
            imageVector = Icons.Filled.StarHalf,
            contentDescription = null,
            modifier = Modifier.size(18.dp),
            tint = GomandapTokens.Colors.champagneGold
        )
    }
    repeat(emptyStars) {
        Icon(
            imageVector = Icons.Outlined.StarOutline,
            contentDescription = null,
            modifier = Modifier.size(18.dp),
            tint = GomandapTokens.Colors.lightSlate
        )
    }
    Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xs))
    Text(
        text = "($reviewCount)",
        style = GomandapTokens.Typography.bodySmall,
        color = GomandapTokens.Colors.slateGray
    )
}

/**
 * Formats the rating value for display.
 * Shows one decimal place if the rating has a fractional part, otherwise shows as integer.
 */
private fun formatRating(rating: Float): String {
    return if (rating == rating.toInt().toFloat()) {
        rating.toInt().toString()
    } else {
        String.format("%.1f", rating)
    }
}
