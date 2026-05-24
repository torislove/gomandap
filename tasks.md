# Implementation Plan: GoMandap UI/UX Redesign & Branding Overhaul

## Overview

This plan implements the comprehensive UI/UX redesign across Admin, Vendor, and Client apps following a phased approach: foundation (tokens, theme, brand assets), core component library, domain-specific components, navigation system, and app-level screen redesigns. All implementation uses Kotlin/Jetpack Compose for native apps and CSS/Tailwind for web parity.

## Tasks

- [x] 1. Set up shared design foundation module
  - [x] 1.1 Create shared `common` module with design token definitions
    - Create a new Gradle module (e.g., `:common:design-system`) shared across Admin, Vendor, and Client apps
    - Define `GomandapTokens` object with all color, typography, spacing, elevation, and shape tokens exactly as specified in the design document
    - Include `ThemeConfig` data class with font scale validation (0.8–1.4 range, default 1.0)
    - Include `ThemeMode` enum (Light, Dark, System)
    - _Requirements: 2.1, 2.3, 2.4, 2.5, 2.6_

  - [x] 1.2 Implement `GomandapTheme` composable and theme provider
    - Create `GomandapTheme` composable that wraps Material 3 `MaterialTheme` with token values
    - Pre-compute all token values at initialization to avoid runtime calculations
    - Implement font scale validation: reject values outside [0.8, 1.4], default to 1.0, log warning
    - Wire color scheme, typography, and shapes from `GomandapTokens` into Material 3 theme
    - _Requirements: 2.2, 2.5, 2.6, 15.3_

  - [x] 1.3 Write property tests for design token system
    - **Property 1: Color Contrast Compliance** — verify all text-background pairings meet WCAG AA (4.5:1 normal, 3:1 large)
    - **Property 5: Theme Token Completeness** — verify no hardcoded visual values in composables
    - **Property 8: Font Scale Validation** — verify range [0.8, 1.4] acceptance and rejection outside range
    - **Validates: Requirements 2.4, 2.5, 3.1, 3.2, 3.3**

  - [x] 1.4 Create brand identity assets
    - Design GoMandap logo as VectorDrawable (full wordmark, standalone icon, monochrome variant)
    - Create app icon assets (rounded square, Royal Navy background, Champagne Gold icon)
    - Create favicon at 16px, 32px sizes using standalone icon variant
    - Create splash screen Lottie animation (800ms–1500ms duration)
    - Implement static fallback for splash if animation fails to load
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

  - [x] 1.5 Write unit tests for theme provider
    - Test font scale boundary values (0.8, 1.0, 1.4, 0.7, 1.5)
    - Test ThemeMode switching (Light, Dark, System)
    - Test token resolution consistency across theme instances
    - _Requirements: 2.4, 2.5_

- [x] 2. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 3. Implement core UI component library
  - [x] 3.1 Implement `GomandapButton` component
    - Build button with 5 variants (Primary, Secondary, Outline, Ghost, Danger) and 3 sizes (Small 32dp, Medium 40dp, Large 48dp)
    - Implement loading state: replace label with circular progress, disable interaction, reduce opacity
    - Implement disabled state: reduce opacity, disable interaction, prevent focus
    - Ensure minimum touch target of 48dp × 48dp regardless of visual size
    - Truncate text with ellipsis when exceeding available width
    - Add haptic feedback on press when enabled in ThemeConfig
    - _Requirements: 5.1, 5.2, 5.4, 5.5, 5.10, 4.1, 4.2, 10.3_

  - [x] 3.2 Implement `GomandapCard` component
    - Build card with 4 variants: Elevated, Outlined, Filled, Glass
    - Support optional onClick with ripple effect
    - Ensure touch target compliance (48dp minimum) for clickable cards
    - Use elevation tokens from `GomandapTokens.Elevation`
    - _Requirements: 5.3, 4.1_

  - [x] 3.3 Implement `GomandapTextField` component
    - Build text field with label, placeholder, leading/trailing icons
    - Implement error state: red border (1dp), error message below field (max 120 chars, ellipsis truncation)
    - Implement real-time validation clearing within 300ms of valid input
    - Support various keyboard types
    - Sanitize input: escape HTML special characters before rendering
    - _Requirements: 5.6, 13.5, 13.6, 14.3_

  - [x] 3.4 Implement `GomandapBadge` component
    - Build badge with 6 variants: Default, Success, Warning, Error, Info, Gold
    - Support optional leading icon
    - Use semantic colors from Design Token System
    - _Requirements: 5.7_

  - [x] 3.5 Implement `GomandapBottomNav` component
    - Accept 3–5 navigation items (icon + label)
    - Report selection changes via callback with selected index
    - Visually indicate currently selected tab
    - Scroll to top or reset to root on re-tap of selected tab
    - _Requirements: 5.8, 8.7, 8.8_

  - [x] 3.6 Implement `GomandapTopBar` component
    - Support title (1 line, ellipsis), optional subtitle (1 line), optional back button, up to 3 action slots
    - Implement collapsing variant that transitions on 56dp scroll
    - Support Standard, Collapsing, Transparent, and Branded styles
    - _Requirements: 5.9, 8.6_

  - [x] 3.7 Implement `GomandapEmptyState` component
    - Display icon (with content description for accessibility), title (max 60 chars), description (max 150 chars)
    - Conditionally render CTA button when actionable next step is configured
    - Ensure text meets WCAG AA contrast requirements
    - _Requirements: 11.1, 11.2, 11.3, 11.5_

  - [x] 3.8 Implement `GomandapSkeleton` loader component
    - Create shimmer animation placeholder matching content layout shapes
    - Support configurable shape via `GomandapTokens.Shapes`
    - Animate within 16ms frame budget
    - _Requirements: 12.1, 12.3, 10.1_

  - [x] 3.9 Write property tests for core components
    - **Property 2: Touch Target Minimum Size** — verify all interactive elements have ≥48dp × 48dp touch targets
    - **Property 14: Loading Button Non-Interactivity** — verify buttons in loading state don't respond to taps
    - **Validates: Requirements 4.1, 4.2, 5.4**

  - [x] 3.10 Write unit tests for core components
    - Test button variants, sizes, and state transitions
    - Test text field error display and clearing behavior
    - Test badge variant rendering
    - Test bottom nav selection and re-tap behavior
    - _Requirements: 5.1–5.10_

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Implement component state management
  - [x] 5.1 Implement `ComponentState` model with state machine
    - Define `ComponentState` data class with isLoading, isError, errorMessage, isEmpty, isRefreshing
    - Enforce invariant: isLoading and isError cannot both be true
    - Enforce invariant: errorMessage non-null when isError is true (min 1 char)
    - Enforce invariant: isEmpty not evaluated while isLoading is true
    - Initialize in Idle state
    - _Requirements: 6.1, 6.2, 6.3, 6.6_

  - [x] 5.2 Implement state transition validation
    - Define permitted transitions: Idle→Loading, Loading→Success, Loading→Error, Error→Loading, Success→Loading
    - Reject invalid transitions and retain current state
    - Implement transition helper functions for clean API
    - _Requirements: 6.4, 6.5_

  - [x] 5.3 Write property tests for component state
    - **Property 3: Component State Validity** — verify all invariants hold for any ComponentState instance
    - **Validates: Requirements 6.1, 6.2, 6.3, 6.4**

  - [x] 5.4 Write unit tests for state transitions
    - Test all valid transition paths
    - Test rejection of invalid transitions
    - Test initial state values
    - _Requirements: 6.4, 6.5, 6.6_

- [x] 6. Implement domain-specific components
  - [x] 6.1 Implement `VendorCard` component
    - Build 4 variants: Standard (name, locality, price, rating, photo), Compact (name, rating, photo), Featured (verified badge, fast-filling), AdminReview (status, admin notes)
    - Integrate skeleton loader for loading state
    - Integrate empty state for no-data scenario
    - Support bookmark and quick action callbacks
    - _Requirements: 7.1, 7.7, 7.8_

  - [x] 6.2 Implement `BookingStatusCard` component
    - Display vendor name, event date, booking status, total amount
    - Optionally embed `EscrowProgressBar`
    - Integrate loading skeleton and empty state
    - _Requirements: 7.2, 7.7, 7.8_

  - [x] 6.3 Implement `EscrowProgressBar` component
    - Visualize milestones as segmented bar proportional to total amount
    - Color-code segments: held, released, frozen using Design Token colors
    - Animate segment transitions within frame budget
    - _Requirements: 7.3, 10.1_

  - [x] 6.4 Implement `StatCard` component
    - Display title (max 40 chars), numeric value, optional trend (Up/Down/Neutral with icon)
    - Support configurable accent color from Design Token System
    - _Requirements: 7.4_

  - [x] 6.5 Implement `AvailabilityCalendar` component
    - Distinguish 3 date states with distinct background colors: available, booked, high-demand (≥80% capacity)
    - Support date selection callback
    - Use Design Token colors for state differentiation
    - _Requirements: 7.5_

  - [x] 6.6 Implement `RatingDisplay` component
    - Build 3 variants: Compact (numeric only), Expanded (score + count), Stars (filled/unfilled icons out of 5.0)
    - _Requirements: 7.6_

  - [x] 6.7 Write property tests for domain components
    - **Property 9: Empty State Coverage** — verify all list/data-driven components render branded empty state with icon, title, description, and CTA when applicable
    - **Property 10: Loading State Coverage** — verify skeleton loaders display during fetch, never showing stale/undefined content
    - **Validates: Requirements 7.7, 7.8, 11.1, 12.1**

  - [x] 6.8 Write unit tests for domain components
    - Test VendorCard variant rendering and data display
    - Test EscrowProgressBar milestone proportions
    - Test AvailabilityCalendar date state coloring
    - _Requirements: 7.1–7.6_

- [x] 7. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Implement navigation and layout system
  - [x] 8.1 Implement `GomandapAppShell` and `GomandapScaffold`
    - Create app shell that wraps each app with appropriate navigation pattern
    - Admin: side drawer + top bar
    - Vendor: bottom navigation (5 tabs)
    - Client: bottom navigation (4 tabs) + contextual sheets
    - _Requirements: 8.2, 8.3, 8.4_

  - [x] 8.2 Implement navigation graph connectivity and back navigation
    - Ensure every screen has a defined back-navigation path to root
    - Root screens show exit confirmation or exit app
    - Implement deep-link parsing and route generation
    - _Requirements: 8.1_

  - [x] 8.3 Implement auth/onboarding navigation bar hiding
    - Hide bottom nav and side drawer on auth/onboarding screens
    - Show only minimal top bar with back/close affordance
    - _Requirements: 8.5_

  - [x] 8.4 Implement `GomandapBottomSheet` wrapper
    - Support visibility toggle, dismiss callback, optional title
    - Use for contextual actions in Client app detail screens
    - _Requirements: 8.4_

  - [x] 8.5 Implement scroll behaviors and responsive layout
    - Support Static, Scroll, and NestedScroll behaviors per screen config
    - Ensure no overflow/clipping on 320dp–412dp width at font scale 0.8–1.4
    - Use spacing tokens for non-overlapping layouts
    - Truncate single-line text with ellipsis, wrap multi-line within bounds
    - _Requirements: 9.1, 9.2, 9.3, 9.4_

  - [x] 8.6 Write property tests for navigation system
    - **Property 4: Navigation Graph Connectivity** — verify all screens have back-navigation path to root
    - **Property 13: Auth Screen Navigation Bar Hiding** — verify bottom nav hidden on auth/onboarding screens
    - **Validates: Requirements 8.1, 8.5**

  - [x] 8.7 Write property tests for responsive layout
    - **Property 7: Responsive Layout Integrity** — verify no overflow/clipping at 320dp–412dp with spacing tokens
    - **Validates: Requirements 9.1, 9.3**

- [x] 9. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. Implement loading, error, and refresh handling
  - [x] 10.1 Implement loading state handling in screens
    - Display skeleton loader for first-time fetch (no cache)
    - Display non-intrusive indicator when cached content available
    - Hide unfetched content regions with skeleton placeholders
    - Transition to error state after 30-second timeout
    - _Requirements: 12.1, 12.2, 12.3, 12.5_

  - [x] 10.2 Implement pull-to-refresh behavior
    - Show progress indicator at top while retaining existing content
    - Preserve content visibility during refresh
    - _Requirements: 12.4_

  - [x] 10.3 Implement network error handling and retry
    - Display inline error banner with retry action
    - Preserve last-known data with stale indicator
    - Implement exponential backoff: 1s start, double per attempt, max 3 retries
    - _Requirements: 13.1, 13.2, 13.8_

  - [x] 10.4 Implement authentication token refresh flow
    - Attempt transparent token refresh without interrupting user
    - On refresh failure: show session expired bottom sheet, redirect to login with preserved nav state
    - _Requirements: 13.3, 13.4_

  - [x] 10.5 Implement form error handling
    - Display inline field-level errors and scroll to first error
    - Preserve form data on submission failure
    - Show retry action on network/server submission errors
    - _Requirements: 13.5, 13.6, 13.7_

  - [x] 10.6 Write property tests for loading and refresh states
    - **Property 15: Refresh State Content Preservation** — verify existing content remains visible during refresh
    - **Property 11: Form Validation Feedback** — verify error clearing in real-time and scroll-to-first-error
    - **Validates: Requirements 12.3, 12.4, 13.5, 13.6**

- [x] 11. Implement security features
  - [x] 11.1 Implement sensitive data masking in Admin app
    - Mask escrow amounts and bank details (show last 4 chars, bullet characters for rest)
    - Reveal on explicit tap, auto-re-mask after 30s or on navigation away
    - _Requirements: 14.1, 14.5_

  - [x] 11.2 Implement FLAG_SECURE for sensitive screens
    - Set FLAG_SECURE on screens displaying vendor financial data or contact details
    - Prevent screenshots and screen recording on those screens
    - _Requirements: 14.2_

  - [x] 11.3 Implement input sanitization for WebView rendering
    - Escape HTML special characters (<, >, &, quotes) in user-supplied text before WebView display
    - _Requirements: 14.3_

  - [x] 11.4 Implement optional biometric lock for Admin app
    - Activate biometric prompt when app returns to foreground after 30s+ background
    - Make biometric lock optional (user setting)
    - _Requirements: 14.4_

  - [x] 11.5 Write property tests for input sanitization
    - **Property 12: Input Sanitization** — verify malicious content (script tags, SQL patterns, HTML entities) is sanitized before display
    - **Validates: Requirement 14.3**

- [x] 12. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 13. Implement performance optimizations
  - [x] 13.1 Implement lazy loading with stable keys for all list screens
    - Use LazyColumn/LazyRow with unique keys derived from item identifiers
    - Minimize recompositions with `remember`, `derivedStateOf`, stable data classes
    - _Requirements: 15.1_

  - [x] 13.2 Implement async image loading with caching
    - Integrate Coil for image loading with memory/disk cache
    - Display placeholder shimmer until image loads or fails
    - _Requirements: 15.2_

  - [x] 13.3 Implement splash screen with SplashScreen API
    - Use Android 12+ SplashScreen API with vector drawable
    - Implement themed launch activity fallback for Android < 12
    - Target first interactive frame within 1500ms on mid-range device
    - _Requirements: 15.4, 15.5, 15.6_

  - [x] 13.4 Implement animation performance guardrails
    - Use Material 3 motion curves, durations 100ms–500ms
    - Drop intermediate frames if exceeding 16ms budget, complete at end-state
    - Support animation disable via ThemeConfig (skip decorative, preserve state-change)
    - _Requirements: 10.1, 10.2, 10.4, 10.5_

- [x] 14. Implement cross-platform web token parity
  - [x] 14.1 Port design tokens to CSS custom properties / Tailwind config
    - Express all color, typography, spacing, elevation, and shape tokens as CSS custom properties
    - Ensure numerically identical values to native Android tokens
    - Document any deviations where CSS has no direct equivalent
    - _Requirements: 16.1, 16.2, 16.4_

  - [x] 14.2 Provide brand assets in web formats
    - Export logo as SVG for web
    - Export favicon/PWA icons at 16px, 32px, 180px, 512px PNG
    - Use identical source artwork across all platforms
    - _Requirements: 16.3_

  - [x] 14.3 Write property tests for cross-platform token consistency
    - **Property 6: Cross-Platform Token Consistency** — verify token values resolve identically across native and web
    - **Validates: Requirements 2.3, 16.2**

- [x] 15. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation between phases
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The implementation uses Kotlin/Jetpack Compose for native apps and CSS/Tailwind for web parity
- All components must reference `GomandapTokens` exclusively — no hardcoded visual values

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2", "1.4"] },
    { "id": 2, "tasks": ["1.3", "1.5"] },
    { "id": 3, "tasks": ["3.1", "3.2", "3.3", "3.4", "5.1"] },
    { "id": 4, "tasks": ["3.5", "3.6", "3.7", "3.8", "5.2"] },
    { "id": 5, "tasks": ["3.9", "3.10", "5.3", "5.4"] },
    { "id": 6, "tasks": ["6.1", "6.2", "6.3", "6.4", "6.5", "6.6"] },
    { "id": 7, "tasks": ["6.7", "6.8"] },
    { "id": 8, "tasks": ["8.1", "8.2", "8.3", "8.4", "8.5"] },
    { "id": 9, "tasks": ["8.6", "8.7"] },
    { "id": 10, "tasks": ["10.1", "10.2", "10.3", "10.4", "10.5"] },
    { "id": 11, "tasks": ["10.6", "11.1", "11.2", "11.3", "11.4"] },
    { "id": 12, "tasks": ["11.5", "13.1", "13.2", "13.3", "13.4"] },
    { "id": 13, "tasks": ["14.1", "14.2"] },
    { "id": 14, "tasks": ["14.3"] }
  ]
}
```
