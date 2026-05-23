package com.gomandap.app.presentation.escrow

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.domain.model.Milestone

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
                title = { Text("Milestone Escrow Tracker", fontWeight = FontWeight.Bold) },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
            )
        }
    ) { paddingValues ->
        if (state.isLoading) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = MaterialTheme.colorScheme.primary)
            }
        } else {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .padding(16.dp)
            ) {
                // Booking Overview Card
                Card(
                    modifier = Modifier.fillMaxWidth().padding(bottom = 20.dp),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(text = "Escrow Lock Total", fontSize = 12.sp, color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f))
                        Text(
                            text = "₹${state.totalAmount}",
                            fontSize = 28.sp,
                            fontWeight = FontWeight.Black,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(text = "Booking Reference: ${state.bookingId}", fontSize = 10.sp, color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.5f))
                    }
                }

                Text(
                    text = "Payment Release Milestones",
                    fontWeight = FontWeight.Bold,
                    fontSize = 16.sp,
                    modifier = Modifier.padding(bottom = 12.dp)
                )

                // List of milestones
                LazyColumn(verticalArrangement = Arrangement.spacedBy(12.dp)) {
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
}

@Composable
fun MilestoneCard(
    milestone: Milestone,
    onReleaseClick: () -> Unit
) {
    val statusColor = when (milestone.status) {
        "RELEASED" -> Color(0xFF27AE60) // Verified Green
        "HELD" -> Color(0xFFF39C12) // Amber
        else -> Color(0xFFE74C3C) // Red
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color.White, shape = RoundedCornerShape(12.dp))
            .border(1.dp, Color.LightGray.copy(alpha = 0.4f), shape = RoundedCornerShape(12.dp))
            .padding(16.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(text = milestone.label, fontWeight = FontWeight.Bold, fontSize = 14.sp)
            Text(text = "₹${milestone.amount}", fontSize = 13.sp, fontWeight = FontWeight.Medium, color = Color.Gray)
            
            // Badge Indicator
            Spacer(modifier = Modifier.height(6.dp))
            Box(
                modifier = Modifier
                    .background(statusColor.copy(alpha = 0.1f), shape = RoundedCornerShape(4.dp))
                    .padding(horizontal = 8.dp, vertical = 2.dp)
            ) {
                Text(text = milestone.status, color = statusColor, fontSize = 10.sp, fontWeight = FontWeight.Bold)
            }
        }

        if (milestone.status == "HELD") {
            Button(
                onClick = onReleaseClick,
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary)
            ) {
                Text("Release", fontSize = 12.sp, fontWeight = FontWeight.Bold)
            }
        } else if (milestone.status == "RELEASED") {
            IconButton(onClick = {}) {
                Icon(
                    imageVector = Icons.Default.CheckCircle,
                    contentDescription = "Success",
                    tint = Color(0xFF27AE60)
                )
            }
        }
    }
}
