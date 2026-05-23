package com.gomandap.app.presentation.chat

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Send
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.presentation.theme.AntigravitySpring
import com.gomandap.app.presentation.theme.ChampagneGold
import com.gomandap.app.presentation.theme.EmeraldGreen
import com.gomandap.app.presentation.theme.RoyalNavy
import com.gomandap.app.presentation.theme.SlateGray

data class ChatMessage(
    val id: String,
    val text: String,
    val isFromMe: Boolean,
    val timestamp: String
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChatScreen(
    vendorName: String,
    onBackClick: () -> Unit
) {
    var messageText by remember { mutableStateOf("") }
    
    // Mock chat history
    var messages by remember {
        mutableStateOf(
            listOf(
                ChatMessage("1", "Hi there! I'm interested in booking your services for my wedding on Nov 15.", true, "10:00 AM"),
                ChatMessage("2", "Hello! Congratulations on your upcoming wedding! Nov 15th is currently available. How many guests are you expecting?", false, "10:05 AM"),
                ChatMessage("3", "We are expecting around 500 guests.", true, "10:08 AM"),
                ChatMessage("4", "Perfect, our venue can easily accommodate that. Shall we schedule a VR tour or a site visit?", false, "10:15 AM")
            )
        )
    }

    Scaffold(
        topBar = {
            Surface(
                color = Color.White.copy(alpha = 0.9f),
                shadowElevation = 8.dp
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .statusBarsPadding()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    val interactionSource = remember { MutableInteractionSource() }
                    val isPressed by interactionSource.collectIsPressedAsState()
                    val scale by animateFloatAsState(
                        targetValue = if (isPressed) 0.85f else 1f,
                        animationSpec = AntigravitySpring.WeightlessSpec,
                        label = "backSpring"
                    )

                    Surface(
                        modifier = Modifier
                            .size(40.dp)
                            .scale(scale)
                            .clickable(interactionSource = interactionSource, indication = null, onClick = onBackClick),
                        shape = CircleShape,
                        color = Color(0xFFF1F5F9)
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                        }
                    }
                    Spacer(modifier = Modifier.width(16.dp))
                    Column {
                        Text(vendorName, fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                        Text("Online | Escrow Protected", fontSize = 12.sp, color = EmeraldGreen, fontWeight = FontWeight.SemiBold)
                    }
                }
            }
        },
        bottomBar = {
            Surface(
                color = Color.White,
                shadowElevation = 16.dp,
                modifier = Modifier.navigationBarsPadding()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    OutlinedTextField(
                        value = messageText,
                        onValueChange = { messageText = it },
                        placeholder = { Text("Type a message...", color = SlateGray) },
                        modifier = Modifier
                            .weight(1f)
                            .padding(end = 12.dp),
                        shape = RoundedCornerShape(24.dp),
                        colors = TextFieldDefaults.outlinedTextFieldColors(
                            containerColor = Color(0xFFF8FAFC),
                            unfocusedBorderColor = Color.Transparent,
                            focusedBorderColor = ChampagneGold
                        )
                    )
                    
                    val sendInteraction = remember { MutableInteractionSource() }
                    val sendPressed by sendInteraction.collectIsPressedAsState()
                    val sendScale by animateFloatAsState(
                        if (sendPressed) 0.9f else 1f,
                        animationSpec = AntigravitySpring.WeightlessSpec,
                        label = "sendScale"
                    )
                    
                    Surface(
                        modifier = Modifier
                            .size(48.dp)
                            .scale(sendScale)
                            .clickable(
                                interactionSource = sendInteraction,
                                indication = null
                            ) {
                                if (messageText.isNotBlank()) {
                                    messages = messages + ChatMessage(
                                        id = System.currentTimeMillis().toString(),
                                        text = messageText,
                                        isFromMe = true,
                                        timestamp = "Now"
                                    )
                                    messageText = ""
                                }
                            },
                        shape = CircleShape,
                        color = RoyalNavy
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Icon(Icons.Default.Send, contentDescription = "Send", tint = ChampagneGold)
                        }
                    }
                }
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .background(Color(0xFFF8FAFC))
                .padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(messages) { msg ->
                ChatBubble(msg)
            }
        }
    }
}

@Composable
fun ChatBubble(msg: ChatMessage) {
    val align = if (msg.isFromMe) Alignment.CenterEnd else Alignment.CenterStart
    val bgColor = if (msg.isFromMe) RoyalNavy else Color.White
    val textColor = if (msg.isFromMe) Color.White else RoyalNavy
    val shape = if (msg.isFromMe) {
        RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp, bottomStart = 16.dp, bottomEnd = 4.dp)
    } else {
        RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp, bottomStart = 4.dp, bottomEnd = 16.dp)
    }

    Box(
        modifier = Modifier.fillMaxWidth(),
        contentAlignment = align
    ) {
        Column(
            horizontalAlignment = if (msg.isFromMe) Alignment.End else Alignment.Start
        ) {
            Surface(
                shape = shape,
                color = bgColor,
                shadowElevation = if (msg.isFromMe) 2.dp else 4.dp,
                modifier = if (!msg.isFromMe) Modifier.border(1.dp, SlateGray.copy(alpha = 0.1f), shape) else Modifier
            ) {
                Text(
                    text = msg.text,
                    color = textColor,
                    fontSize = 15.sp,
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp)
                )
            }
            Spacer(Modifier.height(4.dp))
            Text(msg.timestamp, fontSize = 11.sp, color = SlateGray)
        }
    }
}
