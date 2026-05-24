package com.gomandap.admin.presentation.vendors

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Star
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
import com.gomandap.admin.data.vendor.VendorRepository
import com.gomandap.app.domain.model.CateringVendor
import com.gomandap.app.domain.model.DecorMandapVendor
import com.gomandap.app.domain.model.MakeupArtistVendor
import com.gomandap.app.domain.model.PhotographyVendor
import com.gomandap.app.domain.model.VenueVendor
import com.gomandap.common.design.GomandapTokens
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VendorEditScreen(
    vendorId: String,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    val vendorList = VendorRepository.vendors.collectAsState().value
    val rawVendor = remember(vendorId, vendorList) { vendorList.firstOrNull { it.id == vendorId } ?: error("Vendor not found") }

    // Editable state hooks
    var name by remember { mutableStateOf(rawVendor.name) }
    var locality by remember { mutableStateOf(rawVendor.locality) }
    var basePrice by remember { mutableStateOf(rawVendor.basePrice.toString()) }
    var rating by remember { mutableFloatStateOf(rawVendor.rating) }
    var isVerified by remember { mutableStateOf(rawVendor.isVerified) }
    var isEscrowProtected by remember { mutableStateOf(rawVendor.isEscrowProtected) }
    var isFastFilling by remember { mutableStateOf(rawVendor.isFastFilling) }

    var isSaving by remember { mutableStateOf(false) }
    var showSuccessToast by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Edit Vendor Profile", fontWeight = FontWeight.Bold, color = GomandapTokens.Colors.royalNavy) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = GomandapTokens.Colors.royalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = GomandapTokens.Colors.pearlWhite)
            )
        },
        containerColor = GomandapTokens.Colors.pearlWhite
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(GomandapTokens.Spacing.md),
                verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.md)
            ) {
                // Section Title: Basic Metadata
                Text("Core Information", fontWeight = FontWeight.Black, fontSize = 16.sp, color = GomandapTokens.Colors.royalNavy)

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = GomandapTokens.Shapes.medium,
                    colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
                    elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.low)
                ) {
                    Column(
                        modifier = Modifier.padding(GomandapTokens.Spacing.md),
                        verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
                    ) {
                        OutlinedTextField(
                            value = name,
                            onValueChange = { name = it },
                            label = { Text("Vendor/Business Name") },
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = GomandapTokens.Colors.champagneGold,
                                focusedLabelColor = GomandapTokens.Colors.champagneGoldDark
                            )
                        )

                        OutlinedTextField(
                            value = locality,
                            onValueChange = { locality = it },
                            label = { Text("Locality / Address") },
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = GomandapTokens.Colors.champagneGold,
                                focusedLabelColor = GomandapTokens.Colors.champagneGoldDark
                            )
                        )

                        OutlinedTextField(
                            value = basePrice,
                            onValueChange = { basePrice = it },
                            label = { Text("Starting Base Budget (₹)") },
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = GomandapTokens.Colors.champagneGold,
                                focusedLabelColor = GomandapTokens.Colors.champagneGoldDark
                            )
                        )
                    }
                }

                // Section Title: Platform Attributes
                Text("Platform Attributes & Badges", fontWeight = FontWeight.Black, fontSize = 16.sp, color = GomandapTokens.Colors.royalNavy)

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = GomandapTokens.Shapes.medium,
                    colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
                    elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.low)
                ) {
                    Column(
                        modifier = Modifier.padding(GomandapTokens.Spacing.md),
                        verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.md)
                    ) {
                        // Verification badge toggle
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text("Verified Partner Badge", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                                Text("Displays an emerald verified badge next to vendor name.", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                            }
                            Switch(
                                checked = isVerified,
                                onCheckedChange = { isVerified = it },
                                colors = SwitchDefaults.colors(checkedThumbColor = GomandapTokens.Colors.emeraldGreen, checkedTrackColor = GomandapTokens.Colors.emeraldGreen.copy(alpha = 0.3f))
                            )
                        }

                        Divider(color = GomandapTokens.Colors.lightSlate.copy(alpha = 0.3f))

                        // Escrow Protected toggle
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text("Neutral Escrow Lock Coverage", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                                Text("Guarantees payment protection with split milestones.", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                            }
                            Switch(
                                checked = isEscrowProtected,
                                onCheckedChange = { isEscrowProtected = it },
                                colors = SwitchDefaults.colors(checkedThumbColor = GomandapTokens.Colors.emeraldGreen, checkedTrackColor = GomandapTokens.Colors.emeraldGreen.copy(alpha = 0.3f))
                            )
                        }

                        Divider(color = GomandapTokens.Colors.lightSlate.copy(alpha = 0.3f))

                        // Fast Filling / Hot toggle
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column(modifier = Modifier.weight(1f)) {
                                Text("Filling Fast Badge", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                                Text("Highlights high-demand calendar slots in search results.", fontSize = 11.sp, color = GomandapTokens.Colors.slateGray)
                            }
                            Switch(
                                checked = isFastFilling,
                                onCheckedChange = { isFastFilling = it },
                                colors = SwitchDefaults.colors(checkedThumbColor = GomandapTokens.Colors.champagneGold, checkedTrackColor = GomandapTokens.Colors.champagneGold.copy(alpha = 0.3f))
                            )
                        }
                    }
                }

                // Section Title: Ratings & Performance
                Text("Performance Metrics", fontWeight = FontWeight.Black, fontSize = 16.sp, color = GomandapTokens.Colors.royalNavy)

                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = GomandapTokens.Shapes.medium,
                    colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
                    elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.low)
                ) {
                    Column(
                        modifier = Modifier.padding(GomandapTokens.Spacing.md),
                        verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xs)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text("Customer Rating", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Star, null, tint = GomandapTokens.Colors.champagneGold, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(String.format("%.1f", rating), fontWeight = FontWeight.Bold, fontSize = 14.sp, color = GomandapTokens.Colors.royalNavy)
                            }
                        }

                        Slider(
                            value = rating,
                            onValueChange = { rating = it },
                            valueRange = 1.0f..5.0f,
                            steps = 39, // 0.1 increments
                            colors = SliderDefaults.colors(thumbColor = GomandapTokens.Colors.champagneGold, activeTrackColor = GomandapTokens.Colors.champagneGold)
                        )
                    }
                }

                Spacer(modifier = Modifier.height(60.dp)) // space for absolute button
            }

            // Bottom Sticky Save Button
            Surface(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth(),
                shadowElevation = GomandapTokens.Elevation.high,
                color = GomandapTokens.Colors.pearlWhite
            ) {
                Box(
                    modifier = Modifier
                        .padding(GomandapTokens.Spacing.md)
                        .fillMaxWidth()
                ) {
                    Button(
                        onClick = {
                            scope.launch {
                                isSaving = true
                                val parsedBasePrice = basePrice.toDoubleOrNull() ?: rawVendor.basePrice
                                VendorRepository.updateVendor(vendorId) { vendor ->
                                    when (vendor) {
                                        is VenueVendor -> vendor.copy(
                                            name = name,
                                            locality = locality,
                                            basePrice = parsedBasePrice,
                                            rating = rating,
                                            isVerified = isVerified,
                                            isEscrowProtected = isEscrowProtected,
                                            isFastFilling = isFastFilling
                                        )
                                        is PhotographyVendor -> vendor.copy(
                                            name = name,
                                            locality = locality,
                                            basePrice = parsedBasePrice,
                                            rating = rating,
                                            isVerified = isVerified,
                                            isEscrowProtected = isEscrowProtected,
                                            isFastFilling = isFastFilling
                                        )
                                        is DecorMandapVendor -> vendor.copy(
                                            name = name,
                                            locality = locality,
                                            basePrice = parsedBasePrice,
                                            rating = rating,
                                            isVerified = isVerified,
                                            isEscrowProtected = isEscrowProtected,
                                            isFastFilling = isFastFilling
                                        )
                                        is CateringVendor -> vendor.copy(
                                            name = name,
                                            locality = locality,
                                            basePrice = parsedBasePrice,
                                            rating = rating,
                                            isVerified = isVerified,
                                            isEscrowProtected = isEscrowProtected,
                                            isFastFilling = isFastFilling
                                        )
                                        is MakeupArtistVendor -> vendor.copy(
                                            name = name,
                                            locality = locality,
                                            basePrice = parsedBasePrice,
                                            rating = rating,
                                            isVerified = isVerified,
                                            isEscrowProtected = isEscrowProtected,
                                            isFastFilling = isFastFilling
                                        )
                                    }
                                }
                                delay(350)
                                isSaving = false
                                showSuccessToast = true
                                delay(1000)
                                showSuccessToast = false
                                onBack()
                            }
                        },
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(48.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = GomandapTokens.Colors.emeraldGreen),
                        shape = GomandapTokens.Shapes.small,
                        enabled = !isSaving
                    ) {
                        if (isSaving) {
                            CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                        } else {
                            Text("Save Configurations", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 15.sp)
                        }
                    }
                }
            }

            // Success Popup
            if (showSuccessToast) {
                Box(
                    modifier = Modifier
                        .align(Alignment.Center)
                        .background(Color.Black.copy(alpha = 0.8f), GomandapTokens.Shapes.medium)
                        .padding(GomandapTokens.Spacing.xl),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Default.Check, null, tint = GomandapTokens.Colors.emeraldGreen, modifier = Modifier.size(40.dp))
                        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))
                        Text("Configurations Saved Successfully!", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 14.sp)
                    }
                }
            }
        }
    }
}
