package com.gomandap.vendor.presentation.auth

import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.res.painterResource
import com.gomandap.app.presentation.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VendorLoginScreen(
    onLoginSuccess: (isNewPartner: Boolean) -> Unit
) {
    val context = LocalContext.current
    var isOtpTab by remember { mutableStateOf(true) }
    var mobileNumber by remember { mutableStateOf("") }
    var enteredOtp by remember { mutableStateOf("") }
    var username by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var otpSent by remember { mutableStateOf(false) }
    var showCategoryDialog by remember { mutableStateOf(false) }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(RoyalNavy)
            .padding(24.dp)
            .verticalScroll(rememberScrollState()),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(20.dp),
            modifier = Modifier.fillMaxWidth()
        ) {
            // Elegant Golden Seal Header
            Card(
                shape = RoundedCornerShape(50),
                colors = CardDefaults.cardColors(containerColor = ChampagneGold.copy(alpha = 0.1f)),
                border = BorderStroke(2.dp, ChampagneGold),
                modifier = Modifier.size(90.dp)
            ) {
                Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
                    Image(
                        painter = painterResource(id = com.gomandap.common.R.drawable.ic_gm_logo),
                        contentDescription = "GM Monogram Logo",
                        modifier = Modifier.size(70.dp)
                    )
                }
            }

            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Text(
                    text = "GM",
                    color = Color.White,
                    fontWeight = FontWeight.Black,
                    fontSize = 28.sp,
                    letterSpacing = 1.sp
                )
                Text(
                    text = "PARTNER PORTAL",
                    color = ChampagneGold,
                    fontWeight = FontWeight.Bold,
                    fontSize = 12.sp,
                    letterSpacing = 2.sp
                )
            }

            Text(
                text = "Manage your wedding venue bookings, milestone payments, and catalog sync in one verified, serverless vault.",
                color = SlateGray,
                fontSize = 11.sp,
                lineHeight = 16.sp,
                modifier = Modifier.padding(horizontal = 8.dp),
                textAlign = androidx.compose.ui.text.style.TextAlign.Center
            )

            // Auth Tab Row
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(Color.White.copy(alpha = 0.05f), RoundedCornerShape(12.dp))
                    .padding(4.dp)
            ) {
                Button(
                    onClick = { isOtpTab = true },
                    modifier = Modifier.weight(1f),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = if (isOtpTab) ChampagneGold else Color.Transparent
                    ),
                    shape = RoundedCornerShape(10.dp),
                    contentPadding = PaddingValues(vertical = 10.dp)
                ) {
                    Text(
                        "Auspicious OTP",
                        color = if (isOtpTab) RoyalNavy else Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp
                    )
                }

                Button(
                    onClick = { isOtpTab = false },
                    modifier = Modifier.weight(1f),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = if (!isOtpTab) ChampagneGold else Color.Transparent
                    ),
                    shape = RoundedCornerShape(10.dp),
                    contentPadding = PaddingValues(vertical = 10.dp)
                ) {
                    Text(
                        "Secure Password",
                        color = if (!isOtpTab) RoyalNavy else Color.White,
                        fontWeight = FontWeight.Bold,
                        fontSize = 12.sp
                    )
                }
            }

            // Authentication Input Card
            Card(
                shape = RoundedCornerShape(16.dp),
                border = BorderStroke(1.dp, LightSlate.copy(alpha = 0.15f)),
                colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.08f)),
                modifier = Modifier.fillMaxWidth()
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(14.dp)
                ) {
                    if (isOtpTab) {
                        OutlinedTextField(
                            value = mobileNumber,
                            onValueChange = { mobileNumber = it },
                            label = { Text("Mobile Number (India Only)", color = SlateGray) },
                            leadingIcon = { Icon(Icons.Default.Phone, contentDescription = null, tint = ChampagneGold) },
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = ChampagneGold,
                                unfocusedBorderColor = LightSlate.copy(alpha = 0.3f),
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White
                            ),
                            shape = RoundedCornerShape(12.dp)
                        )

                        if (otpSent) {
                            OutlinedTextField(
                                value = enteredOtp,
                                onValueChange = { enteredOtp = it },
                                label = { Text("Simulated 4-Digit OTP", color = SlateGray) },
                                leadingIcon = { Icon(Icons.Default.Lock, contentDescription = null, tint = ChampagneGold) },
                                modifier = Modifier.fillMaxWidth(),
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = ChampagneGold,
                                    unfocusedBorderColor = LightSlate.copy(alpha = 0.3f),
                                    focusedTextColor = Color.White,
                                    unfocusedTextColor = Color.White
                                ),
                                shape = RoundedCornerShape(12.dp)
                            )
                        }
                    } else {
                        OutlinedTextField(
                            value = username,
                            onValueChange = { username = it },
                            label = { Text("Partner Username", color = SlateGray) },
                            leadingIcon = { Icon(Icons.Default.Person, contentDescription = null, tint = ChampagneGold) },
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = ChampagneGold,
                                unfocusedBorderColor = LightSlate.copy(alpha = 0.3f),
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White
                            ),
                            shape = RoundedCornerShape(12.dp)
                        )

                        OutlinedTextField(
                            value = password,
                            onValueChange = { password = it },
                            label = { Text("Partner Password", color = SlateGray) },
                            leadingIcon = { Icon(Icons.Default.VpnKey, contentDescription = null, tint = ChampagneGold) },
                            visualTransformation = PasswordVisualTransformation(),
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = ChampagneGold,
                                unfocusedBorderColor = LightSlate.copy(alpha = 0.3f),
                                focusedTextColor = Color.White,
                                unfocusedTextColor = Color.White
                            ),
                            shape = RoundedCornerShape(12.dp)
                        )
                    }
                }
            }

            // Action Buttons
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                if (isOtpTab && !otpSent) {
                    Button(
                        onClick = {
                            if (mobileNumber.length < 10) {
                                Toast.makeText(context, "Enter a valid 10-digit mobile number!", Toast.LENGTH_SHORT).show()
                            } else {
                                otpSent = true
                                Toast.makeText(context, "✨ Auspicious OTP Generated: 7777", Toast.LENGTH_LONG).show()
                            }
                        },
                        modifier = Modifier.fillMaxWidth().height(48.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = ChampagneGold),
                        shape = RoundedCornerShape(8.dp)
                    ) {
                        Text("Send Verification OTP", color = RoyalNavy, fontWeight = FontWeight.Bold)
                    }
                } else {
                    Button(
                        onClick = {
                            if (isOtpTab) {
                                if (enteredOtp == "7777" || enteredOtp == "1234") {
                                    Toast.makeText(context, "🔑 Authentication Approved!", Toast.LENGTH_SHORT).show()
                                    onLoginSuccess(false) // logs into dashboard
                                } else {
                                    Toast.makeText(context, "❌ Invalid OTP! Try 7777 or 1234", Toast.LENGTH_SHORT).show()
                                }
                            } else {
                                if (username.isNotBlank() && password.isNotBlank()) {
                                    Toast.makeText(context, "🔑 Access Granted!", Toast.LENGTH_SHORT).show()
                                    onLoginSuccess(false)
                                } else {
                                    Toast.makeText(context, "Please enter username and password!", Toast.LENGTH_SHORT).show()
                                }
                            }
                        },
                        modifier = Modifier.fillMaxWidth().height(48.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                        shape = RoundedCornerShape(8.dp)
                    ) {
                        Text("Log In Securely", color = Color.White, fontWeight = FontWeight.Bold)
                    }
                }

            // Partner Register Redirector
            OutlinedButton(
                onClick = {
                    showCategoryDialog = true
                },
                modifier = Modifier.fillMaxWidth().height(48.dp),
                border = BorderStroke(1.5.dp, ChampagneGold),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = ChampagneGold),
                shape = RoundedCornerShape(8.dp)
            ) {
                Icon(Icons.Default.AddBusiness, contentDescription = null, modifier = Modifier.padding(end = 8.dp))
                Text("Register New Partner Storefront", fontWeight = FontWeight.Bold)
            }
        }

        Spacer(Modifier.height(10.dp))
        Text(
            "🛡️ Secured by GM Escrow Verification Network",
            color = SlateGray,
            fontSize = 10.sp
        )
    }
}

if (showCategoryDialog) {
        AlertDialog(
            onDismissRequest = { showCategoryDialog = false },
            containerColor = Color.White,
            shape = RoundedCornerShape(16.dp),
            title = {
                Text("Select Your Category", fontWeight = FontWeight.Bold, color = RoyalNavy)
            },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    val categories = listOf(
                        "🏛️ Banquets & Mandapams",
                        "📷 Photography & Film",
                        "🌸 Decorators",
                        "🍽️ Premium Catering",
                        "💄 Makeup Artists"
                    )
                    categories.forEach { category ->
                        Surface(
                            onClick = {
                                showCategoryDialog = false
                                Toast.makeText(context, "🎉 Welcome to GM! Setup your $category business.", Toast.LENGTH_LONG).show()
                                onLoginSuccess(true)
                            },
                            modifier = Modifier.fillMaxWidth(),
                            color = SoftMist,
                            shape = RoundedCornerShape(8.dp),
                            border = BorderStroke(1.dp, LightSlate)
                        ) {
                            Text(
                                text = category,
                                modifier = Modifier.padding(16.dp),
                                fontWeight = FontWeight.SemiBold,
                                color = RoyalNavy
                            )
                        }
                    }
                }
            },
            confirmButton = {
                TextButton(onClick = { showCategoryDialog = false }) {
                    Text("Cancel", color = SlateGray)
                }
            }
        )
    }
}
