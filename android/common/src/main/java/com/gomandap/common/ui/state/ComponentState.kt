package com.gomandap.common.ui.state

/**
 * Represents the UI state of a component with enforced invariants.
 *
 * This is the canonical ComponentState for the ui.state package, used by
 * [StateTransitionValidator] for state validation.
 *
 * Invariants:
 * - [isLoading] and [isError] cannot both be true simultaneously.
 * - When [isError] is true, [errorMessage] must be non-null with at least 1 character.
 * - [isEmpty] is only meaningful when [isLoading] is false and [isError] is false.
 *
 * @see StateTransitionValidator
 */
data class ComponentState(
    val isLoading: Boolean = false,
    val isError: Boolean = false,
    val errorMessage: String? = null,
    val isEmpty: Boolean = false,
    val isRefreshing: Boolean = false
)
