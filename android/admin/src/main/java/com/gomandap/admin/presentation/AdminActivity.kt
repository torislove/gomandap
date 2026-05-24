package com.gomandap.admin.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import com.gomandap.admin.presentation.navigation.AdminNavGraph
import com.gomandap.admin.data.vendor.VendorRepository
import com.gomandap.common.design.GomandapTheme
import com.gomandap.common.ui.performance.SplashScreenSetup

class AdminActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        SplashScreenSetup.install(this)
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        com.gomandap.admin.data.auth.AdminSessionManager.initialize(applicationContext)
        VendorRepository.initialize(applicationContext)
        setContent {
            GomandapTheme {
                AdminNavHost()
            }
        }
    }
}

@Composable
fun AdminNavHost() {
    AdminNavGraph()
}
