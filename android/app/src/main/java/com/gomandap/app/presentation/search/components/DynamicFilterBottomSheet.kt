@file:OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
package com.gomandap.app.presentation.search.components

import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.domain.model.MandapStyle
import com.gomandap.app.domain.model.PhotographyStyle
import com.gomandap.app.domain.model.VenueType
import com.gomandap.app.presentation.search.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay

private val RoyalNavy     = Color(0xFF0F172A)
private val EmeraldGreen  = Color(0xFF10B981)
private val ChampagneGold = Color(0xFFDFBA73)
private val DarkGold      = Color(0xFFC59A48)
private val SlateGray     = Color(0xFF64748B)
private val IceBg         = Color(0xFFF8FAFC)

// Accent colors for each category
private val VenueAccent      = EmeraldGreen
private val PhotoAccent      = Color(0xFF8B5CF6) // Purple
private val MakeupAccent     = Color(0xFFF472B6) // Pink
private val MandapAccent     = ChampagneGold
private val CateringAccent   = Color(0xFFF59E0B) // Amber

private fun formatRupees(value: Float): String {
    return when {
        value >= 100000f -> "₹${"%.1f".format(value / 100000)}L"
        value >= 1000f   -> "₹${"%.0f".format(value / 1000)}k"
        else             -> "₹${value.toInt()}"
    }
}

@Composable
fun DynamicFilterBottomSheet(
    viewModel: FilterViewModel,
    onDismiss: () -> Unit
) {
    val CategoryFilterState by viewModel.activeFilterState.collectAsState()
    val matchingCount by viewModel.matchingResultsCount.collectAsState()
    val currentCategory by viewModel.currentCategory.collectAsState()

    // Animate result count changes with a rolling number effect
    val animatedCount by animateIntAsState(
        targetValue = matchingCount,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium),
        label = "resultCountAnim"
    )

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor   = Color.Transparent,
        dragHandle       = null,
        shape            = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(
                    brush = Brush.verticalGradient(
                        listOf(Color.White.copy(alpha = 0.97f), IceBg)
                    ),
                    shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)
                )
        ) {
            // ── Drag Handle ──────────────────────────────────────────────────
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 12.dp, bottom = 4.dp)
            ) {
                Box(
                    modifier = Modifier
                        .width(44.dp)
                        .height(4.dp)
                        .background(RoyalNavy.copy(alpha = 0.15f), RoundedCornerShape(2.dp))
                )
            }

            // ── Header ───────────────────────────────────────────────────────
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment     = Alignment.CenterVertically
            ) {
                Text(
                    text       = "Refine Results",
                    fontSize   = 22.sp,
                    fontWeight = FontWeight.ExtraBold,
                    color      = RoyalNavy
                )
                TextButton(onClick = { viewModel.resetFilters() }) {
                    Text(text = "Reset All", color = ChampagneGold, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                }
            }

            // ── Category Selector Tabs (Scrollable for 5 categories) ─────────
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp)
                    .horizontalScroll(rememberScrollState())
                    .background(IceBg, RoundedCornerShape(14.dp))
                    .padding(4.dp),
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                listOf(
                    "Venues"      to "🏛",
                    "Photography" to "📸",
                    "Makeup"      to "💄",
                    "Mandaps"     to "🌸",
                    "Catering"    to "🍽"
                ).forEach { (cat, emoji) ->
                    val isSelected = currentCategory == cat
                    Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier
                            .width(80.dp)
                            .clip(RoundedCornerShape(10.dp))
                            .background(
                                if (isSelected) Brush.linearGradient(listOf(RoyalNavy, Color(0xFF1E293B)))
                                else Brush.linearGradient(listOf(Color.Transparent, Color.Transparent))
                            )
                    ) {
                        TextButton(
                            onClick   = { viewModel.changeCategory(cat) },
                            modifier  = Modifier.fillMaxWidth()
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(emoji, fontSize = 14.sp)
                                Text(
                                    text       = cat,
                                    fontSize   = 10.sp,
                                    fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Normal,
                                    color      = if (isSelected) Color.White else SlateGray
                                )
                            }
                        }
                    }
                }
            }

            Spacer(Modifier.height(8.dp))

            // ── Dynamic Filter Content (AnimatedContent per category) ─────
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f, fill = false)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 20.dp)
            ) {
                // Location Radar Section
                LocationRadarSection(viewModel)
                Spacer(Modifier.height(16.dp))

                AnimatedContent(
                    targetState  = CategoryFilterState,
                    transitionSpec = {
                        (fadeIn(tween(280)) + slideInHorizontally { if (targetState is CategoryFilterState.VenueFilters) -40 else 40 })
                            .togetherWith(fadeOut(tween(200)) + slideOutHorizontally { if (targetState is CategoryFilterState.VenueFilters) 40 else -40 })
                    },
                    label = "filterContentSwitch"
                ) { state ->
                    when (state) {
                        is CategoryFilterState.VenueFilters -> VenueFilterContent(state, viewModel)
                        is CategoryFilterState.PhotographyFilters -> PhotographyFilterContent(state, viewModel)
                        is CategoryFilterState.MakeupArtistFilters -> MakeupFilterContent(state, viewModel)
                        is CategoryFilterState.DecorFilters -> DecorFilterContent(state, viewModel)
                        is CategoryFilterState.CateringFilters -> CateringFilterContent(state, viewModel)
                    }
                }
            }

            Spacer(Modifier.height(12.dp))

            // ── Sticky Bottom Apply FAB with Rolling Count ───────────────────
            Box(
                modifier = Modifier
                    .padding(horizontal = 20.dp, vertical = 8.dp)
                    // Premium glow shadow behind the button
                    .drawBehind {
                        drawIntoCanvas { canvas ->
                            val paint = Paint()
                            paint.asFrameworkPaint().setShadowLayer(
                                28f, 0f, 8f,
                                EmeraldGreen.copy(alpha = 0.35f).toArgb()
                            )
                            canvas.drawRoundRect(
                                0f, 0f, size.width, size.height,
                                54f, 54f, paint
                            )
                        }
                    }
            ) {
                Button(
                    onClick = onDismiss,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(58.dp),
                    shape  = RoundedCornerShape(18.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = Color.Transparent),
                    contentPadding = PaddingValues(0.dp)
                ) {
                    Box(
                        contentAlignment = Alignment.Center,
                        modifier = Modifier
                            .fillMaxSize()
                            .background(
                                Brush.linearGradient(
                                    listOf(EmeraldGreen, Color(0xFF059669))
                                ),
                                RoundedCornerShape(18.dp)
                            )
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.Center
                        ) {
                            Text(
                                text       = "✨  Show ",
                                fontSize   = 16.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color      = Color.White
                            )
                            // Rolling vertical number animation (cash-register style)
                            AnimatedContent(
                                targetState  = animatedCount,
                                transitionSpec = {
                                    (slideInVertically { height -> -height } + fadeIn(tween(150)))
                                        .togetherWith(slideOutVertically { height -> height } + fadeOut(tween(100)))
                                        .using(SizeTransform(clip = false))
                                },
                                label = "applyBtnCountAnim"
                            ) { count ->
                                Text(
                                    text       = "$count",
                                    fontSize   = 18.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    color      = Color.White
                                )
                            }
                            Text(
                                text       = " Verified Results",
                                fontSize   = 16.sp,
                                fontWeight = FontWeight.ExtraBold,
                                color      = Color.White
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(24.dp))
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Venue Filter Pane — Enhanced with budget type, AC, valet, rooms stepper
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun VenueFilterContent(state: CategoryFilterState.VenueFilters, vm: FilterViewModel) {
    Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {

        // Budget Type selector (PerPlate vs PerDayRent)
        FilterSection("Budget Type") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    BudgetType.PerPlate   to ("🍽" to "Per Plate"),
                    BudgetType.PerDayRent to ("🏠" to "Per Day Rent")
                ).forEach { (type, pair) ->
                    val (emoji, label) = pair
                    AntigravityGlassChip(
                        label       = label,
                        selected    = state.budgetType == type,
                        onClick     = { vm.updateVenueBudgetType(type) },
                        leadingEmoji = emoji,
                        accentColor = VenueAccent
                    )
                }
            }
        }

        // Price Range (dynamic based on budget type)
        FilterSection(if (state.budgetType == BudgetType.PerPlate) "Price Per Plate" else "Venue Rent Budget") {
            AntigravityRangeSlider(
                value          = state.priceRange,
                onValueChange  = vm::updateVenuePriceRange,
                valueRange     = if (state.budgetType == BudgetType.PerPlate) 500f..5000f else 50000f..1000000f,
                labelFormatter = ::formatRupees,
                accentColor    = ChampagneGold
            )
        }

        // Guest Capacity Range
        FilterSection("Guest Capacity") {
            AntigravityRangeSlider(
                value          = state.guestCapacity,
                onValueChange  = vm::updateVenueCapacity,
                valueRange     = 50f..3000f,
                labelFormatter = { "${it.toInt()} guests" },
                accentColor    = VenueAccent
            )
        }

        FilterSection("Ratings") {
            AntigravityRangeSlider(
                value = state.ratingRange,
                onValueChange = vm::updateVenueRatingRange,
                valueRange = 0f..5f,
                labelFormatter = { rating ->
                    if (rating == 0f) "Any" else "${rating.toInt()}★+"
                },
                accentColor = ChampagneGold
            )
        }

        FilterSection("Food Type") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    Triple(VenueFoodType.VegOnly, "🥗", "Veg Only"),
                    Triple(VenueFoodType.NonVeg, "🍛", "Non-Veg"),
                    Triple(VenueFoodType.Both, "🍽", "Veg + Non-Veg")
                ).forEach { (foodType, emoji, label) ->
                    AntigravityGlassChip(
                        label = label,
                        selected = state.foodType == foodType,
                        onClick = { vm.updateVenueFoodType(foodType) },
                        leadingEmoji = emoji,
                        accentColor = VenueAccent
                    )
                }
            }
        }

        // Venue Type chips (including Farmhouse)
        FilterSection("Venue Type") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                for ((type, emoji) in listOf(
                    VenueType.BanquetHall          to "🏢",
                    VenueType.MarriageGardenLawn   to "🌿",
                    VenueType.WeddingResort        to "🏨",
                    VenueType.PalaceFort           to "👑",
                    VenueType.KalyanaMandapam      to "🏛️",
                    VenueType.CommunityTempleHall to "🛕",
                    VenueType.LuxuryHotel          to "⭐"
                )) {
                    AntigravityGlassChip(
                        label       = type.name,
                        selected    = state.selectedVenueTypes.contains(type),
                        onClick     = { vm.toggleVenueType(type) },
                        leadingEmoji = emoji
                    )
                }
            }
        }

        // Rooms Required (FloatingStepper)
        FilterSection("Rooms Required") {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Overnight Rooms", fontWeight = FontWeight.SemiBold, fontSize = 14.sp, color = RoyalNavy)
                    Text("For guests & family", fontSize = 11.sp, color = SlateGray)
                }
                FloatingStepper(
                    value = state.roomsRequired,
                    onValueChange = vm::updateVenueRoomsRequired,
                    range = 0..100,
                    accentColor = VenueAccent
                )
            }
        }

        // Amenity Switches
        FilterSection("Amenities & Policies") {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                AntigravityBouncySwitch(
                    title           = "Auspicious Muhurtham Dates Only",
                    subtitle        = "Filter venues by high-demand wedding dates",
                    checked         = state.isMuhurthamAvailable,
                    onCheckedChange = vm::toggleVenueMuhurtham,
                    accentColor     = VenueAccent
                )
                AntigravityBouncySwitch(
                    title           = "Air Conditioned",
                    subtitle        = "Fully AC indoor venue spaces",
                    checked         = state.isAcOnly,
                    onCheckedChange = vm::toggleVenueAc
                )
                AntigravityBouncySwitch(
                    title           = "Rooms & Suites",
                    subtitle        = "Overnight stay available on-site",
                    checked         = state.isRoomsAvailable,
                    onCheckedChange = vm::toggleVenueRooms
                )
                AntigravityBouncySwitch(
                    title           = "Valet Parking",
                    subtitle        = "Complimentary valet service for guests",
                    checked         = state.isValetParking,
                    onCheckedChange = vm::toggleVenueValet
                )
                AntigravityBouncySwitch(
                    title           = "Liquor Allowed",
                    subtitle        = "Venue permits alcohol service",
                    checked         = state.isAlcoholAllowed,
                    onCheckedChange = vm::toggleVenueAlcohol
                )
                AntigravityBouncySwitch(
                    title           = "Strictly Vegetarian Venue",
                    subtitle        = "Strictly veg-only culinary venue policies",
                    checked         = state.isVegOnlyVenue,
                    onCheckedChange = vm::toggleVenueVegOnly,
                    accentColor     = VenueAccent
                )
                AntigravityBouncySwitch(
                    title           = "Outside Decorators Allowed",
                    subtitle        = "Bring your own decorator setup",
                    checked         = state.isOutsideDecorAllowed,
                    onCheckedChange = vm::toggleVenueOutsideDecor,
                    accentColor     = ChampagneGold
                )
                AntigravityBouncySwitch(
                    title           = "Outside DJ Allowed",
                    subtitle        = "Outside sound systems and DJs permitted",
                    checked         = state.isOutsideDjAllowed,
                    onCheckedChange = vm::toggleVenueOutsideDj,
                    accentColor     = ChampagneGold
                )
                AntigravityBouncySwitch(
                    title           = "Outside Catering",
                    subtitle        = "Bring your own caterer to the venue",
                    checked         = state.isOutsideCateringAllowed,
                    onCheckedChange = vm::toggleVenueOutsideCatering,
                    accentColor     = ChampagneGold
                )
                AntigravityBouncySwitch(
                    title           = "In-House Decor Only",
                    subtitle        = "Vendor mandates their own decor team",
                    checked         = state.isInHouseDecorOnly,
                    onCheckedChange = vm::toggleVenueDecor
                )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Photography Filter Pane — Enhanced with PreWedding style + deliverable chips
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun PhotographyFilterContent(state: CategoryFilterState.PhotographyFilters, vm: FilterViewModel) {
    Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {
        // Style chips (including PreWedding)
        FilterSection("Shooting Style") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    PhotographyStyle.Cinematic   to "🎬",
                    PhotographyStyle.Candid      to "📸",
                    PhotographyStyle.Drone       to "🚁",
                    PhotographyStyle.Traditional to "🎞",
                    PhotographyStyle.PreWedding  to "💑"
                ).forEach { (style, emoji) ->
                    AntigravityGlassChip(
                        label       = style.name,
                        selected    = state.selectedStyles.contains(style),
                        onClick     = { vm.togglePhotographyStyle(style) },
                        leadingEmoji = emoji,
                        accentColor = PhotoAccent
                    )
                }
            }
        }

        // Deliverables as GlassChips instead of plain switches
        FilterSection("Deliverables") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    DeliverableType.TeaserReel     to ("🎥" to "Teaser Reel"),
                    DeliverableType.RawFootage     to ("📀" to "Raw Footage"),
                    DeliverableType.HardcoverAlbum to ("📕" to "Photo Album")
                ).forEach { (deliverable, pair) ->
                    val (emoji, label) = pair
                    AntigravityGlassChip(
                        label       = label,
                        selected    = state.selectedDeliverables.contains(deliverable),
                        onClick     = { vm.togglePhotographyDeliverable(deliverable) },
                        leadingEmoji = emoji,
                        accentColor = PhotoAccent
                    )
                }
            }
        }

        // Per-day budget
        FilterSection("Budget Per Day") {
            AntigravityRangeSlider(
                value          = state.budgetPerDay,
                onValueChange  = vm::updatePhotographyBudgetPerDay,
                valueRange     = 15000f..300000f,
                labelFormatter = ::formatRupees,
                accentColor    = PhotoAccent
            )
        }

        FilterSection("Team & Travel Constraints") {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                AntigravityBouncySwitch(
                    title           = "Outstation Travel Included",
                    subtitle        = "No travel/stay surcharges for outstation slots",
                    checked         = state.isOutstationTravelIncluded,
                    onCheckedChange = vm::togglePhotographyTravel,
                    accentColor     = PhotoAccent
                )
                AntigravityBouncySwitch(
                    title           = "Full Multi-Day Wedding Package",
                    subtitle        = "Covers Mehendi, Sangeet, Wedding & Reception",
                    checked         = state.isFullWeddingPackage,
                    onCheckedChange = vm::togglePhotographyFullPackage,
                    accentColor     = PhotoAccent
                )
            }
        }

        FilterSection("Camera Crew Size") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    "Any", "Small (<3)", "Standard (3-5)", "Large (5+)"
                ).forEach { size ->
                    AntigravityGlassChip(
                        label       = size,
                        selected    = state.teamSizeOption == size,
                        onClick     = { vm.updatePhotographyTeamSize(size) },
                        accentColor = PhotoAccent
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Makeup Artist Filter Pane — NEW
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun MakeupFilterContent(state: CategoryFilterState.MakeupArtistFilters, vm: FilterViewModel) {
    Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {

        // Session Budget
        FilterSection("Session Budget") {
            AntigravityRangeSlider(
                value          = state.budgetPerSession,
                onValueChange  = vm::updateMakeupBudget,
                valueRange     = 5000f..80000f,
                labelFormatter = ::formatRupees,
                accentColor    = MakeupAccent
            )
        }

        // Makeup Type chips
        FilterSection("Makeup Style") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    MakeupType.Airbrush      to ("💨" to "Airbrush"),
                    MakeupType.HDMakeup      to ("✨" to "HD Makeup"),
                    MakeupType.RegularBridal to ("💍" to "Regular Bridal")
                ).forEach { (type, pair) ->
                    val (emoji, label) = pair
                    AntigravityGlassChip(
                        label       = label,
                        selected    = state.selectedMakeupTypes.contains(type),
                        onClick     = { vm.toggleMakeupType(type) },
                        leadingEmoji = emoji,
                        accentColor = MakeupAccent
                    )
                }
            }
        }

        // Services & Add-ons
        FilterSection("Services & Add-ons") {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                AntigravityBouncySwitch(
                    title           = "Hair Styling Included",
                    subtitle        = "Professional styling with makeup package",
                    checked         = state.isHairStylingIncluded,
                    onCheckedChange = vm::toggleMakeupHair,
                    accentColor     = MakeupAccent
                )
                AntigravityBouncySwitch(
                    title           = "Saree/Lehenga Draping",
                    subtitle        = "Expert draping assistance included",
                    checked         = state.isDrapingIncluded,
                    onCheckedChange = vm::toggleMakeupDraping,
                    accentColor     = MakeupAccent
                )
                AntigravityBouncySwitch(
                    title           = "Paid Trial Available",
                    subtitle        = "Pre-wedding trial session offered",
                    checked         = state.isPaidTrialAvailable,
                    onCheckedChange = vm::toggleMakeupTrial,
                    accentColor     = MakeupAccent
                )
                AntigravityBouncySwitch(
                    title           = "Groom Styling Included",
                    subtitle        = "Basic Groom styling/touch-up package included",
                    checked         = state.isGroomMakeupIncluded,
                    onCheckedChange = vm::toggleMakeupGroom,
                    accentColor     = MakeupAccent
                )
            }
        }

        FilterSection("Family Member Makeovers") {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Family Members Makeup", fontWeight = FontWeight.SemiBold, fontSize = 14.sp, color = RoyalNavy)
                    Text("Add makeovers for bridesmaid/family", fontSize = 11.sp, color = SlateGray)
                }
                FloatingStepper(
                    value = state.familyMakeupCount,
                    onValueChange = vm::updateMakeupFamilyCount,
                    range = 0..20,
                    accentColor = MakeupAccent
                )
            }
        }

        FilterSection("Cosmetic Brands Used") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    "MAC", "Huda Beauty", "Kryolan", "Chanel"
                ).forEach { brand ->
                    AntigravityGlassChip(
                        label       = brand,
                        selected    = state.selectedBrands.contains(brand),
                        onClick     = { vm.toggleMakeupBrand(brand) },
                        accentColor = MakeupAccent
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Decor & Mandap Filter Pane — Enhanced with budget range + setup location
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun DecorFilterContent(state: CategoryFilterState.DecorFilters, vm: FilterViewModel) {
    Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {

        // Budget Range
        FilterSection("Decor Budget") {
            AntigravityRangeSlider(
                value          = state.budgetRange,
                onValueChange  = vm::updateDecorBudgetRange,
                valueRange     = 20000f..500000f,
                labelFormatter = ::formatRupees,
                accentColor    = MandapAccent
            )
        }

        // Mandap style chips – visually rich with distinct colors
        FilterSection("Mandap Style") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    MandapStyle.Floral      to ("🌸" to Color(0xFFF472B6)),
                    MandapStyle.Acrylic     to ("💎" to Color(0xFF60A5FA)),
                    MandapStyle.Traditional to ("🏛" to ChampagneGold),
                    MandapStyle.Boho        to ("🌿" to EmeraldGreen)
                ).forEach { (style, pair) ->
                    val (emoji, color) = pair
                    AntigravityGlassChip(
                        label       = style.name,
                        selected    = state.selectedMandapStyles.contains(style),
                        onClick     = { vm.toggleDecorStyle(style) },
                        leadingEmoji = emoji,
                        accentColor = color
                    )
                }
            }
        }

        // Setup Location selector (Indoor / Outdoor / Both)
        FilterSection("Setup Location") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    SetupLocation.Indoor  to ("🏠" to "Indoor"),
                    SetupLocation.Outdoor to ("🌳" to "Outdoor"),
                    SetupLocation.Both    to ("🔄" to "Both")
                ).forEach { (loc, pair) ->
                    val (emoji, label) = pair
                    AntigravityGlassChip(
                        label       = label,
                        selected    = state.setupLocation == loc,
                        onClick     = { vm.updateDecorSetupLocation(loc) },
                        leadingEmoji = emoji,
                        accentColor = MandapAccent
                    )
                }
            }
        }

        // Floral choice
        FilterSection("Floral Choice") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    "Real Orchids" to "🌺",
                    "Artificial"   to "🎨",
                    "Jasmine"      to "🌼",
                    "Mogra"        to "🤍",
                    "Marigold"     to "🟡"
                ).forEach { (choice, emoji) ->
                    AntigravityGlassChip(
                        label       = choice,
                        selected    = state.selectedFloralChoices.contains(choice),
                        onClick     = { vm.toggleDecorFloral(choice) },
                        leadingEmoji = emoji,
                        accentColor = Color(0xFFF472B6)
                    )
                }
            }
        }

        FilterSection("Decor Setup Components") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    "Wedding Mandap", "Stage Backdrop", "Entrance Arch", "Table Centrepieces", "AV/Lighting"
                ).forEach { comp ->
                    AntigravityGlassChip(
                        label       = comp,
                        selected    = state.selectedComponents.contains(comp),
                        onClick     = { vm.toggleDecorComponent(comp) },
                        accentColor = MandapAccent
                    )
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Catering Filter Pane — NEW
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun CateringFilterContent(state: CategoryFilterState.CateringFilters, vm: FilterViewModel) {
    Column(verticalArrangement = Arrangement.spacedBy(20.dp)) {

        // Price Per Plate
        FilterSection("Price Per Plate") {
            AntigravityRangeSlider(
                value          = state.pricePerPlate,
                onValueChange  = vm::updateCateringPriceRange,
                valueRange     = 300f..3000f,
                labelFormatter = ::formatRupees,
                accentColor    = CateringAccent
            )
        }

        // Cuisine Type chips
        FilterSection("Cuisine Preferences") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    CuisineType.SouthIndian  to ("🍛" to "South Indian"),
                    CuisineType.NorthIndian  to ("🫓" to "North Indian"),
                    CuisineType.Continental  to ("🍝" to "Continental"),
                    CuisineType.PanAsian     to ("🥢" to "Pan Asian")
                ).forEach { (cuisine, pair) ->
                    val (emoji, label) = pair
                    AntigravityGlassChip(
                        label       = label,
                        selected    = state.selectedCuisines.contains(cuisine),
                        onClick     = { vm.toggleCateringCuisine(cuisine) },
                        leadingEmoji = emoji,
                        accentColor = CateringAccent
                    )
                }
            }
        }

        // Dietary Type selector
        FilterSection("Dietary Preference") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    DietaryType.StrictlyVeg  to ("🥬" to "Strictly Veg"),
                    DietaryType.VegAndNonVeg to ("🍗" to "Veg & Non-Veg"),
                    DietaryType.Jain         to ("🕉" to "Jain")
                ).forEach { (dietary, pair) ->
                    val (emoji, label) = pair
                    AntigravityGlassChip(
                        label       = label,
                        selected    = state.dietaryType == dietary,
                        onClick     = { vm.updateCateringDietary(dietary) },
                        leadingEmoji = emoji,
                        accentColor = CateringAccent
                    )
                }
            }
        }

        FilterSection("Catering Service Formats") {
            FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    "Banana Leaf Service", "Standard Buffet", "Premium Live Counters"
                ).forEach { style ->
                    AntigravityGlassChip(
                        label       = style,
                        selected    = state.selectedServiceStyles.contains(style),
                        onClick     = { vm.toggleCateringServiceStyle(style) },
                        accentColor = CateringAccent
                    )
                }
            }
        }

        FilterSection("Beverages & Sweets Add-ons") {
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                AntigravityBouncySwitch(
                    title           = "Welcome Drinks / Mocktails",
                    subtitle        = "Cold mocktail stalls for guests entrance",
                    checked         = state.isWelcomeDrinksIncluded,
                    onCheckedChange = vm::toggleCateringWelcomeDrinks,
                    accentColor     = CateringAccent
                )
                AntigravityBouncySwitch(
                    title           = "Traditional Sweets Buffet",
                    subtitle        = "Assorted sweets counters (Payasam, Jalebi)",
                    checked         = state.isSweetsBuffetIncluded,
                    onCheckedChange = vm::toggleCateringSweetsBuffet,
                    accentColor     = CateringAccent
                )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// FilterSection — soft header with no borders, generous whitespace
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun FilterSection(title: String, content: @Composable () -> Unit) {
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(
            text       = title,
            fontSize   = 13.sp,
            fontWeight = FontWeight.Black,
            color      = SlateGray,
            letterSpacing = 0.8.sp
        )
        content()
    }
}

@Composable
fun LocationRadarSection(viewModel: FilterViewModel) {
    val radiusKm by viewModel.radiusKm.collectAsState()
    val userLocation by viewModel.userLocation.collectAsState()
    val haptic = androidx.compose.ui.platform.LocalHapticFeedback.current
    
    var lastHapticValue by remember { mutableStateOf(radiusKm.toInt()) }
    
    // Simulate GPS resolution
    val coroutineScope = rememberCoroutineScope()
    var isLocating by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White, RoundedCornerShape(16.dp))
            .border(1.dp, ChampagneGold.copy(alpha = 0.3f), RoundedCornerShape(16.dp))
            .padding(16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text(
                    text = "📡  Location Radar Discovery",
                    fontWeight = FontWeight.Black,
                    fontSize = 14.sp,
                    color = RoyalNavy
                )
                Text(
                    text = if (userLocation != null) "GPS Locked near Banjara Hills" else "GPS Standby (Guntur/Vijayawada/Hyd)",
                    fontSize = 10.sp,
                    color = if (userLocation != null) EmeraldGreen else SlateGray,
                    fontWeight = FontWeight.Bold
                )
            }
            
            TextButton(
                onClick = {
                    isLocating = true
                    coroutineScope.launch {
                        delay(800)
                        // Mock Banjara Hills coordinates
                        viewModel.updateUserLocation(17.4156, 78.4347)
                        isLocating = false
                        haptic.performHapticFeedback(androidx.compose.ui.hapticfeedback.HapticFeedbackType.LongPress)
                    }
                },
                enabled = !isLocating
            ) {
                if (isLocating) {
                    CircularProgressIndicator(modifier = Modifier.size(16.dp), color = EmeraldGreen, strokeWidth = 2.dp)
                } else {
                    Text(
                        text = if (userLocation != null) "Relocate" else "Detect GPS",
                        color = EmeraldGreen,
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp
                    )
                }
            }
        }
        
        Spacer(Modifier.height(12.dp))
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Search Radius",
                fontSize = 12.sp,
                color = SlateGray,
                fontWeight = FontWeight.SemiBold
            )
            Text(
                text = "${radiusKm.toInt()} km",
                fontSize = 14.sp,
                fontWeight = FontWeight.Black,
                color = RoyalNavy
            )
        }
        
        Slider(
            value = radiusKm,
            onValueChange = { value ->
                viewModel.updateRadius(value)
                val intVal = value.toInt()
                if (intVal != lastHapticValue) {
                    haptic.performHapticFeedback(androidx.compose.ui.hapticfeedback.HapticFeedbackType.TextHandleMove)
                    lastHapticValue = intVal
                }
            },
            valueRange = 5f..100f,
            steps = 18,
            colors = SliderDefaults.colors(
                thumbColor = ChampagneGold,
                activeTrackColor = RoyalNavy,
                inactiveTrackColor = IceBg
            )
        )
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            listOf("5km", "15km", "50km", "100km").forEach { label ->
                Text(label, fontSize = 9.sp, color = SlateGray, fontWeight = FontWeight.Bold)
            }
        }
    }
}
