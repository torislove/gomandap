@file:OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
package com.gomandap.admin.presentation.vendors

import androidx.compose.foundation.BorderStroke
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
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Check
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.admin.data.vendor.VendorRepository
import com.gomandap.app.domain.model.*
import com.gomandap.app.presentation.search.MakeupType
import com.gomandap.app.presentation.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.UUID

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VendorOnboardingScreen(onBack: () -> Unit) {
    val scope = rememberCoroutineScope()
    val scrollState = rememberScrollState()

    // Onboarding Wizard Steps: 1 = Location & Contacts, 2 = Category Details, 3 = Banking & Trust
    var currentStep by remember { mutableIntStateOf(1) }

    // Core Shared States
    var name by remember { mutableStateOf("") }
    var basePrice by remember { mutableStateOf("") }
    var rating by remember { mutableFloatStateOf(5.0f) }
    var isVerified by remember { mutableStateOf(true) }
    var isEscrowProtected by remember { mutableStateOf(true) }
    var isFastFilling by remember { mutableStateOf(false) }

    // STEP 1 States: Location & Contacts
    var fullAddress by remember { mutableStateOf("") }
    var city by remember { mutableStateOf("") }
    var state by remember { mutableStateOf("") }
    var pincode by remember { mutableStateOf("") }
    var landmark by remember { mutableStateOf("") }
    var locality by remember { mutableStateOf("") }
    var mobileNumber by remember { mutableStateOf("") }
    var emailId by remember { mutableStateOf("") }
    var whatsAppNumber by remember { mutableStateOf("") }

    // STEP 2 States: Category Select
    val categoriesList = listOf("Venues", "Catering", "Photography", "Decorators", "Makeup Art")
    var category by remember { mutableStateOf("Venues") }
    var expandedCategoryDropdown by remember { mutableStateOf(false) }

    // Venue Type Selection
    val venueTypesList = VenueType.values().toList()
    var selectedVenueType by remember { mutableStateOf(VenueType.BanquetHall) }
    var expandedVenueTypeDropdown by remember { mutableStateOf(false) }

    // Custom Dynamic Fields (Banquets / General Venues)
    var pricePerPlateVeg by remember { mutableStateOf("1500") }
    var pricePerPlateNonVeg by remember { mutableStateOf("2200") }
    var hasRooms by remember { mutableStateOf(true) }
    var roomCount by remember { mutableStateOf("20") }
    var parkingCount by remember { mutableStateOf("100") }
    var isAlcoholAllowed by remember { mutableStateOf(false) }
    var decorPolicy by remember { mutableStateOf("In-house decor only") }
    var djPolicy by remember { mutableStateOf("In-house DJ only") }
    var generatorBackup by remember { mutableStateOf(true) }

    // Specific Venue Type Fields
    var acCapacity by remember { mutableStateOf("500") }
    var totalLawnArea by remember { mutableStateOf("12000") }
    var rainProtection by remember { mutableStateOf(true) }
    var roomConfigurations by remember { mutableStateOf("Deluxe Suites") }
    var poolSideEvent by remember { mutableStateOf(false) }
    var heritageCategory by remember { mutableStateOf("Heritage Palace Class-A") }
    var royalEntryCarriage by remember { mutableStateOf(true) }
    var traditionalLayout by remember { mutableStateOf(true) }
    var poojaPackage by remember { mutableStateOf(true) }
    var basicRentModel by remember { mutableStateOf("Hourly Slot / Day Basis") }
    var starRating by remember { mutableStateOf("5 Star") }
    var soundproofCurfew by remember { mutableStateOf("10:00 PM") }

    // Photography-specific State
    val selectedPhotoStyles = remember { mutableStateListOf(PhotographyStyle.Cinematic, PhotographyStyle.Candid) }
    var pricePhotoOnly by remember { mutableStateOf("50000") }
    var priceVideoOnly by remember { mutableStateOf("60000") }
    var priceCombo by remember { mutableStateOf("95000") }
    var portfolioVideoUrl by remember { mutableStateOf("") }
    var deliveryTimeWeeks by remember { mutableStateOf("4") }
    var clientBearsTravelCost by remember { mutableStateOf(true) }
    var includesAlbum by remember { mutableStateOf(true) }

    // Decor-specific State
    val selectedDecorStyles = remember { mutableStateListOf(MandapStyle.Floral, MandapStyle.Traditional) }
    var setupTimeHours by remember { mutableStateOf("6") }
    var dimensions by remember { mutableStateOf("40x40 ft") }
    var minimumBudget by remember { mutableStateOf("50000") }
    var specialtyText by remember { mutableStateOf("Floral Backdrops, Theme Lightings") }

    // Catering-specific State
    var cuisineText by remember { mutableStateOf("North Indian, South Indian") }
    var serviceText by remember { mutableStateOf("Buffet Service") }
    var minGuestCount by remember { mutableStateOf("100") }
    var pricePerPlate by remember { mutableStateOf("1500") }
    var includesCrockery by remember { mutableStateOf(true) }
    var waitstaffCount by remember { mutableStateOf("15") }

    // Makeup-specific State
    val selectedMakeupTypes = remember { mutableStateListOf(MakeupType.Airbrush, MakeupType.HDMakeup) }
    var studioPrice by remember { mutableStateOf("15000") }
    var venuePrice by remember { mutableStateOf("22000") }
    var partyMakeupPrice by remember { mutableStateOf("4500") }
    var isHairStylingIncluded by remember { mutableStateOf(true) }
    var isDrapingIncluded by remember { mutableStateOf(true) }
    var isPaidTrialAvailable by remember { mutableStateOf(true) }

    // STEP 3 States: Banking
    var bankAccountName by remember { mutableStateOf("") }
    var bankAccountNumber by remember { mutableStateOf("") }
    var bankName by remember { mutableStateOf("") }
    var bankIfscCode by remember { mutableStateOf("") }
    var upiId by remember { mutableStateOf("") }

    // Wizard Status
    var isSaving by remember { mutableStateOf(false) }
    var showSuccessToast by remember { mutableStateOf(false) }
    var validationError by remember { mutableStateOf<String?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { 
                    Column {
                        Text("Onboard New Partner", fontWeight = FontWeight.Bold, color = RoyalNavy, fontSize = 16.sp)
                        Text("Step $currentStep of 3: " + when(currentStep) {
                            1 -> "Contact & Location"
                            2 -> "Service Details"
                            else -> "Banking & Trust"
                        }, fontSize = 11.sp, color = ChampagneGold, fontWeight = FontWeight.Bold)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = {
                        if (currentStep > 1) {
                            currentStep--
                            validationError = null
                        } else {
                            onBack()
                        }
                    }) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = PearlWhite
    ) { paddingValues ->
        Box(modifier = Modifier.fillMaxSize().padding(paddingValues)) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(scrollState)
                    .padding(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Step Progress Indicator
                LinearProgressIndicator(
                    progress = currentStep / 3.0f,
                    modifier = Modifier.fillMaxWidth().height(6.dp).clip(RoundedCornerShape(3.dp)),
                    color = ChampagneGold,
                    trackColor = Color.LightGray.copy(alpha = 0.2f)
                )

                if (validationError != null) {
                    Card(
                        colors = CardDefaults.cardColors(containerColor = Color.Red.copy(alpha = 0.08f)),
                        border = BorderStroke(1.dp, Color.Red.copy(alpha = 0.2f)),
                        shape = RoundedCornerShape(8.dp)
                    ) {
                        Text(
                            text = validationError ?: "",
                            color = Color.Red,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(12.dp).fillMaxWidth()
                        )
                    }
                }

                when (currentStep) {
                    1 -> {
                        // ── STEP 1: CONTACT & LOCATION ──
                        Text("Identity & Discovery Specs", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                        
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(14.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                OutlinedTextField(
                                    value = name,
                                    onValueChange = { name = it },
                                    label = { Text("Business / Partner Name") },
                                    placeholder = { Text("e.g. Maharaja Banquet Hall") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )

                                OutlinedTextField(
                                    value = basePrice,
                                    onValueChange = { basePrice = it },
                                    label = { Text("Starting Base Budget (₹)") },
                                    placeholder = { Text("e.g. 150000") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )
                            }
                        }

                        Text("Location Specifics", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)

                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(14.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                OutlinedTextField(
                                    value = fullAddress,
                                    onValueChange = { fullAddress = it },
                                    label = { Text("Complete Address") },
                                    placeholder = { Text("e.g. Door No. 12, Ground Floor, Palace Rd") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )

                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                    OutlinedTextField(
                                        value = city,
                                        onValueChange = { city = it },
                                        label = { Text("City / Town") },
                                        modifier = Modifier.weight(1f),
                                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                    )
                                    OutlinedTextField(
                                        value = state,
                                        onValueChange = { state = it },
                                        label = { Text("State") },
                                        modifier = Modifier.weight(1f),
                                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                    )
                                }

                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                    OutlinedTextField(
                                        value = pincode,
                                        onValueChange = { pincode = it },
                                        label = { Text("Pincode") },
                                        modifier = Modifier.weight(1f),
                                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                    )
                                    OutlinedTextField(
                                        value = landmark,
                                        onValueChange = { landmark = it },
                                        label = { Text("Famous Landmark") },
                                        modifier = Modifier.weight(1f),
                                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                    )
                                }

                                OutlinedTextField(
                                    value = locality,
                                    onValueChange = { locality = it },
                                    label = { Text("Listing Suburb / Locality (For search matches)") },
                                    placeholder = { Text("e.g. Banjara Hills") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )
                            }
                        }

                        Text("Primary Contacts (Verification Active)", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)

                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(14.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                OutlinedTextField(
                                    value = mobileNumber,
                                    onValueChange = { mobileNumber = it },
                                    label = { Text("Mobile Phone Number") },
                                    placeholder = { Text("e.g. +91 98765 43210") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )

                                OutlinedTextField(
                                    value = whatsAppNumber,
                                    onValueChange = { whatsAppNumber = it },
                                    label = { Text("WhatsApp Number") },
                                    placeholder = { Text("e.g. +91 98765 43210") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )

                                OutlinedTextField(
                                    value = emailId,
                                    onValueChange = { emailId = it },
                                    label = { Text("Email Address") },
                                    placeholder = { Text("e.g. contact@business.com") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )
                            }
                        }
                    }

                    2 -> {
                        // ── STEP 2: CATEGORY & EXHAUSTIVE PARTICULARS ──
                        Text("Onboarding Category", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                        
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(14.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Box(modifier = Modifier.fillMaxWidth().padding(16.dp)) {
                                OutlinedTextField(
                                    value = category,
                                    onValueChange = {},
                                    readOnly = true,
                                    label = { Text("Select Main Business Type") },
                                    modifier = Modifier.fillMaxWidth(),
                                    trailingIcon = {
                                        IconButton(onClick = { expandedCategoryDropdown = true }) {
                                            Icon(Icons.Default.ArrowDropDown, contentDescription = "Dropdown")
                                        }
                                    },
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )
                                DropdownMenu(
                                    expanded = expandedCategoryDropdown,
                                    onDismissRequest = { expandedCategoryDropdown = false },
                                    modifier = Modifier.fillMaxWidth(0.9f)
                                ) {
                                    categoriesList.forEach { cat ->
                                        DropdownMenuItem(
                                            text = { Text(cat, fontWeight = FontWeight.Bold, color = RoyalNavy) },
                                            onClick = {
                                                category = cat
                                                expandedCategoryDropdown = false
                                            }
                                        )
                                    }
                                }
                            }
                        }

                        Text("Service Specific Attributes", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)

                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(14.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                when (category) {
                                    "Venues" -> {
                                        // Specific sub-venue dropdown
                                        Box(modifier = Modifier.fillMaxWidth()) {
                                            OutlinedTextField(
                                                value = when(selectedVenueType) {
                                                    VenueType.BanquetHall -> "Banquet Hall"
                                                    VenueType.MarriageGardenLawn -> "Marriage Garden / Lawn"
                                                    VenueType.WeddingResort -> "Wedding Resort"
                                                    VenueType.PalaceFort -> "Palace / Fort"
                                                    VenueType.KalyanaMandapam -> "Kalyana Mandapam"
                                                    VenueType.CommunityTempleHall -> "Community / Temple Hall"
                                                    VenueType.LuxuryHotel -> "Luxury / 5-Star Hotel"
                                                },
                                                onValueChange = {},
                                                readOnly = true,
                                                label = { Text("Venue Sub-Type") },
                                                modifier = Modifier.fillMaxWidth(),
                                                trailingIcon = {
                                                    IconButton(onClick = { expandedVenueTypeDropdown = true }) {
                                                        Icon(Icons.Default.ArrowDropDown, contentDescription = "Dropdown")
                                                    }
                                                },
                                                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                            )
                                            DropdownMenu(
                                                expanded = expandedVenueTypeDropdown,
                                                onDismissRequest = { expandedVenueTypeDropdown = false },
                                                modifier = Modifier.fillMaxWidth(0.8f)
                                            ) {
                                                venueTypesList.forEach { vt ->
                                                    DropdownMenuItem(
                                                        text = { Text(when(vt) {
                                                            VenueType.BanquetHall -> "Banquet Hall"
                                                            VenueType.MarriageGardenLawn -> "Marriage Garden / Lawn"
                                                            VenueType.WeddingResort -> "Wedding Resort"
                                                            VenueType.PalaceFort -> "Palace / Fort"
                                                            VenueType.KalyanaMandapam -> "Kalyana Mandapam"
                                                            VenueType.CommunityTempleHall -> "Community / Temple Hall"
                                                            VenueType.LuxuryHotel -> "Luxury / 5-Star Hotel"
                                                        }) },
                                                        onClick = {
                                                            selectedVenueType = vt
                                                            expandedVenueTypeDropdown = false
                                                        }
                                                    )
                                                }
                                            }
                                        }

                                        // Category specific fields
                                        when (selectedVenueType) {
                                            VenueType.BanquetHall -> {
                                                OutlinedTextField(
                                                    value = acCapacity,
                                                    onValueChange = { acCapacity = it },
                                                    label = { Text("Air Conditioned Seating Capacity") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                                OutlinedTextField(
                                                    value = pricePerPlateVeg,
                                                    onValueChange = { pricePerPlateVeg = it },
                                                    label = { Text("Veg Plate Price (₹)") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                                OutlinedTextField(
                                                    value = pricePerPlateNonVeg,
                                                    onValueChange = { pricePerPlateNonVeg = it },
                                                    label = { Text("Non-Veg Plate Price (₹)") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                                OutlinedTextField(
                                                    value = roomCount,
                                                    onValueChange = { roomCount = it },
                                                    label = { Text("Number of Changing Rooms") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                            }
                                            VenueType.MarriageGardenLawn -> {
                                                OutlinedTextField(
                                                    value = totalLawnArea,
                                                    onValueChange = { totalLawnArea = it },
                                                    label = { Text("Total Lawn Area (Sq. Ft.)") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                                    Text("Rain Water Protection Cover", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                                    Switch(checked = rainProtection, onCheckedChange = { rainProtection = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                                }
                                                OutlinedTextField(
                                                    value = pricePerPlateVeg,
                                                    onValueChange = { pricePerPlateVeg = it },
                                                    label = { Text("Standard Veg Plate price") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                            }
                                            VenueType.WeddingResort -> {
                                                OutlinedTextField(
                                                    value = roomConfigurations,
                                                    onValueChange = { roomConfigurations = it },
                                                    label = { Text("Room Configurations (e.g. Deluxe Suites, Villas)") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                                OutlinedTextField(
                                                    value = roomCount,
                                                    onValueChange = { roomCount = it },
                                                    label = { Text("Total Resort Rooms Available") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                                    Text("Poolside Event Capacity Support", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                                    Switch(checked = poolSideEvent, onCheckedChange = { poolSideEvent = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                                }
                                            }
                                            VenueType.PalaceFort -> {
                                                OutlinedTextField(
                                                    value = heritageCategory,
                                                    onValueChange = { heritageCategory = it },
                                                    label = { Text("Heritage Category / Fort Rating") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                                    Text("Royal Carriage Entry Support", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                                    Switch(checked = royalEntryCarriage, onCheckedChange = { royalEntryCarriage = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                                }
                                            }
                                            VenueType.KalyanaMandapam -> {
                                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                                    Text("Traditional Stage Seating Format", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                                    Switch(checked = traditionalLayout, onCheckedChange = { traditionalLayout = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                                }
                                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                                    Text("Includes Traditional Pooja Items Package", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                                    Switch(checked = poojaPackage, onCheckedChange = { poojaPackage = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                                }
                                            }
                                            VenueType.CommunityTempleHall -> {
                                                OutlinedTextField(
                                                    value = basicRentModel,
                                                    onValueChange = { basicRentModel = it },
                                                    label = { Text("Rental Pricing Model") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                                    Text("Permit Alcohol (Strictly Outside Limits)", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                                    Switch(checked = isAlcoholAllowed, onCheckedChange = { isAlcoholAllowed = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                                }
                                            }
                                            VenueType.LuxuryHotel -> {
                                                OutlinedTextField(
                                                    value = starRating,
                                                    onValueChange = { starRating = it },
                                                    label = { Text("Hotel Star Classification (e.g. 5-Star)") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                                OutlinedTextField(
                                                    value = soundproofCurfew,
                                                    onValueChange = { soundproofCurfew = it },
                                                    label = { Text("DJ / Music Curfew Timings") },
                                                    modifier = Modifier.fillMaxWidth(),
                                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                                )
                                            }
                                        }

                                        Divider(color = Color.LightGray.copy(alpha = 0.3f))

                                        OutlinedTextField(
                                            value = decorPolicy,
                                            onValueChange = { decorPolicy = it },
                                            label = { Text("Decor Policy details") },
                                            modifier = Modifier.fillMaxWidth(),
                                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                        )
                                    }
                                    "Catering" -> {
                                        OutlinedTextField(
                                            value = cuisineText,
                                            onValueChange = { cuisineText = it },
                                            label = { Text("Cuisines Offered (Comma separated)") },
                                            modifier = Modifier.fillMaxWidth(),
                                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                        )
                                        OutlinedTextField(
                                            value = serviceText,
                                            onValueChange = { serviceText = it },
                                            label = { Text("Service Styles (Comma separated)") },
                                            modifier = Modifier.fillMaxWidth(),
                                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                        )
                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                            OutlinedTextField(
                                                value = pricePerPlate,
                                                onValueChange = { pricePerPlate = it },
                                                label = { Text("Price per Plate") },
                                                modifier = Modifier.weight(1f),
                                                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                            )
                                            OutlinedTextField(
                                                value = minGuestCount,
                                                onValueChange = { minGuestCount = it },
                                                label = { Text("Min Guest Count") },
                                                modifier = Modifier.weight(1f),
                                                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                            )
                                        }
                                        OutlinedTextField(
                                            value = waitstaffCount,
                                            onValueChange = { waitstaffCount = it },
                                            label = { Text("Catering Waitstaff Count") },
                                            modifier = Modifier.fillMaxWidth(),
                                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                        )
                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                            Text("Includes Crockery & Cutlery", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                            Switch(checked = includesCrockery, onCheckedChange = { includesCrockery = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                        }
                                    }
                                    "Photography" -> {
                                        Text("Photography Styles", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                        FlowRow(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.spacedBy(6.dp),
                                            verticalArrangement = Arrangement.spacedBy(6.dp)
                                        ) {
                                            PhotographyStyle.values().forEach { style ->
                                                val isSelected = selectedPhotoStyles.contains(style)
                                                FilterChip(
                                                    selected = isSelected,
                                                    onClick = {
                                                        if (isSelected) selectedPhotoStyles.remove(style)
                                                        else selectedPhotoStyles.add(style)
                                                    },
                                                    label = { Text(style.name, fontSize = 11.sp) }
                                                )
                                            }
                                        }

                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                            OutlinedTextField(
                                                value = pricePhotoOnly,
                                                onValueChange = { pricePhotoOnly = it },
                                                label = { Text("Photo Only Price") },
                                                modifier = Modifier.weight(1f),
                                                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                            )
                                            OutlinedTextField(
                                                value = priceVideoOnly,
                                                onValueChange = { priceVideoOnly = it },
                                                label = { Text("Video Only Price") },
                                                modifier = Modifier.weight(1f),
                                                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                            )
                                        }

                                        OutlinedTextField(
                                            value = priceCombo,
                                            onValueChange = { priceCombo = it },
                                            label = { Text("Combo Shoot Price") },
                                            modifier = Modifier.fillMaxWidth(),
                                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                        )

                                        OutlinedTextField(
                                            value = deliveryTimeWeeks,
                                            onValueChange = { deliveryTimeWeeks = it },
                                            label = { Text("Delivery Timeline (Weeks)") },
                                            modifier = Modifier.fillMaxWidth(),
                                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                        )

                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                            Text("Client Bears Outstation Travel Costs", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                            Switch(checked = clientBearsTravelCost, onCheckedChange = { clientBearsTravelCost = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                        }

                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                            Text("Includes Premium Printed Album", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                            Switch(checked = includesAlbum, onCheckedChange = { includesAlbum = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                        }
                                    }
                                    "Decorators" -> {
                                        Text("Mandap Styles", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                        FlowRow(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.spacedBy(6.dp),
                                            verticalArrangement = Arrangement.spacedBy(6.dp)
                                        ) {
                                            MandapStyle.values().forEach { style ->
                                                val isSelected = selectedDecorStyles.contains(style)
                                                FilterChip(
                                                    selected = isSelected,
                                                    onClick = {
                                                        if (isSelected) selectedDecorStyles.remove(style)
                                                        else selectedDecorStyles.add(style)
                                                    },
                                                    label = { Text(style.name, fontSize = 11.sp) }
                                                )
                                            }
                                        }

                                        OutlinedTextField(
                                            value = dimensions,
                                            onValueChange = { dimensions = it },
                                            label = { Text("Standard Setup Dimensions") },
                                            modifier = Modifier.fillMaxWidth(),
                                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                        )

                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                            OutlinedTextField(
                                                value = setupTimeHours,
                                                onValueChange = { setupTimeHours = it },
                                                label = { Text("Setup Time (Hours)") },
                                                modifier = Modifier.weight(1f),
                                                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                            )
                                            OutlinedTextField(
                                                value = minimumBudget,
                                                onValueChange = { minimumBudget = it },
                                                label = { Text("Minimum Budget (₹)") },
                                                modifier = Modifier.weight(1f),
                                                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                            )
                                        }

                                        OutlinedTextField(
                                            value = specialtyText,
                                            onValueChange = { specialtyText = it },
                                            label = { Text("Specialties (Comma separated)") },
                                            modifier = Modifier.fillMaxWidth(),
                                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                        )
                                    }
                                    else -> {
                                        // Makeup Art
                                        Text("Makeup Specializations", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                        FlowRow(
                                            modifier = Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.spacedBy(6.dp),
                                            verticalArrangement = Arrangement.spacedBy(6.dp)
                                        ) {
                                            MakeupType.values().forEach { style ->
                                                val isSelected = selectedMakeupTypes.contains(style)
                                                FilterChip(
                                                    selected = isSelected,
                                                    onClick = {
                                                        if (isSelected) selectedMakeupTypes.remove(style)
                                                        else selectedMakeupTypes.add(style)
                                                    },
                                                    label = { Text(style.name, fontSize = 11.sp) }
                                                )
                                            }
                                        }

                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                            OutlinedTextField(
                                                value = studioPrice,
                                                onValueChange = { studioPrice = it },
                                                label = { Text("Studio Package Price") },
                                                modifier = Modifier.weight(1f),
                                                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                            )
                                            OutlinedTextField(
                                                value = venuePrice,
                                                onValueChange = { venuePrice = it },
                                                label = { Text("Venue Package Price") },
                                                modifier = Modifier.weight(1f),
                                                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                            )
                                        }

                                        OutlinedTextField(
                                            value = partyMakeupPrice,
                                            onValueChange = { partyMakeupPrice = it },
                                            label = { Text("Party Makeup Price (₹)") },
                                            modifier = Modifier.fillMaxWidth(),
                                            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                        )

                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                            Text("Includes Premium Hair Styling", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                            Switch(checked = isHairStylingIncluded, onCheckedChange = { isHairStylingIncluded = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                        }

                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                            Text("Includes Saree/Lehenga Draping", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                            Switch(checked = isDrapingIncluded, onCheckedChange = { isDrapingIncluded = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                        }

                                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                            Text("Paid Consultation Trials Offered", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                                            Switch(checked = isPaidTrialAvailable, onCheckedChange = { isPaidTrialAvailable = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                        }
                                    }
                                }
                            }
                        }
                    }

                    3 -> {
                        // ── STEP 3: BANKING, PAYOUTS & PLATFORM TRUST ──
                        Text("Direct Escrow Payout Bank Account", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                        
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(14.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                OutlinedTextField(
                                    value = bankAccountName,
                                    onValueChange = { bankAccountName = it },
                                    label = { Text("Account Holder Name") },
                                    placeholder = { Text("e.g. Maharaja Enterprises") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )

                                OutlinedTextField(
                                    value = bankName,
                                    onValueChange = { bankName = it },
                                    label = { Text("Bank Name") },
                                    placeholder = { Text("e.g. HDFC Bank") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )

                                OutlinedTextField(
                                    value = bankAccountNumber,
                                    onValueChange = { bankAccountNumber = it },
                                    label = { Text("Bank Account Number") },
                                    placeholder = { Text("e.g. 5010023456789") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )

                                OutlinedTextField(
                                    value = bankIfscCode,
                                    onValueChange = { bankIfscCode = it },
                                    label = { Text("Bank IFSC Code") },
                                    placeholder = { Text("e.g. HDFC0001234") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )
                            }
                        }

                        Text("Instant UPI Payout ID", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)

                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(14.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                OutlinedTextField(
                                    value = upiId,
                                    onValueChange = { upiId = it },
                                    label = { Text("UPI ID (For immediate splits)") },
                                    placeholder = { Text("e.g. business@okaxis") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                                )
                            }
                        }

                        Text("Trust Badges & Direct Status", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)

                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(14.dp),
                            colors = CardDefaults.cardColors(containerColor = Color.White),
                            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text("Verified Partner Badge", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                                        Text("Applies live emerald verification to display immediately on client search.", fontSize = 11.sp, color = Color.Gray)
                                    }
                                    Switch(checked = isVerified, onCheckedChange = { isVerified = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                }

                                Divider(color = Color.LightGray.copy(alpha = 0.3f))

                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text("Neutral Escrow Lock Protection", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                                        Text("Secures advances and splits event budget across neutral milestones.", fontSize = 11.sp, color = Color.Gray)
                                    }
                                    Switch(checked = isEscrowProtected, onCheckedChange = { isEscrowProtected = it }, colors = SwitchDefaults.colors(checkedThumbColor = EmeraldGreen, checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)))
                                }

                                Divider(color = Color.LightGray.copy(alpha = 0.3f))

                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                    Column(modifier = Modifier.weight(1f)) {
                                        Text("Filling Fast Badge", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                                        Text("Highlights calendar occupancy and customer booking urgency.", fontSize = 11.sp, color = Color.Gray)
                                    }
                                    Switch(checked = isFastFilling, onCheckedChange = { isFastFilling = it }, colors = SwitchDefaults.colors(checkedThumbColor = ChampagneGold, checkedTrackColor = ChampagneGold.copy(alpha = 0.3f)))
                                }
                            }
                        }
                    }
                }

                Spacer(modifier = Modifier.height(70.dp))
            }

            // Bottom Navigation Panel
            Surface(
                modifier = Modifier.align(Alignment.BottomCenter).fillMaxWidth(),
                shadowElevation = 8.dp,
                color = Color.White
            ) {
                Row(
                    modifier = Modifier.padding(16.dp).fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    if (currentStep > 1) {
                        OutlinedButton(
                            onClick = {
                                currentStep--
                                validationError = null
                            },
                            modifier = Modifier.weight(1f).height(48.dp),
                            shape = RoundedCornerShape(8.dp),
                            colors = ButtonDefaults.outlinedButtonColors(contentColor = RoyalNavy),
                            border = BorderStroke(1.dp, RoyalNavy)
                        ) {
                            Text("Back", fontWeight = FontWeight.Bold)
                        }
                    }

                    Button(
                        onClick = {
                            if (currentStep == 1) {
                                if (name.isBlank()) name = "New Partner"
                                if (locality.isBlank()) locality = "Banjara Hills"
                                if (basePrice.isBlank() || basePrice.toDoubleOrNull() == null) basePrice = "100000"
                                if (fullAddress.isBlank()) fullAddress = "Banjara Hills Road No. 1"
                                if (city.isBlank()) city = "Hyderabad"
                                if (state.isBlank()) state = "Telangana"
                                if (pincode.isBlank()) pincode = "500034"
                                if (mobileNumber.isBlank()) mobileNumber = "+91 99999 88888"
                                if (whatsAppNumber.isBlank()) whatsAppNumber = mobileNumber
                                if (emailId.isBlank() || !emailId.contains("@")) emailId = "partner@gomandap.com"
                                currentStep = 2
                                validationError = null
                            } else if (currentStep == 2) {
                                currentStep = 3
                                validationError = null
                            } else {
                                // Final check & save (Set default escrow bank details if empty)
                                if (bankAccountName.isBlank()) bankAccountName = "Partner Escrow Account"
                                if (bankName.isBlank()) bankName = "State Bank of India"
                                if (bankAccountNumber.isBlank()) bankAccountNumber = "1234567890"
                                if (bankIfscCode.isBlank()) bankIfscCode = "SBIN0000001"
                                if (upiId.isBlank()) upiId = "partner@upi"

                                scope.launch {
                                    isSaving = true
                                    val generatedId = UUID.randomUUID().toString()
                                    
                                    val mockImageUrls = when (category) {
                                        "Venues" -> listOf(
                                            "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800",
                                            "https://images.unsplash.com/photo-1519741497674-611481863552?w=800"
                                        )
                                        "Catering" -> listOf(
                                            "https://images.unsplash.com/photo-1555244162-803834f70033?w=800"
                                        )
                                        "Photography" -> listOf(
                                            "https://images.unsplash.com/photo-1537633552985-df8429e8048b?w=800"
                                        )
                                        "Decorators" -> listOf(
                                            "https://images.unsplash.com/photo-1478812954026-9c750f0e89fc?w=800"
                                        )
                                        else -> listOf(
                                            "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=800"
                                        )
                                    }

                                    val approvalStatus = if (isVerified) ApprovalStatus.APPROVED else ApprovalStatus.PENDING_APPROVAL
                                    val isLive = isVerified

                                    val finalVendor: Vendor = when (category) {
                                        "Venues" -> VenueVendor(
                                            id = generatedId, name = name, locality = locality,
                                            basePrice = basePrice.toDoubleOrNull() ?: 150000.0, rating = rating,
                                            imageUrls = mockImageUrls, isEscrowProtected = isEscrowProtected,
                                            isVerified = isVerified, isFastFilling = isFastFilling,
                                            approvalStatus = approvalStatus, isLive = isLive,
                                            
                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            venueType = selectedVenueType,
                                            pricePerPlateVeg = pricePerPlateVeg.toDoubleOrNull() ?: 1500.0,
                                            pricePerPlateNonVeg = pricePerPlateNonVeg.toDoubleOrNull() ?: 2200.0,
                                            roomCount = roomCount.toIntOrNull() ?: 20,
                                            parkingCount = parkingCount.toIntOrNull() ?: 100,
                                            hasRooms = hasRooms,
                                            isAlcoholAllowed = isAlcoholAllowed,
                                            decorPolicy = decorPolicy,
                                            djPolicy = djPolicy,
                                            generatorBackup = generatorBackup,

                                            acCapacity = acCapacity.toIntOrNull() ?: 500,
                                            totalLawnArea = totalLawnArea,
                                            rainProtection = rainProtection,
                                            roomConfigurations = roomConfigurations,
                                            poolSideEvent = poolSideEvent,
                                            heritageCategory = heritageCategory,
                                            royalEntryCarriage = royalEntryCarriage,
                                            traditionalLayout = traditionalLayout,
                                            poojaPackage = poojaPackage,
                                            basicRentModel = basicRentModel,
                                            starRating = starRating,
                                            soundproofCurfew = soundproofCurfew
                                        )
                                        "Catering" -> CateringVendor(
                                            id = generatedId, name = name, locality = locality,
                                            basePrice = basePrice.toDoubleOrNull() ?: 1500.0, rating = rating,
                                            imageUrls = mockImageUrls, isEscrowProtected = isEscrowProtected,
                                            isVerified = isVerified, isFastFilling = isFastFilling,
                                            approvalStatus = approvalStatus, isLive = isLive,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            cuisineTypes = cuisineText.split(",").map { it.trim() }.filter { it.isNotEmpty() },
                                            serviceTypes = serviceText.split(",").map { it.trim() }.filter { it.isNotEmpty() },
                                            minGuestCount = minGuestCount.toIntOrNull() ?: 100,
                                            pricePerPlate = pricePerPlate.toDoubleOrNull() ?: 1500.0,
                                            includesCrockery = includesCrockery,
                                            waitstaffCount = waitstaffCount.toIntOrNull() ?: 15
                                        )
                                        "Photography" -> PhotographyVendor(
                                            id = generatedId, name = name, locality = locality,
                                            basePrice = basePrice.toDoubleOrNull() ?: 50000.0, rating = rating,
                                            imageUrls = mockImageUrls, isEscrowProtected = isEscrowProtected,
                                            isVerified = isVerified, isFastFilling = isFastFilling,
                                            approvalStatus = approvalStatus, isLive = isLive,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            style = selectedPhotoStyles.toList(),
                                            pricePhotoOnly = pricePhotoOnly.toDoubleOrNull() ?: 50000.0,
                                            priceVideoOnly = priceVideoOnly.toDoubleOrNull() ?: 60000.0,
                                            priceCombo = priceCombo.toDoubleOrNull() ?: 95000.0,
                                            portfolioVideoUrl = portfolioVideoUrl,
                                            deliveryTimeWeeks = deliveryTimeWeeks.toIntOrNull() ?: 4,
                                            clientBearsTravelCost = clientBearsTravelCost,
                                            includesAlbum = includesAlbum
                                        )
                                        "Decorators" -> DecorMandapVendor(
                                            id = generatedId, name = name, locality = locality,
                                            basePrice = basePrice.toDoubleOrNull() ?: 50000.0, rating = rating,
                                            imageUrls = mockImageUrls, isEscrowProtected = isEscrowProtected,
                                            isVerified = isVerified, isFastFilling = isFastFilling,
                                            approvalStatus = approvalStatus, isLive = isLive,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            mandapStyle = selectedDecorStyles.toList(),
                                            specialties = specialtyText.split(",").map { it.trim() }.filter { it.isNotEmpty() },
                                            minimumBudget = minimumBudget.toDoubleOrNull() ?: 50000.0,
                                            dimensions = dimensions,
                                            setupTimeHours = setupTimeHours.toIntOrNull() ?: 6
                                        )
                                        else -> MakeupArtistVendor(
                                            id = generatedId, name = name, locality = locality,
                                            basePrice = basePrice.toDoubleOrNull() ?: 15000.0, rating = rating,
                                            imageUrls = mockImageUrls, isEscrowProtected = isEscrowProtected,
                                            isVerified = isVerified, isFastFilling = isFastFilling,
                                            approvalStatus = approvalStatus, isLive = isLive,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            makeupTypes = selectedMakeupTypes.toList(),
                                            studioPrice = studioPrice.toDoubleOrNull() ?: 15000.0,
                                            venuePrice = venuePrice.toDoubleOrNull() ?: 22000.0,
                                            partyMakeupPrice = partyMakeupPrice.toDoubleOrNull() ?: 4500.0,
                                            isHairStylingIncluded = isHairStylingIncluded,
                                            isDrapingIncluded = isDrapingIncluded,
                                            isPaidTrialAvailable = isPaidTrialAvailable
                                        )
                                    }

                                    VendorRepository.registerVendor(finalVendor)
                                    
                                    isSaving = false
                                    showSuccessToast = true
                                    delay(1200)
                                    showSuccessToast = false
                                    onBack()
                                }
                            }
                        },
                        modifier = Modifier.weight(1f).height(48.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                        shape = RoundedCornerShape(8.dp),
                        enabled = !isSaving
                    ) {
                        if (isSaving) {
                            CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                        } else {
                            Text(
                                text = if (currentStep < 3) "Next Step" else "Register & Publish",
                                color = Color.White,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }

            // Success Overlay
            if (showSuccessToast) {
                Box(
                    modifier = Modifier.fillMaxSize().background(Color.Black.copy(alpha = 0.5f)).clickable(enabled = false) {},
                    contentAlignment = Alignment.Center
                ) {
                    Card(
                        shape = RoundedCornerShape(16.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        modifier = Modifier.padding(32.dp)
                    ) {
                        Column(
                            modifier = Modifier.padding(24.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Box(
                                modifier = Modifier.size(60.dp).background(EmeraldGreen.copy(alpha = 0.1f), CircleShape),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(Icons.Default.Check, null, tint = EmeraldGreen, modifier = Modifier.size(32.dp))
                            }
                            Text("Partner Published!", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                            Text(
                                text = "Business verified, payout credentials synced, and listing pushed instantly to client storefront.",
                                fontSize = 12.sp,
                                color = Color.Gray,
                                modifier = Modifier.padding(horizontal = 8.dp),
                                lineHeight = 16.sp
                            )
                        }
                    }
                }
            }
        }
    }
}
