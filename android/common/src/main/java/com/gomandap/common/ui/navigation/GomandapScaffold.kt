package com.gomandap.common.ui.navigation

import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.DrawerValue
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.ModalDrawerSheet
import androidx.compose.material3.ModalNavigationDrawer
import androidx.compose.material3.NavigationDrawerItem
import androidx.compose.material3.NavigationDrawerItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.rememberDrawerState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import com.gomandap.common.components.GomandapTopBar
import com.gomandap.common.components.TopBarStyle
import com.gomandap.common.design.GomandapTokens
import com.gomandap.common.ui.components.GomandapBottomNav
import com.gomandap.common.ui.components.NavItem
import kotlinx.coroutines.launch

/**
 * Defines the type of GoMandap application, determining the navigation pattern used.
 */
enum class AppType {
    /** Admin app: side drawer + branded top bar (tablet-optimized). */
    Admin,
    /** Vendor app: bottom navigation with 5 tabs. */
    Vendor,
    /** Client app: bottom navigation with 4 tabs + contextual bottom sheets. */
    Client
}

/**
 * GoMandap App Shell that wraps each app with the appropriate navigation pattern
 * based on the [AppType].
 *
 * - [AppType.Admin]: Side drawer combined with a branded top bar (tablet-optimized layout).
 * - [AppType.Vendor]: Bottom navigation bar with 5 tabs.
 * - [AppType.Client]: Bottom navigation bar with 4 tabs, plus contextual bottom sheets.
 *
 * @param appType The type of app, determining the navigation pattern.
 * @param currentRoute The current navigation route, used to highlight the active item.
 * @param onNavigate Callback invoked when a navigation item is selected, providing the route string.
 * @param navItems The list of navigation items to display. For Admin, these appear in the drawer;
 *   for Vendor/Client, they appear in the bottom navigation bar.
 * @param title Optional title for the top bar (used primarily in Admin layout).
 * @param content The main screen content composable.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GomandapAppShell(
    appType: AppType,
    currentRoute: String,
    onNavigate: (String) -> Unit,
    navItems: List<NavItem>,
    title: String = "",
    content: @Composable () -> Unit
) {
    when (appType) {
        AppType.Admin -> AdminAppShell(
            currentRoute = currentRoute,
            onNavigate = onNavigate,
            navItems = navItems,
            title = title,
            content = content
        )

        AppType.Vendor -> BottomNavAppShell(
            currentRoute = currentRoute,
            onNavigate = onNavigate,
            navItems = navItems,
            content = content
        )

        AppType.Client -> BottomNavAppShell(
            currentRoute = currentRoute,
            onNavigate = onNavigate,
            navItems = navItems,
            content = content
        )
    }
}

/**
 * Admin app shell with a side navigation drawer and branded top bar.
 * Tablet-optimized layout using [ModalNavigationDrawer].
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun AdminAppShell(
    currentRoute: String,
    onNavigate: (String) -> Unit,
    navItems: List<NavItem>,
    title: String,
    content: @Composable () -> Unit
) {
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet {
                AdminDrawerContent(
                    navItems = navItems,
                    currentRoute = currentRoute,
                    onItemSelected = { route ->
                        onNavigate(route)
                        scope.launch { drawerState.close() }
                    }
                )
            }
        }
    ) {
        GomandapScaffold(
            topBar = {
                GomandapTopBar(
                    title = title,
                    style = TopBarStyle.Branded
                )
            },
            content = { _ ->
                content()
            }
        )
    }
}

/**
 * Bottom navigation app shell used by Vendor and Client apps.
 * Displays a [GomandapBottomNav] at the bottom with the provided navigation items.
 */
@Composable
private fun BottomNavAppShell(
    currentRoute: String,
    onNavigate: (String) -> Unit,
    navItems: List<NavItem>,
    content: @Composable () -> Unit
) {
    val selectedIndex = navItems.indexOfFirst { it.route == currentRoute }.coerceAtLeast(0)

    GomandapScaffold(
        bottomBar = {
            GomandapBottomNav(
                items = navItems,
                selectedIndex = selectedIndex,
                onItemSelected = { index ->
                    onNavigate(navItems[index].route)
                }
            )
        },
        content = { _ ->
            content()
        }
    )
}

/**
 * Standard screen scaffold wrapping Material 3 [Scaffold] with GoMandap theming.
 *
 * Uses [GomandapTokens.Colors.pearlWhite] as the background color and provides
 * standard slots for topBar, bottomBar, floatingActionButton, snackbarHost, and content.
 *
 * @param topBar Composable slot for the top app bar.
 * @param bottomBar Composable slot for the bottom navigation bar.
 * @param floatingActionButton Composable slot for the floating action button.
 * @param snackbarHost Composable slot for the snackbar host.
 * @param content The main content composable, receiving [PaddingValues] to account for bars.
 */
@Composable
fun GomandapScaffold(
    topBar: @Composable () -> Unit = {},
    bottomBar: @Composable () -> Unit = {},
    floatingActionButton: @Composable () -> Unit = {},
    snackbarHost: @Composable () -> Unit = {},
    content: @Composable (PaddingValues) -> Unit
) {
    Scaffold(
        modifier = Modifier.fillMaxSize(),
        topBar = topBar,
        bottomBar = bottomBar,
        floatingActionButton = floatingActionButton,
        snackbarHost = snackbarHost,
        containerColor = GomandapTokens.Colors.pearlWhite,
        content = content
    )
}

/**
 * Drawer content for the Admin app shell.
 * Displays navigation items in a vertical list with GoMandap theming.
 */
@Composable
private fun AdminDrawerContent(
    navItems: List<NavItem>,
    currentRoute: String,
    onItemSelected: (String) -> Unit
) {
    Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xl))

    Text(
        text = "GoMandap Admin",
        style = GomandapTokens.Typography.headlineMedium,
        color = GomandapTokens.Colors.royalNavy,
        modifier = Modifier.padding(horizontal = GomandapTokens.Spacing.md),
        maxLines = 1,
        overflow = TextOverflow.Ellipsis
    )

    Spacer(modifier = Modifier.height(GomandapTokens.Spacing.md))

    navItems.forEach { item ->
        val isSelected = item.route == currentRoute

        NavigationDrawerItem(
            icon = {
                Icon(
                    imageVector = if (isSelected) item.selectedIcon ?: item.icon else item.icon,
                    contentDescription = item.label
                )
            },
            label = {
                Text(
                    text = item.label,
                    style = GomandapTokens.Typography.labelLarge,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            },
            selected = isSelected,
            onClick = { onItemSelected(item.route) },
            modifier = Modifier.padding(NavigationDrawerItemDefaults.ItemPadding),
            colors = NavigationDrawerItemDefaults.colors(
                selectedContainerColor = GomandapTokens.Colors.champagneGoldLight,
                selectedIconColor = GomandapTokens.Colors.champagneGoldDark,
                selectedTextColor = GomandapTokens.Colors.royalNavy,
                unselectedIconColor = GomandapTokens.Colors.slateGray,
                unselectedTextColor = GomandapTokens.Colors.slateGray
            )
        )
    }
}
