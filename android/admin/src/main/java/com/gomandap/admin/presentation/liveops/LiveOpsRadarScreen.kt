package com.gomandap.admin.presentation.liveops

import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

// ─── Operational Tokens ──────────────────────────────────────────────────────
private val LuxuryNavyBg   = Color(0xFF070B19)
private val CardNavyBg     = Color(0xFF131C35)
private val BorderGold     = Color(0xFFDFBA73)
private val GlowGold       = Color(0xFFC59A48)
private val LightSlateText = Color(0xFF94A3B8)
private val EmeraldGreen   = Color(0xFF10B981)
private val RoseRed        = Color(0xFFEF4444)

data class GeofenceCheckIn(
    val vendorName: String,
    val service: String,
    val scheduledTime: String,
    val checkInStatus: String, // ARRIVED, DELAYED, NOT_ARRIVED
    val coords: String
)

data class StandbyCandidate(
    val name: String,
    val rating: Double,
    val distanceKm: Double,
    val geohash: String
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LiveOpsRadarScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    val haptic = LocalHapticFeedback.current
    val scope = rememberCoroutineScope()

    // Mock live geofence checks
    val activeCheckins = remember {
        mutableStateListOf(
            GeofenceCheckIn("The Grand Taj Palace", "Venue", "2:00 PM (Start)", "ARRIVED", "17.4126, 78.4320"),
            GeofenceCheckIn("Royal Decors & Florals", "Decorations", "1:00 PM (Start)", "DELAYED", "17.4201, 78.4410"),
            GeofenceCheckIn("Gourmet Flavors Catering", "Catering", "3:00 PM (Start)", "NOT_ARRIVED", "17.4082, 78.4190")
        )
    }

    // SOS standby dispatch states
    var isSosBroadcasting by remember { mutableStateOf(false) }
    var sosProgress by remember { mutableStateOf(0f) }
    var sosStatusLog by remember { mutableStateOf("") }
    var sosCompleted by remember { mutableStateOf(false) }

    // Standby Pool candidates
    val standbyPool = listOf(
        StandbyCandidate("Gala Imperial Mandapams", 4.9, 3.4, "tgfy2u"),
        StandbyCandidate("Elite Regency Hall", 4.7, 7.8, "tgfy2v"),
        StandbyCandidate("Nisarga Backdrop setups", 4.8, 12.1, "tgfy3d")
    )

    // Red Flashing SLA breach trigger
    val infiniteTransition = rememberInfiniteTransition()
    val alphaAnim by infiniteTransition.animateFloat(
        initialValue = 0.2f,
        targetValue = 0.8f,
        animationSpec = infiniteRepeatable(
            animation = androidx.compose.animation.core.tween(800, easing = androidx.compose.animation.core.EaseInOutCirc),
            repeatMode = androidx.compose.animation.core.RepeatMode.Reverse
        ),
        label = "redAlertFlash"
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text("Live Ops Radar ", fontWeight = FontWeight.Black, color = Color.White, fontSize = 18.sp)
                        Text("Center", fontWeight = FontWeight.Black, color = BorderGold, fontSize = 18.sp)
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
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ─── 1. Flashing SLA breach Alerts ───
            item {
                Surface(
                    color = RoseRed.copy(alpha = alphaAnim),
                    shape = RoundedCornerShape(12.dp),
                    border = BorderStroke(1.5.dp, RoseRed),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier.padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Icon(Icons.Default.Warning, null, tint = Color.White, modifier = Modifier.size(24.dp))
                        Column(modifier = Modifier.weight(1f)) {
                            Text("CRITICAL: Missed pre-arrival SLA geofence checks!", fontWeight = FontWeight.Black, color = Color.White, fontSize = 12.sp)
                            Text("'Royal Decors & Florals' missed 1:00 PM pre-arrival geofence trigger Banjara Hills (SLA delay logged).", color = Color.White.copy(alpha = 0.9f), fontSize = 10.sp)
                        }
                    }
                }
            }

            // ─── 2. Live geofence Check-in status logs ───
            item {
                Row(
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("📍 Live Partner Geofenced arrival list", fontWeight = FontWeight.Bold, color = Color.White, fontSize = 14.sp)
                    IconButton(onClick = {
                        Toast.makeText(context, "Scanning live coordinates...", Toast.LENGTH_SHORT).show()
                    }) {
                        Icon(Icons.Default.Refresh, "Refresh Logs", tint = BorderGold)
                    }
                }
                Spacer(Modifier.height(4.dp))

                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    activeCheckins.forEach { log ->
                        val checkInColor = when (log.checkInStatus) {
                            "ARRIVED" -> EmeraldGreen
                            "DELAYED" -> RoseRed
                            else -> BorderGold
                        }

                        Card(
                            shape = RoundedCornerShape(12.dp),
                            colors = CardDefaults.cardColors(containerColor = CardNavyBg),
                            modifier = Modifier
                                .fillMaxWidth()
                                .border(BorderStroke(1.dp, Color.White.copy(alpha = 0.1f)), RoundedCornerShape(12.dp))
                        ) {
                            Row(
                                modifier = Modifier.padding(14.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(2.dp)) {
                                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                                        Text(log.vendorName, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                        Box(
                                            modifier = Modifier
                                                .background(checkInColor.copy(alpha = 0.1f), RoundedCornerShape(4.dp))
                                                .padding(horizontal = 6.dp, vertical = 2.dp)
                                        ) {
                                            Text(log.checkInStatus, color = checkInColor, fontSize = 8.sp, fontWeight = FontWeight.Black)
                                        }
                                    }
                                    Text("Service: ${log.service} • Schedule: ${log.scheduledTime}", color = LightSlateText, fontSize = 10.sp)
                                    Text("Coordinates: ${log.coords}", color = checkInColor.copy(alpha = 0.7f), fontSize = 10.sp, fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace)
                                }
                            }
                        }
                    }
                }
            }

            // ─── 3. SOS Standby dispatcher geohash fallback ───
            item {
                Text("🛡️ Standby geohash dispatch backup Router (SOS)", fontWeight = FontWeight.Bold, color = Color.White, fontSize = 14.sp)
                Spacer(Modifier.height(6.dp))

                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = CardNavyBg),
                    modifier = Modifier
                        .fillMaxWidth()
                        .border(BorderStroke(1.2.dp, BorderGold.copy(alpha = 0.35f)), RoundedCornerShape(16.dp))
                ) {
                    Column(modifier = Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("Trigger SOS backup dispatcher to broadcast replacement opportunities to vetted geohash matches.", fontSize = 10.sp, color = LightSlateText)

                        Row(
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically,
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column {
                                Text("Emergency Dispatch: BK-1082", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                Text("Replace Decorator • Banjara Hills Geohash (tgfy)", color = LightSlateText, fontSize = 10.sp)
                            }

                            Button(
                                onClick = {
                                    if (isSosBroadcasting) return@Button
                                    isSosBroadcasting = true
                                    sosCompleted = false
                                    sosProgress = 0f
                                    sosStatusLog = "Receiving SOS request. Scanning coordinate geohashes..."
                                    
                                    scope.launch {
                                        delay(1500)
                                        sosProgress = 0.3f
                                        sosStatusLog = "Resolving vetted fallback profiles within 15km geohash bounds..."
                                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                        
                                        delay(2000)
                                        sosProgress = 0.7f
                                        sosStatusLog = "Broadcasting emergency bounty notifications (15% elevated payout ratio) to 3 matches..."
                                        
                                        delay(2200)
                                        sosProgress = 1.0f
                                        sosStatusLog = "SUCCESS: 'Gala Imperial Mandapams' accepted backup dispatch! Escrow advance auto-routed."
                                        sosCompleted = true
                                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                        isSosBroadcasting = false
                                        
                                        // Update status of Royal Decors
                                        val idx = activeCheckins.indexOfFirst { it.vendorName == "Royal Decors & Florals" }
                                        if (idx >= 0) {
                                            activeCheckins[idx] = activeCheckins[idx].copy(checkInStatus = "SOS_DISPATCHED")
                                        }
                                    }
                                },
                                colors = ButtonDefaults.buttonColors(containerColor = if (sosCompleted) EmeraldGreen else RoseRed),
                                shape = RoundedCornerShape(8.dp),
                                enabled = !isSosBroadcasting,
                                modifier = Modifier.height(36.dp)
                            ) {
                                if (isSosBroadcasting) {
                                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(14.dp))
                                } else {
                                    Text(if (sosCompleted) "DISPATCHED" else "SOS BROADCAST", fontSize = 11.sp, fontWeight = FontWeight.Black)
                                }
                            }
                        }

                        AnimatedVisibility(
                            visible = isSosBroadcasting || sosStatusLog.isNotEmpty(),
                            enter = fadeIn() + expandVertically(),
                            exit = fadeOut() + shrinkVertically()
                        ) {
                            Column(verticalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) {
                                if (isSosBroadcasting) {
                                    LinearProgressIndicator(
                                        progress = { sosProgress },
                                        modifier = Modifier.fillMaxWidth().height(4.dp),
                                        color = RoseRed,
                                        trackColor = RoseRed.copy(alpha = 0.1f)
                                    )
                                }
                                Text(
                                    text = sosStatusLog,
                                    color = if (sosCompleted) EmeraldGreen else Color.White,
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    lineHeight = 14.sp
                                )
                            }
                        }

                        Divider(color = Color.White.copy(alpha = 0.1f))
                        Text("Vetted Standby Candidates Nearby (15km radius)", fontWeight = FontWeight.Bold, color = Color.White, fontSize = 11.sp)
                        
                        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            standbyPool.forEach { candidate ->
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .background(Color.White.copy(alpha = 0.03f), RoundedCornerShape(8.dp))
                                        .padding(8.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Column {
                                        Text(candidate.name, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 11.sp)
                                        Text("Geohash: ${candidate.geohash} • Distance: ${candidate.distanceKm}km", color = LightSlateText, fontSize = 9.sp)
                                    }
                                    Box(
                                        modifier = Modifier
                                            .background(BorderGold.copy(alpha = 0.15f), RoundedCornerShape(4.dp))
                                            .padding(horizontal = 6.dp, vertical = 2.dp)
                                    ) {
                                        Text("${candidate.rating} ⭐", color = BorderGold, fontSize = 9.sp, fontWeight = FontWeight.Bold)
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
