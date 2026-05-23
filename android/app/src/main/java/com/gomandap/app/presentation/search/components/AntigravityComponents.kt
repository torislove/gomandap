package com.gomandap.app.presentation.search.components

import androidx.compose.animation.*
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.core.Spring
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.interaction.collectIsDraggedAsState
import androidx.compose.foundation.interaction.collectIsPressedAsState
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.scale
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.zIndex

private val RoyalNavy     = Color(0xFF0F172A)
private val EmeraldGreen  = Color(0xFF10B981)
private val ChampagneGold = Color(0xFFDFBA73)
private val SlateGray     = Color(0xFF64748B)

// ─────────────────────────────────────────────────────────────────────────────
// 1. GlassChip
// Unselected: flat glass surface.
// Selected: spring selected animation (+5%), elevated (zIndex), colored glow shadow, haptic.
// ─────────────────────────────────────────────────────────────────────────────
@Composable
fun GlassChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    leadingEmoji: String? = null,
    accentColor: Color = EmeraldGreen
) {
    val haptic = LocalHapticFeedback.current
    val interactionSource = remember { MutableInteractionSource() }
    val isPressed by interactionSource.collectIsPressedAsState()

    val scale by animateFloatAsState(
        targetValue = when {
            isPressed -> 0.94f
            selected  -> 1.05f
            else      -> 1.0f
        },
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness    = Spring.StiffnessLow
        ),
        label = "chipScale"
    )

    val zIndex = if (selected) 2f else 1f
    val bgColor     = if (selected) accentColor else Color.White.copy(alpha = 0.85f)
    val textColor   = if (selected) Color.White else RoyalNavy
    val borderAlpha = if (selected) 0f else 0.5f
    val shadowAlpha = if (selected) 0.35f else 0.05f

    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier
            .zIndex(zIndex)
            .scale(scale)
            // Premium glowing custom drop-shadow
            .drawBehind {
                val shadowColor = if (selected) accentColor.copy(alpha = shadowAlpha).toArgb()
                    else RoyalNavy.copy(alpha = shadowAlpha).toArgb()
                drawIntoCanvas { canvas ->
                    val paint = Paint()
                    val fwPaint = paint.asFrameworkPaint()
                    fwPaint.setShadowLayer(
                        if (selected) 24f else 8f, 
                        0f, 
                        if (selected) 6f else 2f, 
                        shadowColor
                    )
                    canvas.drawRoundRect(
                        0f, 0f, size.width, size.height,
                        40f, 40f, paint
                    )
                }
            }
            .background(bgColor, RoundedCornerShape(50))
            .then(
                if (borderAlpha > 0f) Modifier.border(
                    1.dp,
                    Brush.linearGradient(
                        listOf(
                            ChampagneGold.copy(alpha = 0.5f),
                            accentColor.copy(alpha = 0.25f)
                        )
                    ),
                    RoundedCornerShape(50)
                ) else Modifier
            )
            .clickable(
                interactionSource = interactionSource,
                indication = null
            ) {
                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                onClick()
            }
            .padding(horizontal = 16.dp, vertical = 9.dp)
    ) {
        Row(
            horizontalArrangement = Arrangement.spacedBy(6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            if (leadingEmoji != null) {
                Text(text = leadingEmoji, fontSize = 13.sp)
            }
            Text(
                text    = label,
                color   = textColor,
                fontSize = 13.sp,
                fontWeight = if (selected) FontWeight.Bold else FontWeight.Medium
            )
        }
    }
}

// Alias for absolute backward compatibility
@Composable
fun AntigravityGlassChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    leadingEmoji: String? = null,
    accentColor: Color = EmeraldGreen
) {
    GlassChip(label, selected, onClick, modifier, leadingEmoji, accentColor)
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. FloatingRangeSlider
// Dual-thumb range slider. Dragged thumbs spring up + show floating price
// tooltips that fade and bounce upwards using spring(stiffness = Spring.StiffnessLow).
// ─────────────────────────────────────────────────────────────────────────────
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FloatingRangeSlider(
    value: ClosedFloatingPointRange<Float>,
    onValueChange: (ClosedFloatingPointRange<Float>) -> Unit,
    valueRange: ClosedFloatingPointRange<Float> = 0f..100f,
    modifier: Modifier = Modifier,
    labelFormatter: (Float) -> String = { it.toInt().toString() },
    accentColor: Color = EmeraldGreen
) {
    val startInteraction = remember { MutableInteractionSource() }
    val endInteraction   = remember { MutableInteractionSource() }
    val startDragged by startInteraction.collectIsDraggedAsState()
    val endDragged   by endInteraction.collectIsDraggedAsState()

    val startThumbScale by animateFloatAsState(
        targetValue = if (startDragged) 1.35f else 1.0f,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessLow),
        label = "startThumbScale"
    )
    val endThumbScale by animateFloatAsState(
        targetValue = if (endDragged) 1.35f else 1.0f,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessLow),
        label = "endThumbScale"
    )

    Column(modifier = modifier) {
        // Floating glassmorphic tooltips
        Row(
            modifier = Modifier.fillMaxWidth().padding(bottom = 6.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            FloatingTooltipLabel(
                label   = labelFormatter(value.start),
                visible = startDragged,
                color   = accentColor
            )
            Spacer(Modifier.weight(1f))
            FloatingTooltipLabel(
                label   = labelFormatter(value.endInclusive),
                visible = endDragged,
                color   = accentColor
            )
        }

        RangeSlider(
            value    = value,
            onValueChange = onValueChange,
            valueRange    = valueRange,
            startInteractionSource = startInteraction,
            endInteractionSource   = endInteraction,
            startThumb = {
                GlowingThumb(scale = startThumbScale, color = accentColor)
            },
            endThumb = {
                GlowingThumb(scale = endThumbScale, color = accentColor)
            },
            track = { sliderPositions ->
                SliderDefaults.Track(
                    sliderPositions = sliderPositions,
                    colors = SliderDefaults.colors(
                        activeTrackColor   = accentColor,
                        inactiveTrackColor = RoyalNavy.copy(alpha = 0.08f),
                        thumbColor         = accentColor
                    )
                )
            }
        )

        // Lower bounds indicator row
        Row(
            modifier = Modifier.fillMaxWidth().padding(top = 4.dp),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text  = labelFormatter(valueRange.start),
                color = Color(0xFF94A3B8),
                fontSize = 11.sp
            )
            Text(
                text  = labelFormatter(valueRange.endInclusive),
                color = Color(0xFF94A3B8),
                fontSize = 11.sp
            )
        }
    }
}

// Alias for absolute backward compatibility
@Composable
fun AntigravityRangeSlider(
    value: ClosedFloatingPointRange<Float>,
    onValueChange: (ClosedFloatingPointRange<Float>) -> Unit,
    valueRange: ClosedFloatingPointRange<Float> = 0f..100f,
    modifier: Modifier = Modifier,
    labelFormatter: (Float) -> String = { it.toInt().toString() },
    accentColor: Color = EmeraldGreen
) {
    FloatingRangeSlider(value, onValueChange, valueRange, modifier, labelFormatter, accentColor)
}

@Composable
private fun GlowingThumb(scale: Float, color: Color) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .size(24.dp)
            .scale(scale)
            .drawBehind {
                drawIntoCanvas { canvas ->
                    val paint = Paint()
                    paint.asFrameworkPaint().setShadowLayer(
                        12f, 0f, 2f, color.copy(alpha = 0.45f).toArgb()
                    )
                    canvas.drawCircle(
                        Offset(size.width / 2f, size.height / 2f),
                        size.minDimension / 2f,
                        paint
                    )
                }
            }
            .background(color, CircleShape)
    ) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .background(Color.White, CircleShape)
        )
    }
}

@Composable
private fun FloatingTooltipLabel(
    label: String,
    visible: Boolean,
    color: Color
) {
    // Tooltip pops up with a slow, bouncy spring easing
    val tooltipScale by animateFloatAsState(
        targetValue = if (visible) 1.0f else 0.0f,
        animationSpec = spring(
            dampingRatio = Spring.DampingRatioMediumBouncy,
            stiffness    = Spring.StiffnessLow
        ),
        label = "tooltipScale"
    )
    Box(
        contentAlignment = Alignment.Center,
        modifier = Modifier
            .scale(tooltipScale)
            .background(color.copy(alpha = 0.95f), RoundedCornerShape(8.dp))
            .border(
                width = 1.dp,
                brush = Brush.linearGradient(
                    listOf(Color.White.copy(alpha = 0.35f), Color.Transparent)
                ),
                shape = RoundedCornerShape(8.dp)
            )
            .padding(horizontal = 10.dp, vertical = 5.dp)
    ) {
        Text(text = label, color = Color.White, fontSize = 11.sp, fontWeight = FontWeight.Bold)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. FloatingStepper
// A pill-shaped stepless block `[-] 10 [+]` with spring scale taps.
// ─────────────────────────────────────────────────────────────────────────────
@Composable
fun FloatingStepper(
    value: Int,
    onValueChange: (Int) -> Unit,
    modifier: Modifier = Modifier,
    range: IntRange = 0..100,
    accentColor: Color = EmeraldGreen
) {
    val haptic = LocalHapticFeedback.current
    var minusPressed by remember { mutableStateOf(false) }
    var plusPressed by remember { mutableStateOf(false) }

    val minusScale by animateFloatAsState(
        targetValue = if (minusPressed) 0.85f else 1.0f,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium),
        label = "minusScale"
    )
    val plusScale by animateFloatAsState(
        targetValue = if (plusPressed) 0.85f else 1.0f,
        animationSpec = spring(Spring.DampingRatioMediumBouncy, Spring.StiffnessMedium),
        label = "plusScale"
    )

    Box(
        contentAlignment = Alignment.Center,
        modifier = modifier
            .background(Color.White.copy(alpha = 0.85f), RoundedCornerShape(50))
            .border(
                width = 1.dp,
                brush = Brush.linearGradient(
                    listOf(ChampagneGold.copy(alpha = 0.3f), accentColor.copy(alpha = 0.1f))
                ),
                shape = RoundedCornerShape(50)
            )
            .padding(horizontal = 4.dp, vertical = 4.dp)
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Minus Button
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(36.dp)
                    .scale(minusScale)
                    .clip(CircleShape)
                    .background(
                        if (value > range.first) RoyalNavy.copy(alpha = 0.05f) 
                        else Color.Transparent, 
                        CircleShape
                    )
                    .pointerInput(Unit) {
                        detectTapGestures(
                            onPress = {
                                if (value > range.first) {
                                    minusPressed = true
                                    haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                                    tryAwaitRelease()
                                    minusPressed = false
                                }
                            },
                            onTap = {
                                if (value > range.first) {
                                    onValueChange(value - 1)
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                } else {
                                    // Thud haptic on boundary
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                }
                            }
                        )
                    }
            ) {
                Text(
                    text = "−",
                    color = if (value > range.first) RoyalNavy else Color.LightGray,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            // Numeric value with clean transition slide
            AnimatedContent(
                targetState = value,
                transitionSpec = {
                    if (targetState > initialState) {
                        (slideInVertically { height -> height } + fadeIn())
                            .togetherWith(slideOutVertically { height -> -height } + fadeOut())
                    } else {
                        (slideInVertically { height -> -height } + fadeIn())
                            .togetherWith(slideOutVertically { height -> height } + fadeOut())
                    }.using(
                        SizeTransform(clip = false)
                    )
                },
                label = "stepperValueAnim"
            ) { valNum ->
                Text(
                    text = valNum.toString(),
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Black,
                    color = RoyalNavy,
                    modifier = Modifier.widthIn(min = 20.dp),
                    textAlign = TextAlign.Center
                )
            }

            // Plus Button
            Box(
                contentAlignment = Alignment.Center,
                modifier = Modifier
                    .size(36.dp)
                    .scale(plusScale)
                    .clip(CircleShape)
                    .background(
                        if (value < range.last) RoyalNavy.copy(alpha = 0.05f) 
                        else Color.Transparent, 
                        CircleShape
                    )
                    .pointerInput(Unit) {
                        detectTapGestures(
                            onPress = {
                                if (value < range.last) {
                                    plusPressed = true
                                    haptic.performHapticFeedback(HapticFeedbackType.TextHandleMove)
                                    tryAwaitRelease()
                                    plusPressed = false
                                }
                            },
                            onTap = {
                                if (value < range.last) {
                                    onValueChange(value + 1)
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                } else {
                                    // Thud haptic on boundary
                                    haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                }
                            }
                        )
                    }
            ) {
                Text(
                    text = "+",
                    color = if (value < range.last) RoyalNavy else Color.LightGray,
                    fontSize = 18.sp,
                    fontWeight = FontWeight.Bold
                )
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. AntigravityBouncySwitch
// ─────────────────────────────────────────────────────────────────────────────
@Composable
fun AntigravityBouncySwitch(
    title: String,
    subtitle: String? = null,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    accentColor: Color = EmeraldGreen
) {
    val haptic = LocalHapticFeedback.current
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 4.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment     = Alignment.CenterVertically
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(text = title, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, color = RoyalNavy)
            if (subtitle != null) {
                Text(text = subtitle, fontSize = 11.sp, color = SlateGray)
            }
        }
        Spacer(Modifier.width(12.dp))
        Switch(
            checked = checked,
            onCheckedChange = {
                haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                onCheckedChange(it)
            },
            colors = SwitchDefaults.colors(
                checkedThumbColor  = Color.White,
                checkedTrackColor  = accentColor,
                uncheckedThumbColor = Color(0xFF94A3B8),
                uncheckedTrackColor = RoyalNavy.copy(alpha = 0.08f)
            )
        )
    }
}
