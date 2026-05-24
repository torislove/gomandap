package com.gomandap.common.state

/**
 * Represents the UI state of a component with enforced invariants.
 *
 * Invariants:
 * - [isLoading] and [isError] cannot both be true simultaneously.
 * - When [isError] is true, [errorMessage] must be non-null with at least 1 character.
 * - [isEmpty] is only meaningful when [isLoading] is false and [isError] is false.
 *
 * State machine with permitted transitions:
 * - Idle → Loading
 * - Loading → Success (isEmpty evaluated)
 * - Loading → Error
 * - Error → Loading (retry)
 * - Success → Loading (refresh)
 * - Any → Refreshing (preserves content)
 */
data class ComponentState(
    val isLoading: Boolean = false,
    val isError: Boolean = false,
    val errorMessage: String? = null,
    val isEmpty: Boolean = false,
    val isRefreshing: Boolean = false
) {
    init {
        // Invariant 1: isLoading and isError cannot both be true simultaneously
        require(!(isLoading && isError)) {
            "isLoading and isError cannot both be true simultaneously"
        }

        // Invariant 2: When isError is true, errorMessage must be non-null with min 1 char
        if (isError) {
            require(!errorMessage.isNullOrEmpty()) {
                "errorMessage must be a non-null string with minimum length of 1 when isError is true"
            }
        }

        // Invariant 3: isEmpty is only meaningful when isLoading is false and isError is false
        if (isLoading || isError) {
            require(!isEmpty) {
                "isEmpty is only meaningful when isLoading is false and isError is false"
            }
        }
    }

    /**
     * Transitions to Loading state.
     * Permitted from: Idle, Error (retry), Success (refresh)
     */
    fun toLoading(): ComponentState {
        return ComponentState(isLoading = true)
    }

    /**
     * Transitions to Error state with a message.
     * Permitted from: Loading
     */
    fun toError(message: String): ComponentState {
        require(message.isNotEmpty()) { "Error message must not be empty" }
        return ComponentState(isError = true, errorMessage = message)
    }

    /**
     * Transitions to Success state.
     * Permitted from: Loading
     *
     * @param isEmpty Whether the loaded content is empty.
     */
    fun toSuccess(isEmpty: Boolean = false): ComponentState {
        return ComponentState(isEmpty = isEmpty)
    }

    /**
     * Transitions to Refreshing state (preserves content).
     * Permitted from: Any state
     */
    fun toRefreshing(): ComponentState {
        return ComponentState(isRefreshing = true)
    }

    /**
     * Transitions back to Idle state.
     */
    fun toIdle(): ComponentState {
        return Idle
    }

    companion object {
        /**
         * The default Idle state — no loading, no error, no content evaluation.
         */
        val Idle = ComponentState()

        /**
         * Factory for creating a Loading state.
         */
        fun loading() = ComponentState(isLoading = true)
    }
}
