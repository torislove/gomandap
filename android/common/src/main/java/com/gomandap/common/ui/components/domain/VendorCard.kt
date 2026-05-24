package com.gomandap.common.ui.components.domain

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material.icons.outlined.BookmarkBorder
import androidx.compose.material.icons.outlined.LocalFireDepartment
import androidx.compose.material.icons.outlined.PlayArrow
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.gomandap.common.components.BadgeVariant
import com.gomandap.common.components.CardVariant
import com.gomandap.common.components.GomandapBadge
import com.gomandap.common.components.GomandapCard
import com.gomandap.common.components.GomandapSkeleton
import com.gomandap.common.components.GomandapSkeletonCircle
import com.gomandap.common.design.GomandapTokens

/**
 * Data class representing a vendor summary for display in vendor cards.
 */
data class VendorSummary(
    val id: String,
    val name: String,
    val locality: String = "",
    val priceRange: String = "",
    val rating: Float = 0f,
    val reviewCount: Int = 0,
    val photoUrl: String? = null,
    val isVerified: Boolean = false,
    val isFastFilling: Boolean = false,
    val status: String? = null,
    val adminNotes: String? = null
)

/**
 * Variants for the VendorCard component.
 */
enum class VendorCardVariant {
    /** Name, locality, price range, rating, photo thumbnail */
    Standard,
    /** Name, rating, small photo */
    Compact,
    /** Standard + verified badge + "Fast Filling" indicator */
    Featured,
    /** Standard + status badge + admin notes preview */
    AdminReview
}

/**
 * A domain-specific card component for displaying vendor information.
 *
 * Supports 4 variants:
 * - **Standard**: Displays name, locality, price range, rating, and photo thumbnail.
 * - **Compact**: Displays name, rating, and a small photo.
 * - **Featured**: Standard layout plus a verified badge and "Fast Filling" indicator.
 * - **AdminReview**: Standard layout plus a status badge and admin notes preview.
 *
 * Uses [GomandapCard] (Elevated variant) as the container.
 * Integrates [GomandapSkeleton] for loading state.
 * All interactive elements maintain a minimum 48dp touch target.
 *
 * @param vendor The vendor data to display.
 * @param variant The visual variant of the card.
 * @param onTap Callback invoked when the card is tapped.
 * @param onBookmark Optional callback for the bookmark toggle action.
 * @param onQuickAction Optional callback for the quick action button.
 * @param isLoading When true, displays a skeleton loading state.
 * @param isBookmarked Whether the vendor is currently bookmarked.
 * @param modifier Modifier to be applied to the card.
 */
@Composable
fun VendorCard(
    vendor: VendorSummary,
    variant: VendorCardVariant = VendorCardVariant.Standard,
    onTap: () -> Unit,
    onBookmark: (() -> Unit)? = null,
    onQuickAction: (() -> Unit)? = null,
    isLoading: Boolean = false,
    isBookmarked: Boolean = false,
    modifier: Modifier = Modifier
) {
    if (isLoading) {
        VendorCardSkeleton(variant = variant, modifier = modifier)
        return
    }

    GomandapCard(
        modifier = modifier.fillMaxWidth(),
        variant = CardVariant.Elevated,
        onClick = onTap
    ) {
        when (variant) {
            VendorCardVariant.Standard -> StandardContent(
                vendor = vendor,
                onBookmark = onBookmark,
                onQuickAction = onQuickAction,
                isBookmarked = isBookmarked
            )
            VendorCardVariant.Compact -> CompactContent(
                vendor = vendor,
                onBookmark = onBookmark,
                isBookmarked = isBookmarked
            )
            VendorCardVariant.Featured -> FeaturedContent(
                vendor = vendor,
                onBookmark = onBookmark,
                onQuickAction = onQuickAction,
                isBookmarked = isBookmarked
            )
            VendorCardVariant.AdminReview -> AdminReviewContent(
                vendor = vendor,
                onBookmark = onBookmark,
                onQuickAction = onQuickAction,
                isBookmarked = isBookmarked
            )
        }
    }
}

// ─── Standard Variant ────────────────────────────────────────────────────────

@Composable
private fun StandardContent(
    vendor: VendorSummary,
    onBookmark: (() -> Unit)?,
    onQuickAction: (() -> Unit)?,
    isBookmarked: Boolean
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Top
    ) {
        // Photo thumbnail
        VendorPhoto(
            photoUrl = vendor.photoUrl,
            size = 64.dp
        )

        Spacer(modifier = Modifier.width(GomandapTokens.Spacing.sm))

        // Vendor info
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = vendor.name,
                style = GomandapTokens.Typography.headlineSmall,
                color = GomandapTokens.Colors.royalNavy,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            if (vendor.locality.isNotEmpty()) {
                Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xxs))
                Text(
                    text = vendor.locality,
                    style = GomandapTokens.Typography.bodySmall,
                    color = GomandapTokens.Colors.slateGray,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))

            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
            ) {
                if (vendor.priceRange.isNotEmpty()) {
                    Text(
                        text = vendor.priceRange,
                        style = GomandapTokens.Typography.labelMedium,
                        color = GomandapTokens.Colors.royalNavy
                    )
                }

                RatingChip(rating = vendor.rating)
            }
        }

        // Action buttons
        ActionButtons(
            onBookmark = onBookmark,
            onQuickAction = onQuickAction,
            isBookmarked = isBookmarked
        )
    }
}

// ─── Compact Variant ─────────────────────────────────────────────────────────

@Composable
private fun CompactContent(
    vendor: VendorSummary,
    onBookmark: (() -> Unit)?,
    isBookmarked: Boolean
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Small photo
        VendorPhoto(
            photoUrl = vendor.photoUrl,
            size = 40.dp
        )

        Spacer(modifier = Modifier.width(GomandapTokens.Spacing.sm))

        // Name
        Text(
            text = vendor.name,
            style = GomandapTokens.Typography.labelLarge,
            color = GomandapTokens.Colors.royalNavy,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.weight(1f)
        )

        Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xs))

        // Rating
        RatingChip(rating = vendor.rating)

        // Bookmark
        if (onBookmark != null) {
            BookmarkButton(
                isBookmarked = isBookmarked,
                onBookmark = onBookmark
            )
        }
    }
}

// ─── Featured Variant ────────────────────────────────────────────────────────

@Composable
private fun FeaturedContent(
    vendor: VendorSummary,
    onBookmark: (() -> Unit)?,
    onQuickAction: (() -> Unit)?,
    isBookmarked: Boolean
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        // Badges row (verified + fast filling)
        Row(
            horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xs)
        ) {
            if (vendor.isVerified) {
                GomandapBadge(
                    text = "Verified",
                    variant = BadgeVariant.Success,
                    icon = Icons.Filled.Verified
                )
            }
            if (vendor.isFastFilling) {
                GomandapBadge(
                    text = "Fast Filling",
                    variant = BadgeVariant.Warning,
                    icon = Icons.Outlined.LocalFireDepartment
                )
            }
        }

        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))

        // Standard content below badges
        StandardContent(
            vendor = vendor,
            onBookmark = onBookmark,
            onQuickAction = onQuickAction,
            isBookmarked = isBookmarked
        )
    }
}

// ─── AdminReview Variant ─────────────────────────────────────────────────────

@Composable
private fun AdminReviewContent(
    vendor: VendorSummary,
    onBookmark: (() -> Unit)?,
    onQuickAction: (() -> Unit)?,
    isBookmarked: Boolean
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        // Standard content
        StandardContent(
            vendor = vendor,
            onBookmark = onBookmark,
            onQuickAction = onQuickAction,
            isBookmarked = isBookmarked
        )

        // Status badge
        if (vendor.status != null) {
            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))
            GomandapBadge(
                text = vendor.status,
                variant = statusToBadgeVariant(vendor.status)
            )
        }

        // Admin notes preview
        if (vendor.adminNotes != null) {
            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))
            Text(
                text = vendor.adminNotes,
                style = GomandapTokens.Typography.bodySmall,
                color = GomandapTokens.Colors.slateGray,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

// ─── Shared Sub-Components ───────────────────────────────────────────────────

/**
 * Displays a vendor photo placeholder (since Coil is not in the common module dependencies).
 * Uses a colored circle with the first letter of the vendor name as a fallback.
 */
@Composable
private fun VendorPhoto(
    photoUrl: String?,
    size: androidx.compose.ui.unit.Dp
) {
    Box(
        modifier = Modifier
            .size(size)
            .clip(GomandapTokens.Shapes.medium)
            .background(GomandapTokens.Colors.champagneGoldLight),
        contentAlignment = Alignment.Center
    ) {
        // Placeholder — in a full implementation, Coil AsyncImage would load photoUrl
        Icon(
            imageVector = Icons.Filled.Star,
            contentDescription = "Vendor photo",
            modifier = Modifier.size(size / 2),
            tint = GomandapTokens.Colors.champagneGoldDark
        )
    }
}

/**
 * Displays a compact rating chip with a star icon and numeric rating.
 */
@Composable
private fun RatingChip(rating: Float) {
    if (rating <= 0f) return

    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xxs)
    ) {
        Icon(
            imageVector = Icons.Filled.Star,
            contentDescription = "Rating",
            modifier = Modifier.size(14.dp),
            tint = GomandapTokens.Colors.champagneGold
        )
        Text(
            text = String.format("%.1f", rating),
            style = GomandapTokens.Typography.labelMedium,
            color = GomandapTokens.Colors.royalNavy
        )
    }
}

/**
 * Action buttons column with bookmark toggle and optional quick action.
 * Each button maintains a minimum 48dp touch target.
 */
@Composable
private fun ActionButtons(
    onBookmark: (() -> Unit)?,
    onQuickAction: (() -> Unit)?,
    isBookmarked: Boolean
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        if (onBookmark != null) {
            BookmarkButton(
                isBookmarked = isBookmarked,
                onBookmark = onBookmark
            )
        }
        if (onQuickAction != null) {
            QuickActionButton(onQuickAction = onQuickAction)
        }
    }
}

/**
 * Bookmark icon toggle button with 48dp minimum touch target.
 */
@Composable
private fun BookmarkButton(
    isBookmarked: Boolean,
    onBookmark: () -> Unit
) {
    IconButton(
        onClick = onBookmark,
        modifier = Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)
    ) {
        Icon(
            imageVector = if (isBookmarked) Icons.Filled.Bookmark else Icons.Outlined.BookmarkBorder,
            contentDescription = if (isBookmarked) "Remove bookmark" else "Add bookmark",
            tint = if (isBookmarked) GomandapTokens.Colors.champagneGold else GomandapTokens.Colors.slateGray,
            modifier = Modifier.size(24.dp)
        )
    }
}

/**
 * Quick action button with 48dp minimum touch target.
 */
@Composable
private fun QuickActionButton(
    onQuickAction: () -> Unit
) {
    IconButton(
        onClick = onQuickAction,
        modifier = Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)
    ) {
        Icon(
            imageVector = Icons.Outlined.PlayArrow,
            contentDescription = "Quick action",
            tint = GomandapTokens.Colors.emeraldGreen,
            modifier = Modifier.size(24.dp)
        )
    }
}

// ─── Skeleton Loading State ──────────────────────────────────────────────────

/**
 * Skeleton loading state for the VendorCard that replicates the layout
 * dimensions and element positions using placeholder shapes.
 */
@Composable
private fun VendorCardSkeleton(
    variant: VendorCardVariant,
    modifier: Modifier = Modifier
) {
    GomandapCard(
        modifier = modifier.fillMaxWidth(),
        variant = CardVariant.Elevated
    ) {
        when (variant) {
            VendorCardVariant.Compact -> CompactSkeleton()
            else -> StandardSkeleton()
        }
    }
}

@Composable
private fun StandardSkeleton() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.Top
    ) {
        // Photo placeholder
        GomandapSkeleton(
            modifier = Modifier.size(64.dp),
            shape = GomandapTokens.Shapes.medium
        )

        Spacer(modifier = Modifier.width(GomandapTokens.Spacing.sm))

        // Text placeholders
        Column(modifier = Modifier.weight(1f)) {
            GomandapSkeleton(
                modifier = Modifier
                    .fillMaxWidth(0.7f)
                    .height(16.dp),
                shape = GomandapTokens.Shapes.small
            )
            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))
            GomandapSkeleton(
                modifier = Modifier
                    .fillMaxWidth(0.5f)
                    .height(12.dp),
                shape = GomandapTokens.Shapes.small
            )
            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))
            GomandapSkeleton(
                modifier = Modifier
                    .fillMaxWidth(0.3f)
                    .height(12.dp),
                shape = GomandapTokens.Shapes.small
            )
        }

        // Action button placeholder
        GomandapSkeletonCircle(size = 24.dp)
    }
}

@Composable
private fun CompactSkeleton() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // Small photo placeholder
        GomandapSkeleton(
            modifier = Modifier.size(40.dp),
            shape = GomandapTokens.Shapes.medium
        )

        Spacer(modifier = Modifier.width(GomandapTokens.Spacing.sm))

        // Name placeholder
        GomandapSkeleton(
            modifier = Modifier
                .weight(1f)
                .height(14.dp),
            shape = GomandapTokens.Shapes.small
        )

        Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xs))

        // Rating placeholder
        GomandapSkeleton(
            modifier = Modifier
                .width(40.dp)
                .height(14.dp),
            shape = GomandapTokens.Shapes.small
        )
    }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

/**
 * Maps a vendor status string to the appropriate badge variant.
 */
private fun statusToBadgeVariant(status: String): BadgeVariant {
    return when (status.lowercase()) {
        "approved" -> BadgeVariant.Success
        "pending" -> BadgeVariant.Warning
        "rejected" -> BadgeVariant.Error
        "suspended" -> BadgeVariant.Error
        "under review" -> BadgeVariant.Info
        else -> BadgeVariant.Default
    }
}
