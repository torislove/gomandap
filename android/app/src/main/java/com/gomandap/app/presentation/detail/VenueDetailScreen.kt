@file:OptIn(androidx.compose.foundation.ExperimentalFoundationApi::class, androidx.compose.material3.ExperimentalMaterial3Api::class)
package com.gomandap.app.presentation.detail

import androidx.compose.animation.*
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import android.content.Intent
import com.gomandap.app.domain.model.*
import com.gomandap.app.presentation.theme.*

// ─── Mock Database Mapper ────────────────────────────────────────────────────

fun getMockVendor(id: String): Vendor {
    return com.gomandap.app.data.mock.MockDataStore.getVendorById(id)
}

// ─── Main Detail Screen ──────────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VenueDetailScreen(
    venueId: String,
    onBackClick: () -> Unit,
    onBookNowClick: () -> Unit
) {
    val vendor = remember(venueId) { getMockVendor(venueId) }
    val context = LocalContext.current
    var isFavorite by remember { mutableStateOf(false) }
    var showCalendar by remember { mutableStateOf(false) }
    val shareText = remember(vendor) {
        "Check out ${vendor.name} in ${vendor.locality}. Rated ${vendor.rating} and starting at ₹${"%,d".format(vendor.basePrice.toInt())}."
    }

    val scaffoldState = rememberBottomSheetScaffoldState()
    
    Box(modifier = Modifier.fillMaxSize()) {
        // 1. Transparent Backdrop Pager & Core Layer
        val pagerState = rememberPagerState(pageCount = { vendor.imageUrls.size })
        
        BottomSheetScaffold(
            scaffoldState = scaffoldState,
            sheetContent = {
                // Outer Sheet wrapper with custom Antigravity Glassmorphism & Shadow
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .glassCard(shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp))
                        .antigravityShadow(borderRadius = 28.dp)
                        .padding(horizontal = 20.dp, vertical = 8.dp)
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 80.dp) // Leave buffer space for floating booking bar
                    ) {
                        // Title Overview
                        Row(
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text(
                                text = vendor.name,
                                fontWeight = FontWeight.Black,
                                fontSize = 22.sp,
                                color = RoyalNavy,
                                maxLines = 2,
                                overflow = TextOverflow.Ellipsis,
                                modifier = Modifier.weight(1f)
                            )
                            if (vendor.isVerified) {
                                Box(
                                    modifier = Modifier
                                        .background(
                                            brush = Brush.horizontalGradient(listOf(ChampagneGold, DarkGold)),
                                            shape = RoundedCornerShape(6.dp)
                                        )
                                        .padding(horizontal = 8.dp, vertical = 3.dp)
                                ) {
                                    Text(
                                        text = "VERIFIED",
                                        color = Color.White,
                                        fontSize = 9.sp,
                                        fontWeight = FontWeight.Black
                                    )
                                }
                            }
                        }
                        
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.padding(top = 4.dp, bottom = 16.dp)
                        ) {
                            Icon(Icons.Default.Star, null, tint = ChampagneGold, modifier = Modifier.size(15.dp))
                            Spacer(Modifier.width(4.dp))
                            Text(
                                text = vendor.rating.toString(),
                                fontWeight = FontWeight.Bold,
                                fontSize = 13.sp,
                                color = RoyalNavy
                            )
                            Spacer(Modifier.width(8.dp))
                            Box(modifier = Modifier.size(3.dp).background(SlateGray.copy(alpha = 0.5f), CircleShape))
                            Spacer(Modifier.width(8.dp))
                            Icon(Icons.Default.LocationOn, null, tint = EmeraldGreen, modifier = Modifier.size(12.dp))
                            Spacer(Modifier.width(2.dp))
                            Text(
                                text = vendor.locality,
                                fontSize = 12.sp,
                                color = SlateGray
                            )
                        }

                        if (vendor.videoUrl.isNotBlank()) {
                            var showVideoOverlay by remember { mutableStateOf(false) }

                            Surface(
                                onClick = { showVideoOverlay = true },
                                modifier = Modifier.padding(bottom = 16.dp),
                                shape = RoundedCornerShape(8.dp),
                                border = BorderStroke(1.dp, ChampagneGold),
                                color = ChampagneGold.copy(alpha = 0.1f)
                            ) {
                                Row(
                                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Icon(
                                        imageVector = Icons.Default.PlayArrow,
                                        contentDescription = null,
                                        tint = DarkGold,
                                        modifier = Modifier.size(16.dp)
                                    )
                                    Spacer(Modifier.width(6.dp))
                                    Text(
                                        text = "View Cinematic Tour Video",
                                        color = DarkGold,
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 11.sp
                                    )
                                }
                            }

                            if (showVideoOverlay) {
                                AlertDialog(
                                    onDismissRequest = { showVideoOverlay = false },
                                    title = { Text("Cinematic Tour Walkthrough", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                                    text = {
                                        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                            Text("Source Link: ${vendor.videoUrl}", fontSize = 11.sp, color = SlateGray, maxLines = 1)
                                            Text(
                                                "Streaming high-definition cinematic wedding video walkthrough of ${vendor.name} in virtual player overlay...",
                                                fontSize = 12.sp,
                                                color = RoyalNavy
                                            )
                                            Box(
                                                modifier = Modifier
                                                    .fillMaxWidth()
                                                    .height(150.dp)
                                                    .background(RoyalNavy, RoundedCornerShape(12.dp)),
                                                contentAlignment = Alignment.Center
                                            ) {
                                                Icon(
                                                    imageVector = Icons.Default.PlayCircle,
                                                    contentDescription = "Playing",
                                                    tint = ChampagneGold,
                                                    modifier = Modifier.size(48.dp)
                                                )
                                            }
                                        }
                                    },
                                    confirmButton = {
                                        Button(
                                            onClick = { showVideoOverlay = false },
                                            colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen)
                                        ) {
                                            Text("Close Player", color = Color.White)
                                        }
                                    }
                                )
                            }
                        }

                        Divider(color = SlateGray.copy(alpha = 0.15f))
                        Spacer(Modifier.height(16.dp))

                        // ── Contextual Polymorphic Data Rendering ─────────────────
                        when (vendor) {
                            is VenueVendor -> VenueDetailsLayout(vendor)
                            is PhotographyVendor -> PhotographyDetailsLayout(vendor)
                            is DecorMandapVendor -> DecorDetailsLayout(vendor)
                            is CateringVendor -> CateringDetailsLayout(vendor)
                            is MakeupArtistVendor -> MakeupDetailsLayout(vendor)
                        }

                        Spacer(Modifier.height(24.dp))
                        
                        // ── Q-Commerce Booking Engine ────────────────────────────────
                        Text("1. Select Micro-Slot", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                        Spacer(Modifier.height(8.dp))
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                            var selectedSlot by remember { mutableStateOf("Evening") }
                            listOf("Morning (9AM-2PM)", "Evening (5PM-11PM)", "Full Day").forEach { slot ->
                                val isSelected = selectedSlot == slot.split(" ").first()
                                FilterChip(
                                    selected = isSelected,
                                    onClick = { selectedSlot = slot.split(" ").first() },
                                    label = { Text(slot, fontSize = 11.sp, fontWeight = if(isSelected) FontWeight.Bold else FontWeight.Normal) },
                                    colors = FilterChipDefaults.filterChipColors(
                                        selectedContainerColor = EmeraldGreen.copy(alpha = 0.15f),
                                        selectedLabelColor = EmeraldGreen
                                    )
                                )
                            }
                        }

                        Spacer(Modifier.height(16.dp))
                        
                        // 1-Week Prior Booking Constraint
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.fillMaxWidth().background(ChampagneGold.copy(alpha = 0.1f), RoundedCornerShape(8.dp)).padding(12.dp)
                        ) {
                            Icon(Icons.Default.DateRange, contentDescription = "Calendar", tint = ChampagneGold, modifier = Modifier.size(20.dp))
                            Spacer(Modifier.width(8.dp))
                            Column {
                                Text("Select Event Date", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                Text("Availability strictly starts from Today + 7 Days (1-week notice required).", fontSize = 11.sp, color = SlateGray)
                            }
                        }

                        Spacer(Modifier.height(24.dp))

                        Text("2. Instant Add-on SKUs", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                        Spacer(Modifier.height(8.dp))
                        LazyRow(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth()) {
                            items(listOf("Drone Coverage (+₹10k)", "Cinematic Edit (+₹25k)", "Live Streaming (+₹8k)")) { sku ->
                                var added by remember { mutableStateOf(false) }
                                Surface(
                                    onClick = { added = !added },
                                    shape = RoundedCornerShape(12.dp),
                                    border = BorderStroke(1.dp, if(added) EmeraldGreen else SlateGray.copy(alpha = 0.2f)),
                                    color = if(added) EmeraldGreen.copy(alpha = 0.05f) else Color.White
                                ) {
                                    Row(
                                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Icon(
                                            if(added) Icons.Default.Check else Icons.Default.Add, 
                                            contentDescription = null, 
                                            tint = if(added) EmeraldGreen else SlateGray,
                                            modifier = Modifier.size(14.dp)
                                        )
                                        Spacer(Modifier.width(6.dp))
                                        Text(sku, fontSize = 12.sp, fontWeight = if(added) FontWeight.Bold else FontWeight.Normal, color = RoyalNavy)
                                    }
                                }
                            }
                        }

                        Spacer(Modifier.height(24.dp))
                        Divider(color = SlateGray.copy(alpha = 0.15f))
                        Spacer(Modifier.height(20.dp))
                        
                        // About Section
                        Text("About Services", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                        Spacer(Modifier.height(6.dp))
                        Text(
                            text = "Gomandap is proud to present ${vendor.name} operating out of ${vendor.locality}. This service provider features an exceptionally high trust and rating score in our hyper-local bookings registry. Equipped with native Escrow security protection, booking this merchant protects all advance payments safely.",
                            fontSize = 12.sp,
                            color = SlateGray,
                            lineHeight = 18.sp
                        )
                    }
                }
            },
            sheetContainerColor = Color.Transparent,
            sheetShadowElevation = 0.dp,
            sheetPeekHeight = 280.dp,
            sheetShape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp),
            sheetDragHandle = {
                Box(
                    modifier = Modifier
                        .padding(top = 10.dp, bottom = 4.dp)
                        .width(45.dp)
                        .height(4.dp)
                        .background(SlateGray.copy(alpha = 0.4f), CircleShape)
                )
            }
        ) {
            // Background Image Pager Gallery
            Box(modifier = Modifier.fillMaxSize()) {
                HorizontalPager(
                    state = pagerState,
                    modifier = Modifier.fillMaxSize()
                ) { page ->
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(RoyalNavy.copy(alpha = 0.85f))
                    ) {
                        // Colored gradient overlay
                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(
                                    Brush.verticalGradient(
                                        listOf(
                                            Color.Black.copy(alpha = 0.4f),
                                            Color.Transparent,
                                            Color.Black.copy(alpha = 0.7f)
                                        )
                                    )
                                )
                        )
                        Column(
                            modifier = Modifier
                                .align(Alignment.Center)
                                .padding(bottom = 120.dp),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            Text(
                                "📸  GOMANDAP PREMIUM VENDOR  📸",
                                fontSize = 10.sp,
                                fontWeight = FontWeight.Black,
                                color = ChampagneGold
                            )
                            Spacer(Modifier.height(10.dp))
                            Text(
                                "Visual Gallery #${page + 1}",
                                fontSize = 24.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.White
                            )
                            Text(
                                "Immersive HD Mock View",
                                fontSize = 13.sp,
                                color = Color.White.copy(alpha = 0.6f)
                            )
                        }
                    }
                }
                
                // Pinned Pager Indicator Dots
                Row(
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .padding(top = 70.dp),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    repeat(vendor.imageUrls.size) { iteration ->
                        val width by animateFloatAsState(if (pagerState.currentPage == iteration) 18f else 6f, label = "dotWidth")
                        Box(
                            modifier = Modifier
                                .height(6.dp)
                                .width(width.dp)
                                .clip(CircleShape)
                                .background(if (pagerState.currentPage == iteration) ChampagneGold else Color.White.copy(alpha = 0.5f))
                        )
                    }
                }

                // Floating Circular Back / Share buttons
                Row(
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(start = 16.dp, top = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .background(Color.White.copy(alpha = 0.8f), CircleShape)
                            .clickable { onBackClick() },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Default.ArrowBack, null, tint = RoyalNavy, modifier = Modifier.size(20.dp))
                    }

                    Box(
                        modifier = Modifier
                            .size(40.dp)
                            .background(Color.White.copy(alpha = 0.8f), CircleShape)
                            .clickable {
                                val sendIntent = Intent(Intent.ACTION_SEND).apply {
                                    type = "text/plain"
                                    putExtra(Intent.EXTRA_TEXT, shareText)
                                }
                                context.startActivity(Intent.createChooser(sendIntent, "Share this vendor"))
                            },
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Default.Share, null, tint = RoyalNavy, modifier = Modifier.size(20.dp))
                    }
                }
            }
        }

        // 2. Persistent Floating Escrow Action Bar
        Surface(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .padding(16.dp)
                .height(72.dp)
                .antigravityShadow(borderRadius = 16.dp),
            shape = RoundedCornerShape(16.dp),
            color = Color.White,
            tonalElevation = 0.dp
        ) {
            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Starting Price", fontSize = 11.sp, color = SlateGray)
                    Text(
                        text = "₹${"%,d".format(vendor.basePrice.toInt())}${if (vendor is CateringVendor) " / Plate" else ""}",
                        fontWeight = FontWeight.Black,
                        fontSize = 18.sp,
                        color = RoyalNavy
                    )
                }
                
                // Escrow gradient button
                Button(
                    onClick = { showCalendar = true },
                    contentPadding = PaddingValues(0.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier
                        .width(200.dp)
                        .height(44.dp)
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(
                                brush = Brush.horizontalGradient(listOf(EmeraldGreen, Color(0xFF0D9488))),
                                shape = RoundedCornerShape(12.dp)
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Security, null, tint = Color.White, modifier = Modifier.size(16.dp))
                            Spacer(Modifier.width(6.dp))
                            Text(
                                "Book via Escrow",
                                fontWeight = FontWeight.Bold,
                                fontSize = 13.sp,
                                color = Color.White
                            )
                        }
                    }
                }
            }
        }

        // Live Calendar availability modal trigger
        if (showCalendar) {
            LiveAvailabilityCalendarSheet(
                onDismissRequest = { showCalendar = false },
                onDateSelected = { selectedDate ->
                    showCalendar = false
                    onBookNowClick()
                }
            )
        }
    }
}

// ─── Contextual Sub-Layouts ──────────────────────────────────────────────────

@Composable
fun VenueDetailsLayout(vendor: VenueVendor) {
    Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
        Text("WeddingBazaar-style Venue Overview", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)

        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            Text("Seating Capacity: ${vendor.seatingCapacity} seats", fontSize = 11.sp, color = SlateGray)
            LinearProgressIndicator(
                progress = vendor.seatingCapacity.toFloat() / 2000f,
                color = ChampagneGold,
                trackColor = SlateGray.copy(alpha = 0.1f),
                modifier = Modifier.fillMaxWidth().height(8.dp).clip(CircleShape)
            )

            Spacer(Modifier.height(4.dp))
            Text("Floating Capacity: ${vendor.floatingCapacity} guests", fontSize = 11.sp, color = SlateGray)
            LinearProgressIndicator(
                progress = vendor.floatingCapacity.toFloat() / 3500f,
                color = EmeraldGreen,
                trackColor = SlateGray.copy(alpha = 0.1f),
                modifier = Modifier.fillMaxWidth().height(8.dp).clip(CircleShape)
            )
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            DetailPillCard("Venue Type", vendor.venueType.name, "🏛", Modifier.weight(1f))
            DetailPillCard("Base Price", "₹${String.format("%,.0f", vendor.basePrice)}", "💰", Modifier.weight(1f))
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            DetailPillCard("Per Plate", "Veg ₹${String.format("%,.0f", vendor.pricePerPlateVeg)} / Non-Veg ₹${String.format("%,.0f", vendor.pricePerPlateNonVeg)}", "🍽", Modifier.weight(1f))
            DetailPillCard("Parking", "${vendor.parkingCount} cars", "🚘", Modifier.weight(1f))
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            DetailPillCard("Rooms", if (vendor.hasRooms) "On-site rooms available" else "No on-site rooms", "🛏", Modifier.weight(1f))
            DetailPillCard("Alcohol", if (vendor.isAlcoholAllowed) "Allowed" else "Not allowed", "🍺", Modifier.weight(1f))
        }

        Surface(
            color = PearlWhite,
            shape = RoundedCornerShape(16.dp),
            border = BorderStroke(1.dp, SlateGray.copy(alpha = 0.15f))
        ) {
            Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Booking & Policy Notes", fontWeight = FontWeight.Black, fontSize = 13.sp, color = RoyalNavy)
                Text("Decor policy: ${vendor.decorPolicy}", fontSize = 11.sp, color = SlateGray)
                Text("Escrow protected: ${if (vendor.isEscrowProtected) "Yes" else "No"}", fontSize = 11.sp, color = SlateGray)
                Text("Fast filling: ${if (vendor.isFastFilling) "High demand" else "Standard demand"}", fontSize = 11.sp, color = SlateGray)
                Text("Recommended questions to ask: capacity, outside decor, outside catering, food policy, and valet parking availability.", fontSize = 11.sp, color = SlateGray)
            }
        }

        Button(
            onClick = {}, // TODO: Implement VR Tour Viewer
            colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
            shape = RoundedCornerShape(10.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(Icons.Default.Place, contentDescription = null, tint = ChampagneGold)
            Spacer(Modifier.width(8.dp))
            Text("Launch 360° VR Tour", fontWeight = FontWeight.Bold, color = ChampagneGold)
        }
    }
}

@Composable
fun PhotographyDetailsLayout(vendor: PhotographyVendor) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Photography Styles Available", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
        
        // Flow of chip style badges
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            vendor.style.forEach { st ->
                Surface(
                    color = Color(0xFFF1F5F9),
                    shape = RoundedCornerShape(8.dp),
                    border = BorderStroke(1.dp, SlateGray.copy(alpha = 0.2f))
                ) {
                    Text(
                        text = st.name,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = RoyalNavy,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                    )
                }
            }
        }

        Spacer(Modifier.height(8.dp))
        Text("Deliverables Timeline", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
        Column {
            Text("Estimated delivery: ${vendor.deliveryTimeWeeks} weeks", fontSize = 11.sp, color = SlateGray)
            Spacer(Modifier.height(6.dp))
            LinearProgressIndicator(
                progress = 1f - (vendor.deliveryTimeWeeks.toFloat() / 12f), // lesser weeks is faster/better progress
                color = EmeraldGreen,
                trackColor = SlateGray.copy(alpha = 0.1f),
                modifier = Modifier.fillMaxWidth().height(8.dp).clip(CircleShape)
            )
        }

        Spacer(Modifier.height(8.dp))
        Button(
            onClick = {},
            colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
            shape = RoundedCornerShape(10.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("🎥  Play Portfolio Video", fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
fun DecorDetailsLayout(vendor: DecorMandapVendor) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Mandap Decor Specifications", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            DetailPillCard("Mandap Style", vendor.mandapStyle.name, "🌸", Modifier.weight(1f))
            DetailPillCard("Setup Time", "${vendor.setupTimeHours} Hours", "⏱", Modifier.weight(1f))
        }

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            DetailPillCard("Dimensions", vendor.dimensions, "📏", Modifier.weight(1f))
            DetailPillCard("Trust Rating", "${vendor.rating} / 5", "⭐", Modifier.weight(1f))
        }
    }
}

@Composable
fun CateringDetailsLayout(vendor: CateringVendor) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Cuisine Types Supported", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
        
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            vendor.cuisineTypes.take(3).forEach { cui ->
                Surface(
                    color = Color(0xFFFFF7ED),
                    shape = RoundedCornerShape(8.dp),
                    border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.4f))
                ) {
                    Text(
                        text = cui,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = DarkGold,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                    )
                }
            }
        }

        Spacer(Modifier.height(8.dp))
        Text("Ordering Conditions", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
                    DetailPillCard("Min Guest Requirement", "${vendor.minGuestCount} Plates", "👥", Modifier.weight(1f))
            DetailPillCard("Plate Starting Cost", "₹${vendor.pricePerPlate}", "🍛", Modifier.weight(1f))
        }
    }
}

@Composable
fun MakeupDetailsLayout(vendor: MakeupArtistVendor) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Services & Styling Offered", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
        
        Row(
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            val list = mutableListOf<String>()
            if (vendor.isHairStylingIncluded) list.add("💇 Hair")
            if (vendor.isDrapingIncluded) list.add("💃 Draping")
            if (vendor.isPaidTrialAvailable) list.add("✨ Trial")
            vendor.makeupTypes.forEach { list.add("💄 ${it.name}") }
            
            list.take(3).forEach { item ->
                Surface(
                    color = Color(0xFFFFF7ED),
                    shape = RoundedCornerShape(8.dp),
                    border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.4f))
                ) {
                    Text(
                        text = item,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = DarkGold,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                    )
                }
            }
        }
    }
}

@Composable
fun DetailPillCard(
    title: String,
    value: String,
    emoji: String,
    modifier: Modifier = Modifier
) {
    Surface(
        color = PearlWhite,
        shape = RoundedCornerShape(12.dp),
        border = BorderStroke(1.dp, SlateGray.copy(alpha = 0.15f)),
        modifier = modifier
    ) {
        Column(
            modifier = Modifier.padding(12.dp),
            verticalArrangement = Arrangement.Center
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(emoji, fontSize = 16.sp)
                Spacer(Modifier.width(6.dp))
                Text(title, fontSize = 10.sp, color = SlateGray, fontWeight = FontWeight.Medium)
            }
            Spacer(Modifier.height(4.dp))
            Text(
                text = value,
                fontWeight = FontWeight.ExtraBold,
                fontSize = 13.sp,
                color = RoyalNavy,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

// ─── Custom Availability Calendar Sheet ──────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LiveAvailabilityCalendarSheet(
    onDismissRequest: () -> Unit,
    onDateSelected: (String) -> Unit
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    var selectedDate by remember { mutableStateOf<Int?>(null) }
    
    val daysInMonth = 30
    val bookedDates = setOf(5, 6, 12, 13, 14, 20, 21, 27, 28) // June weekend dates
    
    ModalBottomSheet(
        onDismissRequest = onDismissRequest,
        sheetState = sheetState,
        containerColor = Color.White.copy(alpha = 0.95f),
        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp),
        modifier = Modifier.fillMaxHeight(0.75f)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Box(
                modifier = Modifier
                    .width(40.dp)
                    .height(4.dp)
                    .background(SlateGray.copy(alpha = 0.3f), CircleShape)
            )
            Spacer(Modifier.height(16.dp))
            Text(
                "Select Event Date",
                fontWeight = FontWeight.Black,
                fontSize = 18.sp,
                color = RoyalNavy
            )
            Text(
                "Availability radar: June 2026",
                fontSize = 12.sp,
                color = SlateGray
            )
            Spacer(Modifier.height(20.dp))
            
            // Days of the week row
            Row(
                modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun").forEach { day ->
                    Text(
                        text = day,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = SlateGray,
                        modifier = Modifier.weight(1f),
                        textAlign = TextAlign.Center
                    )
                }
            }
            
            // Grid of days
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                for (row in 0 until 5) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        for (col in 1..7) {
                            val dayNumber = row * 7 + col
                            if (dayNumber <= daysInMonth) {
                                val isBooked = dayNumber in bookedDates
                                val isSelected = dayNumber == selectedDate
                                var pressed by remember { mutableStateOf(false) }
                                val scale by animateFloatAsState(
                                    targetValue = if (pressed) 0.88f else 1f,
                                    animationSpec = AntigravitySpring.WeightlessSpec,
                                    label = "dateScale"
                                )
                                
                                Box(
                                    modifier = Modifier
                                        .weight(1f)
                                        .aspectRatio(1f)
                                        .padding(2.dp)
                                        .scale(scale)
                                        .clip(CircleShape)
                                        .background(
                                            when {
                                                isSelected -> EmeraldGreen
                                                isBooked -> Color(0xFFFEE2E2)
                                                else -> PearlWhite
                                            }
                                        )
                                        .clickable(enabled = !isBooked) {
                                            selectedDate = dayNumber
                                        }
                                        .pointerInput(Unit) {
                                            detectTapGestures(
                                                onPress = {
                                                    if (!isBooked) {
                                                        pressed = true
                                                        tryAwaitRelease()
                                                        pressed = false
                                                    }
                                                }
                                            )
                                        },
                                    contentAlignment = Alignment.Center
                                ) {
                                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                        Text(
                                            text = dayNumber.toString(),
                                            fontWeight = FontWeight.ExtraBold,
                                            fontSize = 13.sp,
                                            color = when {
                                                isSelected -> Color.White
                                                isBooked -> Color.Red.copy(alpha = 0.5f)
                                                else -> RoyalNavy
                                            },
                                            style = if (isBooked) androidx.compose.ui.text.TextStyle(textDecoration = androidx.compose.ui.text.style.TextDecoration.LineThrough) else androidx.compose.ui.text.TextStyle.Default
                                        )
                                        if (isBooked) {
                                            Text("Booked", fontSize = 7.sp, color = Color.Red.copy(alpha = 0.6f))
                                        }
                                    }
                                }
                            } else {
                                Box(modifier = Modifier.weight(1f))
                            }
                        }
                    }
                }
            }
            
            Spacer(Modifier.weight(1f))
            Button(
                onClick = {
                    selectedDate?.let { day ->
                        onDateSelected("2026-06-${String.format("%02d", day)}")
                    }
                },
                enabled = selectedDate != null,
                colors = ButtonDefaults.buttonColors(
                    containerColor = EmeraldGreen,
                    disabledContainerColor = SlateGray.copy(alpha = 0.3f)
                ),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(50.dp)
            ) {
                Text(
                    "Confirm Date & Init Escrow",
                    fontWeight = FontWeight.Bold,
                    fontSize = 15.sp,
                    color = Color.White
                )
            }
        }
    }
}
