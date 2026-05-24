package com.gomandap.admin.presentation.cms

import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

// ─── Command Center Aesthetic Tokens ─────────────────────────────────────────
private val LuxuryNavyBg   = Color(0xFF070B19)
private val CardNavyBg     = Color(0xFF131C35)
private val BorderGold     = Color(0xFFDFBA73)
private val GlowGold       = Color(0xFFC59A48)
private val LightSlateText = Color(0xFF94A3B8)
private val EmeraldGreen   = Color(0xFF10B981)

data class AdminBanner(
    val id: String,
    val title: String,
    val dateRange: String,
    val deepLink: String,
    val sequence: Int
)

data class BoostableVendor(
    val id: String,
    val name: String,
    val category: String,
    var boostFactor: Float
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun StorefrontCmsScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    val haptic = LocalHapticFeedback.current

    // Banners Schedule State
    val activeBanners = remember {
        mutableStateListOf(
            AdminBanner("B-101", "The Taj Palace Convention", "14 Nov - 20 Nov", "gomandap://vendor/taj_palace", 1),
            AdminBanner("B-102", "Heritage Sangeet Resort", "18 Nov - 24 Nov", "gomandap://vendor/heritage_resort", 2)
        )
    }

    // Boostable Vendors state
    val vendorsList = remember {
        mutableStateListOf(
            BoostableVendor("V-01", "Purna Kalamkari Mandapams", "Decorator", 1.0f),
            BoostableVendor("V-02", "Royal Decors & Florals", "Decorator", 1.5f),
            BoostableVendor("V-03", "Gourmet Flavors Catering", "Catering", 2.2f)
        )
    }

    // Hotspot Ingestion tagging states
    var droppedX by remember { mutableStateOf(-1f) }
    var droppedY by remember { mutableStateOf(-1f) }
    var attachedSku by remember { mutableStateOf("") }
    var tagSaved by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("Storefront CMS ", fontWeight = FontWeight.Black, color = Color.White, fontSize = 18.sp)
                        Text("Ops", fontWeight = FontWeight.Black, color = BorderGold, fontSize = 18.sp)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = BorderGold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = LuxuryNavyBg)
            )
        },
        containerColor = LuxuryNavyBg
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // ─── 1. Hero Carousel Banner Scheduler ───
            item {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("📷 Client Homepage Banners Scheduler", fontWeight = FontWeight.Bold, color = Color.White, fontSize = 14.sp)
                    IconButton(
                        onClick = {
                            activeBanners.add(AdminBanner("B-${100 + activeBanners.size + 1}", "Winter Special Hall setup", "01 Dec - 07 Dec", "gomandap://category/lawns", activeBanners.size + 1))
                            Toast.makeText(context, "Added new scheduled banner slot", Toast.LENGTH_SHORT).show()
                        },
                        modifier = Modifier.background(BorderGold, CircleShape).size(26.dp)
                    ) {
                        Icon(Icons.Default.Add, null, tint = LuxuryNavyBg, modifier = Modifier.size(16.dp))
                    }
                }
                Spacer(Modifier.height(8.dp))

                LazyRow(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                    items(activeBanners) { banner ->
                        Card(
                            shape = RoundedCornerShape(12.dp),
                            colors = CardDefaults.cardColors(containerColor = CardNavyBg),
                            modifier = Modifier
                                .width(220.dp)
                                .border(BorderStroke(1.dp, BorderGold.copy(alpha = 0.3f)), RoundedCornerShape(12.dp))
                        ) {
                            Column(modifier = Modifier.padding(12.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
                                    Text("SLOT #${banner.sequence}", color = BorderGold, fontWeight = FontWeight.Black, fontSize = 9.sp)
                                    Text(banner.id, color = LightSlateText, fontSize = 9.sp, fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace)
                                }
                                Text(banner.title, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                Text("📅 Schedule: ${banner.dateRange}", color = LightSlateText, fontSize = 10.sp)
                                Text("🔗 Link: ${banner.deepLink}", color = EmeraldGreen, fontSize = 10.sp, maxLines = 1)
                            }
                        }
                    }
                }
            }

            // ─── 2. Algorithmic Search Boost Overrides ───
            item {
                Text("📈 Algorithmic Search Ranking Overrides", fontWeight = FontWeight.Bold, color = Color.White, fontSize = 14.sp)
                Spacer(Modifier.height(8.dp))

                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = CardNavyBg),
                    modifier = Modifier.fillMaxWidth().border(BorderStroke(1.dp, BorderGold.copy(alpha = 0.25f)), RoundedCornerShape(16.dp))
                ) {
                    Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("Slide to inject artificial algorithmic coefficient boosts onto search feeds.", fontSize = 10.sp, color = LightSlateText)
                        
                        vendorsList.forEachIndexed { vIdx, vendor ->
                            var sliderVal by remember { mutableFloatStateOf(vendor.boostFactor) }
                            
                            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Column {
                                        Text(vendor.name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                        Text(vendor.category, color = LightSlateText, fontSize = 10.sp)
                                    }
                                    Text(
                                        text = "${String.format("%.1f", sliderVal)}x Boost",
                                        color = if (sliderVal > 1.0f) BorderGold else Color.White,
                                        fontWeight = FontWeight.Black,
                                        fontSize = 12.sp,
                                        fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                                    )
                                }
                                
                                Slider(
                                    value = sliderVal,
                                    onValueChange = { newVal ->
                                        if (sliderVal.toInt() != newVal.toInt()) {
                                            haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                                        }
                                        sliderVal = newVal
                                        vendorsList[vIdx] = vendor.copy(boostFactor = newVal)
                                    },
                                    valueRange = 1.0f..3.0f,
                                    steps = 19,
                                    colors = SliderDefaults.colors(
                                        thumbColor = BorderGold,
                                        activeTrackColor = BorderGold,
                                        inactiveTrackColor = Color.White.copy(alpha = 0.1f)
                                    ),
                                    modifier = Modifier.height(24.dp)
                                )
                                Spacer(Modifier.height(6.dp))
                            }
                        }
                    }
                }
            }

            // ─── 3. Ingestion Tagging canvas (Product Hotspots Overlay) ───
            item {
                Text("⚡ Shoppable Inspiration coordinate Tagging Canvas", fontWeight = FontWeight.Bold, color = Color.White, fontSize = 14.sp)
                Spacer(Modifier.height(8.dp))

                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = CardNavyBg),
                    modifier = Modifier.fillMaxWidth().border(BorderStroke(1.dp, BorderGold.copy(alpha = 0.25f)), RoundedCornerShape(16.dp))
                ) {
                    Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("Tap coordinates on the vendor uploaded photo below to dropping a product SKU tag.", fontSize = 10.sp, color = LightSlateText)

                        // Relative Coordinates Mock Image Box Canvas
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(220.dp)
                                .clip(RoundedCornerShape(12.dp))
                                .background(
                                    Brush.verticalGradient(listOf(Color(0xFF1E293B), Color(0xFF0F172A)))
                                )
                                .border(1.dp, BorderGold.copy(alpha = 0.2f), RoundedCornerShape(12.dp))
                                .pointerInput(Unit) {
                                    detectTapGestures { offset ->
                                        droppedX = offset.x / size.width
                                        droppedY = offset.y / size.height
                                        tagSaved = false
                                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                    }
                                }
                        ) {
                            Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
                                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text("Mandap Backdrop Setup Portfolio", color = Color.White.copy(alpha = 0.5f), fontSize = 14.sp, fontWeight = FontWeight.Bold)
                                    Text("TAP TO DROP A HOTSPOT PIN", color = BorderGold.copy(alpha = 0.6f), fontSize = 10.sp, fontWeight = FontWeight.Black)
                                }
                            }

                            // Render pin if dropped
                            if (droppedX >= 0f && droppedY >= 0f) {
                                Box(
                                    modifier = Modifier
                                        .align(Alignment.TopStart)
                                        .offset(
                                            x = (droppedX * 300).dp,
                                            y = (droppedY * 200).dp
                                        )
                                ) {
                                    Surface(
                                        color = BorderGold,
                                        shape = CircleShape,
                                        border = BorderStroke(1.5.dp, Color.White),
                                        modifier = Modifier.size(24.dp).shadow(4.dp, CircleShape)
                                    ) {
                                        Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
                                            Text("⚡", color = LuxuryNavyBg, fontWeight = FontWeight.Bold, fontSize = 10.sp)
                                        }
                                    }
                                }
                            }
                        }

                        // Dropped coordinates metadata and attachment
                        if (droppedX >= 0f && droppedY >= 0f) {
                            Column(verticalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth().padding(top = 4.dp)) {
                                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                    Text(
                                        text = "Pin Coords: X=${String.format("%.3f", droppedX)}, Y=${String.format("%.3f", droppedY)}",
                                        color = LightSlateText,
                                        fontSize = 11.sp,
                                        fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                                    )
                                    if (tagSaved) {
                                        Text("✅ Product Tagged!", color = EmeraldGreen, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                                    }
                                }

                                OutlinedTextField(
                                    value = attachedSku,
                                    onValueChange = { attachedSku = it },
                                    label = { Text("Bind to Vendor SKU (e.g. SKU-820 canopy)") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(
                                        focusedBorderColor = BorderGold,
                                        unfocusedBorderColor = Color.White.copy(alpha = 0.2f),
                                        focusedLabelColor = BorderGold,
                                        unfocusedLabelColor = LightSlateText,
                                        focusedTextColor = Color.White,
                                        unfocusedTextColor = Color.White
                                    )
                                )

                                Button(
                                    onClick = {
                                        if (attachedSku.isBlank()) {
                                            Toast.makeText(context, "Specify target SKU bind target!", Toast.LENGTH_SHORT).show()
                                            return@Button
                                        }
                                        tagSaved = true
                                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                        Toast.makeText(context, "🎉 Inspiration hotspots registered live!", Toast.LENGTH_SHORT).show()
                                    },
                                    colors = ButtonDefaults.buttonColors(containerColor = BorderGold),
                                    shape = RoundedCornerShape(8.dp),
                                    modifier = Modifier.fillMaxWidth().height(38.dp)
                                ) {
                                    Text("Push hotspot Tag live", fontWeight = FontWeight.Bold, color = LuxuryNavyBg, fontSize = 12.sp)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
