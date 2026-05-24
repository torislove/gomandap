package com.gomandap.app.presentation.auth

import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.res.painterResource
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.ChampagneGold
import com.gomandap.app.presentation.theme.CreamBg
import com.gomandap.app.presentation.theme.EmeraldGreen
import com.gomandap.app.presentation.theme.LightSlate
import com.gomandap.app.presentation.theme.RoyalNavy
import com.gomandap.app.presentation.theme.SlateGray
import com.gomandap.app.presentation.theme.SoftMist
import com.gomandap.app.presentation.theme.glassCard
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit,
    onSkipClick: () -> Unit
) {
    var mobileNumber by remember { mutableStateOf("") }
    var otpValue by remember { mutableStateOf("") }
    var isOtpSent by remember { mutableStateOf(false) }
    var isVerifying by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Brush.verticalGradient(listOf(SoftMist, CreamBg)))
            .padding(24.dp)
    ) {
        TextButton(
            onClick = onSkipClick,
            modifier = Modifier.align(Alignment.TopEnd)
        ) {
            Text("Skip", color = SlateGray, fontWeight = FontWeight.SemiBold)
        }

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.Center),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Image(
                painter = painterResource(id = com.gomandap.common.R.drawable.ic_gm_logo),
                contentDescription = "GM Logo Wreath Monogram",
                modifier = Modifier.size(140.dp)
            )
            Spacer(modifier = Modifier.height(16.dp))
            Text("GM", fontWeight = FontWeight.Black, fontSize = 40.sp, color = RoyalNavy)

            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Premium wedding discovery, booking, and escrow in one place",
                fontSize = 14.sp,
                color = SlateGray,
                fontWeight = FontWeight.Medium,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(20.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                AssistChip(onClick = {}, label = { Text("Verified vendors") }, colors = AssistChipDefaults.assistChipColors(containerColor = Color.White, labelColor = RoyalNavy), border = BorderStroke(1.dp, LightSlate))
                AssistChip(onClick = {}, label = { Text("Escrow secure") }, colors = AssistChipDefaults.assistChipColors(containerColor = Color.White, labelColor = RoyalNavy), border = BorderStroke(1.dp, LightSlate))
            }

            Spacer(modifier = Modifier.height(28.dp))

            AnimatedContent(
                targetState = isOtpSent,
                transitionSpec = {
                    fadeIn() + slideInHorizontally { it } togetherWith fadeOut() + slideOutHorizontally { -it }
                },
                label = "auth_flow"
            ) { otpSent ->
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .glassCard()
                        .padding(24.dp)
                ) {
                    if (!otpSent) {
                        Text("Enter mobile number", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                        Spacer(modifier = Modifier.height(12.dp))
                        Text("We’ll send a secure OTP to verify your account.", fontSize = 13.sp, color = SlateGray)
                        Spacer(modifier = Modifier.height(20.dp))

                        OutlinedTextField(
                            value = mobileNumber,
                            onValueChange = { if (it.length <= 10) mobileNumber = it },
                            leadingIcon = {
                                Text("+91", fontWeight = FontWeight.Bold, color = RoyalNavy, modifier = Modifier.padding(start = 16.dp, end = 8.dp))
                            },
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = ChampagneGold,
                                unfocusedBorderColor = LightSlate,
                                focusedContainerColor = Color.White,
                                unfocusedContainerColor = Color.White
                            ),
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier.fillMaxWidth(),
                            singleLine = true,
                            placeholder = { Text("99999 99999", color = SlateGray) }
                        )

                        Spacer(modifier = Modifier.height(24.dp))

                        Button(
                            onClick = { if (mobileNumber.length == 10) isOtpSent = true },
                            modifier = Modifier.fillMaxWidth().height(56.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                            shape = RoundedCornerShape(18.dp),
                            enabled = mobileNumber.length == 10
                        ) {
                            Text("Get OTP", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = Color.White)
                        }
                    } else {
                        Text("Verify OTP", fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                        Spacer(modifier = Modifier.height(8.dp))
                        Text("Sent to +91 $mobileNumber", fontSize = 13.sp, color = SlateGray)
                        Spacer(modifier = Modifier.height(20.dp))

                        OutlinedTextField(
                            value = otpValue,
                            onValueChange = { if (it.length <= 4) otpValue = it },
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = EmeraldGreen,
                                unfocusedBorderColor = LightSlate,
                                focusedContainerColor = Color.White,
                                unfocusedContainerColor = Color.White
                            ),
                            shape = RoundedCornerShape(16.dp),
                            modifier = Modifier.fillMaxWidth(0.7f).align(Alignment.CenterHorizontally),
                            textStyle = androidx.compose.ui.text.TextStyle(textAlign = TextAlign.Center, fontSize = 24.sp, letterSpacing = 8.sp, fontWeight = FontWeight.Bold),
                            singleLine = true
                        )

                        Spacer(modifier = Modifier.height(24.dp))

                        Button(
                            onClick = {
                                if (otpValue.length == 4) {
                                    scope.launch {
                                        isVerifying = true
                                        delay(800)
                                        isVerifying = false
                                        onLoginSuccess()
                                    }
                                }
                            },
                            modifier = Modifier.fillMaxWidth().height(56.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
                            shape = RoundedCornerShape(18.dp),
                            enabled = otpValue.length == 4 && !isVerifying
                        ) {
                            if (isVerifying) {
                                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp), strokeWidth = 2.dp)
                            } else {
                                Text("Verify & Login", fontSize = 16.sp, fontWeight = FontWeight.Bold, color = ChampagneGold)
                            }
                        }
                    }
                }
            }
        }
    }
}
