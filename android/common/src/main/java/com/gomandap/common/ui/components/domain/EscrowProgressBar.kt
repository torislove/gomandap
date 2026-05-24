package com.gomandap.common.ui.components.domain

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Status of an escrow milestone.
 */
enum class MilestoneStatus {
    Held,
    Released,
    Frozen
}

/**
 * Represents a single milestone in an escrow payment plan.
 *
 * @property name Display label for the milestone (e.g., "Booking Confirmation").
 * @property amount The monetary amount allocated to this milestone.
 * @property status The current status of this milestone.
 */
data class EscrowMilestone(
    val name: String,
    val amount: Double,
    val status: MilestoneStatus
)

/**
 * Escrow progress bar that visualizes milestones as a segmented horizontal bar.
 *
 * Each segment is proportional to the milestone's amount relative to the total amount.
 * Segments are color-coded by status:
 * - [MilestoneStatus.Held]: champagneGold
 * - [MilestoneStatus.Released]: emeraldGreen
 * - [MilestoneStatus.Frozen]: slateGray
 *
 * The current milestone is visually highlighted with slight elevation.
 * Segment width transitions are animated with a 300ms ease-in-out curve.
 *
 * @param milestones List of escrow milestones to display.
 * @param currentMilestoneIndex Index of the currently active milestone (0-based).
 * @param totalAmount The total escrow amount used to calculate segment proportions.
 * @param modifier Modifier to be applied to the component.
 */
@Composable
fun EscrowProgressBar(
    milestones: List<EscrowMilestone>,
    currentMilestoneIndex: Int,
    totalAmount: Double,
    modifier: Modifier = Modifier
) {
    if (milestones.isEmpty() || totalAmount <= 0.0) return

    Column(
        modifier = modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xs)
    ) {
        // Segmented progress bar
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .height(BarHeight)
                .clip(GomandapTokens.Shapes.pill),
            horizontalArrangement = Arrangement.spacedBy(SegmentGap)
        ) {
            milestones.forEachIndexed { index, milestone ->
                val targetWeight = (milestone.amount / totalAmount).toFloat().coerceIn(0f, 1f)
                val animatedWeight by animateFloatAsState(
                    targetValue = targetWeight,
                    animationSpec = tween(
                        durationMillis = AnimationDurationMs,
                        easing = FastOutSlowInEasing
                    ),
                    label = "segment_weight_$index"
                )

                val segmentColor = milestone.status.toColor()
                val isCurrent = index == currentMilestoneIndex

                val segmentModifier = Modifier
                    .weight(animatedWeight.coerceAtLeast(MinSegmentWeight))
                    .fillMaxHeight()
                    .then(
                        if (isCurrent) {
                            Modifier.shadow(
                                elevation = GomandapTokens.Elevation.medium,
                                shape = RoundedCornerShape(BarCornerRadius)
                            )
                        } else {
                            Modifier
                        }
                    )
                    .clip(RoundedCornerShape(BarCornerRadius))
                    .background(segmentColor)

                Box(modifier = segmentModifier)
            }
        }

        // Milestone labels and amounts below the bar
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(SegmentGap)
        ) {
            milestones.forEachIndexed { index, milestone ->
                val targetWeight = (milestone.amount / totalAmount).toFloat().coerceIn(0f, 1f)
                val animatedWeight by animateFloatAsState(
                    targetValue = targetWeight,
                    animationSpec = tween(
                        durationMillis = AnimationDurationMs,
                        easing = FastOutSlowInEasing
                    ),
                    label = "label_weight_$index"
                )

                val isCurrent = index == currentMilestoneIndex

                Column(
                    modifier = Modifier
                        .weight(animatedWeight.coerceAtLeast(MinSegmentWeight)),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(
                        text = milestone.name,
                        style = if (isCurrent) {
                            GomandapTokens.Typography.labelMedium
                        } else {
                            GomandapTokens.Typography.labelSmall
                        },
                        color = if (isCurrent) {
                            GomandapTokens.Colors.royalNavy
                        } else {
                            GomandapTokens.Colors.slateGray
                        },
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        textAlign = TextAlign.Center
                    )
                    Text(
                        text = formatAmount(milestone.amount),
                        style = GomandapTokens.Typography.labelSmall,
                        color = milestone.status.toColor(),
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        textAlign = TextAlign.Center
                    )
                }
            }
        }
    }
}

/**
 * Maps a [MilestoneStatus] to its corresponding design token color.
 */
private fun MilestoneStatus.toColor(): Color = when (this) {
    MilestoneStatus.Held -> GomandapTokens.Colors.champagneGold
    MilestoneStatus.Released -> GomandapTokens.Colors.emeraldGreen
    MilestoneStatus.Frozen -> GomandapTokens.Colors.slateGray
}

/**
 * Formats a monetary amount for display using Indian numbering (e.g., "₹25,000", "₹1,50,000").
 */
private fun formatAmount(amount: Double): String {
    val wholeAmount = amount.toLong()
    val str = wholeAmount.toString()
    if (str.length <= 3) return "₹$str"

    val lastThree = str.takeLast(3)
    val remaining = str.dropLast(3)
    val formatted = buildString {
        remaining.reversed().chunked(2).reversed().joinTo(this, separator = ",") {
            it.reversed()
        }
        append(',')
        append(lastThree)
    }
    return "₹$formatted"
}

// ─── Constants ───────────────────────────────────────────────────────
private val BarHeight = 12.dp
private val BarCornerRadius = 6.dp
private val SegmentGap = 2.dp
private const val AnimationDurationMs = 300
private const val MinSegmentWeight = 0.01f
