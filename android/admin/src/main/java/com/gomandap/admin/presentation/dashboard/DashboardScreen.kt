package com.gomandap.admin.presentation.dashboard

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.Image
import androidx.compose.ui.res.painterResource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.animation.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import android.widget.Toast
import com.gomandap.common.design.GomandapTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(onNavigate: (String) -> Unit) {
    val scope = rememberCoroutineScope()
    val haptic = LocalHapticFeedback.current

    // SLA Ping States
    var isPingRunning by remember { mutableStateOf(false) }
    var pingProgress by remember { mutableStateOf(0f) }
    var pingStatus by remember { mutableStateOf("") }
    var pingCompleted by remember { mutableStateOf(false) }

    // Standby Dispatch States
    var isDispatchRunning by remember { mutableStateOf(false) }
    var dispatchStatus by remember { mutableStateOf("") }
    var dispatchCompleted by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Image(
                            painter = painterResource(id = com.gomandap.common.R.drawable.ic_gm_logo),
                            contentDescription = "GM Logo",
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("GM ", fontWeight = FontWeight.Black, color = GomandapTokens.Colors.royalNavy, fontSize = 20.sp)
                        Text("Admin", fontWeight = FontWeight.Black, color = GomandapTokens.Colors.champagneGold, fontSize = 20.sp)
                        Spacer(modifier = Modifier.width(6.dp))
                        Box(
                            modifier = Modifier
                                .background(GomandapTokens.Colors.royalNavy, GomandapTokens.Shapes.small)
                                .padding(horizontal = 5.dp, vertical = 2.dp)
                        ) {
                            Text("CONSOLE", color = GomandapTokens.Colors.pearlWhite, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                },
                actions = {
                    IconButton(onClick = {}) {
                        Icon(imageVector = Icons.Default.Notifications, contentDescription = "Alerts", tint = GomandapTokens.Colors.royalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = GomandapTokens.Colors.pearlWhite)
            )
        },
        containerColor = GomandapTokens.Colors.pearlWhite
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(GomandapTokens.Spacing.md),
            verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.md)
        ) {
            // ─── Stat Banner ───
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = GomandapTokens.Shapes.large,
                colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.royalNavy)
            ) {
                Column(modifier = Modifier.padding(GomandapTokens.Spacing.lg)) {
                    Text("🔒 Secure Event Escrow Balance (Protected Client Funds)", color = Color.White.copy(alpha = 0.7f), fontSize = 11.sp)
                    Text("₹5,50,000.00", color = Color.White, fontWeight = FontWeight.Black, fontSize = 28.sp)
                    Spacer(modifier = Modifier.height(GomandapTokens.Spacing.sm))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column {
                            Text("💰 Active Booking Escrows", color = Color.White.copy(alpha = 0.5f), fontSize = 10.sp)
                            Text("8 Event Wallets", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        }
                        Column(horizontalAlignment = Alignment.End) {
                            Text("🤝 Released to Partners", color = Color.White.copy(alpha = 0.5f), fontSize = 10.sp)
                            Text("₹86,000 Disbursed", color = GomandapTokens.Colors.emeraldGreen, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                        }
                    }
                }
            }

            // ─── Q-Commerce Operations Center ───
            Text(text = "Ground Operations Management", fontWeight = FontWeight.Black, fontSize = 16.sp, color = GomandapTokens.Colors.royalNavy)

            // Surge Pricing Toggle
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = GomandapTokens.Shapes.large,
                colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.champagneGold.copy(alpha = 0.1f)),
                border = BorderStroke(1.dp, GomandapTokens.Colors.champagneGold.copy(alpha = 0.5f))
            ) {
                Row(
                    modifier = Modifier.padding(GomandapTokens.Spacing.md),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(Icons.Default.Star, contentDescription = "Surge", tint = GomandapTokens.Colors.champagneGold, modifier = Modifier.size(24.dp))
                    Spacer(Modifier.width(GomandapTokens.Spacing.sm))
                    Column(modifier = Modifier.weight(1f)) {
                        Text("🔥 High-Demand Festive Pricing", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                        Text("Activate a 1.5x price multiplier during auspicious wedding dates.", fontSize = 10.sp, color = GomandapTokens.Colors.slateGray, lineHeight = 12.sp)
                    }
                    Switch(
                        checked = true,
                        onCheckedChange = {},
                        colors = SwitchDefaults.colors(checkedThumbColor = Color.White, checkedTrackColor = GomandapTokens.Colors.champagneGold)
                    )
                }
            }

            // Live Geofenced Events Monitor
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = GomandapTokens.Shapes.large,
                colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
                elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.low)
            ) {
                Column(modifier = Modifier.padding(GomandapTokens.Spacing.md)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(modifier = Modifier.size(8.dp).background(Color.Red, CircleShape))
                        Spacer(Modifier.width(GomandapTokens.Spacing.xs))
                        Text("📍 Live Partner Arrival Tracker", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                    }
                    Spacer(Modifier.height(GomandapTokens.Spacing.sm))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Pixel Studios (Photography)", fontSize = 12.sp, color = GomandapTokens.Colors.slateGray)
                        Text("Arrived 1 hour early", fontSize = 12.sp, color = GomandapTokens.Colors.emeraldGreen, fontWeight = FontWeight.Bold)
                    }
                    Spacer(Modifier.height(GomandapTokens.Spacing.xs))
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Royal Decors (Flower Setup)", fontSize = 12.sp, color = GomandapTokens.Colors.slateGray)
                        Text("Pending Arrival - SLA Delay Alert", fontSize = 12.sp, color = GomandapTokens.Colors.error, fontWeight = FontWeight.Bold)
                    }
                }
            }

            // Standby Backup geohash dispatch router (Task 3.4)
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = GomandapTokens.Shapes.large,
                colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.emeraldGreen.copy(alpha = 0.1f)),
                border = BorderStroke(1.dp, GomandapTokens.Colors.emeraldGreen.copy(alpha = 0.4f))
            ) {
                Column(modifier = Modifier.padding(GomandapTokens.Spacing.md), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
                    ) {
                        Icon(Icons.Default.Info, contentDescription = "Backup", tint = GomandapTokens.Colors.emeraldGreen, modifier = Modifier.size(24.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text("🛡️ Backup Partner Dispatch Router", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                            Text("Broadcast emergency standby alerts within 15km geohash bounds if primary bookings cancel.", fontSize = 10.sp, color = GomandapTokens.Colors.slateGray, lineHeight = 12.sp)
                        }
                        
                        Button(
                            onClick = {
                                if (isDispatchRunning) return@Button
                                isDispatchRunning = true
                                dispatchStatus = "Cancellation alert received. Scanning geohash bounds..."
                                dispatchCompleted = false
                                scope.launch {
                                    delay(1800)
                                    dispatchStatus = "Resolving nearby vetted candidates within 15km geohash range..."
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                    
                                    delay(2000)
                                    dispatchStatus = "Found 3 standby candidates. Broadcasting broadcast flash..."
                                    
                                    delay(2000)
                                    dispatchStatus = "Success! 'Gala Imperial Hall' accepted dispatch assignment. Booking BK-1082 updated, escrow lock auto-transferred."
                                    dispatchCompleted = true
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                    isDispatchRunning = false
                                }
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = GomandapTokens.Colors.emeraldGreen),
                            shape = GomandapTokens.Shapes.small,
                            enabled = !isDispatchRunning,
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                            modifier = Modifier.height(32.dp)
                        ) {
                            Text(if (isDispatchRunning) "Routing..." else "Simulate", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }

                    AnimatedVisibility(
                        visible = isDispatchRunning || dispatchStatus.isNotEmpty(),
                        enter = fadeIn() + expandVertically(),
                        exit = fadeOut() + shrinkVertically()
                    ) {
                        Column(verticalArrangement = Arrangement.spacedBy(6.dp), modifier = Modifier.fillMaxWidth()) {
                            if (isDispatchRunning) {
                                LinearProgressIndicator(
                                    modifier = Modifier.fillMaxWidth().height(4.dp),
                                    color = GomandapTokens.Colors.emeraldGreen,
                                    trackColor = GomandapTokens.Colors.emeraldGreen.copy(alpha = 0.1f)
                                )
                            }
                            Text(
                                text = dispatchStatus,
                                color = if (dispatchCompleted) GomandapTokens.Colors.emeraldGreen else GomandapTokens.Colors.royalNavy,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                lineHeight = 13.sp
                            )
                        }
                    }
                }
            }

            // SLA Availability Auto-Pings Control Card (Task 3.3)
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = GomandapTokens.Shapes.large,
                colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.error.copy(alpha = 0.05f)),
                border = BorderStroke(1.dp, GomandapTokens.Colors.error.copy(alpha = 0.2f))
            ) {
                Column(modifier = Modifier.padding(GomandapTokens.Spacing.md), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
                    ) {
                        Icon(Icons.Default.Settings, contentDescription = "Penalty", tint = GomandapTokens.Colors.error.copy(alpha = 0.7f), modifier = Modifier.size(24.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text("⚠️ Partner SLA Availability Audits", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                            Text("Automatic background bi-weekly checks. Hide unresponsive listings instantly.", fontSize = 10.sp, color = GomandapTokens.Colors.slateGray, lineHeight = 12.sp)
                        }
                        
                        Button(
                            onClick = {
                                if (isPingRunning) return@Button
                                isPingRunning = true
                                pingProgress = 0f
                                pingStatus = "Initializing bi-weekly compliance handshake..."
                                pingCompleted = false
                                scope.launch {
                                    delay(1500)
                                    pingProgress = 0.3f
                                    pingStatus = "Broadcasting check-in pings to 48 active vendor listings..."
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                    
                                    delay(2000)
                                    pingProgress = 0.7f
                                    pingStatus = "Analyzing latency... 46/48 response rate."
                                    
                                    delay(1800)
                                    pingProgress = 1.0f
                                    pingStatus = "Compliance check completed. 'Venkateshwara Catering' and 'Luxury Cars Mandap' failed check-in validation. Action Taken: Silent listings hidden from search results."
                                    pingCompleted = true
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                    isPingRunning = false
                                }
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = GomandapTokens.Colors.error.copy(alpha = 0.7f)),
                            shape = GomandapTokens.Shapes.small,
                            enabled = !isPingRunning,
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                            modifier = Modifier.height(32.dp)
                        ) {
                            Text(if (isPingRunning) "Running..." else "Audit SLA", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    }

                    AnimatedVisibility(
                        visible = isPingRunning || pingStatus.isNotEmpty(),
                        enter = fadeIn() + expandVertically(),
                        exit = fadeOut() + shrinkVertically()
                    ) {
                        Column(verticalArrangement = Arrangement.spacedBy(6.dp), modifier = Modifier.fillMaxWidth()) {
                            if (isPingRunning) {
                                LinearProgressIndicator(
                                    progress = { pingProgress },
                                    modifier = Modifier.fillMaxWidth().height(4.dp),
                                    color = GomandapTokens.Colors.error.copy(alpha = 0.7f),
                                    trackColor = GomandapTokens.Colors.error.copy(alpha = 0.1f)
                                )
                            }
                            Text(
                                text = pingStatus,
                                color = if (pingCompleted) GomandapTokens.Colors.emeraldGreen else GomandapTokens.Colors.royalNavy,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Bold,
                                lineHeight = 13.sp
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))

            // ─── Module Navigation Title ───
            Text(text = "Administrative Toolkits", fontWeight = FontWeight.Black, fontSize = 16.sp, color = GomandapTokens.Colors.royalNavy)

            // Module 1: Vendors Manager
            AdminModuleCard(
                title = "Partner Profiles Manager",
                description = "Manage partner statuses, verification details, search tags, and starting pricing.",
                tag = "VENDORS",
                iconColor = GomandapTokens.Colors.emeraldGreen,
                onClick = { onNavigate("admin_vendors") }
            )

            // Module 1c: CRM Contacts Directory
            AdminModuleCard(
                title = "Client-Vendor CRM Directory",
                description = "Access complete contact specs, banking payout details, and trigger direct communication alerts.",
                tag = "CRM DATABASE",
                iconColor = Color(0xFFFF9F43),
                onClick = { onNavigate("admin_crm_contacts") }
            )

            // Module 1b: Onboard New Partner
            AdminModuleCard(
                title = "Register & Onboard New Partner",
                description = "Directly create and publish new partners (Banquets, Photo, Decor, Catering, Makeup) with live Verified Badges.",
                tag = "ONBOARD",
                iconColor = GomandapTokens.Colors.champagneGold,
                onClick = { onNavigate("admin_vendor_onboarding") }
            )

            // Module 2: Escrow Auditor
            AdminModuleCard(
                title = "Escrow Payout Audits",
                description = "Review secure event vault balances and release transaction milestone funds for active bookings.",
                tag = "PAYOUTS",
                iconColor = Color(0xFF3B82F6),
                onClick = { onNavigate("admin_bookings") }
            )

            // Module 2b: Platform Interaction Tracker
            AdminModuleCard(
                title = "Platform Interaction Log",
                description = "Audit live client inquires, scheduled visits, escrow locks, and milestone releases.",
                tag = "INTERACTION LOG",
                iconColor = Color(0xFF8B5CF6),
                onClick = { onNavigate("admin_crm_interactions") }
            )

            // Module 3: Categories Configurator
            AdminModuleCard(
                title = "Add & Edit Wedding Services",
                description = "Add or edit categories, custom local package structures, and base plate constraints.",
                tag = "CATALOG",
                iconColor = Color(0xFFFF7675),
                onClick = { onNavigate("admin_categories") }
            )

            // Module 4: Storefront CMS Selector
            AdminModuleCard(
                title = "Storefront CMS & Discovery Override",
                description = "Manage app-carousel scheduling, drop pin hotspot product tags, and algorithmic search boosts.",
                tag = "CMS & TRENDS",
                iconColor = Color(0xFFE056FD),
                onClick = { onNavigate("admin_storefront_cms") }
            )

            // Module 5: Live Event Ops Radar
            AdminModuleCard(
                title = "Event-Day Live Ops Radar",
                description = "Audit partner geofence pre-arrival check-ins, flash SLA breach alerts, and trigger SOS backups.",
                tag = "LIVE FLASHOPS",
                iconColor = Color(0xFFEF4444),
                onClick = { onNavigate("admin_liveops_radar") }
            )

            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xl))
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
        shape = GomandapTokens.Shapes.large,
        colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
        elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.low)
    ) {
        Row(
            modifier = Modifier.padding(GomandapTokens.Spacing.md),
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

            Spacer(modifier = Modifier.width(GomandapTokens.Spacing.md))

            Column(modifier = Modifier.weight(1f)) {
                Box(
                    modifier = Modifier
                        .background(iconColor.copy(alpha = 0.08f), GomandapTokens.Shapes.small)
                        .padding(horizontal = 6.dp, vertical = 2.dp)
                ) {
                    Text(tag, color = iconColor, fontWeight = FontWeight.Bold, fontSize = 8.sp)
                }
                Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xxs))
                Text(title, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                Text(description, fontSize = 11.sp, color = GomandapTokens.Colors.slateGray, lineHeight = 14.sp)
            }

            Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xs))

            Icon(
                imageVector = Icons.Default.KeyboardArrowRight,
                contentDescription = "Open Module",
                tint = GomandapTokens.Colors.lightSlate
            )
        }
    }
}
