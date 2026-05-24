package com.gomandap.common.ui.components.domain

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import com.gomandap.common.components.BadgeVariant
import com.gomandap.common.components.CardVariant
import com.gomandap.common.components.GomandapBadge
import com.gomandap.common.components.GomandapCard
import com.gomandap.common.components.GomandapSkeleton
import com.gomandap.common.design.GomandapTokens

// ─── Data Models ─────────────────────────────────────────────────────────────

/**
 * Status of a booking in the GoMandap platform.
 */
enum class BookingStatus {
    Pending,
    Confirmed,
    InProgress,
    Completed,
    Cancelled
}

/**
 * Summary data for a booking, used by [BookingStatusCard].
 *
 * @param id Unique identifier for the booking.
 * @param vendorName The name of the vendor associated with this booking.
 * @param eventDate The formatted event date string.
 * @param status The current booking status.
 * @param totalAmount The total booking amount.
 * @param escrowMilestones List of escrow milestones for this booking.
 * @param currentMilestoneIndex Index of the currently active milestone.
 */
data class BookingSummary(
    val id: String,
    val vendorName: String,
    val eventDate: String,
    val status: BookingStatus,
    val totalAmount: Double,
    val escrowMilestones: List<EscrowMilestone> = emptyList(),
    val currentMilestoneIndex: Int = 0
)

// ─── BookingStatusCard Composable ────────────────────────────────────────────

/**
 * A domain-specific card component that displays a booking summary.
 *
 * Shows vendor name, event date, booking status badge, and total amount.
 * Optionally embeds an [EscrowProgressBar] when [showEscrowProgress] is true
 * and the booking has escrow milestones.
 *
 * Uses [GomandapCard] with [CardVariant.Elevated] as the container.
 * The status badge uses [GomandapBadge] with an appropriate variant:
 * - [BookingStatus.Confirmed] → [BadgeVariant.Success]
 * - [BookingStatus.Pending] → [BadgeVariant.Warning]
 * - [BookingStatus.InProgress] → [BadgeVariant.Info]
 * - [BookingStatus.Completed] → [BadgeVariant.Gold]
 * - [BookingStatus.Cancelled] → [BadgeVariant.Error]
 *
 * @param booking The booking summary data to display.
 * @param onTap Callback invoked when the card is tapped.
 * @param showEscrowProgress Whether to show the escrow progress bar.
 */
@Composable
fun BookingStatusCard(
    booking: BookingSummary,
    onTap: () -> Unit,
    showEscrowProgress: Boolean = false
) {
    GomandapCard(
        variant = CardVariant.Elevated,
        onClick = onTap,
        modifier = Modifier.fillMaxWidth()
    ) {
        // Top row: Vendor name + Status badge
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = booking.vendorName,
                style = GomandapTokens.Typography.headlineSmall,
                color = GomandapTokens.Colors.royalNavy,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f)
            )

            Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xs))

            GomandapBadge(
                text = booking.status.displayLabel(),
                variant = booking.status.toBadgeVariant()
            )
        }

        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))

        // Event date
        Text(
            text = booking.eventDate,
            style = GomandapTokens.Typography.bodyMedium,
            color = GomandapTokens.Colors.slateGray,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )

        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.sm))

        // Total amount
        Text(
            text = formatAmount(booking.totalAmount),
            style = GomandapTokens.Typography.headlineMedium,
            color = GomandapTokens.Colors.royalNavy,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )

        // Optional escrow progress bar
        if (showEscrowProgress && booking.escrowMilestones.isNotEmpty()) {
            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.sm))

            EscrowProgressBar(
                milestones = booking.escrowMilestones,
                currentMilestoneIndex = booking.currentMilestoneIndex,
                totalAmount = booking.totalAmount
            )
        }
    }
}

// ─── Loading Skeleton ────────────────────────────────────────────────────────

/**
 * Skeleton loader for [BookingStatusCard] that replicates the card's layout
 * dimensions and element positions using placeholder shapes.
 *
 * Displays shimmer placeholders matching the vendor name, badge, event date,
 * and amount positions.
 */
@Composable
fun BookingStatusCardSkeleton(
    modifier: Modifier = Modifier
) {
    GomandapCard(
        variant = CardVariant.Elevated,
        modifier = modifier.fillMaxWidth()
    ) {
        // Top row: vendor name skeleton + badge skeleton
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            GomandapSkeleton(
                modifier = Modifier
                    .weight(1f)
                    .height(GomandapTokens.Spacing.md),
                shape = GomandapTokens.Shapes.small
            )

            Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xl))

            GomandapSkeleton(
                modifier = Modifier
                    .width(GomandapTokens.Spacing.xxxl)
                    .height(GomandapTokens.Spacing.lg),
                shape = GomandapTokens.Shapes.pill
            )
        }

        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))

        // Event date skeleton
        GomandapSkeleton(
            modifier = Modifier
                .fillMaxWidth(0.5f)
                .height(GomandapTokens.Spacing.sm),
            shape = GomandapTokens.Shapes.small
        )

        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.sm))

        // Amount skeleton
        GomandapSkeleton(
            modifier = Modifier
                .fillMaxWidth(0.35f)
                .height(GomandapTokens.Spacing.lg),
            shape = GomandapTokens.Shapes.small
        )
    }
}

// ─── Helper Functions ────────────────────────────────────────────────────────

/**
 * Maps a [BookingStatus] to the appropriate [BadgeVariant].
 */
private fun BookingStatus.toBadgeVariant(): BadgeVariant {
    return when (this) {
        BookingStatus.Confirmed -> BadgeVariant.Success
        BookingStatus.Pending -> BadgeVariant.Warning
        BookingStatus.InProgress -> BadgeVariant.Info
        BookingStatus.Completed -> BadgeVariant.Gold
        BookingStatus.Cancelled -> BadgeVariant.Error
    }
}

/**
 * Returns a user-friendly display label for a [BookingStatus].
 */
private fun BookingStatus.displayLabel(): String {
    return when (this) {
        BookingStatus.Pending -> "Pending"
        BookingStatus.Confirmed -> "Confirmed"
        BookingStatus.InProgress -> "In Progress"
        BookingStatus.Completed -> "Completed"
        BookingStatus.Cancelled -> "Cancelled"
    }
}

/**
 * Formats a monetary amount for display (e.g., "₹25,000.00").
 */
private fun formatAmount(amount: Double): String {
    val formatted = String.format("%.2f", amount)
    // Add Indian number formatting for the integer part
    val parts = formatted.split(".")
    val integerPart = parts[0]
    val decimalPart = parts[1]

    val formattedInteger = formatIndianNumber(integerPart)
    return "₹$formattedInteger.$decimalPart"
}

/**
 * Formats a number string using the Indian numbering system
 * (e.g., 1,00,000 instead of 100,000).
 */
private fun formatIndianNumber(number: String): String {
    val isNegative = number.startsWith("-")
    val digits = if (isNegative) number.substring(1) else number

    if (digits.length <= 3) return number

    val lastThree = digits.takeLast(3)
    val remaining = digits.dropLast(3)

    val formatted = buildString {
        remaining.reversed().forEachIndexed { index, char ->
            if (index > 0 && index % 2 == 0) append(',')
            append(char)
        }
    }.reversed()

    val result = "$formatted,$lastThree"
    return if (isNegative) "-$result" else result
}
