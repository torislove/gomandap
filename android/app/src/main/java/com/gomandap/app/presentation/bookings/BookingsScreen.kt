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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private val RoyalNavy     = Color(0xFF0F172A)
private val EmeraldGreen  = Color(0xFF10B981)
private val ChampagneGold = Color(0xFFDFBA73)
private val SlateGray     = Color(0xFF64748B)
private val PearlWhite    = Color(0xFFF8F9FA)
private val RoseRed       = Color(0xFFEF4444)

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
                        Text("My Bookings", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 20.sp)
                        Text("Manage your event reservations", fontSize = 11.sp, color = SlateGray)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = PearlWhite
    ) { paddingValues ->
        Column(modifier = Modifier.fillMaxSize().padding(paddingValues)) {
            // ── Tab Row ──────────────────────────────────────────────────
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
                        if (isSelected) RoyalNavy else PearlWhite, label = "tabBg"
                    )
                    val textColor by animateColorAsState(
                        if (isSelected) Color.White else SlateGray, label = "tabText"
                    )
                    Surface(
                        onClick = { selectedTab = index },
                        color = bgColor,
                        shape = RoundedCornerShape(20.dp),
                        modifier = Modifier.weight(1f)
                    ) {
                        Text(
                            tab,
                            modifier = Modifier.padding(vertical = 8.dp).fillMaxWidth(),
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            color = textColor
                        )
                    }
                }
            }

            Divider(color = Color(0xFFE2E8F0))

            // ── Booking Cards ────────────────────────────────────────────
            if (filteredBookings.isEmpty()) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("🗓️", fontSize = 48.sp)
                        Spacer(Modifier.height(12.dp))
                        Text("No bookings here yet", fontWeight = FontWeight.Bold, color = RoyalNavy, fontSize = 16.sp)
                        Text("Start booking instantly on GoMandap!", fontSize = 12.sp, color = SlateGray)
                    }
                }
            } else {
                LazyColumn(
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
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
        BookingStatus.ACTIVE    -> "CONFIRMED"
        BookingStatus.PAST      -> "COMPLETED"
        BookingStatus.CANCELLED -> "CANCELLED"
    }

    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(2.dp),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            // Header row
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(booking.vendorName, fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy)
                    Text(booking.category, fontSize = 11.sp, color = SlateGray)
                }
                Box(
                    modifier = Modifier
                        .background(statusColor.copy(alpha = 0.1f), RoundedCornerShape(6.dp))
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text(statusLabel, fontSize = 9.sp, fontWeight = FontWeight.Black, color = statusColor)
                }
            }

            Spacer(Modifier.height(12.dp))
            Divider(color = Color(0xFFE2E8F0))
            Spacer(Modifier.height(12.dp))

            // Date / Slot / Amount grid
            Row(modifier = Modifier.fillMaxWidth()) {
                BookingMetaItem(icon = Icons.Default.CalendarToday, label = "Event Date", value = booking.eventDate, modifier = Modifier.weight(1f))
                BookingMetaItem(icon = Icons.Default.AccessTime, label = "Slot", value = booking.slot, modifier = Modifier.weight(1f))
            }
            Spacer(Modifier.height(10.dp))
            Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.AccountBalanceWallet, null, tint = ChampagneGold, modifier = Modifier.size(14.dp))
                Spacer(Modifier.width(4.dp))
                Text("Escrowed: ${booking.amount}", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                Spacer(Modifier.weight(1f))
                Text("ID: ${booking.id}", fontSize = 10.sp, color = SlateGray)
            }

            // Track Vendor CTA (only for ACTIVE)
            if (booking.status == BookingStatus.ACTIVE) {
                Spacer(Modifier.height(14.dp))
                Button(
                    onClick = { onTrackVendor(booking.id) },
                    modifier = Modifier.fillMaxWidth().height(44.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Icon(Icons.Default.LocationOn, null, modifier = Modifier.size(16.dp))
                    Spacer(Modifier.width(8.dp))
                    Text("Track Vendor on Event Day", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                }
            }
        }
    }
}

@Composable
fun BookingMetaItem(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String, value: String, modifier: Modifier = Modifier) {
    Row(verticalAlignment = Alignment.CenterVertically, modifier = modifier) {
        Icon(icon, null, tint = SlateGray, modifier = Modifier.size(13.dp))
        Spacer(Modifier.width(4.dp))
        Column {
            Text(label, fontSize = 9.sp, color = SlateGray)
            Text(value, fontSize = 11.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
        }
    }
}
