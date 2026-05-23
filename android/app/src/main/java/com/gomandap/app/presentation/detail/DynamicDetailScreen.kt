package com.gomandap.app.presentation.detail

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.BorderStroke
import com.gomandap.app.presentation.theme.ChampagneGold
import com.gomandap.app.presentation.theme.EmeraldGreen
import com.gomandap.app.presentation.theme.RoyalNavy
import com.gomandap.app.presentation.theme.SlateGray

data class DynamicFieldDef(
    val id: String = System.currentTimeMillis().toString(),
    var name: String = "",
    var type: FieldType = FieldType.TEXT
)

enum class FieldType(val displayName: String) {
    TEXT("Text Input"),
    NUMBER("Number / Price"),
    BOOLEAN("Yes / No (Toggle)"),
    LIST("List / Badges")
}


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DynamicDetailScreen(
    vendorName: String,
    schemaFields: List<DynamicFieldDef>,
    dynamicData: Map<String, String>,
    onBackClick: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(vendorName, fontWeight = FontWeight.Bold, color = RoyalNavy) },
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
                Text("Vendor Specifications", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                Spacer(Modifier.height(8.dp))
            }

            // Server Driven UI Rendering Logic
            val pairedFields = schemaFields.chunked(2)
            
            pairedFields.forEach { rowFields ->
                item {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        rowFields.forEach { field ->
                            Box(modifier = Modifier.weight(1f)) {
                                DynamicServerWidget(
                                    field = field,
                                    value = dynamicData[field.id] ?: ""
                                )
                            }
                        }
                        // If odd number of items, add an empty spacer for alignment
                        if (rowFields.size == 1) {
                            Spacer(Modifier.weight(1f))
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun DynamicServerWidget(field: DynamicFieldDef, value: String) {
    Surface(
        shape = RoundedCornerShape(12.dp),
        color = Color.White,
        border = BorderStroke(1.dp, SlateGray.copy(alpha = 0.1f)),
        shadowElevation = 2.dp
    ) {
        Column(
            modifier = Modifier.padding(12.dp).fillMaxWidth(),
            horizontalAlignment = Alignment.Start
        ) {
            Text(field.name, fontSize = 11.sp, color = SlateGray, fontWeight = FontWeight.Medium)
            Spacer(Modifier.height(6.dp))
            
            when (field.type) {
                FieldType.BOOLEAN -> {
                    val isTrue = value.equals("true", ignoreCase = true)
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(20.dp)
                                .background(if (isTrue) EmeraldGreen.copy(alpha = 0.2f) else Color.Red.copy(alpha = 0.1f), CircleShape)
                                .border(1.dp, if (isTrue) EmeraldGreen else Color.Red, CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(
                                imageVector = if (isTrue) Icons.Default.Check else Icons.Default.Close,
                                contentDescription = null,
                                tint = if (isTrue) EmeraldGreen else Color.Red,
                                modifier = Modifier.size(12.dp)
                            )
                        }
                        Spacer(Modifier.width(6.dp))
                        Text(if (isTrue) "Yes" else "No", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                    }
                }
                FieldType.NUMBER -> {
                    Text(value.ifEmpty { "0" }, fontWeight = FontWeight.Black, fontSize = 16.sp, color = ChampagneGold)
                }
                FieldType.TEXT, FieldType.LIST -> {
                    Text(value.ifEmpty { "N/A" }, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                }
            }
        }
    }
}
