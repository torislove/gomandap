package com.gomandap.app.presentation.auth

import androidx.compose.animation.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.ChampagneGold
import com.gomandap.app.presentation.theme.EmeraldGreen
import com.gomandap.app.presentation.theme.RoyalNavy
import com.gomandap.app.presentation.theme.SlateGray

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AuthScreen(onAuthSuccess: () -> Unit) {
    var phoneNumber by remember { mutableStateOf("") }
    var otp by remember { mutableStateOf("") }
    var isOtpSent by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize()) {
        // Mock Background Image (in reality, an R.drawable.wedding_hero)
        Box(modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(EmeraldGreen.copy(alpha = 0.8f), RoyalNavy)
                )
            )
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(24.dp),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "GoMandap",
                fontSize = 42.sp,
                fontWeight = FontWeight.Black,
                color = ChampagneGold
            )
            Text(
                text = "Your Dream Wedding Awaits",
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
                color = Color.White.copy(alpha = 0.9f)
            )
            
            Spacer(modifier = Modifier.height(64.dp))

            // Glassmorphism Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(24.dp),
                colors = CardDefaults.cardColors(containerColor = Color.White.copy(alpha = 0.15f)),
                border = BorderStroke(1.dp, Color.White.copy(alpha = 0.3f)),
                elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
            ) {
                Column(
                    modifier = Modifier.padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    AnimatedContent(
                        targetState = isOtpSent,
                        label = "auth_flow"
                    ) { otpSent ->
                        if (!otpSent) {
                            // Phone Number Entry
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Text("Login or Signup", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.White)
                                Spacer(modifier = Modifier.height(16.dp))
                                OutlinedTextField(
                                    value = phoneNumber,
                                    onValueChange = { if (it.length <= 10) phoneNumber = it },
                                    label = { Text("Phone Number", color = Color.White.copy(alpha = 0.7f)) },
                                    leadingIcon = { Text("+91", modifier = Modifier.padding(start = 16.dp, end = 8.dp), color = Color.White, fontWeight = FontWeight.Bold) },
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
                                    singleLine = true,
                                    modifier = Modifier.fillMaxWidth(),
                                    colors = TextFieldDefaults.outlinedTextFieldColors(
                                        focusedBorderColor = ChampagneGold,
                                        unfocusedBorderColor = Color.White.copy(alpha = 0.5f),
                                        focusedTextColor = Color.White,
                                        unfocusedTextColor = Color.White
                                    ),
                                    shape = RoundedCornerShape(12.dp)
                                )
                                Spacer(modifier = Modifier.height(24.dp))
                                Button(
                                    onClick = { if (phoneNumber.length == 10) isOtpSent = true },
                                    modifier = Modifier.fillMaxWidth().height(56.dp),
                                    shape = RoundedCornerShape(16.dp),
                                    colors = ButtonDefaults.buttonColors(containerColor = ChampagneGold),
                                    enabled = phoneNumber.length == 10
                                ) {
                                    Text("Send OTP", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                                }
                            }
                        } else {
                            // OTP Entry
                            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.Start
                                ) {
                                    IconButton(onClick = { isOtpSent = false; otp = "" }) {
                                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = Color.White)
                                    }
                                }
                                Text("Verify Phone", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color.White)
                                Text("Enter the 4-digit code sent to +91 $phoneNumber", fontSize = 12.sp, color = Color.White.copy(alpha = 0.8f), textAlign = TextAlign.Center)
                                Spacer(modifier = Modifier.height(16.dp))
                                
                                OutlinedTextField(
                                    value = otp,
                                    onValueChange = { if (it.length <= 4) otp = it },
                                    placeholder = { Text("0 0 0 0", color = Color.White.copy(alpha = 0.5f), textAlign = TextAlign.Center) },
                                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.NumberPassword),
                                    singleLine = true,
                                    modifier = Modifier.fillMaxWidth(0.6f),
                                    textStyle = LocalTextStyle.current.copy(textAlign = TextAlign.Center, fontSize = 24.sp, letterSpacing = 8.sp, color = Color.White),
                                    colors = TextFieldDefaults.outlinedTextFieldColors(
                                        focusedBorderColor = ChampagneGold,
                                        unfocusedBorderColor = Color.White.copy(alpha = 0.5f)
                                    ),
                                    shape = RoundedCornerShape(12.dp)
                                )
                                Spacer(modifier = Modifier.height(24.dp))
                                Button(
                                    onClick = onAuthSuccess,
                                    modifier = Modifier.fillMaxWidth().height(56.dp),
                                    shape = RoundedCornerShape(16.dp),
                                    colors = ButtonDefaults.buttonColors(containerColor = ChampagneGold),
                                    enabled = otp.length == 4
                                ) {
                                    Text("Verify & Continue", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
