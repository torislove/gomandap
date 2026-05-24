package com.gomandap.common.ui.security

/**
 * Utility object for sanitizing user-supplied text inputs before rendering
 * in WebView components or other display contexts. Prevents XSS, script injection,
 * and other malicious content from being executed.
 *
 * Validates: Requirement 14.3
 */
object InputSanitizer {

    // ─── HTML Entity Mappings ────────────────────────────────────────────────
    private val HTML_ENTITY_MAP = mapOf(
        '&' to "&amp;",   // Must be first to avoid double-encoding
        '<' to "&lt;",
        '>' to "&gt;",
        '"' to "&quot;",
        '\'' to "&#x27;",
        '/' to "&#x2F;"
    )

    // ─── Malicious Content Patterns ──────────────────────────────────────────
    private val MALICIOUS_PATTERNS = listOf(
        // Script tags
        Regex("<\\s*script", RegexOption.IGNORE_CASE),
        Regex("</\\s*script", RegexOption.IGNORE_CASE),
        // JavaScript protocol
        Regex("javascript\\s*:", RegexOption.IGNORE_CASE),
        // SQL injection keywords followed by whitespace
        Regex("\\bDROP\\s", RegexOption.IGNORE_CASE),
        Regex("\\bDELETE\\s", RegexOption.IGNORE_CASE),
        Regex("\\bINSERT\\s", RegexOption.IGNORE_CASE),
        Regex("\\bUPDATE\\s", RegexOption.IGNORE_CASE),
        // Event handlers
        Regex("\\bonclick\\b", RegexOption.IGNORE_CASE),
        Regex("\\bonerror\\b", RegexOption.IGNORE_CASE),
        Regex("\\bonload\\b", RegexOption.IGNORE_CASE)
    )

    // ─── HTML tag stripping pattern ──────────────────────────────────────────
    private val HTML_TAG_PATTERN = Regex("<[^>]*>")

    /**
     * Escapes HTML special characters for safe display in text contexts.
     * Encodes: <, >, &, ", '
     *
     * @param input The raw user-supplied text input.
     * @return The sanitized string with HTML special characters escaped.
     */
    fun sanitizeForDisplay(input: String): String {
        if (input.isEmpty()) return input

        val result = StringBuilder(input.length)
        for (char in input) {
            val entity = HTML_ENTITY_MAP[char]
            if (entity != null && char != '/') {
                // sanitizeForDisplay escapes all except forward slash
                result.append(entity)
            } else {
                result.append(char)
            }
        }
        return result.toString()
    }

    /**
     * Full HTML entity encoding for safe rendering in WebView components.
     * Encodes all characters in the entity map: <, >, &, ", ', /
     *
     * @param input The raw user-supplied text input.
     * @return The fully encoded string safe for WebView display.
     */
    fun sanitizeForWebView(input: String): String {
        if (input.isEmpty()) return input

        val result = StringBuilder(input.length)
        for (char in input) {
            val entity = HTML_ENTITY_MAP[char]
            if (entity != null) {
                result.append(entity)
            } else {
                result.append(char)
            }
        }
        return result.toString()
    }

    /**
     * Detects whether the input contains potentially malicious content including
     * script tags, SQL injection patterns, and HTML event handlers.
     *
     * @param input The text to check for malicious content.
     * @return `true` if malicious content is detected, `false` otherwise.
     */
    fun containsMaliciousContent(input: String): Boolean {
        if (input.isEmpty()) return false

        return MALICIOUS_PATTERNS.any { pattern -> pattern.containsMatchIn(input) }
    }

    /**
     * Removes all HTML tags from the input string, leaving only text content.
     *
     * @param input The text potentially containing HTML tags.
     * @return The input with all HTML tags stripped.
     */
    fun stripHtmlTags(input: String): String {
        if (input.isEmpty()) return input

        return HTML_TAG_PATTERN.replace(input, "")
    }
}
