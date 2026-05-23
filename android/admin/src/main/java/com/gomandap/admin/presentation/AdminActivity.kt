package com.gomandap.admin.presentation

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.runtime.Composable
import com.gomandap.admin.presentation.navigation.AdminNavGraph
import com.gomandap.admin.data.vendor.VendorRepository
import com.gomandap.app.presentation.theme.GomandapTheme

class AdminActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
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
