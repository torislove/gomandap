package com.gomandap.vendor.presentation.onboard

import android.widget.Toast
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.domain.model.*
import com.gomandap.app.presentation.search.MakeupType
import com.gomandap.app.presentation.theme.*
import com.gomandap.vendor.data.vendor.VendorRepository
import kotlinx.coroutines.launch
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VendorOnboardScreen(onOnboardComplete: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    var selectedCategory by remember { mutableStateOf("Banquet") }
    var businessName by remember { mutableStateOf("") }
    var locality by remember { mutableStateOf("") }
    var basePriceInput by remember { mutableStateOf("") }

    // Credentials & Media States
    var gstinInput by remember { mutableStateOf("") }
    var fssaiInput by remember { mutableStateOf("") }
    var photosInput by remember { mutableStateOf("https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=2098&auto=format&fit=crop, https://images.unsplash.com/photo-1544078755-9ee020cda4fb?q=80&w=2070&auto=format&fit=crop") }
    var videoUrlInput by remember { mutableStateOf("https://www.youtube.com/watch?v=dQw4w9WgXcQ") }

    // Banquet specific states
    var seatingCap by remember { mutableStateOf("500") }
    var floatingCap by remember { mutableStateOf("1000") }
    var platePriceVeg by remember { mutableStateOf("800") }
    var platePriceNonVeg by remember { mutableStateOf("1200") }
    var hasRooms by remember { mutableStateOf(true) }
    var parkingCount by remember { mutableStateOf("100") }
    var alcoholAllowed by remember { mutableStateOf(false) }
    var decorPolicy by remember { mutableStateOf("In-house Only") }

    // Photography specific states
    val styles = remember { mutableStateListOf(PhotographyStyle.Candid, PhotographyStyle.Cinematic) }
    var pricePerDay by remember { mutableStateOf("45000") }
    var portfolioVideoUrl by remember { mutableStateOf("https://example.com/video.mp4") }
    var deliveryTimeWeeks by remember { mutableStateOf("4") }

    // Decorator specific states
    var mandapStyle by remember { mutableStateOf(MandapStyle.Traditional) }
    var dimensions by remember { mutableStateOf("30x30 ft") }
    var setupTimeHours by remember { mutableStateOf("8") }

    // Catering specific states
    var cuisinesInput by remember { mutableStateOf("South Indian, North Indian, Jain veg") }
    var minGuestCount by remember { mutableStateOf("150") }
    var pricePerPlate by remember { mutableStateOf("600") }

    // Makeup specific states
    val makeupTypes = remember { mutableStateListOf(MakeupType.HDMakeup, MakeupType.Airbrush) }
    var isHairIncluded by remember { mutableStateOf(true) }
    var isDrapingIncluded by remember { mutableStateOf(true) }
    var isTrialAvailable by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("GoMandap ", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 20.sp)
                        Text("Partner Setup", fontWeight = FontWeight.Black, color = ChampagneGold, fontSize = 20.sp)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = PearlWhite
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                "🌸 Onboard Your Business",
                fontWeight = FontWeight.Black,
                fontSize = 18.sp,
                color = RoyalNavy
            )
            Text(
                "Setup your storefront in 3 simple steps. Your submission will go to the operations team for verification.",
                fontSize = 12.sp,
                color = SlateGray
            )

            // Step 1: Select Category
            Text("Step 1: Select Category", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .horizontalScroll(rememberScrollState()),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                listOf("Banquet", "Photography", "Decorator", "Catering", "Makeup").forEach { cat ->
                    val selected = cat == selectedCategory
                    Surface(
                        onClick = { selectedCategory = cat },
                        color = if (selected) RoyalNavy else Color.White,
                        shape = RoundedCornerShape(12.dp),
                        border = BorderStroke(1.5.dp, if (selected) RoyalNavy else LightSlate),
                        tonalElevation = 2.dp
                    ) {
                        Text(
                            text = cat,
                            color = if (selected) Color.White else RoyalNavy,
                            fontWeight = FontWeight.Bold,
                            fontSize = 13.sp,
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp)
                        )
                    }
                }
            }

            Divider(color = LightSlate.copy(alpha = 0.5f))

            // Step 2: Core Details
            Text("Step 2: Core Details", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(2.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    OutlinedTextField(
                        value = businessName,
                        onValueChange = { businessName = it },
                        label = { Text("Business / Studio Name") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                    )
                    OutlinedTextField(
                        value = locality,
                        onValueChange = { locality = it },
                        label = { Text("Locality (e.g. Banjara Hills, Hyderabad)") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                    )
                    OutlinedTextField(
                        value = basePriceInput,
                        onValueChange = { basePriceInput = it },
                        label = { Text("Starting Base Pricing (₹)") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                    )
                }
            }

            // Step 2B: Credentials & Media Portfolios
            Text("Step 2B: Credentials & Media Portfolios", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(2.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    OutlinedTextField(
                        value = gstinInput,
                        onValueChange = { gstinInput = it },
                        label = { Text("Business GSTIN / PAN Number") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                    )
                    if (selectedCategory == "Catering") {
                        OutlinedTextField(
                            value = fssaiInput,
                            onValueChange = { fssaiInput = it },
                            label = { Text("FSSAI Food License Number") },
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                        )
                    }
                    OutlinedTextField(
                        value = photosInput,
                        onValueChange = { photosInput = it },
                        label = { Text("Portfolio Photos (Comma-separated URLs)") },
                        modifier = Modifier.fillMaxWidth(),
                        minLines = 2,
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                    )
                    OutlinedTextField(
                        value = videoUrlInput,
                        onValueChange = { videoUrlInput = it },
                        label = { Text("Cinematic YouTube / Vimeo Tour URL") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                    )
                }
            }

            Divider(color = LightSlate.copy(alpha = 0.5f))

            // Step 3: Category Specifications
            Text("Step 3: Category Specifications", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)

            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(2.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    when (selectedCategory) {
                        "Banquet" -> {
                            OutlinedTextField(value = seatingCap, onValueChange = { seatingCap = it }, label = { Text("Seating Capacity") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = floatingCap, onValueChange = { floatingCap = it }, label = { Text("Floating Capacity") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = platePriceVeg, onValueChange = { platePriceVeg = it }, label = { Text("Veg Price per Plate (₹)") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = platePriceNonVeg, onValueChange = { platePriceNonVeg = it }, label = { Text("Non-Veg Price per Plate (₹)") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = parkingCount, onValueChange = { parkingCount = it }, label = { Text("Valet Parking Capacity") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = decorPolicy, onValueChange = { decorPolicy = it }, label = { Text("Decor Policy") }, modifier = Modifier.fillMaxWidth())

                            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text("Rooms Available at Hall", fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Bold)
                                Switch(checked = hasRooms, onCheckedChange = { hasRooms = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen))
                            }
                            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text("Outside Alcohol Allowed", fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Bold)
                                Switch(checked = alcoholAllowed, onCheckedChange = { alcoholAllowed = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen))
                            }
                        }
                        "Photography" -> {
                            OutlinedTextField(value = pricePerDay, onValueChange = { pricePerDay = it }, label = { Text("Price per Day (₹)") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = portfolioVideoUrl, onValueChange = { portfolioVideoUrl = it }, label = { Text("Portfolio Video URL") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = deliveryTimeWeeks, onValueChange = { deliveryTimeWeeks = it }, label = { Text("Delivery Time (weeks)") }, modifier = Modifier.fillMaxWidth())

                            Text("Select Camera Specialties", fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Bold)
                            PhotographyStyle.values().forEach { style ->
                                val active = style in styles
                                Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.clickable {
                                    if (active) styles.remove(style) else styles.add(style)
                                }) {
                                    Checkbox(checked = active, onCheckedChange = {
                                        if (active) styles.remove(style) else styles.add(style)
                                    })
                                    Text(style.name, fontSize = 13.sp, color = SlateGray)
                                }
                            }
                        }
                        "Decorator" -> {
                            OutlinedTextField(value = dimensions, onValueChange = { dimensions = it }, label = { Text("Canopy Dimensions (e.g. 30x30 ft)") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = setupTimeHours, onValueChange = { setupTimeHours = it }, label = { Text("Setup Duration (Hours)") }, modifier = Modifier.fillMaxWidth())

                            Text("Select Mandap Theme Style", fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Bold)
                            MandapStyle.values().forEach { style ->
                                Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.clickable {
                                    mandapStyle = style
                                }) {
                                    RadioButton(selected = mandapStyle == style, onClick = { mandapStyle = style })
                                    Text(style.name, fontSize = 13.sp, color = SlateGray)
                                }
                            }
                        }
                        "Catering" -> {
                            OutlinedTextField(value = cuisinesInput, onValueChange = { cuisinesInput = it }, label = { Text("Cuisine Specialties (comma separated)") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = minGuestCount, onValueChange = { minGuestCount = it }, label = { Text("Minimum Guest Count") }, modifier = Modifier.fillMaxWidth())
                            OutlinedTextField(value = pricePerPlate, onValueChange = { pricePerPlate = it }, label = { Text("Base Price per Plate (₹)") }, modifier = Modifier.fillMaxWidth())
                        }
                        "Makeup" -> {
                            OutlinedTextField(value = basePriceInput, onValueChange = { basePriceInput = it }, label = { Text("Premium Package Price (₹)") }, modifier = Modifier.fillMaxWidth())

                            Text("Select Makeup Types Offered", fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Bold)
                            MakeupType.values().forEach { type ->
                                val active = type in makeupTypes
                                Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.clickable {
                                    if (active) makeupTypes.remove(type) else makeupTypes.add(type)
                                }) {
                                    Checkbox(checked = active, onCheckedChange = {
                                        if (active) makeupTypes.remove(type) else makeupTypes.add(type)
                                    })
                                    Text(type.name, fontSize = 13.sp, color = SlateGray)
                                }
                            }

                            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text("Hair Styling Included", fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Bold)
                                Switch(checked = isHairIncluded, onCheckedChange = { isHairIncluded = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen))
                            }
                            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text("Saree/Dhoti Draping Included", fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Bold)
                                Switch(checked = isDrapingIncluded, onCheckedChange = { isDrapingIncluded = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen))
                            }
                            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                                Text("Paid Trial Available", fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Bold)
                                Switch(checked = isTrialAvailable, onCheckedChange = { isTrialAvailable = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen))
                            }
                        }
                    }
                }
            }

            Spacer(Modifier.height(16.dp))

            // Submit Button
            Button(
                onClick = {
                    if (businessName.isBlank() || locality.isBlank()) {
                        Toast.makeText(context, "Please fill in all core details!", Toast.LENGTH_SHORT).show()
                        return@Button
                    }
                    scope.launch {
                        val finalId = "vendor_" + UUID.randomUUID().toString().take(6)
                        val price = basePriceInput.toDoubleOrNull() ?: 0.0
                        val photoList = photosInput.split(",").map { it.trim() }.filter { it.isNotBlank() }

                        val newVendor: Vendor = when (selectedCategory) {
                            "Banquet" -> VenueVendor(
                                id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                imageUrls = photoList.take(2),
                                isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                approvalStatus = ApprovalStatus.PENDING_APPROVAL,
                                adminNotes = "Onboarded via Partner App. Pending credentials verify.",
                                isLive = false,
                                photos = photoList,
                                videoUrl = videoUrlInput,
                                details = mapOf(
                                    "gstin" to gstinInput,
                                    "seating" to seatingCap,
                                    "floating" to floatingCap,
                                    "veg_price" to platePriceVeg,
                                    "non_veg_price" to platePriceNonVeg,
                                    "parking" to parkingCount,
                                    "decor_policy" to decorPolicy,
                                    "has_rooms" to hasRooms.toString(),
                                    "alcohol_allowed" to alcoholAllowed.toString()
                                ),
                                venueType = VenueType.Banquet,
                                pricePerPlateVeg = platePriceVeg.toDoubleOrNull() ?: 500.0,
                                pricePerPlateNonVeg = platePriceNonVeg.toDoubleOrNull() ?: 800.0,
                                seatingCapacity = seatingCap.toIntOrNull() ?: 300,
                                floatingCapacity = floatingCap.toIntOrNull() ?: 500,
                                hasRooms = hasRooms,
                                parkingCount = parkingCount.toIntOrNull() ?: 50,
                                isAlcoholAllowed = alcoholAllowed,
                                decorPolicy = decorPolicy
                            )
                            "Photography" -> PhotographyVendor(
                                id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                imageUrls = photoList.take(2),
                                isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                approvalStatus = ApprovalStatus.PENDING_APPROVAL,
                                adminNotes = "Onboarded via Partner App. Pending credentials verify.",
                                isLive = false,
                                photos = photoList,
                                videoUrl = videoUrlInput,
                                details = mapOf(
                                    "gstin" to gstinInput,
                                    "price_per_day" to pricePerDay,
                                    "delivery_weeks" to deliveryTimeWeeks,
                                    "styles" to styles.joinToString { it.name }
                                ),
                                style = styles.toList(),
                                pricePerDay = pricePerDay.toDoubleOrNull() ?: price,
                                portfolioVideoUrl = videoUrlInput,
                                deliveryTimeWeeks = deliveryTimeWeeks.toIntOrNull() ?: 4
                            )
                            "Decorator" -> DecorMandapVendor(
                                id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                imageUrls = photoList.take(2),
                                isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                approvalStatus = ApprovalStatus.PENDING_APPROVAL,
                                adminNotes = "Onboarded via Partner App. Pending credentials verify.",
                                isLive = false,
                                photos = photoList,
                                videoUrl = videoUrlInput,
                                details = mapOf(
                                    "gstin" to gstinInput,
                                    "dimensions" to dimensions,
                                    "setup_hours" to setupTimeHours,
                                    "mandap_style" to mandapStyle.name
                                ),
                                mandapStyle = mandapStyle,
                                dimensions = dimensions,
                                setupTimeHours = setupTimeHours.toIntOrNull() ?: 6
                            )
                            "Catering" -> CateringVendor(
                                id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                imageUrls = photoList.take(2),
                                isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                approvalStatus = ApprovalStatus.PENDING_APPROVAL,
                                adminNotes = "Onboarded via Partner App. Pending credentials verify.",
                                isLive = false,
                                photos = photoList,
                                videoUrl = videoUrlInput,
                                details = mapOf(
                                    "gstin" to gstinInput,
                                    "fssai" to fssaiInput,
                                    "cuisines" to cuisinesInput,
                                    "min_guests" to minGuestCount,
                                    "veg_plate" to pricePerPlate
                                ),
                                cuisineTypes = cuisinesInput.split(",").map { it.trim() },
                                minGuestCount = minGuestCount.toIntOrNull() ?: 100,
                                pricePerPlate = pricePerPlate.toDoubleOrNull() ?: 500.0
                            )
                            "Makeup" -> MakeupArtistVendor(
                                id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                imageUrls = photoList.take(2),
                                isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                approvalStatus = ApprovalStatus.PENDING_APPROVAL,
                                adminNotes = "Onboarded via Partner App. Pending credentials verify.",
                                isLive = false,
                                photos = photoList,
                                videoUrl = videoUrlInput,
                                details = mapOf(
                                    "gstin" to gstinInput,
                                    "makeup_types" to makeupTypes.joinToString { it.name },
                                    "hair_styling" to isHairIncluded.toString(),
                                    "saree_draping" to isDrapingIncluded.toString(),
                                    "trial_available" to isTrialAvailable.toString()
                                ),
                                makeupTypes = makeupTypes.toList(),
                                isHairStylingIncluded = isHairIncluded,
                                isDrapingIncluded = isDrapingIncluded,
                                isPaidTrialAvailable = isTrialAvailable
                            )
                            else -> error("Unknown Category")
                        }

                        VendorRepository.addVendor(newVendor)
                        Toast.makeText(context, "🎉 Business Onboarded & Submitted for Admin Review!", Toast.LENGTH_LONG).show()
                        onOnboardComplete()
                    }
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp),
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                shape = RoundedCornerShape(8.dp)
            ) {
                Text("Complete Business Setup", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 15.sp)
            }

            Spacer(Modifier.height(30.dp))
        }
    }
}
