package com.gomandap.common.ui.performance

import android.animation.ObjectAnimator
import android.view.View
import android.view.animation.DecelerateInterpolator
import androidx.activity.ComponentActivity
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.core.animation.doOnEnd
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import com.gomandap.common.R
import com.gomandap.common.design.GomandapTokens

/**
 * Utility object for installing and configuring the Android 12+ SplashScreen API.
 *
 * Usage:
 * ```kotlin
 * class MainActivity : ComponentActivity() {
 *     override fun onCreate(savedInstanceState: Bundle?) {
 *         SplashScreenSetup.install(this)
 *         super.onCreate(savedInstanceState)
 *         // ...
 *     }
 * }
 * ```
 */
object SplashScreenSetup {

    /** Target time for first interactive frame (milliseconds). */
    private const val TARGET_FIRST_FRAME_MS = 1500L

    /**
     * Installs the Android 12+ SplashScreen API on the given activity.
     *
     * - Sets the splash icon to the GoMandap vector drawable (ic_gomandap_logo)
     * - Sets background to Royal Navy (#0F172A)
     * - Keeps splash visible until the first frame is drawn
     * - Adds a fade-out exit animation
     *
     * Must be called BEFORE `super.onCreate()`.
     *
     * @param activity The ComponentActivity to install the splash screen on.
     */
    fun install(activity: ComponentActivity) {
        val splashScreen = activity.installSplashScreen()

        // Keep the splash screen visible until the first frame is drawn.
        // The content view's isReady flag signals when the app is ready to render.
        var isReady = false
        splashScreen.setKeepOnScreenCondition { !isReady }

        // Listen for the first frame to be drawn, then dismiss the splash.
        activity.window.decorView.viewTreeObserver.addOnPreDrawListener {
            isReady = true
            true
        }

        // Configure exit animation: fade out the splash icon smoothly.
        splashScreen.setOnExitAnimationListener { splashScreenView ->
            val fadeOut = ObjectAnimator.ofFloat(
                splashScreenView.view,
                View.ALPHA,
                1f,
                0f
            ).apply {
                interpolator = DecelerateInterpolator()
                duration = 300L
                doOnEnd { splashScreenView.remove() }
            }
            fadeOut.start()
        }
    }
}

/**
 * Theme resource reference for pre-Android 12 splash screen fallback.
 *
 * For devices running below Android 12, the launch activity should use the
 * `Theme.Gomandap.Splash` theme defined in the app's `res/values/themes.xml`:
 *
 * ```xml
 * <style name="Theme.Gomandap.Splash" parent="Theme.SplashScreen">
 *     <item name="windowSplashScreenBackground">#0F172A</item>
 *     <item name="windowSplashScreenAnimatedIcon">@drawable/ic_gomandap_logo</item>
 *     <item name="postSplashScreenTheme">@style/Theme.Gomandap</item>
 * </style>
 * ```
 *
 * In the launch activity's AndroidManifest.xml:
 * ```xml
 * <activity
 *     android:name=".MainActivity"
 *     android:theme="@style/Theme.Gomandap.Splash">
 * ```
 *
 * Then in `onCreate`, call `SplashScreenSetup.install(this)` before `super.onCreate()`.
 * The SplashScreen compat library handles the theme switch automatically.
 */
object SplashTheme {
    /**
     * Resource name for the splash theme.
     * The actual theme must be defined in the app module's resources.
     */
    const val THEME_NAME = "Theme.Gomandap.Splash"

    /**
     * Resource name for the post-splash (main) theme.
     * The app should switch to this theme after the splash is dismissed.
     */
    const val POST_SPLASH_THEME_NAME = "Theme.Gomandap"
}

/**
 * In-app splash composable for use when a splash-like loading screen is needed
 * within the Compose UI (e.g., during initial data loading after the system splash).
 *
 * Displays a Royal Navy background with a centered champagne gold GoMandap logo
 * that fades in over 800ms.
 *
 * @param modifier Optional modifier for the splash container.
 * @param onSplashComplete Callback invoked after the fade-in animation completes.
 */
@Composable
fun GomandapSplashContent(
    modifier: Modifier = Modifier,
    onSplashComplete: () -> Unit = {}
) {
    var startAnimation by remember { mutableStateOf(false) }

    val alphaValue by animateFloatAsState(
        targetValue = if (startAnimation) 1f else 0f,
        animationSpec = tween(durationMillis = 800),
        finishedListener = { onSplashComplete() },
        label = "splash_fade_in"
    )

    LaunchedEffect(Unit) {
        startAnimation = true
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(GomandapTokens.Colors.royalNavy),
        contentAlignment = Alignment.Center
    ) {
        Image(
            painter = painterResource(id = R.drawable.ic_gm_logo),
            contentDescription = "GM Logo",
            modifier = Modifier
                .size(120.dp)
                .alpha(alphaValue)
        )
    }
}
