package com.gomandap.app.presentation.escrow

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Security
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.domain.model.Milestone
import com.gomandap.app.presentation.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EscrowTrackerScreen(
    bookingId: String,
    viewModel: EscrowViewModel
) {
    val state by viewModel.uiState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Milestone Escrow Tracker", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 18.sp)
                        Text("Secure real-time transaction vault", fontSize = 11.sp, color = SlateGray)
                    }
                },
                navigationIcon = {
                    Icon(
                        imageVector = Icons.Default.Security,
                        contentDescription = "Security Status",
                        tint = EmeraldGreen,
                        modifier = Modifier.padding(start = 16.dp, end = 8.dp).size(22.dp)
                    )
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White),
                modifier = Modifier.shadow(2.dp)
            )
        },
        containerColor = SoftMist
    ) { paddingValues ->
        if (state.isLoading) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = RoyalNavy)
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Booking Overview Card
                item {
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
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.SpaceBetween,
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Text(
                                    text = "ESCROW LOCK TOTAL",
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Black,
                                    color = ChampagneGold,
                                    letterSpacing = 1.sp
                                )
                                Surface(
                                    color = Color.White.copy(alpha = 0.12f),
                                    shape = RoundedCornerShape(6.dp)
                                ) {
                                    Row(
                                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Icon(Icons.Default.Lock, null, tint = ChampagneGold, modifier = Modifier.size(10.dp))
                                        Spacer(Modifier.width(4.dp))
                                        Text("100% Protected", color = Color.White, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                                    }
                                }
                            }
                            
                            Spacer(Modifier.height(8.dp))
                            
                            Text(
                                text = "₹${"%,.0f".format(state.totalAmount)}",
                                fontSize = 32.sp,
                                fontWeight = FontWeight.Black,
                                color = Color.White
                            )
                            
                            Spacer(Modifier.height(10.dp))
                            Divider(color = Color.White.copy(alpha = 0.12f))
                            Spacer(Modifier.height(10.dp))
                            
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Column {
                                    Text("Booking Reference", fontSize = 9.sp, color = Color.White.copy(alpha = 0.5f))
                                    Text(state.bookingId, fontSize = 12.sp, fontWeight = FontWeight.Bold, color = Color.White)
                                }
                                Column(horizontalAlignment = Alignment.End) {
                                    Text("Release Model", fontSize = 9.sp, color = Color.White.copy(alpha = 0.5f))
                                    Text("Milestone Split", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = ChampagneGold)
                                }
                            }
                        }
                    }
                }

                // Section Title
                item {
                    Spacer(Modifier.height(4.dp))
                    Text(
                        text = "Payment Release Milestones",
                        fontWeight = FontWeight.Black,
                        fontSize = 15.sp,
                        color = RoyalNavy,
                        modifier = Modifier.padding(horizontal = 4.dp)
                    )
                }

                // List of milestones
                items(state.milestones) { milestone ->
                    MilestoneCard(
                        milestone = milestone,
                        onReleaseClick = { viewModel.releaseMilestoneFunds(milestone.id) }
                    )
                }
            }
        }
    }
}

@Composable
fun MilestoneCard(
    milestone: Milestone,
    onReleaseClick: () -> Unit
) {
    val statusColor = when (milestone.status) {
        "RELEASED" -> EmeraldGreen
        "HELD" -> ChampagneGold
        else -> RoseRed
    }
    
    val statusLabel = when (milestone.status) {
        "RELEASED" -> "RELEASED TO PARTNER"
        "HELD" -> "LOCKED IN ESCROW"
        else -> milestone.status
    }

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .neumorphicShadow(borderRadius = 16.dp, shadowRadius = 8.dp)
            .background(Color.White, shape = RoundedCornerShape(16.dp))
            .border(1.dp, ChampagneGold.copy(alpha = 0.15f), shape = RoundedCornerShape(16.dp))
            .padding(16.dp)
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = milestone.label,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp,
                    color = RoyalNavy
                )
                Spacer(Modifier.height(2.dp))
                Text(
                    text = "Amount: ₹${"%,.0f".format(milestone.amount)}",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = SlateGray
                )
                
                Spacer(Modifier.height(8.dp))
                
                Surface(
                    color = statusColor.copy(alpha = 0.08f),
                    shape = RoundedCornerShape(4.dp),
                    border = borderStrokeOrNull(milestone.status, statusColor)
                ) {
                    Text(
                        text = statusLabel,
                        color = statusColor,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Black,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
            }

            Spacer(Modifier.width(12.dp))

            if (milestone.status == "HELD") {
                Button(
                    onClick = onReleaseClick,
                    shape = RoundedCornerShape(10.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                    modifier = Modifier
                        .height(38.dp)
                        .antigravityShadow(color = EmeraldGreen, alpha = 0.15f, borderRadius = 10.dp)
                ) {
                    Text("Release", fontSize = 11.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            } else if (milestone.status == "RELEASED") {
                Box(
                    modifier = Modifier
                        .size(34.dp)
                        .clip(CircleShape)
                        .background(EmeraldGreen.copy(alpha = 0.12f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.CheckCircle,
                        contentDescription = "Success",
                        tint = EmeraldGreen,
                        modifier = Modifier.size(20.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun borderStrokeOrNull(status: String, color: Color): androidx.compose.foundation.BorderStroke? {
    return if (status == "HELD") {
        androidx.compose.foundation.BorderStroke(1.dp, color.copy(alpha = 0.4f))
    } else null
}
