package com.gomandap.app.presentation.bookings

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.foundation.BorderStroke
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*

data class BookingItem(
    val id: String,
    val vendorName: String,
    val category: String,
    val eventDate: String,
    val slot: String,
    val amount: String,
    val status: BookingStatus
)

enum class BookingStatus { ACTIVE, PAST, CANCELLED }

private val sampleBookings = listOf(
    BookingItem("BK-1082", "The Grand Taj Palace", "Venue & Mandap", "14 Nov 2026", "Evening (5 PM–11 PM)", "₹1,55,460", BookingStatus.ACTIVE),
    BookingItem("BK-1083", "Pixel Perfect Studios", "Photography", "14 Nov 2026", "Full Day", "₹80,000", BookingStatus.ACTIVE),
    BookingItem("BK-1051", "Royal Florals Decor", "Decor", "12 Sep 2025", "Morning (9 AM–2 PM)", "₹45,000", BookingStatus.PAST),
    BookingItem("BK-1044", "Spice Garden Catering", "Catering", "22 Jun 2025", "Full Day", "₹1,20,000", BookingStatus.PAST),
    BookingItem("BK-1039", "Beats DJ Services", "Entertainment", "01 May 2025", "Evening (5 PM–11 PM)", "₹28,000", BookingStatus.CANCELLED),
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookingsScreen(onTrackVendor: (String) -> Unit) {
    var selectedTab by remember { mutableStateOf(0) }
    val tabs = listOf("Active", "Past", "Cancelled")

    val filteredBookings = remember(selectedTab) {
        sampleBookings.filter {
            when (selectedTab) {
                0 -> it.status == BookingStatus.ACTIVE
                1 -> it.status == BookingStatus.PAST
                else -> it.status == BookingStatus.CANCELLED
            }
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("My Event Bookings", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 18.sp)
                        Text("Manage your live active escrow reservations", fontSize = 11.sp, color = SlateGray)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White),
                modifier = Modifier.shadow(2.dp)
            )
        },
        containerColor = SoftMist
    ) { paddingValues ->
        Column(modifier = Modifier.fillMaxSize().padding(paddingValues)) {
            // Tab Row Selector
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White)
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                tabs.forEachIndexed { index, tab ->
                    val isSelected = selectedTab == index
                    val bgColor by animateColorAsState(
                        if (isSelected) RoyalNavy else SoftMist, label = "tabBg"
                    )
                    val textColor by animateColorAsState(
                        if (isSelected) Color.White else SlateGray, label = "tabText"
                    )
                    val borderBrush = if (isSelected) {
                        BorderStroke(0.dp, Color.Transparent)
                    } else {
                        BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.25f))
                    }
                    
                    Surface(
                        onClick = { selectedTab = index },
                        color = bgColor,
                        shape = RoundedCornerShape(20.dp),
                        border = borderBrush,
                        modifier = Modifier.weight(1f)
                    ) {
                        Text(
                            text = tab,
                            modifier = Modifier.padding(vertical = 8.dp).fillMaxWidth(),
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = textColor
                        )
                    }
                }
            }

            Divider(color = LightSlate.copy(alpha = 0.5f))

            // Booking Cards Feed
            if (filteredBookings.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("🗓️", fontSize = 48.sp)
                        Spacer(Modifier.height(12.dp))
                        Text("No bookings here yet", fontWeight = FontWeight.Bold, color = RoyalNavy, fontSize = 15.sp)
                        Text("Start booking instantly on GoMandap!", fontSize = 12.sp, color = SlateGray)
                    }
                }
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    items(filteredBookings) { booking ->
                        BookingCard(booking = booking, onTrackVendor = onTrackVendor)
                    }
                }
            }
        }
    }
}

@Composable
fun BookingCard(booking: BookingItem, onTrackVendor: (String) -> Unit) {
    val statusColor = when (booking.status) {
        BookingStatus.ACTIVE    -> EmeraldGreen
        BookingStatus.PAST      -> SlateGray
        BookingStatus.CANCELLED -> RoseRed
    }
    val statusLabel = when (booking.status) {
        BookingStatus.ACTIVE    -> "ACTIVE ESCROW"
        BookingStatus.PAST      -> "COMPLETED"
        BookingStatus.CANCELLED -> "CANCELLED"
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .neumorphicShadow(borderRadius = 16.dp, shadowRadius = 8.dp)
            .background(Color.White, shape = RoundedCornerShape(16.dp))
            .border(1.dp, ChampagneGold.copy(alpha = 0.15f), shape = RoundedCornerShape(16.dp))
            .padding(16.dp)
    ) {
        Column {
            // Header row
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(booking.vendorName, fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy)
                    Text(booking.category, fontSize = 11.sp, color = SlateGray, fontWeight = FontWeight.Medium)
                }
                Surface(
                    color = statusColor.copy(alpha = 0.08f),
                    shape = RoundedCornerShape(4.dp),
                    border = if (booking.status == BookingStatus.ACTIVE) BorderStroke(1.dp, statusColor.copy(alpha = 0.4f)) else null
                ) {
                    Text(
                        text = statusLabel,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Black,
                        color = statusColor,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
            }

            Spacer(Modifier.height(12.dp))
            Divider(color = LightSlate.copy(alpha = 0.5f))
            Spacer(Modifier.height(12.dp))

            // Date / Slot
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                BookingMetaItem(icon = Icons.Default.CalendarToday, label = "Event Date", value = booking.eventDate, modifier = Modifier.weight(1f))
                BookingMetaItem(icon = Icons.Default.AccessTime, label = "Event Slot", value = booking.slot, modifier = Modifier.weight(1f))
            }
            
            Spacer(Modifier.height(12.dp))
            Divider(color = LightSlate.copy(alpha = 0.3f))
            Spacer(Modifier.height(12.dp))
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Default.AccountBalanceWallet, null, tint = ChampagneGold, modifier = Modifier.size(14.dp))
                Spacer(Modifier.width(6.dp))
                Text("Escrowed Value:", fontSize = 11.sp, color = SlateGray, fontWeight = FontWeight.Medium)
                Spacer(Modifier.width(4.dp))
                Text(booking.amount, fontSize = 13.sp, fontWeight = FontWeight.Black, color = RoyalNavy)
                Spacer(Modifier.weight(1f))
                Text("ID: ${booking.id}", fontSize = 10.sp, color = SlateGray, fontWeight = FontWeight.Bold)
            }

            // Track Vendor CTA (only for ACTIVE)
            if (booking.status == BookingStatus.ACTIVE) {
                Spacer(Modifier.height(16.dp))
                Button(
                    onClick = { onTrackVendor(booking.id) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(40.dp)
                        .antigravityShadow(color = RoyalNavy, alpha = 0.15f, borderRadius = 10.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Icon(Icons.Default.LocationOn, null, modifier = Modifier.size(14.dp), tint = ChampagneGold)
                    Spacer(Modifier.width(6.dp))
                    Text("Track Vendor Escrow Milestones", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = Color.White)
                }
            }
        }
    }
}

@Composable
fun BookingMetaItem(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String, value: String, modifier: Modifier = Modifier) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = modifier) {
        Box(
            modifier = Modifier
                .size(26.dp)
                .clip(CircleShape)
                .background(SoftMist),
            contentAlignment = Alignment.Center
        ) {
            Icon(icon, null, tint = RoyalNavy, modifier = Modifier.size(12.dp))
        }
        Spacer(Modifier.width(8.dp))
        Column {
            Text(label, fontSize = 9.sp, color = SlateGray, fontWeight = FontWeight.Bold)
            Text(value, fontSize = 11.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
        }
    }
}
