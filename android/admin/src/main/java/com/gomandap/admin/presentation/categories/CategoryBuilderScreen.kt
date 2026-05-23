package com.gomandap.admin.presentation.categories

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Save
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
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
fun CategoryBuilderScreen(onBackClick: () -> Unit) {
    var categoryName by remember { mutableStateOf("") }
    val fields = remember { mutableStateListOf<DynamicFieldDef>() }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Schema Builder", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                actions = {
                    IconButton(onClick = { /* Save JSON Schema to Backend */ }) {
                        Icon(Icons.Default.Save, contentDescription = "Save Schema", tint = EmeraldGreen)
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
                Text("Define New Category", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                OutlinedTextField(
                    value = categoryName,
                    onValueChange = { categoryName = it },
                    label = { Text("Category Name (e.g. Vintage Cars)") },
                    modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                    colors = TextFieldDefaults.outlinedTextFieldColors(
                        containerColor = Color.White,
                        focusedBorderColor = EmeraldGreen
                    ),
                    shape = RoundedCornerShape(12.dp)
                )
            }

            item {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(top = 16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Dynamic Data Fields", fontWeight = FontWeight.Bold, fontSize = 16.sp, color = RoyalNavy)
                    Button(
                        onClick = { fields.add(DynamicFieldDef()) },
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                        contentPadding = PaddingValues(horizontal = 12.dp, vertical = 6.dp)
                    ) {
                        Icon(Icons.Default.Add, contentDescription = null, modifier = Modifier.size(16.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("Add Field", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }

            if (fields.isEmpty()) {
                item {
                    Box(modifier = Modifier.fillMaxWidth().padding(32.dp), contentAlignment = Alignment.Center) {
                        Text("No custom fields defined.", color = SlateGray)
                    }
                }
            }

            items(fields) { field ->
                FieldDefCard(
                    field = field,
                    onUpdateName = { field.name = it; fields[fields.indexOf(field)] = field.copy() },
                    onUpdateType = { field.type = it; fields[fields.indexOf(field)] = field.copy() },
                    onRemove = { fields.remove(field) }
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FieldDefCard(
    field: DynamicFieldDef,
    onUpdateName: (String) -> Unit,
    onUpdateType: (FieldType) -> Unit,
    onRemove: () -> Unit
) {
    var expanded by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
                OutlinedTextField(
                    value = field.name,
                    onValueChange = onUpdateName,
                    placeholder = { Text("Field Name (e.g. AC Available)") },
                    modifier = Modifier.weight(1f),
                    singleLine = true,
                    colors = TextFieldDefaults.outlinedTextFieldColors(
                        containerColor = Color(0xFFF1F5F9),
                        unfocusedBorderColor = Color.Transparent
                    )
                )
                Spacer(Modifier.width(8.dp))
                IconButton(onClick = onRemove) {
                    Icon(Icons.Default.Delete, contentDescription = "Remove", tint = Color.Red)
                }
            }
            Spacer(Modifier.height(12.dp))
            
            ExposedDropdownMenuBox(
                expanded = expanded,
                onExpandedChange = { expanded = !expanded }
            ) {
                OutlinedTextField(
                    value = field.type.displayName,
                    onValueChange = {},
                    readOnly = true,
                    modifier = Modifier.fillMaxWidth().menuAnchor(),
                    label = { Text("Data Type") },
                    trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
                    colors = ExposedDropdownMenuDefaults.outlinedTextFieldColors()
                )
                ExposedDropdownMenu(
                    expanded = expanded,
                    onDismissRequest = { expanded = false }
                ) {
                    FieldType.values().forEach { type ->
                        DropdownMenuItem(
                            text = { Text(type.displayName) },
                            onClick = {
                                onUpdateType(type)
                                expanded = false
                            }
                        )
                    }
                }
            }
        }
    }
}
