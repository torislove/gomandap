package com.gomandap.admin.presentation.bookings

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookingListScreen(onBack: () -> Unit) {
    val scope = rememberCoroutineScope()
    var expandedBookingId by remember { mutableStateOf<String?>(null) }

    // Mock platform bookings state
    var platformBookings by remember {
        mutableStateOf(
            listOf(
                AdminBooking(
                    id = "BK-1082",
                    clientName = "Manoj Kadiyala",
                    venueName = "The Taj Palace Convention",
                    eventDate = "May 28, 2026",
                    totalAmount = 250000.0,
                    milestones = mutableListOf(
                        AdminMilestone("m1", "Booking Lock (20%)", 50000.0, "RELEASED"),
                        AdminMilestone("m2", "Pre-Event Setup (50%)", 125000.0, "HELD"),
                        AdminMilestone("m3", "Final Handover (30%)", 75000.0, "HELD")
                    )
                ),
                AdminBooking(
                    id = "BK-1083",
                    clientName = "Ananya Rao",
                    venueName = "Heritage Gala Resort",
                    eventDate = "June 12, 2026",
                    totalAmount = 180000.0,
                    milestones = mutableListOf(
                        AdminMilestone("m4", "Booking Lock (20%)", 36000.0, "RELEASED"),
                        AdminMilestone("m5", "Pre-Event Setup (50%)", 90000.0, "HELD"),
                        AdminMilestone("m6", "Final Handover (30%)", 54000.0, "HELD")
                    )
                ),
                AdminBooking(
                    id = "BK-1084",
                    clientName = "Rahul Mehta",
                    venueName = "Grand Imperial Gardens",
                    eventDate = "June 25, 2026",
                    totalAmount = 120000.0,
                    milestones = mutableListOf(
                        AdminMilestone("m7", "Booking Lock (20%)", 24000.0, "HELD"),
                        AdminMilestone("m8", "Pre-Event Setup (50%)", 60000.0, "HELD"),
                        AdminMilestone("m9", "Final Handover (30%)", 36000.0, "HELD")
                    )
                )
            )
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Escrow Bookings Audit", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
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
            Text(
                text = "Active Platform Escrow Trusts",
                fontWeight = FontWeight.Black,
                fontSize = 17.sp,
                color = RoyalNavy
            )

            platformBookings.forEach { booking ->
                val isExpanded = expandedBookingId == booking.id
                val releasedAmount = booking.milestones.filter { it.status == "RELEASED" }.sumOf { it.amount }
                val heldAmount = booking.milestones.filter { it.status == "HELD" }.sumOf { it.amount }

                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .border(
                            width = 1.dp,
                            color = if (isExpanded) ChampagneGold.copy(alpha = 0.4f) else Color.Transparent,
                            shape = RoundedCornerShape(16.dp)
                        ),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White)
                ) {
                    Column(
                        modifier = Modifier
                            .clickable { expandedBookingId = if (isExpanded) null else booking.id }
                            .padding(16.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Text(text = booking.id, fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Box(
                                        modifier = Modifier
                                            .background(EmeraldGreen.copy(alpha = 0.1f), RoundedCornerShape(4.dp))
                                            .padding(horizontal = 6.dp, vertical = 2.dp)
                                    ) {
                                        Text("ACTIVE ESCROW", color = EmeraldGreen, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                                    }
                                }
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(text = "Client: ${booking.clientName}", fontSize = 12.sp, color = Color.Gray)
                                Text(text = "Venue: ${booking.venueName}", fontSize = 12.sp, color = Color.Gray)
                            }

                            Icon(
                                imageVector = if (isExpanded) Icons.Default.KeyboardArrowUp else Icons.Default.KeyboardArrowDown,
                                contentDescription = "Toggle milestones details",
                                tint = RoyalNavy
                            )
                        }

                        Spacer(modifier = Modifier.height(12.dp))
                        Divider(color = Color.LightGray.copy(alpha = 0.2f))
                        Spacer(modifier = Modifier.height(10.dp))

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Column {
                                Text("Total Locked Trust", fontSize = 10.sp, color = Color.Gray)
                                Text("₹${booking.totalAmount}", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                            }
                            Column(horizontalAlignment = Alignment.End) {
                                Text("Released to Vendor", fontSize = 10.sp, color = Color.Gray)
                                Text("₹$releasedAmount", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = EmeraldGreen)
                            }
                        }

                        AnimatedVisibility(visible = isExpanded) {
                            Column(
                                modifier = Modifier
                                    .padding(top = 16.dp)
                                    .fillMaxWidth(),
                                verticalArrangement = Arrangement.spacedBy(10.dp)
                            ) {
                                Divider(color = Color.LightGray.copy(alpha = 0.3f))
                                Text(
                                    text = "Milestones Audit Check",
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 12.sp,
                                    color = RoyalNavy
                                )

                                booking.milestones.forEachIndexed { milestoneIdx, milestone ->
                                    val isReleased = milestone.status == "RELEASED"
                                    val milestoneColor = if (isReleased) EmeraldGreen else ChampagneGold

                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .background(PearlWhite, RoundedCornerShape(10.dp))
                                            .border(1.dp, Color.LightGray.copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                                            .padding(12.dp),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Column {
                                            Text(text = milestone.label, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                            Text(text = "₹${milestone.amount}", fontSize = 11.sp, color = Color.Gray)
                                            Spacer(modifier = Modifier.height(4.dp))
                                            Box(
                                                modifier = Modifier
                                                    .background(milestoneColor.copy(alpha = 0.1f), RoundedCornerShape(4.dp))
                                                    .padding(horizontal = 6.dp, vertical = 2.dp)
                                            ) {
                                                Text(
                                                    text = milestone.status,
                                                    color = milestoneColor,
                                                    fontSize = 8.sp,
                                                    fontWeight = FontWeight.Bold
                                                )
                                            }
                                        }

                                        if (!isReleased) {
                                            var isProcessing by remember { mutableStateOf(false) }

                                            Button(
                                                onClick = {
                                                    scope.launch {
                                                        isProcessing = true
                                                        delay(800) // loading simulator
                                                        isProcessing = false

                                                        // Mutate the list directly
                                                        val updatedList = platformBookings.map { b ->
                                                            if (b.id == booking.id) {
                                                                val updatedMilestones = b.milestones.mapIndexed { mIdx, m ->
                                                                    if (mIdx == milestoneIdx) m.copy(status = "RELEASED") else m
                                                                }.toMutableList()
                                                                b.copy(milestones = updatedMilestones)
                                                            } else b
                                                        }
                                                        platformBookings = updatedList
                                                    }
                                                },
                                                shape = RoundedCornerShape(6.dp),
                                                colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                                                contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                                                enabled = !isProcessing,
                                                modifier = Modifier.height(30.dp)
                                            ) {
                                                if (isProcessing) {
                                                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(14.dp))
                                                } else {
                                                    Text("Audit Release", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.White)
                                                }
                                            }
                                        } else {
                                            Icon(
                                                imageVector = Icons.Default.CheckCircle,
                                                contentDescription = "Success",
                                                tint = EmeraldGreen,
                                                modifier = Modifier.size(24.dp)
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// State Models
private data class AdminBooking(
    val id: String,
    val clientName: String,
    val venueName: String,
    val eventDate: String,
    val totalAmount: Double,
    val milestones: MutableList<AdminMilestone>
)

private data class AdminMilestone(
    val id: String,
    val label: String,
    val amount: Double,
    val status: String // HELD, RELEASED
)
