package com.gomandap.admin.presentation.cms

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.common.design.GomandapTokens

data class FeaturedVendorSlot(
    val slot: Int,
    val vendorId: String?,
    val vendorName: String?,
    val category: String?,
    val location: String?
)

data class VendorOption(
    val id: String,
    val name: String,
    val category: String,
    val location: String,
    val rating: Float
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StorefrontCmsScreen(onBack: () -> Unit) {

    val allVendors = remember {
        listOf(
            VendorOption("V001", "Pixel Studios", "Photography", "Banjara Hills", 4.9f),
            VendorOption("V002", "Royal Decors", "Decoration", "Jubilee Hills", 4.8f),
            VendorOption("V003", "Spice Garden", "Catering", "Madhapur", 4.7f),
            VendorOption("V004", "Glam Squad", "Makeup", "Kondapur", 4.8f),
            VendorOption("V005", "Grand Palace", "Venue", "Gachibowli", 4.9f),
            VendorOption("V006", "Melody Band", "Entertainment", "Kukatpally", 4.6f),
            VendorOption("V007", "Lens Magic", "Photography", "Ameerpet", 4.7f),
            VendorOption("V008", "Bloom Decors", "Decoration", "Hitech City", 4.5f),
        )
    }

    var featuredSlots by remember {
        mutableStateOf(
            listOf(
                FeaturedVendorSlot(1, "V001", "Pixel Studios", "Photography", "Banjara Hills"),
                FeaturedVendorSlot(2, "V005", "Grand Palace", "Venue", "Gachibowli"),
                FeaturedVendorSlot(3, null, null, null, null),
                FeaturedVendorSlot(4, null, null, null, null),
                FeaturedVendorSlot(5, null, null, null, null),
            )
        )
    }

    var showPickerForSlot by remember { mutableStateOf<Int?>(null) }
    var saved by remember { mutableStateOf(false) }

    if (showPickerForSlot != null) {
        VendorPickerDialog(
            vendors = allVendors,
            onSelect = { vendor ->
                featuredSlots = featuredSlots.map { slot ->
                    if (slot.slot == showPickerForSlot) {
                        slot.copy(vendorId = vendor.id, vendorName = vendor.name, category = vendor.category, location = vendor.location)
                    } else slot
                }
                showPickerForSlot = null
                saved = false
            },
            onDismiss = { showPickerForSlot = null }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Featured Vendors", fontWeight = FontWeight.Black, fontSize = 18.sp, color = GomandapTokens.Colors.royalNavy)
                        Text("Client app home carousel · This week", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, "Back", tint = GomandapTokens.Colors.royalNavy)
                    }
                },
                actions = {
                    TextButton(
                        onClick = { saved = true },
                        colors = ButtonDefaults.textButtonColors(contentColor = GomandapTokens.Colors.emeraldGreen)
                    ) {
                        Icon(Icons.Default.Check, null, modifier = Modifier.size(16.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("Save", fontWeight = FontWeight.Bold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = GomandapTokens.Colors.pearlWhite)
            )
        },
        containerColor = GomandapTokens.Colors.softMist
    ) { padding ->
        LazyColumn(
            contentPadding = PaddingValues(GomandapTokens.Spacing.md),
            verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm),
            modifier = Modifier.fillMaxSize().padding(padding)
        ) {
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = GomandapTokens.Shapes.large,
                    colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.champagneGoldLight)
                ) {
                    Row(
                        modifier = Modifier.padding(GomandapTokens.Spacing.md),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
                    ) {
                        Icon(Icons.Default.Info, null, tint = GomandapTokens.Colors.champagneGoldDark, modifier = Modifier.size(18.dp))
                        Text(
                            "Select up to 5 vendors to feature on the client app's home screen carousel this week. Tap a slot to change.",
                            fontSize = 12.sp,
                            color = GomandapTokens.Colors.royalNavy,
                            lineHeight = 16.sp
                        )
                    }
                }
            }

            if (saved) {
                item {
                    Card(
                        modifier = Modifier.fillMaxWidth(),
                        shape = GomandapTokens.Shapes.large,
                        colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.emeraldGreenLight)
                    ) {
                        Row(
                            modifier = Modifier.padding(GomandapTokens.Spacing.md),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
                        ) {
                            Icon(Icons.Default.CheckCircle, null, tint = GomandapTokens.Colors.emeraldGreen, modifier = Modifier.size(18.dp))
                            Text("Featured vendors saved! Client app will update within 60 seconds.", fontSize = 12.sp, color = GomandapTokens.Colors.emeraldGreenDark)
                        }
                    }
                }
            }

            itemsIndexed(featuredSlots) { _, slot ->
                FeaturedSlotCard(
                    slot = slot,
                    onTap = { showPickerForSlot = slot.slot },
                    onRemove = {
                        featuredSlots = featuredSlots.map { s ->
                            if (s.slot == slot.slot) s.copy(vendorId = null, vendorName = null, category = null, location = null)
                            else s
                        }
                        saved = false
                    }
                )
            }
        }
    }
}

@Composable
private fun FeaturedSlotCard(
    slot: FeaturedVendorSlot,
    onTap: () -> Unit,
    onRemove: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth().clickable { onTap() },
        shape = GomandapTokens.Shapes.large,
        colors = CardDefaults.cardColors(
            containerColor = if (slot.vendorId != null) GomandapTokens.Colors.pearlWhite
            else GomandapTokens.Colors.softMist
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = if (slot.vendorId != null) GomandapTokens.Elevation.low else 0.dp),
        border = if (slot.vendorId == null) CardDefaults.outlinedCardBorder() else null
    ) {
        Row(
            modifier = Modifier.padding(GomandapTokens.Spacing.md),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Slot number badge
            Box(
                modifier = Modifier
                    .size(36.dp)
                    .background(
                        if (slot.vendorId != null) GomandapTokens.Colors.champagneGold else GomandapTokens.Colors.lightSlate,
                        CircleShape
                    ),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    "${slot.slot}",
                    fontWeight = FontWeight.Black,
                    fontSize = 14.sp,
                    color = if (slot.vendorId != null) GomandapTokens.Colors.royalNavy else GomandapTokens.Colors.slateGray
                )
            }

            Spacer(Modifier.width(GomandapTokens.Spacing.sm))

            if (slot.vendorId != null) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(slot.vendorName ?: "", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                    Text("${slot.category} · ${slot.location}", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                }
                IconButton(onClick = onRemove, modifier = Modifier.size(36.dp)) {
                    Icon(Icons.Default.Close, "Remove", tint = GomandapTokens.Colors.slateGray, modifier = Modifier.size(16.dp))
                }
            } else {
                Column(modifier = Modifier.weight(1f)) {
                    Text("Slot ${slot.slot} — Empty", fontWeight = FontWeight.SemiBold, fontSize = 13.sp, color = GomandapTokens.Colors.slateGray)
                    Text("Tap to select a vendor", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                }
                Icon(Icons.Default.Add, "Add", tint = GomandapTokens.Colors.slateGray)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun VendorPickerDialog(
    vendors: List<VendorOption>,
    onSelect: (VendorOption) -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Select a Vendor", fontWeight = FontWeight.Black, color = GomandapTokens.Colors.royalNavy) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xs)) {
                vendors.forEach { vendor ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onSelect(vendor) }
                            .padding(vertical = GomandapTokens.Spacing.xs),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Box(
                            modifier = Modifier.size(36.dp).background(GomandapTokens.Colors.champagneGoldLight, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(vendor.name.first().toString(), fontWeight = FontWeight.Black, color = GomandapTokens.Colors.champagneGoldDark)
                        }
                        Spacer(Modifier.width(GomandapTokens.Spacing.sm))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(vendor.name, fontWeight = FontWeight.Bold, fontSize = 13.sp, color = GomandapTokens.Colors.royalNavy, maxLines = 1, overflow = TextOverflow.Ellipsis)
                            Text("${vendor.category} · ${vendor.location} · ★${vendor.rating}", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                        }
                        Icon(Icons.Default.ChevronRight, null, tint = GomandapTokens.Colors.lightSlate)
                    }
                    if (vendor != vendors.last()) Divider(color = GomandapTokens.Colors.lightSlate, thickness = 0.5.dp)
                }
            }
        },
        confirmButton = {},
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        },
        containerColor = GomandapTokens.Colors.pearlWhite,
        shape = GomandapTokens.Shapes.extraLarge
    )
}
