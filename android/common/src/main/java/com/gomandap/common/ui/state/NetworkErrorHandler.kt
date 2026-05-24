package com.gomandap.common.ui.state

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Retry policy configuration for network error recovery with exponential backoff.
 *
 * @property initialDelayMs The initial delay in milliseconds before the first retry.
 * @property maxRetries The maximum number of retry attempts before showing the error banner.
 * @property backoffMultiplier The multiplier applied to the delay after each failed attempt.
 */
data class RetryPolicy(
    val initialDelayMs: Long = 1000L,
    val maxRetries: Int = 3,
    val backoffMultiplier: Float = 2.0f
)

/**
 * State holder for retry logic with exponential backoff.
 *
 * @property canRetry Whether another retry attempt is available (retryCount < maxRetries).
 * @property retryCount The number of retry attempts made so far.
 * @property retry Function to execute the next retry attempt, incrementing the count and delay.
 */
class RetryState internal constructor(
    canRetry: Boolean,
    retryCount: Int,
    private val currentDelayMs: Long,
    private val onRetry: () -> Unit
) {
    var canRetry by mutableStateOf(canRetry)
        internal set

    var retryCount by mutableIntStateOf(retryCount)
        internal set

    /**
     * Triggers a retry attempt. Updates the retry count and applies exponential backoff.
     * Does nothing if [canRetry] is false.
     */
    fun retry() {
        if (canRetry) {
            onRetry()
        }
    }
}

/**
 * Remembers and manages retry state with exponential backoff.
 *
 * Tracks retry count and current delay, implementing exponential backoff:
 * starts at [RetryPolicy.initialDelayMs], doubles per attempt, up to [RetryPolicy.maxRetries].
 *
 * @param policy The retry policy configuration.
 * @param onRetry Callback invoked when a retry is triggered, receiving the current delay in ms.
 * @return A [RetryState] instance tracking retry progress.
 */
@Composable
fun rememberRetryState(
    policy: RetryPolicy = RetryPolicy(),
    onRetry: (delayMs: Long) -> Unit = {}
): RetryState {
    var retryCount by remember { mutableIntStateOf(0) }
    var currentDelayMs by remember { mutableLongStateOf(policy.initialDelayMs) }

    val retryState = remember(retryCount, currentDelayMs, policy) {
        RetryState(
            canRetry = retryCount < policy.maxRetries,
            retryCount = retryCount,
            currentDelayMs = currentDelayMs,
            onRetry = {
                if (retryCount < policy.maxRetries) {
                    val delayForThisRetry = currentDelayMs
                    retryCount++
                    currentDelayMs = (currentDelayMs * policy.backoffMultiplier).toLong()
                    onRetry(delayForThisRetry)
                }
            }
        )
    }

    return retryState
}

/**
 * Inline error banner displayed when a network error occurs.
 *
 * Shows an error message with a "Retry" action button. Uses error/errorLight colors
 * from [GomandapTokens]. Optionally displays a "stale" indicator when last-known data
 * is being preserved below the banner.
 *
 * @param errorMessage The error message to display.
 * @param onRetry Callback invoked when the user taps the "Retry" button.
 * @param modifier Modifier to be applied to the banner.
 * @param showStaleIndicator Whether to show a "Showing cached data" indicator text.
 */
@Composable
fun NetworkErrorBanner(
    errorMessage: String,
    onRetry: () -> Unit,
    modifier: Modifier = Modifier,
    showStaleIndicator: Boolean = false
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(
                color = GomandapTokens.Colors.errorLight,
                shape = GomandapTokens.Shapes.small
            )
            .padding(GomandapTokens.Spacing.sm)
            .semantics { contentDescription = "Network error: $errorMessage" }
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                modifier = Modifier.weight(1f),
                horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xs),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = Icons.Default.Warning,
                    contentDescription = null,
                    tint = GomandapTokens.Colors.error
                )
                Text(
                    text = errorMessage,
                    style = GomandapTokens.Typography.bodySmall,
                    color = GomandapTokens.Colors.error,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
            }

            TextButton(
                onClick = onRetry,
                modifier = Modifier.sizeIn(minWidth = 48.dp, minHeight = 48.dp)
            ) {
                Icon(
                    imageVector = Icons.Default.Refresh,
                    contentDescription = null,
                    tint = GomandapTokens.Colors.error,
                    modifier = Modifier.padding(end = GomandapTokens.Spacing.xxs)
                )
                Text(
                    text = "Retry",
                    style = GomandapTokens.Typography.labelLarge,
                    color = GomandapTokens.Colors.error
                )
            }
        }

        if (showStaleIndicator) {
            Text(
                text = "Showing cached data",
                style = GomandapTokens.Typography.labelSmall,
                color = GomandapTokens.Colors.slateGray,
                modifier = Modifier.padding(top = GomandapTokens.Spacing.xxs)
            )
        }
    }
}
