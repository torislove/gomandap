package com.gomandap.common.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LargeTopAppBar
import androidx.compose.material3.MediumTopAppBar
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarColors
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.material3.TopAppBarScrollBehavior
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Top bar style variants for the GoMandap design system.
 */
enum class TopBarStyle {
    /** Standard top bar with pearlWhite/royalNavy background and low elevation. */
    Standard,
    /** Collapsing top bar using LargeTopAppBar with scroll behavior. */
    Collapsing,
    /** Transparent top bar with no background, for overlay on images. */
    Transparent,
    /** Branded top bar with royalNavy background and champagneGold title (for Admin app). */
    Branded
}

/**
 * GoMandap design system top app bar component.
 *
 * Supports 4 style variants (Standard, Collapsing, Transparent, Branded) with
 * consistent styling using design tokens. Includes optional subtitle, back button
 * with 48dp touch target, and up to 3 action slots.
 *
 * @param title The title text displayed in the top bar (1 line, truncated with ellipsis).
 * @param modifier Modifier to be applied to the top bar.
 * @param subtitle Optional subtitle text displayed below the title (1 line, truncated with ellipsis).
 * @param showBackButton Whether to show the back navigation button.
 * @param onBack Callback invoked when the back button is pressed. Required when showBackButton is true.
 * @param style The visual style variant of the top bar.
 * @param scrollBehavior Optional scroll behavior for collapsing variant.
 * @param actions Composable content for action icons in the trailing slot (up to 3 actions).
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GomandapTopBar(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    showBackButton: Boolean = false,
    onBack: (() -> Unit)? = null,
    style: TopBarStyle = TopBarStyle.Standard,
    scrollBehavior: TopAppBarScrollBehavior? = null,
    actions: @Composable RowScope.() -> Unit = {}
) {
    val colors = getTopBarColors(style)

    val navigationIcon: @Composable () -> Unit = if (showBackButton && onBack != null) {
        {
            IconButton(
                onClick = onBack,
                modifier = Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Navigate back",
                    tint = getTitleColor(style)
                )
            }
        }
    } else {
        {}
    }

    val titleContent: @Composable () -> Unit = {
        if (subtitle != null) {
            Column {
                Text(
                    text = title,
                    style = GomandapTokens.Typography.headlineMedium,
                    color = getTitleColor(style),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = subtitle,
                    style = GomandapTokens.Typography.bodySmall,
                    color = getSubtitleColor(style),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        } else {
            Text(
                text = title,
                style = GomandapTokens.Typography.headlineMedium,
                color = getTitleColor(style),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }

    when (style) {
        TopBarStyle.Collapsing -> {
            LargeTopAppBar(
                title = titleContent,
                modifier = modifier,
                navigationIcon = navigationIcon,
                actions = actions,
                colors = colors,
                scrollBehavior = scrollBehavior
            )
        }

        TopBarStyle.Standard, TopBarStyle.Branded -> {
            CenterAlignedTopAppBar(
                title = titleContent,
                modifier = modifier,
                navigationIcon = navigationIcon,
                actions = actions,
                colors = colors,
                scrollBehavior = scrollBehavior
            )
        }

        TopBarStyle.Transparent -> {
            TopAppBar(
                title = titleContent,
                modifier = modifier,
                navigationIcon = navigationIcon,
                actions = actions,
                colors = colors,
                scrollBehavior = scrollBehavior
            )
        }
    }
}

/**
 * Returns the TopAppBarColors for the given style variant.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun getTopBarColors(style: TopBarStyle): TopAppBarColors {
    return when (style) {
        TopBarStyle.Standard -> TopAppBarDefaults.centerAlignedTopAppBarColors(
            containerColor = GomandapTokens.Colors.pearlWhite,
            scrolledContainerColor = GomandapTokens.Colors.pearlWhite,
            navigationIconContentColor = GomandapTokens.Colors.royalNavy,
            titleContentColor = GomandapTokens.Colors.royalNavy,
            actionIconContentColor = GomandapTokens.Colors.royalNavy
        )

        TopBarStyle.Collapsing -> TopAppBarDefaults.largeTopAppBarColors(
            containerColor = GomandapTokens.Colors.pearlWhite,
            scrolledContainerColor = GomandapTokens.Colors.pearlWhite,
            navigationIconContentColor = GomandapTokens.Colors.royalNavy,
            titleContentColor = GomandapTokens.Colors.royalNavy,
            actionIconContentColor = GomandapTokens.Colors.royalNavy
        )

        TopBarStyle.Transparent -> TopAppBarDefaults.topAppBarColors(
            containerColor = Color.Transparent,
            scrolledContainerColor = Color.Transparent,
            navigationIconContentColor = GomandapTokens.Colors.royalNavy,
            titleContentColor = GomandapTokens.Colors.royalNavy,
            actionIconContentColor = GomandapTokens.Colors.royalNavy
        )

        TopBarStyle.Branded -> TopAppBarDefaults.centerAlignedTopAppBarColors(
            containerColor = GomandapTokens.Colors.royalNavy,
            scrolledContainerColor = GomandapTokens.Colors.royalNavy,
            navigationIconContentColor = GomandapTokens.Colors.champagneGold,
            titleContentColor = GomandapTokens.Colors.champagneGold,
            actionIconContentColor = GomandapTokens.Colors.champagneGold
        )
    }
}

/**
 * Returns the title text color for the given style variant.
 */
private fun getTitleColor(style: TopBarStyle): Color {
    return when (style) {
        TopBarStyle.Standard, TopBarStyle.Collapsing, TopBarStyle.Transparent ->
            GomandapTokens.Colors.royalNavy
        TopBarStyle.Branded ->
            GomandapTokens.Colors.champagneGold
    }
}

/**
 * Returns the subtitle text color for the given style variant.
 */
private fun getSubtitleColor(style: TopBarStyle): Color {
    return when (style) {
        TopBarStyle.Standard, TopBarStyle.Collapsing, TopBarStyle.Transparent ->
            GomandapTokens.Colors.slateGray
        TopBarStyle.Branded ->
            GomandapTokens.Colors.champagneGoldLight
    }
}
