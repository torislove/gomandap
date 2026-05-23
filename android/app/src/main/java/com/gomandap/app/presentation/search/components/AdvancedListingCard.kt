package com.gomandap.app.presentation.search.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.app.domain.model.Vendor
import com.gomandap.app.presentation.theme.AntigravitySpring
import com.gomandap.app.presentation.theme.antigravityShadow

private val RoyalNavy = Color(0xFF0F172A)
private val EmeraldGreen = Color(0xFF10B981)
private val ChampagneGold = Color(0xFFDFBA73)
private val LightGrayBg = Color(0xFFF8F9FA)
private val SlateGray = Color(0xFF64748B)

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun AdvancedListingCard(
    vendor: Vendor,
    onBookNowClick: () -> Unit,
    onChatClick: () -> Unit,
    onShortlistClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    var isPerPlate by remember { mutableStateOf(true) }
    var isLiked by remember { mutableStateOf(false) }
    
    // Tap scale animation using Spring dynamics and MutableInteractionSource to prevent scroll blocking
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()
    val scaleFactor by animateFloatAsState(
        targetValue = if (isPressed) 0.96f else 1.0f,
        animationSpec = AntigravitySpring.WeightlessSpec,
        label = "clickSpringScale"
    )

    Card(
        modifier = modifier
            .fillMaxWidth()
            .scale(scaleFactor)
            .clickable(
                interactionSource = interactionSource,
                indication = null
            ) {
                onBookNowClick()
            }
            .antigravityShadow(borderRadius = 16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        shape = RoundedCornerShape(16.dp),
        elevation = CardDefaults.cardElevation(defaultElevation = 0.dp)
    ) {
        Column {
            // 1. Media Container (Horizontal Pager Carousel)
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp)
                    .background(Color(0xFFE2E8F0))
            ) {
                val pagerState = rememberPagerState(pageCount = { vendor.imageUrls.size })
                
                HorizontalPager(
                    state = pagerState,
                    modifier = Modifier.fillMaxSize()
                ) { page ->
                    // Image Placeholder (Natively optimized using standard shapes/labels for local reliability)
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(RoyalNavy.copy(alpha = 0.1f)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "📸 ${vendor.name} - View ${page + 1}",
                            color = RoyalNavy.copy(alpha = 0.6f),
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp
                        )
                    }
                }

                // Custom Carousel Page Indicators pinned to bottom center
                Row(
                    Modifier
                        .height(30.dp)
                        .fillMaxWidth()
                        .align(Alignment.BottomCenter),
                    horizontalArrangement = Arrangement.Center
                ) {
                    repeat(vendor.imageUrls.size) { iteration ->
                        val color = if (pagerState.currentPage == iteration) ChampagneGold else Color.White.copy(alpha = 0.5f)
                        Box(
                            modifier = Modifier
                                .padding(3.dp)
                                .clip(CircleShape)
                                .background(color)
                                .size(6.dp)
                        )
                    }
                }

                // Dynamic Floating Trust Badges in top left
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(12.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        if (vendor.isEscrowProtected) {
                            Box(
                                modifier = Modifier
                                    .background(Color.White, RoundedCornerShape(6.dp))
                                    .border(1.dp, EmeraldGreen.copy(alpha = 0.4f), RoundedCornerShape(6.dp))
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Box(modifier = Modifier.size(6.dp).background(EmeraldGreen, CircleShape))
                                    Text(text = "Escrow Guard", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = RoyalNavy)
                                }
                            }
                        }

                        if (vendor.isFastFilling) {
                            Box(
                                modifier = Modifier
                                    .background(ChampagneGold, RoundedCornerShape(6.dp))
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            ) {
                                Text(text = "🔥 FAST FILLING", fontSize = 9.sp, fontWeight = FontWeight.Black, color = Color.White)
                            }
                        }
                    }

                    if (vendor.isVerified) {
                        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                            // Lightning Bolt Q-Commerce Tag
                            Box(
                                modifier = Modifier
                                    .background(ChampagneGold, RoundedCornerShape(6.dp))
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            ) {
                                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Text("⚡", fontSize = 10.sp)
                                    Text(text = "100% INSTANT BOOK", fontSize = 9.sp, fontWeight = FontWeight.Black, color = Color.White)
                                }
                            }
                            
                            Box(
                                modifier = Modifier
                                    .background(RoyalNavy, RoundedCornerShape(6.dp))
                                    .border(1.dp, ChampagneGold.copy(alpha = 0.6f), RoundedCornerShape(6.dp))
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            ) {
                                Text(text = "💎 VERIFIED", fontSize = 9.sp, fontWeight = FontWeight.Bold, color = ChampagneGold)
                            }
                        }
                    }
                }
            }

            // 2. Info Block Details
            Column(modifier = Modifier.padding(16.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        text = vendor.name,
                        fontWeight = FontWeight.ExtraBold,
                        color = RoyalNavy,
                        fontSize = 17.sp,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Star, contentDescription = "Rating", tint = ChampagneGold, modifier = Modifier.size(16.dp))
                        Text(text = vendor.rating.toString(), fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                    }
                }
                Text(text = vendor.locality, fontSize = 12.sp, color = SlateGray, modifier = Modifier.padding(top = 2.dp))

                // 3. Dynamic Contextual Pricing Row
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 12.dp)
                        .background(LightGrayBg, RoundedCornerShape(8.dp))
                        .padding(10.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        val displayPrice = if (isPerPlate) vendor.basePrice else (vendor.basePrice * 2.5)
                        Text(
                            text = "₹${"%,d".format(displayPrice.toInt())}",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Black,
                            color = RoyalNavy
                        )
                        Text(
                            text = if (isPerPlate) "Fixed Base Price (Per Plate)" else "Fixed Package Cost",
                            fontSize = 10.sp,
                            color = SlateGray
                        )
                    }
                    Box(
                        modifier = Modifier
                            .background(Color.White, RoundedCornerShape(6.dp))
                            .border(1.dp, ChampagneGold, RoundedCornerShape(6.dp))
                            .clickable { isPerPlate = !isPerPlate }
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = if (isPerPlate) "Show Package" else "Show Plate",
                            color = ChampagneGold,
                            fontWeight = FontWeight.Bold,
                            fontSize = 10.sp
                        )
                    }
                }

                // 4. Quick Actions Footer Row
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        IconButton(
                            onClick = onChatClick,
                            modifier = Modifier
                                .size(36.dp)
                                .background(LightGrayBg, CircleShape)
                        ) {
                            Text(text = "💬", fontSize = 14.sp)
                        }
                        IconButton(
                            onClick = {
                                isLiked = !isLiked
                                onShortlistClick()
                            },
                            modifier = Modifier
                                .size(36.dp)
                                .background(LightGrayBg, CircleShape)
                        ) {
                            Text(text = if (isLiked) "❤️" else "🖤", fontSize = 14.sp)
                        }
                    }

                    Button(
                        onClick = onBookNowClick,
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                        shape = RoundedCornerShape(8.dp),
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 8.dp)
                    ) {
                        Text(text = "Book Now", fontWeight = FontWeight.Bold, fontSize = 13.sp, color = Color.White)
                    }
                }
            }
        }
    }
}
