package com.gomandap.admin.presentation.liveops

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.common.design.GomandapTokens

data class StandbyVendor(
    val id: String,
    val name: String,
    val category: String,
    val phone: String,
    val location: String,
    val rating: Float,
    val isAvailable: Boolean,
    val note: String = ""
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LiveOpsRadarScreen(onBack: () -> Unit) {
    val context = LocalContext.current

    val standbyVendors = remember {
        listOf(
            StandbyVendor("S001", "Lens & Light Studio", "Photography", "+91 98765 11111", "Banjara Hills, Hyderabad", 4.8f, true),
            StandbyVendor("S002", "Dream Decors", "Decoration", "+91 98765 22222", "Jubilee Hills, Hyderabad", 4.6f, true),
            StandbyVendor("S003", "Spice Route Catering", "Catering", "+91 98765 33333", "Madhapur, Hyderabad", 4.7f, true),
            StandbyVendor("S004", "Glam Squad Makeup", "Makeup", "+91 98765 44444", "Kondapur, Hyderabad", 4.5f, false, "Booked until 3 PM"),
            StandbyVendor("S005", "Royal Banquet Hall", "Venue", "+91 98765 55555", "Gachibowli, Hyderabad", 4.9f, true),
            StandbyVendor("S006", "Melody Music Band", "Entertainment", "+91 98765 66666", "Kukatpally, Hyderabad", 4.4f, true),
        )
    }

    var selectedCategory by remember { mutableStateOf("All") }
    val categories = listOf("All", "Photography", "Decoration", "Catering", "Makeup", "Venue", "Entertainment")

    val filtered = if (selectedCategory == "All") standbyVendors
    else standbyVendors.filter { it.category == selectedCategory }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Emergency Contacts", fontWeight = FontWeight.Black, fontSize = 18.sp, color = GomandapTokens.Colors.royalNavy)
                        Text("Standby backup partners", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, "Back", tint = GomandapTokens.Colors.royalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = GomandapTokens.Colors.pearlWhite)
            )
        },
        containerColor = GomandapTokens.Colors.softMist
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding)) {

            // Info banner
            Card(
                modifier = Modifier.fillMaxWidth().padding(GomandapTokens.Spacing.md),
                shape = GomandapTokens.Shapes.large,
                colors = CardDefaults.cardColors(containerColor = Color(0xFFEF4444).copy(alpha = 0.08f)),
                border = CardDefaults.outlinedCardBorder()
            ) {
                Row(
                    modifier = Modifier.padding(GomandapTokens.Spacing.md),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
                ) {
                    Icon(Icons.Default.Info, null, tint = Color(0xFFEF4444), modifier = Modifier.size(20.dp))
                    Text(
                        "If a vendor cancels, call available standby partners below one by one to negotiate a replacement.",
                        fontSize = 12.sp,
                        color = GomandapTokens.Colors.royalNavy,
                        lineHeight = 16.sp
                    )
                }
            }

            // Category filter chips
            ScrollableTabRow(
                selectedTabIndex = categories.indexOf(selectedCategory),
                containerColor = GomandapTokens.Colors.pearlWhite,
                edgePadding = GomandapTokens.Spacing.md,
                divider = {}
            ) {
                categories.forEach { cat ->
                    Tab(
                        selected = selectedCategory == cat,
                        onClick = { selectedCategory = cat },
                        text = {
                            Text(
                                cat,
                                fontSize = 12.sp,
                                fontWeight = if (selectedCategory == cat) FontWeight.Bold else FontWeight.Normal,
                                color = if (selectedCategory == cat) GomandapTokens.Colors.royalNavy else GomandapTokens.Colors.slateGray
                            )
                        }
                    )
                }
            }

            Spacer(Modifier.height(GomandapTokens.Spacing.xs))

            LazyColumn(
                contentPadding = PaddingValues(GomandapTokens.Spacing.md),
                verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
            ) {
                items(filtered) { vendor ->
                    StandbyVendorCard(
                        vendor = vendor,
                        onCall = {
                            val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:${vendor.phone}"))
                            context.startActivity(intent)
                        }
                    )
                }
            }
        }
    }
}

@Composable
private fun StandbyVendorCard(
    vendor: StandbyVendor,
    onCall: () -> Unit
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
            // Avatar
            Box(
                modifier = Modifier
                    .size(48.dp)
                    .background(
                        if (vendor.isAvailable) GomandapTokens.Colors.emeraldGreenLight
                        else GomandapTokens.Colors.lightSlate,
                        CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    vendor.name.first().toString(),
                    fontWeight = FontWeight.Black,
                    fontSize = 18.sp,
                    color = if (vendor.isAvailable) GomandapTokens.Colors.emeraldGreenDark
                    else GomandapTokens.Colors.slateGray
                )
            }

            Spacer(Modifier.width(GomandapTokens.Spacing.sm))

            Column(modifier = Modifier.weight(1f)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(vendor.name, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy, modifier = Modifier.weight(1f), maxLines = 1, overflow = TextOverflow.Ellipsis)
                    Surface(
                        color = if (vendor.isAvailable) GomandapTokens.Colors.emeraldGreenLight else GomandapTokens.Colors.lightSlate,
                        shape = GomandapTokens.Shapes.pill
                    ) {
                        Text(
                            if (vendor.isAvailable) "Available" else "Busy",
                            color = if (vendor.isAvailable) GomandapTokens.Colors.emeraldGreenDark else GomandapTokens.Colors.slateGray,
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                }
                Text(vendor.category, fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Place, null, tint = GomandapTokens.Colors.slateGray, modifier = Modifier.size(11.dp))
                    Spacer(Modifier.width(2.dp))
                    Text(vendor.location, fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.Star, null, tint = GomandapTokens.Colors.champagneGold, modifier = Modifier.size(11.dp))
                    Spacer(Modifier.width(2.dp))
                    Text("${vendor.rating}", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                }
                if (vendor.note.isNotEmpty()) {
                    Text(vendor.note, fontSize = 10.sp, color = GomandapTokens.Colors.warning)
                }
            }

            Spacer(Modifier.width(GomandapTokens.Spacing.xs))

            FilledIconButton(
                onClick = onCall,
                colors = IconButtonDefaults.filledIconButtonColors(
                    containerColor = if (vendor.isAvailable) GomandapTokens.Colors.royalNavy else GomandapTokens.Colors.lightSlate
                ),
                modifier = Modifier.size(44.dp)
            ) {
                Icon(Icons.Default.Phone, "Call", tint = if (vendor.isAvailable) Color.White else GomandapTokens.Colors.slateGray, modifier = Modifier.size(20.dp))
            }
        }
    }
}
