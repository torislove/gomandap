package com.gomandap.common.components

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Button variants for the GoMandap design system.
 */
enum class ButtonVariant {
    Primary,
    Secondary,
    Outline,
    Ghost,
    Danger
}

/**
 * Button sizes for the GoMandap design system.
 */
enum class ButtonSize {
    /** Height: 32dp */
    Small,
    /** Height: 40dp */
    Medium,
    /** Height: 48dp */
    Large
}

/**
 * GoMandap design system button component.
 *
 * Supports 5 variants (Primary, Secondary, Outline, Ghost, Danger) and 3 sizes
 * (Small 32dp, Medium 40dp, Large 48dp). Includes loading state, disabled state,
 * haptic feedback, optional leading icon, and text truncation with ellipsis.
 *
 * All interactive states maintain a minimum touch target of 48dp × 48dp.
 *
 * @param text The button label text.
 * @param onClick Callback invoked when the button is pressed.
 * @param modifier Modifier to be applied to the button.
 * @param variant The visual variant of the button.
 * @param size The size of the button.
 * @param icon Optional leading icon displayed before the text.
 * @param isLoading When true, replaces label with a circular progress indicator and disables interaction.
 * @param enabled When false, reduces opacity and disables interaction.
 */
@Composable
fun GomandapButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    variant: ButtonVariant = ButtonVariant.Primary,
    size: ButtonSize = ButtonSize.Medium,
    icon: ImageVector? = null,
    isLoading: Boolean = false,
    enabled: Boolean = true
) {
    val hapticFeedback = LocalHapticFeedback.current

    val isInteractive = enabled && !isLoading
    val alpha = when {
        isLoading -> 0.6f
        !enabled -> 0.5f
        else -> 1f
    }

    val buttonHeight = when (size) {
        ButtonSize.Small -> 32.dp
        ButtonSize.Medium -> 40.dp
        ButtonSize.Large -> 48.dp
    }

    val contentPadding = when (size) {
        ButtonSize.Small -> PaddingValues(horizontal = 12.dp, vertical = 4.dp)
        ButtonSize.Medium -> PaddingValues(horizontal = 16.dp, vertical = 8.dp)
        ButtonSize.Large -> PaddingValues(horizontal = 20.dp, vertical = 12.dp)
    }

    val iconSize = when (size) {
        ButtonSize.Small -> 14.dp
        ButtonSize.Medium -> 18.dp
        ButtonSize.Large -> 20.dp
    }

    val progressSize = when (size) {
        ButtonSize.Small -> 14.dp
        ButtonSize.Medium -> 18.dp
        ButtonSize.Large -> 20.dp
    }

    val colors = getButtonColors(variant)

    val wrappedOnClick: () -> Unit = {
        hapticFeedback.performHapticFeedback(HapticFeedbackType.LongPress)
        onClick()
    }

    // Ensure minimum touch target of 48dp × 48dp regardless of visual size
    val touchTargetModifier = modifier
        .sizeIn(minWidth = 48.dp, minHeight = 48.dp)
        .alpha(alpha)

    when (variant) {
        ButtonVariant.Outline -> {
            OutlinedButton(
                onClick = wrappedOnClick,
                modifier = touchTargetModifier,
                enabled = isInteractive,
                shape = GomandapTokens.Shapes.small,
                border = BorderStroke(
                    width = 1.dp,
                    color = if (isInteractive) colors.containerColor else colors.containerColor.copy(alpha = 0.5f)
                ),
                contentPadding = contentPadding,
                colors = ButtonDefaults.outlinedButtonColors(
                    contentColor = colors.contentColor,
                    disabledContentColor = colors.contentColor.copy(alpha = 0.5f)
                )
            ) {
                ButtonContent(
                    text = text,
                    icon = icon,
                    isLoading = isLoading,
                    iconSize = iconSize,
                    progressSize = progressSize,
                    contentColor = colors.contentColor
                )
            }
        }

        ButtonVariant.Ghost -> {
            TextButton(
                onClick = wrappedOnClick,
                modifier = touchTargetModifier,
                enabled = isInteractive,
                shape = GomandapTokens.Shapes.small,
                contentPadding = contentPadding,
                colors = ButtonDefaults.textButtonColors(
                    contentColor = colors.contentColor,
                    disabledContentColor = colors.contentColor.copy(alpha = 0.5f)
                )
            ) {
                ButtonContent(
                    text = text,
                    icon = icon,
                    isLoading = isLoading,
                    iconSize = iconSize,
                    progressSize = progressSize,
                    contentColor = colors.contentColor
                )
            }
        }

        else -> {
            Button(
                onClick = wrappedOnClick,
                modifier = touchTargetModifier,
                enabled = isInteractive,
                shape = GomandapTokens.Shapes.small,
                contentPadding = contentPadding,
                colors = ButtonDefaults.buttonColors(
                    containerColor = colors.containerColor,
                    contentColor = colors.contentColor,
                    disabledContainerColor = colors.containerColor.copy(alpha = 0.5f),
                    disabledContentColor = colors.contentColor.copy(alpha = 0.5f)
                )
            ) {
                ButtonContent(
                    text = text,
                    icon = icon,
                    isLoading = isLoading,
                    iconSize = iconSize,
                    progressSize = progressSize,
                    contentColor = colors.contentColor
                )
            }
        }
    }
}

/**
 * Internal content composable for the button, handling icon, text, and loading state.
 */
@Composable
private fun ButtonContent(
    text: String,
    icon: ImageVector?,
    isLoading: Boolean,
    iconSize: androidx.compose.ui.unit.Dp,
    progressSize: androidx.compose.ui.unit.Dp,
    contentColor: Color
) {
    if (isLoading) {
        CircularProgressIndicator(
            modifier = Modifier.size(progressSize),
            color = contentColor,
            strokeWidth = 2.dp
        )
    } else {
        Row(verticalAlignment = Alignment.CenterVertically) {
            if (icon != null) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    modifier = Modifier.size(iconSize),
                    tint = contentColor
                )
                Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xs))
            }
            Text(
                text = text,
                style = GomandapTokens.Typography.labelLarge,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

/**
 * Color configuration for a button variant.
 */
private data class ButtonColors(
    val containerColor: Color,
    val contentColor: Color
)

/**
 * Returns the color configuration for the given button variant.
 */
private fun getButtonColors(variant: ButtonVariant): ButtonColors {
    return when (variant) {
        ButtonVariant.Primary -> ButtonColors(
            containerColor = GomandapTokens.Colors.champagneGold,
            contentColor = GomandapTokens.Colors.royalNavy
        )
        ButtonVariant.Secondary -> ButtonColors(
            containerColor = GomandapTokens.Colors.royalNavyLight,
            contentColor = GomandapTokens.Colors.pearlWhite
        )
        ButtonVariant.Outline -> ButtonColors(
            containerColor = GomandapTokens.Colors.champagneGold, // Used for border color
            contentColor = GomandapTokens.Colors.champagneGold
        )
        ButtonVariant.Ghost -> ButtonColors(
            containerColor = Color.Transparent,
            contentColor = GomandapTokens.Colors.slateGray
        )
        ButtonVariant.Danger -> ButtonColors(
            containerColor = GomandapTokens.Colors.error,
            contentColor = GomandapTokens.Colors.pearlWhite
        )
    }
}
