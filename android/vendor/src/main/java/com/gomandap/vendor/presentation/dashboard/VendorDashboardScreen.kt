package com.gomandap.vendor.presentation.dashboard

import android.widget.Toast
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VendorDashboardScreen(onNavigateToOnboard: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    var activeVaultBalance by remember { mutableStateOf("₹64,000") }
    var releaseStatus by remember { mutableStateOf("Pre-Event 50% Held") }
    var arrivingState by remember { mutableStateOf("Not Checked-in") }
    var isCheckingIn by remember { mutableStateOf(false) }

    // Blocked calendar dates state (simulated)
    val blockedDates = remember { mutableStateListOf(3, 14, 22) }
    val surgedDates = remember { mutableStateListOf(4, 15, 23) }

    // Package builder states
    var pkgName by remember { mutableStateOf("") }
    var pkgPrice by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("GoMandap ", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 20.sp)
                        Text("Vendor Hub", fontWeight = FontWeight.Black, color = ChampagneGold, fontSize = 20.sp)
                    }
                },
                actions = {
                    IconButton(onClick = onNavigateToOnboard) {
                        Icon(imageVector = Icons.Default.Add, contentDescription = "Add Storefront", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = PearlWhite
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ─── 1. Payout Vault Milestone Card ───
            Text("💰 Safe Payout Vault", fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = RoyalNavy),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(18.dp)) {
                    Text("Total Milestone Payouts Locked", color = Color.White.copy(alpha = 0.6f), fontSize = 10.sp)
                    Text(activeVaultBalance, color = Color.White, fontWeight = FontWeight.Black, fontSize = 28.sp)
                    Spacer(Modifier.height(14.dp))

                    // Node Timeline Layout
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Box(modifier = Modifier.size(20.dp).background(EmeraldGreen, CircleShape), contentAlignment = Alignment.Center) {
                                Icon(Icons.Default.Check, null, tint = Color.White, modifier = Modifier.size(10.dp))
                            }
                            Spacer(Modifier.height(4.dp))
                            Text("20% Booking Lock", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                            Text("₹16,000 Paid", color = EmeraldGreen, fontSize = 9.sp)
                        }

                        Box(modifier = Modifier.weight(1f).height(2.dp).background(ChampagneGold).padding(horizontal = 4.dp))

                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Box(modifier = Modifier.size(20.dp).background(ChampagneGold, CircleShape), contentAlignment = Alignment.Center) {
                                Box(modifier = Modifier.size(6.dp).background(Color.White, CircleShape))
                            }
                            Spacer(Modifier.height(4.dp))
                            Text("50% Pre-Event", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                            Text("₹40,000 Held", color = ChampagneGold, fontSize = 9.sp)
                        }

                        Box(modifier = Modifier.weight(1f).height(2.dp).background(Color.White.copy(alpha = 0.3f)).padding(horizontal = 4.dp))

                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Box(modifier = Modifier.size(20.dp).background(Color.White.copy(alpha = 0.3f), CircleShape))
                            Spacer(Modifier.height(4.dp))
                            Text("30% Handover", color = Color.White.copy(alpha = 0.5f), fontSize = 9.sp)
                            Text("₹24,000 Post-Event", color = Color.White.copy(alpha = 0.5f), fontSize = 9.sp)
                        }
                    }
                }
            }

            // ─── 2. Auspicious Slot Tracker ───
            Text("📅 My Auspicious Slot Tracker", fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(2.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Select a date to block bookings or apply 1.5x Festive Surge Prices", fontSize = 11.sp, color = SlateGray)
                    Spacer(Modifier.height(12.dp))

                    // Simplified Calendar Grid (28 days)
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        listOf("M", "T", "W", "T", "F", "S", "S").forEach { day ->
                            Text(day, modifier = Modifier.weight(1f), textAlign = androidx.compose.ui.text.style.TextAlign.Center, fontWeight = FontWeight.Black, color = SlateGray, fontSize = 10.sp)
                        }
                    }
                    Spacer(Modifier.height(6.dp))

                    val chunkedDates = (1..28).chunked(7)
                    chunkedDates.forEach { row ->
                        Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                            row.forEach { date ->
                                val blocked = date in blockedDates
                                val surged = date in surgedDates
                                val bg = when {
                                    blocked -> Color.LightGray.copy(alpha = 0.4f)
                                    surged -> ChampagneGold.copy(alpha = 0.2f)
                                    else -> PearlWhite
                                }
                                val border = when {
                                    blocked -> BorderStroke(1.dp, Color.LightGray)
                                    surged -> BorderStroke(1.dp, ChampagneGold)
                                    else -> null
                                }
                                val textColor = when {
                                    blocked -> SlateGray
                                    surged -> DarkGold
                                    else -> RoyalNavy
                                }

                                Surface(
                                    onClick = {
                                        when {
                                            blocked -> {
                                                blockedDates.remove(date)
                                                surgedDates.add(date)
                                            }
                                            surged -> surgedDates.remove(date)
                                            else -> blockedDates.add(date)
                                        }
                                    },
                                    color = bg,
                                    shape = RoundedCornerShape(8.dp),
                                    border = border,
                                    modifier = Modifier
                                        .weight(1f)
                                        .aspectRatio(1f)
                                        .padding(2.dp)
                                ) {
                                    Box(contentAlignment = Alignment.Center) {
                                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                            Text(date.toString(), fontSize = 12.sp, fontWeight = FontWeight.Bold, color = textColor)
                                            if (surged) Text("1.5x", fontSize = 7.sp, color = DarkGold, fontWeight = FontWeight.Black)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer(Modifier.height(10.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(modifier = Modifier.size(10.dp).background(Color.LightGray.copy(alpha = 0.4f), RoundedCornerShape(2.dp)))
                            Spacer(Modifier.width(4.dp))
                            Text("Blocked / Booked", fontSize = 10.sp, color = SlateGray)
                        }
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(modifier = Modifier.size(10.dp).background(ChampagneGold.copy(alpha = 0.2f), RoundedCornerShape(2.dp)))
                            Spacer(Modifier.width(4.dp))
                            Text("1.5x Festive Surge", fontSize = 10.sp, color = DarkGold)
                        }
                    }
                }
            }

            // ─── 3. Fixed SKU Package Builder ───
            Text("📦 Create Fixed-Price Packages", fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(2.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text("Add dynamic, fixed price packages clients can book in one tap.", fontSize = 11.sp, color = SlateGray)
                    OutlinedTextField(
                        value = pkgName,
                        onValueChange = { pkgName = it },
                        label = { Text("Package Name (e.g. Minimalist Haldi Decor)") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    OutlinedTextField(
                        value = pkgPrice,
                        onValueChange = { pkgPrice = it },
                        label = { Text("Package Price (e.g. ₹15,000)") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Button(
                        onClick = {
                            if (pkgName.isBlank() || pkgPrice.isBlank()) {
                                Toast.makeText(context, "Please fill in all package details!", Toast.LENGTH_SHORT).show()
                                return@Button
                            }
                            Toast.makeText(context, "🎉 Fixed-Price SKU Package Created!", Toast.LENGTH_SHORT).show()
                            pkgName = ""
                            pkgPrice = ""
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
                        shape = RoundedCornerShape(8.dp),
                        modifier = Modifier.fillMaxWidth().height(40.dp)
                    ) {
                        Text("Add Package SKU", fontWeight = FontWeight.Bold)
                    }
                }
            }

            // ─── 4. One-Tap Venue Arrival Check-in ───
            Text("📍 Event Day Arrival Check-in", fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White),
                elevation = CardDefaults.cardElevation(2.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Venue Check-in Tracker", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                        Text(
                            text = if (arrivingState.contains("Checked")) "Arrived at venue Banjara Hills 🏛️" else "Tap check-in when you arrive at wedding venue.",
                            fontSize = 11.sp, color = SlateGray
                        )
                    }

                    Button(
                        onClick = {
                            isCheckingIn = true
                            scope.launch {
                                delay(1200)
                                arrivingState = "Arrived Successfully"
                                isCheckingIn = false
                                Toast.makeText(context, "📍 Check-in Successful! Client & Ops Notified.", Toast.LENGTH_LONG).show()
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = if (arrivingState.contains("Arrived")) EmeraldGreen else ChampagneGold),
                        shape = RoundedCornerShape(8.dp),
                        enabled = !isCheckingIn && !arrivingState.contains("Arrived")
                    ) {
                        if (isCheckingIn) {
                            CircularProgressIndicator(color = Color.White, modifier = Modifier.size(16.dp))
                        } else {
                            Text(if (arrivingState.contains("Arrived")) "Checked" else "Check-in")
                        }
                    }
                }
            }

            Spacer(Modifier.height(30.dp))
        }
    }
}
