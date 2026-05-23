package com.gomandap.app.presentation.theme

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.Shape
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

object AntigravitySpring {
    val WeightlessSpec = spring<Float>(
        dampingRatio = Spring.DampingRatioMediumBouncy,
        stiffness = Spring.StiffnessLow
    )

    fun <T> spec() = spring<T>(
        dampingRatio = Spring.DampingRatioMediumBouncy,
        stiffness = Spring.StiffnessLow
    )
}

fun Modifier.glassCard(
    shape: Shape = RoundedCornerShape(20.dp),
    backgroundColor: Color = Color.White.copy(alpha = 0.65f),
    borderColor: Color = Color.White.copy(alpha = 0.35f)
): Modifier = this
    .background(backgroundColor, shape)
    .border(
        width = 1.dp,
        brush = Brush.linearGradient(
            colors = listOf(
                Color.White.copy(alpha = 0.65f),
                Color.White.copy(alpha = 0.15f),
                ChampagneGold.copy(alpha = 0.4f)
            )
        ),
        shape = shape
    )
    .clip(shape)

fun Modifier.antigravityShadow(
    color: Color = RoyalNavy,
    alpha: Float = 0.08f,
    borderRadius: Dp = 16.dp,
    shadowRadius: Dp = 12.dp,
    offsetY: Dp = 4.dp,
    offsetX: Dp = 0.dp
): Modifier = this.drawBehind {
    val shadowColor = color.copy(alpha = alpha).toArgb()
    this.drawIntoCanvas { canvas ->
        val paint = Paint()
        val frameworkPaint = paint.asFrameworkPaint()
        frameworkPaint.color = shadowColor
        frameworkPaint.setShadowLayer(
            shadowRadius.toPx(),
            offsetX.toPx(),
            offsetY.toPx(),
            shadowColor
        )
        canvas.drawRoundRect(
            left = 0f,
            top = 0f,
            right = size.width,
            bottom = size.height,
            radiusX = borderRadius.toPx(),
            radiusY = borderRadius.toPx(),
            paint = paint
        )
    }
}

fun Modifier.neumorphicShadow(
    borderRadius: Dp = 16.dp,
    shadowRadius: Dp = 8.dp,
    lightShadowColor: Color = Color.White.copy(alpha = 0.95f),
    darkShadowColor: Color = Color(0xFF94A3B8).copy(alpha = 0.35f),
    offset: Dp = 4.dp
): Modifier = this.drawBehind {
    this.drawIntoCanvas { canvas ->
        // 1. Bottom-Right Dark Shadow
        val darkPaint = Paint()
        val darkFrameworkPaint = darkPaint.asFrameworkPaint()
        darkFrameworkPaint.color = darkShadowColor.toArgb()
        darkFrameworkPaint.setShadowLayer(
            shadowRadius.toPx(),
            offset.toPx(),
            offset.toPx(),
            darkShadowColor.toArgb()
        )
        canvas.drawRoundRect(
            left = 0f,
            top = 0f,
            right = size.width,
            bottom = size.height,
            radiusX = borderRadius.toPx(),
            radiusY = borderRadius.toPx(),
            paint = darkPaint
        )

        // 2. Top-Left Light Shadow
        val lightPaint = Paint()
        val lightFrameworkPaint = lightPaint.asFrameworkPaint()
        lightFrameworkPaint.color = lightShadowColor.toArgb()
        lightFrameworkPaint.setShadowLayer(
            shadowRadius.toPx(),
            -offset.toPx(),
            -offset.toPx(),
            lightShadowColor.toArgb()
        )
        canvas.drawRoundRect(
            left = 0f,
            top = 0f,
            right = size.width,
            bottom = size.height,
            radiusX = borderRadius.toPx(),
            radiusY = borderRadius.toPx(),
            paint = lightPaint
        )
    }
}
