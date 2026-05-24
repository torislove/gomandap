package com.gomandap.common.ui.state

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ErrorOutline
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.Stable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import com.gomandap.common.design.GomandapTokens

/**
 * Represents the state of a single form field, including its current value,
 * optional error message, and validity status.
 *
 * @property value The current text value of the field.
 * @property error The error message for this field, or null if no error.
 * @property isValid Whether the field currently passes validation.
 */
data class FormFieldState(
    val value: String = "",
    val error: String? = null,
    val isValid: Boolean = true
)

/**
 * Manages the state of a form with multiple fields, providing validation,
 * error tracking, and scroll-to-error support.
 *
 * Fields are identified by string keys. The class tracks per-field errors
 * and exposes aggregate state (hasErrors, firstErrorFieldKey) for UI logic.
 *
 * Usage:
 * ```
 * val formState = remember { FormState() }
 * formState.updateField("email", emailValue)
 * formState.setError("email", "Invalid email address")
 * formState.clearError("email")
 * ```
 */
@Stable
class FormState {

    /**
     * Internal mutable map of field keys to their current [FormFieldState].
     */
    private val _fields = mutableStateMapOf<String, FormFieldState>()

    /**
     * Read-only snapshot of all field states keyed by field identifier.
     */
    val fields: Map<String, FormFieldState>
        get() = _fields.toMap()

    /**
     * Whether any field in the form currently has an error.
     */
    val hasErrors: Boolean
        get() = _fields.values.any { it.error != null }

    /**
     * The key of the first field with an error (insertion order),
     * or null if no errors exist.
     */
    val firstErrorFieldKey: String?
        get() = _fields.entries.firstOrNull { it.value.error != null }?.key

    /**
     * Whether a form submission has failed due to a network/server error.
     * Used by [FormSubmissionErrorBanner] to show/hide the banner.
     */
    var submissionError: String? by mutableStateOf(null)
        internal set

    /**
     * Registered validation rules per field key.
     */
    private val validationRules = mutableMapOf<String, (String) -> String?>()

    /**
     * Updates the value of a field and optionally clears its error if the
     * new value passes validation.
     *
     * @param fieldKey The identifier of the field to update.
     * @param value The new value for the field.
     */
    fun updateField(fieldKey: String, value: String) {
        val currentField = _fields[fieldKey]
        val rule = validationRules[fieldKey]
        val error = rule?.invoke(value)
        _fields[fieldKey] = FormFieldState(
            value = value,
            error = if (currentField?.error != null && error == null) null else currentField?.error,
            isValid = error == null
        )
    }

    /**
     * Registers a validation rule for a field. The rule receives the field
     * value and returns an error message string if invalid, or null if valid.
     *
     * @param fieldKey The identifier of the field.
     * @param rule A function that returns an error message or null.
     */
    fun addValidationRule(fieldKey: String, rule: (String) -> String?) {
        validationRules[fieldKey] = rule
    }

    /**
     * Runs all registered validation rules against current field values.
     *
     * @return true if all fields pass validation, false if any field has errors.
     */
    fun validate(): Boolean {
        var allValid = true
        for ((key, rule) in validationRules) {
            val field = _fields[key] ?: FormFieldState()
            val error = rule(field.value)
            _fields[key] = field.copy(
                error = error,
                isValid = error == null
            )
            if (error != null) {
                allValid = false
            }
        }
        return allValid
    }

    /**
     * Clears the error for a specific field.
     *
     * @param fieldKey The identifier of the field to clear the error for.
     */
    fun clearError(fieldKey: String) {
        val field = _fields[fieldKey] ?: return
        _fields[fieldKey] = field.copy(error = null, isValid = true)
    }

    /**
     * Sets an error message on a specific field.
     *
     * @param fieldKey The identifier of the field.
     * @param message The error message to display.
     */
    fun setError(fieldKey: String, message: String) {
        val field = _fields[fieldKey] ?: FormFieldState()
        _fields[fieldKey] = field.copy(error = message, isValid = false)
    }

    /**
     * Reports a submission error (e.g., network or server failure).
     * This triggers the [FormSubmissionErrorBanner] to display.
     *
     * @param message The error message describing the submission failure.
     */
    fun reportSubmissionError(message: String) {
        submissionError = message
    }

    /**
     * Dismisses the submission error, hiding the [FormSubmissionErrorBanner].
     */
    fun dismissSubmissionError() {
        submissionError = null
    }

    /**
     * Initializes a field with a value if it doesn't already exist.
     *
     * @param fieldKey The identifier of the field.
     * @param initialValue The initial value for the field.
     */
    fun initField(fieldKey: String, initialValue: String = "") {
        if (fieldKey !in _fields) {
            _fields[fieldKey] = FormFieldState(value = initialValue)
        }
    }
}

/**
 * Creates and remembers a [FormState] instance for managing form field
 * states, validation, and error handling.
 *
 * @return A remembered [FormState] instance.
 */
@Composable
fun rememberFormState(): FormState {
    return remember { FormState() }
}

/**
 * A composable effect that scrolls to the first field with an error when
 * the form has validation errors.
 *
 * Uses [LaunchedEffect] triggered by changes to [FormState.firstErrorFieldKey].
 * When an error is detected, it scrolls the [LazyListState] to bring the
 * first error field into view.
 *
 * @param formState The [FormState] to observe for errors.
 * @param listState The [LazyListState] controlling the scrollable list.
 * @param fieldKeyToIndex A mapping function that converts a field key to its
 *   index in the lazy list. Returns null if the field is not in the list.
 */
@Composable
fun ScrollToFirstError(
    formState: FormState,
    listState: LazyListState,
    fieldKeyToIndex: (String) -> Int?
) {
    val firstErrorKey = formState.firstErrorFieldKey

    LaunchedEffect(firstErrorKey) {
        if (firstErrorKey != null) {
            val index = fieldKeyToIndex(firstErrorKey)
            if (index != null) {
                listState.animateScrollToItem(index)
            }
        }
    }
}

/**
 * A banner composable displayed when a form submission fails due to a
 * network or server error.
 *
 * The banner preserves all form data (no data is cleared) and provides
 * a retry action for the user to re-attempt submission.
 *
 * The banner animates in/out based on whether [FormState.submissionError]
 * is non-null.
 *
 * @param formState The [FormState] containing the submission error state.
 * @param onRetry Callback invoked when the user taps the retry action.
 * @param modifier Modifier to be applied to the banner.
 */
@Composable
fun FormSubmissionErrorBanner(
    formState: FormState,
    onRetry: () -> Unit,
    modifier: Modifier = Modifier
) {
    val errorMessage = formState.submissionError

    AnimatedVisibility(
        visible = errorMessage != null,
        enter = expandVertically() + fadeIn(),
        exit = shrinkVertically() + fadeOut(),
        modifier = modifier
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .clip(GomandapTokens.Shapes.medium)
                .background(GomandapTokens.Colors.errorLight)
                .padding(
                    horizontal = GomandapTokens.Spacing.md,
                    vertical = GomandapTokens.Spacing.sm
                )
                .semantics {
                    contentDescription = "Form submission error: ${errorMessage ?: ""}"
                },
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.sm)
        ) {
            Icon(
                imageVector = Icons.Default.ErrorOutline,
                contentDescription = null,
                tint = GomandapTokens.Colors.error
            )

            Column(
                modifier = Modifier.weight(1f)
            ) {
                Text(
                    text = "Submission failed",
                    style = GomandapTokens.Typography.labelLarge,
                    color = GomandapTokens.Colors.error
                )
                Text(
                    text = errorMessage ?: "",
                    style = GomandapTokens.Typography.bodySmall,
                    color = GomandapTokens.Colors.royalNavy
                )
            }

            TextButton(onClick = onRetry) {
                Text(
                    text = "Retry",
                    style = GomandapTokens.Typography.labelLarge,
                    color = GomandapTokens.Colors.error
                )
            }
        }
    }
}
