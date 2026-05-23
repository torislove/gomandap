package com.gomandap.app.presentation.onboarding

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.scaleIn
import androidx.compose.animation.scaleOut
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.search.components.AntigravityGlassChip
import com.gomandap.app.presentation.theme.glassCard

private val RoyalNavy = Color(0xFF0F172A)
private val EmeraldGreen = Color(0xFF10B981)
private val ChampagneGold = Color(0xFFDFBA73)
private val SlateGray = Color(0xFF64748B)

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun EventCategoryScreen(
    onNext: () -> Unit,
    onSkipClick: () -> Unit
) {
    val selectedCategories = remember { mutableStateListOf<String>() }
    
    val allCategories = listOf(
        "Engagement" to "💍",
        "Wedding" to "👑",
        "Reception" to "🥂",
        "Birthday" to "🎂",
        "Half Saree Function" to "🥻",
        "Naming Ceremony" to "👶",
        "Anniversary" to "🎉",
        "Corporate Event" to "🏢"
    )

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
                .verticalScroll(rememberScrollState())
        ) {
            Text(
                text = "What are you planning?",
                fontWeight = FontWeight.Black,
                fontSize = 32.sp,
                color = RoyalNavy,
                lineHeight = 38.sp
            )
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = "Select all the events you need help organizing.",
                fontSize = 16.sp,
                color = SlateGray
            )

            Spacer(modifier = Modifier.height(40.dp))

            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                allCategories.forEach { (category, emoji) ->
                    val isSelected = selectedCategories.contains(category)
                    AntigravityGlassChip(
                        label = category,
                        leadingEmoji = emoji,
                        selected = isSelected,
                        onClick = {
                            if (isSelected) selectedCategories.remove(category)
                            else selectedCategories.add(category)
                        },
                        accentColor = ChampagneGold
                    )
                }
            }
            
            Spacer(modifier = Modifier.height(100.dp)) // padding for bottom FAB
        }

        // Next Action FAB
        Box(modifier = Modifier.align(Alignment.BottomEnd)) {
            AnimatedVisibility(
                visible = selectedCategories.isNotEmpty(),
                enter = scaleIn(),
                exit = scaleOut()
            ) {
                FloatingActionButton(
                    onClick = onNext,
                    containerColor = EmeraldGreen,
                    contentColor = Color.White,
                    shape = RoundedCornerShape(16.dp)
                ) {
                    Text(
                        "Next",
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 24.dp)
                    )
                }
            }
        }
    }
}
