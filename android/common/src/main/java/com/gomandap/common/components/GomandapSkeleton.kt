package com.gomandap.common.components

import androidx.compose.animation.core.RepeatMode
import androidx.compose.animation.core.animateFloat
import androidx.compose.animation.core.infiniteRepeatable
import androidx.compose.animation.core.rememberInfiniteTransition
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.lerp
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Base skeleton loader component for the GoMandap design system.
 *
 * Displays a shimmer/pulse animation placeholder that animates between
 * a base color (lightSlate) and a highlight color (softMist) using an
 * infinite transition with ease-in-out easing.
 *
 * The component fills the size specified by the [modifier] and clips
 * to the provided [shape].
 *
 * @param modifier Modifier to specify size and layout of the skeleton.
 * @param shape The shape to clip the skeleton to. Defaults to [GomandapTokens.Shapes.medium].
 */
@Composable
fun GomandapSkeleton(
    modifier: Modifier = Modifier,
    shape: Shape = GomandapTokens.Shapes.medium
) {
    val shimmerColor = rememberShimmerColor()

    Box(
        modifier = modifier
            .clip(shape)
            .background(shimmerColor)
    )
}

/**
 * Convenience skeleton composable that renders multiple text-like skeleton lines
 * with varying widths to simulate a text block loading state.
 *
 * Line widths follow the pattern:
 * - All lines except the last: 100% width
 * - Second-to-last line (if more than 2 lines): 80% width
 * - Last line: 60% width
 *
 * @param lines The number of skeleton text lines to display.
 * @param modifier Modifier to be applied to the containing column.
 */
@Composable
fun GomandapSkeletonText(
    lines: Int,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        repeat(lines) { index ->
            val widthFraction = when {
                lines == 1 -> 0.6f
                index == lines - 1 -> 0.6f
                index == lines - 2 && lines > 2 -> 0.8f
                else -> 1f
            }

            GomandapSkeleton(
                modifier = Modifier
                    .fillMaxWidth(widthFraction)
                    .height(12.dp),
                shape = GomandapTokens.Shapes.small
            )

            if (index < lines - 1) {
                Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))
            }
        }
    }
}

/**
 * Convenience skeleton composable that renders a circular skeleton placeholder.
 *
 * Useful for avatar or profile image loading states.
 *
 * @param size The diameter of the circular skeleton.
 * @param modifier Modifier to be applied to the skeleton.
 */
@Composable
fun GomandapSkeletonCircle(
    size: Dp,
    modifier: Modifier = Modifier
) {
    GomandapSkeleton(
        modifier = modifier.size(size),
        shape = CircleShape
    )
}

/**
 * Convenience skeleton composable that renders a card-shaped skeleton
 * with an image area at the top and text lines below, simulating a
 * typical content card loading state.
 *
 * Layout:
 * - Image area: full width, 120dp height, medium rounded shape
 * - Below image: 3 text skeleton lines with varying widths
 *
 * @param modifier Modifier to be applied to the card skeleton container.
 */
@Composable
fun GomandapSkeletonCard(
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        // Image area placeholder
        GomandapSkeleton(
            modifier = Modifier
                .fillMaxWidth()
                .height(120.dp),
            shape = GomandapTokens.Shapes.medium
        )

        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.sm))

        // Text lines placeholder
        GomandapSkeletonText(
            lines = 3,
            modifier = Modifier.fillMaxWidth()
        )
    }
}

/**
 * Remembers and returns the current shimmer animation color that pulses
 * between lightSlate (base) and softMist (highlight) with a 1000ms
 * ease-in-out infinite transition.
 */
@Composable
private fun rememberShimmerColor(): Color {
    val infiniteTransition = rememberInfiniteTransition(label = "skeleton_shimmer")

    val animationProgress by infiniteTransition.animateFloat(
        initialValue = 0f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(
                durationMillis = 1000,
                easing = androidx.compose.animation.core.FastOutSlowInEasing
            ),
            repeatMode = RepeatMode.Reverse
        ),
        label = "skeleton_shimmer_alpha"
    )

    return lerp(
        GomandapTokens.Colors.lightSlate,
        GomandapTokens.Colors.softMist,
        animationProgress
    )
}
