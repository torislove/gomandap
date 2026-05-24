package com.gomandap.vendor.presentation.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.HourglassEmpty
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*

@Composable
fun VendorWaitScreen(onLogout: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(SoftMist)
            .padding(24.dp),
        contentAlignment = Alignment.Center
    ) {
        Card(
            shape = RoundedCornerShape(16.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(4.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.HourglassEmpty,
                    contentDescription = "Pending",
                    tint = DarkGold,
                    modifier = Modifier.size(64.dp)
                )
                
                Text(
                    "Verification Pending",
                    fontWeight = FontWeight.Black,
                    fontSize = 20.sp,
                    color = RoyalNavy
                )
                
                Text(
                    "Your storefront application is currently under review by the GoMandap Operations team. This usually takes 24-48 hours.",
                    fontSize = 14.sp,
                    color = SlateGray,
                    textAlign = TextAlign.Center
                )
                
                Spacer(Modifier.height(16.dp))
                
                Button(
                    onClick = onLogout,
                    colors = ButtonDefaults.buttonColors(containerColor = RoseRed),
                    shape = RoundedCornerShape(8.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("Log Out", color = Color.White, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}
