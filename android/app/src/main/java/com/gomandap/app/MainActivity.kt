package com.gomandap.app

import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.gomandap.app.data.vendor.VendorRepository
import com.gomandap.app.presentation.navigation.GomandapNavGraph
import com.gomandap.app.presentation.theme.GomandapTheme
import com.gomandap.app.presentation.theme.CreamBg

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        VendorRepository.initialize(applicationContext)

        val window: Window = getWindow()
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
        window.statusBarColor = android.graphics.Color.parseColor("#FBFAEE")

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
            val decor: View = window.decorView
            @Suppress("DEPRECATION")
            decor.systemUiVisibility = View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
        }

        setContent {
            GomandapTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = CreamBg
                ) {
                    GomandapNavGraph()
                }
            }
        }
    }
}
