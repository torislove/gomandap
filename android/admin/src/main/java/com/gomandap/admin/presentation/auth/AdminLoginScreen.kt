package com.gomandap.admin.presentation.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.EmeraldGreen
import com.gomandap.app.presentation.theme.RoyalNavy
import com.gomandap.app.presentation.theme.SlateGray

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AdminLoginScreen(onLoginSuccess: () -> Unit) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var expanded by remember { mutableStateOf(false) }
    var selectedRole by remember { mutableStateOf("Super Admin") }
    val roles = listOf("Super Admin", "Vendor Manager", "Dispute Resolution")

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.verticalGradient(
                    colors = listOf(RoyalNavy, Color(0xFF1E293B))
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.9f)
                .padding(16.dp),
            shape = RoundedCornerShape(24.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 12.dp)
        ) {
            Column(
                modifier = Modifier.padding(32.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Logo placeholder
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .background(EmeraldGreen.copy(alpha = 0.1f), RoundedCornerShape(20.dp)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Default.Person, contentDescription = "Admin", tint = EmeraldGreen, modifier = Modifier.size(40.dp))
                }
                
                Spacer(modifier = Modifier.height(24.dp))
                Text("GmAdmin Portal", fontSize = 24.sp, fontWeight = FontWeight.Black, color = RoyalNavy)
                Text("Secure access for authorized personnel only.", fontSize = 12.sp, color = SlateGray, textAlign = TextAlign.Center)
                Spacer(modifier = Modifier.height(32.dp))

                ExposedDropdownMenuBox(
                    expanded = expanded,
                    onExpandedChange = { expanded = !expanded }
                ) {
                    OutlinedTextField(
                        value = selectedRole,
                        onValueChange = {},
                        readOnly = true,
                        modifier = Modifier.fillMaxWidth().menuAnchor(),
                        label = { Text("Select Role") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded) },
                        colors = ExposedDropdownMenuDefaults.outlinedTextFieldColors(
                            focusedBorderColor = EmeraldGreen,
                            unfocusedBorderColor = SlateGray.copy(alpha = 0.3f)
                        )
                    )
                    ExposedDropdownMenu(
                        expanded = expanded,
                        onDismissRequest = { expanded = false }
                    ) {
                        roles.forEach { role ->
                            DropdownMenuItem(
                                text = { Text(role) },
                                onClick = {
                                    selectedRole = role
                                    expanded = false
                                }
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                OutlinedTextField(
                    value = email,
                    onValueChange = { email = it },
                    label = { Text("Email Address") },
                    leadingIcon = { Icon(Icons.Default.Email, contentDescription = "Email", tint = SlateGray) },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    colors = TextFieldDefaults.outlinedTextFieldColors(
                        focusedBorderColor = EmeraldGreen,
                        unfocusedBorderColor = SlateGray.copy(alpha = 0.3f)
                    ),
                    shape = RoundedCornerShape(12.dp)
                )

                Spacer(modifier = Modifier.height(16.dp))

                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Password") },
                    leadingIcon = { Icon(Icons.Default.Lock, contentDescription = "Password", tint = SlateGray) },
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    colors = TextFieldDefaults.outlinedTextFieldColors(
                        focusedBorderColor = EmeraldGreen,
                        unfocusedBorderColor = SlateGray.copy(alpha = 0.3f)
                    ),
                    shape = RoundedCornerShape(12.dp)
                )

                Spacer(modifier = Modifier.height(32.dp))

                Button(
                    onClick = onLoginSuccess,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen)
                ) {
                    Text("Authenticate", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
    }
}
