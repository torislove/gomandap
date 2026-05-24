package com.gomandap.common.ui.navigation

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * GoMandap design system bottom sheet wrapper.
 *
 * Uses Material 3 ModalBottomSheet with GoMandap theming. Supports an optional title,
 * dismiss on swipe down or scrim tap, and Material 3 default sheet animations.
 *
 * Styling:
 * - Container: pearlWhite background, large shape (16dp top corners)
 * - Drag handle: slateGray, centered
 * - Optional title: headlineSmall, royalNavy, with md (16dp) padding
 * - Content area: md (16dp) horizontal padding
 *
 * @param isVisible Whether the bottom sheet is currently visible.
 * @param onDismiss Callback invoked when the sheet is dismissed (swipe down or scrim tap).
 * @param title Optional title displayed at the top of the sheet.
 * @param content The composable content rendered inside the sheet.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GomandapBottomSheet(
    isVisible: Boolean,
    onDismiss: () -> Unit,
    title: String? = null,
    content: @Composable ColumnScope.() -> Unit
) {
    if (!isVisible) return

    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = false)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = GomandapTokens.Colors.pearlWhite,
        shape = GomandapTokens.Shapes.large,
        dragHandle = {
            BottomSheetDragHandle()
        }
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            if (title != null) {
                Text(
                    text = title,
                    style = GomandapTokens.Typography.headlineSmall,
                    color = GomandapTokens.Colors.royalNavy,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.padding(
                        horizontal = GomandapTokens.Spacing.md,
                        vertical = GomandapTokens.Spacing.md
                    )
                )
            }

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = GomandapTokens.Spacing.md),
                content = content
            )
        }
    }
}


/**
 * Custom drag handle for the bottom sheet, styled with slateGray color and centered.
 */
@Composable
private fun BottomSheetDragHandle() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = GomandapTokens.Spacing.sm),
        contentAlignment = Alignment.Center
    ) {
        Box(
            modifier = Modifier
                .width(32.dp)
                .height(4.dp)
                .clip(RoundedCornerShape(2.dp))
                .background(GomandapTokens.Colors.slateGray)
        )
    }
}
