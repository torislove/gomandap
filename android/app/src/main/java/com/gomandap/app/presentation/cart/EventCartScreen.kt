package com.gomandap.app.presentation.cart

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.ChampagneGold
import com.gomandap.app.presentation.theme.EmeraldGreen
import com.gomandap.app.presentation.theme.RoyalNavy
import com.gomandap.app.presentation.theme.SlateGray

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventCartScreen(
    onBackClick: () -> Unit,
    onCheckoutClick: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Event Cart", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        bottomBar = {
            CartCheckoutBar(onCheckoutClick = onCheckoutClick)
        },
        containerColor = Color(0xFFF8FAFC)
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item { Spacer(Modifier.height(8.dp)) }

            // ── Cart Items (Multi-Vendor) ─────────────────────────────────────
            item {
                Text("Your Vendors", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                Spacer(Modifier.height(12.dp))
            }
            
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

            // ── Escrow Ledger & Financial Breakdown ─────────────────────────
            item {
                Spacer(Modifier.height(24.dp))
                EscrowLedgerCard()
                Spacer(Modifier.height(32.dp))
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
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Text(category.uppercase(), fontSize = 10.sp, fontWeight = FontWeight.Black, color = EmeraldGreen)
                Icon(Icons.Default.Delete, contentDescription = "Remove", tint = SlateGray.copy(alpha=0.5f), modifier = Modifier.size(16.dp))
            }
            Spacer(Modifier.height(4.dp))
            Text(vendorName, fontWeight = FontWeight.Bold, fontSize = 16.sp, color = RoyalNavy)
            Text("$date • $slot", fontSize = 12.sp, color = SlateGray)
            
            Spacer(Modifier.height(12.dp))
            
            // Pricing Breakdown
            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Text("Base Booking", fontSize = 13.sp, color = RoyalNavy)
                Text(basePrice, fontSize = 13.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
            }
            skus.forEach { sku ->
                Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                    Text(sku.substringBefore(" (+"), fontSize = 13.sp, color = SlateGray)
                    Text(sku.substringAfter("(+").substringBefore(")"), fontSize = 13.sp, color = SlateGray)
                }
            }
        }
    }
}

@Composable
fun EscrowLedgerCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = RoyalNavy),
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.Lock, contentDescription = "Escrow", tint = ChampagneGold, modifier = Modifier.size(20.dp))
                Spacer(Modifier.width(8.dp))
                Text("Gomandap Escrow Ledger", fontWeight = FontWeight.Black, fontSize = 16.sp, color = ChampagneGold)
            }
            Text("Your funds are locked safely and only released post-event.", fontSize = 11.sp, color = Color.White.copy(alpha=0.7f), modifier = Modifier.padding(top=4.dp, bottom=16.dp))
            
            Divider(color = Color.White.copy(alpha = 0.1f))
            Spacer(Modifier.height(12.dp))
            
            FinancialRow("Total Base Costs", "₹ 1,95,000")
            FinancialRow("Selected Add-ons", "₹ 40,000")
            FinancialRow("GST (18%)", "₹ 42,300")
            Spacer(Modifier.height(8.dp))
            
            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                Text("Grand Total", fontSize = 16.sp, fontWeight = FontWeight.Black, color = Color.White)
                Text("₹ 2,77,300", fontSize = 16.sp, fontWeight = FontWeight.Black, color = ChampagneGold)
            }
            
            Spacer(Modifier.height(16.dp))
            
            // Milestone Splits
            Box(modifier = Modifier.fillMaxWidth().background(Color.White.copy(alpha=0.1f), RoundedCornerShape(12.dp)).padding(12.dp)) {
                Column {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(modifier = Modifier.size(8.dp).clip(CircleShape).background(ChampagneGold))
                        Spacer(Modifier.width(8.dp))
                        Text("Due Now (20% Advance)", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        Spacer(Modifier.weight(1f))
                        Text("₹ 55,460", fontSize = 13.sp, fontWeight = FontWeight.Bold, color = ChampagneGold)
                    }
                    Spacer(Modifier.height(8.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(modifier = Modifier.size(8.dp).clip(CircleShape).background(SlateGray))
                        Spacer(Modifier.width(8.dp))
                        Text("Held in Escrow (80%)", fontSize = 13.sp, color = Color.White.copy(alpha=0.8f))
                        Spacer(Modifier.weight(1f))
                        Text("₹ 2,21,840", fontSize = 13.sp, color = Color.White.copy(alpha=0.8f))
                    }
                }
            }
        }
    }
}

@Composable
fun FinancialRow(label: String, amount: String) {
    Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp)) {
        Text(label, fontSize = 13.sp, color = Color.White.copy(alpha=0.8f))
        Text(amount, fontSize = 13.sp, color = Color.White.copy(alpha=0.8f))
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
            modifier = Modifier.padding(horizontal = 24.dp, vertical = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text("Amount Due Now", fontSize = 11.sp, color = SlateGray)
                Text("₹ 55,460", fontWeight = FontWeight.Black, fontSize = 20.sp, color = RoyalNavy)
            }
            Button(
                onClick = onCheckoutClick,
                colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier.height(48.dp)
            ) {
                Text("Secure Checkout", fontWeight = FontWeight.Bold, fontSize = 15.sp)
                Spacer(Modifier.width(8.dp))
                Icon(Icons.Default.CheckCircle, contentDescription = null, modifier = Modifier.size(18.dp))
            }
        }
    }
}
