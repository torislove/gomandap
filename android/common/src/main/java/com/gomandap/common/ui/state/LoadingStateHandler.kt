package com.gomandap.common.ui.state

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.gomandap.common.design.GomandapTokens
import kotlinx.coroutines.delay

/**
 * Default timeout duration in milliseconds for loading state before
 * transitioning to error state.
 */
private const val LOADING_TIMEOUT_MS = 30_000L

/**
 * Represents the internal state of the loading state machine managed by
 * [rememberLoadingState].
 */
@Stable
class LoadingState internal constructor(
    initialState: StateTransition = StateTransition.Loading
) {
    /**
     * The current state in the state machine.
     */
    var currentState: StateTransition by mutableStateOf(initialState)
        private set

    /**
     * Error message when in [StateTransition.Error] state.
     */
    var errorMessage: String? by mutableStateOf(null)
        private set

    /**
     * Whether cached data is available during loading.
     * When true, the loading indicator is non-intrusive (overlay/progress bar)
     * rather than a full skeleton replacement.
     */
    var hasCachedData: Boolean by mutableStateOf(false)
        internal set

    /**
     * Transitions to [StateTransition.Loading] state.
     * Valid from Idle, Error (retry), or Success (refresh).
     */
    fun startLoading(hasCachedData: Boolean = false) {
        val result = StateTransitionValidator.tryValidate(currentState, StateTransition.Loading)
        if (result is ValidationResult.Valid) {
            this.hasCachedData = hasCachedData
            this.errorMessage = null
            currentState = StateTransition.Loading
        }
    }

    /**
     * Transitions to [StateTransition.Success] state.
     * Valid from Loading or Refreshing.
     */
    fun onSuccess() {
        val result = StateTransitionValidator.tryValidate(currentState, StateTransition.Success)
        if (result is ValidationResult.Valid) {
            this.hasCachedData = true
            currentState = StateTransition.Success
        }
    }

    /**
     * Transitions to [StateTransition.Error] state with the given message.
     * Valid from Loading or Refreshing.
     *
     * @param message A non-empty error message describing the failure.
     */
    fun onError(message: String) {
        val result = StateTransitionValidator.tryValidate(currentState, StateTransition.Error)
        if (result is ValidationResult.Valid) {
            this.errorMessage = message.ifEmpty { "An error occurred" }
            currentState = StateTransition.Error
        }
    }

    /**
     * Resets the state machine back to [StateTransition.Idle].
     * Valid from Error or Success.
     */
    fun reset() {
        val result = StateTransitionValidator.tryValidate(currentState, StateTransition.Idle)
        if (result is ValidationResult.Valid) {
            this.errorMessage = null
            currentState = StateTransition.Idle
        }
    }

    /**
     * Converts the current [LoadingState] to a [ComponentState] for use
     * with components that accept [ComponentState].
     */
    fun toComponentState(): ComponentState {
        return when (currentState) {
            StateTransition.Idle -> ComponentState()
            StateTransition.Loading -> ComponentState(isLoading = true)
            StateTransition.Success -> ComponentState()
            StateTransition.Error -> ComponentState(
                isError = true,
                errorMessage = errorMessage ?: "An error occurred"
            )
            StateTransition.Refreshing -> ComponentState(isRefreshing = true)
        }
    }
}

/**
 * Creates and remembers a [LoadingState] instance that manages the loading
 * state machine.
 *
 * The state machine starts in [StateTransition.Loading] and supports the
 * following transitions:
 * - Loading → Success (data arrived)
 * - Loading → Error (timeout or failure)
 * - Error → Loading (retry)
 * - Success → Loading (refresh)
 *
 * A timeout of [timeoutMs] (default 30 seconds) automatically transitions
 * from Loading to Error if no success or explicit error occurs.
 *
 * @param timeoutMs The timeout duration in milliseconds before transitioning
 *   from Loading to Error. Defaults to 30,000ms (30 seconds).
 * @param hasCachedData Whether cached data is available. When true, the
 *   loading UI shows a non-intrusive indicator instead of a full skeleton.
 * @return A [LoadingState] instance for managing the state machine.
 */
@Composable
fun rememberLoadingState(
    timeoutMs: Long = LOADING_TIMEOUT_MS,
    hasCachedData: Boolean = false
): LoadingState {
    val state = remember {
        LoadingState(initialState = StateTransition.Loading).also {
            it.hasCachedData = hasCachedData
        }
    }

    // Handle timeout: transition to Error after timeoutMs if still Loading
    LaunchedEffect(state.currentState) {
        if (state.currentState == StateTransition.Loading) {
            delay(timeoutMs)
            // Only transition if still in Loading state after timeout
            if (state.currentState == StateTransition.Loading) {
                state.onError("Request timed out. Please try again.")
            }
        }
    }

    return state
}

/**
 * A composable that renders different content based on the current [ComponentState].
 *
 * Behavior:
 * - **Loading (no cached data)**: Shows the [loading] composable (skeleton loader).
 * - **Loading (cached data available)**: Shows the [content] composable with a
 *   non-intrusive progress indicator overlay at the top.
 * - **Error**: Shows the [error] composable.
 * - **Success / Idle**: Shows the [content] composable.
 *
 * This composable ensures that stale or undefined content is never shown while
 * loading is in progress. When cached data is available, the existing content
 * remains visible with a subtle loading indicator.
 *
 * @param state The current [ComponentState] driving the UI.
 * @param hasCachedData Whether cached data is available to display during loading.
 * @param modifier Modifier to be applied to the container.
 * @param loading Composable to display as a skeleton loader during first-time fetch.
 * @param error Composable to display when in error state. Receives the error message.
 * @param content Composable to display when data is available (success or cached).
 */
@Composable
fun LoadingStateContent(
    state: ComponentState,
    hasCachedData: Boolean = false,
    modifier: Modifier = Modifier,
    loading: @Composable () -> Unit,
    error: @Composable (String) -> Unit,
    content: @Composable () -> Unit
) {
    Box(modifier = modifier) {
        when {
            // Error state: show error composable
            state.isError -> {
                error(state.errorMessage ?: "An error occurred")
            }

            // Loading with no cached data: show full skeleton
            state.isLoading && !hasCachedData -> {
                loading()
            }

            // Loading with cached data: show content with non-intrusive indicator
            state.isLoading && hasCachedData -> {
                Column {
                    AnimatedVisibility(
                        visible = true,
                        enter = fadeIn(),
                        exit = fadeOut()
                    ) {
                        LinearProgressIndicator(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(bottom = GomandapTokens.Spacing.xs),
                            color = GomandapTokens.Colors.champagneGold,
                            trackColor = GomandapTokens.Colors.lightSlate
                        )
                    }
                    content()
                }
            }

            // Refreshing: show content with progress indicator
            state.isRefreshing -> {
                Column {
                    LinearProgressIndicator(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = GomandapTokens.Spacing.xs),
                        color = GomandapTokens.Colors.champagneGold,
                        trackColor = GomandapTokens.Colors.lightSlate
                    )
                    content()
                }
            }

            // Success / Idle: show content
            else -> {
                content()
            }
        }
    }
}

/**
 * Overload of [LoadingStateContent] that accepts a [LoadingState] directly,
 * deriving the [ComponentState] and cached data flag automatically.
 *
 * @param loadingState The [LoadingState] instance from [rememberLoadingState].
 * @param modifier Modifier to be applied to the container.
 * @param loading Composable to display as a skeleton loader during first-time fetch.
 * @param error Composable to display when in error state. Receives the error message.
 * @param content Composable to display when data is available (success or cached).
 */
@Composable
fun LoadingStateContent(
    loadingState: LoadingState,
    modifier: Modifier = Modifier,
    loading: @Composable () -> Unit,
    error: @Composable (String) -> Unit,
    content: @Composable () -> Unit
) {
    LoadingStateContent(
        state = loadingState.toComponentState(),
        hasCachedData = loadingState.hasCachedData,
        modifier = modifier,
        loading = loading,
        error = error,
        content = content
    )
}
