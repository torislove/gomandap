package com.gomandap.common.ui.performance

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyItemScope
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.gomandap.common.design.GomandapTokens

/**
 * Lazy loading utilities with enforced stable keys for optimal recomposition performance.
 *
 * ## Best Practices for Stable Keys
 *
 * - **Use unique item IDs** (database IDs, UUIDs) as keys — never list indices.
 * - Index-based keys cause full recomposition on insertions, deletions, and reordering.
 * - Stable keys allow Compose to identify moved items and skip unnecessary recompositions.
 * - Keys must be unique within the list; duplicates cause undefined behavior.
 *
 * ### Good Examples
 * ```kotlin
 * StableKeyLazyColumn(
 *     items = vendors,
 *     key = { it.id },  // unique database ID
 * ) { vendor -> VendorCard(vendor) }
 * ```
 *
 * ### Bad Examples
 * ```kotlin
 * // DON'T: index-based keys defeat the purpose of stable keys
 * LazyColumn {
 *     itemsIndexed(vendors) { index, vendor ->
 *         key(index) { VendorCard(vendor) }
 *     }
 * }
 * ```
 */

// ─── StableKeyLazyColumn ─────────────────────────────────────────────────────

/**
 * A [LazyColumn] wrapper that enforces stable key usage for all items.
 *
 * Uses [remember] and [derivedStateOf] internally to minimize recompositions
 * when the list data changes. Items are keyed by the provided [key] extractor,
 * which should return a unique, stable identifier for each item (e.g., a database ID).
 *
 * @param items The list of data items to display.
 * @param key A function that extracts a unique, stable key from each item.
 * @param modifier Modifier applied to the underlying [LazyColumn].
 * @param state The [LazyListState] for controlling and observing scroll position.
 * @param contentPadding Padding around the list content.
 * @param verticalArrangement Vertical arrangement of items.
 * @param horizontalAlignment Horizontal alignment of items.
 * @param content The composable content for each item.
 */
@Composable
fun <T> StableKeyLazyColumn(
    items: List<T>,
    key: (T) -> Any,
    modifier: Modifier = Modifier,
    state: LazyListState = rememberLazyListState(),
    contentPadding: PaddingValues = PaddingValues(GomandapTokens.Spacing.md),
    verticalArrangement: Arrangement.Vertical = Arrangement.spacedBy(GomandapTokens.Spacing.xs),
    horizontalAlignment: Alignment.Horizontal = Alignment.Start,
    content: @Composable LazyItemScope.(T) -> Unit
) {
    val stableItems by remember(items) {
        derivedStateOf { items }
    }

    LazyColumn(
        modifier = modifier,
        state = state,
        contentPadding = contentPadding,
        verticalArrangement = verticalArrangement,
        horizontalAlignment = horizontalAlignment
    ) {
        items(
            items = stableItems,
            key = key
        ) { item ->
            content(item)
        }
    }
}

// ─── StableKeyLazyRow ────────────────────────────────────────────────────────

/**
 * A [LazyRow] wrapper that enforces stable key usage for all items.
 *
 * Uses [remember] and [derivedStateOf] internally to minimize recompositions
 * when the list data changes. Items are keyed by the provided [key] extractor,
 * which should return a unique, stable identifier for each item.
 *
 * @param items The list of data items to display.
 * @param key A function that extracts a unique, stable key from each item.
 * @param modifier Modifier applied to the underlying [LazyRow].
 * @param state The [LazyListState] for controlling and observing scroll position.
 * @param contentPadding Padding around the list content.
 * @param horizontalArrangement Horizontal arrangement of items.
 * @param verticalAlignment Vertical alignment of items.
 * @param content The composable content for each item.
 */
@Composable
fun <T> StableKeyLazyRow(
    items: List<T>,
    key: (T) -> Any,
    modifier: Modifier = Modifier,
    state: LazyListState = rememberLazyListState(),
    contentPadding: PaddingValues = PaddingValues(horizontal = GomandapTokens.Spacing.md),
    horizontalArrangement: Arrangement.Horizontal = Arrangement.spacedBy(GomandapTokens.Spacing.xs),
    verticalAlignment: Alignment.Vertical = Alignment.CenterVertically,
    content: @Composable LazyItemScope.(T) -> Unit
) {
    val stableItems by remember(items) {
        derivedStateOf { items }
    }

    LazyRow(
        modifier = modifier,
        state = state,
        contentPadding = contentPadding,
        horizontalArrangement = horizontalArrangement,
        verticalAlignment = verticalAlignment
    ) {
        items(
            items = stableItems,
            key = key
        ) { item ->
            content(item)
        }
    }
}

// ─── Extension Functions ─────────────────────────────────────────────────────

/**
 * Adds a list of items with enforced stable keys to a [LazyListScope].
 *
 * This is a convenience extension that ensures the [key] parameter is always provided,
 * preventing accidental use of index-based keys.
 *
 * @param items The list of data items to display.
 * @param key A function that extracts a unique, stable key from each item.
 *            Use item IDs (database IDs, UUIDs), not list indices.
 * @param contentType Optional factory for content types used by the list for item recycling.
 * @param itemContent The composable content for each item.
 */
fun <T> LazyListScope.stableItems(
    items: List<T>,
    key: (T) -> Any,
    contentType: ((T) -> Any?)? = null,
    itemContent: @Composable LazyItemScope.(T) -> Unit
) {
    items(
        items = items,
        key = key,
        contentType = contentType ?: { null }
    ) { item ->
        itemContent(item)
    }
}

/**
 * Adds a list of items with enforced stable keys and index access to a [LazyListScope].
 *
 * This is a convenience extension that ensures the [key] parameter is always provided,
 * preventing accidental use of index-based keys. The index is provided for display
 * purposes only (e.g., numbering) — never use it as a key.
 *
 * @param items The list of data items to display.
 * @param key A function that extracts a unique, stable key from each item.
 *            Use item IDs (database IDs, UUIDs), not list indices.
 * @param contentType Optional factory for content types used by the list for item recycling.
 * @param itemContent The composable content for each item, receiving the index and item.
 */
fun <T> LazyListScope.stableItemsIndexed(
    items: List<T>,
    key: (index: Int, item: T) -> Any,
    contentType: ((index: Int, item: T) -> Any?)? = null,
    itemContent: @Composable LazyItemScope.(index: Int, item: T) -> Unit
) {
    itemsIndexed(
        items = items,
        key = key,
        contentType = contentType ?: { _, _ -> null }
    ) { index, item ->
        itemContent(index, item)
    }
}
