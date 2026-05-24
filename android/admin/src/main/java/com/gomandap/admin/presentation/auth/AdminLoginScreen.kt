package com.gomandap.admin.presentation.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
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
import com.gomandap.common.design.GomandapTokens

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
                    colors = listOf(GomandapTokens.Colors.royalNavy, GomandapTokens.Colors.royalNavyLight)
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        Card(
            modifier = Modifier
                .fillMaxWidth(0.9f)
                .padding(GomandapTokens.Spacing.md),
            shape = GomandapTokens.Shapes.extraLarge,
            colors = CardDefaults.cardColors(containerColor = GomandapTokens.Colors.pearlWhite),
            elevation = CardDefaults.cardElevation(defaultElevation = GomandapTokens.Elevation.overlay)
        ) {
            Column(
                modifier = Modifier.padding(GomandapTokens.Spacing.xxl),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                // Logo placeholder
                Box(
                    modifier = Modifier
                        .size(80.dp)
                        .background(GomandapTokens.Colors.emeraldGreen.copy(alpha = 0.1f), GomandapTokens.Shapes.large),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(Icons.Default.Person, contentDescription = "Admin", tint = GomandapTokens.Colors.emeraldGreen, modifier = Modifier.size(40.dp))
                }
                
                Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xl))
                Text("GmAdmin Portal", fontSize = 24.sp, fontWeight = FontWeight.Black, color = GomandapTokens.Colors.royalNavy)
                Text("Secure access for authorized personnel only.", fontSize = 12.sp, color = GomandapTokens.Colors.slateGray, textAlign = TextAlign.Center)
                Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xxl))

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
                            focusedBorderColor = GomandapTokens.Colors.emeraldGreen,
                            unfocusedBorderColor = GomandapTokens.Colors.slateGray.copy(alpha = 0.3f)
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

                Spacer(modifier = Modifier.height(GomandapTokens.Spacing.md))

                OutlinedTextField(
                    value = email,
                    onValueChange = { email = it },
                    label = { Text("Email Address") },
                    leadingIcon = { Icon(Icons.Default.Email, contentDescription = "Email", tint = GomandapTokens.Colors.slateGray) },
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    colors = TextFieldDefaults.outlinedTextFieldColors(
                        focusedBorderColor = GomandapTokens.Colors.emeraldGreen,
                        unfocusedBorderColor = GomandapTokens.Colors.slateGray.copy(alpha = 0.3f)
                    ),
                    shape = GomandapTokens.Shapes.medium
                )

                Spacer(modifier = Modifier.height(GomandapTokens.Spacing.md))

                OutlinedTextField(
                    value = password,
                    onValueChange = { password = it },
                    label = { Text("Password") },
                    leadingIcon = { Icon(Icons.Default.Lock, contentDescription = "Password", tint = GomandapTokens.Colors.slateGray) },
                    visualTransformation = PasswordVisualTransformation(),
                    modifier = Modifier.fillMaxWidth(),
                    singleLine = true,
                    colors = TextFieldDefaults.outlinedTextFieldColors(
                        focusedBorderColor = GomandapTokens.Colors.emeraldGreen,
                        unfocusedBorderColor = GomandapTokens.Colors.slateGray.copy(alpha = 0.3f)
                    ),
                    shape = GomandapTokens.Shapes.medium
                )

                Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xxl))

                Button(
                    onClick = onLoginSuccess,
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp),
                    shape = GomandapTokens.Shapes.large,
                    colors = ButtonDefaults.buttonColors(containerColor = GomandapTokens.Colors.emeraldGreen)
                ) {
                    Text("Authenticate", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                }
            }
        }
    }
}
