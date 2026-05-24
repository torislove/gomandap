package com.gomandap.app.presentation.checkout

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

// ─── Luxury Design System Tokens ─────────────────────────────────────────────
private val RoyalNavy      = Color(0xFF0F172A)
private val DeepSlate      = Color(0xFF1E293B)
private val ChampagneGold  = Color(0xFFDFBA73)
private val DarkGold       = Color(0xFFC59A48)
private val EmeraldGreen   = Color(0xFF10B981)
private val SoftMist       = Color(0xFFF8FAFC)
private val SlateGray      = Color(0xFF64748B)
private val HotRose        = Color(0xFFF43F5E)

enum class CheckoutStage {
    AVAILABILITY_CALENDAR,
    PACKAGE_CUSTOMIZER,
    ESCROW_VISUALIZER,
    ONE_CLICK_PAYMENT
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EscrowCheckoutFlow(
    vendorName: String,
    basePricePerPlate: Double,
    onDismiss: () -> Unit,
    onPaymentComplete: () -> Unit
) {
    var currentStage by remember { mutableStateOf(CheckoutStage.AVAILABILITY_CALENDAR) }
    
    // Package parameters
    var selectedDate by remember { mutableStateOf("14 Nov 2026") }
    var vegPlateCount by remember { mutableStateOf(500) }
    var nonVegPlateCount by remember { mutableStateOf(150) }
    var extraChangingRoom by remember { mutableStateOf(false) }
    var premiumSoundSystem by remember { mutableStateOf(false) }

    // Financial math calculations
    val vegTotal = vegPlateCount * basePricePerPlate
    val nonVegTotal = nonVegPlateCount * (basePricePerPlate + 150) // Non-veg plate is premium
    val addOnCost = (if (extraChangingRoom) 5000.0 else 0.0) + (if (premiumSoundSystem) 15000.0 else 0.0)
    val baseCost = vegTotal + nonVegTotal + addOnCost
    val gst = baseCost * 0.18
    val grandTotal = baseCost + gst
    val depositDueNow = grandTotal * 0.20
    val escrowHeldAmount = grandTotal * 0.80

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = Color.White,
        shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 24.dp)
                .padding(bottom = 32.dp)
                .verticalScroll(rememberScrollState()),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Drag Handle helper
            Box(
                modifier = Modifier
                    .width(44.dp)
                    .height(4.dp)
                    .background(SlateGray.copy(alpha = 0.15f), RoundedCornerShape(2.dp))
                    .align(Alignment.CenterHorizontally)
            )

            // Header Section
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(vendorName, fontWeight = FontWeight.Black, fontSize = 20.sp, color = RoyalNavy)
                    Text("Instant Q-Commerce Escrow Checkout", fontSize = 11.sp, color = SlateGray)
                }
                
                Surface(
                    color = EmeraldGreen.copy(alpha = 0.08f),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.Security, null, tint = EmeraldGreen, modifier = Modifier.size(12.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("Vault Safe", color = EmeraldGreen, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }

            Divider(color = SlateGray.copy(alpha = 0.1f))

            // Step Progress Indicator Bar
            StepProgressBar(activeStage = currentStage)

            // Dynamic Content body using state transitions
            AnimatedContent(
                targetState = currentStage,
                transitionSpec = {
                    fadeIn(tween(300)) togetherWith fadeOut(tween(200))
                },
                label = "checkoutStageAnim"
            ) { stage ->
                when (stage) {
                    CheckoutStage.AVAILABILITY_CALENDAR -> {
                        AvailabilityCalendarStep(
                            selectedDate = selectedDate,
                            onDateSelect = { selectedDate = it },
                            onNext = { currentStage = CheckoutStage.PACKAGE_CUSTOMIZER }
                        )
                    }
                    CheckoutStage.PACKAGE_CUSTOMIZER -> {
                        PackageCustomizerStep(
                            vegPlateCount = vegPlateCount,
                            nonVegPlateCount = nonVegPlateCount,
                            extraChangingRoom = extraChangingRoom,
                            premiumSoundSystem = premiumSoundSystem,
                            basePricePerPlate = basePricePerPlate,
                            onVegChange = { vegPlateCount = it },
                            onNonVegChange = { nonVegPlateCount = it },
                            onRoomToggle = { extraChangingRoom = it },
                            onSoundToggle = { premiumSoundSystem = it },
                            baseCost = baseCost,
                            onNext = { currentStage = CheckoutStage.ESCROW_VISUALIZER }
                        )
                    }
                    CheckoutStage.ESCROW_VISUALIZER -> {
                        EscrowVisualizerStep(
                            grandTotal = grandTotal,
                            depositDueNow = depositDueNow,
                            escrowHeldAmount = escrowHeldAmount,
                            onNext = { currentStage = CheckoutStage.ONE_CLICK_PAYMENT }
                        )
                    }
                    CheckoutStage.ONE_CLICK_PAYMENT -> {
                        OneClickPaymentStep(
                            depositAmount = depositDueNow,
                            onPaymentComplete = onPaymentComplete
                        )
                    }
                }
            }
        }
    }
}

// ─── Step Progress Indicator ──────────────────────────────────────────────────
@Composable
fun StepProgressBar(activeStage: CheckoutStage) {
    val stages = CheckoutStage.values()
    val activeIndex = activeStage.ordinal

    Row(
        modifier = Modifier.fillMaxWidth().padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.spacedBy(4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        stages.forEachIndexed { index, stage ->
            val isCurrent = index == activeIndex
            val isPassed = index < activeIndex
            val color = if (isCurrent) RoyalNavy else if (isPassed) EmeraldGreen else SlateGray.copy(alpha = 0.2f)
            val weight = if (isCurrent) 1.8f else 1.0f

            Box(
                modifier = Modifier
                    .weight(weight)
                    .height(6.dp)
                    .clip(CircleShape)
                    .background(color)
            )
        }
    }
}

// ─── Step 1: Availability Calendar ────────────────────────────────────────────
@Composable
fun AvailabilityCalendarStep(
    selectedDate: String,
    onDateSelect: (String) -> Unit,
    onNext: () -> Unit
) {
    val haptic = LocalHapticFeedback.current
    val peakDates = setOf("14 Nov", "23 Nov", "28 Nov", "02 Dec")

    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("Select Event Date", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy)

        // Pulse Animation for high-demand banner
        val infiniteTransition = rememberInfiniteTransition()
        val pulseScale by infiniteTransition.animateFloat(
            initialValue = 0.98f,
            targetValue = 1.02f,
            animationSpec = infiniteRepeatable(
                animation = tween(1000, easing = EaseInOutCirc),
                repeatMode = RepeatMode.Reverse
            ),
            label = "fillingFastPulse"
        )

        Surface(
            modifier = Modifier.fillMaxWidth().scale(pulseScale),
            color = Color(0xFFFEF3C7),
            shape = RoundedCornerShape(12.dp),
            border = BorderStroke(1.dp, ChampagneGold.copy(alpha = 0.6f))
        ) {
            Row(
                modifier = Modifier.padding(12.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Text("🔥", fontSize = 16.sp)
                Text(
                    text = "High-demand auspicious dates are filling fast. Book instantly to secure your slot in the escrow registry.",
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color(0xFF92400E)
                )
            }
        }

        // Mock Auspicious Grid Calendar (November 2026)
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(SoftMist, RoundedCornerShape(16.dp))
                .border(1.dp, SlateGray.copy(alpha = 0.1f), RoundedCornerShape(16.dp))
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text("November 2026", fontWeight = FontWeight.Black, fontSize = 13.sp, color = RoyalNavy, modifier = Modifier.fillMaxWidth(), textAlign = TextAlign.Center)

            // Calendar days
            val days = (1..30).toList()
            val chunkedDays = days.chunked(7)

            chunkedDays.forEach { week ->
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    week.forEach { day ->
                        val dateString = "$day Nov"
                        val isPeak = peakDates.contains(dateString)
                        val isSelected = selectedDate.startsWith(dateString)
                        
                        Box(
                            modifier = Modifier
                                .size(36.dp)
                                .clip(CircleShape)
                                .background(
                                    if (isSelected) RoyalNavy
                                    else if (isPeak) Color(0xFFFEF3C7)
                                    else Color.Transparent
                                )
                                .clickable {
                                    onDateSelect("$dateString 2026")
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                },
                            contentAlignment = Alignment.Center
                        ) {
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text(
                                    text = day.toString(),
                                    fontWeight = FontWeight.Bold,
                                    fontSize = 12.sp,
                                    color = if (isSelected) Color.White else if (isPeak) Color(0xFFB45309) else RoyalNavy
                                )
                                if (isPeak && !isSelected) {
                                    Box(modifier = Modifier.size(4.dp).clip(CircleShape).background(Color(0xFFB45309)))
                                }
                            }
                        }
                    }
                }
            }
        }

        Button(
            onClick = onNext,
            modifier = Modifier.fillMaxWidth().height(52.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy)
        ) {
            Text("Confirm Date & Configure Package", fontWeight = FontWeight.Bold)
        }
    }
}

// ─── Step 2: Package Customizer ───────────────────────────────────────────────
@Composable
fun PackageCustomizerStep(
    vegPlateCount: Int,
    nonVegPlateCount: Int,
    extraChangingRoom: Boolean,
    premiumSoundSystem: Boolean,
    basePricePerPlate: Double,
    onVegChange: (Int) -> Unit,
    onNonVegChange: (Int) -> Unit,
    onRoomToggle: (Boolean) -> Unit,
    onSoundToggle: (Boolean) -> Unit,
    baseCost: Double,
    onNext: () -> Unit
) {
    val haptic = LocalHapticFeedback.current

    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("Customize Event Plan", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy)

        // Plate Steppers
        PlateStepperCard(
            title = "Vegetarian Plates",
            subtitle = "Fixed base veg plate rate: ₹${basePricePerPlate.toInt()}/plate",
            count = vegPlateCount,
            onCountChange = {
                onVegChange(it)
                haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
            }
        )

        PlateStepperCard(
            title = "Non-Vegetarian Plates",
            subtitle = "Fixed premium non-veg plate rate: ₹${(basePricePerPlate + 150).toInt()}/plate",
            count = nonVegPlateCount,
            onCountChange = {
                onNonVegChange(it)
                haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
            }
        )

        // Addon choices
        Text("Select Elite Add-ons", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
        
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(SoftMist, RoundedCornerShape(12.dp))
                .clickable { onRoomToggle(!extraChangingRoom) }
                .padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text("Double VIP green room accommodation", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = RoyalNavy)
                Text("+₹5,000 flat cost", fontSize = 11.sp, color = ChampagneGold, fontWeight = FontWeight.Bold)
            }
            Checkbox(checked = extraChangingRoom, onCheckedChange = { onRoomToggle(it) })
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .background(SoftMist, RoundedCornerShape(12.dp))
                .clickable { onSoundToggle(!premiumSoundSystem) }
                .padding(12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text("Premium JBL 5kW line-array DJ Audio system", fontWeight = FontWeight.Bold, fontSize = 12.sp, color = RoyalNavy)
                Text("+₹15,000 flat cost", fontSize = 11.sp, color = ChampagneGold, fontWeight = FontWeight.Bold)
            }
            Checkbox(checked = premiumSoundSystem, onCheckedChange = { onSoundToggle(it) })
        }

        Divider(color = SlateGray.copy(alpha = 0.1f))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text("Est. Base Cost", fontWeight = FontWeight.SemiBold, fontSize = 13.sp, color = SlateGray)
            Text("₹${"%,.0f".format(baseCost)}", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
        }

        Button(
            onClick = onNext,
            modifier = Modifier.fillMaxWidth().height(52.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy)
        ) {
            Text("Review Payout Milestones", fontWeight = FontWeight.Bold)
        }
    }
}

@Composable
fun PlateStepperCard(
    title: String,
    subtitle: String,
    count: Int,
    onCountChange: (Int) -> Unit
) {
    Card(
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = SoftMist),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(16.dp).fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(title, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                Text(subtitle, fontSize = 10.sp, color = SlateGray)
            }
            
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                IconButton(
                    onClick = { if (count > 50) onCountChange(count - 50) },
                    modifier = Modifier.size(32.dp).background(Color.White, CircleShape)
                ) {
                    Text("-", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = RoyalNavy)
                }
                
                Text(
                    text = count.toString(),
                    fontWeight = FontWeight.Black,
                    fontSize = 15.sp,
                    color = RoyalNavy,
                    modifier = Modifier.widthIn(min = 36.dp),
                    textAlign = TextAlign.Center
                )
                
                IconButton(
                    onClick = { onCountChange(count + 50) },
                    modifier = Modifier.size(32.dp).background(Color.White, CircleShape)
                ) {
                    Text("+", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = RoyalNavy)
                }
            }
        }
    }
}

// ─── Step 3: Escrow Visualizer ────────────────────────────────────────────────
@Composable
fun EscrowVisualizerStep(
    grandTotal: Double,
    depositDueNow: Double,
    escrowHeldAmount: Double,
    onNext: () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
        Text("GM Escrow Visualizer", fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy)

        // Visual Timeline Node Chain
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .background(RoyalNavy, RoundedCornerShape(18.dp))
                .border(1.dp, ChampagneGold.copy(alpha = 0.3f), RoundedCornerShape(18.dp))
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("Vault Payout Milestone Splits", color = ChampagneGold, fontWeight = FontWeight.Black, fontSize = 13.sp)

            EscrowNode(
                dotColor = EmeraldGreen,
                title = "20% Deposit (Locks Wedding Date)",
                description = "Released instantly to secure venue slot calendar allocation",
                amount = depositDueNow
            )
            
            EscrowNode(
                dotColor = ChampagneGold,
                title = "50% Setup Lock (Held in Custody)",
                description = "Held securely. Released automatically on setup check-in day",
                amount = grandTotal * 0.50
            )

            EscrowNode(
                dotColor = HotRose,
                title = "30% Post-Event Approval (You Hold Key)",
                description = "Released only post-wedding after your validation click",
                amount = grandTotal * 0.30
            )
        }

        Divider(color = SlateGray.copy(alpha = 0.1f))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column {
                Text("Total Escrow Protected Cost", fontSize = 11.sp, color = SlateGray)
                Text("Includes GST (18%)", fontSize = 9.sp, color = SlateGray)
            }
            Text("₹${"%,.0f".format(grandTotal)}", fontWeight = FontWeight.Black, fontSize = 20.sp, color = RoyalNavy)
        }

        Button(
            onClick = onNext,
            modifier = Modifier.fillMaxWidth().height(52.dp),
            shape = RoundedCornerShape(14.dp),
            colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen)
        ) {
            Text("Proceed to One-Click Deposit Payment", fontWeight = FontWeight.Bold, color = Color.White)
        }
    }
}

@Composable
fun EscrowNode(
    dotColor: Color,
    title: String,
    description: String,
    amount: Double
) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(dotColor))
            Box(modifier = Modifier.width(1.5.dp).height(44.dp).background(Color.White.copy(alpha = 0.15f)))
        }
        
        Column(modifier = Modifier.weight(1f)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(title, fontWeight = FontWeight.Bold, fontSize = 12.sp, color = Color.White, modifier = Modifier.weight(1f))
                Text("₹${"%,.0f".format(amount)}", fontWeight = FontWeight.Black, fontSize = 12.sp, color = ChampagneGold)
            }
            Text(description, fontSize = 10.sp, color = Color.White.copy(alpha = 0.65f), lineHeight = 14.sp)
        }
    }
}

// ─── Step 4: One-Click Payment Sheet ──────────────────────────────────────────
@Composable
fun OneClickPaymentStep(
    depositAmount: Double,
    onPaymentComplete: () -> Unit
) {
    val scope = rememberCoroutineScope()
    var isProcessing by remember { mutableStateOf(false) }

    Column(
        verticalArrangement = Arrangement.spacedBy(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "One-Click Instant UPI Checkout",
            fontWeight = FontWeight.Bold,
            fontSize = 15.sp,
            color = RoyalNavy,
            modifier = Modifier.fillMaxWidth(),
            textAlign = TextAlign.Start
        )

        Surface(
            color = SoftMist,
            shape = RoundedCornerShape(14.dp),
            modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                Text("SECURE LOCK DEPOSIT AMOUNT", fontSize = 10.sp, color = SlateGray, fontWeight = FontWeight.Black)
                Text("₹${"%,.0f".format(depositAmount)}", fontSize = 26.sp, fontWeight = FontWeight.Black, color = RoyalNavy)
                Text("Authorized under standard escrow protocol", fontSize = 10.sp, color = EmeraldGreen, fontWeight = FontWeight.Bold)
            }
        }

        if (isProcessing) {
            Column(
                modifier = Modifier.fillMaxWidth().padding(vertical = 20.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                CircularProgressIndicator(color = EmeraldGreen)
                Spacer(Modifier.height(12.dp))
                Text("Contacting safe gateway vault...", fontSize = 12.sp, color = SlateGray, fontWeight = FontWeight.Bold)
            }
        } else {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Quick UPI Option: PhonePe
                UPIPaymentButton(
                    logoEmoji = "🟣",
                    providerName = "PhonePe",
                    onClick = {
                        isProcessing = true
                        scope.launch {
                            delay(1800)
                            isProcessing = false
                            onPaymentComplete()
                        }
                    }
                )

                // Quick UPI Option: GPay
                UPIPaymentButton(
                    logoEmoji = "🔵",
                    providerName = "Google Pay",
                    onClick = {
                        isProcessing = true
                        scope.launch {
                            delay(1800)
                            isProcessing = false
                            onPaymentComplete()
                        }
                    }
                )

                // Quick UPI Option: Paytm
                UPIPaymentButton(
                    logoEmoji = "🔷",
                    providerName = "Paytm",
                    onClick = {
                        isProcessing = true
                        scope.launch {
                            delay(1800)
                            isProcessing = false
                            onPaymentComplete()
                        }
                    }
                )
            }
        }

        Spacer(Modifier.height(12.dp))
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.Center,
            modifier = Modifier.fillMaxWidth()
        ) {
            Icon(Icons.Default.Lock, null, tint = SlateGray, modifier = Modifier.size(12.dp))
            Spacer(Modifier.width(4.dp))
            Text("Payments fully PCI-DSS compliant & escrow guarded", fontSize = 10.sp, color = SlateGray)
        }
    }
}

@Composable
fun UPIPaymentButton(
    logoEmoji: String,
    providerName: String,
    onClick: () -> Unit
) {
    Surface(
        onClick = onClick,
        color = Color.White,
        shape = RoundedCornerShape(12.dp),
        border = BorderStroke(1.dp, SlateGray.copy(alpha = 0.2f)),
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(logoEmoji, fontSize = 20.sp)
            Text(providerName, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy, modifier = Modifier.weight(1f))
            Text("Pay Now", color = EmeraldGreen, fontWeight = FontWeight.Black, fontSize = 12.sp)
            Icon(Icons.Default.KeyboardArrowRight, null, tint = EmeraldGreen)
        }
    }
}
