package com.gomandap.common.components

import androidx.compose.animation.core.Animatable
import androidx.compose.animation.core.tween
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * GoMandap design system empty state component.
 *
 * Displays a centered layout with an icon, title, description, and an optional
 * action button when a list or data-driven screen has no content to display.
 *
 * The component includes a subtle scale and fade-in animation on first appearance.
 * The icon uses a fade-in animation, and the entire component scales in from 0.8 to 1.0.
 *
 * @param icon The icon to display at the top of the empty state.
 * @param title The title text describing the empty state (max 60 characters recommended).
 * @param description The description text suggesting a next action (max 150 characters recommended).
 * @param actionText Optional label for the call-to-action button. When non-null, a Primary button is shown.
 * @param onAction Optional callback invoked when the action button is pressed.
 * @param modifier Modifier to be applied to the root layout.
 */
@Composable
fun GomandapEmptyState(
    icon: ImageVector,
    title: String,
    description: String,
    actionText: String? = null,
    onAction: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    // Scale animation on first appearance
    val scaleAnim = remember { Animatable(0.8f) }
    // Fade-in animation for the icon
    val iconAlpha = remember { Animatable(0f) }

    LaunchedEffect(Unit) {
        // Animate scale from 0.8 to 1.0
        scaleAnim.animateTo(
            targetValue = 1f,
            animationSpec = tween(durationMillis = 400)
        )
    }

    LaunchedEffect(Unit) {
        // Animate icon fade-in
        iconAlpha.animateTo(
            targetValue = 1f,
            animationSpec = tween(durationMillis = 500)
        )
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .scale(scaleAnim.value),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Icon: 64dp size, slateGray color, with fade-in animation
        Icon(
            imageVector = icon,
            contentDescription = title,
            modifier = Modifier
                .size(64.dp)
                .alpha(iconAlpha.value),
            tint = GomandapTokens.Colors.slateGray
        )

        // Spacing: xl (24dp) between icon and title
        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xl))

        // Title: headlineSmall style, royalNavy color, centered
        Text(
            text = title,
            style = GomandapTokens.Typography.headlineSmall,
            color = GomandapTokens.Colors.royalNavy,
            textAlign = TextAlign.Center
        )

        // Spacing: sm (12dp) between title and description
        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.sm))

        // Description: bodyMedium style, slateGray color, centered, max 280dp width
        Text(
            text = description,
            style = GomandapTokens.Typography.bodyMedium,
            color = GomandapTokens.Colors.slateGray,
            textAlign = TextAlign.Center,
            modifier = Modifier.widthIn(max = 280.dp)
        )

        // Action button (optional): shown only when actionText is non-null
        if (actionText != null) {
            // Spacing: lg (20dp) between description and button
            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.lg))

            GomandapButton(
                text = actionText,
                onClick = { onAction?.invoke() },
                variant = ButtonVariant.Primary
            )
        }
    }
}
