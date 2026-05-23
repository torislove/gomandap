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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val RoyalNavy     = Color(0xFF0F172A)
private val EmeraldGreen  = Color(0xFF10B981)
private val ChampagneGold = Color(0xFFDFBA73)
private val DarkGold      = Color(0xFFC59A48)
private val SlateGray     = Color(0xFF64748B)
private val PearlWhite    = Color(0xFFF8F9FA)
private val IceBg         = Color(0xFFF8FAFC)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(onLogout: () -> Unit = {}) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("My Account", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 20.sp) },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = IceBg
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
        ) {
            // ── Profile Header ───────────────────────────────────────────
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        Brush.horizontalGradient(listOf(RoyalNavy, Color(0xFF1E3A5F)))
                    )
                    .padding(24.dp),
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier.size(68.dp)
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
                        Surface(color = ChampagneGold.copy(0.2f), shape = RoundedCornerShape(6.dp),
                            border = BorderStroke(1.dp, ChampagneGold.copy(0.5f))) {
                            Text(
                                "⚡ Quick Commerce Member",
                                fontSize = 10.sp, fontWeight = FontWeight.Bold, color = ChampagneGold,
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            // ── Escrow Wallet Card ───────────────────────────────────────
            Card(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(2.dp)
            ) {
                Column(modifier = Modifier.padding(18.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Lock, null, tint = ChampagneGold, modifier = Modifier.size(20.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Gomandap Escrow Wallet", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                    }
                    Spacer(Modifier.height(14.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        EscrowStat(label = "Held in Escrow", value = "₹2,21,840", color = ChampagneGold)
                        EscrowStat(label = "Released", value = "₹86,000", color = EmeraldGreen)
                        EscrowStat(label = "Pending", value = "₹55,460", color = SlateGray)
                    }
                    Spacer(Modifier.height(14.dp))
                    Divider(color = Color(0xFFE2E8F0))
                    Spacer(Modifier.height(10.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Security, null, tint = EmeraldGreen, modifier = Modifier.size(14.dp))
                        Spacer(Modifier.width(6.dp))
                        Text(
                            "Funds released 24 hours after event completion",
                            fontSize = 11.sp, color = SlateGray
                        )
                    }
                }
            }

            Spacer(Modifier.height(20.dp))

            // ── Account Settings ─────────────────────────────────────────
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

            Spacer(Modifier.height(16.dp))

            // ── Logout ───────────────────────────────────────────────────
            OutlinedButton(
                onClick = onLogout,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .height(50.dp),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = RoyalNavy),
                border = BorderStroke(1.dp, Color(0xFFE2E8F0))
            ) {
                Icon(Icons.Default.Logout, null, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(8.dp))
                Text("Log Out", fontWeight = FontWeight.Bold, fontSize = 14.sp)
            }

            Spacer(Modifier.height(32.dp))
        }
    }
}

@Composable
private fun ProfileSectionTitle(title: String) {
    Text(
        title,
        fontWeight = FontWeight.Black,
        fontSize = 13.sp,
        color = SlateGray,
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
        Row(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier.size(38.dp)
                    .background(PearlWhite, RoundedCornerShape(10.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(icon, null, tint = RoyalNavy, modifier = Modifier.size(18.dp))
            }
            Spacer(Modifier.width(14.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(title, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, color = RoyalNavy)
                Text(subtitle, fontSize = 11.sp, color = SlateGray)
            }
            Icon(Icons.Default.ChevronRight, null, tint = SlateGray, modifier = Modifier.size(18.dp))
        }
        Divider(color = Color(0xFFF1F5F9), modifier = Modifier.padding(start = 68.dp))
    }
}

@Composable
private fun EscrowStat(label: String, value: String, color: Color) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text(value, fontWeight = FontWeight.Black, fontSize = 16.sp, color = color)
        Text(label, fontSize = 9.sp, color = SlateGray, textAlign = androidx.compose.ui.text.style.TextAlign.Center)
    }
}
