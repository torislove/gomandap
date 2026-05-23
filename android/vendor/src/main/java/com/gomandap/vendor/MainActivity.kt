package com.gomandap.vendor

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.*
import com.gomandap.app.presentation.theme.GomandapTheme
import com.gomandap.vendor.data.vendor.VendorRepository
import com.gomandap.vendor.presentation.auth.VendorLoginScreen
import com.gomandap.vendor.presentation.dashboard.VendorDashboardScreen
import com.gomandap.vendor.presentation.onboard.VendorOnboardScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize local serverless repository cache
        VendorRepository.initialize(applicationContext)

        setContent {
            GomandapTheme {
                var currentScreen by remember { mutableStateOf("LOGIN") } // LOGIN, ONBOARD, DASHBOARD

                when (currentScreen) {
                    "LOGIN" -> {
                        VendorLoginScreen(
                            onLoginSuccess = { isNewPartner ->
                                currentScreen = if (isNewPartner) "ONBOARD" else "DASHBOARD"
                            }
                        )
                    }
                    "ONBOARD" -> {
                        VendorOnboardScreen(
                            onOnboardComplete = {
                                currentScreen = "DASHBOARD"
                            }
                        )
                    }
                    "DASHBOARD" -> {
                        VendorDashboardScreen(
                            onNavigateToOnboard = {
                                currentScreen = "ONBOARD"
                            }
                        )
                    }
                }
            }
        }
    }
}
