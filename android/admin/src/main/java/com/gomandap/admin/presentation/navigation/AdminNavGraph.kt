package com.gomandap.admin.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.gomandap.admin.presentation.auth.AdminLoginScreen
import com.gomandap.admin.presentation.dashboard.DashboardScreen
import com.gomandap.admin.presentation.vendors.VendorListScreen
import com.gomandap.admin.presentation.vendors.VendorEditScreen
import com.gomandap.admin.presentation.categories.CategoryScreen
import com.gomandap.admin.presentation.bookings.BookingListScreen

// Define routes
private object AdminDestinations {
    const val Login = "admin_login"
    const val Dashboard = "admin_dashboard"
    const val VendorList = "admin_vendors"
    const val VendorEdit = "admin_vendor_edit/{vendorId}"
    const val Category = "admin_categories"
    const val BookingList = "admin_bookings"
}

@Composable
fun AdminNavGraph(startDestination: String = AdminDestinations.Login) {
    val navController = rememberNavController()
    NavHost(navController = navController, startDestination = startDestination) {
        composable(AdminDestinations.Login) {
            AdminLoginScreen(
                onLoginSuccess = {
                    navController.navigate(AdminDestinations.Dashboard) {
                        popUpTo(AdminDestinations.Login) { inclusive = true }
                    }
                }
            )
        }
        composable(AdminDestinations.Dashboard) {
            DashboardScreen(onNavigate = { route -> navController.navigate(route) })
        }
        composable(AdminDestinations.VendorList) {
            VendorListScreen(onNavigate = { route -> navController.navigate(route) })
        }
        composable(AdminDestinations.VendorEdit) { backStackEntry ->
            val vendorId = backStackEntry.arguments?.getString("vendorId") ?: ""
            VendorEditScreen(vendorId = vendorId, onBack = { navController.popBackStack() })
        }
        composable(AdminDestinations.Category) {
            CategoryScreen(onBack = { navController.popBackStack() })
        }
        composable(AdminDestinations.BookingList) {
            BookingListScreen(onBack = { navController.popBackStack() })
        }
    }
}

// Helper extension for navigation from screens
fun navigateToVendorEdit(navController: NavHostController, vendorId: String) {
    navController.navigate("admin_vendor_edit/$vendorId")
}
