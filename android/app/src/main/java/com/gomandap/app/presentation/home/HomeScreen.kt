package com.gomandap.app.presentation.home

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.*
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.gomandap.app.presentation.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlin.math.abs
import android.widget.Toast
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType

// ─── Home Screen Entry Point ──────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
@Composable
fun HomeScreen(
    onCategoryTap: (String) -> Unit,
    onVenueTap: (String) -> Unit,
    onCartTap: () -> Unit,
    onSearchClick: () -> Unit,
    onGalleryClick: () -> Unit,
    viewModel: HomeViewModel = viewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val radarSheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val scope = rememberCoroutineScope()

    // Category Bottom Sheet
    if (uiState.isCategorySheetOpen) {
        ModalBottomSheet(
            onDismissRequest = { viewModel.closeCategorySheet() },
            sheetState = sheetState,
            containerColor = Color.White,
            shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
        ) {
            CategoryBottomSheetContent(
                category = uiState.selectedCategory ?: "",
                onDismiss = { viewModel.closeCategorySheet() },
                onNavigate = { catId ->
                    viewModel.closeCategorySheet()
                    onCategoryTap(catId)
                }
            )
        }
    }

    // Radar / Location Bottom Sheet
    if (uiState.isRadarSheetOpen) {
        ModalBottomSheet(
            onDismissRequest = { viewModel.closeRadarSheet() },
            sheetState = radarSheetState,
            containerColor = Color.White,
            shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
        ) {
            RadarBottomSheetContent(
                radiusKm = uiState.radiusKm,
                onRadiusChange = viewModel::updateRadius,
                onConfirm = { viewModel.closeRadarSheet() }
            )
        }
    }

    Scaffold(
        topBar = {
            GomandapTopBar(
                cartCount = uiState.cartCount,
                selectedCity = uiState.selectedCity,
                onCartTap = onCartTap,
                onCityTap = { viewModel.openRadarSheet() }
            )
        },
        containerColor = SoftMist
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .background(Brush.verticalGradient(listOf(SoftMist, CreamBg)))
                .padding(paddingValues),
            verticalArrangement = Arrangement.spacedBy(0.dp)
        ) {
            // ── 1. Hero Auto-Playing Carousel ──────────────────────────────
            item {
                HeroAdCarousel(
                    currentIndex = uiState.activeCarouselIndex,
                    onIndexChange = viewModel::setCarouselIndex
                )
            }

            // ── 2. Trust / Shortcuts Band ────────────────────────────────
            item {
                TrustStatusBand()
            }

            // ── 3. Floating Search & Filter Bar ───────────────────────────
            item {
                Spacer(Modifier.height(16.dp))
                GlassSearchBar(
                    selectedCity = uiState.selectedCity,
                    onClick = onSearchClick,
                    onLocationTap = { viewModel.openRadarSheet() }
                )
                Spacer(Modifier.height(18.dp))
            }

            // ── 2b. Instant Book Packages (Q-Commerce SKU Cards) ──────────
            item {
                SectionHeader(
                    title = "⚡ Instant Book Packages",
                    subtitle = "Fixed-price, book in one tap — no calls needed"
                )
                Spacer(Modifier.height(12.dp))
                InstantBookPackagesRow()
                Spacer(Modifier.height(20.dp))
            }

            // ── 3. Two Sections of Antigravity Category Discovery ─────────
            item {
                CategoryDualSection(
                    onCategoryTap = { cat ->
                        viewModel.selectCategory(cat)
                    }
                )
                Spacer(Modifier.height(20.dp))
            }

            // ── 4. Trending Venues Feed with Interspersed Native Ads ──────
            item {
                SectionHeader(
                    title = "Trending Venues Near You",
                    subtitle = "Based on your location • ${uiState.selectedCity}"
                )
                Spacer(Modifier.height(12.dp))
                if (uiState.isLoading) {
                    ShimmerVenueRow()
                } else {
                    TrendingVenuesList(
                        venues = uiState.trendingVenues,
                        wishlistedIds = uiState.wishlistedIds,
                        onVenueTap = onVenueTap,
                        onWishlistToggle = viewModel::toggleWishlist
                    )
                }
                Spacer(Modifier.height(20.dp))
            }

            // ── 5. Category Banner Injection ──────────────────────────────
            item {
                FeaturedDealBanner()
                Spacer(Modifier.height(20.dp))
            }

            // ── 5b. Pinterest Shoppable Gallery Banner Injection ───────────
            item {
                ShoppableGalleryBanner(onClick = onGalleryClick)
                Spacer(Modifier.height(20.dp))
            }

            // ── 6. Elite Services Shelf ───────────────────────────────────
            item {
                SectionHeader(
                    title = "Elite Service Specialists",
                    subtitle = "Photography, Makeup, Decor & more"
                )
                Spacer(Modifier.height(12.dp))
                if (uiState.isLoading) {
                    ShimmerServiceRow()
                } else {
                    EliteServicesList(services = uiState.eliteServices, onTap = onCategoryTap)
                }
                Spacer(Modifier.height(20.dp))
            }

            // ── 6b. VIP Enterprise Concierge Section ───────────────────────
            item {
                VipConciergeSection()
                Spacer(Modifier.height(20.dp))
            }

            // ── 7. Browse by City Strip ───────────────────────────────────
            item {
                SectionHeader(title = "Browse by City", subtitle = "Discover venues across India")
                Spacer(Modifier.height(12.dp))
                CityBrowseStrip(
                    cities = uiState.cities,
                    selectedCity = uiState.selectedCity,
                    onCityTap = viewModel::selectCity
                )
                Spacer(Modifier.height(32.dp))
            }

            // ── 8. Unified App Footer ──────────────────────────────────────
            item {
                AppFooter()
            }
        }
    }
}

// ─── Top App Bar ─────────────────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GomandapTopBar(
    cartCount: Int,
    selectedCity: String,
    onCartTap: () -> Unit,
    onCityTap: () -> Unit
) {
    var selectedSlot by remember { mutableStateOf("14 Nov · Evening") }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                Brush.verticalGradient(
                    listOf(Color.White, SoftMist)
                )
            )
            .shadow(elevation = 6.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier
                        .background(
                            Brush.horizontalGradient(listOf(RoyalNavy, DeepSky)),
                            RoundedCornerShape(16.dp)
                        )
                        .padding(horizontal = 12.dp, vertical = 6.dp)
                ) {
                    Text("GoMandap", fontWeight = FontWeight.Black, fontSize = 18.sp, color = Color.White)
                }
                Spacer(Modifier.weight(1f))
                IconButton(onClick = onCartTap) {
                    BadgedBox(badge = {
                        if (cartCount > 0) Badge { Text(cartCount.toString()) }
                    }) {
                        Icon(Icons.Default.ShoppingCart, "Cart", tint = RoyalNavy)
                    }
                }
                Box(
                    modifier = Modifier
                        .size(34.dp)
                        .clip(CircleShape)
                        .background(Brush.linearGradient(listOf(EmeraldGreen, Color(0xFF059669))))
                        .border(1.5.dp, ChampagneGold, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Text("M", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                }
            }

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    onClick = onCityTap,
                    color = Color.White,
                    shape = RoundedCornerShape(24.dp),
                    border = BorderStroke(1.dp, LightSlate),
                    tonalElevation = 2.dp
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.LocationOn, null, tint = EmeraldGreen, modifier = Modifier.size(14.dp))
                        Spacer(Modifier.width(4.dp))
                        Text(selectedCity, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = RoyalNavy, maxLines = 1)
                        Icon(Icons.Default.ArrowDropDown, null, tint = SlateGray, modifier = Modifier.size(16.dp))
                    }
                }

                Surface(
                    onClick = { /* open date/slot picker */ },
                    color = RoyalNavy,
                    shape = RoundedCornerShape(24.dp),
                    tonalElevation = 2.dp
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.DateRange, null, tint = ChampagneGold, modifier = Modifier.size(14.dp))
                        Spacer(Modifier.width(4.dp))
                        Text(selectedSlot, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.White, maxLines = 1)
                        Icon(Icons.Default.ArrowDropDown, null, tint = ChampagneGold, modifier = Modifier.size(16.dp))
                    }
                }
            }
        }
    }
}

@Composable
fun TrustStatusBand() {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 10.dp),
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        listOf(
            "✅ Verified venues" to EmeraldGreen,
            "🛡️ Escrow safe" to RoyalNavy,
            "⭐ 4.8+ rated" to DarkGold
        ).forEach { (text, color) ->
            Surface(
                color = Color.White,
                shape = RoundedCornerShape(999.dp),
                border = BorderStroke(1.dp, LightSlate)
            ) {
                Text(
                    text,
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp),
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = color
                )
            }
        }
    }
}

// ─── Instant Book Packages Row (Q-Commerce SKUs) ─────────────────────────────

data class InstantPackage(
    val title: String,
    val category: String,
    val price: String,
    val period: String,
    val emoji: String,
    val tag: String,
    val tagColor: Long,
    val amenity1Icon: androidx.compose.ui.graphics.vector.ImageVector,
    val amenity1Text: String,
    val amenity2Icon: androidx.compose.ui.graphics.vector.ImageVector,
    val amenity2Text: String,
    val amenity3Icon: androidx.compose.ui.graphics.vector.ImageVector,
    val amenity3Text: String
)

val instantPackages = listOf(
    InstantPackage(
        title = "4-Hr Candid Photography",
        category = "Photography",
        price = "₹20,000",
        period = "per 4 hours",
        emoji = "📷",
        tag = "Most Booked",
        tagColor = 0xFF10B981,
        amenity1Icon = Icons.Default.Person,
        amenity1Text = "1 Lead",
        amenity2Icon = Icons.Default.ElectricBolt,
        amenity2Text = "Raw + Edit",
        amenity3Icon = Icons.Default.Check,
        amenity3Text = "4-Wk Delivery"
    ),
    InstantPackage(
        title = "Minimalist Haldi Decor",
        category = "Decor Setup",
        price = "₹12,000",
        period = "per event slot",
        emoji = "🌸",
        tag = "⚡ Instant",
        tagColor = 0xFFDFBA73,
        amenity1Icon = Icons.Default.Star,
        amenity1Text = "Fresh Flowers",
        amenity2Icon = Icons.Default.ThumbUp,
        amenity2Text = "Theme Stage",
        amenity3Icon = Icons.Default.Check,
        amenity3Text = "3-Hr Setup"
    ),
    InstantPackage(
        title = "Bridal Makeup Package",
        category = "Makeup & Beauty",
        price = "₹8,500",
        period = "per session",
        emoji = "💄",
        tag = "⚡ Instant",
        tagColor = 0xFFDFBA73,
        amenity1Icon = Icons.Default.Person,
        amenity1Text = "HD Makeup",
        amenity2Icon = Icons.Default.Star,
        amenity2Text = "Mac Products",
        amenity3Icon = Icons.Default.Check,
        amenity3Text = "Hair Styling"
    ),
    InstantPackage(
        title = "250 Pax Veg Catering",
        category = "Catering",
        price = "₹37,500",
        period = "per 150 guests",
        emoji = "🍽️",
        tag = "Fast Filling 🔥",
        tagColor = 0xFFEF4444,
        amenity1Icon = Icons.Default.People,
        amenity1Text = "Veg Buffet",
        amenity2Icon = Icons.Default.Person,
        amenity2Text = "Servers Incl.",
        amenity3Icon = Icons.Default.Check,
        amenity3Text = "Standard Plate"
    ),
    InstantPackage(
        title = "DJ + Sound System",
        category = "Entertainment",
        price = "₹18,000",
        period = "per 6 hours",
        emoji = "🎧",
        tag = "⚡ Instant",
        tagColor = 0xFFDFBA73,
        amenity1Icon = Icons.Default.ElectricBolt,
        amenity1Text = "5kW Audio",
        amenity2Icon = Icons.Default.People,
        amenity2Text = "DJ Console",
        amenity3Icon = Icons.Default.Check,
        amenity3Text = "Lights Incl."
    ),
    InstantPackage(
        title = "Mehndi Artist (2 Hands)",
        category = "Mehndi",
        price = "₹3,500",
        period = "per person",
        emoji = "🌿",
        tag = "Top Rated ⭐",
        tagColor = 0xFF10B981,
        amenity1Icon = Icons.Default.Person,
        amenity1Text = "1 Artist",
        amenity2Icon = Icons.Default.Star,
        amenity2Text = "Organic Henna",
        amenity3Icon = Icons.Default.Check,
        amenity3Text = "Bridal Pattern"
    )
)

@Composable
fun InstantBookPackagesRow(onPackageClick: (InstantPackage) -> Unit = {}) {
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        items(instantPackages) { pkg ->
            InstantPackageCard(pkg = pkg, onClick = { onPackageClick(pkg) })
        }
    }
}

@Composable
internal fun InstantPackageCard(pkg: InstantPackage, onClick: () -> Unit) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        animationSpec = AntigravitySpring.WeightlessSpec,
        label = "pkgScale"
    )

    Card(
        modifier = Modifier
            .width(155.dp)
            .scale(scale)
            .clickable(interactionSource = interactionSource, indication = null) { onClick() },
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column {
            // Header Image/Emoji Box
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(95.dp)
                    .background(
                        brush = Brush.verticalGradient(
                            listOf(LightGrayBg, Color.White)
                        )
                    )
            ) {
                // Large Emoji in Center
                Box(
                    modifier = Modifier.fillMaxSize(),
                    contentAlignment = Alignment.Center
                ) {
                    Text(pkg.emoji, fontSize = 34.sp)
                }

                // Tag overlay
                Surface(
                    color = Color(pkg.tagColor).copy(alpha = 0.12f),
                    shape = RoundedCornerShape(bottomEnd = 10.dp),
                    modifier = Modifier.align(Alignment.TopStart)
                ) {
                    Text(
                        pkg.tag, fontSize = 8.sp, fontWeight = FontWeight.Black,
                        color = Color(pkg.tagColor),
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                    )
                }
            }

            // Info Column
            Column(
                modifier = Modifier.padding(10.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Text(
                    text = pkg.category.uppercase(),
                    fontSize = 8.sp,
                    color = ChampagneGold,
                    fontWeight = FontWeight.Black,
                    letterSpacing = 0.5.sp
                )
                
                Text(
                    text = pkg.title,
                    fontWeight = FontWeight.Bold,
                    fontSize = 12.sp,
                    color = RoyalNavy,
                    maxLines = 2,
                    minLines = 2,
                    lineHeight = 14.sp,
                    overflow = TextOverflow.Ellipsis
                )
                
                Spacer(modifier = Modifier.height(2.dp))
                
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(
                            text = pkg.price,
                            fontWeight = FontWeight.Black,
                            fontSize = 14.sp,
                            color = RoyalNavy
                        )
                        Text(
                            text = pkg.period.replace("per ", ""),
                            fontSize = 8.sp,
                            color = Color.Gray
                        )
                    }
                    
                    // Small visual action indicator
                    Box(
                        modifier = Modifier
                            .size(24.dp)
                            .clip(CircleShape)
                            .background(EmeraldGreen.copy(alpha = 0.1f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.Add,
                            contentDescription = "Details",
                            tint = EmeraldGreen,
                            modifier = Modifier.size(14.dp)
                        )
                    }
                }
            }
        }
    }
}

// ─── Hero Ad Auto-Play Carousel ───────────────────────────────────────────────

private val heroBanners = listOf(
    Triple("The Taj Palace Convention", "Luxury 5-star venue — limited slots!", Color(0xFF1A0A2E)),
    Triple("Heritage Gala Resort", "Exclusive summer offers available", Color(0xFF0A1F0F)),
    Triple("Grand Imperial Gardens", "Outdoor garden weddings at ₹1,200/plate", Color(0xFF1A0D00))
)

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun HeroAdCarousel(currentIndex: Int, onIndexChange: (Int) -> Unit) {
    val pagerState = rememberPagerState(pageCount = { heroBanners.size })
    val scope = rememberCoroutineScope()

    // Auto-advance every 3s
    LaunchedEffect(Unit) {
        while (true) {
            delay(3000)
            val next = (pagerState.currentPage + 1) % heroBanners.size
            pagerState.animateScrollToPage(next, animationSpec = tween(600))
        }
    }
    LaunchedEffect(pagerState.currentPage) {
        onIndexChange(pagerState.currentPage)
    }

    Box(modifier = Modifier.fillMaxWidth().height(220.dp)) {
        HorizontalPager(state = pagerState) { page ->
            val (title, subtitle, bg) = heroBanners[page]
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(Brush.verticalGradient(listOf(bg, bg.copy(alpha = 0.7f), Color.Black)))
            ) {
                // Gradient overlay
                Box(
                    modifier = Modifier.fillMaxSize().background(
                        Brush.verticalGradient(listOf(Color.Transparent, Color.Black.copy(alpha = 0.7f)))
                    )
                )
                Column(
                    modifier = Modifier.align(Alignment.BottomStart).padding(16.dp)
                ) {
                    Surface(
                        color = RoseRed,
                        shape = RoundedCornerShape(4.dp)
                    ) {
                        Text(
                            "LUXURY SPONSOR",
                            color = Color.White, fontSize = 9.sp,
                            fontWeight = FontWeight.Black,
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                        )
                    }
                    Spacer(Modifier.height(6.dp))
                    Text(title, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                    Text(subtitle, color = Color.White.copy(alpha = 0.75f), fontSize = 12.sp)
                }
            }
        }
        // Dot indicators bottom-center
        Row(
            modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 12.dp),
            horizontalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            repeat(heroBanners.size) { i ->
                val width by animateDpAsState(if (i == pagerState.currentPage) 20.dp else 6.dp)
                Box(
                    modifier = Modifier
                        .height(6.dp)
                        .width(width)
                        .background(
                            if (i == pagerState.currentPage) ChampagneGold else Color.White.copy(0.4f),
                            CircleShape
                        )
                )
            }
        }
    }
}

// ─── Glass Search Bar ─────────────────────────────────────────────────────────

@Composable
fun GlassSearchBar(selectedCity: String, onClick: () -> Unit, onLocationTap: () -> Unit) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .shadow(elevation = 8.dp, shape = RoundedCornerShape(18.dp), spotColor = RoyalNavy.copy(alpha = 0.12f))
            .background(Color.White.copy(alpha = 0.98f), RoundedCornerShape(18.dp))
            .border(1.5.dp, ChampagneGold.copy(alpha = 0.45f), RoundedCornerShape(18.dp))
            .clickable { onClick() }
            .padding(horizontal = 16.dp, vertical = 14.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(Icons.Default.Search, null, tint = SlateGray)
            Spacer(Modifier.width(10.dp))
            Text(
                "Search banquets, caterers, decor...",
                color = SlateGray,
                fontSize = 14.sp,
                modifier = Modifier.weight(1f)
            )
            Box(modifier = Modifier.width(1.dp).height(22.dp).background(LightSlate))
            Spacer(Modifier.width(10.dp))
            Row(
                modifier = Modifier.clickable { onLocationTap() },
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(Icons.Default.LocationOn, null, tint = EmeraldGreen, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(4.dp))
                Text(selectedCity, color = RoyalNavy, fontWeight = FontWeight.Bold, fontSize = 13.sp)
            }
        }
    }
}

// ─── Two-Section Category Rows ───────────────────────────────────────────────

internal data class CategoryDef(val name: String, val emoji: String, val color: Color)

@Composable
fun CategoryDualSection(onCategoryTap: (String) -> Unit) {
    // Dynamic array representing backend-driven category schemas
    val dynamicCategories = remember {
        listOf(
            CategoryDef("Kalyana Mandapams", "🏛", Color(0xFFFFF3E0)),
            CategoryDef("Banquet Halls",    "🏢", Color(0xFFE3F2FD)),
            CategoryDef("Open Lawns",      "🌿", Color(0xFFE8F5E9)),
            CategoryDef("Luxury Resorts",   "🏨", Color(0xFFF3E5F5)),
            CategoryDef("Royal Palaces",    "👑", Color(0xFFFFE8E8)),
            CategoryDef("Photography", "📷", Color(0xFFFFF8E1)),
            CategoryDef("Catering",    "🍽", Color(0xFFFCE4EC)),
            CategoryDef("Decorators",  "🌸", Color(0xFFE0F7FA)),
            CategoryDef("Makeup Art",  "💄", Color(0xFFECEFF1)),
            CategoryDef("DJs & AV",   "🎧", Color(0xFFF5F5F5)),
            CategoryDef("Mehendi Artists", "🌿", Color(0xFFE8F5E9)),
            CategoryDef("Bridal Wear",    "👗", Color(0xFFFCE4EC)),
            CategoryDef("Jewellery",      "💎", Color(0xFFE3F2FD)),
            CategoryDef("Priests & Pandits", "🕉", Color(0xFFFFF3E0)),
            CategoryDef("Vintage Cars", "🚗", Color(0xFFE0F7FA)),
            CategoryDef("Choreographers", "💃", Color(0xFFF3E5F5))
        )
    }

    val chunkedCategories = dynamicCategories.chunked(5)
    val sectionTitles = listOf("Core Venues & Mandaps", "Specialist Services", "Bridal Essentials & Rituals", "Premium Extras")

    Column(modifier = Modifier.fillMaxWidth()) {
        chunkedCategories.forEachIndexed { index, categoryChunk ->
            Text(
                text = sectionTitles.getOrElse(index) { "More Categories" },
                fontWeight = FontWeight.Black,
                fontSize = 15.sp,
                color = RoyalNavy,
                modifier = Modifier.padding(start = 16.dp, end = 16.dp, bottom = 8.dp)
            )
            LazyRow(
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(14.dp),
                modifier = Modifier.fillMaxWidth().padding(bottom = if (index == chunkedCategories.lastIndex) 0.dp else 22.dp)
            ) {
                items(categoryChunk) { cat ->
                    CategorySquareCard(
                        name = cat.name,
                        emoji = cat.emoji,
                        bgColor = cat.color,
                        onClick = { onCategoryTap(cat.name) }
                    )
                }
            }
        }
    }
}

@Composable
fun CategorySquareCard(name: String, emoji: String, bgColor: Color, onClick: () -> Unit) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.92f else 1f,
        animationSpec = AntigravitySpring.WeightlessSpec,
        label = "chipSpringScale"
    )
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .width(74.dp)
            .scale(scale)
            .clickable(
                interactionSource = interactionSource,
                indication = null
            ) {
                onClick()
            }
    ) {
        // Small Square Card with Emoji
        Surface(
            modifier = Modifier
                .size(68.dp)
                .neumorphicShadow(borderRadius = 16.dp, shadowRadius = 4.dp),
            color = bgColor.copy(alpha = 0.9f),
            shape = RoundedCornerShape(16.dp),
            border = BorderStroke(1.2.dp, Color.White)
        ) {
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier.fillMaxSize()
            ) {
                Text(emoji, fontSize = 28.sp)
            }
        }
        
        Spacer(Modifier.height(6.dp))
        
        // Centered Small Label below square
        Text(
            text = name,
            fontSize = 10.sp,
            fontWeight = FontWeight.Bold,
            color = RoyalNavy,
            textAlign = TextAlign.Center,
            maxLines = 2,
            lineHeight = 12.sp,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.fillMaxWidth().padding(horizontal = 2.dp)
        )
    }
}

// ─── Section Header ───────────────────────────────────────────────────────────

@Composable
fun SectionHeader(title: String, subtitle: String = "") {
    Column(modifier = Modifier.padding(horizontal = 16.dp)) {
        Text(title, fontWeight = FontWeight.Bold, fontSize = 17.sp, color = RoyalNavy)
        if (subtitle.isNotEmpty()) {
            Text(subtitle, fontSize = 11.sp, color = SlateGray)
        }
    }
}

// ─── Trending Venues (Advanced Listing Cards) ─────────────────────────────────

@Composable
fun TrendingVenuesList(
    venues: List<VenueFeedItem>,
    wishlistedIds: Set<String>,
    onVenueTap: (String) -> Unit,
    onWishlistToggle: (String) -> Unit
) {
    val firstRow = remember(venues) { venues.filterIndexed { index, _ -> index % 2 == 0 } }
    val secondRow = remember(venues) { venues.filterIndexed { index, _ -> index % 2 != 0 } }
    
    Column(verticalArrangement = Arrangement.spacedBy(18.dp)) {
        // Row 1
        LazyRow(
            contentPadding = PaddingValues(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            items(firstRow) { venue ->
                AdvancedVenueCard(
                    venue = venue,
                    isWishlisted = venue.id in wishlistedIds,
                    onTap = { onVenueTap(venue.id) },
                    onWishlistToggle = { onWishlistToggle(venue.id) }
                )
            }
        }
        
        // Row 2 (Staggered start for parallax feel)
        LazyRow(
            contentPadding = PaddingValues(start = 48.dp, end = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            items(secondRow) { venue ->
                AdvancedVenueCard(
                    venue = venue,
                    isWishlisted = venue.id in wishlistedIds,
                    onTap = { onVenueTap(venue.id) },
                    onWishlistToggle = { onWishlistToggle(venue.id) }
                )
            }
        }
    }
}

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun AdvancedVenueCard(
    venue: VenueFeedItem,
    isWishlisted: Boolean,
    onTap: () -> Unit,
    onWishlistToggle: () -> Unit
) {
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    var isPerPlate by remember { mutableStateOf(true) }
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.96f else 1f,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessHigh)
    )
    val borderModifier = if (venue.isSponsored) {
        Modifier.border(2.dp, Brush.horizontalGradient(listOf(ChampagneGold, DarkGold)), RoundedCornerShape(16.dp))
    } else Modifier.border(1.dp, Color.White.copy(alpha = 0.6f), RoundedCornerShape(16.dp))

    Box(
        modifier = Modifier
            .width(260.dp)
            .scale(scale)
            .neumorphicShadow(borderRadius = 16.dp, shadowRadius = 8.dp)
            .then(borderModifier)
            .background(SoftMist, RoundedCornerShape(16.dp))
            .clickable(
                interactionSource = interactionSource,
                indication = null
            ) {
                onTap()
            }
    ) {
        Column {
            // ── Image & Video Carousel section ──────────────────────────────
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(140.dp)
                    .clip(RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp))
            ) {
                val pagerState = rememberPagerState(pageCount = { if (venue.photos.isNotEmpty()) venue.photos.size else 1 })
                
                HorizontalPager(state = pagerState, modifier = Modifier.fillMaxSize()) { page ->
                    // Use gradients to simulate photos
                    val brush = Brush.verticalGradient(
                        colors = listOf(
                            Color(0xFFCBD5E1), Color(0xFF94A3B8)
                        )
                    )
                    Box(modifier = Modifier.fillMaxSize().background(brush))
                }

                // Dot indicators
                if (venue.photos.size > 1) {
                    Row(
                        modifier = Modifier.align(Alignment.BottomCenter).padding(bottom = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        repeat(venue.photos.size) { i ->
                            Box(
                                modifier = Modifier
                                    .size(if (i == pagerState.currentPage) 6.dp else 4.dp)
                                    .background(if (i == pagerState.currentPage) Color.White else Color.White.copy(alpha = 0.5f), CircleShape)
                            )
                        }
                    }
                }

                // Video Overlay Icon
                if (venue.videoUrl.isNotEmpty()) {
                    Box(
                        modifier = Modifier
                            .align(Alignment.Center)
                            .size(36.dp)
                            .background(Color.Black.copy(alpha = 0.4f), CircleShape)
                            .border(1.dp, Color.White.copy(alpha = 0.6f), CircleShape),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(Icons.Default.PlayArrow, null, tint = Color.White, modifier = Modifier.size(20.dp))
                    }
                }

                // Sponsored badge
                if (venue.isSponsored) {
                    Box(
                        modifier = Modifier
                            .background(DarkGold, RoundedCornerShape(bottomEnd = 10.dp))
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text("PROMOTED", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Black)
                    }
                }
                // Fast-filling badge
                if (venue.isFastFilling) {
                    Surface(
                        modifier = Modifier.align(Alignment.BottomStart).padding(8.dp),
                        color = Color(0xFFFFE4B5).copy(alpha = 0.9f),
                        shape = RoundedCornerShape(6.dp)
                    ) {
                        Text(
                            "🔥 FILLING FAST",
                            fontSize = 8.sp, fontWeight = FontWeight.Black, color = Color(0xFF92400E),
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                        )
                    }
                }
                // Escrow badge
                if (venue.isEscrowProtected) {
                    Surface(
                        modifier = Modifier
                            .align(if (venue.isFastFilling) Alignment.BottomEnd else Alignment.BottomStart)
                            .padding(8.dp),
                        color = Color.White.copy(alpha = 0.9f),
                        shape = RoundedCornerShape(6.dp),
                        border = BorderStroke(1.dp, EmeraldGreen.copy(alpha = 0.5f))
                    ) {
                        Row(
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(Icons.Default.Security, null, tint = EmeraldGreen, modifier = Modifier.size(10.dp))
                            Spacer(Modifier.width(3.dp))
                            Text("Escrow Guard", fontSize = 8.sp, color = RoyalNavy, fontWeight = FontWeight.Bold)
                        }
                    }
                }
                // Wishlist heart
                IconButton(
                    onClick = onWishlistToggle,
                    modifier = Modifier.align(Alignment.TopEnd)
                ) {
                    Icon(
                        if (isWishlisted) Icons.Default.Favorite else Icons.Outlined.FavoriteBorder,
                        null,
                        tint = if (isWishlisted) RoseRed else Color.White,
                        modifier = Modifier.size(20.dp)
                    )
                }
                // Verified badge
                if (venue.isVerified) {
                    Surface(
                        modifier = Modifier.align(Alignment.TopStart).padding(8.dp),
                        color = EmeraldGreen,
                        shape = CircleShape
                    ) {
                        Icon(
                            Icons.Default.Verified,
                            null, tint = Color.White,
                            modifier = Modifier.padding(2.dp).size(12.dp)
                        )
                    }
                }
            }

            // ── Info section ───────────────────────────────────────────────
            Column(modifier = Modifier.padding(12.dp)) {
                Row(
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        venue.name,
                        fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy,
                        maxLines = 1, overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Star, null, tint = ChampagneGold, modifier = Modifier.size(12.dp))
                        Spacer(Modifier.width(2.dp))
                        Text(venue.rating.toString(), fontSize = 11.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                    }
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Default.LocationOn, null, tint = SlateGray, modifier = Modifier.size(10.dp))
                    Text(venue.locality, fontSize = 10.sp, color = SlateGray)
                }

                // Tags row
                LazyRow(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    modifier = Modifier.padding(top = 6.dp)
                ) {
                    items(venue.tags.take(3)) { tag ->
                        Surface(
                            color = Color.White.copy(alpha = 0.5f),
                            shape = RoundedCornerShape(4.dp),
                            border = BorderStroke(1.dp, Color.White)
                        ) {
                            Text(tag, fontSize = 9.sp, color = SlateGray, modifier = Modifier.padding(horizontal = 5.dp, vertical = 2.dp))
                        }
                    }
                }

                // Pricing toggle row (Neumorphic Embossed Look)
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 10.dp)
                        .background(Color.White.copy(alpha = 0.4f), RoundedCornerShape(8.dp))
                        .border(1.dp, Color.White.copy(alpha = 0.5f), RoundedCornerShape(8.dp))
                        .padding(8.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            AnimatedContent(targetState = isPerPlate, label = "PricingAnim") { perPlate ->
                                Text(
                                    if (perPlate) "₹${venue.platePrice.toInt()}" else "₹${String.format("%,.0f", venue.price)}",
                                    fontSize = 15.sp, fontWeight = FontWeight.Black, color = RoyalNavy
                                )
                            }
                            Text(
                                if (isPerPlate) "Fixed Base Price / Plate" else "Fixed Package Cost",
                                fontSize = 8.sp, color = SlateGray
                            )
                        }
                        Surface(
                            onClick = { isPerPlate = !isPerPlate },
                            color = Color.White.copy(alpha = 0.8f),
                            shape = RoundedCornerShape(6.dp),
                            border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.6f))
                        ) {
                            Text(
                                if (isPerPlate) "Show Package" else "Show Plate",
                                fontSize = 8.sp, fontWeight = FontWeight.Bold, color = DarkGold,
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 5.dp)
                            )
                        }
                    }
                }

                // Action footer
                Row(
                    modifier = Modifier.fillMaxWidth().padding(top = 12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        IconButton(
                            onClick = {},
                            modifier = Modifier.size(32.dp).background(Color.White.copy(alpha = 0.6f), CircleShape).border(1.dp, Color.White, CircleShape)
                        ) {
                            Icon(Icons.Default.Chat, null, tint = RoyalNavy, modifier = Modifier.size(14.dp))
                        }
                        IconButton(
                            onClick = onWishlistToggle,
                            modifier = Modifier.size(32.dp).background(Color.White.copy(alpha = 0.6f), CircleShape).border(1.dp, Color.White, CircleShape)
                        ) {
                            Icon(
                                if (isWishlisted) Icons.Default.Favorite else Icons.Outlined.FavoriteBorder,
                                null,
                                tint = if (isWishlisted) RoseRed else SlateGray,
                                modifier = Modifier.size(14.dp)
                            )
                        }
                    }
                    Button(
                        onClick = onTap,
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                        shape = RoundedCornerShape(8.dp),
                        contentPadding = PaddingValues(horizontal = 14.dp, vertical = 8.dp),
                        modifier = Modifier.height(32.dp)
                    ) {
                        Text("⚡ Book Now", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }
            }
        }
    }
}

// ─── Featured Deal Banner ─────────────────────────────────────────────────────

@Composable
fun FeaturedDealBanner() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .height(110.dp)
            .background(
                Brush.horizontalGradient(listOf(RoyalNavy, Color(0xFF1E3A5F))),
                RoundedCornerShape(16.dp)
            )
            .clickable {}
            .padding(16.dp),
        contentAlignment = Alignment.CenterStart
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Surface(
                    color = ChampagneGold.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(4.dp),
                    border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.6f))
                ) {
                    Text(
                        "FEATURED DEALS",
                        color = ChampagneGold, fontSize = 9.sp, fontWeight = FontWeight.Black,
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                    )
                }
                Spacer(Modifier.height(6.dp))
                Text("Get up to 20% off on premium caterers", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 15.sp)
                Text("Limited time offer • Book before June 30", color = Color.White.copy(0.65f), fontSize = 11.sp)
            }
            Icon(Icons.Default.KeyboardArrowRight, null, tint = ChampagneGold, modifier = Modifier.size(28.dp))
        }
    }
}

// ─── Elite Services Shelf ─────────────────────────────────────────────────────

@Composable
fun EliteServicesList(services: List<ServiceItem>, onTap: (String) -> Unit) {
    val chunkedServices = remember(services) { services.chunked(2) }
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        items(chunkedServices) { pair ->
            Column(verticalArrangement = Arrangement.spacedBy(14.dp)) {
                pair.forEach { service ->
                    Card(
                        modifier = Modifier.width(180.dp).clickable { onTap(service.category) },
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White),
                        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
                    ) {
                        Column {
                            Box(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .height(90.dp)
                                    .background(
                                        Brush.verticalGradient(listOf(Color(0xFFE0E7FF), Color(0xFFC7D2FE)))
                                    )
                            )
                            Column(modifier = Modifier.padding(10.dp)) {
                                Text(service.name, fontWeight = FontWeight.Bold, fontSize = 12.sp, color = RoyalNavy, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                Text(service.category, fontSize = 10.sp, color = SlateGray)
                                Spacer(Modifier.height(6.dp))
                                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween, verticalAlignment = Alignment.CenterVertically) {
                                    Text("₹${String.format("%,.0f", service.price)}", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = RoyalNavy)
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Icon(Icons.Default.Star, null, tint = ChampagneGold, modifier = Modifier.size(11.dp))
                                        Text(service.rating.toString(), fontSize = 10.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// ─── City Browse Strip ────────────────────────────────────────────────────────

@Composable
fun getCityColors(cityName: String): List<Color> = when (cityName) {
    "Hyderabad" -> listOf(Color(0xFF0F172A), Color(0xFF1E3A8A)) // Slate Navy
    "Secunderabad" -> listOf(Color(0xFF312E81), Color(0xFF4F46E5)) // Indigo
    "Warangal" -> listOf(Color(0xFF581C87), Color(0xFF7E22CE)) // Royal Purple
    "Vijayawada" -> listOf(Color(0xFF065F46), Color(0xFF10B981)) // Emerald Green
    "Guntur" -> listOf(Color(0xFF7C2D12), Color(0xFFD97706)) // Amber Copper
    else -> listOf(Color(0xFF0F172A), Color(0xFF1E293B))
}

@Composable
fun CityParallaxCard(
    city: CityItem,
    selected: Boolean,
    onClick: () -> Unit
) {
    var cardX by remember { mutableStateOf(0f) }
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scale by animateFloatAsState(
        targetValue = if (isPressed) 0.95f else 1f,
        animationSpec = spring(dampingRatio = Spring.DampingRatioMediumBouncy, stiffness = Spring.StiffnessHigh),
        label = "cityCardScale"
    )

    Card(
        modifier = Modifier
            .width(180.dp)
            .height(100.dp)
            .scale(scale)
            .onGloballyPositioned { coordinates ->
                cardX = coordinates.localToWindow(Offset.Zero).x
            }
            .clickable(interactionSource = interactionSource, indication = null) { onClick() },
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(
            1.5.dp,
            if (selected) ChampagneGold else Color.White.copy(alpha = 0.5f)
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            // Background Image / Gradient that shifts based on scroll position (cardX)
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .graphicsLayer {
                        translationX = -cardX * 0.3f
                    }
                    .background(
                        Brush.linearGradient(
                            colors = getCityColors(city.name),
                            start = Offset(0f, 0f),
                            end = Offset(600f, 600f)
                        )
                    )
            )
            // Beautiful glassmorphism overlay inside
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(
                        Brush.verticalGradient(
                            listOf(Color.Transparent, Color.Black.copy(alpha = 0.6f))
                        )
                    )
                    .padding(16.dp),
                contentAlignment = Alignment.BottomStart
            ) {
                Column {
                    Text(
                        text = city.name.uppercase(),
                        fontWeight = FontWeight.Black,
                        color = Color.White,
                        fontSize = 14.sp,
                        letterSpacing = 1.sp
                    )
                    Text(
                        text = city.region,
                        fontWeight = FontWeight.Medium,
                        color = Color.White.copy(alpha = 0.8f),
                        fontSize = 10.sp
                    )
                }
            }
        }
    }
}

@Composable
fun CityBrowseStrip(cities: List<CityItem>, selectedCity: String, onCityTap: (String) -> Unit) {
    val scrollState = rememberLazyListState()
    LazyRow(
        state = scrollState,
        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp),
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        items(cities) { city ->
            val selected = city.name == selectedCity
            CityParallaxCard(
                city = city,
                selected = selected,
                onClick = { onCityTap(city.name) }
            )
        }
    }
}

// ─── Category Bottom Sheet ────────────────────────────────────────────────────

@Composable
fun CategoryBottomSheetContent(
    category: String,
    onDismiss: () -> Unit,
    onNavigate: (String) -> Unit
) {
    val subCategories = when (category) {
        "Banquets"     -> listOf("AC Banquet Hall", "Non-AC Hall", "Garden / Lawn", "Terrace Venue", "5-Star Hotel")
        "Decorators"   -> listOf("Temple-Style Mandap", "Rajasthani Royal", "Mogra / Jasmine", "Geometric Minimalist", "Floral Canopy", "Boho / Rustic Bamboo")
        "Photography"  -> listOf("Candid Photography", "Traditional", "Drone / Aerial", "Pre-Wedding Shoot", "Cinematic Film")
        "Catering"     -> listOf("Veg Catering", "Non-Veg Catering", "Live Counters", "Mehfil Style", "Jain Menu")
        else           -> listOf("Premium", "Standard", "Budget")
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp)
            .padding(bottom = 40.dp)
    ) {
        // Sheet handle
        Box(
            modifier = Modifier.width(40.dp).height(4.dp)
                .background(LightSlate, CircleShape)
                .align(Alignment.CenterHorizontally)
        )
        Spacer(Modifier.height(16.dp))
        Text("Explore $category", fontWeight = FontWeight.Black, fontSize = 20.sp, color = RoyalNavy)
        Text("Select a category below", fontSize = 12.sp, color = SlateGray)
        Spacer(Modifier.height(20.dp))
        subCategories.forEach { sub ->
            Surface(
                onClick = { onNavigate(sub) },
                color = PearlWhite,
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 14.dp).fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(sub, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, color = RoyalNavy)
                    Icon(Icons.Default.KeyboardArrowRight, null, tint = ChampagneGold)
                }
            }
            Spacer(Modifier.height(8.dp))
        }
    }
}

// ─── Radar / Geolocation Bottom Sheet ────────────────────────────────────────

@Composable
fun RadarBottomSheetContent(
    radiusKm: Float,
    onRadiusChange: (Float) -> Unit,
    onConfirm: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 20.dp)
            .padding(bottom = 40.dp)
    ) {
        Box(
            modifier = Modifier.width(40.dp).height(4.dp)
                .background(LightSlate, CircleShape)
                .align(Alignment.CenterHorizontally)
        )
        Spacer(Modifier.height(20.dp))
        Text("📡  Location Radar", fontWeight = FontWeight.Black, fontSize = 20.sp, color = RoyalNavy)
        Text("Find venues within a radius of your location", fontSize = 12.sp, color = SlateGray)
        Spacer(Modifier.height(24.dp))

        // Auto-detect location button
        Button(
            onClick = {},
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
            shape = RoundedCornerShape(12.dp)
        ) {
            Icon(Icons.Default.MyLocation, null, tint = Color.White)
            Spacer(Modifier.width(8.dp))
            Text("Use Current Location", fontWeight = FontWeight.Bold)
        }

        Spacer(Modifier.height(24.dp))
        Text(
            "Search Radius: ${radiusKm.toInt()} km",
            fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy
        )
        Spacer(Modifier.height(8.dp))
        Slider(
            value = radiusKm,
            onValueChange = onRadiusChange,
            valueRange = 5f..100f,
            steps = 18,
            colors = SliderDefaults.colors(
                thumbColor = ChampagneGold,
                activeTrackColor = RoyalNavy,
                inactiveTrackColor = LightSlate
            )
        )
        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
            listOf("5km", "15km", "50km", "100km").forEach { label ->
                Text(label, fontSize = 10.sp, color = SlateGray)
            }
        }
        Spacer(Modifier.height(24.dp))
        Button(
            onClick = onConfirm,
            modifier = Modifier.fillMaxWidth(),
            colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
            shape = RoundedCornerShape(12.dp)
        ) {
            Text("Find Venues in ${radiusKm.toInt()}km Radius", fontWeight = FontWeight.Bold)
        }
    }
}

// ─── Shimmer Placeholders ─────────────────────────────────────────────────────

@Composable
fun ShimmerVenueRow() {
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(3) {
            ShimmerBox(width = 290.dp, height = 300.dp, cornerRadius = 16.dp)
        }
    }
}

@Composable
fun ShimmerServiceRow() {
    LazyRow(
        contentPadding = PaddingValues(horizontal = 16.dp),
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        items(4) {
            ShimmerBox(width = 180.dp, height = 160.dp, cornerRadius = 12.dp)
        }
    }
}

@Composable
fun ShimmerBox(
    width: androidx.compose.ui.unit.Dp,
    height: androidx.compose.ui.unit.Dp,
    cornerRadius: androidx.compose.ui.unit.Dp
) {
    val transition = rememberInfiniteTransition()
    val shimmerOffset by transition.animateFloat(
        initialValue = -1f, targetValue = 2f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1200, easing = LinearEasing),
            repeatMode = RepeatMode.Restart
        )
    )
    val brush = Brush.linearGradient(
        colors = listOf(ShimmerBase, ShimmerHighlight, ShimmerBase),
        start = Offset(shimmerOffset * 300f, 0f),
        end   = Offset(shimmerOffset * 300f + 300f, 0f)
    )
    Box(
        modifier = Modifier
            .width(width)
            .height(height)
            .background(brush, RoundedCornerShape(cornerRadius))
    )
}

// ─── Unified High-Trust App Footer Component ─────────────────────────────────

@Composable
fun AppFooter() {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .background(RoyalNavy)
            .padding(horizontal = 24.dp, vertical = 32.dp)
    ) {
        // Platform branding and celebratory Made-in-India badge
        Row(
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "GoMandap",
                color = Color.White,
                fontWeight = FontWeight.Black,
                fontSize = 22.sp
            )
            Spacer(Modifier.width(8.dp))
            Surface(
                color = ChampagneGold.copy(alpha = 0.2f),
                shape = RoundedCornerShape(4.dp),
                border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.5f))
            ) {
                Text(
                    text = "🇮🇳 Made for India",
                    color = ChampagneGold,
                    fontSize = 10.sp,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                )
            }
        }
        Text(
            text = "Great Indian Weddings, Instantly Booked. Fixed Prices. Zero Quote Chats.",
            color = SlateGray,
            fontSize = 12.sp,
            modifier = Modifier.padding(top = 8.dp)
        )
        
        Spacer(Modifier.height(24.dp))
        Box(modifier = Modifier.fillMaxWidth().height(1.dp).background(LightSlate.copy(alpha = 0.15f)))
        Spacer(Modifier.height(20.dp))

        // Quick Navigation & Assurance Grid
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "DISCOVER",
                    color = ChampagneGold,
                    fontWeight = FontWeight.Black,
                    fontSize = 11.sp
                )
                Spacer(Modifier.height(8.dp))
                listOf("Kalyana Mandapams", "AC Banquet Halls", "Premium Caterers", "Wedding Decorators", "Pandits & Priests").forEach { item ->
                    Text(
                        text = item,
                        color = LightSlate.copy(alpha = 0.75f),
                        fontSize = 11.sp,
                        modifier = Modifier
                            .padding(vertical = 4.dp)
                            .clickable {}
                    )
                }
            }
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "OUR ASSURANCE",
                    color = ChampagneGold,
                    fontWeight = FontWeight.Black,
                    fontSize = 11.sp
                )
                Spacer(Modifier.height(8.dp))
                listOf("🔒 100% Safe Vault", "🤝 Fixed Price Guarantee", "✅ Verified Vendors Only", "🛡️ 24/7 Ground Ops Support").forEach { item ->
                    Text(
                        text = item,
                        color = LightSlate.copy(alpha = 0.75f),
                        fontSize = 11.sp,
                        modifier = Modifier
                            .padding(vertical = 4.dp)
                            .clickable {}
                    )
                }
            }
        }

        Spacer(Modifier.height(24.dp))
        Box(modifier = Modifier.fillMaxWidth().height(1.dp).background(LightSlate.copy(alpha = 0.15f)))
        Spacer(Modifier.height(20.dp))

        // Corporate & Contact Information (Indian HQ + GSTIN)
        Text(
            text = "CORPORATE REGISTERED OFFICE",
            color = ChampagneGold,
            fontWeight = FontWeight.Black,
            fontSize = 11.sp
        )
        Text(
            text = "GoMandap Tech India Private Limited\n4th Floor, Gold Crest Towers, Banjara Hills Road No. 2, Hyderabad, Telangana - 500034",
            color = LightSlate.copy(alpha = 0.7f),
            fontSize = 11.sp,
            modifier = Modifier.padding(top = 6.dp)
        )
        Text(
            text = "GSTIN: 36AAFCD8793M1Z8",
            color = LightSlate,
            fontSize = 11.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(top = 4.dp)
        )

        Spacer(Modifier.height(18.dp))

        // Contact Helpline and Support VIP Bars
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(vertical = 2.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Phone,
                contentDescription = null,
                tint = EmeraldGreen,
                modifier = Modifier.size(14.dp)
            )
            Spacer(Modifier.width(8.dp))
            Text(
                text = "Toll-Free Helpline: 1800-GOMANDAP (1800-466-26327)",
                color = Color.White,
                fontSize = 11.sp,
                fontWeight = FontWeight.Bold
            )
        }
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = Modifier.padding(vertical = 2.dp)
        ) {
            Icon(
                imageVector = Icons.Default.Email,
                contentDescription = null,
                tint = ChampagneGold,
                modifier = Modifier.size(14.dp)
            )
            Spacer(Modifier.width(8.dp))
            Text(
                text = "VIP Concierge: VIPconcierge@gomandap.in",
                color = Color.White,
                fontSize = 11.sp
            )
        }

        Spacer(Modifier.height(24.dp))
        Box(modifier = Modifier.fillMaxWidth().height(1.dp).background(LightSlate.copy(alpha = 0.15f)))
        Spacer(Modifier.height(20.dp))

        // Social Connect & Terms Link Strip
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                Text("Terms", color = SlateGray, fontSize = 10.sp, modifier = Modifier.clickable {})
                Text("Privacy", color = SlateGray, fontSize = 10.sp, modifier = Modifier.clickable {})
                Text("Refund Policy", color = SlateGray, fontSize = 10.sp, modifier = Modifier.clickable {})
                Text("Vault Terms", color = SlateGray, fontSize = 10.sp, modifier = Modifier.clickable {})
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf("IG", "YT", "FB", "LI").forEach { platform ->
                    Box(
                        modifier = Modifier
                            .background(LightSlate.copy(alpha = 0.1f), CircleShape)
                            .padding(horizontal = 8.dp, vertical = 6.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = platform,
                            color = ChampagneGold,
                            fontSize = 9.sp,
                            fontWeight = FontWeight.Black
                        )
                    }
                }
            }
        }
        Spacer(Modifier.height(20.dp))
        Text(
            text = "© 2026 GoMandap Tech India Pvt. Ltd. Proudly crafted for Great Indian Weddings. All rights reserved.",
            color = SlateGray.copy(alpha = 0.5f),
            fontSize = 9.sp,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )
    }
}

// end of HomeScreen.kt

data class Vendor(
    val id: String,
    val name: String,
    val locality: String,
    val basePrice: Double
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CategoryQuickDetailSheet(
    categoryName: String,
    vendors: List<Vendor>,
    onDismiss: () -> Unit,
    onVendorTap: (String) -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = Color.White,
        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Column {
                    Text(
                        text = categoryName,
                        fontWeight = FontWeight.Black,
                        fontSize = 20.sp,
                        color = RoyalNavy
                    )
                    Text(
                        text = "Verified Elite Partners • Instant Payouts",
                        fontSize = 11.sp,
                        color = SlateGray
                    )
                }
                Surface(
                    color = EmeraldGreen.copy(alpha = 0.1f),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.Verified, null, tint = EmeraldGreen, modifier = Modifier.size(12.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("100% Verified", color = EmeraldGreen, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }

            Divider(color = Color.LightGray.copy(alpha = 0.3f))

            if (vendors.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 40.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("🏛️", fontSize = 40.sp)
                        Spacer(Modifier.height(8.dp))
                        Text("No active verified partners in this category yet.", fontSize = 12.sp, color = Color.Gray, textAlign = TextAlign.Center)
                    }
                }
            } else {
                vendors.forEach { vendor ->
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { 
                                onDismiss()
                                onVendorTap(vendor.id)
                            },
                        shape = RoundedCornerShape(16.dp),
                        colors = CardDefaults.cardColors(containerColor = SoftMist),
                        border = BorderStroke(1.dp, Color.White)
                    ) {
                        Row(
                            modifier = Modifier.padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Text(vendor.name, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                                    Spacer(Modifier.width(4.dp))
                                    Icon(Icons.Default.Verified, null, tint = EmeraldGreen, modifier = Modifier.size(14.dp))
                                }
                                Text(vendor.locality, fontSize = 11.sp, color = SlateGray)
                                Spacer(Modifier.height(4.dp))
                                Text("Starting Price: ₹${"%,.0f".format(vendor.basePrice)}", fontWeight = FontWeight.Black, fontSize = 12.sp, color = EmeraldGreen)
                            }
                            Icon(Icons.Default.KeyboardArrowRight, null, tint = ChampagneGold)
                        }
                    }
                }
            }

            Spacer(Modifier.height(24.dp))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun InstantPackageDetailSheet(
    pkg: InstantPackage,
    onDismiss: () -> Unit,
    onBookClick: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = Color.White,
        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(24.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Header
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth()
            ) {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .background(Color(pkg.tagColor).copy(alpha = 0.1f), RoundedCornerShape(12.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Text(pkg.emoji, fontSize = 24.sp)
                }
                Spacer(Modifier.width(12.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(pkg.title, fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                    Text(pkg.category + " • Instant Confirmation", fontSize = 11.sp, color = SlateGray)
                }
            }

            Divider(color = Color.LightGray.copy(alpha = 0.3f))

            // Pricing Block
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(SoftMist, RoundedCornerShape(12.dp))
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Total Fixed Payout Cost", fontSize = 10.sp, color = SlateGray)
                    Text(pkg.price, fontWeight = FontWeight.Black, fontSize = 24.sp, color = RoyalNavy)
                    Text(pkg.period, fontSize = 10.sp, color = Color.Gray)
                }
                Surface(
                    color = EmeraldGreen,
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Text(
                        "🔒 ESCROW LOCKED",
                        color = Color.White,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Black,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                    )
                }
            }

            // Inclusions / Amenities details
            Text("What's Included in Package", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                listOf(
                    pkg.amenity1Icon to pkg.amenity1Text,
                    pkg.amenity2Icon to pkg.amenity2Text,
                    pkg.amenity3Icon to pkg.amenity3Text
                ).forEach { (icon, text) ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(icon, null, tint = ChampagneGold, modifier = Modifier.size(16.dp))
                        Spacer(Modifier.width(8.dp))
                        Text(text, fontSize = 12.sp, color = RoyalNavy, fontWeight = FontWeight.Medium)
                    }
                }
            }

            Divider(color = Color.LightGray.copy(alpha = 0.3f))

            // Escrow Milestone Split explanation
            Text("100% Protected Escrow Payout Model", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            Text(
                "GoMandap secures your payment in neutral escrow. Payouts are split into three structured stages automatically:",
                fontSize = 11.sp,
                color = SlateGray,
                lineHeight = 15.sp
            )

            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(modifier = Modifier.size(8.dp).background(EmeraldGreen, CircleShape))
                    Spacer(Modifier.width(8.dp))
                    Text("20% Booking Confirmation slot (Released instantly to confirm calendar)", fontSize = 11.sp, color = RoyalNavy)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(modifier = Modifier.size(8.dp).background(ChampagneGold, CircleShape))
                    Spacer(Modifier.width(8.dp))
                    Text("50% Pre-Event Setup confirmation (Held until setup starts)", fontSize = 11.sp, color = RoyalNavy)
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(modifier = Modifier.size(8.dp).background(Color.Red, CircleShape))
                    Spacer(Modifier.width(8.dp))
                    Text("30% Post-Event Handover approval (Held until you approve quality)", fontSize = 11.sp, color = RoyalNavy)
                }
            }

            Spacer(Modifier.height(8.dp))

            // Action Buttons
            Button(
                onClick = {
                    onDismiss()
                    onBookClick()
                },
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .height(48.dp)
            ) {
                Text("Lock Package Now", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            }

            Spacer(Modifier.height(24.dp))
        }
    }
}

@Composable
fun ShoppableGalleryBanner(onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.5f))
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(140.dp)
                .background(
                    Brush.verticalGradient(
                        listOf(RoyalNavy, Color(0xFF1E293B))
                    )
                )
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(horizontal = 20.dp, vertical = 16.dp)
            ) {
                Column(modifier = Modifier.align(Alignment.CenterStart)) {
                    Surface(
                        color = ChampagneGold,
                        shape = RoundedCornerShape(6.dp),
                        modifier = Modifier.padding(bottom = 6.dp)
                    ) {
                        Text(
                            "⚡ INSTANT BOOK DESIGNS",
                            color = Color.White,
                            fontSize = 8.sp,
                            fontWeight = FontWeight.Black,
                            modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                    }
                    Text(
                        "Browse Shoppable Inspirations",
                        color = Color.White,
                        fontWeight = FontWeight.Black,
                        fontSize = 16.sp
                    )
                    Text(
                        "Tap tagged hotspot regions on high-res photos to immediately add complete decor & style setups to cart.",
                        color = Color.White.copy(alpha = 0.7f),
                        fontSize = 10.sp,
                        lineHeight = 14.sp,
                        modifier = Modifier.fillMaxWidth(0.8f)
                    )
                }
                
                Text(
                    "🦚",
                    fontSize = 42.sp,
                    modifier = Modifier.align(Alignment.CenterEnd)
                )
            }
        }
    }
}

@Composable
fun VipConciergeSection() {
    var isConciergeEnabled by remember { mutableStateOf(false) }
    var requirementText by remember { mutableStateOf("") }
    val context = LocalContext.current
    val haptic = LocalHapticFeedback.current

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.25f))
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text("💎", fontSize = 20.sp)
                    Column {
                        Text("Enterprise VIP Concierge", fontWeight = FontWeight.Black, fontSize = 14.sp, color = RoyalNavy)
                        Text("High-ticket customized wedding planning", fontSize = 10.sp, color = SlateGray)
                    }
                }

                Switch(
                    checked = isConciergeEnabled,
                    onCheckedChange = {
                        isConciergeEnabled = it
                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                    },
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = Color.White,
                        checkedTrackColor = ChampagneGold,
                        uncheckedThumbColor = SlateGray,
                        uncheckedTrackColor = SlateGray.copy(alpha = 0.15f)
                    )
                )
            }

            AnimatedVisibility(visible = isConciergeEnabled) {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedTextField(
                        value = requirementText,
                        onValueChange = { requirementText = it },
                        label = { Text("Specify VIP requirements (e.g. 5-Star resort capacity >1500)") },
                        modifier = Modifier.fillMaxWidth(),
                        maxLines = 2,
                        textStyle = MaterialTheme.typography.bodyMedium.copy(fontSize = 12.sp),
                        colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = ChampagneGold, focusedLabelColor = DarkGold)
                    )

                    Button(
                        onClick = {
                            if (requirementText.isBlank()) return@Button
                            Toast.makeText(context, "🎉 VIP Lead Logged! Direct concierge manager will contact you.", Toast.LENGTH_LONG).show()
                            requirementText = ""
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
                        shape = RoundedCornerShape(8.dp),
                        modifier = Modifier.fillMaxWidth().height(38.dp)
                    ) {
                        Text("Submit Request to Registry", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    }
                }
            }
        }
    }
}
