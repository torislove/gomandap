package com.gomandap.vendor.presentation.onboard

import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex
import androidx.compose.ui.res.painterResource
import androidx.compose.runtime.snapshots.SnapshotStateList
import com.gomandap.app.domain.model.*
import com.gomandap.app.presentation.search.MakeupType
import com.gomandap.vendor.data.vendor.VendorRepository
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import java.util.UUID

// ─── Luxury Kalamkari Brand Tokens ───────────────────────────────────────────
private val RoyalNavy      = Color(0xFF0F172A)
private val EmeraldGreen   = Color(0xFF10B981)
private val ChampagneGold  = Color(0xFFDFBA73)
private val DarkGold       = Color(0xFFC59A48)
private val SoftMist       = Color(0xFFF8FAFC)
private val SlateGray      = Color(0xFF64748B)
private val HotRose        = Color(0xFFF43F5E)
private val SandGold       = Color(0xFFFEF3C7)
private val WarmRed        = Color(0xFFEF4444)

@OptIn(ExperimentalMaterial3Api::class, ExperimentalAnimationApi::class, ExperimentalLayoutApi::class)
@Composable
fun VendorOnboardScreen(onOnboardComplete: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val haptic = LocalHapticFeedback.current

    var currentStep by remember { mutableStateOf(1) }
    val totalSteps = 6

    // ─── STEP 1: Mobile OTP Sign-In ──────────────────────────────────────────
    var mobileInput by remember { mutableStateOf("") }
    var enteredOtp by remember { mutableStateOf("") }
    var isOtpSent by remember { mutableStateOf(false) }
    var isOtpVerified by remember { mutableStateOf(false) }

    // ─── STEP 2: Category & Core Service ─────────────────────────────────────
    var selectedCategory by remember { mutableStateOf("Banquet") }
    var selectedVenueType by remember { mutableStateOf(VenueType.BanquetHall) }
    var expandedVenueTypeDropdown by remember { mutableStateOf(false) }

    // ─── STEP 3: Business KYC & Geo-Radar ────────────────────────────────────
    var businessName by remember { mutableStateOf("") }
    var locality by remember { mutableStateOf("") }
    var basePriceInput by remember { mutableStateOf("") }
    var yearEstablished by remember { mutableStateOf("2024") }
    var instagramUrl by remember { mutableStateOf("") }
    var googleMapsUrl by remember { mutableStateOf("") }
    var gstinInput by remember { mutableStateOf("") }
    var gstinError by remember { mutableStateOf(false) }
    
    // Address detail
    var fullAddress by remember { mutableStateOf("") }
    var city by remember { mutableStateOf("") }
    var state by remember { mutableStateOf("") }
    var pincode by remember { mutableStateOf("") }
    var landmark by remember { mutableStateOf("") }

    // Contact info
    var contactMobile by remember { mutableStateOf("") }
    var whatsAppNumber by remember { mutableStateOf("") }
    var contactEmail by remember { mutableStateOf("") }

    // Geo-Radar settings
    var gpsLocationLocked by remember { mutableStateOf(false) }
    var gpsCoordinates by remember { mutableStateOf("") }
    var travelRadiusKm by remember { mutableStateOf(15f) }

    // ─── STEP 4: Advanced Category specs (Polymorphic) ────────────────────────
    // Banquets
    var platePriceVeg by remember { mutableStateOf("1500") }
    var platePriceNonVeg by remember { mutableStateOf("2200") }
    var hasRooms by remember { mutableStateOf(true) }
    var roomCount by remember { mutableStateOf("20") }
    var parkingCount by remember { mutableStateOf("100") }
    var alcoholAllowed by remember { mutableStateOf(false) }
    var decorPolicy by remember { mutableStateOf("In-house decor only") }
    var djPolicy by remember { mutableStateOf("In-house DJ only") }
    
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

    // Catering specs
    var cateringFssaiInput by remember { mutableStateOf("") }
    var fssaiError by remember { mutableStateOf(false) }
    var platePriceVegStd by remember { mutableStateOf("800") }
    var platePriceVegDlx by remember { mutableStateOf("1200") }
    var platePriceNonVegStd by remember { mutableStateOf("1200") }
    var platePriceNonVegDlx by remember { mutableStateOf("1800") }
    var cateringMinGuests by remember { mutableStateOf("150") }
    var waitstaffCount by remember { mutableStateOf("15") }
    var includesCrockery by remember { mutableStateOf(true) }
    val cateringCuisines = remember { mutableStateListOf("South Indian", "North Indian", "Continental") }
    var separateJainKitchenConfirm by remember { mutableStateOf(false) }

    // Photography BUNDLED Package Specs
    // Essential Bundle
    var pPriceTier1 by remember { mutableStateOf("120000") }
    var pT1TradPhoto by remember { mutableStateOf(true) }
    var pT1TradVideo by remember { mutableStateOf(true) }
    var pT1CandidPhoto by remember { mutableStateOf(false) }
    var pT1Teaser by remember { mutableStateOf(false) }
    var pT1Drone by remember { mutableStateOf(false) }
    
    // Premium Bundle (Bestseller)
    var pPriceTier2 by remember { mutableStateOf("185000") }
    var pT2TradPhoto by remember { mutableStateOf(true) }
    var pT2TradVideo by remember { mutableStateOf(true) }
    var pT2CandidPhoto by remember { mutableStateOf(true) }
    var pT2Teaser by remember { mutableStateOf(true) }
    var pT2Drone by remember { mutableStateOf(true) }

    // Royal Elite Bundle
    var pPriceTier3 by remember { mutableStateOf("250000") }
    var pT3TradPhoto by remember { mutableStateOf(true) }
    var pT3TradVideo by remember { mutableStateOf(true) }
    var pT3CandidPhoto by remember { mutableStateOf(true) }
    var pT3Teaser by remember { mutableStateOf(true) }
    var pT3Drone by remember { mutableStateOf(true) }
    var pT3PreWedding by remember { mutableStateOf(true) }

    var albumsCountStepper by remember { mutableStateOf(2) }
    var photoDeliveryWeeksSlider by remember { mutableStateOf(6f) }
    
    var gearSonyA1 by remember { mutableStateOf(true) }
    var gearNikonZ9 by remember { mutableStateOf(false) }
    var gearHeavyDrone by remember { mutableStateOf(false) }

    // Decorator Specs
    val decoratorThemes = remember { mutableStateListOf("Floral Canopy", "Traditional Mandap") }
    var decorMaterialFresh by remember { mutableStateOf(true) }
    var decorMaterialImported by remember { mutableStateOf(false) }
    var decorMaterialFaux by remember { mutableStateOf(false) }
    var decorStartingStagePrice by remember { mutableStateOf("60000") }
    var decorSetupTimeHours by remember { mutableStateOf("8") }
    var decorDimensions by remember { mutableStateOf("30x35 ft") }

    // Bridal Makeup Specs
    var makeupPriceHd by remember { mutableStateOf("15000") }
    var makeupPriceAirbrush by remember { mutableStateOf("22000") }
    val makeupBrands = remember { mutableStateListOf("MAC", "Huda Beauty", "NARS") }
    var makeupPaidTrialAvailable by remember { mutableStateOf(true) }
    var makeupTrialFeeAbsorbed by remember { mutableStateOf(true) }

    // Policies
    var paymentAdvancePercent by remember { mutableStateOf("30") }
    var cancellationPolicy by remember { mutableStateOf("Non-Refundable") }

    // ─── STEP 5: Ingestion Portfolio & Transformation ────────────────────────
    var coverPhotoUrl by remember { mutableStateOf("https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=2098&auto=format&fit=crop") }
    val selectedPhotos = remember { mutableStateListOf<String>() }
    var videoUrlInput by remember { mutableStateOf("") }
    var beforeImageUrl by remember { mutableStateOf("https://images.unsplash.com/photo-1544078755-9ee020cda4fb?q=80&w=600&auto=format&fit=crop") }
    var afterImageUrl by remember { mutableStateOf("https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=600&auto=format&fit=crop") }
    var resolutionError by remember { mutableStateOf("") }
    val selectedEventTags = remember { mutableStateListOf("Muhurtham", "Haldi") }

    // ─── STEP 6: Banking & SLA Lock ──────────────────────────────────────────
    var bankAccountHolderName by remember { mutableStateOf("") }
    var bankAccountNumber by remember { mutableStateOf("") }
    var bankName by remember { mutableStateOf("") }
    var bankIfscCode by remember { mutableStateOf("") }
    var upiId by remember { mutableStateOf("") }
    var slaAccepted by remember { mutableStateOf(false) }

    // Dynamic validations
    val isStep1Valid = isOtpVerified
    val isStep2Valid = selectedCategory.isNotBlank()
    val isStep3Valid = businessName.isNotBlank() && fullAddress.isNotBlank() && contactMobile.isNotBlank() && !gstinError && gstinInput.isNotBlank() && gpsLocationLocked
    val isStep4Valid = if (selectedCategory == "Catering") {
        cateringFssaiInput.isNotBlank() && !fssaiError
    } else {
        true
    }
    val isStep5Valid = coverPhotoUrl.isNotBlank()
    val isStep6Valid = bankAccountNumber.isNotBlank() && bankIfscCode.isNotBlank() && slaAccepted

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Image(
                            painter = painterResource(id = com.gomandap.common.R.drawable.ic_gm_logo),
                            contentDescription = "GM Logo",
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("GM ", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 18.sp)
                        Text("Onboarding Setup", fontWeight = FontWeight.Bold, color = ChampagneGold, fontSize = 16.sp)
                    }
                },
                navigationIcon = {
                    if (currentStep > 1) {
                        IconButton(onClick = { currentStep-- }) {
                            Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White),
                modifier = Modifier.shadow(2.dp)
            )
        },
        containerColor = SoftMist,
        bottomBar = {
            Surface(
                color = Color.White,
                shadowElevation = 16.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(16.dp).fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = "Step $currentStep of $totalSteps",
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Bold,
                        color = SlateGray
                    )

                    val canProceed = when(currentStep) {
                        1 -> isStep1Valid
                        2 -> isStep2Valid
                        3 -> isStep3Valid
                        4 -> isStep4Valid
                        5 -> isStep5Valid
                        6 -> isStep6Valid
                        else -> false
                    }

                    Button(
                        enabled = canProceed,
                        onClick = {
                            if (currentStep < totalSteps) {
                                currentStep++
                                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                            } else {
                                // Final submit lock logic
                                scope.launch {
                                    val finalId = "vendor_" + UUID.randomUUID().toString().take(6)
                                    val price = basePriceInput.toDoubleOrNull() ?: 150000.0
                                    val photoList = selectedPhotos.toList()
                                    val cPhoto = if (coverPhotoUrl.isNotBlank()) coverPhotoUrl else photoList.firstOrNull() ?: beforeImageUrl

                                    val baseMap = mutableMapOf(
                                        "gstin" to gstinInput,
                                        "fssai" to cateringFssaiInput,
                                        "travel_radius" to travelRadiusKm.toInt().toString(),
                                        "advance_percent" to paymentAdvancePercent,
                                        "cancellation" to cancellationPolicy
                                    )

                                    // Add photography bundles if photographer
                                    if (selectedCategory == "Photography") {
                                        baseMap["photography_tier1_price"] = pPriceTier1
                                        baseMap["photography_tier2_price"] = pPriceTier2
                                        baseMap["photography_tier3_price"] = pPriceTier3
                                        baseMap["photography_albums_count"] = albumsCountStepper.toString()
                                        baseMap["photography_delivery_weeks"] = photoDeliveryWeeksSlider.toInt().toString()
                                        baseMap["gear_tags"] = buildString {
                                            if (gearSonyA1) append("Sony A1, ")
                                            if (gearNikonZ9) append("Nikon Z9, ")
                                            if (gearHeavyDrone) append("DJI Inspire Drone")
                                        }.removeSuffix(", ")
                                    }

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
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 30,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = contactMobile, emailId = contactEmail, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountHolderName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            venueType = selectedVenueType,
                                            pricePerPlateVeg = platePriceVeg.toDoubleOrNull() ?: 1500.0,
                                            pricePerPlateNonVeg = platePriceNonVeg.toDoubleOrNull() ?: 2200.0,
                                            spaces = listOf(EventSpace("Ornate Hall", "Hall", 500, 800)),
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
                                            id = finalId, name = businessName, locality = locality, basePrice = pPriceTier2.toDoubleOrNull() ?: 185000.0, rating = 5.0f,
                                            imageUrls = listOf(cPhoto) + photoList.take(2),
                                            isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                            approvalStatus = ApprovalStatus.PENDING_APPROVAL, adminNotes = "Pending review", isLive = false,
                                            photos = photoList, coverPhotoUrl = cPhoto, videoUrl = videoUrlInput,
                                            details = baseMap,
                                            yearEstablished = yearEstablished.toIntOrNull() ?: 2024,
                                            instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 30,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = contactMobile, emailId = contactEmail, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountHolderName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            style = listOf(PhotographyStyle.Candid, PhotographyStyle.Cinematic, PhotographyStyle.Drone),
                                            pricePhotoOnly = pPriceTier1.toDoubleOrNull() ?: 120000.0,
                                            priceVideoOnly = pPriceTier3.toDoubleOrNull() ?: 250000.0,
                                            priceCombo = pPriceTier2.toDoubleOrNull() ?: 185000.0,
                                            portfolioVideoUrl = videoUrlInput, deliveryTimeWeeks = photoDeliveryWeeksSlider.toInt(),
                                            clientBearsTravelCost = true, includesAlbum = albumsCountStepper > 0
                                        )
                                        "Decorator" -> DecorMandapVendor(
                                            id = finalId, name = businessName, locality = locality, basePrice = decorStartingStagePrice.toDoubleOrNull() ?: 60000.0, rating = 5.0f,
                                            imageUrls = listOf(cPhoto) + photoList.take(2),
                                            isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                            approvalStatus = ApprovalStatus.PENDING_APPROVAL, adminNotes = "Pending review", isLive = false,
                                            photos = photoList, coverPhotoUrl = cPhoto, videoUrl = videoUrlInput,
                                            details = baseMap,
                                            yearEstablished = yearEstablished.toIntOrNull() ?: 2024,
                                            instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 30,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = contactMobile, emailId = contactEmail, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountHolderName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            mandapStyle = listOf(MandapStyle.Traditional, MandapStyle.Floral), specialties = decoratorThemes.toList(),
                                            minimumBudget = decorStartingStagePrice.toDoubleOrNull() ?: 60000.0, dimensions = decorDimensions,
                                            setupTimeHours = decorSetupTimeHours.toIntOrNull() ?: 8
                                        )
                                        "Catering" -> CateringVendor(
                                            id = finalId, name = businessName, locality = locality, basePrice = platePriceVegStd.toDoubleOrNull() ?: 800.0, rating = 5.0f,
                                            imageUrls = listOf(cPhoto) + photoList.take(2),
                                            isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                            approvalStatus = ApprovalStatus.PENDING_APPROVAL, adminNotes = "Pending review", isLive = false,
                                            photos = photoList, coverPhotoUrl = cPhoto, videoUrl = videoUrlInput,
                                            details = baseMap,
                                            yearEstablished = yearEstablished.toIntOrNull() ?: 2024,
                                            instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 30,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = contactMobile, emailId = contactEmail, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountHolderName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            cuisineTypes = cateringCuisines.toList(), serviceTypes = listOf("Buffet Service"),
                                            minGuestCount = cateringMinGuests.toIntOrNull() ?: 150, pricePerPlate = platePriceVegStd.toDoubleOrNull() ?: 800.0,
                                            includesCrockery = includesCrockery, waitstaffCount = waitstaffCount.toIntOrNull() ?: 15
                                        )
                                        "Makeup" -> MakeupArtistVendor(
                                            id = finalId, name = businessName, locality = locality, basePrice = makeupPriceHd.toDoubleOrNull() ?: 15000.0, rating = 5.0f,
                                            imageUrls = listOf(cPhoto) + photoList.take(2),
                                            isEscrowProtected = true, isVerified = false, isFastFilling = false,
                                            approvalStatus = ApprovalStatus.PENDING_APPROVAL, adminNotes = "Pending review", isLive = false,
                                            photos = photoList, coverPhotoUrl = cPhoto, videoUrl = videoUrlInput,
                                            details = baseMap,
                                            yearEstablished = yearEstablished.toIntOrNull() ?: 2024,
                                            instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                                            paymentAdvancePercent = paymentAdvancePercent.toIntOrNull() ?: 30,
                                            cancellationPolicy = cancellationPolicy,

                                            fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                                            mobileNumber = contactMobile, emailId = contactEmail, whatsAppNumber = whatsAppNumber,
                                            bankAccountName = bankAccountHolderName, bankAccountNumber = bankAccountNumber,
                                            bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,

                                            makeupTypes = listOf(MakeupType.HDMakeup, MakeupType.Airbrush),
                                            isHairStylingIncluded = true, isDrapingIncluded = true, isPaidTrialAvailable = makeupPaidTrialAvailable,
                                            studioPrice = makeupPriceHd.toDoubleOrNull() ?: 15000.0, venuePrice = makeupPriceAirbrush.toDoubleOrNull() ?: 22000.0,
                                            partyMakeupPrice = 3500.0
                                        )
                                        else -> error("Unknown Category")
                                    }

                                    VendorRepository.addVendor(newVendor)
                                    Toast.makeText(context, "🎉 Advanced Business Profile Submitted for Admin Approval!", Toast.LENGTH_LONG).show()
                                    onOnboardComplete()
                                }
                            }
                        },
                        colors = ButtonDefaults.buttonColors(
                            containerColor = EmeraldGreen,
                            disabledContainerColor = SlateGray.copy(alpha = 0.25f)
                        ),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.height(48.dp)
                    ) {
                        Text(
                            text = if (currentStep < totalSteps) "Next Step" else "Lock & Submit Draft",
                            color = Color.White,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(Modifier.width(8.dp))
                        Icon(
                            imageVector = if (currentStep < totalSteps) Icons.AutoMirrored.Filled.ArrowForward else Icons.Default.Lock,
                            contentDescription = null,
                            tint = Color.White
                        )
                    }
                }
            }
        },
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Horizontal Step Indicators
            LinearProgressIndicator(
                progress = currentStep.toFloat() / totalSteps.toFloat(),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(4.dp),
                color = ChampagneGold,
                trackColor = SlateGray.copy(alpha = 0.1f)
            )

            AnimatedContent(
                targetState = currentStep,
                transitionSpec = {
                    fadeIn(tween(300)) togetherWith fadeOut(tween(200))
                },
                modifier = Modifier.fillMaxSize()
            ) { step ->
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(rememberScrollState())
                        .padding(20.dp),
                    verticalArrangement = Arrangement.spacedBy(20.dp)
                ) {
                    when (step) {
                        1 -> Step1OtpVerification(
                            mobileInput = mobileInput,
                            enteredOtp = enteredOtp,
                            isOtpSent = isOtpSent,
                            isOtpVerified = isOtpVerified,
                            onMobileChange = { mobileInput = it },
                            onOtpChange = { enteredOtp = it },
                            onSendOtp = {
                                isOtpSent = true
                                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                Toast.makeText(context, "OTP Sent (Use 1234 to verify)", Toast.LENGTH_SHORT).show()
                            },
                            onVerifyOtp = {
                                if (enteredOtp == "1234") {
                                    isOtpVerified = true
                                    contactMobile = mobileInput
                                    whatsAppNumber = mobileInput
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                    Toast.makeText(context, "OTP Verified successfully!", Toast.LENGTH_SHORT).show()
                                    scope.launch {
                                        delay(500)
                                        currentStep = 2
                                    }
                                } else {
                                    Toast.makeText(context, "Invalid OTP. Try '1234'.", Toast.LENGTH_SHORT).show()
                                }
                            }
                        )

                        2 -> Step2CategorySelection(
                            selectedCategory = selectedCategory,
                            selectedVenueType = selectedVenueType,
                            expandedVenueTypeDropdown = expandedVenueTypeDropdown,
                            onCategorySelected = { selectedCategory = it },
                            onVenueTypeSelected = { selectedVenueType = it },
                            onOpenVenueType = { expandedVenueTypeDropdown = true },
                            onDismissVenueType = { expandedVenueTypeDropdown = false }
                        )

                        3 -> Step3BusinessKycGeo(
                            businessName = businessName,
                            locality = locality,
                            basePriceInput = basePriceInput,
                            yearEstablished = yearEstablished,
                            instagramUrl = instagramUrl,
                            googleMapsUrl = googleMapsUrl,
                            gstinInput = gstinInput,
                            gstinError = gstinError,
                            fullAddress = fullAddress,
                            city = city,
                            state = state,
                            pincode = pincode,
                            landmark = landmark,
                            contactEmail = contactEmail,
                            whatsAppNumber = whatsAppNumber,
                            gpsLocationLocked = gpsLocationLocked,
                            gpsCoordinates = gpsCoordinates,
                            travelRadiusKm = travelRadiusKm,
                            onBusinessName = { businessName = it },
                            onLocality = { locality = it },
                            onBasePrice = { basePriceInput = it },
                            onYear = { yearEstablished = it },
                            onInstagram = { instagramUrl = it },
                            onGoogleMaps = { googleMapsUrl = it },
                            onGstin = {
                                gstinInput = it
                                val regex = Regex("^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$")
                                gstinError = it.isNotBlank() && !regex.matches(it.uppercase())
                            },
                            onFullAddress = { fullAddress = it },
                            onCity = { city = it },
                            onState = { state = it },
                            onPincode = { pincode = it },
                            onLandmark = { landmark = it },
                            onEmail = { contactEmail = it },
                            onWhatsApp = { whatsAppNumber = it },
                            onCalibrateGps = {
                                gpsLocationLocked = true
                                gpsCoordinates = "16.3067° N, 80.4365° E (Guntur Central)"
                                locality = "Guntur"
                                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                Toast.makeText(context, "GPS Coordinates locked in registry!", Toast.LENGTH_SHORT).show()
                            },
                            onRadiusChange = {
                                travelRadiusKm = it
                                haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                            }
                        )

                        4 -> Step4PolymorphicSpecs(
                            category = selectedCategory,
                            venueType = selectedVenueType,
                            platePriceVeg = platePriceVeg,
                            platePriceNonVeg = platePriceNonVeg,
                            hasRooms = hasRooms,
                            roomCount = roomCount,
                            parkingCount = parkingCount,
                            alcoholAllowed = alcoholAllowed,
                            decorPolicy = decorPolicy,
                            djPolicy = djPolicy,
                            acCapacity = acCapacity,
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
                            soundproofCurfew = soundproofCurfew,
                            cateringFssaiInput = cateringFssaiInput,
                            fssaiError = fssaiError,
                            platePriceVegStd = platePriceVegStd,
                            platePriceVegDlx = platePriceVegDlx,
                            platePriceNonVegStd = platePriceNonVegStd,
                            platePriceNonVegDlx = platePriceNonVegDlx,
                            cateringMinGuests = cateringMinGuests,
                            waitstaffCount = waitstaffCount,
                            includesCrockery = includesCrockery,
                            cateringCuisines = cateringCuisines,
                            separateJainKitchenConfirm = separateJainKitchenConfirm,
                            pPriceTier1 = pPriceTier1,
                            pT1TradPhoto = pT1TradPhoto,
                            pT1TradVideo = pT1TradVideo,
                            pT1CandidPhoto = pT1CandidPhoto,
                            pT1Teaser = pT1Teaser,
                            pT1Drone = pT1Drone,
                            pPriceTier2 = pPriceTier2,
                            pT2TradPhoto = pT2TradPhoto,
                            pT2TradVideo = pT2TradVideo,
                            pT2CandidPhoto = pT2CandidPhoto,
                            pT2Teaser = pT2Teaser,
                            pT2Drone = pT2Drone,
                            pPriceTier3 = pPriceTier3,
                            pT3TradPhoto = pT3TradPhoto,
                            pT3TradVideo = pT3TradVideo,
                            pT3CandidPhoto = pT3CandidPhoto,
                            pT3Teaser = pT3Teaser,
                            pT3Drone = pT3Drone,
                            pT3PreWedding = pT3PreWedding,
                            albumsCountStepper = albumsCountStepper,
                            photoDeliveryWeeksSlider = photoDeliveryWeeksSlider,
                            gearSonyA1 = gearSonyA1,
                            gearNikonZ9 = gearNikonZ9,
                            gearHeavyDrone = gearHeavyDrone,
                            decoratorThemes = decoratorThemes,
                            decorMaterialFresh = decorMaterialFresh,
                            decorMaterialImported = decorMaterialImported,
                            decorMaterialFaux = decorMaterialFaux,
                            decorStartingStagePrice = decorStartingStagePrice,
                            decorSetupTimeHours = decorSetupTimeHours,
                            decorDimensions = decorDimensions,
                            makeupPriceHd = makeupPriceHd,
                            makeupPriceAirbrush = makeupPriceAirbrush,
                            makeupBrands = makeupBrands,
                            makeupPaidTrialAvailable = makeupPaidTrialAvailable,
                            makeupTrialFeeAbsorbed = makeupTrialFeeAbsorbed,
                            paymentAdvancePercent = paymentAdvancePercent,
                            cancellationPolicy = cancellationPolicy,
                            onPlateVeg = { platePriceVeg = it },
                            onPlateNonVeg = { platePriceNonVeg = it },
                            onHasRooms = { hasRooms = it },
                            onRoomCount = { roomCount = it },
                            onParking = { parkingCount = it },
                            onAlcohol = { alcoholAllowed = it },
                            onDecorPol = { decorPolicy = it },
                            onDjPol = { djPolicy = it },
                            onAcCapacity = { acCapacity = it },
                            onTotalLawn = { totalLawnArea = it },
                            onRainProtection = { rainProtection = it },
                            onRoomConfig = { roomConfigurations = it },
                            onPoolside = { poolSideEvent = it },
                            onHeritage = { heritageCategory = it },
                            onRoyalEntry = { royalEntryCarriage = it },
                            onTradLayout = { traditionalLayout = it },
                            onPoojaPack = { poojaPackage = it },
                            onRentModel = { basicRentModel = it },
                            onStarRating = { starRating = it },
                            onCurfew = { soundproofCurfew = it },
                            onFssai = {
                                cateringFssaiInput = it
                                val regex = Regex("^[0-9]{14}$")
                                fssaiError = it.isNotBlank() && !regex.matches(it)
                            },
                            onPlateVegStd = { platePriceVegStd = it },
                            onPlateVegDlx = { platePriceVegDlx = it },
                            onPlateNonVegStd = { platePriceNonVegStd = it },
                            onPlateNonVegDlx = { platePriceNonVegDlx = it },
                            onMinGuests = { cateringMinGuests = it },
                            onWaitstaff = { waitstaffCount = it },
                            onCrockery = { includesCrockery = it },
                            onJainConfirm = { separateJainKitchenConfirm = it },
                            onPhotoTier1Price = { pPriceTier1 = it },
                            onPhotoT1Candid = { pT1CandidPhoto = it },
                            onPhotoT1Trad = { pT1TradPhoto = it },
                            onPhotoT1TradV = { pT1TradVideo = it },
                            onPhotoT1Tease = { pT1Teaser = it },
                            onPhotoT1Drone = { pT1Drone = it },
                            onPhotoTier2Price = { pPriceTier2 = it },
                            onPhotoT2Candid = { pT2CandidPhoto = it },
                            onPhotoT2Trad = { pT2TradPhoto = it },
                            onPhotoT2TradV = { pT2TradVideo = it },
                            onPhotoT2Tease = { pT2Teaser = it },
                            onPhotoT2Drone = { pT2Drone = it },
                            onPhotoTier3Price = { pPriceTier3 = it },
                            onPhotoT3Candid = { pT3CandidPhoto = it },
                            onPhotoT3Trad = { pT3TradPhoto = it },
                            onPhotoT3TradV = { pT3TradVideo = it },
                            onPhotoT3Tease = { pT3Teaser = it },
                            onPhotoT3Drone = { pT3Drone = it },
                            onPhotoT3PreW = { pT3PreWedding = it },
                            onAlbumsCount = { albumsCountStepper = it },
                            onPhotoWeeks = { photoDeliveryWeeksSlider = it },
                            onGearSony = { gearSonyA1 = it },
                            onGearNikon = { gearNikonZ9 = it },
                            onGearDrone = { gearHeavyDrone = it },
                            onDecorMaterialFresh = { decorMaterialFresh = it },
                            onDecorMaterialImported = { decorMaterialImported = it },
                            onDecorMaterialFaux = { decorMaterialFaux = it },
                            onDecorStartingStage = { decorStartingStagePrice = it },
                            onDecorSetupHours = { decorSetupTimeHours = it },
                            onDecorDim = { decorDimensions = it },
                            onMakeupHd = { makeupPriceHd = it },
                            onMakeupAirbrush = { makeupPriceAirbrush = it },
                            onMakeupTrial = { makeupPaidTrialAvailable = it },
                            onMakeupTrialAbsorb = { makeupTrialFeeAbsorbed = it },
                            onAdvancePercent = { paymentAdvancePercent = it },
                            onCancellation = { cancellationPolicy = it }
                        )

                        5 -> Step5MediaIngestion(
                            coverUrl = coverPhotoUrl,
                            generalPhotos = selectedPhotos,
                            videoUrl = videoUrlInput,
                            beforeUrl = beforeImageUrl,
                            afterUrl = afterImageUrl,
                            resolutionError = resolutionError,
                            selectedEventTags = selectedEventTags,
                            onCoverUrl = { coverPhotoUrl = it },
                            onVideoUrl = { videoUrlInput = it },
                            onBeforeUrl = { beforeImageUrl = it },
                            onAfterUrl = { afterImageUrl = it },
                            onResolutionCheck = { url ->
                                // Simulate resolutions checks by analyzing links
                                if (url.contains("warning") || url.length % 2 == 1) {
                                    resolutionError = "⚠️ WARNING: Image resolution is lower than standard 1080p. Premium clients filter for high-res listings."
                                } else {
                                    resolutionError = ""
                                }
                            }
                        )

                        6 -> Step6EscrowSla(
                            bankName = bankName,
                            bankAccountHolderName = bankAccountHolderName,
                            bankAccountNumber = bankAccountNumber,
                            bankIfscCode = bankIfscCode,
                            upiId = upiId,
                            slaAccepted = slaAccepted,
                            onBankName = { bankName = it },
                            onAccountHolder = { bankAccountHolderName = it },
                            onAccountNumber = { bankAccountNumber = it },
                            onIfscCode = { bankIfscCode = it },
                            onUpiId = { upiId = it },
                            onSlaAccepted = { slaAccepted = it }
                        )
                    }
                    Spacer(Modifier.height(80.dp))
                }
            }
        }
    }
}

// ─── STEP 1: MOBILE OTP VERIFICATION ─────────────────────────────────────────
@Composable
fun Step1OtpVerification(
    mobileInput: String,
    enteredOtp: String,
    isOtpSent: Boolean,
    isOtpVerified: Boolean,
    onMobileChange: (String) -> Unit,
    onOtpChange: (String) -> Unit,
    onSendOtp: () -> Unit,
    onVerifyOtp: () -> Unit
) {
    Text("Auspicious Vendor Access", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
    Text("Enter your mobile number to establish a verified partner channel.", fontSize = 14.sp, color = SlateGray)

    Surface(
        color = SandGold,
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.5f))
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text("🦚", fontSize = 24.sp)
            Text(
                "Welcome to the GoMandap network. Our trust ledger ensures complete booking automation and instant payouts.",
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                color = Color(0xFF92400E)
            )
        }
    }

    if (!isOtpSent) {
        OutlinedTextField(
            value = mobileInput,
            onValueChange = onMobileChange,
            label = { Text("Mobile Number (+91)") },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
        )
        Button(
            enabled = mobileInput.length >= 10,
            onClick = onSendOtp,
            colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth().height(48.dp)
        ) {
            Text("Send Auspicious OTP", fontWeight = FontWeight.Bold)
        }
    } else {
        OutlinedTextField(
            value = enteredOtp,
            onValueChange = onOtpChange,
            label = { Text("Enter 4-Digit OTP") },
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
        )
        Button(
            onClick = onVerifyOtp,
            colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
            shape = RoundedCornerShape(12.dp),
            modifier = Modifier.fillMaxWidth().height(48.dp)
        ) {
            Text("Verify OTP Access", fontWeight = FontWeight.Bold, color = Color.White)
        }
    }
}

// ─── STEP 2: CATEGORY SELECTION ──────────────────────────────────────────────
@Composable
fun Step2CategorySelection(
    selectedCategory: String,
    selectedVenueType: VenueType,
    expandedVenueTypeDropdown: Boolean,
    onCategorySelected: (String) -> Unit,
    onVenueTypeSelected: (VenueType) -> Unit,
    onOpenVenueType: () -> Unit,
    onDismissVenueType: () -> Unit
) {
    Text("Select Your Core Service", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
    Text("Which primary category does your business operate in?", fontSize = 14.sp, color = SlateGray)
    
    val categories = listOf(
        Pair("Banquet", "Venues (Banquet Halls, Kalyan Mandapams, Resorts...)"),
        Pair("Photography", "Candid, Cinematic, Drone & Bundled Packages"),
        Pair("Decorator", "Floral Canopy, Theme & Stage Designers"),
        Pair("Catering", "Premium Gastronomy, Veg & Non-Veg plate services"),
        Pair("Makeup", "Bridal airbrush, HD Makeovers & Styling")
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
                        text = { Text(vt.name) },
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

// ─── STEP 3: BUSINESS KYC & GEO-RADAR ────────────────────────────────────────
@Composable
fun Step3BusinessKycGeo(
    businessName: String,
    locality: String,
    basePriceInput: String,
    yearEstablished: String,
    instagramUrl: String,
    googleMapsUrl: String,
    gstinInput: String,
    gstinError: Boolean,
    fullAddress: String,
    city: String,
    state: String,
    pincode: String,
    landmark: String,
    contactEmail: String,
    whatsAppNumber: String,
    gpsLocationLocked: Boolean,
    gpsCoordinates: String,
    travelRadiusKm: Float,
    onBusinessName: (String) -> Unit,
    onLocality: (String) -> Unit,
    onBasePrice: (String) -> Unit,
    onYear: (String) -> Unit,
    onInstagram: (String) -> Unit,
    onGoogleMaps: (String) -> Unit,
    onGstin: (String) -> Unit,
    onFullAddress: (String) -> Unit,
    onCity: (String) -> Unit,
    onState: (String) -> Unit,
    onPincode: (String) -> Unit,
    onLandmark: (String) -> Unit,
    onEmail: (String) -> Unit,
    onWhatsApp: (String) -> Unit,
    onCalibrateGps: () -> Unit,
    onRadiusChange: (Float) -> Unit
) {
    Text("Business KYC & Geo-Discovery", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
    Text("Verify your corporate identity and lock geographical reach parameters.", fontSize = 14.sp, color = SlateGray)

    OutlinedTextField(
        value = businessName,
        onValueChange = onBusinessName,
        label = { Text("Legal Business / Brand Name") },
        modifier = Modifier.fillMaxWidth()
    )

    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        OutlinedTextField(
            value = yearEstablished,
            onValueChange = onYear,
            label = { Text("Year Established") },
            modifier = Modifier.weight(1f)
        )
        OutlinedTextField(
            value = basePriceInput,
            onValueChange = onBasePrice,
            label = { Text("Starting Rate (₹)") },
            modifier = Modifier.weight(1f)
        )
    }

    Column {
        OutlinedTextField(
            value = gstinInput,
            onValueChange = onGstin,
            label = { Text("GSTIN Identification Number") },
            isError = gstinError,
            modifier = Modifier.fillMaxWidth()
        )
        if (gstinError) {
            Text(
                "⚠️ Invalid GSTIN format. Require standard 15-digit code.",
                color = WarmRed,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(top = 4.dp)
            )
        }
    }

    Text("Address Locations", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
    OutlinedTextField(value = fullAddress, onValueChange = onFullAddress, label = { Text("Street Address") }, modifier = Modifier.fillMaxWidth())
    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        OutlinedTextField(value = city, onValueChange = onCity, label = { Text("City") }, modifier = Modifier.weight(1f))
        OutlinedTextField(value = state, onValueChange = onState, label = { Text("State") }, modifier = Modifier.weight(1f))
    }
    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        OutlinedTextField(value = pincode, onValueChange = onPincode, label = { Text("Pincode") }, modifier = Modifier.weight(1f))
        OutlinedTextField(value = landmark, onValueChange = onLandmark, label = { Text("Landmark") }, modifier = Modifier.weight(1.5f))
    }

    Text("Communications & Verification", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
    OutlinedTextField(value = whatsAppNumber, onValueChange = onWhatsApp, label = { Text("WhatsApp Contact Number") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = contactEmail, onValueChange = onEmail, label = { Text("Email Contact Address") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = instagramUrl, onValueChange = onInstagram, label = { Text("Instagram Profile URL") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = googleMapsUrl, onValueChange = onGoogleMaps, label = { Text("Google Maps Venue URL") }, modifier = Modifier.fillMaxWidth())

    Text("Geo-Radar Proximity Resolution", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
    Surface(
        color = Color.White,
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.25f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Background GPS Coordinates", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = RoyalNavy)
                    Text(if (gpsLocationLocked) gpsCoordinates else "Not Locked", fontSize = 11.sp, color = if (gpsLocationLocked) EmeraldGreen else SlateGray)
                }

                Button(
                    onClick = onCalibrateGps,
                    colors = ButtonDefaults.buttonColors(containerColor = if (gpsLocationLocked) EmeraldGreen else RoyalNavy),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Text(if (gpsLocationLocked) "GPS Calibrated" else "Sync Location", fontSize = 11.sp)
                }
            }

            if (gpsLocationLocked) {
                Text("Statewide Travel Radius Coverage: ${travelRadiusKm.toInt()} km", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = RoyalNavy)
                Slider(
                    value = travelRadiusKm,
                    onValueChange = onRadiusChange,
                    valueRange = 5f..150f,
                    colors = SliderDefaults.colors(
                        activeTrackColor = EmeraldGreen,
                        thumbColor = ChampagneGold
                    )
                )
            }
        }
    }
}

// ─── STEP 4: CATEGORY SPECIFIC SUPER-FORMS ───────────────────────────────────
@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
fun Step4PolymorphicSpecs(
    category: String,
    venueType: VenueType,
    // Banquets
    platePriceVeg: String, platePriceNonVeg: String, hasRooms: Boolean, roomCount: String, parkingCount: String, alcoholAllowed: Boolean, decorPolicy: String, djPolicy: String,
    acCapacity: String, totalLawnArea: String, rainProtection: Boolean, roomConfigurations: String, poolSideEvent: Boolean, heritageCategory: String, royalEntryCarriage: Boolean, traditionalLayout: Boolean, poojaPackage: Boolean, basicRentModel: String, starRating: String, soundproofCurfew: String,
    // Catering
    cateringFssaiInput: String, fssaiError: Boolean, platePriceVegStd: String, platePriceVegDlx: String, platePriceNonVegStd: String, platePriceNonVegDlx: String, cateringMinGuests: String, waitstaffCount: String, includesCrockery: Boolean, cateringCuisines: SnapshotStateList<String>, separateJainKitchenConfirm: Boolean,
    // Photography Bundling Matrix
    pPriceTier1: String, pT1TradPhoto: Boolean, pT1TradVideo: Boolean, pT1CandidPhoto: Boolean, pT1Teaser: Boolean, pT1Drone: Boolean,
    pPriceTier2: String, pT2TradPhoto: Boolean, pT2TradVideo: Boolean, pT2CandidPhoto: Boolean, pT2Teaser: Boolean, pT2Drone: Boolean,
    pPriceTier3: String, pT3TradPhoto: Boolean, pT3TradVideo: Boolean, pT3CandidPhoto: Boolean, pT3Teaser: Boolean, pT3Drone: Boolean, pT3PreWedding: Boolean,
    albumsCountStepper: Int, photoDeliveryWeeksSlider: Float,
    gearSonyA1: Boolean, gearNikonZ9: Boolean, gearHeavyDrone: Boolean,
    // Decor
    decoratorThemes: SnapshotStateList<String>, decorMaterialFresh: Boolean, decorMaterialImported: Boolean, decorMaterialFaux: Boolean, decorStartingStagePrice: String, decorSetupTimeHours: String, decorDimensions: String,
    // Makeup
    makeupPriceHd: String, makeupPriceAirbrush: String, makeupBrands: SnapshotStateList<String>, makeupPaidTrialAvailable: Boolean, makeupTrialFeeAbsorbed: Boolean,
    // Universal Policies
    paymentAdvancePercent: String, cancellationPolicy: String,
    onPlateVeg: (String) -> Unit, onPlateNonVeg: (String) -> Unit, onHasRooms: (Boolean) -> Unit, onRoomCount: (String) -> Unit, onParking: (String) -> Unit, onAlcohol: (Boolean) -> Unit, onDecorPol: (String) -> Unit, onDjPol: (String) -> Unit,
    onAcCapacity: (String) -> Unit, onTotalLawn: (String) -> Unit, onRainProtection: (Boolean) -> Unit, onRoomConfig: (String) -> Unit, onPoolside: (Boolean) -> Unit, onHeritage: (String) -> Unit, onRoyalEntry: (Boolean) -> Unit, onTradLayout: (Boolean) -> Unit, onPoojaPack: (Boolean) -> Unit, onRentModel: (String) -> Unit, onStarRating: (String) -> Unit, onCurfew: (String) -> Unit,
    onFssai: (String) -> Unit, onPlateVegStd: (String) -> Unit, onPlateVegDlx: (String) -> Unit, onPlateNonVegStd: (String) -> Unit, onPlateNonVegDlx: (String) -> Unit, onMinGuests: (String) -> Unit, onWaitstaff: (String) -> Unit, onCrockery: (Boolean) -> Unit, onJainConfirm: (Boolean) -> Unit,
    onPhotoTier1Price: (String) -> Unit, onPhotoT1Candid: (Boolean) -> Unit, onPhotoT1Trad: (Boolean) -> Unit, onPhotoT1TradV: (Boolean) -> Unit, onPhotoT1Tease: (Boolean) -> Unit, onPhotoT1Drone: (Boolean) -> Unit,
    onPhotoTier2Price: (String) -> Unit, onPhotoT2Candid: (Boolean) -> Unit, onPhotoT2Trad: (Boolean) -> Unit, onPhotoT2TradV: (Boolean) -> Unit, onPhotoT2Tease: (Boolean) -> Unit, onPhotoT2Drone: (Boolean) -> Unit,
    onPhotoTier3Price: (String) -> Unit, onPhotoT3Candid: (Boolean) -> Unit, onPhotoT3Trad: (Boolean) -> Unit, onPhotoT3TradV: (Boolean) -> Unit, onPhotoT3Tease: (Boolean) -> Unit, onPhotoT3Drone: (Boolean) -> Unit, onPhotoT3PreW: (Boolean) -> Unit,
    onAlbumsCount: (Int) -> Unit, onPhotoWeeks: (Float) -> Unit,
    onGearSony: (Boolean) -> Unit, onGearNikon: (Boolean) -> Unit, onGearDrone: (Boolean) -> Unit,
    onDecorMaterialFresh: (Boolean) -> Unit, onDecorMaterialImported: (Boolean) -> Unit, onDecorMaterialFaux: (Boolean) -> Unit, onDecorStartingStage: (String) -> Unit, onDecorSetupHours: (String) -> Unit, onDecorDim: (String) -> Unit,
    onMakeupHd: (String) -> Unit, onMakeupAirbrush: (String) -> Unit, onMakeupTrial: (Boolean) -> Unit, onMakeupTrialAbsorb: (Boolean) -> Unit,
    onAdvancePercent: (String) -> Unit, onCancellation: (String) -> Unit
) {
    val haptic = LocalHapticFeedback.current
    Text("Category Specific Parameters", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)

    when (category) {
        "Banquet" -> {
            Text("🏛️ " + venueType.name + " Configuration", fontWeight = FontWeight.Bold, color = ChampagneGold)

            when (venueType) {
                VenueType.BanquetHall -> {
                    OutlinedTextField(value = acCapacity, onValueChange = onAcCapacity, label = { Text("Seating Capacity") }, modifier = Modifier.fillMaxWidth())
                    OutlinedTextField(value = platePriceVeg, onValueChange = onPlateVeg, label = { Text("Veg Price per Plate (₹)") }, modifier = Modifier.fillMaxWidth())
                    OutlinedTextField(value = platePriceNonVeg, onValueChange = onPlateNonVeg, label = { Text("Non-Veg Price per Plate (₹)") }, modifier = Modifier.fillMaxWidth())
                }
                VenueType.MarriageGardenLawn -> {
                    OutlinedTextField(value = totalLawnArea, onValueChange = onTotalLawn, label = { Text("Total Lawn Area (Sq. Ft.)") }, modifier = Modifier.fillMaxWidth())
                    AntigravityBouncySwitch(title = "Rain Protection Waterproofing Covers", checked = rainProtection, onCheckedChange = onRainProtection)
                }
                VenueType.WeddingResort -> {
                    OutlinedTextField(value = roomConfigurations, onValueChange = onRoomConfig, label = { Text("Villas / Suite Configurations") }, modifier = Modifier.fillMaxWidth())
                    AntigravityBouncySwitch(title = "Poolside Party Venues", checked = poolSideEvent, onCheckedChange = onPoolside)
                }
                VenueType.PalaceFort -> {
                    OutlinedTextField(value = heritageCategory, onValueChange = onHeritage, label = { Text("Palace Classification Grade") }, modifier = Modifier.fillMaxWidth())
                    AntigravityBouncySwitch(title = "Royal Carriage Entry Facilities", checked = royalEntryCarriage, onCheckedChange = onRoyalEntry)
                }
                VenueType.KalyanaMandapam -> {
                    AntigravityBouncySwitch(title = "Traditional Wooden Stage setups", checked = traditionalLayout, onCheckedChange = onTradLayout)
                    AntigravityBouncySwitch(title = "Standard Pooja utilities included", checked = poojaPackage, onCheckedChange = onPoojaPack)
                }
                VenueType.CommunityTempleHall -> {
                    OutlinedTextField(value = basicRentModel, onValueChange = onRentModel, label = { Text("Temple Booking Model (Standard)") }, modifier = Modifier.fillMaxWidth())
                }
                VenueType.LuxuryHotel -> {
                    OutlinedTextField(value = starRating, onValueChange = onStarRating, label = { Text("Hotel Classification Stars") }, modifier = Modifier.fillMaxWidth())
                    OutlinedTextField(value = soundproofCurfew, onValueChange = onCurfew, label = { Text("Sound curfew timings") }, modifier = Modifier.fillMaxWidth())
                }
            }

            AntigravityBouncySwitch(title = "In-House Green Rooms", checked = hasRooms, onCheckedChange = onHasRooms)
            if (hasRooms) {
                OutlinedTextField(value = roomCount, onValueChange = onRoomCount, label = { Text("Green Rooms Count") }, modifier = Modifier.fillMaxWidth())
            }
            OutlinedTextField(value = parkingCount, onValueChange = onParking, label = { Text("Valet Parking Capacity") }, modifier = Modifier.fillMaxWidth())
            AntigravityBouncySwitch(title = "Alcohol / Liquor allowed on site", checked = alcoholAllowed, onCheckedChange = onAlcohol)
            OutlinedTextField(value = decorPolicy, onValueChange = onDecorPol, label = { Text("Decor Policy (e.g. Panel decorators)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = djPolicy, onValueChange = onDjPol, label = { Text("DJ Restrictions Policy") }, modifier = Modifier.fillMaxWidth())
        }

        "Catering" -> {
            Text("🍽️ Premium Catering Super-Form", fontWeight = FontWeight.Bold, color = ChampagneGold)

            Column {
                OutlinedTextField(
                    value = cateringFssaiInput,
                    onValueChange = onFssai,
                    label = { Text("FSSAI License Number (14 Digits)") },
                    isError = fssaiError,
                    modifier = Modifier.fillMaxWidth()
                )
                if (fssaiError) {
                    Text(
                        "⚠️ Valid 14-digit FSSAI Number required to activate catering.",
                        color = WarmRed,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(top = 4.dp)
                    )
                }
            }

            Text("Gastronomy Plate Rates Matrices", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                OutlinedTextField(value = platePriceVegStd, onValueChange = onPlateVegStd, label = { Text("Standard Veg Rate (₹)") }, modifier = Modifier.weight(1f))
                OutlinedTextField(value = platePriceVegDlx, onValueChange = onPlateVegDlx, label = { Text("Deluxe Veg Rate (₹)") }, modifier = Modifier.weight(1f))
            }
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                OutlinedTextField(value = platePriceNonVegStd, onValueChange = onPlateNonVegStd, label = { Text("Standard Non-Veg (₹)") }, modifier = Modifier.weight(1f))
                OutlinedTextField(value = platePriceNonVegDlx, onValueChange = onPlateNonVegDlx, label = { Text("Deluxe Non-Veg (₹)") }, modifier = Modifier.weight(1f))
            }

            OutlinedTextField(value = cateringMinGuests, onValueChange = onMinGuests, label = { Text("Minimum Guest Plate count") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = waitstaffCount, onValueChange = onWaitstaff, label = { Text("Assigned Waitstaff headcount") }, modifier = Modifier.fillMaxWidth())
            AntigravityBouncySwitch(title = "Premium crockery, cutlery & linen included", checked = includesCrockery, onCheckedChange = onCrockery)

            Text("Standard Cuisines", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            FlowRow(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf("South Indian", "North Indian", "Continental", "Jain Specials", "Mughlai").forEach { cuisine ->
                    val hasIt = cateringCuisines.contains(cuisine)
                    FilterChip(
                        selected = hasIt,
                        onClick = {
                            if (hasIt) cateringCuisines.remove(cuisine) else cateringCuisines.add(cuisine)
                        },
                        label = { Text(cuisine) }
                    )
                }
            }

            if (cateringCuisines.contains("Jain Specials")) {
                Surface(
                    color = SandGold,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Text("Jain Dietary Protections", fontWeight = FontWeight.Black, fontSize = 12.sp, color = Color(0xFF92400E))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = separateJainKitchenConfirm, onCheckedChange = onJainConfirm)
                            Text("I confirm strictly separate cooking workflows (no garlic/onion, separate prep zone).", fontSize = 11.sp, color = Color(0xFF92400E))
                        }
                    }
                }
            }
        }

        "Photography" -> {
            Text("📷 strict Bundled Photography Tier Builder", fontWeight = FontWeight.Bold, color = ChampagneGold)

            Text("Eliminate custom quotes. Configure clean SaaS-style packages.", fontSize = 12.sp, color = SlateGray)

            // Essential Bundle Card
            Card(colors = CardDefaults.cardColors(containerColor = SoftMist), shape = RoundedCornerShape(16.dp)) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("Tier 1: Essential Wedding Bundle", fontWeight = FontWeight.Black, fontSize = 14.sp, color = RoyalNavy)
                    OutlinedTextField(value = pPriceTier1, onValueChange = onPhotoTier1Price, label = { Text("Total Bundle Price (₹)") }, modifier = Modifier.fillMaxWidth())
                    
                    Text("Deliverables included:", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = SlateGray)
                    Row(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Checkbox(checked = pT1TradPhoto, onCheckedChange = onPhotoT1Trad)
                        Text("Traditional Photo", fontSize = 11.sp)
                        Checkbox(checked = pT1TradVideo, onCheckedChange = onPhotoT1TradV)
                        Text("Traditional Video", fontSize = 11.sp)
                    }
                }
            }

            // Premium Bundle (Bestseller) Card
            Card(
                colors = CardDefaults.cardColors(containerColor = SandGold.copy(alpha = 0.3f)),
                shape = RoundedCornerShape(16.dp),
                border = BorderStroke(1.5.dp, ChampagneGold)
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                        Text("Tier 2: Premium Cinematic Bundle", fontWeight = FontWeight.Black, fontSize = 14.sp, color = RoyalNavy)
                        Surface(color = ChampagneGold, shape = RoundedCornerShape(4.dp)) {
                            Text("BESTSELLER", color = Color.White, fontWeight = FontWeight.Black, fontSize = 9.sp, modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp))
                        }
                    }
                    OutlinedTextField(value = pPriceTier2, onValueChange = onPhotoTier2Price, label = { Text("Total Bundle Price (₹)") }, modifier = Modifier.fillMaxWidth())

                    Text("Deliverables included:", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = SlateGray)
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = pT2TradPhoto, onCheckedChange = onPhotoT2Trad)
                            Text("Traditional Photo", fontSize = 11.sp)
                        }
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = pT2CandidPhoto, onCheckedChange = onPhotoT2Candid)
                            Text("Candid Photo", fontSize = 11.sp)
                        }
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = pT2Teaser, onCheckedChange = onPhotoT2Tease)
                            Text("Cinematic Teaser", fontSize = 11.sp)
                        }
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = pT2Drone, onCheckedChange = onPhotoT2Drone)
                            Text("Drone/Aerial", fontSize = 11.sp)
                        }
                    }
                }
            }

            // Royal Elite Card
            Card(colors = CardDefaults.cardColors(containerColor = RoyalNavy), shape = RoundedCornerShape(16.dp)) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text("Tier 3: Royal Elite Bundle", fontWeight = FontWeight.Black, fontSize = 14.sp, color = ChampagneGold)
                    OutlinedTextField(
                        value = pPriceTier3,
                        onValueChange = onPhotoTier3Price,
                        label = { Text("Total Bundle Price (₹)", color = ChampagneGold) },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White,
                            focusedBorderColor = ChampagneGold
                        )
                    )

                    Text("Deliverables included:", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = ChampagneGold)
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = pT3TradPhoto, onCheckedChange = onPhotoT3Trad)
                            Text("Traditional Photo", fontSize = 11.sp, color = Color.White)
                        }
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = pT3CandidPhoto, onCheckedChange = onPhotoT3Candid)
                            Text("Candid Photo", fontSize = 11.sp, color = Color.White)
                        }
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = pT3Teaser, onCheckedChange = onPhotoT3Tease)
                            Text("Cinematic Teaser", fontSize = 11.sp, color = Color.White)
                        }
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = pT3Drone, onCheckedChange = onPhotoT3Drone)
                            Text("Drone/Aerial", fontSize = 11.sp, color = Color.White)
                        }
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = pT3PreWedding, onCheckedChange = onPhotoT3PreW)
                            Text("Pre-Wedding Shoot", fontSize = 11.sp, color = Color.White)
                        }
                    }
                }
            }

            Text("Standard Albums: $albumsCountStepper Hardbound", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
            Slider(
                value = albumsCountStepper.toFloat(),
                onValueChange = { onAlbumsCount(it.toInt()) },
                valueRange = 0f..5f,
                steps = 4,
                colors = SliderDefaults.colors(activeTrackColor = EmeraldGreen, thumbColor = ChampagneGold)
            )

            Text("Final Delivery Timeline: ${photoDeliveryWeeksSlider.toInt()} weeks", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
            Slider(
                value = photoDeliveryWeeksSlider,
                onValueChange = onPhotoWeeks,
                valueRange = 2f..12f,
                colors = SliderDefaults.colors(activeTrackColor = EmeraldGreen, thumbColor = ChampagneGold)
            )

            Text("Justify Premium Tier Rates: Elite Hardware Tagging", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
            Row(verticalAlignment = Alignment.CenterVertically) {
                Checkbox(checked = gearSonyA1, onCheckedChange = onGearSony)
                Text("Sony A1 Dual-Body Camera kit", fontSize = 12.sp)
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Checkbox(checked = gearNikonZ9, onCheckedChange = onGearNikon)
                Text("Nikon Z9 Mirrorless High-speed rig", fontSize = 12.sp)
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Checkbox(checked = gearHeavyDrone, onCheckedChange = onGearDrone)
                Text("DJI Inspire Cine Heavy-lift Drone", fontSize = 12.sp)
            }
        }

        "Decorator" -> {
            Text("🌸 Decorator Specialization Form", fontWeight = FontWeight.Bold, color = ChampagneGold)

            OutlinedTextField(value = decorStartingStagePrice, onValueChange = onDecorStartingStage, label = { Text("Stage Setup Starting Budget (₹)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = decorSetupTimeHours, onValueChange = onDecorSetupHours, label = { Text("Average setup time required (Hours)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = decorDimensions, onValueChange = onDecorDim, label = { Text("Standard Stage Dimensions (e.g. 30x40 ft)") }, modifier = Modifier.fillMaxWidth())

            Text("Theme Specializations", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf("Floral Canopy", "Acrylic Mandap", "Traditional Mandap", "Bohemian Wedding", "Fairy-tale Theme").forEach { theme ->
                    val isChecked = decoratorThemes.contains(theme)
                    FilterChip(selected = isChecked, onClick = { if (isChecked) decoratorThemes.remove(theme) else decoratorThemes.add(theme) }, label = { Text(theme) })
                }
            }

            Text("Floral & Materials Sourcing", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            AntigravityBouncySwitch(title = "100% Fresh Local flowers", checked = decorMaterialFresh, onCheckedChange = onDecorMaterialFresh)
            AntigravityBouncySwitch(title = "Exotic Imported Flowers (e.g. Dutch Tulips)", checked = decorMaterialImported, onCheckedChange = onDecorMaterialImported)
            AntigravityBouncySwitch(title = "Premium Faux / Silks materials", checked = decorMaterialFaux, onCheckedChange = onDecorMaterialFaux)
        }

        "Makeup" -> {
            Text("💄 Bridal Makeup & Styling specs", fontWeight = FontWeight.Bold, color = ChampagneGold)

            OutlinedTextField(value = makeupPriceHd, onValueChange = onMakeupHd, label = { Text("HD Bridal Makeup Rate (₹)") }, modifier = Modifier.fillMaxWidth())
            OutlinedTextField(value = makeupPriceAirbrush, onValueChange = onMakeupAirbrush, label = { Text("Airbrush Bridal Makeup Rate (₹)") }, modifier = Modifier.fillMaxWidth())

            Text("Assigned Brand Inventory checkboxes:", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf("MAC", "Huda Beauty", "NARS", "Kryolan", "Estee Lauder").forEach { brand ->
                    val hasIt = makeupBrands.contains(brand)
                    FilterChip(selected = hasIt, onClick = { if (hasIt) makeupBrands.remove(brand) else makeupBrands.add(brand) }, label = { Text(brand) })
                }
            }

            AntigravityBouncySwitch(title = "Paid Bridal Trials Available", checked = makeupPaidTrialAvailable, onCheckedChange = onMakeupTrial)
            if (makeupPaidTrialAvailable) {
                AntigravityBouncySwitch(title = "Trial fee absorbed into Escrow total upon booking", checked = makeupTrialFeeAbsorbed, onCheckedChange = onMakeupTrialAbsorb)
            }
        }
    }

    Divider(color = Color.LightGray.copy(alpha = 0.3f), modifier = Modifier.padding(vertical = 12.dp))
    Text("Universal Escrow Booking Policies", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
    OutlinedTextField(value = paymentAdvancePercent, onValueChange = onAdvancePercent, label = { Text("Advance Slot Lock Percent (Min. 20%)") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = cancellationPolicy, onValueChange = onCancellation, label = { Text("Cancellation terms (e.g. Fully Refundable 30d)") }, modifier = Modifier.fillMaxWidth())
}

// ─── STEP 5: MEDIA INGESTION & COMPARATIVE TRANSFORMATIONS ───────────────────
@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
@Composable
fun Step5MediaIngestion(
    coverUrl: String,
    generalPhotos: MutableList<String>,
    videoUrl: String,
    beforeUrl: String,
    afterUrl: String,
    resolutionError: String,
    selectedEventTags: MutableList<String>,
    onCoverUrl: (String) -> Unit,
    onVideoUrl: (String) -> Unit,
    onBeforeUrl: (String) -> Unit,
    onAfterUrl: (String) -> Unit,
    onResolutionCheck: (String) -> Unit
) {
    val context = LocalContext.current
    Text("Portfolio Ingestion Engine", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
    Text("Enforce resolution guards and upload rich transformations for client discovery.", fontSize = 14.sp, color = SlateGray)

    OutlinedTextField(
        value = coverUrl,
        onValueChange = {
            onCoverUrl(it)
            onResolutionCheck(it)
        },
        label = { Text("Primary Cover Photo URL") },
        modifier = Modifier.fillMaxWidth()
    )

    if (resolutionError.isNotBlank()) {
        Surface(
            color = SandGold,
            shape = RoundedCornerShape(12.dp)
        ) {
            Text(
                text = resolutionError,
                color = Color(0xFFB45309),
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(12.dp)
            )
        }
    }

    Text("General Gallery Photos", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
    LazyRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        item {
            Surface(
                onClick = {
                    val mockImages = listOf(
                        "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=600&auto=format&fit=crop",
                        "https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?q=80&w=600&auto=format&fit=crop",
                        "https://images.unsplash.com/photo-1519225495810-7517c2440bce?q=80&w=600&auto=format&fit=crop"
                    )
                    generalPhotos.add(mockImages.random())
                    Toast.makeText(context, "Added mock high-res portfolio photo!", Toast.LENGTH_SHORT).show()
                },
                shape = RoundedCornerShape(12.dp),
                color = SoftMist,
                border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.5f)),
                modifier = Modifier.size(80.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.Center) {
                    Icon(Icons.Default.AddAPhoto, null, tint = EmeraldGreen)
                    Text("Add", fontSize = 11.sp, color = SlateGray)
                }
            }
        }

        items(generalPhotos) { url ->
            Box(modifier = Modifier.size(80.dp).clip(RoundedCornerShape(12.dp))) {
                Image(
                    imageVector = Icons.Default.Image,
                    contentDescription = null,
                    modifier = Modifier.fillMaxSize().background(Color.LightGray)
                )
                Surface(
                    onClick = { generalPhotos.remove(url) },
                    shape = CircleShape,
                    color = WarmRed,
                    modifier = Modifier.align(Alignment.TopEnd).padding(4.dp).size(20.dp)
                ) {
                    Icon(Icons.Default.Close, null, tint = Color.White, modifier = Modifier.padding(2.dp))
                }
            }
        }
    }

    // Before/After Transformations COMPARATIVE SLIDER (Makeup/Decorators)
    Text("📸 sliding Before / After Comparative Transform", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
        OutlinedTextField(value = beforeUrl, onValueChange = onBeforeUrl, label = { Text("Pre-Setup (Before) Image URL") }, modifier = Modifier.weight(1f))
        OutlinedTextField(value = afterUrl, onValueChange = onAfterUrl, label = { Text("Premium Final (After) Image URL") }, modifier = Modifier.weight(1f))
    }

    // Gorgeous interactive transformation sliding box
    var sliderRatio by remember { mutableStateOf(0.5f) }
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(200.dp)
            .clip(RoundedCornerShape(16.dp))
            .background(Color.DarkGray)
            .pointerInput(Unit) {
                detectHorizontalDragGestures { change, dragAmount ->
                    change.consume()
                    val newRatio = (sliderRatio + dragAmount / size.width).coerceIn(0f, 1f)
                    sliderRatio = newRatio
                }
            }
    ) {
        // After Image (Base)
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("AFTER SETUP (Completed premium luxury Mandap)", color = ChampagneGold, fontWeight = FontWeight.Black, fontSize = 12.sp)
        }

        // Before Image (Overlay clipped on ratio)
        Box(
            modifier = Modifier
                .fillMaxHeight()
                .fillMaxWidth(sliderRatio)
                .background(Color.Black.copy(alpha = 0.8f)),
            contentAlignment = Alignment.Center
        ) {
            Text("BEFORE SETUP", color = Color.White.copy(alpha = 0.6f), fontWeight = FontWeight.Bold, fontSize = 12.sp)
        }

        // Draggable vertical split slider bar
        Box(
            modifier = Modifier
                .fillMaxHeight()
                .width(4.dp)
                .background(ChampagneGold)
                .align(Alignment.CenterStart)
                .offset(x = 350.dp * sliderRatio) // Approximated width offset
        )
    }

    Text("Contextual discovery Tagging", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
    FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        listOf("Muhurtham", "Haldi", "Mehendi", "Reception", "Sangeet").forEach { tag ->
            val hasIt = selectedEventTags.contains(tag)
            FilterChip(
                selected = hasIt,
                onClick = { if (hasIt) selectedEventTags.remove(tag) else selectedEventTags.add(tag) },
                label = { Text(tag) }
            )
        }
    }

    OutlinedTextField(value = videoUrl, onValueChange = onVideoUrl, label = { Text("Direct Vimeo / YouTube walkthrough Tour URL") }, modifier = Modifier.fillMaxWidth())
}

// ─── STEP 6: BANKING CREDENTIALS & ESCROW SLA LOCK ───────────────────────────
@Composable
fun Step6EscrowSla(
    bankName: String,
    bankAccountHolderName: String,
    bankAccountNumber: String,
    bankIfscCode: String,
    upiId: String,
    slaAccepted: Boolean,
    onBankName: (String) -> Unit,
    onAccountHolder: (String) -> Unit,
    onAccountNumber: (String) -> Unit,
    onIfscCode: (String) -> Unit,
    onUpiId: (String) -> Unit,
    onSlaAccepted: (Boolean) -> Unit
) {
    Text("Escrow Settlers Payout Credentials", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
    Text("Add your banking credentials. Payout nodes release funds automatically based on escrow milestones.", fontSize = 14.sp, color = SlateGray)

    OutlinedTextField(value = bankAccountHolderName, onValueChange = onAccountHolder, label = { Text("Account Holder Name") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = bankName, onValueChange = onBankName, label = { Text("Bank Name") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = bankAccountNumber, onValueChange = onAccountNumber, label = { Text("Bank Account Number") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = bankIfscCode, onValueChange = onIfscCode, label = { Text("IFSC Code") }, modifier = Modifier.fillMaxWidth())
    OutlinedTextField(value = upiId, onValueChange = onUpiId, label = { Text("Direct UPI ID Payout VPA") }, modifier = Modifier.fillMaxWidth())

    Divider(color = Color.LightGray.copy(alpha = 0.3f), modifier = Modifier.padding(vertical = 12.dp))

    // SLA Contract agreement details
    Text("GoMandap Escrow Service Level Agreement (SLA)", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
    
    Surface(
        color = RoyalNavy,
        shape = RoundedCornerShape(18.dp),
        border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.4f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(modifier = Modifier.padding(18.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Text("📜 Partner SLA Covenants:", color = ChampagneGold, fontWeight = FontWeight.Black, fontSize = 13.sp)
            Text(
                "1. 20% Slot Lock Deposit is released instantly to partner upon booking slot validation.\n" +
                "2. 50% Pre-Event Setup fee is locked in the escrow vault and released automatically on setup check-in day.\n" +
                "3. 30% Post-Event Approval remains held in safe custody, released strictly after the client clicks approval post-event.\n" +
                "4. 3-Hour Geo-Fenced check-in is required on site. Non-responsive partners are automatically replaced by the Standby Pool registry.",
                color = Color.White.copy(alpha = 0.8f),
                fontSize = 11.sp,
                lineHeight = 16.sp
            )
            
            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
                Checkbox(
                    checked = slaAccepted,
                    onCheckedChange = onSlaAccepted,
                    colors = CheckboxDefaults.colors(checkmarkColor = RoyalNavy, checkedColor = ChampagneGold)
                )
                Text(
                    text = "I accept the GoMandap Q-Commerce Escrow SLA. Lock my draft profile for review.",
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 10.sp,
                    modifier = Modifier.weight(1f)
                )
            }
        }
    }
}

// ─── CUSTOM ANTIGRAVITY COMPONENT ALIAS WIDGETS (Self-Contained) ─────────────
@Composable
fun AntigravityBouncySwitch(
    title: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    val haptic = LocalHapticFeedback.current
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = title, fontWeight = FontWeight.SemiBold, fontSize = 13.sp, color = RoyalNavy)
        Switch(
            checked = checked,
            onCheckedChange = {
                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                onCheckedChange(it)
            },
            colors = SwitchDefaults.colors(
                checkedThumbColor = Color.White,
                checkedTrackColor = EmeraldGreen,
                uncheckedThumbColor = SlateGray,
                uncheckedTrackColor = SlateGray.copy(alpha = 0.15f)
            )
        )
    }
}
