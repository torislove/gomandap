package com.gomandap.vendor.presentation.onboard

import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.animation.core.tween
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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

@OptIn(ExperimentalMaterial3Api::class, ExperimentalAnimationApi::class, ExperimentalLayoutApi::class)
@Composable
fun VendorOnboardScreen(onOnboardComplete: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    var currentStep by remember { mutableStateOf(1) }
    val totalSteps = 5 // 1: Category, 2: Contacts & Address, 3: Specs, 4: Media, 5: Bank Details

    // -- Step 1: Category --
    var selectedCategory by remember { mutableStateOf("Banquet") }
    var selectedVenueType by remember { mutableStateOf(VenueType.BanquetHall) }
    var expandedVenueTypeDropdown by remember { mutableStateOf(false) }

    // -- Step 2: Core Profile & Contacts --
    var businessName by remember { mutableStateOf("") }
    var locality by remember { mutableStateOf("") }
    var basePriceInput by remember { mutableStateOf("") }
    var yearEstablished by remember { mutableStateOf("2024") }
    var instagramUrl by remember { mutableStateOf("") }
    var googleMapsUrl by remember { mutableStateOf("") }
    var gstinInput by remember { mutableStateOf("") }
    
    // Address location asking details
    var fullAddress by remember { mutableStateOf("") }
    var city by remember { mutableStateOf("") }
    var state by remember { mutableStateOf("") }
    var pincode by remember { mutableStateOf("") }
    var landmark by remember { mutableStateOf("") }

    // Contact info
    var mobileNumber by remember { mutableStateOf("") }
    var emailId by remember { mutableStateOf("") }
    var whatsAppNumber by remember { mutableStateOf("") }

    // -- Step 3: Advanced Category Specs --
    // Banquets / Venues Custom Fields
    var platePriceVeg by remember { mutableStateOf("1500") }
    var platePriceNonVeg by remember { mutableStateOf("2200") }
    var hasRooms by remember { mutableStateOf(true) }
    var roomCount by remember { mutableStateOf("20") }
    var parkingCount by remember { mutableStateOf("100") }
    var alcoholAllowed by remember { mutableStateOf(false) }
    var decorPolicy by remember { mutableStateOf("In-house decor only") }
    var djPolicy by remember { mutableStateOf("In-house DJ only") }
    var spaces = remember { mutableStateListOf(EventSpace("Main Hall", "Hall", 500, 800)) }

    // Specific Venue Type Fields
    var acCapacity by remember { mutableStateOf("500") }
    var totalLawnArea by remember { mutableStateOf("12000") }
    var rainProtection by remember { mutableStateOf(true) }
    var roomConfigurations by remember { mutableStateOf("Deluxe Suites") }
    var poolSideEvent by remember { mutableStateOf(false) }
    var heritageCategory by remember { mutableStateOf("Heritage Class-A") }
    var royalEntryCarriage by remember { mutableStateOf(true) }
    var traditionalLayout by remember { mutableStateOf(true) }
    var poojaPackage by remember { mutableStateOf(true) }
    var basicRentModel by remember { mutableStateOf("Day Basis") }
    var starRating by remember { mutableStateOf("5 Star") }
    var soundproofCurfew by remember { mutableStateOf("10:00 PM") }

    // Photography
    val styles = remember { mutableStateListOf(PhotographyStyle.Candid, PhotographyStyle.Cinematic) }
    var pricePhotoOnly by remember { mutableStateOf("45000") }
    var priceVideoOnly by remember { mutableStateOf("50000") }
    var priceCombo by remember { mutableStateOf("85000") }
    var deliveryTimeWeeks by remember { mutableStateOf("4") }
    var clientBearsTravelCost by remember { mutableStateOf(true) }
    var includesAlbum by remember { mutableStateOf(true) }

    // Decorator
    val mandapStyles = remember { mutableStateListOf(MandapStyle.Traditional) }
    var dimensions by remember { mutableStateOf("30x30 ft") }
    var setupTimeHours by remember { mutableStateOf("8") }
    var minBudget by remember { mutableStateOf("50000") }
    var specialties = remember { mutableStateOf("Theme Decor") }

    // Catering
    val cuisineTypes = remember { mutableStateListOf("South Indian", "North Indian") }
    val serviceTypes = remember { mutableStateListOf("Standard Buffet") }
    var minGuestCount by remember { mutableStateOf("150") }
    var pricePerPlate by remember { mutableStateOf("1500") }
    var waitstaffCount by remember { mutableStateOf("15") }
    var includesCrockery by remember { mutableStateOf(true) }

    // Makeup
    val makeupTypes = remember { mutableStateListOf(MakeupType.HDMakeup, MakeupType.Airbrush) }
    var isHairIncluded by remember { mutableStateOf(true) }
    var isDrapingIncluded by remember { mutableStateOf(true) }
    var isTrialAvailable by remember { mutableStateOf(false) }
    var studioPrice by remember { mutableStateOf("15000") }
    var venuePrice by remember { mutableStateOf("20000") }
    var partyMakeupPrice by remember { mutableStateOf("3500") }
    
    // Universal Policies
    var paymentAdvancePercent by remember { mutableStateOf("50") }
    var cancellationPolicy by remember { mutableStateOf("Non-Refundable") }

    // -- Step 4: Media Gallery --
    var coverPhotoUrl by remember { mutableStateOf("") }
    val selectedPhotos = remember { mutableStateListOf<String>() }
    var videoUrlInput by remember { mutableStateOf("") }

    // -- Step 5: Bank details --
    var bankAccountName by remember { mutableStateOf("") }
    var bankAccountNumber by remember { mutableStateOf("") }
    var bankName by remember { mutableStateOf("") }
    var bankIfscCode by remember { mutableStateOf("") }
    var upiId by remember { mutableStateOf("") }

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
        containerColor = PearlWhite,
        bottomBar = {
            Surface(
                color = Color.White,
                shadowElevation = 8.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(16.dp).fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    if (currentStep > 1) {
                        TextButton(onClick = { currentStep-- }) {
                            Text("Back", color = SlateGray, fontWeight = FontWeight.Bold)
                        }
                    } else {
                        Spacer(modifier = Modifier.width(60.dp))
                    }
                    
                    Button(
                        onClick = {
                            if (currentStep < totalSteps) {
                                if (currentStep == 2) {
                                    if (businessName.isBlank()) businessName = "New Vendor"
                                    if (locality.isBlank()) locality = "Banjara Hills"
                                    if (fullAddress.isBlank()) fullAddress = "Banjara Hills Road No. 1"
                                    if (city.isBlank()) city = "Hyderabad"
                                    if (state.isBlank()) state = "Telangana"
                                    if (pincode.isBlank()) pincode = "500034"
                                    if (mobileNumber.isBlank()) mobileNumber = "+91 99999 88888"
                                    if (whatsAppNumber.isBlank()) whatsAppNumber = mobileNumber
                                    if (emailId.isBlank() || !emailId.contains("@")) emailId = "partner@gomandap.com"
                                }
                                currentStep++
                            } else {
                                if (bankAccountName.isBlank()) bankAccountName = "Partner Escrow Account"
                                if (bankName.isBlank()) bankName = "State Bank of India"
                                if (bankAccountNumber.isBlank()) bankAccountNumber = "1234567890"
                                if (bankIfscCode.isBlank()) bankIfscCode = "SBIN0000001"
                                if (upiId.isBlank()) upiId = "partner@upi"
                                scope.launch {
                                    val finalId = "vendor_" + UUID.randomUUID().toString().take(6)
                                    val price = basePriceInput.toDoubleOrNull() ?: 150000.0
                                    val photoList = selectedPhotos.toList()
                                    val cPhoto = if (coverPhotoUrl.isNotBlank()) coverPhotoUrl else photoList.firstOrNull() ?: "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=2098&auto=format&fit=crop"

                                    val baseMap = mutableMapOf(
                                        "gstin" to gstinInput,
                                        "advance_percent" to paymentAdvancePercent,
                                        "cancellation" to cancellationPolicy
                                    )

                                    val newVendor: Vendor = when (selectedCategory) {
                                        "Banquet" -> VenueVendor(
                                            id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                            imageUrls = listOf(cPhoto) + photoList.take(2),
                                            isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                            approvalStatus = ApprovalStatus.PENDING_APPROVAL, adminNotes = "Pending review", isLive = false,
                                            photos = photoList, coverPhotoUrl = cPhoto, videoUrl = videoUrlInput,
                                            details = baseMap.apply { 
                                                put("rooms", roomCount)
                                                put("parking", parkingCount)
                                                put("veg", platePriceVeg)
                                                put("nonveg", platePriceNonVeg)
                                            },
                                            yearEstablished = yearEstablished.toIntOrNull() ?: 2024,
                                            instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 50,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            venueType = selectedVenueType,
                                            pricePerPlateVeg = platePriceVeg.toDoubleOrNull() ?: 1500.0,
                                            pricePerPlateNonVeg = platePriceNonVeg.toDoubleOrNull() ?: 2200.0,
                                            spaces = spaces.toList(),
                                            hasRooms = hasRooms, roomCount = roomCount.toIntOrNull() ?: 0,
                                            parkingCount = parkingCount.toIntOrNull() ?: 50,
                                            isAlcoholAllowed = alcoholAllowed, decorPolicy = decorPolicy, djPolicy = djPolicy, generatorBackup = true,

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
                                        "Photography" -> PhotographyVendor(
                                            id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                            imageUrls = listOf(cPhoto) + photoList.take(2),
                                            isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                            approvalStatus = ApprovalStatus.PENDING_APPROVAL, adminNotes = "Pending review", isLive = false,
                                            photos = photoList, coverPhotoUrl = cPhoto, videoUrl = videoUrlInput,
                                            details = baseMap,
                                            yearEstablished = yearEstablished.toIntOrNull() ?: 2024,
                                            instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 50,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            style = styles.toList(),
                                            pricePhotoOnly = pricePhotoOnly.toDoubleOrNull() ?: price,
                                            priceVideoOnly = priceVideoOnly.toDoubleOrNull() ?: price,
                                            priceCombo = priceCombo.toDoubleOrNull() ?: price,
                                            portfolioVideoUrl = videoUrlInput, deliveryTimeWeeks = deliveryTimeWeeks.toIntOrNull() ?: 4,
                                            clientBearsTravelCost = clientBearsTravelCost, includesAlbum = includesAlbum
                                        )
                                        "Decorator" -> DecorMandapVendor(
                                            id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                            imageUrls = listOf(cPhoto) + photoList.take(2),
                                            isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                            approvalStatus = ApprovalStatus.PENDING_APPROVAL, adminNotes = "Pending review", isLive = false,
                                            photos = photoList, coverPhotoUrl = cPhoto, videoUrl = videoUrlInput,
                                            details = baseMap,
                                            yearEstablished = yearEstablished.toIntOrNull() ?: 2024,
                                            instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 50,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            mandapStyle = mandapStyles.toList(), dimensions = dimensions,
                                            setupTimeHours = setupTimeHours.toIntOrNull() ?: 6,
                                            specialties = specialties.value.split(",").map { it.trim() },
                                            minimumBudget = minBudget.toDoubleOrNull() ?: price
                                        )
                                        "Catering" -> CateringVendor(
                                            id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                            imageUrls = listOf(cPhoto) + photoList.take(2),
                                            isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                            approvalStatus = ApprovalStatus.PENDING_APPROVAL, adminNotes = "Pending review", isLive = false,
                                            photos = photoList, coverPhotoUrl = cPhoto, videoUrl = videoUrlInput,
                                            details = baseMap,
                                            yearEstablished = yearEstablished.toIntOrNull() ?: 2024,
                                            instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 50,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            cuisineTypes = cuisineTypes.toList(), serviceTypes = serviceTypes.toList(),
                                            minGuestCount = minGuestCount.toIntOrNull() ?: 100, pricePerPlate = pricePerPlate.toDoubleOrNull() ?: 500.0,
                                            includesCrockery = includesCrockery, waitstaffCount = waitstaffCount.toIntOrNull() ?: 10
                                        )
                                        "Makeup" -> MakeupArtistVendor(
                                            id = finalId, name = businessName, locality = locality, basePrice = price, rating = 5.0f,
                                            imageUrls = listOf(cPhoto) + photoList.take(2),
                                            isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                            approvalStatus = ApprovalStatus.PENDING_APPROVAL, adminNotes = "Pending review", isLive = false,
                                            photos = photoList, coverPhotoUrl = cPhoto, videoUrl = videoUrlInput,
                                            details = baseMap,
                                            yearEstablished = yearEstablished.toIntOrNull() ?: 2024,
                                            instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 50,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            makeupTypes = makeupTypes.toList(),
                                            isHairStylingIncluded = isHairIncluded, isDrapingIncluded = isDrapingIncluded, isPaidTrialAvailable = isTrialAvailable,
                                            studioPrice = studioPrice.toDoubleOrNull() ?: price, venuePrice = venuePrice.toDoubleOrNull() ?: price,
                                            partyMakeupPrice = partyMakeupPrice.toDoubleOrNull() ?: 3500.0
                                        )
                                        else -> error("Unknown Category")
                                    }

                                    VendorRepository.addVendor(newVendor)
                                    Toast.makeText(context, "🎉 Advanced Business Profile Submitted!", Toast.LENGTH_LONG).show()
                                    onOnboardComplete()
                                }
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.height(48.dp).padding(horizontal = 16.dp)
                    ) {
                        Text(if (currentStep < totalSteps) "Next Step" else "Submit Profile", color = Color.White, fontWeight = FontWeight.Bold)
                        Spacer(Modifier.width(8.dp))
                        Icon(if (currentStep < totalSteps) Icons.Default.ArrowForward else Icons.Default.Check, null)
                    }
                }
            }
        }
    ) { padding ->
        Column(
            modifier = Modifier.fillMaxSize().padding(padding)
        ) {
            // Step Progress Bar
            LinearProgressIndicator(
                progress = currentStep.toFloat() / totalSteps.toFloat(),
                modifier = Modifier.fillMaxWidth().height(4.dp),
                color = ChampagneGold,
                trackColor = LightSlate
            )

            AnimatedContent(
                targetState = currentStep,
                transitionSpec = {
                    slideInHorizontally(animationSpec = tween(400)) { width -> if (targetState > initialState) width else -width } + fadeIn() with
                    slideOutHorizontally(animationSpec = tween(400)) { width -> if (targetState > initialState) -width else width } + fadeOut()
                },
                modifier = Modifier.fillMaxSize()
            ) { step ->
                Column(
                    modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(20.dp)
                ) {
                    when (step) {
                        1 -> Step1CategorySelection(
                            selectedCategory = selectedCategory,
                            selectedVenueType = selectedVenueType,
                            expandedVenueTypeDropdown = expandedVenueTypeDropdown,
                            onCategorySelected = { selectedCategory = it },
                            onVenueTypeSelected = { selectedVenueType = it },
                            onDismissVenueType = { expandedVenueTypeDropdown = false },
                            onOpenVenueType = { expandedVenueTypeDropdown = true }
                        )
                        2 -> Step2CoreProfile(
                            name = businessName, loc = locality, price = basePriceInput, year = yearEstablished, insta = instagramUrl, maps = googleMapsUrl, gstin = gstinInput,
                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                            mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                            onName = {businessName = it}, onLoc={locality=it}, onPrice={basePriceInput=it}, onYear={yearEstablished=it}, onInsta={instagramUrl=it}, onMaps={googleMapsUrl=it}, onGstin={gstinInput=it},
                            onFullAddress = {fullAddress=it}, onCity={city=it}, onState={state=it}, onPincode={pincode=it}, onLandmark={landmark=it},
                            onMobileNumber = {mobileNumber=it}, onEmailId={emailId=it}, onWhatsAppNumber={whatsAppNumber=it}
                        )
                        3 -> Step3AdvancedSpecs(
                            selectedCategory, selectedVenueType,
                            // Banquet
                            platePriceVeg, platePriceNonVeg, hasRooms, roomCount, parkingCount, alcoholAllowed, decorPolicy, djPolicy, spaces,
                            acCapacity, totalLawnArea, rainProtection, roomConfigurations, poolSideEvent, heritageCategory, royalEntryCarriage, traditionalLayout, poojaPackage, basicRentModel, starRating, soundproofCurfew,
                            {platePriceVeg=it}, {platePriceNonVeg=it}, {hasRooms=it}, {roomCount=it}, {parkingCount=it}, {alcoholAllowed=it}, {decorPolicy=it}, {djPolicy=it},
                            {acCapacity=it}, {totalLawnArea=it}, {rainProtection=it}, {roomConfigurations=it}, {poolSideEvent=it}, {heritageCategory=it}, {royalEntryCarriage=it}, {traditionalLayout=it}, {poojaPackage=it}, {basicRentModel=it}, {starRating=it}, {soundproofCurfew=it},
                            // Photography
                            styles, pricePhotoOnly, priceVideoOnly, priceCombo, deliveryTimeWeeks, clientBearsTravelCost, includesAlbum,
                            {pricePhotoOnly=it}, {priceVideoOnly=it}, {priceCombo=it}, {deliveryTimeWeeks=it}, {clientBearsTravelCost=it}, {includesAlbum=it},
                            // Decor
                            mandapStyles, dimensions, setupTimeHours, minBudget, specialties.value,
                            {dimensions=it}, {setupTimeHours=it}, {minBudget=it}, {specialties.value=it},
                            // Catering
                            cuisineTypes, serviceTypes, minGuestCount, pricePerPlate, waitstaffCount, includesCrockery,
                            {minGuestCount=it}, {pricePerPlate=it}, {waitstaffCount=it}, {includesCrockery=it},
                            // Makeup
                            makeupTypes, isHairIncluded, isDrapingIncluded, isTrialAvailable, studioPrice, venuePrice, partyMakeupPrice,
                            {isHairIncluded=it}, {isDrapingIncluded=it}, {isTrialAvailable=it}, {studioPrice=it}, {venuePrice=it}, {partyMakeupPrice=it},
                            // Policies
                            paymentAdvancePercent, cancellationPolicy, {paymentAdvancePercent=it}, {cancellationPolicy=it}
                        )
                        4 -> Step4MediaGallery(coverPhotoUrl, selectedPhotos, videoUrlInput, {coverPhotoUrl=it}, {videoUrlInput=it})
                        5 -> Step5BankingCredentials(
                            bankAccountName, bankAccountNumber, bankName, bankIfscCode, upiId,
                            {bankAccountName=it}, {bankAccountNumber=it}, {bankName=it}, {bankIfscCode=it}, {upiId=it}
                        )
                    }
                    Spacer(Modifier.height(80.dp)) // padding for bottom bar
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Step 1: Category Selection
// ---------------------------------------------------------------------------
@Composable
fun Step1CategorySelection(
    selectedCategory: String,
    selectedVenueType: VenueType,
    expandedVenueTypeDropdown: Boolean,
    onCategorySelected: (String) -> Unit,
    onVenueTypeSelected: (VenueType) -> Unit,
    onDismissVenueType: () -> Unit,
    onOpenVenueType: () -> Unit
) {
    Text("Select Your Core Service", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
    Text("Which primary category does your business operate in?", fontSize = 14.sp, color = SlateGray)
    
    val categories = listOf(
        Pair("Banquet", "Venues (Banquet Halls, Kalyan Mandapams, Resorts, Palaces...)"),
        Pair("Photography", "Candid, Traditional, Cinematic Films & Pre-Wedding"),
        Pair("Decorator", "Floral, Traditional, Stage & Theme Decorators"),
        Pair("Catering", "Premium Buffets & Traditional Leaf Services"),
        Pair("Makeup", "Bridal Airbrush, HD & Pre-wedding Makeovers")
    )

    categories.forEach { (cat, desc) ->
        val isSelected = selectedCategory == cat
        Surface(
            onClick = { onCategorySelected(cat) },
            shape = RoundedCornerShape(16.dp),
            border = BorderStroke(2.dp, if (isSelected) EmeraldGreen else Color.Transparent),
            color = if (isSelected) EmeraldGreen.copy(alpha = 0.05f) else Color.White,
            shadowElevation = if (isSelected) 4.dp else 1.dp,
            modifier = Modifier.fillMaxWidth()
        ) {
            Row(modifier = Modifier.padding(16.dp).fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                RadioButton(selected = isSelected, onClick = null, colors = RadioButtonDefaults.colors(selectedColor = EmeraldGreen))
                Spacer(Modifier.width(12.dp))
                Column {
                    Text(cat, fontWeight = FontWeight.Bold, fontSize = 16.sp, color = RoyalNavy)
                    Text(desc, fontSize = 12.sp, color = SlateGray)
                }
            }
        }
    }

    if (selectedCategory == "Banquet") {
        Divider(color = Color.LightGray.copy(alpha = 0.3f))
        Text("Venue Sub-Type Selection", fontWeight = FontWeight.Bold, color = RoyalNavy, fontSize = 14.sp)
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
                    IconButton(onClick = onOpenVenueType) {
                        Icon(Icons.Default.ArrowDropDown, contentDescription = "Dropdown")
                    }
                },
                colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
            )
            DropdownMenu(
                expanded = expandedVenueTypeDropdown,
                onDismissRequest = onDismissVenueType,
                modifier = Modifier.fillMaxWidth(0.8f)
            ) {
                VenueType.values().forEach { vt ->
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
                            onVenueTypeSelected(vt)
                            onDismissVenueType()
                        }
                    )
                }
            }
        }
    }
}

// ---------------------------------------------------------------------------
// Step 2: Core Profile & Contacts
// ---------------------------------------------------------------------------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Step2CoreProfile(
    name: String, loc: String, price: String, year: String, insta: String, maps: String, gstin: String,
    fullAddress: String, city: String, state: String, pincode: String, landmark: String,
    mobileNumber: String, emailId: String, whatsAppNumber: String,
    onName: (String)->Unit, onLoc: (String)->Unit, onPrice: (String)->Unit, onYear: (String)->Unit, onInsta: (String)->Unit, onMaps: (String)->Unit, onGstin: (String)->Unit,
    onFullAddress: (String)->Unit, onCity: (String)->Unit, onState: (String)->Unit, onPincode: (String)->Unit, onLandmark: (String)->Unit,
    onMobileNumber: (String)->Unit, onEmailId: (String)->Unit, onWhatsAppNumber: (String)->Unit
) {
    Text("Business Profile & Contacts", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
    Text("Add address and contacts to enable discovery and booking inquiries.", fontSize = 14.sp, color = SlateGray)

    OutlinedTextField(value = name, onValueChange = onName, label = { Text("Brand / Business Name") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = price, onValueChange = onPrice, label = { Text("Starting Base Budget (₹)") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = loc, onValueChange = onLoc, label = { Text("Listing Locality (e.g. Jubilee Hills)") }, modifier = Modifier.fillMaxWidth())
    
    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        OutlinedTextField(value = year, onValueChange = onYear, label = { Text("Year Est.") }, modifier = Modifier.weight(1f))
        OutlinedTextField(value = gstin, onValueChange = onGstin, label = { Text("GSTIN") }, modifier = Modifier.weight(2f))
    }

    Text("Address Locations", fontWeight = FontWeight.Bold, color = RoyalNavy)
    OutlinedTextField(value = fullAddress, onValueChange = onFullAddress, label = { Text("Complete Address") }, modifier = Modifier.fillMaxWidth())
    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        OutlinedTextField(value = city, onValueChange = onCity, label = { Text("City") }, modifier = Modifier.weight(1f))
        OutlinedTextField(value = state, onValueChange = onState, label = { Text("State") }, modifier = Modifier.weight(1f))
    }
    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        OutlinedTextField(value = pincode, onValueChange = onPincode, label = { Text("Pincode") }, modifier = Modifier.weight(1f))
        OutlinedTextField(value = landmark, onValueChange = onLandmark, label = { Text("Landmark") }, modifier = Modifier.weight(2f))
    }

    Text("Verification Contacts", fontWeight = FontWeight.Bold, color = RoyalNavy)
    OutlinedTextField(value = mobileNumber, onValueChange = onMobileNumber, label = { Text("Mobile Phone Number") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = whatsAppNumber, onValueChange = onWhatsAppNumber, label = { Text("WhatsApp Number") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = emailId, onValueChange = onEmailId, label = { Text("Email Address") }, modifier = Modifier.fillMaxWidth())

    OutlinedTextField(value = insta, onValueChange = onInsta, label = { Text("Instagram Profile URL") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = maps, onValueChange = onMaps, label = { Text("Google Maps Location Link") }, modifier = Modifier.fillMaxWidth())
}

// ---------------------------------------------------------------------------
// Step 3: Advanced Specifications (Dynamic by Category)
// ---------------------------------------------------------------------------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Step3AdvancedSpecs(
    cat: String,
    venueType: VenueType,
    // Banquet
    vVeg: String, vNonVeg: String, hasRooms: Boolean, roomCount: String, parking: String, alc: Boolean, decPol: String, djPol: String, spaces: MutableList<EventSpace>,
    acCapacity: String, totalLawnArea: String, rainProtection: Boolean, roomConfigurations: String, poolSideEvent: Boolean, heritageCategory: String, royalEntryCarriage: Boolean, traditionalLayout: Boolean, poojaPackage: Boolean, basicRentModel: String, starRating: String, soundproofCurfew: String,
    onVeg: (String)->Unit, onNonVeg: (String)->Unit, onHasRooms: (Boolean)->Unit, onRoomCount: (String)->Unit, onParking: (String)->Unit, onAlc: (Boolean)->Unit, onDecPol: (String)->Unit, onDjPol: (String)->Unit,
    onAcCapacity: (String)->Unit, onTotalLawnArea: (String)->Unit, onRainProtection: (Boolean)->Unit, onRoomConfigurations: (String)->Unit, onPoolSideEvent: (Boolean)->Unit, onHeritageCategory: (String)->Unit, onRoyalEntryCarriage: (Boolean)->Unit, onTraditionalLayout: (Boolean)->Unit, onPoojaPackage: (Boolean)->Unit, onBasicRentModel: (String)->Unit, onStarRating: (String)->Unit, onSoundproofCurfew: (String)->Unit,
    // Photography
    styles: MutableList<PhotographyStyle>, pPhoto: String, pVideo: String, pCombo: String, del: String, cTravel: Boolean, iAlbum: Boolean,
    onPPhoto: (String)->Unit, onPVideo: (String)->Unit, onPCombo: (String)->Unit, onDel: (String)->Unit, onCTravel: (Boolean)->Unit, onIAlbum: (Boolean)->Unit,
    // Decor
    mStyles: MutableList<MandapStyle>, dim: String, setupH: String, mBudget: String, specText: String,
    onDim: (String)->Unit, onSetupH: (String)->Unit, onMBudget: (String)->Unit, onSpecText: (String)->Unit,
    // Catering
    cTypes: MutableList<String>, sTypes: MutableList<String>, minG: String, pPlate: String, wCount: String, iCrockery: Boolean,
    onMinG: (String)->Unit, onPPlate: (String)->Unit, onWCount: (String)->Unit, onICrockery: (Boolean)->Unit,
    // Makeup
    mkTypes: MutableList<MakeupType>, hair: Boolean, draping: Boolean, trial: Boolean, sPrice: String, vPrice: String, pPrice: String,
    onHair: (Boolean)->Unit, onDraping: (Boolean)->Unit, onTrial: (Boolean)->Unit, onSPrice: (String)->Unit, onVPrice: (String)->Unit, onPPrice: (String)->Unit,
    // Policies
    adv: String, cancel: String, onAdv: (String)->Unit, onCancel: (String)->Unit
) {
    Text("Advanced Details ($cat)", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)

    when (cat) {
        "Banquet" -> {
            Text("Sub-Venue Settings: " + venueType.name, fontWeight = FontWeight.Bold, color = ChampagneGold)
            
            // Sub-venue type custom fields
            when (venueType) {
                VenueType.BanquetHall -> {
                    OutlinedTextField(value = acCapacity, onValueChange = onAcCapacity, label = { Text("AC Seating Capacity") }, modifier = Modifier.fillMaxWidth())
                    OutlinedTextField(value = vVeg, onValueChange = onVeg, label = { Text("Veg Price/Plate") }, modifier = Modifier.fillMaxWidth())
                    OutlinedTextField(value = vNonVeg, onValueChange = onNonVeg, label = { Text("Non-Veg Price/Plate") }, modifier = Modifier.fillMaxWidth())
                }
                VenueType.MarriageGardenLawn -> {
                    OutlinedTextField(value = totalLawnArea, onValueChange = onTotalLawnArea, label = { Text("Total Lawn Area (Sq. Ft.)") }, modifier = Modifier.fillMaxWidth())
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                        Text("Rain Water Protection Cover"); Switch(checked = rainProtection, onCheckedChange = onRainProtection)
                    }
                }
                VenueType.WeddingResort -> {
                    OutlinedTextField(value = roomConfigurations, onValueChange = onRoomConfigurations, label = { Text("Room Configurations (Suites/Villas)") }, modifier = Modifier.fillMaxWidth())
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                        Text("Poolside Event Support Available"); Switch(checked = poolSideEvent, onCheckedChange = onPoolSideEvent)
                    }
                }
                VenueType.PalaceFort -> {
                    OutlinedTextField(value = heritageCategory, onValueChange = onHeritageCategory, label = { Text("Heritage Fort Category Class") }, modifier = Modifier.fillMaxWidth())
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                        Text("Royal Entry Horse/Carriage Available"); Switch(checked = royalEntryCarriage, onCheckedChange = onRoyalEntryCarriage)
                    }
                }
                VenueType.KalyanaMandapam -> {
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                        Text("Traditional Stage layout"); Switch(checked = traditionalLayout, onCheckedChange = onTraditionalLayout)
                    }
                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                        Text("Traditional Pooja Items Included"); Switch(checked = poojaPackage, onCheckedChange = onPoojaPackage)
                    }
                }
                VenueType.CommunityTempleHall -> {
                    OutlinedTextField(value = basicRentModel, onValueChange = onBasicRentModel, label = { Text("Temple Hall Booking Model") }, modifier = Modifier.fillMaxWidth())
                }
                VenueType.LuxuryHotel -> {
                    OutlinedTextField(value = starRating, onValueChange = onStarRating, label = { Text("Star Classification") }, modifier = Modifier.fillMaxWidth())
                    OutlinedTextField(value = soundproofCurfew, onValueChange = onSoundproofCurfew, label = { Text("Music soundproof curfew time") }, modifier = Modifier.fillMaxWidth())
                }
            }

            OutlinedTextField(value = parking, onValueChange = onParking, label = { Text("Valet Parking Capacity") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = decPol, onValueChange = onDecPol, label = { Text("Decor Policy") }, modifier = Modifier.fillMaxWidth())
            
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Text("Permit Outside Catering"); Switch(checked = alc, onCheckedChange = onAlc) // maps to isAlcoholAllowed / outside caterer
            }
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Text("Has On-site Rooms?"); Switch(checked = hasRooms, onCheckedChange = onHasRooms)
            }
            if (hasRooms) OutlinedTextField(value = roomCount, onValueChange = onRoomCount, label = { Text("Number of Guest Rooms") }, modifier = Modifier.fillMaxWidth())
        }
        "Photography" -> {
            Text("Select Photography Styles", fontWeight = FontWeight.Bold)
            Row(modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                PhotographyStyle.values().forEach { st ->
                    FilterChip(selected = st in styles, onClick = { if (st in styles) styles.remove(st) else styles.add(st) }, label = { Text(st.name) })
                }
            }
            OutlinedTextField(value = pPhoto, onValueChange = onPPhoto, label = { Text("Photo Only Price/Day") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = pVideo, onValueChange = onPVideo, label = { Text("Video Only Price/Day") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = pCombo, onValueChange = onPCombo, label = { Text("Combo Price/Day") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = del, onValueChange = onDel, label = { Text("Delivery Time (Weeks)") }, modifier = Modifier.fillMaxWidth())
        }
        "Decorator" -> {
            Text("Select Mandap Styles", fontWeight = FontWeight.Bold)
            Row(modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                MandapStyle.values().forEach { st ->
                    FilterChip(selected = st in mStyles, onClick = { if (st in mStyles) mStyles.remove(st) else mStyles.add(st) }, label = { Text(st.name) })
                }
            }
            OutlinedTextField(value = dim, onValueChange = onDim, label = { Text("Standard Canopy Dimensions") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = mBudget, onValueChange = onMBudget, label = { Text("Minimum Budget (₹)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = setupH, onValueChange = onSetupH, label = { Text("Setup Time (Hours)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = specText, onValueChange = onSpecText, label = { Text("Specialties (Comma separated)") }, modifier = Modifier.fillMaxWidth())
        }
        "Catering" -> {
            OutlinedTextField(value = minG, onValueChange = onMinG, label = { Text("Minimum Guest Count") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = pPlate, onValueChange = onPPlate, label = { Text("Base Price/Plate (₹)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = wCount, onValueChange = onWCount, label = { Text("Waitstaff Count") }, modifier = Modifier.fillMaxWidth())
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Text("Includes Crockery & Cutlery"); Switch(checked = iCrockery, onCheckedChange = onICrockery)
            }
        }
        "Makeup" -> {
            Text("Select Makeup Types", fontWeight = FontWeight.Bold)
            Row(modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                MakeupType.values().forEach { st ->
                    FilterChip(selected = st in mkTypes, onClick = { if (st in mkTypes) mkTypes.remove(st) else mkTypes.add(st) }, label = { Text(st.name) })
                }
            }
            OutlinedTextField(value = sPrice, onValueChange = onSPrice, label = { Text("Studio Price (₹)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = vPrice, onValueChange = onVPrice, label = { Text("Venue Price (₹)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = pPrice, onValueChange = onPPrice, label = { Text("Party Makeup Price (₹)") }, modifier = Modifier.fillMaxWidth())
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Text("Hair Styling Included"); Switch(checked = hair, onCheckedChange = onHair)
            }
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Text("Saree / Lehenga Draping Included"); Switch(checked = draping, onCheckedChange = onDraping)
            }
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Text("Paid Consultation Trials Available"); Switch(checked = trial, onCheckedChange = onTrial)
            }
        }
    }

    Divider(modifier = Modifier.padding(vertical = 16.dp))
    Text("Universal Booking Policies", fontWeight = FontWeight.Bold, color = RoyalNavy)
    OutlinedTextField(value = adv, onValueChange = onAdv, label = { Text("Advance Payment Required (%)") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = cancel, onValueChange = onCancel, label = { Text("Cancellation Policy Description") }, modifier = Modifier.fillMaxWidth())
}

// ---------------------------------------------------------------------------
// Step 4: Premium Media Gallery
// ---------------------------------------------------------------------------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Step4MediaGallery(cover: String, gallery: MutableList<String>, video: String, onCover: (String)->Unit, onVideo: (String)->Unit) {
    val context = LocalContext.current
    
    Text("Premium Media Gallery", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
    Text("Upload high-res photos to stand out to clients.", fontSize = 14.sp, color = SlateGray)

    // Cover Photo Zone
    Card(shape = RoundedCornerShape(12.dp), modifier = Modifier.fillMaxWidth().height(140.dp), colors = CardDefaults.cardColors(containerColor = PearlWhite), border = BorderStroke(1.dp, ChampagneGold)) {
        Box(modifier = Modifier.fillMaxSize().clickable { 
            onCover("https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=2098&auto=format&fit=crop")
            Toast.makeText(context, "Cover Photo Uploaded", Toast.LENGTH_SHORT).show()
        }, contentAlignment = Alignment.Center) {
            if (cover.isNotBlank()) {
                Box(modifier = Modifier.fillMaxSize().background(Color.Gray)) {
                    Text("Cover Uploaded", color = Color.White, modifier = Modifier.align(Alignment.Center))
                }
            } else {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(Icons.Default.CloudUpload, null, tint = DarkGold, modifier = Modifier.size(36.dp))
                    Text("Tap to upload Hero Cover Photo", color = DarkGold, fontWeight = FontWeight.Bold)
                }
            }
        }
    }

    // Gallery Grid
    Text("Gallery Photos", fontWeight = FontWeight.Bold, color = RoyalNavy)
    Row(modifier = Modifier.fillMaxWidth().horizontalScroll(rememberScrollState()), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        Surface(onClick = { 
            gallery.add("https://images.unsplash.com/photo-1544078755-9ee020cda4fb?q=80&w=600&auto=format&fit=crop")
            Toast.makeText(context, "Added to Gallery", Toast.LENGTH_SHORT).show()
        }, shape = RoundedCornerShape(12.dp), color = SoftMist, border = BorderStroke(1.dp, LightSlate), modifier = Modifier.size(90.dp)) {
            Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                Icon(Icons.Default.AddPhotoAlternate, null, tint = EmeraldGreen)
                Text("Add", fontSize = 12.sp, color = SlateGray)
            }
        }

        gallery.forEach { url ->
            Box(modifier = Modifier.size(90.dp)) {
                Surface(shape = RoundedCornerShape(12.dp), color = Color.LightGray, modifier = Modifier.fillMaxSize()) {
                    Text("IMG", modifier = Modifier.align(Alignment.Center), fontSize = 10.sp)
                }
                Surface(onClick = { gallery.remove(url) }, shape = CircleShape, color = RoseRed, modifier = Modifier.align(Alignment.TopEnd).offset(x = 6.dp, y = (-6).dp).size(22.dp)) {
                    Icon(Icons.Default.Close, null, tint = Color.White, modifier = Modifier.padding(4.dp))
                }
            }
        }
    }

    OutlinedTextField(value = video, onValueChange = onVideo, label = { Text("Direct Video / YouTube Link") }, modifier = Modifier.fillMaxWidth())
}

// ---------------------------------------------------------------------------
// Step 5: Banking & Escrow Credentials
// ---------------------------------------------------------------------------
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Step5BankingCredentials(
    bankAccountName: String, bankAccountNumber: String, bankName: String, bankIfscCode: String, upiId: String,
    onBankAccountName: (String)->Unit, onBankAccountNumber: (String)->Unit, onBankName: (String)->Unit, onBankIfscCode: (String)->Unit, onUpiId: (String)->Unit
) {
    Text("Escrow Payout Settlement Accounts", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
    Text("Add your bank accounts to enable real-time splits of event payments.", fontSize = 14.sp, color = SlateGray)

    OutlinedTextField(value = bankAccountName, onValueChange = onBankAccountName, label = { Text("Account Holder Name") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = bankName, onValueChange = onBankName, label = { Text("Bank Name") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = bankAccountNumber, onValueChange = onBankAccountNumber, label = { Text("Bank Account Number") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = bankIfscCode, onValueChange = onBankIfscCode, label = { Text("Bank IFSC Code") }, modifier = Modifier.fillMaxWidth())
    
    Divider(modifier = Modifier.padding(vertical = 8.dp))
    Text("Direct UPI ID Settlement", fontWeight = FontWeight.Bold, color = RoyalNavy)
    OutlinedTextField(value = upiId, onValueChange = onUpiId, label = { Text("UPI ID (VPA: e.g. name@upi)") }, modifier = Modifier.fillMaxWidth())
}
