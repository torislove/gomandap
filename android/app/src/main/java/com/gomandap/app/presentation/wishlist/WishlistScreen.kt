package com.gomandap.app.presentation.wishlist

import androidx.compose.foundation.BorderStroke
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
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
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
import com.gomandap.app.presentation.theme.*

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
                        Text("Saved Event Partners", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 18.sp)
                        Text("${activeList.size} premium vendors bookmarked", fontSize = 11.sp, color = SlateGray)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White),
                modifier = Modifier.shadow(2.dp)
            )
        },
        containerColor = SoftMist
    ) { paddingValues ->
        if (activeList.isEmpty()) {
            Box(modifier = Modifier.fillMaxSize().padding(paddingValues), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("❤️", fontSize = 56.sp)
                    Spacer(Modifier.height(12.dp))
                    Text("No saved vendors yet", fontWeight = FontWeight.Bold, color = RoyalNavy, fontSize = 16.sp)
                    Text(
                        "Tap the heart icon on any vendor to save them here.",
                        fontSize = 12.sp,
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
                verticalArrangement = Arrangement.spacedBy(16.dp)
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

    val isInstantTag = tag.contains("Instant")

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .neumorphicShadow(borderRadius = 16.dp, shadowRadius = 8.dp)
            .background(Color.White, shape = RoundedCornerShape(16.dp))
            .border(1.dp, ChampagneGold.copy(alpha = 0.15f), shape = RoundedCornerShape(16.dp))
            .clickable { onTap() }
            .padding(14.dp)
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Box(
                modifier = Modifier
                    .size(58.dp)
                    .background(
                        Brush.verticalGradient(listOf(Color(0xFFE2E8F0), SoftMist)),
                        RoundedCornerShape(12.dp)
                    )
                    .border(1.dp, ChampagneGold.copy(alpha = 0.3f), RoundedCornerShape(12.dp)),
                contentAlignment = Alignment.Center
            ) {
                Text(emoji, fontSize = 26.sp)
            }

            Spacer(Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Surface(
                    color = if (isInstantTag) EmeraldGreen.copy(alpha = 0.08f) else ChampagneGold.copy(alpha = 0.08f),
                    shape = RoundedCornerShape(4.dp),
                    border = BorderStroke(1.dp, if (isInstantTag) EmeraldGreen.copy(alpha = 0.3f) else ChampagneGold.copy(alpha = 0.3f))
                ) {
                    Text(
                        text = tag,
                        fontSize = 8.sp,
                        fontWeight = FontWeight.Black,
                        color = if (isInstantTag) EmeraldGreen else DarkGold,
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
                
                Spacer(Modifier.height(4.dp))
                
                Text(
                    text = vendor.name,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    color = RoyalNavy,
                    maxLines = 1
                )
                
                Text(category, fontSize = 11.sp, color = SlateGray, fontWeight = FontWeight.Medium)
                
                Spacer(Modifier.height(6.dp))
                
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.LocationOn, null, tint = EmeraldGreen, modifier = Modifier.size(11.dp))
                    Spacer(Modifier.width(2.dp))
                    Text(vendor.locality, fontSize = 10.sp, color = SlateGray, fontWeight = FontWeight.Bold)
                    Spacer(Modifier.width(10.dp))
                    Icon(Icons.Default.Star, null, tint = ChampagneGold, modifier = Modifier.size(11.dp))
                    Spacer(Modifier.width(2.dp))
                    Text(vendor.rating.toString(), fontSize = 10.sp, fontWeight = FontWeight.Black, color = RoyalNavy)
                }
                
                Spacer(Modifier.height(6.dp))
                
                Text(
                    text = priceLabel,
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Black,
                    color = RoyalNavy
                )
            }

            Spacer(Modifier.width(8.dp))

            Box(
                modifier = Modifier
                    .size(36.dp)
                    .clip(CircleShape)
                    .background(RoseRed.copy(alpha = 0.08f))
                    .clickable { onRemove() },
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Favorite,
                    contentDescription = "Remove",
                    tint = RoseRed,
                    modifier = Modifier.size(18.dp)
                )
            }
        }
    }
}
