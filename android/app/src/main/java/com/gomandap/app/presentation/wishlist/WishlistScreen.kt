package com.gomandap.app.presentation.wishlist

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.data.vendor.VendorRepository
import com.gomandap.app.domain.model.CateringVendor
import com.gomandap.app.domain.model.DecorMandapVendor
import com.gomandap.app.domain.model.MakeupArtistVendor
import com.gomandap.app.domain.model.PhotographyVendor
import com.gomandap.app.domain.model.Vendor
import com.gomandap.app.domain.model.VenueVendor

private val RoyalNavy = Color(0xFF0F172A)
private val EmeraldGreen = Color(0xFF10B981)
private val ChampagneGold = Color(0xFFDFBA73)
private val SlateGray = Color(0xFF64748B)
private val PearlWhite = Color(0xFFF8F9FA)
private val RoseRed = Color(0xFFEF4444)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun WishlistScreen(
    wishlistedIds: Set<String>,
    onVendorTap: (String) -> Unit,
    onRemove: (String) -> Unit
) {
    val vendorList = VendorRepository.vendors.collectAsState().value
    val activeList = remember(wishlistedIds, vendorList) {
        vendorList.filter { it.id in wishlistedIds }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Saved Vendors", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 20.sp)
                        Text("${activeList.size} vendors bookmarked", fontSize = 11.sp, color = SlateGray)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = PearlWhite
    ) { paddingValues ->
        if (activeList.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize().padding(paddingValues), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("❤️", fontSize = 56.sp)
                    Spacer(Modifier.height(12.dp))
                    Text("No saved vendors yet", fontWeight = FontWeight.Bold, color = RoyalNavy, fontSize = 17.sp)
                    Text(
                        "Tap the heart icon on any vendor to save them here.",
                        fontSize = 13.sp,
                        color = SlateGray,
                        modifier = Modifier.padding(horizontal = 32.dp),
                        textAlign = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier.padding(paddingValues),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                items(activeList, key = { it.id }) { vendor ->
                    WishlistCard(
                        vendor = vendor,
                        onRemove = { onRemove(vendor.id) },
                        onTap = { onVendorTap(vendor.id) }
                    )
                }
            }
        }
    }
}

@Composable
fun WishlistCard(vendor: Vendor, onRemove: () -> Unit, onTap: () -> Unit) {
    val category = when (vendor) {
        is VenueVendor -> "Venue & Mandap"
        is PhotographyVendor -> "Photography"
        is DecorMandapVendor -> "Decor & Mandap"
        is CateringVendor -> "Catering"
        is MakeupArtistVendor -> "Makeup"
        else -> "Service"
    }

    val priceLabel = when (vendor) {
        is VenueVendor -> "₹${"%,d".format(vendor.basePrice.toInt())} package"
        is PhotographyVendor -> "₹${"%,d".format(vendor.basePrice.toInt())} / day"
        is DecorMandapVendor -> "₹${"%,d".format(vendor.basePrice.toInt())} package"
        is CateringVendor -> "₹${"%,d".format(vendor.pricePerPlate.toInt())} / plate"
        is MakeupArtistVendor -> "₹${"%,d".format(vendor.basePrice.toInt())} / artist"
        else -> "₹${"%,d".format(vendor.basePrice.toInt())}"
    }

    val emoji = when (vendor) {
        is VenueVendor -> "🏛️"
        is PhotographyVendor -> "📷"
        is DecorMandapVendor -> "🌸"
        is CateringVendor -> "🍽️"
        is MakeupArtistVendor -> "💄"
        else -> "✨"
    }

    val tag = when (vendor) {
        is VenueVendor -> if (vendor.isFastFilling) "🔥 Filling Fast" else "⚡ Instant Book"
        is PhotographyVendor -> if (vendor.deliveryTimeWeeks <= 4) "⚡ Instant Book" else "Featured"
        is DecorMandapVendor -> if (vendor.setupTimeHours <= 6) "⚡ Instant Book" else "Featured"
        is CateringVendor -> "⚡ Instant Book"
        is MakeupArtistVendor -> "Featured"
        else -> "Featured"
    }

    Card(
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(2.dp),
        modifier = Modifier.fillMaxWidth().clickable { onTap() }
    ) {
        Row(modifier = Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(56.dp)
                    .background(
                        Brush.verticalGradient(listOf(Color(0xFFCBD5E1), Color(0xFF94A3B8))),
                        RoundedCornerShape(12.dp)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(emoji, fontSize = 24.sp)
            }

            Spacer(Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Surface(
                    color = if (tag.contains("Instant")) EmeraldGreen.copy(alpha = 0.12f) else ChampagneGold.copy(alpha = 0.12f),
                    shape = RoundedCornerShape(4.dp)
                ) {
                    Text(
                        tag,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Black,
                        color = if (tag.contains("Instant")) EmeraldGreen else ChampagneGold,
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
                Spacer(Modifier.height(4.dp))
                Text(vendor.name, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy, maxLines = 1)
                Text(category, fontSize = 11.sp, color = SlateGray)
                Spacer(Modifier.height(6.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.LocationOn, null, tint = SlateGray, modifier = Modifier.size(11.dp))
                    Text(vendor.locality, fontSize = 10.sp, color = SlateGray)
                    Spacer(Modifier.width(8.dp))
                    Icon(Icons.Default.Star, null, tint = ChampagneGold, modifier = Modifier.size(11.dp))
                    Text(vendor.rating.toString(), fontSize = 10.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                }
                Spacer(Modifier.height(4.dp))
                Text(priceLabel, fontSize = 13.sp, fontWeight = FontWeight.Black, color = RoyalNavy)
            }

            IconButton(
                onClick = onRemove,
                modifier = Modifier
                    .size(36.dp)
                    .background(RoseRed.copy(alpha = 0.08f), CircleShape)
            ) {
                Icon(Icons.Default.Favorite, null, tint = RoseRed, modifier = Modifier.size(18.dp))
            }
        }
    }
}
