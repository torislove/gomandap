package com.gomandap.admin.presentation.vendors

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.admin.presentation.categories.DynamicFieldDef
import com.gomandap.admin.presentation.categories.FieldType
import com.gomandap.app.presentation.theme.EmeraldGreen
import com.gomandap.app.presentation.theme.RoyalNavy
import com.gomandap.app.presentation.theme.SlateGray

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DynamicVendorEntryScreen(
    categoryName: String,
    schemaFields: List<DynamicFieldDef>,
    onBackClick: () -> Unit
) {
    // Map to hold dynamic data values (FieldId -> Value string)
    val dynamicData = remember { mutableStateMapOf<String, String>() }
    var vendorName by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Add $categoryName Vendor", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                actions = {
                    IconButton(onClick = { /* Compile dynamicData map and save */ }) {
                        Icon(Icons.Default.Save, contentDescription = "Save Vendor", tint = EmeraldGreen)
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
                Text("Basic Information", fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)
                OutlinedTextField(
                    value = vendorName,
                    onValueChange = { vendorName = it },
                    label = { Text("Vendor / Business Name") },
                    modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                    colors = TextFieldDefaults.outlinedTextFieldColors(
                        containerColor = Color.White,
                        focusedBorderColor = EmeraldGreen
                    ),
                    shape = RoundedCornerShape(12.dp)
                )
            }

            item {
                Spacer(Modifier.height(8.dp))
                Text("Dynamic Attributes", fontWeight = FontWeight.Black, fontSize = 16.sp, color = RoyalNavy)
                Text("These fields are generated automatically from the Category Schema.", fontSize = 11.sp, color = SlateGray)
                Spacer(Modifier.height(8.dp))
            }

            items(schemaFields) { field ->
                DynamicInputRow(
                    fieldDef = field,
                    currentValue = dynamicData[field.id] ?: "",
                    onValueChange = { newValue -> dynamicData[field.id] = newValue }
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DynamicInputRow(
    fieldDef: DynamicFieldDef,
    currentValue: String,
    onValueChange: (String) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(fieldDef.name, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
            Spacer(Modifier.height(8.dp))

            when (fieldDef.type) {
                FieldType.TEXT, FieldType.LIST -> {
                    OutlinedTextField(
                        value = currentValue,
                        onValueChange = onValueChange,
                        placeholder = { Text(if (fieldDef.type == FieldType.LIST) "Comma separated values" else "Enter text") },
                        modifier = Modifier.fillMaxWidth(),
                        colors = TextFieldDefaults.outlinedTextFieldColors(containerColor = Color(0xFFF1F5F9))
                    )
                }
                FieldType.NUMBER -> {
                    OutlinedTextField(
                        value = currentValue,
                        onValueChange = onValueChange,
                        placeholder = { Text("0") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.fillMaxWidth(),
                        colors = TextFieldDefaults.outlinedTextFieldColors(containerColor = Color(0xFFF1F5F9))
                    )
                }
                FieldType.BOOLEAN -> {
                    val isChecked = currentValue.toBoolean()
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(if (isChecked) "Yes" else "No", color = if (isChecked) EmeraldGreen else SlateGray, fontWeight = FontWeight.Bold)
                        Switch(
                            checked = isChecked,
                            onCheckedChange = { onValueChange(it.toString()) },
                            colors = SwitchDefaults.colors(checkedThumbColor = Color.White, checkedTrackColor = EmeraldGreen)
                        )
                    }
                }
            }
        }
    }
}
