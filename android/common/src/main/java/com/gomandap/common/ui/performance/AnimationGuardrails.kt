package com.gomandap.common.ui.performance

import android.util.Log
import androidx.compose.animation.core.AnimationSpec
import androidx.compose.animation.core.FastOutSlowInEasing
import androidx.compose.animation.core.tween
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.remember
import com.gomandap.common.design.ThemeConfig

/**
 * Animation Duration Guidelines for GoMandap:
 *
 * - Micro-interactions (button press, toggle, ripple): 100–200ms
 * - Standard transitions (fade, slide, expand): 200–400ms
 * - Complex/page transitions (navigation, full-screen overlays): 400–500ms
 * - Maximum allowed duration: 500ms — never exceed this value.
 *
 * All animations use Material 3 motion curves (FastOutSlowInEasing) for
 * consistent, natural-feeling motion across the app.
 */

// ─────────────────────────────────────────────────────────────────────────────
// 1. Pre-defined Animation Specs
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Pre-defined animation specs for the GoMandap design system.
 *
 * These specs enforce consistent timing and easing across the app,
 * following Material 3 motion guidelines.
 */
object GomandapAnimationSpec {

    /**
     * Quick fade for micro-interactions (100ms).
     * Use for: button press feedback, icon toggles, small state changes.
     */
    fun <T> quickFade(): AnimationSpec<T> = tween(
        durationMillis = DURATION_QUICK,
        easing = FastOutSlowInEasing
    )

    /**
     * Standard transition for typical UI changes (300ms).
     * Use for: content fade-in, panel slides, card expansions.
     */
    fun <T> standardTransition(): AnimationSpec<T> = tween(
        durationMillis = DURATION_STANDARD,
        easing = FastOutSlowInEasing
    )

    /**
     * Long transition for complex animations (500ms).
     * Use for: page transitions, full-screen overlays, navigation animations.
     */
    fun <T> longTransition(): AnimationSpec<T> = tween(
        durationMillis = DURATION_LONG,
        easing = FastOutSlowInEasing
    )

    /** Micro-interaction duration: 100ms */
    const val DURATION_QUICK = 100

    /** Standard transition duration: 300ms */
    const val DURATION_STANDARD = 300

    /** Complex/page transition duration: 500ms */
    const val DURATION_LONG = 500

    /** Maximum allowed animation duration — never exceed this. */
    const val DURATION_MAX = 500
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Animation Config (respects ThemeConfig.animationsEnabled)
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Describes the type of animation for conditional enabling/disabling.
 */
enum class AnimationType {
    /** Decorative animations: shimmer, fade-in, pulse, skeleton loaders. */
    Decorative,

    /** State-change animations: button press, navigation, toggle. */
    StateChange
}

/**
 * CompositionLocal providing the current animation-enabled state.
 * Defaults to `true` (animations enabled).
 */
val LocalAnimationsEnabled = compositionLocalOf { true }

/**
 * Configuration that determines whether an animation should run based on
 * [ThemeConfig.animationsEnabled] and the [AnimationType].
 *
 * When animations are disabled:
 * - [AnimationType.Decorative] animations are skipped (shimmer, fade-in).
 * - [AnimationType.StateChange] animations are preserved (button press, navigation).
 */
object AnimationConfig {

    /**
     * Returns whether the given [animationType] should animate based on
     * the current [animationsEnabled] setting.
     *
     * @param animationsEnabled Whether animations are globally enabled (from ThemeConfig).
     * @param animationType The category of animation being evaluated.
     * @return `true` if the animation should play; `false` if it should be skipped.
     */
    fun shouldAnimate(
        animationsEnabled: Boolean,
        animationType: AnimationType
    ): Boolean {
        if (animationsEnabled) return true
        // When disabled, only state-change animations are preserved
        return animationType == AnimationType.StateChange
    }
}

/**
 * Remembers whether animations are currently enabled from the composition local.
 *
 * Use this in composables to conditionally run decorative animations:
 * ```
 * val animationsEnabled = rememberAnimationEnabled()
 * if (AnimationConfig.shouldAnimate(animationsEnabled, AnimationType.Decorative)) {
 *     // run shimmer animation
 * }
 * ```
 */
@Composable
fun rememberAnimationEnabled(): Boolean {
    val enabled = LocalAnimationsEnabled.current
    return remember(enabled) { enabled }
}

/**
 * Provides the animation-enabled state from [ThemeConfig] to the composition tree.
 *
 * Wrap your content with this to propagate the animation setting:
 * ```
 * ProvideAnimationEnabled(themeConfig) {
 *     // child composables can use rememberAnimationEnabled()
 * }
 * ```
 */
@Composable
fun ProvideAnimationEnabled(
    themeConfig: ThemeConfig,
    content: @Composable () -> Unit
) {
    CompositionLocalProvider(
        LocalAnimationsEnabled provides themeConfig.animationsEnabled,
        content = content
    )
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Frame Budget Animation Wrapper
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Monitors animation frame timing and enforces the 16ms frame budget.
 *
 * If a frame exceeds the budget, intermediate frames are dropped and the
 * animation completes at its end-state. A warning is logged when the budget
 * is exceeded.
 *
 * Usage:
 * ```
 * val frameBudget = remember { FrameBudgetAnimation() }
 * // In your animation loop:
 * frameBudget.onFrame(currentTimeMillis) { shouldSkip ->
 *     if (!shouldSkip) {
 *         // render intermediate frame
 *     } else {
 *         // jump to end state
 *     }
 * }
 * ```
 */
class FrameBudgetAnimation(
    private val frameBudgetMs: Long = FRAME_BUDGET_MS
) {
    private var lastFrameTimeMs: Long = 0L
    private var droppedFrameCount: Int = 0

    /**
     * Called on each animation frame. Evaluates whether the frame is within
     * budget and invokes [onFrame] with a flag indicating whether to skip
     * intermediate rendering.
     *
     * @param currentTimeMs The current system time in milliseconds.
     * @param onFrame Callback receiving `shouldSkipToEnd`:
     *   - `false` = render normally (within budget)
     *   - `true` = skip to end state (budget exceeded)
     */
    fun onFrame(currentTimeMs: Long, onFrame: (shouldSkipToEnd: Boolean) -> Unit) {
        if (lastFrameTimeMs == 0L) {
            lastFrameTimeMs = currentTimeMs
            onFrame(false)
            return
        }

        val elapsed = currentTimeMs - lastFrameTimeMs
        lastFrameTimeMs = currentTimeMs

        if (elapsed > frameBudgetMs) {
            droppedFrameCount++
            Log.w(
                TAG,
                "Animation frame budget exceeded: ${elapsed}ms (budget: ${frameBudgetMs}ms). " +
                    "Dropped frames: $droppedFrameCount. Skipping to end state."
            )
            onFrame(true)
        } else {
            onFrame(false)
        }
    }

    /**
     * Resets the frame tracking state. Call when starting a new animation sequence.
     */
    fun reset() {
        lastFrameTimeMs = 0L
        droppedFrameCount = 0
    }

    /**
     * Returns the total number of frames dropped due to budget overruns
     * since the last [reset].
     */
    fun getDroppedFrameCount(): Int = droppedFrameCount

    companion object {
        private const val TAG = "FrameBudgetAnimation"

        /** Standard frame budget: 16ms (targeting 60fps). */
        const val FRAME_BUDGET_MS = 16L
    }
}

/**
 * Remembers a [FrameBudgetAnimation] instance scoped to the composition.
 *
 * @param frameBudgetMs The frame budget in milliseconds. Defaults to 16ms (60fps).
 */
@Composable
fun rememberFrameBudgetAnimation(
    frameBudgetMs: Long = FrameBudgetAnimation.FRAME_BUDGET_MS
): FrameBudgetAnimation {
    return remember { FrameBudgetAnimation(frameBudgetMs) }
}
