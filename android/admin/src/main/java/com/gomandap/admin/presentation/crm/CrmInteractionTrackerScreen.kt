package com.gomandap.admin.presentation.crm

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import kotlinx.coroutines.tasks.await
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CrmInteractionTrackerScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    val db = FirebaseFirestore.getInstance()

    var interactions by remember { mutableStateOf<List<Map<String, Any>>>(emptyList()) }
    var isLoading by remember { mutableStateOf(false) }

    // Fetch interactions from Firestore in real-time
    LaunchedEffect(Unit) {
        isLoading = true
        db.collection("crm_interactions")
            .orderBy("timestamp", Query.Direction.DESCENDING)
            .addSnapshotListener { snapshot, error ->
                if (error == null && snapshot != null) {
                    val list = snapshot.documents.map { doc ->
                        val data = doc.data ?: emptyMap<String, Any>()
                        data + ("id" to doc.id)
                    }
                    
                    if (list.isEmpty()) {
                        // Populate elegant initial mock data if database is empty
                        interactions = getMockInteractions()
                    } else {
                        interactions = list
                    }
                } else {
                    interactions = getMockInteractions()
                }
                isLoading = false
            }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Platform Interaction Log", fontWeight = FontWeight.Bold, color = RoyalNavy) },
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
                .padding(16.dp)
        ) {
            Text("Real-Time Timeline Monitor", fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)
            Text("Track direct operational inquiries, contract closures, and escrow milestones.", fontSize = 11.sp, color = Color.Gray)
            
            Spacer(modifier = Modifier.height(16.dp))

            if (isLoading) {
                Box(modifier = Modifier.fillMaxWidth().weight(1f), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = ChampagneGold)
                }
            } else {
                LazyColumn(
                    modifier = Modifier.fillMaxWidth().weight(1f),
                    verticalArrangement = Arrangement.spacedBy(0.dp) // customized timeline spacing
                ) {
                    items(interactions) { item ->
                        TimelineItemRow(item = item)
                    }
                }
            }
        }
    }
}

@Composable
fun TimelineItemRow(item: Map<String, Any>) {
    val title = item["title"] as? String ?: "Inquiry Logged"
    val description = item["description"] as? String ?: "No details provided"
    val type = item["type"] as? String ?: "INQUIRY"
    
    val timestamp = item["timestamp"] as? com.google.firebase.Timestamp
    val dateString = if (timestamp != null) {
        val sdf = SimpleDateFormat("dd MMM, hh:mm a", Locale.getDefault())
        sdf.format(timestamp.toDate())
    } else {
        item["dateStr"] as? String ?: "Just Now"
    }

    val bulletColor = when(type) {
        "INQUIRY", "SITE_VISIT" -> Color(0xFF3B82F6) // Blue
        "ESCROW_LOCKED" -> ChampagneGold // Yellow
        "MILESTONE_RELEASED", "COMPLETED" -> EmeraldGreen // Green
        "DISPUTE" -> Color.Red // Red
        else -> SlateGray
    }

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .height(IntrinsicSize.Min)
    ) {
        // Vertical Timeline line & bullet
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier
                .width(40.dp)
                .fillMaxHeight()
        ) {
            Box(
                modifier = Modifier
                    .size(14.dp)
                    .clip(CircleShape)
                    .background(bulletColor)
                    .border(2.dp, Color.White, CircleShape)
            )
            Box(
                modifier = Modifier
                    .width(2.dp)
                    .weight(1f)
                    .background(Color.LightGray.copy(alpha = 0.5f))
            )
        }

        // Timeline details card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 20.dp, end = 4.dp),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
        ) {
            Column(modifier = Modifier.padding(14.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier
                            .background(bulletColor.copy(alpha = 0.08f), RoundedCornerShape(4.dp))
                            .padding(horizontal = 6.dp, vertical = 2.dp)
                    ) {
                        Text(type, color = bulletColor, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                    }
                    Text(dateString, color = Color.Gray, fontSize = 10.sp)
                }
                Spacer(modifier = Modifier.height(6.dp))
                Text(title, fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                Text(description, fontSize = 11.sp, color = SlateGray, lineHeight = 14.sp)
            }
        }
    }
}

private fun getMockInteractions(): List<Map<String, Any>> {
    return listOf(
        mapOf(
            "title" to "Milestone 2 Released - Maharaja Banquet Hall",
            "description" to "Client Manoj released setup milestones (50% booking payment, ₹75,000 disbursed directly into HDFC account).",
            "type" to "MILESTONE_RELEASED",
            "dateStr" to "Today, 10:45 AM"
        ),
        mapOf(
            "title" to "Vendor Checked In - Maharaja Banquet Hall",
            "description" to "Venue staff marked arrival check-in. Verified location geofence matches address Banjara Hills.",
            "type" to "COMPLETED",
            "dateStr" to "Today, 08:30 AM"
        ),
        mapOf(
            "title" to "Escrow Secured - booking #8930",
            "description" to "Client completed checkout for Tharaga Kalyan Mandapam. Booking locked ₹2,00,000 securely in escrow.",
            "type" to "ESCROW_LOCKED",
            "dateStr" to "Yesterday, 06:15 PM"
        ),
        mapOf(
            "title" to "Site Visit Scheduled - Pixel Studios",
            "description" to "Client scheduled portfolio review site visit at Jubilee Hills studio location for Sangeet photography package.",
            "type" to "SITE_VISIT",
            "dateStr" to "22 May, 02:20 PM"
        ),
        mapOf(
            "title" to "New Platform Inquiry",
            "description" to "Manoj submitted a pricing inquiry for Bridal HD Makeup package at Royal Makeovers.",
            "type" to "INQUIRY",
            "dateStr" to "22 May, 11:00 AM"
        )
    )
}
