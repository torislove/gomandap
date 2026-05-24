package com.gomandap.app.presentation.profile

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(onLogout: () -> Unit = {}) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("My Account Dashboard", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 18.sp) },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White),
                modifier = Modifier.shadow(2.dp)
            )
        },
        containerColor = SoftMist
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
        ) {
            // Profile Header
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        Brush.horizontalGradient(listOf(RoyalNavy, DeepSky))
                    )
                    .drawBehind {
                        val strokeWidth = 1.5.dp.toPx()
                        drawLine(
                            color = ChampagneGold.copy(alpha = 0.35f),
                            start = androidx.compose.ui.geometry.Offset(0f, size.height - strokeWidth / 2),
                            end = androidx.compose.ui.geometry.Offset(size.width, size.height - strokeWidth / 2),
                            strokeWidth = strokeWidth
                        )
                    }
                    .padding(24.dp),
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(68.dp)
                            .background(
                                Brush.linearGradient(listOf(EmeraldGreen, Color(0xFF059669))),
                                CircleShape
                            )
                            .border(3.dp, ChampagneGold, CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("M", fontWeight = FontWeight.Black, fontSize = 28.sp, color = Color.White)
                    }
                    Spacer(Modifier.width(16.dp))
                    Column {
                        Text("Manoj Kumar", fontWeight = FontWeight.Black, fontSize = 18.sp, color = Color.White)
                        Text("+91 98765 43210", fontSize = 12.sp, color = Color.White.copy(0.7f))
                        Spacer(Modifier.height(6.dp))
                        Surface(
                            color = ChampagneGold.copy(0.2f),
                            shape = RoundedCornerShape(6.dp),
                            border = BorderStroke(1.dp, ChampagneGold.copy(0.5f))
                        ) {
                            Text(
                                "⚡ Quick Commerce Member",
                                fontSize = 9.sp,
                                fontWeight = FontWeight.Black,
                                color = ChampagneGold,
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            // Escrow Wallet Card
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .antigravityShadow(borderRadius = 16.dp)
                    .background(Color.White, shape = RoundedCornerShape(16.dp))
                    .border(1.5.dp, ChampagneGold.copy(alpha = 0.25f), shape = RoundedCornerShape(16.dp))
                    .padding(18.dp)
            ) {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(32.dp)
                                .clip(CircleShape)
                                .background(ChampagneGold.copy(alpha = 0.12f)),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Default.Lock, null, tint = DarkGold, modifier = Modifier.size(16.dp))
                        }
                        Spacer(Modifier.width(10.dp))
                        Text("GoMandap Escrow Wallet", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                    }
                    
                    Spacer(Modifier.height(16.dp))
                    
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        EscrowStat(label = "Held in Escrow", value = "₹2,21,840", color = DarkGold)
                        EscrowStat(label = "Released", value = "₹86,000", color = EmeraldGreen)
                        EscrowStat(label = "Pending Due", value = "₹55,460", color = RoyalNavy)
                    }
                    
                    Spacer(Modifier.height(14.dp))
                    Divider(color = LightSlate.copy(alpha = 0.5f))
                    Spacer(Modifier.height(12.dp))
                    
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Security, null, tint = EmeraldGreen, modifier = Modifier.size(14.dp))
                        Spacer(Modifier.width(6.dp))
                        Text(
                            "Safeadvance protection guarantees partner payouts",
                            fontSize = 11.sp,
                            color = SlateGray,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }

            Spacer(Modifier.height(20.dp))

            // Settings Menus
            ProfileSectionTitle("Account")
            ProfileMenuItem(Icons.Default.Person, "Personal Information", "Name, phone, email")
            ProfileMenuItem(Icons.Default.Notifications, "Notifications", "Booking alerts & reminders")
            ProfileMenuItem(Icons.Default.Language, "Preferred Language", "English")

            Spacer(Modifier.height(8.dp))
            ProfileSectionTitle("Payments")
            ProfileMenuItem(Icons.Default.CreditCard, "Saved Payment Methods", "UPI, Cards, Net Banking")
            ProfileMenuItem(Icons.Default.AccountBalanceWallet, "Transaction History", "View all payments")
            ProfileMenuItem(Icons.Default.Receipt, "GST & Invoices", "Download booking receipts")

            Spacer(Modifier.height(8.dp))
            ProfileSectionTitle("Support")
            ProfileMenuItem(Icons.Default.HeadsetMic, "Help & Support", "Chat with GoMandap team")
            ProfileMenuItem(Icons.Default.Policy, "Privacy Policy", "Data usage & terms")
            ProfileMenuItem(Icons.Default.Star, "Rate the App", "Share your feedback")

            Spacer(Modifier.height(20.dp))

            // Logout Button
            OutlinedButton(
                onClick = onLogout,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .height(48.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = RoyalNavy),
                border = BorderStroke(1.5.dp, RoyalNavy.copy(alpha = 0.8f))
            ) {
                Icon(Icons.Default.Logout, null, modifier = Modifier.size(16.dp), tint = RoyalNavy)
                Spacer(Modifier.width(8.dp))
                Text("Log Out Account", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
            }

            Spacer(Modifier.height(32.dp))
        }
    }
}

@Composable
private fun ProfileSectionTitle(title: String) {
    Text(
        text = title.uppercase(),
        fontWeight = FontWeight.Black,
        fontSize = 10.sp,
        color = SlateGray,
        letterSpacing = 0.5.sp,
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
    )
}

@Composable
private fun ProfileMenuItem(icon: ImageVector, title: String, subtitle: String) {
    Surface(
        color = Color.White,
        modifier = Modifier
            .fillMaxWidth()
            .clickable {}
    ) {
        Column {
            Row(
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .background(SoftMist, RoundedCornerShape(10.dp))
                        .border(1.dp, ChampagneGold.copy(alpha = 0.15f), RoundedCornerShape(10.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(icon, null, tint = RoyalNavy, modifier = Modifier.size(16.dp))
                }
                Spacer(Modifier.width(14.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(title, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                    Text(subtitle, fontSize = 11.sp, color = SlateGray, fontWeight = FontWeight.Medium)
                }
                Icon(Icons.Default.ChevronRight, null, tint = SlateGray, modifier = Modifier.size(18.dp))
            }
            Divider(color = SoftMist, modifier = Modifier.padding(start = 66.dp))
        }
    }
}

@Composable
private fun EscrowStat(label: String, value: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, fontWeight = FontWeight.Black, fontSize = 16.sp, color = color)
        Spacer(Modifier.height(2.dp))
        Text(label, fontSize = 10.sp, color = SlateGray, fontWeight = FontWeight.Bold)
    }
}


