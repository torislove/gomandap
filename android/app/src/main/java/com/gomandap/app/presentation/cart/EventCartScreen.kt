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

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventCartScreen(
    onBackClick: () -> Unit,
    onCheckoutClick: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Event Booking Cart", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 18.sp)
                        Text("Review your hyper-local items", fontSize = 11.sp, color = SlateGray)
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
            CartCheckoutBar(onCheckoutClick = onCheckoutClick)
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
            // Cart Header Text
            item {
                Text(
                    text = "Selected Event Partners",
                    fontWeight = FontWeight.Black,
                    fontSize = 15.sp,
                    color = RoyalNavy,
                    modifier = Modifier.padding(horizontal = 4.dp)
                )
            }
            
            // Cart Items
            item {
                CartVendorCard(
                    category = "Venue & Mandap",
                    vendorName = "The Grand Taj Palace",
                    slot = "Evening Slot (5 PM - 11 PM)",
                    date = "Nov 14, 2026",
                    basePrice = "₹ 1,50,000",
                    skus = listOf("Extra Changing Room (+₹5,000)")
                )
            }
            
            item {
                CartVendorCard(
                    category = "Photography",
                    vendorName = "Pixel Perfect Studios",
                    slot = "Full Day",
                    date = "Nov 14, 2026",
                    basePrice = "₹ 45,000",
                    skus = listOf("Drone Coverage (+₹10,000)", "Cinematic Edit (+₹25,000)")
                )
            }

            // Escrow Ledger & Financial Breakdown
            item {
                Spacer(Modifier.height(8.dp))
                EscrowLedgerCard()
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
fun EscrowLedgerCard() {
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
            
            FinancialRow("Total Base Costs", "₹ 1,95,000")
            FinancialRow("Selected Add-ons", "₹ 40,000")
            FinancialRow("GST (18%)", "₹ 42,300")
            
            Spacer(Modifier.height(10.dp))
            Divider(color = Color.White.copy(alpha = 0.12f))
            Spacer(Modifier.height(12.dp))
            
            Row(
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("GRAND TOTAL", fontSize = 14.sp, fontWeight = FontWeight.Black, color = Color.White, letterSpacing = 0.5.sp)
                Text("₹ 2,77,300", fontSize = 18.sp, fontWeight = FontWeight.Black, color = ChampagneGold)
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
                        Text("₹ 55,460", fontSize = 12.sp, fontWeight = FontWeight.Black, color = ChampagneGold)
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
                        Text("₹ 2,21,840", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.White.copy(alpha = 0.7f))
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
