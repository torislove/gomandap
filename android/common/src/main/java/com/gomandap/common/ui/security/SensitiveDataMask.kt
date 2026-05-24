package com.gomandap.common.ui.security

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens
import kotlinx.coroutines.delay

/**
 * Duration in milliseconds before a revealed sensitive field is automatically re-masked.
 */
private const val AUTO_MASK_DELAY_MS = 30_000L

/**
 * Bullet character used to mask sensitive data.
 */
private const val MASK_CHAR = '•'

// ─── Utility Function ────────────────────────────────────────────────────────

/**
 * Returns a masked version of the given [value], showing only the last [visibleChars] characters
 * with the remainder replaced by bullet characters (•).
 *
 * If the value length is less than or equal to [visibleChars], the entire string is masked
 * (all bullets) to avoid revealing the full value.
 *
 * @param value The sensitive string to mask.
 * @param visibleChars The number of trailing characters to leave visible. Defaults to 4.
 * @return The masked string, e.g. "••••••1234".
 */
fun maskString(value: String, visibleChars: Int = 4): String {
    if (value.isEmpty()) return ""
    if (value.length <= visibleChars) {
        return MASK_CHAR.toString().repeat(value.length)
    }
    val maskedLength = value.length - visibleChars
    val maskedPart = MASK_CHAR.toString().repeat(maskedLength)
    val visiblePart = value.takeLast(visibleChars)
    return maskedPart + visiblePart
}

// ─── State Class ─────────────────────────────────────────────────────────────

/**
 * Manages the reveal/mask state for sensitive data fields.
 *
 * Provides [reveal] and [mask] functions to toggle visibility, with an auto-mask timer
 * that re-masks the data after [AUTO_MASK_DELAY_MS] (30 seconds) of being revealed.
 *
 * Use [rememberSensitiveDataState] to create an instance within a composable scope.
 */
@Stable
class SensitiveDataState {

    /**
     * Whether the sensitive data is currently revealed (visible).
     */
    var isRevealed: Boolean by mutableStateOf(false)
        private set

    /**
     * Reveals the sensitive data. The auto-mask timer is managed externally
     * via [LaunchedEffect] in the composable that observes this state.
     */
    fun reveal() {
        isRevealed = true
    }

    /**
     * Masks the sensitive data immediately.
     */
    fun mask() {
        isRevealed = false
    }

    /**
     * Toggles between revealed and masked states.
     */
    fun toggle() {
        isRevealed = !isRevealed
    }
}

/**
 * Creates and remembers a [SensitiveDataState] instance scoped to the composable lifecycle.
 */
@Composable
fun rememberSensitiveDataState(): SensitiveDataState {
    return remember { SensitiveDataState() }
}

// ─── Composable ──────────────────────────────────────────────────────────────

/**
 * A composable that displays sensitive text in a masked format by default,
 * revealing the full value only on explicit user tap.
 *
 * Behavior:
 * - Shows masked text (last 4 characters visible, rest as bullets) by default.
 * - Reveals full text on tap.
 * - Automatically re-masks after 30 seconds of being revealed.
 * - Automatically re-masks when the composable leaves composition (navigation away).
 *
 * @param value The sensitive text to display.
 * @param modifier Modifier to be applied to the root layout.
 * @param visibleChars Number of trailing characters to show when masked. Defaults to 4.
 * @param textStyle The text style to apply. Defaults to [GomandapTokens.Typography.bodyMedium].
 * @param state Optional externally managed [SensitiveDataState]. If null, an internal state is created.
 * @param contentDescriptionLabel Accessibility label describing the masked field (e.g., "Bank account number").
 */
@Composable
fun MaskedText(
    value: String,
    modifier: Modifier = Modifier,
    visibleChars: Int = 4,
    textStyle: TextStyle = GomandapTokens.Typography.bodyMedium,
    state: SensitiveDataState? = null,
    contentDescriptionLabel: String = "Sensitive data"
) {
    val dataState = state ?: rememberSensitiveDataState()
    val interactionSource = remember { MutableInteractionSource() }

    val displayText = if (dataState.isRevealed) value else maskString(value, visibleChars)

    // Auto-re-mask after 30 seconds when revealed
    LaunchedEffect(dataState.isRevealed) {
        if (dataState.isRevealed) {
            delay(AUTO_MASK_DELAY_MS)
            dataState.mask()
        }
    }

    // Auto-re-mask on navigation away (composable leaves composition)
    DisposableEffect(Unit) {
        onDispose {
            dataState.mask()
        }
    }

    Row(
        modifier = modifier
            .sizeIn(minWidth = 48.dp, minHeight = 48.dp)
            .clickable(
                interactionSource = interactionSource,
                indication = null
            ) {
                dataState.toggle()
            }
            .semantics {
                contentDescription = if (dataState.isRevealed) {
                    "$contentDescriptionLabel, revealed"
                } else {
                    "$contentDescriptionLabel, masked. Tap to reveal."
                }
            },
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = displayText,
            style = textStyle,
            color = GomandapTokens.Colors.royalNavy
        )
        Spacer(modifier = Modifier.width(GomandapTokens.Spacing.xs))
        Icon(
            imageVector = if (dataState.isRevealed) {
                Icons.Default.VisibilityOff
            } else {
                Icons.Default.Visibility
            },
            contentDescription = if (dataState.isRevealed) "Hide" else "Show",
            tint = GomandapTokens.Colors.slateGray
        )
    }
}
