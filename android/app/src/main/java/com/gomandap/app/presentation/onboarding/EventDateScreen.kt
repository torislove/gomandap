package com.gomandap.app.presentation.onboarding

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.glassCard

private val RoyalNavy = Color(0xFF0F172A)
private val EmeraldGreen = Color(0xFF10B981)
private val ChampagneGold = Color(0xFFDFBA73)
private val SlateGray = Color(0xFF64748B)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun EventDateScreen(
    onConfirm: () -> Unit,
    onSkipClick: () -> Unit
) {
    val datePickerState = rememberDatePickerState()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                brush = Brush.verticalGradient(
                    listOf(Color(0xFFF8FAFC), Color(0xFFE2E8F0))
                )
            )
            .padding(top = 48.dp, bottom = 24.dp, start = 24.dp, end = 24.dp)
    ) {
        // Skip Button
        TextButton(
            onClick = onSkipClick,
            modifier = Modifier.align(Alignment.TopEnd)
        ) {
            Text("Skip", color = SlateGray, fontWeight = FontWeight.SemiBold)
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(top = 40.dp)
        ) {
            Text(
                text = "When is the event?",
                fontWeight = FontWeight.Black,
                fontSize = 32.sp,
                color = RoyalNavy,
                lineHeight = 38.sp
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Select an estimated date to help us find available venues.",
                fontSize = 16.sp,
                color = SlateGray
            )

            Spacer(modifier = Modifier.height(32.dp))

            // Calendar Picker wrapped in a glass card for premium feel
            Box(modifier = Modifier.glassCard().padding(8.dp)) {
                DatePicker(
                    state = datePickerState,
                    colors = DatePickerDefaults.colors(
                        selectedDayContainerColor = EmeraldGreen,
                        selectedDayContentColor = Color.White,
                        todayContentColor = EmeraldGreen,
                        todayDateBorderColor = EmeraldGreen
                    )
                )
            }
        }

        // Confirm Action FAB
        Box(modifier = Modifier.align(Alignment.BottomEnd)) {
            AnimatedVisibility(
                visible = datePickerState.selectedDateMillis != null,
                enter = scaleIn(),
                exit = scaleOut()
            ) {
                FloatingActionButton(
                    onClick = onConfirm,
                    containerColor = EmeraldGreen,
                    contentColor = Color.White,
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Text(
                        "Confirm & Explore",
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 24.dp)
                    )
                }
            }
        }
    }
}
