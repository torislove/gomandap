package com.gomandap.admin.presentation.dashboard

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.common.design.GomandapTokens

// ─── Data Models ─────────────────────────────────────────────────────────────

data class TodayEvent(
    val id: String,
    val clientName: String,
    val eventType: String,
    val venue: String,
    val time: String,
    val vendorName: String,
    val vendorPhone: String,
    val vendorCategory: String,
    val checkInStatus: CheckInStatus
)

enum class CheckInStatus { Pending, Confirmed, Arrived, Delayed }

data class PendingPayout(
    val id: String,
    val vendorName: String,
    val clientName: String,
    val amount: String,
    val milestone: String,
    val eventDate: String
)

data class PendingApproval(
    val id: String,
    val vendorName: String,
    val category: String,
    val submittedDate: String
)

// ─── Dashboard Screen ─────────────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DashboardScreen(onNavigate: (String) -> Unit) {
    val role = com.gomandap.admin.data.auth.AdminSessionManager.currentRole
    val context = LocalContext.current

    // Sample data — replace with Firestore in production
    val todayEvents = remember {
        listOf(
            TodayEvent("E001", "Priya & Arjun", "Wedding", "Royal Palace Banquet, Hyderabad", "10:00 AM", "Pixel Studios", "+91 98765 43210", "Photography", CheckInStatus.Arrived),
            TodayEvent("E002", "Sneha & Kiran", "Engagement", "The Grand Venue, Secunderabad", "4:00 PM", "Royal Decors", "+91 91234 56789", "Decoration", CheckInStatus.Pending),
            TodayEvent("E003", "Meera & Rahul", "Reception", "Taj Falaknuma, Hyderabad", "7:00 PM", "Spice Garden Catering", "+91 99887 76655", "Catering", CheckInStatus.Delayed)
        )
    }

    val pendingPayouts = remember {
        listOf(
            PendingPayout("P001", "Pixel Studios", "Priya & Arjun", "₹45,000", "Event Completion", "15 Jan 2025"),
            PendingPayout("P002", "Royal Decors", "Sneha & Kiran", "₹28,000", "Setup Confirmed", "18 Jan 2025")
        )
    }

    val pendingApprovals = remember {
        listOf(
            PendingApproval("A001", "Glamour Makeup Studio", "Makeup Artist", "2 days ago"),
            PendingApproval("A002", "Shree Caterers", "Catering", "1 day ago")
        )
    }

    var checkInStates by remember {
        mutableStateOf(todayEvents.associate { it.id to it.checkInStatus })
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            "GoMandap",
                            fontWeight = FontWeight.Black,
                            color = GomandapTokens.Colors.royalNavy,
                            fontSize = 20.sp
                        )
                        Spacer(Modifier.width(4.dp))
                        Surface(
                            color = GomandapTokens.Colors.champagneGold,
                            shape = GomandapTokens.Shapes.small
                        ) {
                            Text(
                                "Admin",
                                color = GomandapTokens.Colors.royalNavy,
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Black,
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                            )
                        }
                    }
                },
                actions = {
                    IconButton(onClick = {}) {
                        Icon(Icons.Default.Notifications, "Alerts", tint = GomandapTokens.Colors.royalNavy)
                    }
                    IconButton(onClick = { onNavigate("admin_settings") }) {
                        Icon(Icons.Default.Settings, "Settings", tint = GomandapTokens.Colors.slateGray)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = GomandapTokens.Colors.pearlWhite)
            )
        },
        containerColor = GomandapTokens.Colors.softMist
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(GomandapTokens.Spacing.md),
            verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.md)
        ) {

            // ─── Greeting ────────────────────────────────────────────────────
            Text(
                "Good morning, $role 👋",
                style = GomandapTokens.Typography.bodyMedium,
                color = GomandapTokens.Colors.slateGray
            )

            // ─── Summary Metric Cards ─────────────────────────────────────────
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
            ) {
                MetricCard(
                    modifier = Modifier.weight(1f),
                    label = "Today's Events",
                    value = "${todayEvents.size}",
                    icon = Icons.Default.Event,
                    color = GomandapTokens.Colors.royalNavy
                )
                MetricCard(
                    modifier = Modifier.weight(1f),
                    label = "Pending Payouts",
                    value = "${pendingPayouts.size}",
                    icon = Icons.Default.AccountBalance,
                    color = GomandapTokens.Colors.champagneGoldDark
                )
                MetricCard(
                    modifier = Modifier.weight(1f),
                    label = "Approvals",
                    value = "${pendingApprovals.size}",
                    icon = Icons.Default.HowToReg,
                    color = GomandapTokens.Colors.emeraldGreen
                )
            }

            // ─── Escrow Balance Banner ────────────────────────────────────────
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = GomandapTokens.Shapes.large,
                colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.royalNavy)
            ) {
                Row(
                    modifier = Modifier.padding(GomandapTokens.Spacing.lg),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            "Escrow Balance",
                            color = Color.White.copy(alpha = 0.6f),
                            fontSize = 12.sp
                        )
                        Text(
                            "₹5,50,000",
                            color = Color.White,
                            fontWeight = FontWeight.Black,
                            fontSize = 28.sp
                        )
                        Spacer(Modifier.height(4.dp))
                        Text(
                            "8 active event wallets · ₹86,000 released this month",
                            color = GomandapTokens.Colors.champagneGoldLight,
                            fontSize = 11.sp
                        )
                    }
                    Icon(
                        Icons.Default.Lock,
                        contentDescription = null,
                        tint = GomandapTokens.Colors.champagneGold,
                        modifier = Modifier.size(36.dp)
                    )
                }
            }

            // ─── TODAY'S EVENT CHECK-INS (Live Ops) ──────────────────────────
            if (role == "Super Admin" || role == "Live Ops Coordinator") {
                SectionHeader(
                    title = "Today's Event Check-ins",
                    subtitle = "${todayEvents.count { checkInStates[it.id] == CheckInStatus.Pending || checkInStates[it.id] == CheckInStatus.Delayed }} pending",
                    icon = Icons.Default.RadioButtonChecked,
                    iconColor = Color.Red
                )

                todayEvents.forEach { event ->
                    val currentStatus = checkInStates[event.id] ?: event.checkInStatus
                    EventCheckInCard(
                        event = event,
                        status = currentStatus,
                        onCallVendor = {
                            val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:${event.vendorPhone}"))
                            context.startActivity(intent)
                        },
                        onMarkArrived = {
                            checkInStates = checkInStates.toMutableMap().apply {
                                put(event.id, CheckInStatus.Arrived)
                            }
                        },
                        onMarkDelayed = {
                            checkInStates = checkInStates.toMutableMap().apply {
                                put(event.id, CheckInStatus.Delayed)
                            }
                        }
                    )
                }
            }

            // ─── MANUAL PAYOUT APPROVALS ──────────────────────────────────────
            if (role == "Super Admin" || role == "Dispute Resolution") {
                SectionHeader(
                    title = "Manual Payout Approvals",
                    subtitle = "${pendingPayouts.size} awaiting review",
                    icon = Icons.Default.AccountBalance,
                    iconColor = GomandapTokens.Colors.champagneGoldDark
                )

                pendingPayouts.forEach { payout ->
                    PayoutApprovalCard(
                        payout = payout,
                        onReview = { onNavigate("admin_bookings") }
                    )
                }
            }

            // ─── PARTNER APPROVALS ────────────────────────────────────────────
            if (role == "Super Admin" || role == "Vendor Manager") {
                SectionHeader(
                    title = "New Partner Applications",
                    subtitle = "${pendingApprovals.size} to review",
                    icon = Icons.Default.HowToReg,
                    iconColor = GomandapTokens.Colors.emeraldGreen
                )

                pendingApprovals.forEach { approval ->
                    PartnerApprovalCard(
                        approval = approval,
                        onReview = { onNavigate("admin_vendors") }
                    )
                }
            }

            // ─── QUICK ACTIONS ────────────────────────────────────────────────
            SectionHeader(
                title = "Quick Actions",
                subtitle = null,
                icon = Icons.Default.GridView,
                iconColor = GomandapTokens.Colors.royalNavy
            )

            // Row 1
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
            ) {
                if (role == "Super Admin" || role == "Vendor Manager") {
                    QuickActionCard(
                        modifier = Modifier.weight(1f),
                        title = "Partner Profiles",
                        icon = Icons.Default.People,
                        color = GomandapTokens.Colors.emeraldGreen,
                        onClick = { onNavigate("admin_vendors") }
                    )
                    QuickActionCard(
                        modifier = Modifier.weight(1f),
                        title = "Onboard Partner",
                        icon = Icons.Default.PersonAdd,
                        color = GomandapTokens.Colors.champagneGoldDark,
                        onClick = { onNavigate("admin_vendor_onboarding") }
                    )
                }
            }

            // Row 2
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
            ) {
                if (role == "Super Admin" || role == "Dispute Resolution") {
                    QuickActionCard(
                        modifier = Modifier.weight(1f),
                        title = "CRM Directory",
                        icon = Icons.Default.ContactPhone,
                        color = Color(0xFFFF9F43),
                        onClick = { onNavigate("admin_crm_contacts") }
                    )
                    QuickActionCard(
                        modifier = Modifier.weight(1f),
                        title = "Interaction Log",
                        icon = Icons.Default.History,
                        color = Color(0xFF8B5CF6),
                        onClick = { onNavigate("admin_crm_interactions") }
                    )
                }
            }

            // Row 3
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
            ) {
                if (role == "Super Admin" || role == "Vendor Manager") {
                    QuickActionCard(
                        modifier = Modifier.weight(1f),
                        title = "Service Catalog",
                        icon = Icons.Default.Category,
                        color = Color(0xFFFF7675),
                        onClick = { onNavigate("admin_categories") }
                    )
                }
                if (role == "Super Admin") {
                    QuickActionCard(
                        modifier = Modifier.weight(1f),
                        title = "Featured Vendors",
                        icon = Icons.Default.Star,
                        color = Color(0xFFE056FD),
                        onClick = { onNavigate("admin_storefront_cms") }
                    )
                }
            }

            // Row 4 — Live Ops
            if (role == "Super Admin" || role == "Live Ops Coordinator") {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
                ) {
                    QuickActionCard(
                        modifier = Modifier.weight(1f),
                        title = "Emergency Contacts",
                        icon = Icons.Default.SupportAgent,
                        color = Color(0xFFEF4444),
                        onClick = { onNavigate("admin_liveops_radar") }
                    )
                    QuickActionCard(
                        modifier = Modifier.weight(1f),
                        title = "Payout Audits",
                        icon = Icons.Default.Payments,
                        color = Color(0xFF3B82F6),
                        onClick = { onNavigate("admin_bookings") }
                    )
                }
            }

            Spacer(Modifier.height(GomandapTokens.Spacing.xl))
        }
    }
}

// ─── Reusable Components ──────────────────────────────────────────────────────

@Composable
private fun SectionHeader(
    title: String,
    subtitle: String?,
    icon: ImageVector,
    iconColor: Color
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xs)
    ) {
        Icon(icon, null, tint = iconColor, modifier = Modifier.size(18.dp))
        Column {
            Text(title, fontWeight = FontWeight.Black, fontSize = 15.sp, color = GomandapTokens.Colors.royalNavy)
            if (subtitle != null) {
                Text(subtitle, fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
            }
        }
    }
}

@Composable
private fun MetricCard(
    modifier: Modifier = Modifier,
    label: String,
    value: String,
    icon: ImageVector,
    color: Color
) {
    Card(
        modifier = modifier,
        shape = GomandapTokens.Shapes.large,
        colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
        elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.low)
    ) {
        Column(
            modifier = Modifier.padding(GomandapTokens.Spacing.sm),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .background(color.copy(alpha = 0.1f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(icon, null, tint = color, modifier = Modifier.size(18.dp))
            }
            Spacer(Modifier.height(4.dp))
            Text(value, fontWeight = FontWeight.Black, fontSize = 20.sp, color = color)
            Text(label, fontSize = 9.sp, color = GomandapTokens.Colors.slateGray, maxLines = 1, overflow = TextOverflow.Ellipsis)
        }
    }
}

@Composable
private fun EventCheckInCard(
    event: TodayEvent,
    status: CheckInStatus,
    onCallVendor: () -> Unit,
    onMarkArrived: () -> Unit,
    onMarkDelayed: () -> Unit
) {
    val statusColor = when (status) {
        CheckInStatus.Arrived -> GomandapTokens.Colors.emeraldGreen
        CheckInStatus.Delayed -> GomandapTokens.Colors.error
        CheckInStatus.Confirmed -> GomandapTokens.Colors.champagneGoldDark
        CheckInStatus.Pending -> GomandapTokens.Colors.slateGray
    }
    val statusLabel = when (status) {
        CheckInStatus.Arrived -> "✓ Arrived"
        CheckInStatus.Delayed -> "⚠ Delayed"
        CheckInStatus.Confirmed -> "✓ Confirmed"
        CheckInStatus.Pending -> "Pending Call"
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = GomandapTokens.Shapes.large,
        colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
        elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.low)
    ) {
        Column(modifier = Modifier.padding(GomandapTokens.Spacing.md)) {
            // Header row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(event.clientName, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                    Text("${event.eventType} · ${event.time}", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                }
                Surface(
                    color = statusColor.copy(alpha = 0.1f),
                    shape = GomandapTokens.Shapes.pill
                ) {
                    Text(
                        statusLabel,
                        color = statusColor,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
            }

            Spacer(Modifier.height(GomandapTokens.Spacing.xs))

            // Vendor info
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Person, null, tint = GomandapTokens.Colors.slateGray, modifier = Modifier.size(14.dp))
                Spacer(Modifier.width(4.dp))
                Text("${event.vendorName} · ${event.vendorCategory}", fontSize = 12.sp, color = GomandapTokens.Colors.slateGray)
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Place, null, tint = GomandapTokens.Colors.slateGray, modifier = Modifier.size(14.dp))
                Spacer(Modifier.width(4.dp))
                Text(event.venue, fontSize = 11.sp, color = GomandapTokens.Colors.slateGray, maxLines = 1, overflow = TextOverflow.Ellipsis)
            }

            Spacer(Modifier.height(GomandapTokens.Spacing.sm))

            // Action buttons
            if (status == CheckInStatus.Pending || status == CheckInStatus.Delayed) {
                Row(horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xs)) {
                    Button(
                        onClick = onCallVendor,
                        colors = ButtonDefaults.buttonColors(containerColor = GomandapTokens.Colors.royalNavy),
                        shape = GomandapTokens.Shapes.medium,
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp),
                        modifier = Modifier.height(34.dp)
                    ) {
                        Icon(Icons.Default.Phone, null, modifier = Modifier.size(14.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("Call Vendor", fontSize = 11.sp, fontWeight = FontWeight.Bold)
                    }
                    OutlinedButton(
                        onClick = onMarkArrived,
                        shape = GomandapTokens.Shapes.medium,
                        border = BorderStroke(1.dp, GomandapTokens.Colors.emeraldGreen),
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp),
                        modifier = Modifier.height(34.dp)
                    ) {
                        Text("Mark Arrived", fontSize = 11.sp, color = GomandapTokens.Colors.emeraldGreen, fontWeight = FontWeight.Bold)
                    }
                    if (status != CheckInStatus.Delayed) {
                        TextButton(
                            onClick = onMarkDelayed,
                            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 6.dp),
                            modifier = Modifier.height(34.dp)
                        ) {
                            Text("Delay", fontSize = 11.sp, color = GomandapTokens.Colors.error)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun PayoutApprovalCard(
    payout: PendingPayout,
    onReview: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
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
                    .size(44.dp)
                    .background(GomandapTokens.Colors.champagneGoldLight, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.AccountBalance, null, tint = GomandapTokens.Colors.champagneGoldDark, modifier = Modifier.size(22.dp))
            }
            Spacer(Modifier.width(GomandapTokens.Spacing.sm))
            Column(modifier = Modifier.weight(1f)) {
                Text(payout.vendorName, fontWeight = FontWeight.Bold, fontSize = 13.sp, color = GomandapTokens.Colors.royalNavy)
                Text("${payout.milestone} · ${payout.eventDate}", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                Text("Client: ${payout.clientName}", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
            }
            Column(horizontalAlignment = Alignment.End) {
                Text(payout.amount, fontWeight = FontWeight.Black, fontSize = 15.sp, color = GomandapTokens.Colors.emeraldGreen)
                Spacer(Modifier.height(4.dp))
                TextButton(
                    onClick = onReview,
                    contentPadding = PaddingValues(horizontal = 8.dp, vertical = 2.dp)
                ) {
                    Text("Review →", fontSize = 11.sp, color = GomandapTokens.Colors.royalNavy, fontWeight = FontWeight.Bold)
                }
            }
        }
    }
}

@Composable
private fun PartnerApprovalCard(
    approval: PendingApproval,
    onReview: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
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
                    .size(44.dp)
                    .background(GomandapTokens.Colors.emeraldGreenLight, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(Icons.Default.HowToReg, null, tint = GomandapTokens.Colors.emeraldGreenDark, modifier = Modifier.size(22.dp))
            }
            Spacer(Modifier.width(GomandapTokens.Spacing.sm))
            Column(modifier = Modifier.weight(1f)) {
                Text(approval.vendorName, fontWeight = FontWeight.Bold, fontSize = 13.sp, color = GomandapTokens.Colors.royalNavy)
                Text(approval.category, fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                Text("Submitted ${approval.submittedDate}", fontSize = 10.sp, color = GomandapTokens.Colors.slateGray)
            }
            TextButton(
                onClick = onReview,
                contentPadding = PaddingValues(horizontal = 8.dp, vertical = 2.dp)
            ) {
                Text("Review →", fontSize = 11.sp, color = GomandapTokens.Colors.royalNavy, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
private fun QuickActionCard(
    modifier: Modifier = Modifier,
    title: String,
    icon: ImageVector,
    color: Color,
    onClick: () -> Unit
) {
    Card(
        modifier = modifier.clickable { onClick() },
        shape = GomandapTokens.Shapes.large,
        colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
        elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.low)
    ) {
        Row(
            modifier = Modifier.padding(GomandapTokens.Spacing.sm),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xs)
        ) {
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .background(color.copy(alpha = 0.1f), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(icon, null, tint = color, modifier = Modifier.size(18.dp))
            }
            Text(
                title,
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold,
                color = GomandapTokens.Colors.royalNavy,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier.weight(1f)
            )
        }
    }
}
