package com.gomandap.admin.presentation.categories

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
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CategoryScreen(onBack: () -> Unit) {
    var expandedCategoryIndex by remember { mutableStateOf<Int?>(null) }

    val categories = listOf(
        CategorySettingItem("🏛 Kalyana Mandapams", "Venues", true, 150000, 250),
        CategorySettingItem("🏢 Banquet Halls", "Venues", true, 80000, 150),
        CategorySettingItem("🌿 Open Lawns", "Venues", true, 100000, 500),
        CategorySettingItem("📸 Photography", "Services", true, 45000, 1),
        CategorySettingItem("🍽 Catering", "Services", true, 800, 100),
        CategorySettingItem("🌸 Decorators", "Services", true, 50000, 1),
        CategorySettingItem("💄 Makeup Art", "Services", true, 15000, 1)
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Configure Event Categories", fontWeight = FontWeight.Bold, color = RoyalNavy) },
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
            verticalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            Text(
                text = "Dynamic Category Configuration",
                fontWeight = FontWeight.Black,
                fontSize = 17.sp,
                color = RoyalNavy
            )
            Text(
                text = "Enable categories on the platform and set default booking, pricing, and questionnaire configurations.",
                fontSize = 12.sp,
                color = Color.Gray,
                lineHeight = 16.sp
            )

            Spacer(modifier = Modifier.height(4.dp))

            categories.forEachIndexed { index, item ->
                var isEnabled by remember { mutableStateOf(item.isEnabled) }
                var basePrice by remember { mutableStateOf(item.basePrice.toString()) }
                val isExpanded = expandedCategoryIndex == index

                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .border(
                            width = 1.dp,
                            color = if (isExpanded) ChampagneGold.copy(alpha = 0.5f) else Color.Transparent,
                            shape = RoundedCornerShape(16.dp)
                        ),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White)
                ) {
                    Column(
                        modifier = Modifier
                            .clickable { expandedCategoryIndex = if (isExpanded) null else index }
                            .padding(16.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Column {
                                Text(text = item.name, fontWeight = FontWeight.Bold, fontSize = 15.sp, color = RoyalNavy)
                                Text(text = "Module Type: ${item.type}", fontSize = 10.sp, color = Color.Gray)
                            }

                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Switch(
                                    checked = isEnabled,
                                    onCheckedChange = { isEnabled = it },
                                    modifier = Modifier.scale(0.8f),
                                    colors = SwitchDefaults.colors(
                                        checkedThumbColor = EmeraldGreen,
                                        checkedTrackColor = EmeraldGreen.copy(alpha = 0.3f)
                                    )
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                                Icon(
                                    imageVector = Icons.Default.Settings,
                                    contentDescription = "Expand Settings",
                                    tint = if (isExpanded) ChampagneGold else Color.LightGray,
                                    modifier = Modifier.size(20.dp)
                                )
                            }
                        }

                        if (isExpanded) {
                            Spacer(modifier = Modifier.height(16.dp))
                            Divider(color = Color.LightGray.copy(alpha = 0.3f))
                            Spacer(modifier = Modifier.height(16.dp))

                            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                                OutlinedTextField(
                                    value = basePrice,
                                    onValueChange = { basePrice = it },
                                    label = { Text("Base System Pricing (₹)") },
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = OutlinedTextFieldDefaults.colors(
                                        focusedBorderColor = ChampagneGold,
                                        focusedLabelColor = DarkGold
                                    )
                                )

                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    OutlinedTextField(
                                        value = item.minLimit.toString(),
                                        onValueChange = {},
                                        label = { Text("Min Booking Constraint") },
                                        modifier = Modifier.weight(1f),
                                        readOnly = true
                                    )
                                    OutlinedTextField(
                                        value = "Active questions (5)",
                                        onValueChange = {},
                                        label = { Text("Onboarding Rules") },
                                        modifier = Modifier.weight(1f),
                                        readOnly = true
                                    )
                                }

                                Button(
                                    onClick = { expandedCategoryIndex = null },
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(38.dp),
                                    colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                                    shape = RoundedCornerShape(8.dp)
                                ) {
                                    Text("Apply Settings", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// Helpers
private data class CategorySettingItem(
    val name: String,
    val type: String,
    val isEnabled: Boolean,
    val basePrice: Int,
    val minLimit: Int
)
