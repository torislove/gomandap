@file:OptIn(ExperimentalMaterial3Api::class)
package com.gomandap.app.presentation.navigation

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.ui.unit.dp
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.gomandap.app.presentation.bookings.BookingsScreen
import com.gomandap.app.presentation.cart.EventCartScreen
import com.gomandap.app.presentation.checkout.BookingCheckoutScreen
import com.gomandap.app.presentation.detail.VenueDetailScreen
import com.gomandap.app.presentation.home.HomeScreen
import com.gomandap.app.presentation.home.HomeViewModel
import com.gomandap.app.presentation.profile.ProfileScreen
import com.gomandap.app.presentation.search.SearchScreen
import com.gomandap.app.presentation.auth.LoginScreen
import com.gomandap.app.presentation.onboarding.EventCategoryScreen
import com.gomandap.app.presentation.onboarding.EventDateScreen
import com.gomandap.app.presentation.escrow.EscrowTrackerScreen
import com.gomandap.app.presentation.escrow.EscrowViewModel
import com.gomandap.app.presentation.wishlist.WishlistScreen
import com.gomandap.app.presentation.theme.*


// ── Bottom Nav Tab Definitions ────────────────────────────────────────────────
private data class BottomTab(
    val route: String,
    val label: String,
    val selectedIcon: ImageVector,
    val unselectedIcon: ImageVector
)

private val bottomTabs = listOf(
    BottomTab("home",     "Home",     Icons.Filled.Home,             Icons.Outlined.Home),
    BottomTab("wishlist", "Saved",    Icons.Filled.Favorite,         Icons.Outlined.FavoriteBorder),
    BottomTab("cart",     "Cart",     Icons.Filled.ShoppingCart,     Icons.Outlined.ShoppingCart),
    BottomTab("bookings", "Bookings", Icons.Filled.CalendarMonth,    Icons.Outlined.CalendarMonth),
    BottomTab("profile",  "Profile",  Icons.Filled.Person,           Icons.Outlined.Person),
)

@Composable
fun GomandapNavGraph() {
    val rootNavController = rememberNavController()

    // Auth screens shown first, without bottom bar
    NavHost(navController = rootNavController, startDestination = "login") {
        composable("login") {
            LoginScreen(
                onLoginSuccess = {
                    rootNavController.navigate("onboarding_category") {
                        popUpTo("login") { inclusive = true }
                    }
                },
                onSkipClick = {
                    rootNavController.navigate("main") {
                        popUpTo("login") { inclusive = true }
                    }
                }
            )
        }

        composable("onboarding_category") {
            EventCategoryScreen(
                onNext = { rootNavController.navigate("onboarding_date") },
                onSkipClick = {
                    rootNavController.navigate("main") {
                        popUpTo("onboarding_category") { inclusive = true }
                    }
                }
            )
        }

        composable("onboarding_date") {
            EventDateScreen(
                onConfirm = {
                    rootNavController.navigate("main") {
                        popUpTo("onboarding_category") { inclusive = true }
                    }
                },
                onSkipClick = {
                    rootNavController.navigate("main") {
                        popUpTo("onboarding_category") { inclusive = true }
                    }
                }
            )
        }

        // ── Main shell with bottom navigation ────────────────────────────
        composable("main") {
            MainShell()
        }
    }
}

// ── Main Shell: Scaffold + 5-Tab NavigationBar ───────────────────────────────
@Composable
fun MainShell() {
    val navController = rememberNavController()
    val homeViewModel: HomeViewModel = viewModel()
    val homeUiState by homeViewModel.uiState.collectAsState()
    var currentTab by remember { mutableStateOf("home") }

    // Keep currentTab in sync with the back stack
    LaunchedEffect(navController) {
        navController.currentBackStackEntryFlow.collect { entry ->
            val route = entry.destination.route
            bottomTabs.firstOrNull { it.route == route }?.let { currentTab = it.route }
        }
    }

    Scaffold(
        containerColor = Color.White,
        bottomBar = {
            NavigationBar(
                containerColor = Color.White,
                tonalElevation = 8.dp
            ) {
                bottomTabs.forEach { tab ->
                    val isSelected = currentTab == tab.route
                    NavigationBarItem(
                        selected = isSelected,
                        onClick = {
                            currentTab = tab.route
                            navController.navigate(tab.route) {
                                popUpTo("home") { saveState = true }
                                launchSingleTop = true
                                restoreState = true
                            }
                        },
                        icon = {
                            // Cart gets a special badge
                            if (tab.route == "cart") {
                                BadgedBox(badge = {
                                    Badge { Text("2") }
                                }) {
                                    Icon(
                                        if (isSelected) tab.selectedIcon else tab.unselectedIcon,
                                        contentDescription = tab.label
                                    )
                                }
                            } else {
                                Icon(
                                    if (isSelected) tab.selectedIcon else tab.unselectedIcon,
                                    contentDescription = tab.label
                                )
                            }
                        },
                        label = {
                            Text(
                                tab.label,
                                fontSize = 10.sp,
                                fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal
                            )
                        },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor   = RoyalNavy,
                            selectedTextColor   = RoyalNavy,
                            indicatorColor      = ChampagneGold.copy(alpha = 0.15f),
                            unselectedIconColor = SlateGray,
                            unselectedTextColor = SlateGray
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding)) {
            NavHost(
                navController = navController,
                startDestination = "home"
            ) {
                // ── Tab: Home ─────────────────────────────────────────────
                composable("home") {
                    HomeScreen(
                        onCategoryTap = { category ->
                            navController.navigate("search?category=$category")
                        },
                        onVenueTap = { venueId ->
                            navController.navigate("venue_details/$venueId")
                        },
                        onCartTap = {
                            navController.navigate("cart")
                        },
                        onSearchClick = {
                            navController.navigate("search")
                        },
                        viewModel = homeViewModel
                    )
                }

                // ── Tab: Saved / Wishlist ─────────────────────────────────
                composable("wishlist") {
                    WishlistScreen(
                        wishlistedIds = homeUiState.wishlistedIds,
                        onVendorTap = { venueId ->
                            navController.navigate("venue_details/$venueId")
                        },
                        onRemove = { venueId ->
                            homeViewModel.toggleWishlist(venueId)
                        }
                    )
                }

                // ── Tab: Cart ─────────────────────────────────────────────
                composable("cart") {
                    EventCartScreen(
                        onBackClick = { navController.popBackStack() },
                        onCheckoutClick = {
                            navController.navigate("checkout/cart-bundle")
                        }
                    )
                }

                // ── Tab: Bookings ─────────────────────────────────────────
                composable("bookings") {
                    BookingsScreen(
                        onTrackVendor = { bookingId ->
                            // No tracking - just navigate to escrow tracker
                            navController.navigate("escrow_tracker/$bookingId")
                        }
                    )
                }

                // ── Tab: Profile ──────────────────────────────────────────
                composable("profile") {
                    ProfileScreen(
                        onLogout = {
                            navController.navigate("home") {
                                popUpTo("home") { inclusive = true }
                            }
                        }
                    )
                }

                // ── Detail & Flow screens ─────────────────────────────────
                composable(
                    route = "search?category={category}",
                    arguments = listOf(navArgument("category") { defaultValue = "Venues" })
                ) { backStackEntry ->
                    val category = backStackEntry.arguments?.getString("category") ?: "Venues"
                    SearchScreen(
                        initialCategory = category,
                        onBackClick = { navController.popBackStack() },
                        onVenueTap = { venueId ->
                            navController.navigate("venue_details/$venueId")
                        }
                    )
                }

                composable("venue_details/{venueId}") { backStackEntry ->
                    val venueId = backStackEntry.arguments?.getString("venueId") ?: ""
                    VenueDetailScreen(
                        venueId = venueId,
                        onBackClick = { navController.popBackStack() },
                        onBookNowClick = { navController.navigate("checkout/$venueId") }
                    )
                }

                composable("checkout/{venueId}") { backStackEntry ->
                    val venueId = backStackEntry.arguments?.getString("venueId") ?: ""
                    BookingCheckoutScreen(
                        venueId = venueId,
                        onCheckoutSuccess = {
                            navController.navigate("escrow_tracker/BK-1082") {
                                popUpTo("home")
                            }
                        },
                        onBackClick = { navController.popBackStack() }
                    )
                }

                composable("escrow_tracker/{bookingId}") { backStackEntry ->
                    val bookingId = backStackEntry.arguments?.getString("bookingId") ?: "BK-1082"
                    val escrowViewModel: EscrowViewModel = viewModel()
                    LaunchedEffect(bookingId) {
                        escrowViewModel.loadEscrowDetails(bookingId)
                    }
                    EscrowTrackerScreen(
                        bookingId = bookingId,
                        viewModel = escrowViewModel
                    )
                }
            }
        }
    }
}
