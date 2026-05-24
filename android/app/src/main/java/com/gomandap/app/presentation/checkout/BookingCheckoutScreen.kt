package com.gomandap.app.presentation.checkout

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BookingCheckoutScreen(
    venueId: String,
    onCheckoutSuccess: () -> Unit,
    onBackClick: () -> Unit
) {
    var stepIndex by remember { mutableStateOf(1) } // 1: Date Calendar, 2: Package Customizer, 3: Escrow checkout details, 4: Payment gateway
    var selectedDate by remember { mutableStateOf<Int?>(null) }
    
    // Package selections
    var plateCount by remember { mutableIntStateOf(200) }
    var isDjSetupChecked by remember { mutableStateOf(false) }
    var isWelcomeDrinksChecked by remember { mutableStateOf(false) }

    val basePlatePrice = 1200
    val djCost = 25000
    val welcomeDrinksCost = 15000
    
    val calculatedTotal = (plateCount * basePlatePrice) + 
            (if (isDjSetupChecked) djCost else 0) + 
            (if (isWelcomeDrinksChecked) welcomeDrinksCost else 0)

    val scope = rememberCoroutineScope()
    val db = remember { com.google.firebase.firestore.FirebaseFirestore.getInstance() }

    val handlePayClick = {
        scope.launch {
            val bookingId = "BK-1082" // Standard demo ID
            val milestones = listOf(
                mapOf("id" to "${bookingId}_1", "index" to 1, "title" to "Booking Lock (20%)", "amount" to calculatedTotal * 0.2, "status" to "RELEASED"),
                mapOf("id" to "${bookingId}_2", "index" to 2, "title" to "Pre-Event Setup (50%)", "amount" to calculatedTotal * 0.5, "status" to "HELD"),
                mapOf("id" to "${bookingId}_3", "index" to 3, "title" to "Final Handover (30%)", "amount" to calculatedTotal * 0.3, "status" to "HELD")
            )
            val bookingData = mapOf(
                "id" to bookingId,
                "clientId" to "client_user_1",
                "vendorId" to venueId,
                "vendorName" to (com.gomandap.app.data.vendor.VendorRepository.getVendorById(venueId)?.name ?: "The Taj Palace Convention"),
                "vendorCategory" to "Venue & Mandap",
                "eventDate" to "14 Nov 2026",
                "timeSlot" to "Evening (5 PM–11 PM)",
                "totalAmount" to calculatedTotal.toDouble(),
                "status" to "ACTIVE",
                "checkInStatus" to "NOT_ARRIVED",
                "milestones" to milestones
            )
            
            try {
                db.collection("bookings").document(bookingId).set(bookingData).await()
                
                val interactionData = mapOf(
                    "title" to "Escrow Secured - booking #$bookingId",
                    "description" to "Client completed checkout for ${bookingData["vendorName"]}. Booking locked ₹$calculatedTotal securely in escrow.",
                    "type" to "ESCROW_LOCKED",
                    "timestamp" to com.google.firebase.firestore.FieldValue.serverTimestamp()
                )
                db.collection("crm_interactions").add(interactionData).await()
            } catch (e: Exception) {
                e.printStackTrace()
            }
            onCheckoutSuccess()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text = when (stepIndex) {
                            1 -> "Select Event Date"
                            2 -> "Customize Your Event"
                            3 -> "Secure Escrow Lock"
                            else -> "Process Payment"
                        },
                        fontWeight = FontWeight.Bold,
                        color = RoyalNavy
                     )
                },
                navigationIcon = {
                    IconButton(onClick = {
                        if (stepIndex > 1) {
                            stepIndex--
                        } else {
                            onBackClick()
                        }
                    }) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(LightGrayBg)
                .padding(paddingValues)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(bottom = 76.dp) // space for sticky bottom
            ) {
                // Progress timeline steps top bar
                StepProgressBar(currentStep = stepIndex)

                when (stepIndex) {
                    1 -> DateCalendarSelector(
                        selectedDate = selectedDate,
                        onDateSelected = {
                            selectedDate = it
                            stepIndex = 2
                        }
                    )
                    2 -> PackageCustomizer(
                        plateCount = plateCount,
                        onPlateCountChange = { plateCount = it },
                        isDjSetupChecked = isDjSetupChecked,
                        onDjSetupCheckedChange = { isDjSetupChecked = it },
                        isWelcomeDrinksChecked = isWelcomeDrinksChecked,
                        onWelcomeDrinksCheckedChange = { isWelcomeDrinksChecked = it }
                    )
                    3 -> EscrowVisualizer(totalAmount = calculatedTotal.toDouble())
                    4 -> PaymentGatewaySelection(
                        totalAmount = calculatedTotal.toDouble(),
                        onPayClick = { handlePayClick() }
                    )
                }
            }

            // Sticky Bottom CTA Bar
            if (stepIndex in 2..3) {
                Surface(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                        .height(72.dp),
                    shadowElevation = 8.dp,
                    color = Color.White
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(horizontal = 16.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(text = "Booking Summary Total", fontSize = 11.sp, color = Color.Gray)
                            Text(text = "₹$calculatedTotal", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                        }
                        Button(
                            onClick = { stepIndex++ },
                            shape = RoundedCornerShape(8.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                            modifier = Modifier.width(180.dp).height(44.dp)
                        ) {
                            Text(
                                text = if (stepIndex == 3) "Pay Now" else "Proceed",
                                fontWeight = FontWeight.Bold,
                                fontSize = 15.sp,
                                color = Color.White
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun StepProgressBar(currentStep: Int) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White)
            .padding(vertical = 12.dp, horizontal = 24.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        StepNode(index = 1, label = "Date", isActive = currentStep >= 1, isCompleted = currentStep > 1)
        StepLine(isCompleted = currentStep > 1)
        StepNode(index = 2, label = "Package", isActive = currentStep >= 2, isCompleted = currentStep > 2)
        StepLine(isCompleted = currentStep > 2)
        StepNode(index = 3, label = "Escrow", isActive = currentStep >= 3, isCompleted = currentStep > 3)
        StepLine(isCompleted = currentStep > 3)
        StepNode(index = 4, label = "Pay", isActive = currentStep >= 4, isCompleted = currentStep > 4)
    }
}

@Composable
fun StepNode(index: Int, label: String, isActive: Boolean, isCompleted: Boolean) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .size(24.dp)
                .background(
                    color = if (isCompleted) EmeraldGreen else if (isActive) ChampagneGold else Color.LightGray,
                    shape = CircleShape
                ),
            contentAlignment = Alignment.Center
        ) {
            if (isCompleted) {
                Icon(imageVector = Icons.Default.Check, contentDescription = "Done", tint = Color.White, modifier = Modifier.size(14.dp))
            } else {
                Text(text = index.toString(), color = Color.White, fontSize = 10.sp, fontWeight = FontWeight.Bold)
            }
        }
        Spacer(modifier = Modifier.height(2.dp))
        Text(text = label, fontSize = 9.sp, color = if (isActive) RoyalNavy else Color.Gray, fontWeight = FontWeight.Bold)
    }
}

@Composable
fun RowScope.StepLine(isCompleted: Boolean) {
    Box(
        modifier = Modifier
            .weight(1f)
            .height(2.dp)
            .background(if (isCompleted) EmeraldGreen else Color.LightGray)
            .padding(horizontal = 4.dp)
    )
}

@Composable
fun DateCalendarSelector(
    selectedDate: Int?,
    onDateSelected: (Int) -> Unit
) {
    val dates = (1..30).toList()
    val highDemandDays = listOf(7, 14, 15, 22)
    val unavailableDays = listOf(3, 4, 10, 11, 18)

    Column(modifier = Modifier.padding(16.dp)) {
        Text(
            text = "May 2026",
            fontWeight = FontWeight.Black,
            fontSize = 18.sp,
            color = RoyalNavy,
            modifier = Modifier.padding(bottom = 12.dp)
        )
        
        LazyVerticalGrid(
            columns = GridCells.Fixed(7),
            verticalArrangement = Arrangement.spacedBy(8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            val weekdays = listOf("Mo", "Tu", "We", "Th", "Fr", "Sa", "Su")
            items(weekdays) { day ->
                Text(
                    text = day,
                    fontSize = 12.sp,
                    color = Color.Gray,
                    fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center
                )
            }

            items(dates) { date ->
                val isUnavailable = unavailableDays.contains(date)
                val isHighDemand = highDemandDays.contains(date)
                val isSelected = selectedDate == date

                val bgColors = when {
                    isSelected -> EmeraldGreen
                    isUnavailable -> Color.LightGray.copy(alpha = 0.3f)
                    else -> Color.White
                }

                val borderModifier = when {
                    isHighDemand -> Modifier.border(1.dp, ChampagneGold, RoundedCornerShape(8.dp))
                    else -> Modifier.border(1.dp, Color.LightGray.copy(alpha = 0.2f), RoundedCornerShape(8.dp))
                }

                Box(
                    modifier = Modifier
                        .aspectRatio(1f)
                        .background(bgColors, RoundedCornerShape(8.dp))
                        .then(borderModifier)
                        .clickable(enabled = !isUnavailable) { onDateSelected(date) },
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = date.toString(),
                            fontWeight = FontWeight.Bold,
                            color = if (isSelected) Color.White else if (isUnavailable) Color.Gray else RoyalNavy,
                            fontSize = 14.sp
                        )
                        if (isHighDemand && !isSelected) {
                            Box(
                                modifier = Modifier
                                    .background(ChampagneGold.copy(alpha = 0.2f), RoundedCornerShape(2.dp))
                                    .padding(horizontal = 3.dp, vertical = 1.dp)
                            ) {
                                Text("FAST", color = DarkGold, fontSize = 7.sp, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun PackageCustomizer(
    plateCount: Int,
    onPlateCountChange: (Int) -> Unit,
    isDjSetupChecked: Boolean,
    onDjSetupCheckedChange: (Boolean) -> Unit,
    isWelcomeDrinksChecked: Boolean,
    onWelcomeDrinksCheckedChange: (Boolean) -> Unit
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Guest plate count controller
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(text = "Catering Guest Count", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(text = "Base plate price: ₹1,200/Plate", fontSize = 11.sp, color = Color.Gray)
                    Spacer(modifier = Modifier.height(12.dp))

                    Row(
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        IconButton(
                            onClick = { if (plateCount > 50) onPlateCountChange(plateCount - 50) },
                            modifier = Modifier.background(LightGrayBg, CircleShape)
                        ) {
                            Icon(imageVector = Icons.Default.Delete, contentDescription = "Decrease", tint = RoyalNavy)
                        }
                        Text(text = "$plateCount Guests", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                        IconButton(
                            onClick = { onPlateCountChange(plateCount + 50) },
                            modifier = Modifier.background(LightGrayBg, CircleShape)
                        ) {
                            Icon(imageVector = Icons.Default.Add, contentDescription = "Increase", tint = RoyalNavy)
                        }
                    }
                }
            }
        }

        // Add-ons list
        item {
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White)
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(text = "Popular Event Add-ons", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                    Spacer(modifier = Modifier.height(12.dp))

                    // DJ Setup
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onDjSetupCheckedChange(!isDjSetupChecked) }
                            .padding(vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = isDjSetupChecked, onCheckedChange = onDjSetupCheckedChange)
                            Spacer(modifier = Modifier.width(8.dp))
                            Column {
                                Text(text = "Signature Beats DJ Setup", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                Text(text = "Professional high-fidelity acoustics + lights", fontSize = 10.sp, color = Color.Gray)
                            }
                        }
                        Text(text = "+₹25,000", fontWeight = FontWeight.Black, fontSize = 12.sp, color = EmeraldGreen)
                    }

                    // Welcome Drinks
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onWelcomeDrinksCheckedChange(!isWelcomeDrinksChecked) }
                            .padding(vertical = 8.dp),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Checkbox(checked = isWelcomeDrinksChecked, onCheckedChange = onWelcomeDrinksCheckedChange)
                            Spacer(modifier = Modifier.width(8.dp))
                            Column {
                                Text(text = "Live Welcome Mocktail Bar", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                Text(text = "Imported syrups, live blending hosts", fontSize = 10.sp, color = Color.Gray)
                            }
                        }
                        Text(text = "+₹15,000", fontWeight = FontWeight.Black, fontSize = 12.sp, color = EmeraldGreen)
                    }
                }
            }
        }
    }
}

@Composable
fun EscrowVisualizer(totalAmount: Double) {
    val lockAmount = totalAmount * 0.2
    val holdAmount = totalAmount * 0.5
    val releaseAmount = totalAmount * 0.3

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(text = "Secure Escrow Payment Flow", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy)
                Spacer(modifier = Modifier.height(4.dp))
                Text(text = "Funds are locked in secure neutral escrow to guarantee booking setup and quality metrics.", fontSize = 12.sp, color = Color.Gray, lineHeight = 16.sp)
                Spacer(modifier = Modifier.height(20.dp))

                // Timeline visualization (3 rows)
                TimelineRow(nodeName = "1. Booking Lock Date", percentage = "20%", amount = lockAmount, detail = "Released immediately to vendor to confirm calendar slot.", nodeColor = EmeraldGreen)
                TimelineConnector()
                TimelineRow(nodeName = "2. Pre-Event Setup", percentage = "50%", amount = holdAmount, detail = "Held in neutral escrow. Transferred 24-48h before setup.", nodeColor = ChampagneGold)
                TimelineConnector()
                TimelineRow(nodeName = "3. Final Handover", percentage = "30%", amount = releaseAmount, detail = "Released post-event only after you approve completion.", nodeColor = Color.Red)
            }
        }
    }
}

@Composable
fun TimelineRow(nodeName: String, percentage: String, amount: Double, detail: String, nodeColor: Color) {
    Row(modifier = Modifier.fillMaxWidth()) {
        Box(
            modifier = Modifier
                .size(16.dp)
                .background(nodeColor, CircleShape)
                .border(2.dp, Color.White, CircleShape)
        )
        Spacer(modifier = Modifier.width(12.dp))
        Column(modifier = Modifier.weight(1f)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(text = nodeName, fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                Text(text = "₹$amount ($percentage)", fontWeight = FontWeight.Black, fontSize = 13.sp, color = RoyalNavy)
            }
            Text(text = detail, fontSize = 11.sp, color = Color.Gray, lineHeight = 14.sp)
        }
    }
}

@Composable
fun TimelineConnector() {
    Row(modifier = Modifier.padding(start = 7.dp)) {
        Box(
            modifier = Modifier
                .width(2.dp)
                .height(30.dp)
                .background(Color.LightGray)
        )
    }
}

@Composable
fun PaymentGatewaySelection(
    totalAmount: Double,
    onPayClick: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(text = "Select Payment Option", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy)
                Spacer(modifier = Modifier.height(16.dp))

                PaymentOptionItem(name = "Popular UPI (Google Pay, PhonePe)", logo = Icons.Default.ShoppingCart)
                Divider(color = Color.LightGray.copy(alpha = 0.4f))
                PaymentOptionItem(name = "Credit or Debit Card", logo = Icons.Default.Star)
                Divider(color = Color.LightGray.copy(alpha = 0.4f))
                PaymentOptionItem(name = "Netbanking / Online Transfers", logo = Icons.Default.Face)
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        Button(
            onClick = onPayClick,
            shape = RoundedCornerShape(8.dp),
            colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp)
        ) {
            Text(text = "Pay Securely ₹${totalAmount * 0.2} Advance", fontWeight = FontWeight.Bold, fontSize = 15.sp)
        }
    }
}

@Composable
fun PaymentOptionItem(name: String, logo: androidx.compose.ui.graphics.vector.ImageVector) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { /* Select */ }
            .padding(vertical = 12.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(imageVector = logo, contentDescription = name, tint = RoyalNavy, modifier = Modifier.size(20.dp))
            Spacer(modifier = Modifier.width(12.dp))
            Text(text = name, fontWeight = FontWeight.Medium, fontSize = 13.sp, color = RoyalNavy)
        }
        Icon(imageVector = Icons.Default.KeyboardArrowRight, contentDescription = "Select", tint = Color.Gray)
    }
}
