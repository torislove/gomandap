package com.gomandap.common.ui.security

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class InputSanitizerTest {

    // ── sanitizeForDisplay ────────────────────────────────────────────────────

    @Test
    fun `sanitizeForDisplay escapes less-than character`() {
        assertEquals("&lt;div&gt;", InputSanitizer.sanitizeForDisplay("<div>"))
    }

    @Test
    fun `sanitizeForDisplay escapes greater-than character`() {
        assertEquals("&gt;", InputSanitizer.sanitizeForDisplay(">"))
    }

    @Test
    fun `sanitizeForDisplay escapes ampersand`() {
        assertEquals("&amp;", InputSanitizer.sanitizeForDisplay("&"))
    }

    @Test
    fun `sanitizeForDisplay escapes double quote`() {
        assertEquals("&quot;hello&quot;", InputSanitizer.sanitizeForDisplay("\"hello\""))
    }

    @Test
    fun `sanitizeForDisplay escapes single quote`() {
        assertEquals("&#x27;hello&#x27;", InputSanitizer.sanitizeForDisplay("'hello'"))
    }

    @Test
    fun `sanitizeForDisplay does not escape forward slash`() {
        assertEquals("path/to/file", InputSanitizer.sanitizeForDisplay("path/to/file"))
    }

    @Test
    fun `sanitizeForDisplay handles empty string`() {
        assertEquals("", InputSanitizer.sanitizeForDisplay(""))
    }

    @Test
    fun `sanitizeForDisplay preserves normal text`() {
        assertEquals("Hello World", InputSanitizer.sanitizeForDisplay("Hello World"))
    }

    @Test
    fun `sanitizeForDisplay escapes multiple special characters`() {
        assertEquals(
            "&lt;script&gt;alert(&#x27;xss&#x27;)&lt;/script&gt;",
            InputSanitizer.sanitizeForDisplay("<script>alert('xss')</script>")
        )
    }

    @Test
    fun `sanitizeForDisplay handles ampersand in existing entities`() {
        assertEquals("&amp;lt;", InputSanitizer.sanitizeForDisplay("&lt;"))
    }

    // ── sanitizeForWebView ────────────────────────────────────────────────────

    @Test
    fun `sanitizeForWebView escapes all HTML entity characters`() {
        assertEquals(
            "&lt;&gt;&amp;&quot;&#x27;&#x2F;",
            InputSanitizer.sanitizeForWebView("<>&\"'/")
        )
    }

    @Test
    fun `sanitizeForWebView escapes forward slash`() {
        assertEquals("path&#x2F;to&#x2F;file", InputSanitizer.sanitizeForWebView("path/to/file"))
    }

    @Test
    fun `sanitizeForWebView handles empty string`() {
        assertEquals("", InputSanitizer.sanitizeForWebView(""))
    }

    @Test
    fun `sanitizeForWebView preserves normal text`() {
        assertEquals("Hello World", InputSanitizer.sanitizeForWebView("Hello World"))
    }

    @Test
    fun `sanitizeForWebView fully encodes script tag`() {
        assertEquals(
            "&lt;script&gt;alert(&#x27;xss&#x27;)&lt;&#x2F;script&gt;",
            InputSanitizer.sanitizeForWebView("<script>alert('xss')</script>")
        )
    }

    // ── containsMaliciousContent ──────────────────────────────────────────────

    @Test
    fun `containsMaliciousContent detects script opening tag`() {
        assertTrue(InputSanitizer.containsMaliciousContent("<script>alert('xss')</script>"))
    }

    @Test
    fun `containsMaliciousContent detects script closing tag`() {
        assertTrue(InputSanitizer.containsMaliciousContent("</script>"))
    }

    @Test
    fun `containsMaliciousContent detects script tag with spaces`() {
        assertTrue(InputSanitizer.containsMaliciousContent("< script>"))
    }

    @Test
    fun `containsMaliciousContent detects javascript protocol`() {
        assertTrue(InputSanitizer.containsMaliciousContent("javascript:alert(1)"))
    }

    @Test
    fun `containsMaliciousContent detects javascript protocol case insensitive`() {
        assertTrue(InputSanitizer.containsMaliciousContent("JAVASCRIPT:void(0)"))
    }

    @Test
    fun `containsMaliciousContent detects DROP SQL keyword`() {
        assertTrue(InputSanitizer.containsMaliciousContent("DROP TABLE users"))
    }

    @Test
    fun `containsMaliciousContent detects DELETE SQL keyword`() {
        assertTrue(InputSanitizer.containsMaliciousContent("DELETE FROM users"))
    }

    @Test
    fun `containsMaliciousContent detects INSERT SQL keyword`() {
        assertTrue(InputSanitizer.containsMaliciousContent("INSERT INTO users"))
    }

    @Test
    fun `containsMaliciousContent detects UPDATE SQL keyword`() {
        assertTrue(InputSanitizer.containsMaliciousContent("UPDATE users SET"))
    }

    @Test
    fun `containsMaliciousContent detects SQL keywords case insensitive`() {
        assertTrue(InputSanitizer.containsMaliciousContent("drop table users"))
    }

    @Test
    fun `containsMaliciousContent detects onclick event handler`() {
        assertTrue(InputSanitizer.containsMaliciousContent("onclick=alert(1)"))
    }

    @Test
    fun `containsMaliciousContent detects onerror event handler`() {
        assertTrue(InputSanitizer.containsMaliciousContent("<img onerror=alert(1)>"))
    }

    @Test
    fun `containsMaliciousContent detects onload event handler`() {
        assertTrue(InputSanitizer.containsMaliciousContent("<body onload=alert(1)>"))
    }

    @Test
    fun `containsMaliciousContent returns false for normal text`() {
        assertFalse(InputSanitizer.containsMaliciousContent("Hello World"))
    }

    @Test
    fun `containsMaliciousContent returns false for empty string`() {
        assertFalse(InputSanitizer.containsMaliciousContent(""))
    }

    @Test
    fun `containsMaliciousContent returns false for SQL keywords without trailing space`() {
        // "dropdown" contains "drop" but not "DROP " (with whitespace after)
        assertFalse(InputSanitizer.containsMaliciousContent("dropdown menu"))
    }

    @Test
    fun `containsMaliciousContent returns false for words containing update`() {
        // "updated" contains "update" but not as a standalone word followed by space
        assertFalse(InputSanitizer.containsMaliciousContent("The item was updated"))
    }

    // ── stripHtmlTags ─────────────────────────────────────────────────────────

    @Test
    fun `stripHtmlTags removes simple tags`() {
        assertEquals("Hello", InputSanitizer.stripHtmlTags("<b>Hello</b>"))
    }

    @Test
    fun `stripHtmlTags removes tags with attributes`() {
        assertEquals("Click", InputSanitizer.stripHtmlTags("<a href=\"http://evil.com\">Click</a>"))
    }

    @Test
    fun `stripHtmlTags removes self-closing tags`() {
        assertEquals("Before  After", InputSanitizer.stripHtmlTags("Before <br/> After"))
    }

    @Test
    fun `stripHtmlTags removes script tags and content between them`() {
        assertEquals("alert('xss')", InputSanitizer.stripHtmlTags("<script>alert('xss')</script>"))
    }

    @Test
    fun `stripHtmlTags handles empty string`() {
        assertEquals("", InputSanitizer.stripHtmlTags(""))
    }

    @Test
    fun `stripHtmlTags preserves text without tags`() {
        assertEquals("Hello World", InputSanitizer.stripHtmlTags("Hello World"))
    }

    @Test
    fun `stripHtmlTags removes nested tags`() {
        assertEquals("Hello", InputSanitizer.stripHtmlTags("<div><span>Hello</span></div>"))
    }

    @Test
    fun `stripHtmlTags removes img tag with attributes`() {
        assertEquals("", InputSanitizer.stripHtmlTags("<img src=\"x\" onerror=\"alert(1)\">"))
    }
}
