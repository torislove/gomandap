package com.gomandap.admin.presentation.vendors

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.admin.data.vendor.VendorRepository
import com.gomandap.app.domain.model.Vendor
import com.gomandap.common.design.GomandapTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VendorListScreen(onNavigate: (String) -> Unit) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategoryFilter by remember { mutableStateOf("All") }

    val categories = listOf("All", "Venues", "Catering", "Photography", "Decorators", "Makeup Art")

    val vendorList = VendorRepository.vendors.collectAsState().value
    val filteredVendors = remember(searchQuery, selectedCategoryFilter, vendorList) {
        vendorList.filter { vendor ->
            val matchesSearch = vendor.name.contains(searchQuery, ignoreCase = true) ||
                    vendor.locality.contains(searchQuery, ignoreCase = true)
            val matchesCategory = when (selectedCategoryFilter) {
                "All" -> true
                "Venues" -> vendor is com.gomandap.app.domain.model.VenueVendor
                "Catering" -> vendor is com.gomandap.app.domain.model.CateringVendor
                "Photography" -> vendor is com.gomandap.app.domain.model.PhotographyVendor
                "Decorators" -> vendor is com.gomandap.app.domain.model.DecorMandapVendor
                "Makeup Art" -> vendor is com.gomandap.app.domain.model.MakeupArtistVendor
                else -> true
            }
            matchesSearch && matchesCategory
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Wedding Partners", fontWeight = FontWeight.Bold, color = GomandapTokens.Colors.royalNavy) },
                navigationIcon = {
                    IconButton(onClick = { onNavigate("admin_dashboard") }) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = GomandapTokens.Colors.royalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = GomandapTokens.Colors.pearlWhite)
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                text = { Text("Onboard Partner", color = Color.White, fontWeight = FontWeight.Bold) },
                icon = { Icon(imageVector = Icons.Default.Add, contentDescription = "Add Partner", tint = Color.White) },
                onClick = { onNavigate("admin_vendor_onboarding") },
                containerColor = GomandapTokens.Colors.champagneGold,
                shape = GomandapTokens.Shapes.large
            )
        },
        containerColor = GomandapTokens.Colors.pearlWhite
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // ── Search field ──
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = GomandapTokens.Spacing.md, vertical = GomandapTokens.Spacing.sm)
                    .background(GomandapTokens.Colors.pearlWhite, GomandapTokens.Shapes.medium)
                    .border(1.dp, GomandapTokens.Colors.lightSlate.copy(alpha = 0.3f), GomandapTokens.Shapes.medium)
                    .padding(horizontal = GomandapTokens.Spacing.md, vertical = 2.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Search, contentDescription = "Search", tint = GomandapTokens.Colors.slateGray)
                    Spacer(modifier = Modifier.width(10.dp))
                    TextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        placeholder = { Text("Search platform partners...", color = GomandapTokens.Colors.slateGray) },
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color.Transparent,
                            unfocusedContainerColor = Color.Transparent,
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent
                        ),
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )
                }
            }

            // ── Filter Horizontal Strip ──
            LazyRow(
                contentPadding = PaddingValues(horizontal = GomandapTokens.Spacing.md),
                horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xs),
                modifier = Modifier.padding(bottom = GomandapTokens.Spacing.sm)
            ) {
                items(categories) { cat ->
                    val isSelected = selectedCategoryFilter == cat
                    Surface(
                        onClick = { selectedCategoryFilter = cat },
                        color = if (isSelected) GomandapTokens.Colors.champagneGold else GomandapTokens.Colors.pearlWhite,
                        border = BorderStroke(1.dp, if (isSelected) GomandapTokens.Colors.champagneGold else GomandapTokens.Colors.lightSlate.copy(alpha = 0.5f)),
                        shape = GomandapTokens.Shapes.pill
                    ) {
                        Text(
                            text = cat,
                            color = if (isSelected) Color.White else GomandapTokens.Colors.royalNavy,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp)
                        )
                    }
                }
            }

            // ── List of vendors ──
            LazyColumn(
                contentPadding = PaddingValues(GomandapTokens.Spacing.md),
                verticalArrangement = Arrangement.spacedBy(14.dp),
                modifier = Modifier.weight(1f)
            ) {
                items(filteredVendors) { vendor ->
                    AdminVendorCard(
                        vendor = vendor,
                        onEditClick = { onNavigate("admin_vendor_edit/${vendor.id}") }
                    )
                }

                if (filteredVendors.isEmpty()) {
                    item {
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 40.dp),
                            contentAlignment = Alignment.Center
                        ) {
                            Text("No platform partners match your search criteria.", fontSize = 12.sp, color = GomandapTokens.Colors.slateGray)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun AdminVendorCard(
    vendor: Vendor,
    onEditClick: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = GomandapTokens.Shapes.large,
        colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
        elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.low)
    ) {
        Column(modifier = Modifier.padding(GomandapTokens.Spacing.md)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = vendor.name,
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp,
                            color = GomandapTokens.Colors.royalNavy,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        if (vendor.isVerified) {
                            Spacer(modifier = Modifier.width(4.dp))
                            Box(
                                modifier = Modifier
                                    .size(12.dp)
                                    .clip(CircleShape)
                                    .background(GomandapTokens.Colors.emeraldGreen)
                            )
                        }
                    }
                    Text(text = vendor.locality, fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                }

                IconButton(
                    onClick = onEditClick,
                    modifier = Modifier
                        .size(32.dp)
                        .background(GomandapTokens.Colors.softMist, CircleShape)
                ) {
                    Icon(imageVector = Icons.Default.Edit, contentDescription = "Edit Profile", tint = GomandapTokens.Colors.royalNavy, modifier = Modifier.size(16.dp))
                }
            }

            Spacer(modifier = Modifier.height(10.dp))
            Divider(color = GomandapTokens.Colors.lightSlate.copy(alpha = 0.2f))
            Spacer(modifier = Modifier.height(8.dp))

            // Badges row
            Row(
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth()
            ) {
                // Escrow badge
                if (vendor.isEscrowProtected) {
                    Box(
                        modifier = Modifier
                            .background(GomandapTokens.Colors.emeraldGreen.copy(alpha = 0.08f), GomandapTokens.Shapes.small)
                            .border(1.dp, GomandapTokens.Colors.emeraldGreen.copy(alpha = 0.2f), GomandapTokens.Shapes.small)
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text("ESCROW GUARD", color = GomandapTokens.Colors.emeraldGreen, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                    }
                }

                // Fast Filling badge
                if (vendor.isFastFilling) {
                    Box(
                        modifier = Modifier
                            .background(GomandapTokens.Colors.champagneGold.copy(alpha = 0.08f), GomandapTokens.Shapes.small)
                            .border(1.dp, GomandapTokens.Colors.champagneGold.copy(alpha = 0.2f), GomandapTokens.Shapes.small)
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text("FILLING FAST", color = GomandapTokens.Colors.champagneGoldDark, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Spacer(modifier = Modifier.weight(1f))

                // Rating
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Star, contentDescription = "Rating", tint = GomandapTokens.Colors.champagneGold, modifier = Modifier.size(14.dp))
                    Spacer(modifier = Modifier.width(3.dp))
                    Text(text = vendor.rating.toString(), fontSize = 11.sp, fontWeight = FontWeight.Bold, color = GomandapTokens.Colors.royalNavy)
                }
            }
        }
    }
}
