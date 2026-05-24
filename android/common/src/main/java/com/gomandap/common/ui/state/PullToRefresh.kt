package com.gomandap.common.ui.state

import androidx.compose.foundation.layout.Box
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.pulltorefresh.PullToRefreshContainer
import androidx.compose.material3.pulltorefresh.rememberPullToRefreshState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.nestedscroll.nestedScroll
import com.gomandap.common.design.GomandapTokens

/**
 * GoMandap pull-to-refresh wrapper composable.
 *
 * Wraps content with a Material 3 pull-to-refresh indicator that uses the
 * champagneGold brand color. The existing content remains fully visible during
 * the refresh operation — content is never hidden while refreshing.
 *
 * Usage:
 * ```
 * GomandapPullToRefresh(
 *     isRefreshing = viewModel.isRefreshing,
 *     onRefresh = { viewModel.refresh() }
 * ) {
 *     LazyColumn { ... }
 * }
 * ```
 *
 * @param isRefreshing Whether a refresh operation is currently in progress.
 * @param onRefresh Callback invoked when the user triggers a pull-to-refresh gesture.
 * @param modifier Modifier to be applied to the outer container.
 * @param content The scrollable content to wrap with pull-to-refresh behavior.
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GomandapPullToRefresh(
    isRefreshing: Boolean,
    onRefresh: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable () -> Unit
) {
    val pullToRefreshState = rememberPullToRefreshState()

    // Trigger the onRefresh callback when the user completes the pull gesture
    if (pullToRefreshState.isRefreshing) {
        LaunchedEffect(true) {
            onRefresh()
        }
    }

    // End the refresh animation when the external isRefreshing state becomes false
    LaunchedEffect(isRefreshing) {
        if (isRefreshing) {
            pullToRefreshState.startRefresh()
        } else {
            pullToRefreshState.endRefresh()
        }
    }

    Box(
        modifier = modifier.nestedScroll(pullToRefreshState.nestedScrollConnection)
    ) {
        // Content is always rendered and visible — never hidden during refresh
        content()

        // Pull-to-refresh indicator displayed at the top, overlaying content
        PullToRefreshContainer(
            state = pullToRefreshState,
            modifier = Modifier.align(Alignment.TopCenter),
            containerColor = GomandapTokens.Colors.pearlWhite,
            contentColor = GomandapTokens.Colors.champagneGold
        )
    }
}
