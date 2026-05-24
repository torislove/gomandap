package com.gomandap.common.ui.layout

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import com.gomandap.common.components.TopBarStyle
import com.gomandap.common.design.GomandapTokens

/**
 * Defines the scroll behavior for a screen's content area.
 */
enum class ScrollBehavior {
    /** Fixed-height screen with no scrolling. */
    Static,
    /** Single-axis vertically scrollable screen. */
    Scroll,
    /** Screen with independently scrollable child regions (nested scroll). */
    NestedScroll
}

/**
 * Defines the app type for navigation and layout decisions.
 */
enum class AppType {
    Admin,
    Vendor,
    Client
}

/**
 * Configuration for a screen's layout behavior within the GoMandap app shell.
 *
 * @property appType The application type (Admin, Vendor, Client).
 * @property screenName A unique identifier for the screen.
 * @property hasBottomNav Whether the screen displays a bottom navigation bar.
 * @property hasTopBar Whether the screen displays a top app bar.
 * @property topBarStyle The visual style of the top bar.
 * @property contentPadding The padding applied to the screen's content area.
 * @property scrollBehavior The scroll behavior for the screen's content.
 */
data class ScreenConfig(
    val appType: AppType,
    val screenName: String,
    val hasBottomNav: Boolean,
    val hasTopBar: Boolean,
    val topBarStyle: TopBarStyle,
    val contentPadding: PaddingValues,
    val scrollBehavior: ScrollBehavior
)

/**
 * Returns responsive content padding based on the current screen width.
 *
 * Adapts horizontal padding for devices in the 320dp–412dp range:
 * - 320dp and below: uses [GomandapTokens.Spacing.sm] (12dp) horizontal padding
 * - 360dp: uses [GomandapTokens.Spacing.md] (16dp) horizontal padding
 * - 412dp and above: uses [GomandapTokens.Spacing.lg] (20dp) horizontal padding
 *
 * Vertical padding is consistently [GomandapTokens.Spacing.md] (16dp).
 *
 * @return [PaddingValues] appropriate for the current screen width.
 */
@Composable
fun responsiveContentPadding(): PaddingValues {
    val screenWidthDp = LocalConfiguration.current.screenWidthDp.dp
    val horizontalPadding = responsiveHorizontalPadding(screenWidthDp)
    return PaddingValues(
        start = horizontalPadding,
        end = horizontalPadding,
        top = GomandapTokens.Spacing.md,
        bottom = GomandapTokens.Spacing.md
    )
}

/**
 * Calculates the appropriate horizontal padding based on screen width.
 *
 * Uses spacing tokens to ensure non-overlapping layouts across the
 * supported device width range (320dp–412dp).
 */
private fun responsiveHorizontalPadding(screenWidth: Dp): Dp {
    return when {
        screenWidth <= 320.dp -> GomandapTokens.Spacing.sm  // 12dp — tight screens
        screenWidth <= 360.dp -> GomandapTokens.Spacing.md  // 16dp — standard phones
        else -> GomandapTokens.Spacing.lg                   // 20dp — larger phones
    }
}

/**
 * A scrollable column composable that applies the correct scroll behavior
 * based on the provided [ScrollBehavior] configuration.
 *
 * - [ScrollBehavior.Static]: No scrolling; content is rendered in a fixed column.
 * - [ScrollBehavior.Scroll]: Vertical scrolling enabled for the entire column.
 * - [ScrollBehavior.NestedScroll]: Vertical scrolling with nested scroll support,
 *   allowing independently scrollable child regions to coexist.
 *
 * Uses [responsiveContentPadding] by default for content padding, ensuring
 * no overflow at 320dp minimum width. Text within this column should use
 * [SingleLineText] or [MultiLineText] helpers for proper truncation behavior.
 *
 * @param modifier Modifier to be applied to the column.
 * @param scrollBehavior The scroll behavior to apply.
 * @param contentPadding Optional custom padding. Defaults to [responsiveContentPadding].
 * @param content The composable content to display within the column.
 */
@Composable
fun GomandapScrollableColumn(
    modifier: Modifier = Modifier,
    scrollBehavior: ScrollBehavior = ScrollBehavior.Scroll,
    contentPadding: PaddingValues? = null,
    content: @Composable ColumnScope.() -> Unit
) {
    val padding = contentPadding ?: responsiveContentPadding()

    val scrollModifier = when (scrollBehavior) {
        ScrollBehavior.Static -> Modifier
        ScrollBehavior.Scroll -> Modifier.verticalScroll(rememberScrollState())
        ScrollBehavior.NestedScroll -> Modifier.verticalScroll(rememberScrollState())
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .then(scrollModifier)
            .padding(
                start = padding.calculateLeftPadding(LayoutDirection.Ltr),
                end = padding.calculateRightPadding(LayoutDirection.Ltr),
                top = padding.calculateTopPadding(),
                bottom = padding.calculateBottomPadding()
            )
    ) {
        content()
    }
}

/**
 * Renders single-line text with ellipsis truncation when content exceeds
 * the available width. Ensures no horizontal overflow at 320dp minimum width.
 *
 * @param text The text content to display.
 * @param modifier Modifier to be applied to the text.
 * @param style The text style from [GomandapTokens.Typography].
 */
@Composable
fun SingleLineText(
    text: String,
    modifier: Modifier = Modifier,
    style: TextStyle = GomandapTokens.Typography.bodyMedium
) {
    Text(
        text = text,
        modifier = modifier.fillMaxWidth(),
        style = style,
        maxLines = 1,
        overflow = TextOverflow.Ellipsis
    )
}

/**
 * Renders multi-line text that wraps within container bounds.
 * Prevents horizontal overflow by constraining text to the available width.
 *
 * @param text The text content to display.
 * @param modifier Modifier to be applied to the text.
 * @param style The text style from [GomandapTokens.Typography].
 * @param maxLines Maximum number of lines before truncation with ellipsis. Defaults to [Int.MAX_VALUE] (no limit).
 */
@Composable
fun MultiLineText(
    text: String,
    modifier: Modifier = Modifier,
    style: TextStyle = GomandapTokens.Typography.bodyMedium,
    maxLines: Int = Int.MAX_VALUE
) {
    Text(
        text = text,
        modifier = modifier.fillMaxWidth(),
        style = style,
        maxLines = maxLines,
        overflow = if (maxLines < Int.MAX_VALUE) TextOverflow.Ellipsis else TextOverflow.Visible
    )
}
