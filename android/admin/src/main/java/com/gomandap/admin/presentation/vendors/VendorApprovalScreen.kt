package com.gomandap.admin.presentation.vendors

import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.domain.model.*
import com.gomandap.app.presentation.theme.*
import com.gomandap.admin.data.vendor.VendorRepository
import kotlinx.coroutines.launch

val Vendor.category: String
    get() = when (this) {
        is VenueVendor -> "Banquet"
        is PhotographyVendor -> "Photography"
        is DecorMandapVendor -> "Decorator"
        is CateringVendor -> "Catering"
        is MakeupArtistVendor -> "Makeup"
    }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VendorApprovalScreen(onBackClick: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    
    val allVendors by VendorRepository.vendors.collectAsState()
    val pendingVendors = remember(allVendors) {
        allVendors.filter { it.approvalStatus == ApprovalStatus.PENDING_APPROVAL }
    }

    var selectedVendor by remember { mutableStateOf<Vendor?>(null) }
    var showRevisionDialog by remember { mutableStateOf(false) }
    var revisionNotes by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Operations Approvals Center", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = SoftMist
    ) { padding ->
        Box(modifier = Modifier.fillMaxSize().padding(padding)) {
            if (pendingVendors.isEmpty()) {
                // Celebration Empty State
                Column(
                    modifier = Modifier.fillMaxSize().padding(32.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Card(
                        shape = RoundedCornerShape(50),
                        colors = CardDefaults.cardColors(containerColor = EmeraldGreen.copy(alpha = 0.1f)),
                        border = BorderStroke(2.dp, EmeraldGreen),
                        modifier = Modifier.size(80.dp)
                    ) {
                        Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
                            Icon(Icons.Default.CheckCircle, contentDescription = null, tint = EmeraldGreen, modifier = Modifier.size(40.dp))
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    Text("All Partners Verified", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                    Text(
                        "Gomandap catalog is 100% compliant. No pending vendor submissions found.",
                        color = SlateGray,
                        fontSize = 12.sp,
                        textAlign = androidx.compose.ui.text.style.TextAlign.Center,
                        modifier = Modifier.padding(horizontal = 24.dp)
                    )
                }
            } else {
                // Pending Review Queue
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    item {
                        Text(
                            "Pending Storefront Verifications (${pendingVendors.size})",
                            fontWeight = FontWeight.Black,
                            fontSize = 15.sp,
                            color = RoyalNavy,
                            modifier = Modifier.padding(bottom = 4.dp)
                        )
                    }

                    items(pendingVendors) { vendor ->
                        Card(
                            modifier = Modifier.fillMaxWidth().clickable { selectedVendor = vendor },
                            shape = RoundedCornerShape(12.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            border = BorderStroke(1.dp, LightSlate.copy(alpha = 0.5f)),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Row(
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    modifier = Modifier.fillMaxWidth(),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Column {
                                        Text(vendor.name, fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)
                                        Text(vendor.locality, fontSize = 12.sp, color = SlateGray)
                                    }
                                    Box(
                                        modifier = Modifier
                                            .background(ChampagneGold.copy(alpha = 0.2f), RoundedCornerShape(4.dp))
                                            .padding(horizontal = 8.dp, vertical = 4.dp)
                                    ) {
                                        Text(
                                            vendor.category.uppercase(),
                                            color = DarkGold,
                                            fontSize = 9.sp,
                                            fontWeight = FontWeight.Black
                                        )
                                    }
                                }

                                Spacer(Modifier.height(12.dp))
                                Divider(color = LightSlate.copy(alpha = 0.3f))
                                Spacer(Modifier.height(12.dp))

                                Row(
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    modifier = Modifier.fillMaxWidth(),
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Icon(Icons.Default.VerifiedUser, null, tint = SlateGray, modifier = Modifier.size(16.dp))
                                        Spacer(Modifier.width(6.dp))
                                        val gstin = vendor.details["gstin"] ?: "Pending GSTIN"
                                        Text(
                                            "PAN/GSTIN: ${gstin.ifBlank { "Not Specified" }}",
                                            fontSize = 11.sp,
                                            color = SlateGray
                                        )
                                    }
                                    
                                    Text(
                                        "Base Price: ₹${vendor.basePrice.toInt()}",
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold,
                                        color = RoyalNavy
                                    )
                                }
                            }
                        }
                    }
                }
            }

            // Detailed Verification Tabbed Sheet Overlay
            selectedVendor?.let { vendor ->
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Color.Black.copy(alpha = 0.6f))
                        .clickable { selectedVendor = null }
                ) {
                    Card(
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .fillMaxWidth()
                            .fillMaxHeight(0.9f)
                            .clickable(enabled = false) {}, // Bypasses click to close
                        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White)
                    ) {
                        Column(modifier = Modifier.fillMaxSize()) {
                            // Sheet Title Header
                            Row(
                                modifier = Modifier.fillMaxWidth().padding(20.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(modifier = Modifier.weight(1f)) {
                                    Text("Storefront Audit Sheet", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = ChampagneGold)
                                    Text(vendor.name, fontWeight = FontWeight.Black, fontSize = 20.sp, color = RoyalNavy, maxLines = 1)
                                }
                                IconButton(onClick = { selectedVendor = null }) {
                                    Icon(Icons.Default.Close, contentDescription = "Close", tint = RoyalNavy)
                                }
                            }

                            var selectedTabIndex by remember { mutableStateOf(0) }
                            val tabs = listOf("Core Profile", "Pricing & Policies", "Media Sandbox")

                            TabRow(
                                selectedTabIndex = selectedTabIndex,
                                containerColor = Color.White,
                                contentColor = RoyalNavy,
                                indicator = { tabPositions ->
                                    TabRowDefaults.Indicator(
                                        Modifier.tabIndicatorOffset(tabPositions[selectedTabIndex]),
                                        color = ChampagneGold,
                                        height = 3.dp
                                    )
                                }
                            ) {
                                tabs.forEachIndexed { index, title ->
                                    Tab(
                                        selected = selectedTabIndex == index,
                                        onClick = { selectedTabIndex = index },
                                        text = { Text(title, fontSize = 12.sp, fontWeight = if(selectedTabIndex==index) FontWeight.Bold else FontWeight.Normal) }
                                    )
                                }
                            }

                            // Tab Contents
                            Column(
                                modifier = Modifier
                                    .weight(1f)
                                    .padding(horizontal = 20.dp, vertical = 10.dp)
                                    .verticalScroll(rememberScrollState()),
                                verticalArrangement = Arrangement.spacedBy(16.dp)
                            ) {
                                when (selectedTabIndex) {
                                    0 -> CoreProfileTab(vendor)
                                    1 -> PricingPoliciesTab(vendor)
                                    2 -> MediaSandboxTab(vendor)
                                }
                            }

                            // Decision Drawer Bar
                            Surface(color = Color.White, shadowElevation = 8.dp) {
                                Row(
                                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    Button(
                                        onClick = { showRevisionDialog = true },
                                        modifier = Modifier.weight(1f).height(48.dp),
                                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFEE2E2)),
                                        shape = RoundedCornerShape(8.dp)
                                    ) {
                                        Text("Request Revision", color = Color(0xFFDC2626), fontWeight = FontWeight.Bold)
                                    }

                                    Button(
                                        onClick = {
                                            scope.launch {
                                                VendorRepository.updateVendor(vendor.id) { v ->
                                                    when (v) {
                                                        is VenueVendor -> v.copy(approvalStatus = ApprovalStatus.APPROVED, isLive = true, isVerified = true)
                                                        is PhotographyVendor -> v.copy(approvalStatus = ApprovalStatus.APPROVED, isLive = true, isVerified = true)
                                                        is DecorMandapVendor -> v.copy(approvalStatus = ApprovalStatus.APPROVED, isLive = true, isVerified = true)
                                                        is CateringVendor -> v.copy(approvalStatus = ApprovalStatus.APPROVED, isLive = true, isVerified = true)
                                                        is MakeupArtistVendor -> v.copy(approvalStatus = ApprovalStatus.APPROVED, isLive = true, isVerified = true)
                                                        else -> v
                                                    }
                                                }
                                                Toast.makeText(context, "🎉 ${vendor.name} verified and published live!", Toast.LENGTH_LONG).show()
                                                selectedVendor = null
                                            }
                                        },
                                        modifier = Modifier.weight(1.2f).height(48.dp),
                                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                                        shape = RoundedCornerShape(8.dp)
                                    ) {
                                        Text("Verify & Publish Live", color = Color.White, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Revision Request Notes Dialog
        if (showRevisionDialog) {
            AlertDialog(
                onDismissRequest = { showRevisionDialog = false },
                title = { Text("Request Storefront Revision", fontWeight = FontWeight.Bold) },
                text = {
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Text("Specify instructions detailing what the vendor needs to update in their storefront business sheet.", fontSize = 12.sp, color = SlateGray)
                        OutlinedTextField(
                            value = revisionNotes,
                            onValueChange = { revisionNotes = it },
                            label = { Text("Ops Revision Instructions") },
                            modifier = Modifier.fillMaxWidth(),
                            minLines = 3,
                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                        )
                    }
                },
                confirmButton = {
                    Button(
                        onClick = {
                            if (revisionNotes.isBlank()) {
                                Toast.makeText(context, "Please specify revision notes!", Toast.LENGTH_SHORT).show()
                                return@Button
                            }
                            selectedVendor?.let { vendor ->
                                scope.launch {
                                    VendorRepository.updateVendor(vendor.id) { v ->
                                        when (v) {
                                            is VenueVendor -> v.copy(approvalStatus = ApprovalStatus.REVISION_REQUESTED, adminNotes = revisionNotes, isLive = false)
                                            is PhotographyVendor -> v.copy(approvalStatus = ApprovalStatus.REVISION_REQUESTED, adminNotes = revisionNotes, isLive = false)
                                            is DecorMandapVendor -> v.copy(approvalStatus = ApprovalStatus.REVISION_REQUESTED, adminNotes = revisionNotes, isLive = false)
                                            is CateringVendor -> v.copy(approvalStatus = ApprovalStatus.REVISION_REQUESTED, adminNotes = revisionNotes, isLive = false)
                                            is MakeupArtistVendor -> v.copy(approvalStatus = ApprovalStatus.REVISION_REQUESTED, adminNotes = revisionNotes, isLive = false)
                                            else -> v
                                        }
                                    }
                                    Toast.makeText(context, "⚠️ Sent revision requests to partner.", Toast.LENGTH_SHORT).show()
                                    showRevisionDialog = false
                                    selectedVendor = null
                                }
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = ChampagneGold)
                    ) {
                        Text("Send Requests", color = RoyalNavy, fontWeight = FontWeight.Bold)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showRevisionDialog = false }) {
                        Text("Cancel", color = SlateGray)
                    }
                }
            )
        }
    }
}

@Composable
fun CoreProfileTab(vendor: Vendor) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        DetailRow("Location", vendor.locality)
        DetailRow("Base Starting Price", "₹${vendor.basePrice}")
        DetailRow("Year Established", vendor.yearEstablished.toString())
        DetailRow("Instagram", vendor.instagramUrl.ifBlank { "Not provided" })
        DetailRow("Google Maps", vendor.googleMapsUrl.ifBlank { "Not provided" })
        
        Spacer(Modifier.height(8.dp))
        Text("Operations Compliance Checklist", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
        Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
            val gstin = vendor.details["gstin"] ?: ""
            ChecklistRow(gstin.isNotBlank(), "GSTIN / PAN Structure Provided: $gstin")
            
            if (vendor is CateringVendor) {
                val fssai = vendor.details["fssai"] ?: ""
                ChecklistRow(fssai.isNotBlank(), "FSSAI Food Safety License: $fssai")
            }
        }
    }
}

@Composable
fun PricingPoliciesTab(vendor: Vendor) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("Booking Policies", fontWeight = FontWeight.Bold, color = RoyalNavy)
        DetailRow("Advance Required", "${vendor.paymentAdvancePercent}%")
        DetailRow("Cancellation", vendor.cancellationPolicy)
        
        Divider(modifier = Modifier.padding(vertical = 8.dp))
        Text("Category Deep Specifications", fontWeight = FontWeight.Bold, color = RoyalNavy)
        
        when (vendor) {
            is VenueVendor -> {
                DetailRow("Venue Type", vendor.venueType.name)
                DetailRow("Veg Price / Plate", "₹${vendor.pricePerPlateVeg}")
                DetailRow("Non-Veg Price / Plate", "₹${vendor.pricePerPlateNonVeg}")
                DetailRow("Rooms Available", if (vendor.hasRooms) "${vendor.roomCount} Rooms" else "No")
                DetailRow("Valet Parking", "${vendor.parkingCount} Cars")
                DetailRow("Decor Policy", vendor.decorPolicy)
                DetailRow("DJ Policy", vendor.djPolicy)
                DetailRow("Generator Backup", if (vendor.generatorBackup) "Available" else "None")
                
                Spacer(Modifier.height(8.dp))
                Text("Spaces Available (${vendor.spaces.size})", fontWeight = FontWeight.Bold, color = RoyalNavy)
                vendor.spaces.forEach { space ->
                    Card(colors = CardDefaults.cardColors(containerColor = PearlWhite), border = BorderStroke(1.dp, LightSlate)) {
                        Column(modifier = Modifier.padding(10.dp).fillMaxWidth()) {
                            Text("${space.name} (${space.type})", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                            Text("Seating: ${space.seatingCapacity} | Floating: ${space.floatingCapacity}", fontSize = 11.sp)
                        }
                    }
                }
            }
            is PhotographyVendor -> {
                DetailRow("Styles", vendor.style.joinToString { it.name })
                DetailRow("Photo Only / Day", "₹${vendor.pricePhotoOnly}")
                DetailRow("Video Only / Day", "₹${vendor.priceVideoOnly}")
                DetailRow("Combo / Day", "₹${vendor.priceCombo}")
                DetailRow("Delivery Timeline", "${vendor.deliveryTimeWeeks} Weeks")
                DetailRow("Includes Album", if (vendor.includesAlbum) "Yes" else "No")
                DetailRow("Outstation Travel", if (vendor.clientBearsTravelCost) "Client bears cost" else "Vendor bears cost")
            }
            is DecorMandapVendor -> {
                DetailRow("Mandap Styles", vendor.mandapStyle.joinToString { it.name })
                DetailRow("Specialties", vendor.specialties.joinToString())
                DetailRow("Setup Time", "${vendor.setupTimeHours} Hours")
                DetailRow("Standard Dimensions", vendor.dimensions)
                DetailRow("Minimum Budget", "₹${vendor.minimumBudget}")
            }
            is CateringVendor -> {
                DetailRow("Cuisines", vendor.cuisineTypes.joinToString())
                DetailRow("Service Styles", vendor.serviceTypes.joinToString())
                DetailRow("Per Plate Price", "₹${vendor.pricePerPlate}")
                DetailRow("Minimum Guests", "${vendor.minGuestCount}")
                DetailRow("Includes Crockery", if (vendor.includesCrockery) "Yes" else "No")
                DetailRow("Waitstaff per 100", "${vendor.waitstaffCount}")
            }
            is MakeupArtistVendor -> {
                DetailRow("Makeup Styles", vendor.makeupTypes.joinToString { it.name })
                DetailRow("Studio Pricing", "₹${vendor.studioPrice}")
                DetailRow("Venue Pricing", "₹${vendor.venuePrice}")
                DetailRow("Party Makeup (Guests)", "₹${vendor.partyMakeupPrice}")
                DetailRow("Hair Included", if (vendor.isHairStylingIncluded) "Yes" else "No")
                DetailRow("Draping Included", if (vendor.isDrapingIncluded) "Yes" else "No")
                DetailRow("Paid Trial", if (vendor.isPaidTrialAvailable) "Available" else "No")
            }
        }
    }
}

@Composable
fun MediaSandboxTab(vendor: Vendor) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("Cover Photo Hero Image", fontWeight = FontWeight.Bold, color = RoyalNavy)
        if (vendor.coverPhotoUrl.isNotBlank()) {
            Card(shape = RoundedCornerShape(12.dp), modifier = Modifier.fillMaxWidth().height(150.dp), border = BorderStroke(1.dp, ChampagneGold)) {
                Box(modifier = Modifier.fillMaxSize().background(RoyalNavy), contentAlignment = Alignment.Center) {
                    Text("Cover Photo Display", color = Color.White)
                }
            }
        }
        
        Text("Gallery Submissions", fontWeight = FontWeight.Bold, color = RoyalNavy)
        Row(modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(10.dp)) {
            val photos = vendor.photos.ifEmpty { listOf("mock_image") }
            photos.forEachIndexed { index, _ ->
                Card(shape = RoundedCornerShape(8.dp), modifier = Modifier.size(width = 120.dp, height = 95.dp)) {
                    Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize().background(SlateGray)) {
                        Icon(Icons.Default.Image, contentDescription = null, tint = Color.White)
                        Text("Photo #${index + 1}", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Bold, modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 6.dp))
                    }
                }
            }
        }

        Text("Cinematic Walkthrough", fontWeight = FontWeight.Bold, color = RoyalNavy)
        Card(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(12.dp), colors = CardDefaults.cardColors(containerColor = SoftMist), border = BorderStroke(1.dp, LightSlate)) {
            Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.PlayCircle, null, tint = ChampagneGold, modifier = Modifier.size(36.dp))
                Spacer(Modifier.width(10.dp))
                Column {
                    Text("YouTube URL", fontSize = 11.sp, color = SlateGray, fontWeight = FontWeight.Bold)
                    Text(text = vendor.videoUrl.ifBlank { "No walkthrough video provided." }, fontSize = 12.sp, color = RoyalNavy, fontWeight = FontWeight.Bold, maxLines = 1)
                }
            }
        }
    }
}

@Composable
fun DetailRow(label: String, value: String) {
    Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
        Text(text = label, fontSize = 13.sp, color = SlateGray, fontWeight = FontWeight.Medium)
        Text(text = value, fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Black)
    }
}

@Composable
fun ChecklistRow(checked: Boolean, text: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(if (checked) Icons.Default.CheckCircle else Icons.Default.Cancel, null, tint = if (checked) EmeraldGreen else RoseRed, modifier = Modifier.size(18.dp))
        Spacer(Modifier.width(8.dp))
        Text(text, fontSize = 12.sp, color = RoyalNavy)
    }
}
