package com.gomandap.common.ui.state

/**
 * Represents the possible states in the component state machine.
 *
 * State transitions follow:
 * - Idle → Loading
 * - Loading → Success | Error
 * - Error → Loading (retry) | Idle (reset)
 * - Success → Loading (refresh) | Idle (reset)
 * - Refreshing → Success | Error
 */
enum class StateTransition {
    Idle,
    Loading,
    Success,
    Error,
    Refreshing
}

/**
 * Result of a state validation check.
 */
sealed class ValidationResult {
    /** The state or transition is valid. */
    data object Valid : ValidationResult()

    /** The state or transition is invalid, with a reason explaining why. */
    data class Invalid(val reason: String) : ValidationResult()
}

/**
 * Validates state transitions and component state invariants.
 *
 * Enforces the state machine rules:
 * - Idle → Loading
 * - Loading → Success | Error
 * - Error → Loading (retry) | Idle (reset)
 * - Success → Loading (refresh) | Idle (reset)
 * - Refreshing → Success | Error
 *
 * Also validates ComponentState invariants:
 * - isLoading and isError cannot both be true simultaneously
 * - When isError is true, errorMessage must be non-null
 * - When isLoading is true, isEmpty is not evaluated (ignored)
 */
object StateTransitionValidator {

    /**
     * Map of valid transitions from each state to its permitted target states.
     */
    private val validTransitions: Map<StateTransition, Set<StateTransition>> = mapOf(
        StateTransition.Idle to setOf(StateTransition.Loading),
        StateTransition.Loading to setOf(StateTransition.Success, StateTransition.Error),
        StateTransition.Error to setOf(StateTransition.Loading, StateTransition.Idle),
        StateTransition.Success to setOf(StateTransition.Loading, StateTransition.Idle),
        StateTransition.Refreshing to setOf(StateTransition.Success, StateTransition.Error)
    )

    /**
     * Validates whether a state transition from [from] to [to] is permitted.
     *
     * @param from The current state.
     * @param to The target state to transition to.
     * @return true if the transition is valid, false otherwise.
     * @throws IllegalStateException if the transition is not permitted.
     */
    fun validate(from: StateTransition, to: StateTransition): Boolean {
        val allowedTargets = validTransitions[from]
            ?: throw IllegalStateException(
                "Invalid state transition: no transitions defined from state '$from'"
            )

        if (to !in allowedTargets) {
            throw IllegalStateException(
                "Invalid state transition: cannot transition from '$from' to '$to'. " +
                    "Permitted transitions from '$from': ${allowedTargets.joinToString(", ") { "'$it'" }}"
            )
        }

        return true
    }

    /**
     * Validates the invariants of a [ComponentState] instance.
     *
     * Checks:
     * 1. isLoading and isError cannot both be true simultaneously
     * 2. When isError is true, errorMessage must be non-null
     * 3. When isLoading is true, isEmpty is not evaluated (ignored — no constraint on isEmpty)
     *
     * @param state The ComponentState to validate.
     * @return [ValidationResult.Valid] if all invariants hold, or [ValidationResult.Invalid] with a reason.
     */
    fun validateComponentState(state: ComponentState): ValidationResult {
        // Rule 1: isLoading and isError cannot both be true simultaneously
        if (state.isLoading && state.isError) {
            return ValidationResult.Invalid(
                "isLoading and isError cannot both be true simultaneously"
            )
        }

        // Rule 2: When isError is true, errorMessage must be non-null
        if (state.isError && state.errorMessage == null) {
            return ValidationResult.Invalid(
                "errorMessage must be non-null when isError is true"
            )
        }

        // Rule 3: When isLoading is true, isEmpty is not evaluated (no constraint needed)
        // This is an informational rule — isEmpty is simply ignored during loading.
        // No validation failure is produced for isEmpty when isLoading is true.

        return ValidationResult.Valid
    }

    /**
     * Determines the [StateTransition] that corresponds to the given [ComponentState].
     *
     * @param state The ComponentState to map.
     * @return The corresponding StateTransition enum value.
     */
    fun resolveCurrentState(state: ComponentState): StateTransition {
        return when {
            state.isRefreshing -> StateTransition.Refreshing
            state.isLoading -> StateTransition.Loading
            state.isError -> StateTransition.Error
            state.isEmpty -> StateTransition.Success // Empty is a form of success (loaded but no data)
            else -> {
                // If none of the flags are set, it could be Idle or Success (with data)
                // We treat the default state (all false, no error) as Idle
                // A state that has been through Loading and arrived at a non-error, non-empty state is Success
                // Since we can't distinguish without history, we default to Idle for the initial state
                StateTransition.Idle
            }
        }
    }

    /**
     * Attempts a state transition and returns the result.
     * Does not throw — returns [ValidationResult] instead.
     *
     * @param from The current state.
     * @param to The target state.
     * @return [ValidationResult.Valid] if the transition is permitted, [ValidationResult.Invalid] otherwise.
     */
    fun tryValidate(from: StateTransition, to: StateTransition): ValidationResult {
        val allowedTargets = validTransitions[from]
            ?: return ValidationResult.Invalid(
                "No transitions defined from state '$from'"
            )

        return if (to in allowedTargets) {
            ValidationResult.Valid
        } else {
            ValidationResult.Invalid(
                "Cannot transition from '$from' to '$to'. " +
                    "Permitted transitions from '$from': ${allowedTargets.joinToString(", ") { "'$it'" }}"
            )
        }
    }
}
