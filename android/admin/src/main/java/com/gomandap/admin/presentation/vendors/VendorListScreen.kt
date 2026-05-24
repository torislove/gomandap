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
import androidx.compose.foundation.shape.RoundedCornerShape
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
import com.gomandap.app.presentation.theme.*

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
                title = { Text("Wedding Partners", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                navigationIcon = {
                    IconButton(onClick = { onNavigate("admin_dashboard") }) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        floatingActionButton = {
            ExtendedFloatingActionButton(
                text = { Text("Onboard Partner", color = Color.White, fontWeight = FontWeight.Bold) },
                icon = { Icon(imageVector = Icons.Default.Add, contentDescription = "Add Partner", tint = Color.White) },
                onClick = { onNavigate("admin_vendor_onboarding") },
                containerColor = ChampagneGold,
                shape = RoundedCornerShape(16.dp)
            )
        },
        containerColor = PearlWhite
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
                    .padding(horizontal = 16.dp, vertical = 12.dp)
                    .background(Color.White, RoundedCornerShape(12.dp))
                    .border(1.dp, Color.LightGray.copy(alpha = 0.3f), RoundedCornerShape(12.dp))
                    .padding(horizontal = 16.dp, vertical = 2.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Search, contentDescription = "Search", tint = Color.Gray)
                    Spacer(modifier = Modifier.width(10.dp))
                    TextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        placeholder = { Text("Search platform partners...", color = Color.Gray) },
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
                contentPadding = PaddingValues(horizontal = 16.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.padding(bottom = 12.dp)
            ) {
                items(categories) { cat ->
                    val isSelected = selectedCategoryFilter == cat
                    Surface(
                        onClick = { selectedCategoryFilter = cat },
                        color = if (isSelected) ChampagneGold else Color.White,
                        border = BorderStroke(1.dp, if (isSelected) ChampagneGold else Color.LightGray.copy(alpha = 0.5f)),
                        shape = RoundedCornerShape(20.dp)
                    ) {
                        Text(
                            text = cat,
                            color = if (isSelected) Color.White else RoyalNavy,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp)
                        )
                    }
                }
            }

            // ── List of vendors ──
            LazyColumn(
                contentPadding = PaddingValues(16.dp),
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
                            Text("No platform partners match your search criteria.", fontSize = 12.sp, color = Color.Gray)
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
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
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
                            color = RoyalNavy,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        if (vendor.isVerified) {
                            Spacer(modifier = Modifier.width(4.dp))
                            Box(
                                modifier = Modifier
                                    .size(12.dp)
                                    .clip(CircleShape)
                                    .background(EmeraldGreen)
                            )
                        }
                    }
                    Text(text = vendor.locality, fontSize = 11.sp, color = Color.Gray)
                }

                IconButton(
                    onClick = onEditClick,
                    modifier = Modifier
                        .size(32.dp)
                        .background(PearlWhite, CircleShape)
                ) {
                    Icon(imageVector = Icons.Default.Edit, contentDescription = "Edit Profile", tint = RoyalNavy, modifier = Modifier.size(16.dp))
                }
            }

            Spacer(modifier = Modifier.height(10.dp))
            Divider(color = Color.LightGray.copy(alpha = 0.2f))
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
                            .background(EmeraldGreen.copy(alpha = 0.08f), RoundedCornerShape(4.dp))
                            .border(1.dp, EmeraldGreen.copy(alpha = 0.2f), RoundedCornerShape(4.dp))
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text("ESCROW GUARD", color = EmeraldGreen, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                    }
                }

                // Fast Filling badge
                if (vendor.isFastFilling) {
                    Box(
                        modifier = Modifier
                            .background(ChampagneGold.copy(alpha = 0.08f), RoundedCornerShape(4.dp))
                            .border(1.dp, ChampagneGold.copy(alpha = 0.2f), RoundedCornerShape(4.dp))
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text("FILLING FAST", color = DarkGold, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                    }
                }

                Spacer(modifier = Modifier.weight(1f))

                // Rating
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Star, contentDescription = "Rating", tint = ChampagneGold, modifier = Modifier.size(14.dp))
                    Spacer(modifier = Modifier.width(3.dp))
                    Text(text = vendor.rating.toString(), fontSize = 11.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                }
            }
        }
    }
}
