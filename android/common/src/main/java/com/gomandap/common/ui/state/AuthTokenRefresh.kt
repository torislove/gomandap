package com.gomandap.common.ui.state

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Lock
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.gomandap.common.components.ButtonSize
import com.gomandap.common.components.ButtonVariant
import com.gomandap.common.components.GomandapButton
import com.gomandap.common.design.GomandapTokens
import com.gomandap.common.ui.navigation.GomandapBottomSheet

/**
 * Represents the authentication state of the current user session.
 */
sealed class AuthState {
    /** User is authenticated with a valid token. */
    data object Authenticated : AuthState()

    /** Token refresh is in progress — transparent to the user. */
    data object Refreshing : AuthState()

    /** Token has expired and refresh failed — user must re-authenticate. */
    data object Expired : AuthState()
}

/**
 * A non-intrusive bottom sheet displayed when the user's session has expired.
 *
 * Shows a "Session Expired" message with a "Sign In Again" button that navigates
 * the user to the login screen. The current navigation state is preserved so the
 * user can be deep-linked back after re-authentication.
 *
 * Styling uses [GomandapTokens] exclusively:
 * - Icon: slateGray, 48dp
 * - Title: headlineMedium, royalNavy
 * - Description: bodyMedium, slateGray
 * - Button: Primary variant, Large size
 *
 * @param isVisible Whether the bottom sheet is currently visible.
 * @param onDismiss Callback invoked when the sheet is dismissed (swipe or scrim tap).
 * @param onReLogin Callback invoked when the user taps "Sign In Again".
 *   The implementation should navigate to login while preserving the current nav state.
 */
@Composable
fun SessionExpiredSheet(
    isVisible: Boolean,
    onDismiss: () -> Unit,
    onReLogin: () -> Unit
) {
    GomandapBottomSheet(
        isVisible = isVisible,
        onDismiss = onDismiss,
        title = null
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    top = GomandapTokens.Spacing.md,
                    bottom = GomandapTokens.Spacing.xxl
                ),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = Icons.Outlined.Lock,
                contentDescription = "Session expired",
                modifier = Modifier.size(48.dp),
                tint = GomandapTokens.Colors.slateGray
            )

            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.md))

            Text(
                text = "Session Expired",
                style = GomandapTokens.Typography.headlineMedium,
                color = GomandapTokens.Colors.royalNavy,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))

            Text(
                text = "Your session has expired. Please sign in again to continue where you left off.",
                style = GomandapTokens.Typography.bodyMedium,
                color = GomandapTokens.Colors.slateGray,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(horizontal = GomandapTokens.Spacing.md)
            )

            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xl))

            GomandapButton(
                text = "Sign In Again",
                onClick = onReLogin,
                variant = ButtonVariant.Primary,
                size = ButtonSize.Large,
                modifier = Modifier.fillMaxWidth()
            )
        }
    }
}

/**
 * Handles authentication state transitions and displays appropriate UI.
 *
 * Behavior:
 * - [AuthState.Authenticated]: Renders [content] normally with no interruption.
 * - [AuthState.Refreshing]: Attempts a transparent token refresh without interrupting
 *   the user. The [content] remains visible during the refresh attempt.
 * - [AuthState.Expired]: Shows the [SessionExpiredSheet] over the [content].
 *   The user can tap "Sign In Again" to navigate to login with preserved navigation state.
 *
 * @param authState The current authentication state.
 * @param onRefreshToken Suspend function that attempts to refresh the auth token.
 *   Returns true if refresh succeeded, false if it failed.
 * @param onReLogin Callback invoked when the user acknowledges session expiry and
 *   chooses to sign in again. Should navigate to login while preserving current nav state.
 * @param onRefreshSuccess Callback invoked when a token refresh succeeds, allowing
 *   the caller to update the auth state back to [AuthState.Authenticated].
 * @param onRefreshFailure Callback invoked when a token refresh fails, allowing
 *   the caller to update the auth state to [AuthState.Expired].
 * @param content The main screen content to display.
 */
@Composable
fun AuthStateHandler(
    authState: AuthState,
    onRefreshToken: suspend () -> Boolean,
    onReLogin: () -> Unit,
    onRefreshSuccess: () -> Unit,
    onRefreshFailure: () -> Unit,
    content: @Composable () -> Unit
) {
    // Always render the content — the session expired sheet overlays non-intrusively
    content()

    // Attempt transparent token refresh when in Refreshing state
    LaunchedEffect(authState) {
        if (authState is AuthState.Refreshing) {
            val success = onRefreshToken()
            if (success) {
                onRefreshSuccess()
            } else {
                onRefreshFailure()
            }
        }
    }

    // Show session expired sheet when token refresh has failed
    SessionExpiredSheet(
        isVisible = authState is AuthState.Expired,
        onDismiss = { /* Non-dismissible by design — user must re-login */ },
        onReLogin = onReLogin
    )
}
