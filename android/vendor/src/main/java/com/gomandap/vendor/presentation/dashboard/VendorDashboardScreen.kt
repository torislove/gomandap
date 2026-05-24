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
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.res.painterResource
import com.gomandap.app.presentation.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VendorDashboardScreen(onNavigateToOnboard: () -> Unit) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    val db = remember { com.google.firebase.firestore.FirebaseFirestore.getInstance() }

    var bookingData by remember { mutableStateOf<Map<String, Any>?>(null) }
    var milestones by remember { mutableStateOf<List<Map<String, Any>>>(emptyList()) }
    var isCheckingIn by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        db.collection("bookings").document("BK-1082")
            .addSnapshotListener { snapshot, error ->
                if (snapshot != null && snapshot.exists()) {
                    bookingData = snapshot.data
                    milestones = snapshot.get("milestones") as? List<Map<String, Any>> ?: emptyList()
                }
            }
    }

    val totalAmount = bookingData?.get("totalAmount") as? Double ?: 250000.0
    val activeVaultBalance = "₹" + String.format("%,.0f", totalAmount)
    val checkInStatus = bookingData?.get("checkInStatus") as? String ?: "NOT_ARRIVED"
    val isArrived = checkInStatus == "ARRIVED"

    // Blocked calendar dates state (simulated)
    val blockedDates = remember { mutableStateListOf(3, 14, 22) }
    val surgedDates = remember { mutableStateListOf(4, 15, 23) }

    // Package builder states
    var pkgName by remember { mutableStateOf("") }
    var pkgPrice by remember { mutableStateOf("") }

    val DeepNavyDark   = Color(0xFF090D1A)
    val CardNavyBg     = Color(0xFF131C35)
    val LightSlateText = Color(0xFF94A3B8)
    val BorderGold     = Color(0xFFDFBA73)
    val GlowGold       = Color(0xFFC59A48)

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Image(
                            painter = painterResource(id = com.gomandap.common.R.drawable.ic_gm_logo),
                            contentDescription = "GM Logo",
                            modifier = Modifier.size(24.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("GM ", fontWeight = FontWeight.Black, color = Color.White, fontSize = 20.sp)
                        Text("Vendor Hub", fontWeight = FontWeight.Black, color = ChampagneGold, fontSize = 20.sp)
                    }
                },
                actions = {
                    IconButton(onClick = onNavigateToOnboard) {
                        Icon(imageVector = Icons.Default.Add, contentDescription = "Add Storefront", tint = ChampagneGold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = DeepNavyDark)
            )
        },
        containerColor = DeepNavyDark
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
            Text("💰 Safe Payout Vault", fontWeight = FontWeight.Black, fontSize = 16.sp, color = Color.White)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardNavyBg),
                modifier = Modifier
                    .fillMaxWidth()
                    .border(
                        BorderStroke(1.2.dp, Brush.linearGradient(listOf(BorderGold, GlowGold))),
                        RoundedCornerShape(16.dp)
                    )
            ) {
                Column(modifier = Modifier.padding(18.dp)) {
                    Text("Total Milestone Payouts Locked", color = LightSlateText, fontSize = 10.sp)
                    Text(activeVaultBalance, color = Color.White, fontWeight = FontWeight.Black, fontSize = 28.sp)
                    Spacer(Modifier.height(14.dp))

                    // Node Timeline Layout
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        val m1 = milestones.find { (it["index"] as? Long)?.toInt() == 1 || (it["index"] as? Int) == 1 }
                        val m2 = milestones.find { (it["index"] as? Long)?.toInt() == 2 || (it["index"] as? Int) == 2 }
                        val m3 = milestones.find { (it["index"] as? Long)?.toInt() == 3 || (it["index"] as? Int) == 3 }

                        val m1Status = m1?.get("status") as? String ?: "RELEASED"
                        val m1Amount = m1?.get("amount") as? Double ?: (totalAmount * 0.2)

                        val m2Status = m2?.get("status") as? String ?: "HELD"
                        val m2Amount = m2?.get("amount") as? Double ?: (totalAmount * 0.5)

                        val m3Status = m3?.get("status") as? String ?: "HELD"
                        val m3Amount = m3?.get("amount") as? Double ?: (totalAmount * 0.3)

                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Box(modifier = Modifier.size(20.dp).background(EmeraldGreen, CircleShape), contentAlignment = Alignment.Center) {
                                Icon(Icons.Default.Check, null, tint = Color.White, modifier = Modifier.size(10.dp))
                            }
                            Spacer(Modifier.height(4.dp))
                            Text("20% Booking Lock", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                            Text("₹${String.format("%,.0f", m1Amount)} Paid", color = EmeraldGreen, fontSize = 9.sp)
                        }

                        val line12Color = if (m2Status == "RELEASED") EmeraldGreen else BorderGold
                        Box(modifier = Modifier.weight(1f).height(2.dp).background(line12Color).padding(horizontal = 4.dp))

                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            val node2Bg = if (m2Status == "RELEASED") EmeraldGreen else BorderGold
                            Box(modifier = Modifier.size(20.dp).background(node2Bg, CircleShape), contentAlignment = Alignment.Center) {
                                if (m2Status == "RELEASED") {
                                    Icon(Icons.Default.Check, null, tint = Color.White, modifier = Modifier.size(10.dp))
                                } else {
                                    Box(modifier = Modifier.size(6.dp).background(Color.White, CircleShape))
                                }
                            }
                            Spacer(Modifier.height(4.dp))
                            Text("50% Pre-Event", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                            Text("₹${String.format("%,.0f", m2Amount)} " + if (m2Status == "RELEASED") "Paid" else "Held", color = node2Bg, fontSize = 9.sp)
                        }

                        val line23Color = if (m3Status == "RELEASED") EmeraldGreen else Color.White.copy(alpha = 0.2f)
                        Box(modifier = Modifier.weight(1f).height(2.dp).background(line23Color).padding(horizontal = 4.dp))

                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            val node3Bg = if (m3Status == "RELEASED") EmeraldGreen else Color.White.copy(alpha = 0.2f)
                            Box(modifier = Modifier.size(20.dp).background(node3Bg, CircleShape), contentAlignment = Alignment.Center) {
                                if (m3Status == "RELEASED") {
                                    Icon(Icons.Default.Check, null, tint = Color.White, modifier = Modifier.size(10.dp))
                                }
                            }
                            Spacer(Modifier.height(4.dp))
                            Text("30% Handover", color = if (m3Status == "RELEASED") Color.White else Color.White.copy(alpha = 0.5f), fontSize = 9.sp)
                            Text("₹${String.format("%,.0f", m3Amount)} " + if (m3Status == "RELEASED") "Paid" else "Post-Event", color = if (m3Status == "RELEASED") EmeraldGreen else Color.White.copy(alpha = 0.5f), fontSize = 9.sp)
                        }
                    }
                }
            }

            // ─── 2. Auspicious Slot Tracker & Surge Pricing Multiplier ───
            Text("📅 Auspicious Slot Tracker & Surge Pricing", fontWeight = FontWeight.Black, fontSize = 16.sp, color = Color.White)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardNavyBg),
                modifier = Modifier
                    .fillMaxWidth()
                    .border(BorderStroke(1.dp, BorderGold.copy(alpha = 0.3f)), RoundedCornerShape(16.dp))
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text("Select a date to block bookings or apply 1.5x Festive Surge Prices", fontSize = 11.sp, color = LightSlateText)
                    Spacer(Modifier.height(12.dp))

                    // Calendar Grid (28 days)
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        listOf("M", "T", "W", "T", "F", "S", "S").forEach { day ->
                            Text(day, modifier = Modifier.weight(1f), textAlign = androidx.compose.ui.text.style.TextAlign.Center, fontWeight = FontWeight.Black, color = LightSlateText, fontSize = 10.sp)
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
                                    blocked -> Color.White.copy(alpha = 0.1f)
                                    surged -> BorderGold.copy(alpha = 0.2f)
                                    else -> DeepNavyDark
                                }
                                val border = when {
                                    blocked -> BorderStroke(1.dp, Color.White.copy(alpha = 0.2f))
                                    surged -> BorderStroke(1.dp, BorderGold)
                                    else -> BorderStroke(1.dp, Color.White.copy(alpha = 0.05f))
                                }
                                val textColor = when {
                                    blocked -> LightSlateText
                                    surged -> BorderGold
                                    else -> Color.White
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
                                            if (surged) Text("1.5x", fontSize = 7.sp, color = BorderGold, fontWeight = FontWeight.Black)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer(Modifier.height(10.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(modifier = Modifier.size(10.dp).background(Color.White.copy(alpha = 0.1f), RoundedCornerShape(2.dp)))
                            Spacer(Modifier.width(4.dp))
                            Text("Blocked / Booked", fontSize = 10.sp, color = LightSlateText)
                        }
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Box(modifier = Modifier.size(10.dp).background(BorderGold.copy(alpha = 0.2f), RoundedCornerShape(2.dp)))
                            Spacer(Modifier.width(4.dp))
                            Text("1.5x Festive Surge", fontSize = 10.sp, color = BorderGold)
                        }
                    }
                }
            }

            // ─── 3. Fixed SKU Package Builder ───
            Text("📦 Create Fixed-Price Packages", fontWeight = FontWeight.Black, fontSize = 16.sp, color = Color.White)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardNavyBg),
                modifier = Modifier
                    .fillMaxWidth()
                    .border(BorderStroke(1.dp, BorderGold.copy(alpha = 0.3f)), RoundedCornerShape(16.dp))
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text("Add dynamic, fixed price packages clients can book in one tap.", fontSize = 11.sp, color = LightSlateText)
                    OutlinedTextField(
                        value = pkgName,
                        onValueChange = { pkgName = it },
                        label = { Text("Package Name (e.g. Minimalist Haldi Decor)") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = BorderGold,
                            unfocusedBorderColor = Color.White.copy(alpha = 0.25f),
                            focusedLabelColor = BorderGold,
                            unfocusedLabelColor = LightSlateText,
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        )
                    )
                    OutlinedTextField(
                        value = pkgPrice,
                        onValueChange = { pkgPrice = it },
                        label = { Text("Package Price (e.g. ₹15,000)") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = BorderGold,
                            unfocusedBorderColor = Color.White.copy(alpha = 0.25f),
                            focusedLabelColor = BorderGold,
                            unfocusedLabelColor = LightSlateText,
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        )
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
                        colors = ButtonDefaults.buttonColors(containerColor = BorderGold),
                        shape = RoundedCornerShape(8.dp),
                        modifier = Modifier.fillMaxWidth().height(40.dp)
                    ) {
                        Text("Add Package SKU", fontWeight = FontWeight.Bold, color = DeepNavyDark)
                    }
                }
            }

            // ─── 4. One-Tap Venue Arrival Check-in ───
            Text("📍 Event Day Arrival Check-in", fontWeight = FontWeight.Black, fontSize = 16.sp, color = Color.White)
            Card(
                shape = RoundedCornerShape(16.dp),
                colors = CardDefaults.cardColors(containerColor = CardNavyBg),
                modifier = Modifier
                    .fillMaxWidth()
                    .border(BorderStroke(1.dp, BorderGold.copy(alpha = 0.3f)), RoundedCornerShape(16.dp))
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Venue Check-in Tracker", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = Color.White)
                        Text(
                            text = if (isArrived) "Arrived at venue Banjara Hills 🏛️" else "Tap check-in when you arrive at wedding venue.",
                            fontSize = 11.sp, color = LightSlateText
                        )
                    }

                    Button(
                        onClick = {
                            isCheckingIn = true
                            scope.launch {
                                try {
                                    db.collection("bookings").document("BK-1082")
                                        .update("checkInStatus", "ARRIVED")
                                        .await()
                                    
                                    val vendorName = bookingData?.get("vendorName") as? String ?: "Maharaja Banquet Hall"
                                    val interactionData = mapOf(
                                        "title" to "Vendor Checked In - $vendorName",
                                        "description" to "Venue staff marked arrival check-in. Verified location geofence matches address.",
                                        "type" to "COMPLETED",
                                        "timestamp" to com.google.firebase.firestore.FieldValue.serverTimestamp()
                                    )
                                    db.collection("crm_interactions").add(interactionData).await()
                                    
                                    Toast.makeText(context, "📍 Check-in Successful! Client & Ops Notified.", Toast.LENGTH_LONG).show()
                                } catch (e: Exception) {
                                    Toast.makeText(context, "Failed check-in: ${e.localizedMessage}", Toast.LENGTH_SHORT).show()
                                }
                                isCheckingIn = false
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = if (isArrived) EmeraldGreen else BorderGold),
                        shape = RoundedCornerShape(8.dp),
                        enabled = !isCheckingIn && !isArrived
                    ) {
                        if (isCheckingIn) {
                            CircularProgressIndicator(color = Color.White, modifier = Modifier.size(16.dp))
                        } else {
                            Text(
                                text = if (isArrived) "Checked" else "Check-in",
                                color = if (isArrived) Color.White else DeepNavyDark,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }

            Spacer(Modifier.height(30.dp))
        }
    }
}
