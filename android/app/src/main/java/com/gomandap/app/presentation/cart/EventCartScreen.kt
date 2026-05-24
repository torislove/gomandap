package com.gomandap.app.presentation.cart

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Security
import androidx.compose.material.icons.filled.KeyboardArrowRight
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*
import androidx.compose.foundation.BorderStroke
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.animation.*
import kotlinx.coroutines.delay

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventCartScreen(
    onBackClick: () -> Unit,
    onCheckoutClick: () -> Unit
) {
    // Interactive states for multiplayer and RSVP sync
    var vegPlatesCount by remember { mutableStateOf(500) }
    var isRsvpSynced by remember { mutableStateOf(false) }
    var coPlannerEditMessage by remember { mutableStateOf<String?>(null) }
    var extraSoundSystemAdded by remember { mutableStateOf(false) }
    val haptic = LocalHapticFeedback.current

    // Simulated Firestore Snapshot / Co-Planner edits
    LaunchedEffect(Unit) {
        // Step 1: Wait 5 seconds, then show that Rahul Groom is editing
        delay(5000)
        coPlannerEditMessage = "Rahul (Groom) is editing catering plates count..."
        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
        
        delay(3000)
        // Step 2: Rahul updates the plates count to 550
        vegPlatesCount = 550
        coPlannerEditMessage = "Rahul (Groom) updated Catering Plates count to 550 🍽️"
        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
        
        delay(5000)
        // Step 3: Rahul adds a sound system
        coPlannerEditMessage = "Rahul (Groom) is customizing audio setup..."
        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
        
        delay(3000)
        extraSoundSystemAdded = true
        coPlannerEditMessage = "Rahul (Groom) added JBL 5kW Sound System (+₹15,000) 🔊"
        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
        
        delay(5000)
        // Dismiss message
        coPlannerEditMessage = null
    }
    
    // Cost Engine Calculations
    val venuePrice = 150000.0
    val photoPrice = 45000.0
    val extraChangingRoomPrice = 5000.0
    val cateringPricePerPlate = 800.0
    val soundSystemPrice = if (extraSoundSystemAdded) 15000.0 else 0.0
    val cateringTotal = vegPlatesCount * cateringPricePerPlate
    
    val baseCost = venuePrice + photoPrice + extraChangingRoomPrice + cateringTotal + soundSystemPrice
    val gst = baseCost * 0.18
    val grandTotal = baseCost + gst
    val dueNow = grandTotal * 0.20
    val escrowHeld = grandTotal * 0.80

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Wedding Workspace Cart", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 18.sp)
                        Text("Review co-planner customized layout", fontSize = 11.sp, color = SlateGray)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White),
                modifier = Modifier.shadow(2.dp)
            )
        },
        bottomBar = {
            Surface(
                color = Color.White,
                shadowElevation = 16.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("20% DEPOSIT NOW", fontSize = 9.sp, color = SlateGray, fontWeight = FontWeight.Black, letterSpacing = 0.5.sp)
                        Text("₹${"%,.0f".format(dueNow)}", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
                    }
                    Button(
                        onClick = onCheckoutClick,
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.height(44.dp)
                    ) {
                        Text("Proceed to Checkout", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = Color.White)
                        Spacer(Modifier.width(6.dp))
                        Icon(Icons.Default.CheckCircle, contentDescription = null, modifier = Modifier.size(16.dp), tint = Color.White)
                    }
                }
            }
        },
        containerColor = SoftMist
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Multiplayer Workspace Header Pinned Section ──
            item {
                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    modifier = Modifier.fillMaxWidth().border(1.dp, ChampagneGold.copy(alpha = 0.25f), RoundedCornerShape(16.dp))
                ) {
                    Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        Row(
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Text("👥 Co-Planner Wedding Workspace", fontSize = 12.sp, fontWeight = FontWeight.Black, color = RoyalNavy)
                            Surface(color = EmeraldGreen.copy(alpha = 0.1f), shape = RoundedCornerShape(6.dp)) {
                                Text("Shared Sync Live", color = EmeraldGreen, fontSize = 9.sp, fontWeight = FontWeight.Black, modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp))
                            }
                        }

                        // Avatar layout
                        Row(horizontalArrangement = Arrangement.spacedBy(12.dp), verticalAlignment = Alignment.CenterVertically) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Box(modifier = Modifier.size(24.dp).clip(CircleShape).background(EmeraldGreen), contentAlignment = Alignment.Center) {
                                    Text("K", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 11.sp)
                                }
                                Spacer(Modifier.width(4.dp))
                                Text("Kavya (Bride)", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                            }
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Box(modifier = Modifier.size(24.dp).clip(CircleShape).background(ChampagneGold), contentAlignment = Alignment.Center) {
                                    Text("R", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 11.sp)
                                }
                                Spacer(Modifier.width(4.dp))
                                Text("Rahul (Groom)", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                            }
                        }

                        AnimatedVisibility(
                            visible = coPlannerEditMessage != null,
                            enter = fadeIn() + expandVertically(),
                            exit = fadeOut() + shrinkVertically()
                        ) {
                            coPlannerEditMessage?.let { msg ->
                                Surface(
                                    color = ChampagneGold.copy(alpha = 0.12f),
                                    shape = RoundedCornerShape(8.dp),
                                    border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.5f)),
                                    modifier = Modifier.fillMaxWidth().padding(top = 4.dp)
                                ) {
                                    Row(
                                        modifier = Modifier.padding(10.dp),
                                        verticalAlignment = Alignment.CenterVertically,
                                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                                    ) {
                                        Text("💬", fontSize = 14.sp)
                                        Text(
                                            text = msg,
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = RoyalNavy
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Smart RSVP Intelligent Plate Sync Banner ──
            if (!isRsvpSynced) {
                item {
                    Surface(
                        onClick = {
                            vegPlatesCount = 450 // Auto downscale package count
                            isRsvpSynced = true
                            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                        },
                        color = Color(0xFFEFF6FF),
                        shape = RoundedCornerShape(16.dp),
                        border = BorderStroke(1.dp, Color(0xFF93C5FD))
                    ) {
                        Row(
                            modifier = Modifier.padding(14.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Text("💡", fontSize = 24.sp)
                            Column(modifier = Modifier.weight(1f)) {
                                Text("Save ₹40,000 Instantly!", fontWeight = FontWeight.Black, fontSize = 13.sp, color = Color(0xFF1E40AF))
                                Text("GoMandap Digital Invite tracker detected 50 guest declines. Tap here to auto-adjust catering order plates down to 450.", fontSize = 11.sp, color = Color(0xFF1E3A8A))
                            }
                            Icon(Icons.Default.KeyboardArrowRight, null, tint = Color(0xFF1E40AF))
                        }
                    }
                }
            } else {
                item {
                    Surface(
                        color = EmeraldGreen.copy(alpha = 0.08f),
                        shape = RoundedCornerShape(16.dp),
                        border = BorderStroke(1.dp, EmeraldGreen.copy(alpha = 0.4f))
                    ) {
                        Row(
                            modifier = Modifier.padding(14.dp).fillMaxWidth(),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Text("✅", fontSize = 16.sp)
                            Text("Catering plates automatically downscaled to 450 based on RSVP declines. Saved ₹40,000 in escrow vault!", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = EmeraldGreen)
                        }
                    }
                }
            }

            // Cart Items
            item {
                CartVendorCard(
                    category = "Venue & Mandap",
                    vendorName = "The Grand Taj Palace",
                    slot = "Evening Slot (5 PM - 11 PM)",
                    date = "Nov 14, 2026",
                    basePrice = "₹ 1,50,000",
                    skus = buildList {
                        add("Extra Changing Room (+₹5,000)")
                        if (extraSoundSystemAdded) {
                            add("JBL 5kW Sound System (+₹15,000)")
                        }
                    }
                )
            }

            item {
                CartVendorCard(
                    category = "Catering",
                    vendorName = "Gourmet Flavors Catering",
                    slot = "Dinner Buffet",
                    date = "Nov 14, 2026",
                    basePrice = "₹ ${"%,.0f".format(cateringTotal)}",
                    skus = listOf("Veg Plate Quantity: $vegPlatesCount")
                )
            }
            
            item {
                CartVendorCard(
                    category = "Photography",
                    vendorName = "Pixel Perfect Studios",
                    slot = "Full Day",
                    date = "Nov 14, 2026",
                    basePrice = "₹ 45,000",
                    skus = emptyList()
                )
            }

            // Escrow Ledger & Financial Breakdown
            item {
                Spacer(Modifier.height(8.dp))
                EscrowLedgerCard(
                    baseCost = baseCost,
                    gst = gst,
                    grandTotal = grandTotal,
                    dueNow = dueNow,
                    escrowHeld = escrowHeld,
                    extraSoundSystemAdded = extraSoundSystemAdded
                )
                Spacer(Modifier.height(24.dp))
            }
        }
    }
}

@Composable
fun CartVendorCard(
    category: String,
    vendorName: String,
    slot: String,
    date: String,
    basePrice: String,
    skus: List<String>
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .neumorphicShadow(borderRadius = 16.dp, shadowRadius = 8.dp)
            .background(Color.White, shape = RoundedCornerShape(16.dp))
            .border(1.dp, ChampagneGold.copy(alpha = 0.15f), shape = RoundedCornerShape(16.dp))
            .padding(16.dp)
    ) {
        Column {
            Row(
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth()
            ) {
                Surface(
                    color = EmeraldGreen.copy(alpha = 0.08f),
                    shape = RoundedCornerShape(4.dp)
                ) {
                    Text(
                        text = category.uppercase(),
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Black,
                        color = EmeraldGreen,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
                
                Box(
                    modifier = Modifier
                        .size(28.dp)
                        .clip(CircleShape)
                        .background(RoseRed.copy(alpha = 0.08f))
                        .clickable { /* remove */ },
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Delete,
                        contentDescription = "Remove",
                        tint = RoseRed,
                        modifier = Modifier.size(14.dp)
                    )
                }
            }
            
            Spacer(Modifier.height(8.dp))
            
            Text(
                text = vendorName,
                fontWeight = FontWeight.Bold,
                fontSize = 15.sp,
                color = RoyalNavy
            )
            Text(
                text = "$date • $slot",
                fontSize = 11.sp,
                color = SlateGray,
                fontWeight = FontWeight.Medium
            )
            
            Spacer(Modifier.height(12.dp))
            Divider(color = LightSlate.copy(alpha = 0.5f))
            Spacer(Modifier.height(12.dp))
            
            // Pricing Breakdown
            Row(
                horizontalArrangement = Arrangement.SpaceBetween,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("Base Booking", fontSize = 13.sp, color = RoyalNavy, fontWeight = FontWeight.Medium)
                Text(basePrice, fontSize = 13.sp, fontWeight = FontWeight.Black, color = RoyalNavy)
            }
            
            skus.forEach { sku ->
                Spacer(Modifier.height(4.dp))
                Row(
                    horizontalArrangement = Arrangement.SpaceBetween,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(
                        text = sku.substringBefore(" (+"),
                        fontSize = 12.sp,
                        color = SlateGray,
                        fontWeight = FontWeight.Normal
                    )
                    Text(
                        text = sku.substringAfter("(").substringBefore(")"),
                        fontSize = 12.sp,
                        color = SlateGray,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }
    }
}

@Composable
fun EscrowLedgerCard(
    baseCost: Double,
    gst: Double,
    grandTotal: Double,
    dueNow: Double,
    escrowHeld: Double,
    extraSoundSystemAdded: Boolean = false
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .antigravityShadow(borderRadius = 20.dp)
            .background(
                brush = Brush.linearGradient(listOf(RoyalNavy, DeepSky)),
                shape = RoundedCornerShape(20.dp)
            )
            .border(1.5.dp, ChampagneGold.copy(alpha = 0.35f), RoundedCornerShape(20.dp))
            .padding(20.dp)
    ) {
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Security,
                    contentDescription = "Escrow",
                    tint = ChampagneGold,
                    modifier = Modifier.size(20.dp)
                )
                Spacer(Modifier.width(8.dp))
                Text(
                    text = "GoMandap Escrow Ledger",
                    fontWeight = FontWeight.Black,
                    fontSize = 15.sp,
                    color = ChampagneGold,
                    letterSpacing = 0.5.sp
                )
            }
            
            Spacer(Modifier.height(6.dp))
            
            Text(
                text = "Advance funds are securely locked in GoMandap safe custody and only released based on your milestone authorization.",
                fontSize = 11.sp,
                color = Color.White.copy(alpha = 0.7f),
                lineHeight = 16.sp
            )
            
            Spacer(Modifier.height(14.dp))
            Divider(color = Color.White.copy(alpha = 0.12f))
            Spacer(Modifier.height(14.dp))
            
            val selectedAddons = 5000.0 + if (extraSoundSystemAdded) 15000.0 else 0.0
            val baseWithoutAddons = baseCost - selectedAddons
            FinancialRow("Total Base Costs", "₹ ${"%,.0f".format(baseWithoutAddons)}")
            FinancialRow("Selected Add-ons", "₹ ${"%,.0f".format(selectedAddons)}")
            FinancialRow("GST (18%)", "₹ ${"%,.0f".format(gst)}")
            
            Spacer(Modifier.height(10.dp))
            Divider(color = Color.White.copy(alpha = 0.12f))
            Spacer(Modifier.height(12.dp))
            
            Row(
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("GRAND TOTAL", fontSize = 14.sp, fontWeight = FontWeight.Black, color = Color.White, letterSpacing = 0.5.sp)
                Text("₹ ${"%,.0f".format(grandTotal)}", fontSize = 18.sp, fontWeight = FontWeight.Black, color = ChampagneGold)
            }
            
            Spacer(Modifier.height(16.dp))
            
            // Milestone Splits
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White.copy(alpha = 0.08f), RoundedCornerShape(12.dp))
                    .border(1.dp, Color.White.copy(alpha = 0.1f), RoundedCornerShape(12.dp))
                    .padding(12.dp)
            ) {
                Column {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(modifier = Modifier.size(6.dp).clip(CircleShape).background(ChampagneGold))
                            Spacer(Modifier.width(8.dp))
                            Text("Due Now (20% Advance)", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                        Text("₹ ${"%,.0f".format(dueNow)}", fontSize = 12.sp, fontWeight = FontWeight.Black, color = ChampagneGold)
                    }
                    
                    Spacer(Modifier.height(6.dp))
                    
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(modifier = Modifier.size(6.dp).clip(CircleShape).background(Color.White.copy(alpha = 0.4f)))
                            Spacer(Modifier.width(8.dp))
                            Text("Held in Escrow (80%)", fontSize = 12.sp, color = Color.White.copy(alpha = 0.7f))
                        }
                        Text("₹ ${"%,.0f".format(escrowHeld)}", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.White.copy(alpha = 0.7f))
                    }
                }
            }
        }
    }
}

@Composable
fun FinancialRow(label: String, amount: String) {
    Row(
        horizontalArrangement = Arrangement.SpaceBetween,
        modifier = Modifier
            .fillMaxWidth()
            .padding(bottom = 6.dp)
    ) {
        Text(label, fontSize = 12.sp, color = Color.White.copy(alpha = 0.75f), fontWeight = FontWeight.Normal)
        Text(amount, fontSize = 12.sp, color = Color.White.copy(alpha = 0.9f), fontWeight = FontWeight.Bold)
    }
}

@Composable
fun CartCheckoutBar(onCheckoutClick: () -> Unit) {
    Surface(
        color = Color.White,
        shadowElevation = 16.dp,
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text("AMOUNT DUE NOW", fontSize = 9.sp, color = SlateGray, fontWeight = FontWeight.Black, letterSpacing = 0.5.sp)
                Text("₹ 55,460", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
            }
            Button(
                onClick = onCheckoutClick,
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .height(44.dp)
                    .antigravityShadow(color = EmeraldGreen, alpha = 0.15f, borderRadius = 12.dp)
            ) {
                Text("Secure Checkout", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = Color.White)
                Spacer(Modifier.width(6.dp))
                Icon(Icons.Default.CheckCircle, contentDescription = null, modifier = Modifier.size(16.dp), tint = Color.White)
            }
        }
    }
}
