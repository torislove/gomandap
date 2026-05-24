package com.gomandap.vendor

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.*
import com.gomandap.common.design.GomandapTheme
import com.gomandap.common.ui.performance.SplashScreenSetup
import com.gomandap.vendor.data.vendor.VendorRepository
import com.gomandap.vendor.presentation.auth.VendorLoginScreen
import com.gomandap.vendor.presentation.dashboard.VendorDashboardScreen
import com.gomandap.vendor.presentation.onboard.VendorOnboardScreen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        SplashScreenSetup.install(this)
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        // Initialize local serverless repository cache
        VendorRepository.initialize(applicationContext)

        setContent {
            GomandapTheme {
                val vendors by VendorRepository.vendors.collectAsState()
                var currentScreen by remember { mutableStateOf("LOGIN") } // LOGIN, ONBOARD, WAIT, DASHBOARD

                when (currentScreen) {
                    "LOGIN" -> {
                        VendorLoginScreen(
                            onLoginSuccess = { isNewPartner ->
                                if (isNewPartner) {
                                    currentScreen = "ONBOARD"
                                } else {
                                    // In a real app, we'd query by logged in user ID. Here we mock it by checking if any vendor exists.
                                    val vendor = vendors.firstOrNull()
                                    if (vendor == null) {
                                        currentScreen = "ONBOARD"
                                    } else if (vendor.approvalStatus == com.gomandap.app.domain.model.ApprovalStatus.APPROVED) {
                                        currentScreen = "DASHBOARD"
                                    } else {
                                        currentScreen = "WAIT"
                                    }
                                }
                            }
                        )
                    }
                    "ONBOARD" -> {
                        VendorOnboardScreen(
                            onOnboardComplete = {
                                currentScreen = "WAIT"
                            }
                        )
                    }
                    "WAIT" -> {
                        com.gomandap.vendor.presentation.auth.VendorWaitScreen(
                            onLogout = { currentScreen = "LOGIN" }
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
