@file:OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
package com.gomandap.app.presentation.search

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.gomandap.app.domain.model.*
import com.gomandap.app.presentation.search.components.*
import kotlinx.coroutines.delay

// ─── Color Palette ───────────────────────────────────────────────────────────
private val RoyalNavy      = Color(0xFF0F172A)
private val EmeraldGreen   = Color(0xFF10B981)
private val ChampagneGold  = Color(0xFFDFBA73)
private val DarkGold       = Color(0xFFC59A48)
private val LightGrayBg    = Color(0xFFF8F9FA)
private val IceBg          = Color(0xFFF8FAFC)
private val SlateGray      = Color(0xFF64748B)

// ─── Quick-Filter Pill Definition ────────────────────────────────────────────
private data class QuickFilter(val label: String, val category: String, val emoji: String)

@Composable
fun SearchScreen(
    initialCategory: String = "Venues",
    onBackClick: () -> Unit,
    onVenueTap: (String) -> Unit,
    filterViewModel: FilterViewModel = viewModel()
) {
    // Kick off with the category from the Home Screen tap
    LaunchedEffect(initialCategory) {
        filterViewModel.changeCategory(initialCategory)
    }

    val currentCategory  by filterViewModel.currentCategory.collectAsState()
    val filteredResults  by filterViewModel.filteredResults.collectAsState()
    val activeFilterState by filterViewModel.activeFilterState.collectAsState()

    var searchQuery by remember { mutableStateOf("") }
    var showFilterSheet by remember { mutableStateOf(false) }
    var isMapMode by remember { mutableStateOf(false) }
    var isBlueprinted by remember { mutableStateOf(false) }

    // Cycling placeholder text
    val placeholders = listOf(
        "Search Banquets, Resorts…",
        "Try 'Mogra Mandapam in Hyderabad'",
        "Try 'Candid Drone Photographers'",
        "Try 'Lawn under ₹50k'",
        "Try 'Acrylic Boho Decor'"
    )
    var placeholderIdx by remember { mutableStateOf(0) }
    LaunchedEffect(Unit) {
        while (true) {
            delay(3400)
            placeholderIdx = (placeholderIdx + 1) % placeholders.size
        }
    }

    val listState = rememberLazyListState()

    // Whether list has scrolled (for elevated header effect)
    val isScrolled by remember { derivedStateOf { listState.firstVisibleItemIndex > 0 } }

    Scaffold(
        containerColor = IceBg,
        topBar = {
            // ── Header (Search bar + quick filter row) ────────────────────
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(
                        if (isScrolled)
                            Brush.verticalGradient(listOf(Color.White, Color.White.copy(alpha = 0.95f)))
                        else
                            Brush.verticalGradient(listOf(Color.White, Color.Transparent))
                    )
            ) {
                // ── Search Input Row ──────────────────────────────────────
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    IconButton(onClick = onBackClick) {
                        Icon(
                            imageVector  = Icons.Default.ArrowBack,
                            contentDescription = "Back",
                            tint = RoyalNavy
                        )
                    }

                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(50.dp)
                            .background(IceBg, RoundedCornerShape(25.dp))
                            .border(
                                1.dp,
                                Brush.linearGradient(
                                    listOf(ChampagneGold.copy(alpha = 0.6f), EmeraldGreen.copy(alpha = 0.3f))
                                ),
                                RoundedCornerShape(25.dp)
                            )
                            .padding(horizontal = 16.dp),
                        contentAlignment = Alignment.CenterStart
                    ) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            modifier         = Modifier.fillMaxWidth()
                        ) {
                            Icon(
                                Icons.Default.Search,
                                contentDescription = null,
                                tint     = SlateGray,
                                modifier = Modifier.size(18.dp)
                            )
                            Spacer(Modifier.width(8.dp))

                            Box(modifier = Modifier.weight(1f)) {
                                if (searchQuery.isEmpty()) {
                                    AnimatedContent(
                                        targetState = placeholderIdx,
                                        transitionSpec = {
                                            (fadeIn(tween(400)) + slideInVertically { it / 3 })
                                                .togetherWith(fadeOut(tween(200)) + slideOutVertically { -it / 3 })
                                        },
                                        label = "placeholderAnim"
                                    ) { idx ->
                                        Text(
                                            text     = placeholders[idx],
                                            color    = SlateGray.copy(alpha = 0.65f),
                                            fontSize = 14.sp
                                        )
                                    }
                                }
                                androidx.compose.foundation.text.BasicTextField(
                                    value       = searchQuery,
                                    onValueChange = { searchQuery = it },
                                    textStyle   = LocalTextStyle.current.copy(
                                        color    = RoyalNavy,
                                        fontSize = 14.sp
                                    ),
                                    modifier = Modifier.fillMaxWidth()
                                )
                            }

                            if (searchQuery.isNotEmpty()) {
                                Icon(
                                    Icons.Default.Clear,
                                    contentDescription = "Clear",
                                    tint     = SlateGray,
                                    modifier = Modifier
                                        .size(18.dp)
                                        .clickable { searchQuery = "" }
                                )
                            }
                        }
                    }

                    Spacer(Modifier.width(8.dp))

                    // Map/List toggle
                    IconButton(
                        onClick = { isMapMode = !isMapMode },
                        modifier = Modifier
                            .size(42.dp)
                            .background(
                                if (isMapMode) RoyalNavy else IceBg,
                                CircleShape
                            )
                    ) {
                        Icon(
                            imageVector = if (isMapMode) Icons.Default.List else Icons.Default.LocationOn,
                            contentDescription = "Toggle Map",
                            tint = if (isMapMode) Color.White else RoyalNavy,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }

                // ── Sticky Glassmorphic Quick-Filter Row ──────────────────
                OmniFilterBar(
                    currentCategory = currentCategory,
                    activeFilterState = activeFilterState,
                    onCategoryTap = { filterViewModel.changeCategory(it) },
                    onFiltersTap  = { showFilterSheet = true }
                )
            }
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            // ── Blueprinting & Results Feed ──────────────────────────────────────────────
            if (!isBlueprinted) {
                // Hyper-Local Blueprinting Step
                Column(
                    modifier = Modifier.fillMaxSize().padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(Icons.Default.DateRange, null, modifier = Modifier.size(48.dp), tint = ChampagneGold)
                    Spacer(Modifier.height(16.dp))
                    Text("Event Blueprint Required", fontSize = 22.sp, fontWeight = FontWeight.Black, color = RoyalNavy)
                    Text("Q-Commerce enforces strict 100% available inventory. Please define your event parameters first.", fontSize = 12.sp, color = SlateGray, textAlign = TextAlign.Center, modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp))
                    
                    Spacer(Modifier.height(24.dp))
                    Card(
                        shape = RoundedCornerShape(16.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        elevation = CardDefaults.cardElevation(2.dp)
                    ) {
                        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
                            OutlinedTextField(value = "Today + 7 Days", onValueChange = {}, label = { Text("Event Date") }, modifier = Modifier.fillMaxWidth(), enabled = false)
                            OutlinedTextField(value = "Evening (5 PM - 11 PM)", onValueChange = {}, label = { Text("Time Slot") }, modifier = Modifier.fillMaxWidth(), enabled = false)
                            OutlinedTextField(value = "500 Guests", onValueChange = {}, label = { Text("Guest Count") }, modifier = Modifier.fillMaxWidth(), enabled = false)
                            OutlinedTextField(value = "Banjara Hills, Hyderabad", onValueChange = {}, label = { Text("Micro-Location") }, modifier = Modifier.fillMaxWidth(), enabled = false)
                        }
                    }
                    Spacer(Modifier.height(24.dp))
                    Button(
                        onClick = { isBlueprinted = true },
                        modifier = Modifier.fillMaxWidth().height(56.dp),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen)
                    ) {
                        Text("Search Available Inventory", fontWeight = FontWeight.Bold, fontSize = 16.sp)
                    }
                }
            } else if (filteredResults.isEmpty()) {
                EmptyResultsPane(
                    category  = currentCategory,
                    onReset   = { filterViewModel.resetFilters() }
                )
            } else {
                val chunkedResults = remember(filteredResults) { filteredResults.chunked(2) }
                LazyColumn(
                    state           = listState,
                    contentPadding  = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    item {
                        ResultsHeaderRow(
                            count    = filteredResults.size,
                            category = currentCategory
                        )
                    }

                    items(chunkedResults) { pair ->
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            pair.forEachIndexed { idx, vendor ->
                                Box(modifier = Modifier.weight(1f)) {
                                    StaggeredVendorCard(
                                        vendor       = vendor,
                                        index        = idx,
                                        onBookNow    = { onVenueTap(vendor.id) }
                                    )
                                }
                            }
                            if (pair.size < 2) {
                                Box(modifier = Modifier.weight(1f))
                            }
                        }
                    }

                    item { Spacer(Modifier.height(80.dp)) }
                }
            }
        }
    }

    // ── Deep Filter Sheet ─────────────────────────────────────────────────
    if (showFilterSheet) {
        DynamicFilterBottomSheet(
            viewModel = filterViewModel,
            onDismiss = { showFilterSheet = false }
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// OmniFilterBar — sticky glassmorphic quick-filter pill strip
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun OmniFilterBar(
    currentCategory: String,
    activeFilterState: CategoryFilterState,
    onCategoryTap: (String) -> Unit,
    onFiltersTap: () -> Unit
) {
    val quickFilters = listOf(
        QuickFilter("Venues",       "Venues",      "🏛"),
        QuickFilter("Photography",  "Photography", "📸"),
        QuickFilter("Mandaps",      "Mandaps",     "🌸"),
        QuickFilter("Catering",     "Catering",    "🍽"),
        QuickFilter("DJ & AV",      "DJ",          "🎧")
    )

    // Count active non-category filters
    val activeFilterCount = when (activeFilterState) {
        is CategoryFilterState.VenueFilters -> listOf(
            activeFilterState.isAcOnly,
            activeFilterState.isRoomsAvailable,
            activeFilterState.isValetParking,
            activeFilterState.isAlcoholAllowed,
            activeFilterState.isOutsideCateringAllowed,
            activeFilterState.isInHouseDecorOnly,
            activeFilterState.roomsRequired > 0,
            activeFilterState.selectedVenueTypes.isNotEmpty(),
            activeFilterState.ratingRange.start > 0f,
            activeFilterState.foodType != VenueFoodType.Both
        ).count { it }
        is CategoryFilterState.PhotographyFilters -> listOf(
            activeFilterState.selectedDeliverables.isNotEmpty(),
            activeFilterState.selectedStyles.isNotEmpty()
        ).count { it }
        is CategoryFilterState.DecorFilters -> listOf(
            activeFilterState.setupLocation != SetupLocation.Both,
            activeFilterState.selectedMandapStyles.isNotEmpty(),
            activeFilterState.selectedFloralChoices.isNotEmpty()
        ).count { it }
        is CategoryFilterState.MakeupArtistFilters -> listOf(
            activeFilterState.isHairStylingIncluded,
            activeFilterState.isDrapingIncluded,
            activeFilterState.isPaidTrialAvailable,
            activeFilterState.selectedMakeupTypes.isNotEmpty()
        ).count { it }
        is CategoryFilterState.CateringFilters -> listOf(
            activeFilterState.dietaryType != DietaryType.VegAndNonVeg,
            activeFilterState.selectedCuisines.isNotEmpty()
        ).count { it }
    }

    LazyRow(
        contentPadding      = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        // Deep Filter button (always first)
        item {
            FilterPill(
                label    = if (activeFilterCount > 0) "Filters ($activeFilterCount)" else "Filters",
                emoji    = "⚡",
                selected = activeFilterCount > 0,
                onClick  = onFiltersTap,
                accentColor = if (activeFilterCount > 0) ChampagneGold else EmeraldGreen
            )
        }

        items(quickFilters) { qf ->
            FilterPill(
                label    = qf.label,
                emoji    = qf.emoji,
                selected = currentCategory == qf.category,
                onClick  = { onCategoryTap(qf.category) }
            )
        }
    }
}

@Composable
private fun FilterPill(
    label: String,
    emoji: String,
    selected: Boolean,
    onClick: () -> Unit,
    accentColor: Color = EmeraldGreen
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.94f else if (selected) 1.04f else 1.0f,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessLow),
        label = "pillScale"
    )

    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(5.dp),
        modifier = Modifier
            .scale(scale)
            .clip(RoundedCornerShape(50))
            .background(
                if (selected)
                    Brush.linearGradient(listOf(accentColor, accentColor.copy(alpha = 0.8f)))
                else
                    Brush.linearGradient(listOf(Color.White, Color.White))
            )
            .border(
                1.dp,
                if (selected) Color.Transparent else ChampagneGold.copy(alpha = 0.3f),
                RoundedCornerShape(50)
            )
            .clickable(
                interactionSource = interactionSource,
                indication = null
            ) {
                onClick()
            }
            .padding(horizontal = 14.dp, vertical = 8.dp)
    ) {
        Text(emoji, fontSize = 12.sp)
        Text(
            text       = label,
            fontSize   = 12.sp,
            fontWeight = if (selected) FontWeight.Bold else FontWeight.Medium,
            color      = if (selected) Color.White else RoyalNavy,
            maxLines   = 1
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Results Header Row
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun ResultsHeaderRow(count: Int, category: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment     = Alignment.CenterVertically
    ) {
        Column {
            Text(
                text       = "$category Results",
                fontSize   = 18.sp,
                fontWeight = FontWeight.ExtraBold,
                color      = RoyalNavy
            )
            Text(
                text     = "$count verified listings near you",
                fontSize = 12.sp,
                color    = SlateGray
            )
        }
        // Sort icon placeholder
        Box(
            contentAlignment = Alignment.Center,
            modifier = Modifier
                .size(38.dp)
                .background(Color.White, CircleShape)
                .border(1.dp, ChampagneGold.copy(alpha = 0.3f), CircleShape)
        ) {
            Icon(
                Icons.Default.List,
                contentDescription = "Sort",
                tint     = RoyalNavy,
                modifier = Modifier.size(18.dp)
            )
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stagger-Loaded Vendor Card Wrapper
// Each card slides + fades in based on its index, creating a cascade effect.
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun StaggeredVendorCard(
    vendor: Vendor,
    index: Int,
    onBookNow: () -> Unit
) {
    var visible by remember { mutableStateOf(false) }
    LaunchedEffect(vendor.id) {
        delay((index * 70L).coerceAtMost(350L))
        visible = true
    }

    AnimatedVisibility(
        visible = visible,
        enter   = fadeIn(tween(350)) + slideInVertically(
            animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessLow),
            initialOffsetY = { it / 3 }
        )
    ) {
        AdvancedListingCard(
            vendor        = vendor,
            onBookNowClick = onBookNow,
            onChatClick    = {},
            onShortlistClick = {}
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Results Pane
// ─────────────────────────────────────────────────────────────────────────────
@Composable
private fun EmptyResultsPane(category: String, onReset: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("🔍", fontSize = 48.sp, textAlign = TextAlign.Center)
        Spacer(Modifier.height(16.dp))
        Text(
            text       = "No $category Found",
            fontSize   = 20.sp,
            fontWeight = FontWeight.ExtraBold,
            color      = RoyalNavy,
            textAlign  = TextAlign.Center
        )
        Spacer(Modifier.height(8.dp))
        Text(
            text      = "Your filters returned zero results.\nTry broadening your search criteria.",
            fontSize  = 13.sp,
            color     = SlateGray,
            textAlign = TextAlign.Center
        )
        Spacer(Modifier.height(28.dp))
        Button(
            onClick = onReset,
            colors  = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
            shape   = RoundedCornerShape(14.dp),
            modifier = Modifier.height(50.dp)
        ) {
            Icon(Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(16.dp))
            Spacer(Modifier.width(8.dp))
            Text("Reset All Filters", fontWeight = FontWeight.Bold)
        }
    }
}
