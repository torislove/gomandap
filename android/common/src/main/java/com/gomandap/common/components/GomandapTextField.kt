package com.gomandap.common.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextOverflow
import com.gomandap.common.design.GomandapTokens

/**
 * Sanitizes user input by escaping HTML special characters to prevent injection attacks.
 *
 * Escapes the following characters:
 * - `&` → `&amp;`
 * - `<` → `&lt;`
 * - `>` → `&gt;`
 * - `"` → `&quot;`
 * - `'` → `&#x27;`
 *
 * @param input The raw user input string.
 * @return The sanitized string with HTML entities escaped.
 */
fun sanitizeInput(input: String): String {
    return input
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")
        .replace("'", "&#x27;")
}

/**
 * GoMandap branded text field component built on Material 3 OutlinedTextField.
 *
 * Features:
 * - Label and placeholder support
 * - Leading and trailing icon support
 * - Error state with colored border and error message display
 * - Real-time validation clearing (error clears when [isError] becomes false)
 * - Input sanitization (HTML special characters are escaped)
 * - Configurable keyboard type
 *
 * @param value The current text field value.
 * @param onValueChange Callback invoked when the text changes. The value passed is sanitized.
 * @param label The label text displayed above/inside the field.
 * @param modifier Optional modifier for the text field.
 * @param placeholder Placeholder text shown when the field is empty.
 * @param leadingIcon Optional icon displayed at the start of the field.
 * @param trailingIcon Optional icon displayed at the end of the field.
 * @param isError Whether the field is in an error state.
 * @param errorMessage The error message to display below the field (max 120 chars, truncated with ellipsis).
 * @param keyboardType The keyboard type to use for input.
 */
@Composable
fun GomandapTextField(
    value: String,
    onValueChange: (String) -> Unit,
    label: String,
    modifier: Modifier = Modifier,
    placeholder: String = "",
    leadingIcon: ImageVector? = null,
    trailingIcon: ImageVector? = null,
    isError: Boolean = false,
    errorMessage: String? = null,
    keyboardType: KeyboardType = KeyboardType.Text
) {
    Column(modifier = modifier) {
        OutlinedTextField(
            value = value,
            onValueChange = { newValue ->
                onValueChange(sanitizeInput(newValue))
            },
            label = {
                Text(
                    text = label,
                    style = GomandapTokens.Typography.labelMedium
                )
            },
            placeholder = if (placeholder.isNotEmpty()) {
                {
                    Text(
                        text = placeholder,
                        style = GomandapTokens.Typography.bodyMedium,
                        color = GomandapTokens.Colors.slateGray
                    )
                }
            } else null,
            leadingIcon = leadingIcon?.let {
                {
                    Icon(
                        imageVector = it,
                        contentDescription = null
                    )
                }
            },
            trailingIcon = trailingIcon?.let {
                {
                    Icon(
                        imageVector = it,
                        contentDescription = null
                    )
                }
            },
            isError = isError,
            textStyle = GomandapTokens.Typography.bodyMedium,
            keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
            singleLine = true,
            shape = GomandapTokens.Shapes.medium,
            colors = OutlinedTextFieldDefaults.colors(
                // Default border
                unfocusedBorderColor = GomandapTokens.Colors.lightSlate,
                // Focused border
                focusedBorderColor = GomandapTokens.Colors.champagneGold,
                // Error border
                errorBorderColor = GomandapTokens.Colors.error,
                // Label colors
                unfocusedLabelColor = GomandapTokens.Colors.slateGray,
                focusedLabelColor = GomandapTokens.Colors.champagneGold,
                errorLabelColor = GomandapTokens.Colors.error,
                // Cursor
                cursorColor = GomandapTokens.Colors.champagneGold,
                errorCursorColor = GomandapTokens.Colors.error,
                // Text color
                focusedTextColor = GomandapTokens.Colors.royalNavy,
                unfocusedTextColor = GomandapTokens.Colors.royalNavy,
                errorTextColor = GomandapTokens.Colors.royalNavy
            ),
            modifier = Modifier.fillMaxWidth()
        )

        // Error message displayed below the field when in error state
        if (isError && !errorMessage.isNullOrEmpty()) {
            val displayMessage = if (errorMessage.length > 120) {
                errorMessage.take(120)
            } else {
                errorMessage
            }
            Text(
                text = displayMessage,
                style = GomandapTokens.Typography.bodySmall,
                color = GomandapTokens.Colors.error,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(
                        start = GomandapTokens.Spacing.md,
                        top = GomandapTokens.Spacing.xxs
                    )
            )
        }
    }
}
