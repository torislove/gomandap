package com.gomandap.admin.presentation.vendors

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.ChampagneGold
import com.gomandap.app.presentation.theme.EmeraldGreen
import com.gomandap.app.presentation.theme.RoyalNavy
import com.gomandap.app.presentation.theme.SlateGray

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CommissionConfigScreen(onBackClick: () -> Unit) {
    var venueCommission by remember { mutableFloatStateOf(5f) }
    var photoCommission by remember { mutableFloatStateOf(10f) }
    var makeupCommission by remember { mutableFloatStateOf(12f) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Commission Tiers", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFFF8FAFC))
                .padding(padding)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                Text(
                    "Dynamic Commission Adjuster",
                    fontWeight = FontWeight.Black,
                    fontSize = 18.sp,
                    color = RoyalNavy
                )
                Text(
                    "Set percentage cuts taken from Escrow releases by category.",
                    fontSize = 12.sp,
                    color = SlateGray,
                    modifier = Modifier.padding(top = 4.dp, bottom = 12.dp)
                )
            }

            item { CommissionSlider("Venues & Mandaps", venueCommission) { venueCommission = it } }
            item { CommissionSlider("Photography", photoCommission) { photoCommission = it } }
            item { CommissionSlider("Makeup Artists", makeupCommission) { makeupCommission = it } }

            item {
                Spacer(Modifier.height(24.dp))
                Button(
                    onClick = { /* Save Settings */ },
                    colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                    modifier = Modifier.fillMaxWidth().height(48.dp),
                    shape = RoundedCornerShape(8.dp)
                ) {
                    Icon(Icons.Default.Save, contentDescription = null, tint = Color.White)
                    Spacer(Modifier.width(8.dp))
                    Text("Save Global Commission Rates", fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
    }
}

@Composable
fun CommissionSlider(category: String, value: Float, onValueChange: (Float) -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                Text(category, fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy)
                Text("${String.format("%.1f", value)}%", fontWeight = FontWeight.Black, fontSize = 15.sp, color = ChampagneGold)
            }
            Spacer(Modifier.height(12.dp))
            Slider(
                value = value,
                onValueChange = onValueChange,
                valueRange = 0f..30f,
                colors = SliderDefaults.colors(
                    thumbColor = RoyalNavy,
                    activeTrackColor = ChampagneGold,
                    inactiveTrackColor = Color(0xFFF1F5F9)
                )
            )
        }
    }
}
