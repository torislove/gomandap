package com.gomandap.admin.presentation.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(onNavigate: (String) -> Unit) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("GoMandap ", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 20.sp)
                        Text("Admin", fontWeight = FontWeight.Black, color = ChampagneGold, fontSize = 20.sp)
                        Spacer(modifier = Modifier.width(6.dp))
                        Box(
                            modifier = Modifier
                                .background(RoyalNavy, RoundedCornerShape(4.dp))
                                .padding(horizontal = 5.dp, vertical = 2.dp)
                        ) {
                            Text("CONSOLE", color = Color.White, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                },
                actions = {
                    IconButton(onClick = {}) {
                        Icon(imageVector = Icons.Default.Notifications, contentDescription = "Alerts", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = PearlWhite
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ─── Stat Banner ───
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(18.dp),
                colors = CardDefaults.cardColors(containerColor = RoyalNavy)
            ) {
                Column(modifier = Modifier.padding(20.dp)) {
                    Text("🔒 Locked in Safe Vault (Total Secure Payments)", color = Color.White.copy(alpha = 0.7f), fontSize = 11.sp)
                    Text("₹5,50,000.00", color = Color.White, fontWeight = FontWeight.Black, fontSize = 28.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text("💰 Pending Payouts", color = Color.White.copy(alpha = 0.5f), fontSize = 10.sp)
                            Text("8 Wedding Vaults", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text("🤝 Paid to Partners", color = Color.White.copy(alpha = 0.5f), fontSize = 10.sp)
                            Text("₹86,000 Disbursed", color = EmeraldGreen, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        }
                    }
                }
            }

            // ─── Q-Commerce Operations Center ───
            Text(text = "Q-Commerce Operations", fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)

            // Surge Pricing Toggle
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = ChampagneGold.copy(alpha=0.1f)),
                border = BorderStroke(1.dp, ChampagneGold.copy(alpha=0.5f))
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.Star, contentDescription = "Surge", tint = ChampagneGold, modifier = Modifier.size(24.dp))
                    Spacer(Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text("🔥 Festive High-Demand Prices", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                        Text("Toggles 1.5x festive price multipliers on auspicious Muhurtham dates.", fontSize = 10.sp, color = SlateGray, lineHeight = 12.sp)
                    }
                    Switch(
                        checked = true,
                        onCheckedChange = {},
                        colors = SwitchDefaults.colors(checkedThumbColor = Color.White, checkedTrackColor = ChampagneGold)
                    )
                }
            }

            // Live Geofenced Events Monitor
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(modifier = Modifier.size(8.dp).background(Color.Red, CircleShape))
                        Spacer(Modifier.width(8.dp))
                        Text("📍 Vendor Arrival Tracker", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                    }
                    Spacer(Modifier.height(12.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Pixel Studios (Photo)", fontSize = 12.sp, color = SlateGray)
                        Text("Arrived 1hr early", fontSize = 12.sp, color = EmeraldGreen, fontWeight = FontWeight.Bold)
                    }
                    Spacer(Modifier.height(8.dp))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Royal Decors (Decor)", fontSize = 12.sp, color = SlateGray)
                        Text("Pending - SLA Delay Alert", fontSize = 12.sp, color = Color.Red, fontWeight = FontWeight.Bold)
                    }
                }
            }

            // Standby Backup Vendors Pool
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = EmeraldGreen.copy(alpha=0.1f)),
                border = BorderStroke(1.dp, EmeraldGreen.copy(alpha=0.4f))
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.Info, contentDescription = "Backup", tint = EmeraldGreen, modifier = Modifier.size(24.dp))
                    Spacer(Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text("🛡️ Ground Ops Backup Pool", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                        Text("12 verified backup partners ready for instant replacement dispatch.", fontSize = 10.sp, color = SlateGray, lineHeight = 12.sp)
                    }
                    Text("Ready", fontWeight = FontWeight.Black, fontSize = 14.sp, color = EmeraldGreen)
                }
            }

            // SLA Penalty Engine
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.Red.copy(alpha=0.05f)),
                border = BorderStroke(1.dp, Color.Red.copy(alpha=0.2f))
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.Settings, contentDescription = "Penalty", tint = Color.Red.copy(alpha=0.7f), modifier = Modifier.size(24.dp))
                    Spacer(Modifier.width(12.dp))
                    Column(modifier = Modifier.weight(1f)) {
                        Text("⚠️ Vendor Quality Control", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                        Text("2 active suspensions for calendar delays. 1 compliance check in progress.", fontSize = 10.sp, color = SlateGray, lineHeight = 12.sp)
                    }
                    Text("Audit", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = Color.Red.copy(alpha=0.7f))
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // ─── Module Navigation Title ───
            Text(text = "Administrative Toolkits", fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)

            // Module 1: Vendors Manager
            AdminModuleCard(
                title = "Vendor & Service Profiles",
                description = "Manage partner statuses, verification, fast-filling parameters, and audit pricing.",
                tag = "VENDORS",
                iconColor = EmeraldGreen,
                onClick = { onNavigate("admin_vendors") }
            )

            // Module 2: Escrow Auditor
            AdminModuleCard(
                title = "Safe Payment Vault Audits",
                description = "Review secure vault balances and authorize payout milestones for active weddings.",
                tag = "VAULTS",
                iconColor = ChampagneGold,
                onClick = { onNavigate("admin_bookings") }
            )

            // Module 3: Categories Configurator
            AdminModuleCard(
                title = "Add & Edit Wedding Services",
                description = "Add or edit categories, custom local package structures, and base plate constraints.",
                tag = "CATALOG",
                iconColor = Color(0xFF8B5CF6),
                onClick = { onNavigate("admin_categories") }
            )

            Spacer(modifier = Modifier.height(24.dp))
        }
    }
}

@Composable
fun AdminModuleCard(
    title: String,
    description: String,
    tag: String,
    iconColor: Color,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(42.dp)
                    .background(iconColor.copy(alpha = 0.1f), CircleShape)
                    .border(1.dp, iconColor.copy(alpha = 0.3f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Box(modifier = Modifier.size(12.dp).background(iconColor, CircleShape))
            }

            Spacer(modifier = Modifier.width(16.dp))

            Column(modifier = Modifier.weight(1f)) {
                Box(
                    modifier = Modifier
                        .background(iconColor.copy(alpha = 0.08f), RoundedCornerShape(4.dp))
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    Text(tag, color = iconColor, fontWeight = FontWeight.Bold, fontSize = 8.sp)
                }
                Spacer(modifier = Modifier.height(4.dp))
                Text(title, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                Text(description, fontSize = 11.sp, color = Color.Gray, lineHeight = 14.sp)
            }

            Spacer(modifier = Modifier.width(8.dp))

            Icon(
                imageVector = Icons.Default.KeyboardArrowRight,
                contentDescription = "Open Module",
                tint = Color.LightGray
            )
        }
    }
}
