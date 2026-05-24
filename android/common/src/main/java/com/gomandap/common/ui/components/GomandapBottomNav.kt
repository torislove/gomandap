package com.gomandap.common.ui.components

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Represents a single navigation item in the bottom navigation bar.
 *
 * @property icon The default icon displayed for this item.
 * @property selectedIcon Optional icon displayed when this item is selected. Falls back to [icon] if null.
 * @property label The text label displayed below the icon.
 * @property route The navigation route associated with this item.
 */
data class NavItem(
    val icon: ImageVector,
    val selectedIcon: ImageVector? = null,
    val label: String,
    val route: String
)

/**
 * GoMandap design system bottom navigation bar component.
 *
 * Uses Material 3 NavigationBar with GoMandap theming. Supports 3–5 navigation items,
 * each with an icon and label. Reports selection changes via a callback with the selected index.
 *
 * Theming:
 * - Background: pearlWhite (light) / royalNavy (dark)
 * - Selected indicator: champagneGoldLight
 * - Selected icon/label: champagneGoldDark
 * - Unselected icon/label: slateGray
 *
 * Each item maintains a minimum touch target of 48dp per item.
 *
 * @param items List of navigation items (3–5 items supported).
 * @param selectedIndex The index of the currently selected item.
 * @param onItemSelected Callback invoked when an item is selected, providing the item index.
 * @param modifier Modifier to be applied to the navigation bar.
 */
@Composable
fun GomandapBottomNav(
    items: List<NavItem>,
    selectedIndex: Int,
    onItemSelected: (Int) -> Unit,
    modifier: Modifier = Modifier
) {
    require(items.size in 3..5) {
        "GomandapBottomNav supports 3–5 items, but received ${items.size}."
    }

    val isDarkTheme = isSystemInDarkTheme()

    val containerColor = if (isDarkTheme) {
        GomandapTokens.Colors.royalNavy
    } else {
        GomandapTokens.Colors.pearlWhite
    }

    val itemColors = NavigationBarItemDefaults.colors(
        selectedIconColor = GomandapTokens.Colors.champagneGoldDark,
        selectedTextColor = GomandapTokens.Colors.champagneGoldDark,
        indicatorColor = GomandapTokens.Colors.champagneGoldLight,
        unselectedIconColor = GomandapTokens.Colors.slateGray,
        unselectedTextColor = GomandapTokens.Colors.slateGray
    )

    NavigationBar(
        modifier = modifier,
        containerColor = containerColor,
        tonalElevation = GomandapTokens.Elevation.none
    ) {
        items.forEachIndexed { index, item ->
            val isSelected = index == selectedIndex

            NavigationBarItem(
                selected = isSelected,
                onClick = { onItemSelected(index) },
                icon = {
                    Icon(
                        imageVector = if (isSelected) {
                            item.selectedIcon ?: item.icon
                        } else {
                            item.icon
                        },
                        contentDescription = item.label
                    )
                },
                label = {
                    Text(
                        text = item.label,
                        style = GomandapTokens.Typography.labelSmall,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                },
                colors = itemColors,
                modifier = Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)
            )
        }
    }
}
