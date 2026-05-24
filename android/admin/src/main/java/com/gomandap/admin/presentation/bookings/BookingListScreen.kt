package com.gomandap.admin.presentation.bookings

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.KeyboardArrowUp
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.LockOpen
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookingListScreen(onBack: () -> Unit) {
    val scope = rememberCoroutineScope()
    var expandedBookingId by remember { mutableStateOf<String?>(null) }

    val db = remember { com.google.firebase.firestore.FirebaseFirestore.getInstance() }
    
    // Real-time Firestore platform bookings state
    var platformBookings by remember { mutableStateOf<List<AdminBooking>>(emptyList()) }

    // FLAG_SECURE window manager injection to prevent screenshotting sensitive banking/payout details
    val context = androidx.compose.ui.platform.LocalContext.current
    LaunchedEffect(Unit) {
        val activity = context as? android.app.Activity
        activity?.window?.addFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
    }

    // Biometric Security dialog states
    var showBiometricDialog by remember { mutableStateOf(false) }
    var activeBiometricBookingId by remember { mutableStateOf<String?>(null) }
    var activeBiometricMilestoneIdx by remember { mutableStateOf<Int?>(null) }
    var activeBiometricMilestoneLabel by remember { mutableStateOf("") }
    var activeBiometricMilestoneAmount by remember { mutableStateOf(0.0) }

    LaunchedEffect(Unit) {
        db.collection("bookings")
            .addSnapshotListener { snapshot, error ->
                if (error != null) return@addSnapshotListener
                if (snapshot != null) {
                    val bookingsList = snapshot.documents.mapNotNull { doc ->
                        try {
                            val id = doc.id
                            val clientName = doc.getString("clientName") ?: "Client User"
                            val venueName = doc.getString("vendorName") ?: doc.getString("vendorId") ?: "Venue Partner"
                            val eventDate = doc.getString("eventDate") ?: "14 Nov 2026"
                            val totalAmount = doc.getDouble("totalAmount") ?: 250000.0
                            val milestonesRaw = doc.get("milestones") as? List<Map<String, Any>> ?: emptyList()
                            val milestonesList = milestonesRaw.map { m ->
                                AdminMilestone(
                                    id = m["id"] as? String ?: "",
                                    label = m["title"] as? String ?: m["label"] as? String ?: "",
                                    amount = (m["amount"] as? Number)?.toDouble() ?: 0.0,
                                    status = m["status"] as? String ?: "HELD"
                                )
                            }
                            AdminBooking(id, clientName, venueName, eventDate, totalAmount, milestonesList)
                        } catch (e: Exception) {
                            null
                        }
                    }
                    platformBookings = bookingsList
                }
            }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Escrow Bookings Audit", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = PearlWhite
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text(
                text = "Active Platform Escrow Trusts",
                fontWeight = FontWeight.Black,
                fontSize = 17.sp,
                color = RoyalNavy
            )

            if (platformBookings.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 40.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("No active escrow bookings found on Firestore.", color = Color.Gray, fontSize = 14.sp)
                        Spacer(modifier = Modifier.height(16.dp))
                        var isSeeding by remember { mutableStateOf(false) }
                        Button(
                            onClick = {
                                scope.launch {
                                    isSeeding = true
                                    try {
                                        val demoBookings = listOf(
                                            mapOf(
                                                "clientName" to "Aditi Sharma",
                                                "vendorName" to "Umaid Bhawan Palace",
                                                "eventDate" to "18 Dec 2026",
                                                "totalAmount" to 1200000.0,
                                                "milestones" to listOf(
                                                    mapOf("id" to "m1", "title" to "20% Booking Deposit", "amount" to 240000.0, "status" to "RELEASED"),
                                                    mapOf("id" to "m2", "title" to "50% Pre-Event Setup Lock", "amount" to 600000.0, "status" to "HELD"),
                                                    mapOf("id" to "m3", "title" to "30% Post-Event Handover", "amount" to 360000.0, "status" to "HELD")
                                                )
                                            ),
                                            mapOf(
                                                "clientName" to "Vikram Mehta",
                                                "vendorName" to "Imperial Floral Designs",
                                                "eventDate" to "22 Nov 2026",
                                                "totalAmount" to 350000.0,
                                                "milestones" to listOf(
                                                    mapOf("id" to "m1", "title" to "20% Booking Deposit", "amount" to 70000.0, "status" to "RELEASED"),
                                                    mapOf("id" to "m2", "title" to "50% Pre-Event Setup Lock", "amount" to 175000.0, "status" to "RELEASED"),
                                                    mapOf("id" to "m3", "title" to "30% Post-Event Handover", "amount" to 105000.0, "status" to "HELD")
                                                )
                                            )
                                        )

                                        demoBookings.forEachIndexed { index, booking ->
                                            db.collection("bookings").document("BK-108${index + 2}").set(booking).await()
                                        }
                                    } catch (e: Exception) {
                                        e.printStackTrace()
                                    }
                                    isSeeding = false
                                }
                            },
                            colors = ButtonDefaults.buttonColors(containerColor = ChampagneGold),
                            enabled = !isSeeding
                        ) {
                            if (isSeeding) {
                                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(16.dp))
                            } else {
                                Text("Seed Demo Escrow Bookings", color = RoyalNavy, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            } else {
                platformBookings.forEach { booking ->
                    val isExpanded = expandedBookingId == booking.id
                    val releasedAmount = booking.milestones.filter { it.status == "RELEASED" }.sumOf { it.amount }
                    val heldAmount = booking.milestones.filter { it.status == "HELD" }.sumOf { it.amount }

                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .border(
                                width = 1.dp,
                                color = if (isExpanded) ChampagneGold.copy(alpha = 0.4f) else Color.Transparent,
                                shape = RoundedCornerShape(16.dp)
                            ),
                        shape = RoundedCornerShape(16.dp),
                        colors = CardDefaults.cardColors(containerColor = Color.White)
                    ) {
                        Column(
                            modifier = Modifier
                                .clickable { expandedBookingId = if (isExpanded) null else booking.id }
                                .padding(16.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Text(text = booking.id, fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                                        Spacer(modifier = Modifier.width(6.dp))
                                        Box(
                                            modifier = Modifier
                                                .background(EmeraldGreen.copy(alpha = 0.1f), RoundedCornerShape(4.dp))
                                                .padding(horizontal = 6.dp, vertical = 2.dp)
                                        ) {
                                            Text("ACTIVE ESCROW", color = EmeraldGreen, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                                        }
                                    }
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Text(text = "Client: ${booking.clientName}", fontSize = 12.sp, color = Color.Gray)
                                    Text(text = "Venue: ${booking.venueName}", fontSize = 12.sp, color = Color.Gray)
                                }

                                Icon(
                                    imageVector = if (isExpanded) Icons.Default.KeyboardArrowUp else Icons.Default.KeyboardArrowDown,
                                    contentDescription = "Toggle milestones details",
                                    tint = RoyalNavy
                                )
                            }

                            Spacer(modifier = Modifier.height(12.dp))
                            Divider(color = Color.LightGray.copy(alpha = 0.2f))
                            Spacer(modifier = Modifier.height(10.dp))

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Column {
                                    Text("Total Locked Trust", fontSize = 10.sp, color = Color.Gray)
                                    Text("₹${String.format("%,.0f", booking.totalAmount)}", fontWeight = FontWeight.Black, fontSize = 15.sp, color = RoyalNavy)
                                }
                                Column(horizontalAlignment = Alignment.End) {
                                    Text("Released to Vendor", fontSize = 10.sp, color = Color.Gray)
                                    Text("₹${String.format("%,.0f", releasedAmount)}", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = EmeraldGreen)
                                }
                            }

                            AnimatedVisibility(visible = isExpanded) {
                                Column(
                                    modifier = Modifier
                                        .padding(top = 16.dp)
                                        .fillMaxWidth(),
                                    verticalArrangement = Arrangement.spacedBy(10.dp)
                                ) {
                                    // 3-Node Timeline Visualizer
                                    Spacer(modifier = Modifier.height(4.dp))
                                    Row(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .background(RoyalNavy.copy(alpha = 0.04f), RoundedCornerShape(8.dp))
                                            .border(1.dp, ChampagneGold.copy(alpha = 0.15f), RoundedCornerShape(8.dp))
                                            .padding(12.dp),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        val m1 = booking.milestones.getOrNull(0)
                                        val m2 = booking.milestones.getOrNull(1)
                                        val m3 = booking.milestones.getOrNull(2)

                                        TimelineNode(label = "Deposit", percentage = "20%", status = m1?.status ?: "PENDING", modifier = Modifier.weight(1f))
                                        TimelineConnector(isCompleted = (m2?.status == "RELEASED"))
                                        TimelineNode(label = "Setup", percentage = "50%", status = m2?.status ?: "PENDING", modifier = Modifier.weight(1f))
                                        TimelineConnector(isCompleted = (m3?.status == "RELEASED"))
                                        TimelineNode(label = "Handover", percentage = "30%", status = m3?.status ?: "PENDING", modifier = Modifier.weight(1f))
                                    }
                                    Spacer(modifier = Modifier.height(6.dp))

                                    // Secure Masked Bank details Panel
                                    var isAccountRevealed by remember { mutableStateOf(false) }
                                    var isUpiRevealed by remember { mutableStateOf(false) }
                                    var accountTimerJob by remember { mutableStateOf<kotlinx.coroutines.Job?>(null) }
                                    var upiTimerJob by remember { mutableStateOf<kotlinx.coroutines.Job?>(null) }

                                    Card(
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .border(1.dp, Color.LightGray.copy(alpha = 0.15f), RoundedCornerShape(8.dp)),
                                        shape = RoundedCornerShape(8.dp),
                                        colors = CardDefaults.cardColors(containerColor = RoyalNavy.copy(alpha = 0.02f))
                                    ) {
                                        Column(
                                            modifier = Modifier.padding(12.dp),
                                            verticalArrangement = Arrangement.spacedBy(6.dp)
                                        ) {
                                            Row(
                                                modifier = Modifier.fillMaxWidth(),
                                                horizontalArrangement = Arrangement.SpaceBetween,
                                                verticalAlignment = Alignment.CenterVertically
                                            ) {
                                                Text("Escrow Vault Bank Details", fontWeight = FontWeight.Bold, fontSize = 10.sp, color = RoyalNavy)
                                                Icon(imageVector = Icons.Default.Lock, contentDescription = "Secure Field", tint = ChampagneGold, modifier = Modifier.size(12.dp))
                                            }
                                            Divider(color = Color.LightGray.copy(alpha = 0.2f))
                                            
                                            // Beneficiary Name
                                            Row(
                                                modifier = Modifier.fillMaxWidth(),
                                                horizontalArrangement = Arrangement.SpaceBetween
                                            ) {
                                                Text("Beneficiary:", fontSize = 10.sp, color = Color.Gray, fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace)
                                                Text(booking.venueName, fontSize = 10.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                                            }

                                            // Bank Account Number
                                            Row(
                                                modifier = Modifier.fillMaxWidth(),
                                                horizontalArrangement = Arrangement.SpaceBetween,
                                                verticalAlignment = Alignment.CenterVertically
                                            ) {
                                                Text("A/C Number:", fontSize = 10.sp, color = Color.Gray, fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace)
                                                Row(
                                                    verticalAlignment = Alignment.CenterVertically,
                                                    modifier = Modifier.clickable {
                                                        accountTimerJob?.cancel()
                                                        isAccountRevealed = !isAccountRevealed
                                                        if (isAccountRevealed) {
                                                            accountTimerJob = scope.launch {
                                                                delay(30000)
                                                                isAccountRevealed = false
                                                            }
                                                        }
                                                    }
                                                ) {
                                                    Text(
                                                        text = if (isAccountRevealed) "3098 7654 3210" else "•••• •••• •••• 3210",
                                                        fontSize = 10.sp,
                                                        fontWeight = FontWeight.Bold,
                                                        color = RoyalNavy,
                                                        fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                                                    )
                                                    Spacer(modifier = Modifier.width(4.dp))
                                                    Icon(
                                                        imageVector = if (isAccountRevealed) Icons.Default.LockOpen else Icons.Default.Lock,
                                                        contentDescription = "Reveal Account Number",
                                                        tint = ChampagneGold,
                                                        modifier = Modifier.size(11.dp)
                                                    )
                                                }
                                            }

                                            // UPI ID
                                            Row(
                                                modifier = Modifier.fillMaxWidth(),
                                                horizontalArrangement = Arrangement.SpaceBetween,
                                                verticalAlignment = Alignment.CenterVertically
                                            ) {
                                                Text("UPI ID:", fontSize = 10.sp, color = Color.Gray, fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace)
                                                Row(
                                                    verticalAlignment = Alignment.CenterVertically,
                                                    modifier = Modifier.clickable {
                                                        upiTimerJob?.cancel()
                                                        isUpiRevealed = !isUpiRevealed
                                                        if (isUpiRevealed) {
                                                            upiTimerJob = scope.launch {
                                                                delay(30000)
                                                                isUpiRevealed = false
                                                            }
                                                        }
                                                    }
                                                ) {
                                                    val cleanVenueName = booking.venueName.lowercase().replace(" ", "")
                                                    Text(
                                                        text = if (isUpiRevealed) "${cleanVenueName}@okaxis" else "••••••••••••@okaxis",
                                                        fontSize = 10.sp,
                                                        fontWeight = FontWeight.Bold,
                                                        color = RoyalNavy,
                                                        fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                                                    )
                                                    Spacer(modifier = Modifier.width(4.dp))
                                                    Icon(
                                                        imageVector = if (isUpiRevealed) Icons.Default.LockOpen else Icons.Default.Lock,
                                                        contentDescription = "Reveal UPI ID",
                                                        tint = ChampagneGold,
                                                        modifier = Modifier.size(11.dp)
                                                    )
                                                }
                                            }
                                        }
                                    }
                                    
                                    Divider(color = Color.LightGray.copy(alpha = 0.3f))
                                    Text(
                                        text = "Milestones Audit Check",
                                        fontWeight = FontWeight.Bold,
                                        fontSize = 12.sp,
                                        color = RoyalNavy
                                    )

                                    booking.milestones.forEachIndexed { milestoneIdx, milestone ->
                                        val isReleased = milestone.status == "RELEASED"
                                        val milestoneColor = if (isReleased) EmeraldGreen else ChampagneGold

                                        Row(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .background(PearlWhite, RoundedCornerShape(10.dp))
                                                .border(1.dp, Color.LightGray.copy(alpha = 0.2f), RoundedCornerShape(10.dp))
                                                .padding(12.dp),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Column {
                                                Text(text = milestone.label, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                                Text(text = "₹${String.format("%,.0f", milestone.amount)}", fontSize = 11.sp, color = Color.Gray)
                                                Spacer(modifier = Modifier.height(4.dp))
                                                Box(
                                                    modifier = Modifier
                                                        .background(milestoneColor.copy(alpha = 0.1f), RoundedCornerShape(4.dp))
                                                        .padding(horizontal = 6.dp, vertical = 2.dp)
                                                ) {
                                                    Text(
                                                        text = milestone.status,
                                                        color = milestoneColor,
                                                        fontSize = 8.sp,
                                                        fontWeight = FontWeight.Bold
                                                    )
                                                }
                                            }

                                            if (!isReleased) {
                                                Button(
                                                    onClick = {
                                                        activeBiometricBookingId = booking.id
                                                        activeBiometricMilestoneIdx = milestoneIdx
                                                        activeBiometricMilestoneLabel = milestone.label
                                                        activeBiometricMilestoneAmount = milestone.amount
                                                        showBiometricDialog = true
                                                    },
                                                    shape = RoundedCornerShape(6.dp),
                                                    colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                                                    contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp),
                                                    modifier = Modifier.height(30.dp)
                                                ) {
                                                    Text("Audit Release", fontSize = 10.sp, fontWeight = FontWeight.Bold, color = Color.White)
                                                }
                                            } else {
                                                Icon(
                                                    imageVector = Icons.Default.CheckCircle,
                                                    contentDescription = "Success",
                                                    tint = EmeraldGreen,
                                                    modifier = Modifier.size(24.dp)
                                                )
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
    }

    // Secondary Biometric dialog trigger
    if (showBiometricDialog && activeBiometricBookingId != null && activeBiometricMilestoneIdx != null) {
        BiometricReleaseDialog(
            bookingId = activeBiometricBookingId!!,
            milestoneLabel = activeBiometricMilestoneLabel,
            amount = activeBiometricMilestoneAmount,
            onConfirm = {
                val bId = activeBiometricBookingId!!
                val mIdx = activeBiometricMilestoneIdx!!
                showBiometricDialog = false
                activeBiometricBookingId = null
                activeBiometricMilestoneIdx = null
                
                // Execute secure release database write post verification
                scope.launch {
                    try {
                        val docRef = db.collection("bookings").document(bId)
                        val doc = docRef.get().await()
                        if (doc.exists()) {
                            val milestonesRaw = doc.get("milestones") as? List<Map<String, Any>> ?: emptyList()
                            val updatedMilestones = milestonesRaw.mapIndexed { idx, m ->
                                if (idx == mIdx) {
                                    m.toMutableMap().apply { put("status", "RELEASED") }
                                } else {
                                    m
                                }
                            }
                            docRef.update("milestones", updatedMilestones).await()
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            },
            onDismiss = {
                showBiometricDialog = false
                activeBiometricBookingId = null
                activeBiometricMilestoneIdx = null
            }
        )
    }
}

@Composable
private fun TimelineNode(label: String, percentage: String, status: String, modifier: Modifier = Modifier) {
    val color = when (status) {
        "RELEASED" -> EmeraldGreen
        "HELD" -> ChampagneGold
        else -> Color.Gray
    }
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = modifier
    ) {
        Box(
            modifier = Modifier
                .size(24.dp)
                .background(color.copy(alpha = 0.1f), CircleShape)
                .border(2.dp, color, CircleShape),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = percentage,
                fontSize = 7.sp,
                fontWeight = FontWeight.Bold,
                color = color
            )
        }
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = label,
            fontSize = 9.sp,
            fontWeight = FontWeight.Bold,
            color = RoyalNavy
        )
        Text(
            text = status,
            fontSize = 8.sp,
            fontWeight = FontWeight.SemiBold,
            color = color
        )
    }
}

@Composable
private fun TimelineConnector(isCompleted: Boolean) {
    val color = if (isCompleted) EmeraldGreen else Color.LightGray.copy(alpha = 0.5f)
    Box(
        modifier = Modifier
            .width(24.dp)
            .height(2.dp)
            .background(color)
    )
}

@Composable
fun BiometricReleaseDialog(
    bookingId: String,
    milestoneLabel: String,
    amount: Double,
    onConfirm: () -> Unit,
    onDismiss: () -> Unit
) {
    var isVerifying by remember { mutableStateOf(false) }
    var verificationResult by remember { mutableStateOf<Boolean?>(null) } // null = not started, true = success, false = failed
    val scope = rememberCoroutineScope()
    val haptic = androidx.compose.ui.platform.LocalHapticFeedback.current

    AlertDialog(
        onDismissRequest = { if (!isVerifying) onDismiss() },
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Lock,
                    contentDescription = null,
                    tint = ChampagneGold,
                    modifier = Modifier.size(22.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("Biometric Verification Required", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
            }
        },
        text = {
            Column(
                modifier = Modifier.fillMaxWidth(),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "Release Payment to Vendor Vault",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.Gray
                )
                Spacer(modifier = Modifier.height(8.dp))
                
                // Payout Details Box
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(PearlWhite, RoundedCornerShape(8.dp))
                        .border(1.dp, ChampagneGold.copy(alpha = 0.3f), RoundedCornerShape(8.dp))
                        .padding(12.dp)
                ) {
                    Column {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text("Booking Reference:", fontSize = 10.sp, color = Color.Gray)
                            Text(bookingId, fontSize = 10.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                        }
                        Spacer(modifier = Modifier.height(4.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text("Milestone:", fontSize = 10.sp, color = Color.Gray)
                            Text(milestoneLabel, fontSize = 10.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                        }
                        Spacer(modifier = Modifier.height(4.dp))
                        Divider(color = Color.LightGray.copy(alpha = 0.3f))
                        Spacer(modifier = Modifier.height(4.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text("Transfer Amount:", fontSize = 10.sp, color = Color.Gray)
                            Text(
                                "₹${String.format("%,.0f", amount)}",
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Black,
                                color = EmeraldGreen,
                                fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                            )
                        }
                    }
                }
                
                Spacer(modifier = Modifier.height(20.dp))
                
                // Fingerprint scanner mockup
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .background(
                            if (verificationResult == true) EmeraldGreen.copy(alpha = 0.1f) else RoyalNavy.copy(alpha = 0.05f),
                            CircleShape
                        )
                        .border(
                            width = 2.dp,
                            color = when (verificationResult) {
                                true -> EmeraldGreen
                                false -> RoseRed
                                else -> ChampagneGold
                            },
                            shape = CircleShape
                        ),
                    contentAlignment = Alignment.Center
                ) {
                    if (isVerifying) {
                        CircularProgressIndicator(
                            color = ChampagneGold,
                            modifier = Modifier.size(40.dp),
                            strokeWidth = 3.dp
                        )
                    } else {
                        Icon(
                            imageVector = if (verificationResult == true) Icons.Default.CheckCircle else Icons.Default.Lock,
                            contentDescription = "Fingerprint Sensor",
                            tint = when (verificationResult) {
                                true -> EmeraldGreen
                                false -> RoseRed
                                else -> ChampagneGold
                            },
                            modifier = Modifier.size(36.dp)
                        )
                    }
                }
                
                Spacer(modifier = Modifier.height(12.dp))
                
                Text(
                    text = when {
                        isVerifying -> "Validating fingerprint credential..."
                        verificationResult == true -> "Identity Confirmed. Authorizing release..."
                        verificationResult == false -> "Fingerprint not recognized. Try again."
                        else -> "Place administrator finger on the biometric scanner"
                    },
                    fontSize = 11.sp,
                    color = when (verificationResult) {
                        true -> EmeraldGreen
                        false -> RoseRed
                        else -> RoyalNavy
                    },
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.padding(horizontal = 16.dp),
                    textAlign = androidx.compose.ui.text.style.TextAlign.Center
                )
            }
        },
        confirmButton = {
            if (verificationResult == null && !isVerifying) {
                Button(
                    onClick = {
                        scope.launch {
                            isVerifying = true
                            haptic.performHapticFeedback(androidx.compose.ui.hapticfeedback.HapticFeedbackType.LongPress)
                            delay(1200) // Simulated scanner delay
                            isVerifying = false
                            verificationResult = true
                            haptic.performHapticFeedback(androidx.compose.ui.hapticfeedback.HapticFeedbackType.LongPress)
                            delay(800) // Success delay
                            onConfirm()
                        }
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy)
                ) {
                    Text("Simulate TouchID / FaceID", color = Color.White)
                }
            }
        },
        dismissButton = {
            if (!isVerifying) {
                TextButton(onClick = onDismiss) {
                    Text("Cancel", color = Color.Gray)
                }
            }
        },
        containerColor = Color.White,
        shape = RoundedCornerShape(16.dp)
    )
}

// State Models
private data class AdminBooking(
    val id: String,
    val clientName: String,
    val venueName: String,
    val eventDate: String,
    val totalAmount: Double,
    val milestones: List<AdminMilestone>
)

private data class AdminMilestone(
    val id: String,
    val label: String,
    val amount: Double,
    val status: String // HELD, RELEASED
)
