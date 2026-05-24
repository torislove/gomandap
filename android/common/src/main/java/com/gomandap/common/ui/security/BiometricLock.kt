package com.gomandap.common.ui.security

import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.outlined.Fingerprint
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import com.gomandap.common.design.GomandapTokens

// ─── Biometric Lock State ────────────────────────────────────────────────────

/**
 * Represents the current state of the biometric lock.
 */
sealed class BiometricLockState {
    /** The app is locked and requires biometric authentication. */
    data object Locked : BiometricLockState()

    /** The app is unlocked and accessible. */
    data object Unlocked : BiometricLockState()

    /** Biometric hardware is not available on this device. */
    data object NotAvailable : BiometricLockState()

    /** Biometric lock is not enabled by the user. */
    data object NotEnabled : BiometricLockState()
}

// ─── Biometric Lock Manager ──────────────────────────────────────────────────

/**
 * Manages biometric authentication for the Admin app.
 *
 * Provides utilities to check biometric availability, prompt the user for
 * authentication, and determine whether the lock should be shown based on
 * the time the app spent in the background.
 */
class BiometricLockManager(private val activity: FragmentActivity) {

    private val biometricManager: BiometricManager =
        BiometricManager.from(activity)

    /**
     * Checks whether biometric authentication (or device credential fallback)
     * is available on this device.
     *
     * @return true if biometric or device credential authentication can be used.
     */
    fun checkBiometricAvailability(): Boolean {
        val canAuthenticate = biometricManager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL
        )
        return canAuthenticate == BiometricManager.BIOMETRIC_SUCCESS
    }

    /**
     * Prompts the user for biometric authentication with device credential fallback.
     *
     * If biometric hardware is unavailable, falls back to device PIN/pattern/password.
     *
     * @param onSuccess Callback invoked when authentication succeeds.
     * @param onFailure Callback invoked when authentication fails, with an error message.
     */
    fun promptBiometric(
        onSuccess: () -> Unit,
        onFailure: (String) -> Unit
    ) {
        val executor = ContextCompat.getMainExecutor(activity)

        val callback = object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                super.onAuthenticationSucceeded(result)
                onSuccess()
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                super.onAuthenticationError(errorCode, errString)
                onFailure(errString.toString())
            }

            override fun onAuthenticationFailed() {
                super.onAuthenticationFailed()
                // Individual attempt failed — prompt remains visible for retry
            }
        }

        val biometricPrompt = BiometricPrompt(activity, executor, callback)

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("GoMandap Admin")
            .setSubtitle("Authenticate to continue")
            .setAllowedAuthenticators(
                BiometricManager.Authenticators.BIOMETRIC_STRONG or
                    BiometricManager.Authenticators.DEVICE_CREDENTIAL
            )
            .build()

        biometricPrompt.authenticate(promptInfo)
    }

    /**
     * Determines whether the biometric lock should be shown based on how long
     * the app was in the background.
     *
     * @param lastBackgroundTimestamp The timestamp (ms) when the app went to background.
     *   A value of 0 means the app has not been backgrounded yet.
     * @param thresholdMs The minimum background duration (ms) before requiring
     *   re-authentication. Defaults to 30 seconds.
     * @return true if the elapsed background time exceeds the threshold.
     */
    fun shouldLock(
        lastBackgroundTimestamp: Long,
        thresholdMs: Long = 30_000L
    ): Boolean {
        if (lastBackgroundTimestamp == 0L) return false
        val elapsed = System.currentTimeMillis() - lastBackgroundTimestamp
        return elapsed >= thresholdMs
    }
}

// ─── Biometric Lock Screen Composable ────────────────────────────────────────

/**
 * Full-screen lock overlay displayed when the Admin app requires biometric
 * authentication after returning from background.
 *
 * Displays the GoMandap logo icon and an "Authenticate to continue" message.
 * Automatically triggers the biometric prompt when shown.
 *
 * Styling uses [GomandapTokens] exclusively:
 * - Background: pearlWhite
 * - Icon: champagneGold, 72dp
 * - Title: headlineMedium, royalNavy
 * - Subtitle: bodyMedium, slateGray
 *
 * @param onAuthenticated Callback invoked when authentication succeeds.
 * @param onAuthFailed Callback invoked when authentication fails or is cancelled.
 * @param activity The [FragmentActivity] required for the biometric prompt.
 */
@Composable
fun BiometricLockScreen(
    onAuthenticated: () -> Unit,
    onAuthFailed: (String) -> Unit,
    activity: FragmentActivity
) {
    val manager = remember { BiometricLockManager(activity) }

    // Trigger biometric prompt automatically when this screen is shown
    LaunchedEffect(Unit) {
        manager.promptBiometric(
            onSuccess = onAuthenticated,
            onFailure = onAuthFailed
        )
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(GomandapTokens.Colors.pearlWhite),
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(horizontal = GomandapTokens.Spacing.xxl)
        ) {
            // GoMandap logo icon (fingerprint icon as placeholder for GoMandap logo)
            Icon(
                imageVector = Icons.Outlined.Fingerprint,
                contentDescription = "GoMandap logo",
                modifier = Modifier.size(72.dp),
                tint = GomandapTokens.Colors.champagneGold
            )

            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xl))

            Text(
                text = "GoMandap Admin",
                style = GomandapTokens.Typography.headlineMedium,
                color = GomandapTokens.Colors.royalNavy,
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))

            Text(
                text = "Authenticate to continue",
                style = GomandapTokens.Typography.bodyMedium,
                color = GomandapTokens.Colors.slateGray,
                textAlign = TextAlign.Center
            )
        }
    }
}

// ─── Remember Biometric State Composable ─────────────────────────────────────

/**
 * Tracks foreground/background transitions and determines whether the biometric
 * lock should be shown based on the 30-second background threshold.
 *
 * This composable observes the [ProcessLifecycleOwner] to detect when the app
 * moves to background and returns to foreground. If the app was in the background
 * for 30 seconds or more, the returned state will be [BiometricLockState.Locked].
 *
 * @param isEnabled Whether the biometric lock feature is enabled by the user.
 *   When false, always returns [BiometricLockState.NotEnabled].
 * @param thresholdMs The minimum background duration (ms) before requiring
 *   re-authentication. Defaults to 30 seconds.
 * @return The current [BiometricLockState] based on lifecycle transitions.
 */
@Composable
fun rememberBiometricState(
    isEnabled: Boolean = true,
    thresholdMs: Long = 30_000L
): BiometricLockState {
    val context = LocalContext.current

    // Check biometric availability
    val biometricAvailable = remember {
        val manager = BiometricManager.from(context)
        val canAuth = manager.canAuthenticate(
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL
        )
        canAuth == BiometricManager.BIOMETRIC_SUCCESS
    }

    if (!isEnabled) return BiometricLockState.NotEnabled
    if (!biometricAvailable) return BiometricLockState.NotAvailable

    var lockState by remember { mutableStateOf<BiometricLockState>(BiometricLockState.Unlocked) }
    var backgroundTimestamp by remember { mutableLongStateOf(0L) }

    DisposableEffect(Unit) {
        val observer = object : DefaultLifecycleObserver {
            override fun onStop(owner: LifecycleOwner) {
                // App moved to background — record timestamp
                backgroundTimestamp = System.currentTimeMillis()
            }

            override fun onStart(owner: LifecycleOwner) {
                // App returned to foreground — check if lock threshold exceeded
                if (backgroundTimestamp > 0L) {
                    val elapsed = System.currentTimeMillis() - backgroundTimestamp
                    if (elapsed >= thresholdMs) {
                        lockState = BiometricLockState.Locked
                    }
                    backgroundTimestamp = 0L
                }
            }
        }

        ProcessLifecycleOwner.get().lifecycle.addObserver(observer)

        onDispose {
            ProcessLifecycleOwner.get().lifecycle.removeObserver(observer)
        }
    }

    return lockState
}
