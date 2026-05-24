# Requirements Document

## Introduction

This document formalizes the requirements for the GoMandap UI/UX Redesign & Branding Overhaul. The redesign establishes a unified, premium visual identity across the Admin, Vendor, and Client applications with a shared design token system, consistent component library, and streamlined user experiences following the "Luxury Simplicity" philosophy. The platform uses Jetpack Compose (Android/Kotlin) for native apps and Next.js for web portals.

## Glossary

- **Design_Token_System**: The centralized collection of color, typography, spacing, elevation, and shape values that serve as the single source of truth for all visual decisions across all apps.
- **Component_Library**: The set of reusable Jetpack Compose UI components (buttons, cards, inputs, badges, navigation) that form the building blocks of all screens.
- **Brand_Identity_System**: The visual identity assets including logo, favicon, app icons, and splash screens used across all touchpoints.
- **Admin_App**: The Jetpack Compose Android application used by GoMandap administrators for vendor management, booking oversight, CRM, and analytics.
- **Vendor_App**: The Jetpack Compose Android application used by vendors to manage their profiles, bookings, earnings, and availability.
- **Client_App**: The Jetpack Compose Android and Next.js web application used by clients to discover vendors, make bookings, and track escrow payments.
- **WCAG_AA**: Web Content Accessibility Guidelines level AA, requiring minimum contrast ratios of 4.5:1 for normal text and 3:1 for large text and UI components.
- **Design_Tokens**: Named values (colors, spacing, typography, elevation, shapes) defined in the GomandapTokens object that all UI components reference.
- **Component_State**: The data model representing the current state of a UI component (loading, error, empty, refreshing, idle).
- **Touch_Target**: The interactive area of a UI element that responds to user taps, measured in density-independent pixels (dp).
- **Skeleton_Loader**: A placeholder UI element that mimics the shape of content while data is being fetched.
- **Empty_State**: A branded illustration with contextual message displayed when a list or data-driven screen has no content.
- **Theme_Provider**: The GomandapTheme composable that initializes Material 3 theming with the design token values.
- **Navigation_System**: The routing and screen transition architecture that defines how users move between screens within each app.

## Requirements

### Requirement 1: Brand Identity Consistency

**User Story:** As a platform stakeholder, I want a consistent brand identity across all apps and platforms, so that users recognize and trust GoMandap regardless of which app they use.

#### Acceptance Criteria

1. THE Brand_Identity_System SHALL provide a full logo wordmark, standalone icon, and monochrome variant for all rendering contexts
2. WHEN the app icon is rendered at any size from 16px to 512px, THE Brand_Identity_System SHALL maintain all distinguishing visual elements (GoMandap logo shape and brand color) without pixelation or clipping at each size
3. WHEN the app icon is rendered at a size below 48px, THE Brand_Identity_System SHALL use the standalone icon variant instead of the full wordmark
4. THE Brand_Identity_System SHALL render the logo with a minimum contrast ratio of 3:1 against both light and dark backgrounds by using the designated light-background and dark-background logo variants respectively
5. WHEN the Admin_App, Vendor_App, or Client_App launches, THE Brand_Identity_System SHALL display the GoMandap icon splash animation lasting between 800ms and 1500ms before transitioning to the first screen
6. IF the splash animation asset fails to load, THEN THE Brand_Identity_System SHALL display a static GoMandap icon for 1000ms and proceed to the first screen without blocking app launch

### Requirement 2: Design Token System Integrity

**User Story:** As a developer, I want a single source of truth for all visual values, so that I can maintain consistency and make theme changes in one place.

#### Acceptance Criteria

1. THE Design_Token_System SHALL define all color, typography, spacing, elevation, and shape values used across all three apps as named tokens within a single shared module
2. WHEN a screen composable renders any visual element, THE Design_Token_System SHALL be the sole source of color, typography, spacing, and shape values with no hardcoded literal values (hex colors, dp literals, sp literals) permitted in composable functions
3. WHEN the same Design_Token is referenced in the Admin_App, Vendor_App, and Client_App, THE Design_Token_System SHALL resolve to the same color, dimension, or typography value on the same device
4. THE Design_Token_System SHALL define a font scale range between 0.8 and 1.4 inclusive with a minimum step increment of 0.1
5. IF a font scale value outside the range 0.8 to 1.4 is provided, THEN THE Theme_Provider SHALL reject the value, apply the default scale of 1.0, and log a warning indicating the invalid value was ignored
6. IF a composable references a Design_Token that is not defined in the Design_Token_System, THEN THE Theme_Provider SHALL fail at compile time or throw an IllegalStateException at initialization preventing the screen from rendering with undefined values

### Requirement 3: Color Accessibility Compliance

**User Story:** As a user with visual impairments, I want sufficient color contrast in all text and UI elements, so that I can read and interact with the app comfortably.

#### Acceptance Criteria

1. THE Theme_Provider SHALL ensure that every text-background color pairing defined in the Design_Token_System achieves a contrast ratio of at least 4.5:1 for normal text (below 16sp) in both light and dark theme configurations
2. THE Theme_Provider SHALL ensure that every large text (16sp and above) and non-decorative UI component (icons, borders, focus indicators, toggle tracks) color pairing defined in the Design_Token_System achieves a contrast ratio of at least 3:1 in both light and dark theme configurations
3. THE Design_Token_System SHALL define for each semantic color (error, warning, info, success) a dedicated on-color token for foreground content (text and icons) that achieves a contrast ratio of at least 4.5:1 against the semantic color background
4. IF a color token pairing defined in the Design_Token_System fails to meet the required WCAG_AA contrast ratio during build-time validation, THEN THE Design_Token_System SHALL report the non-compliant pairing and prevent compilation

### Requirement 4: Touch Target Accessibility

**User Story:** As a mobile user, I want all interactive elements to be easy to tap, so that I can navigate the app without frustration or mis-taps.

#### Acceptance Criteria

1. THE Component_Library SHALL render all interactive elements (buttons, cards, icons, toggles, checkboxes, radio buttons, sliders, dropdown triggers, and text links) with a minimum touch target of 48dp by 48dp regardless of visual size
2. IF an interactive element has a visual size smaller than 48dp in either dimension, THEN THE Component_Library SHALL extend the touch target area to meet the 48dp minimum without shifting adjacent elements or altering visible component dimensions
3. WHEN two or more interactive elements are placed adjacent to each other, THE Component_Library SHALL maintain a minimum spacing of 8dp between their touch target boundaries to prevent overlapping hit areas

### Requirement 5: Core Component Library

**User Story:** As a developer, I want a reusable component library with consistent behavior, so that I can build screens quickly while maintaining design quality.

#### Acceptance Criteria

1. THE Component_Library SHALL provide button components in five variants: Primary, Secondary, Outline, Ghost, and Danger
2. THE Component_Library SHALL provide button components in three sizes: Small (height 32dp, labelSmall typography), Medium (height 40dp, labelLarge typography), and Large (height 48dp, titleSmall typography)
3. THE Component_Library SHALL provide card components in four variants: Elevated, Outlined, Filled, and Glass
4. WHEN a button is in loading state, THE Component_Library SHALL replace the button label with a circular progress indicator, disable tap interaction, and reduce the button opacity to indicate the non-interactive state
5. IF a button is in disabled state and not loading, THEN THE Component_Library SHALL reduce the button opacity, disable tap interaction, and prevent the button from receiving focus
6. WHEN a text field has an error, THE Component_Library SHALL display the error message (maximum 120 characters, truncated with ellipsis if exceeded) below the field using the Design_Token_System error color with a 1dp border highlight on the field
7. THE Component_Library SHALL provide badge components in six variants: Default, Success, Warning, Error, Info, and Gold
8. THE Component_Library SHALL provide a bottom navigation component that accepts between 3 and 5 navigation items (each with icon and label) and reports selection changes via a callback with the selected item index
9. THE Component_Library SHALL provide a top app bar component supporting a title (maximum 1 line, truncated with ellipsis), optional subtitle (maximum 1 line), optional back button, and up to 3 action slots
10. WHEN button text exceeds the available width within the button, THE Component_Library SHALL truncate the text with an ellipsis and preserve the button's defined size constraints

### Requirement 6: Component State Management

**User Story:** As a developer, I want clear state management rules for components, so that the UI never shows contradictory or undefined states.

#### Acceptance Criteria

1. THE Component_State model SHALL enforce that isLoading and isError cannot both be true simultaneously
2. IF isError is true, THEN THE Component_State model SHALL require errorMessage to be a non-null string with a minimum length of 1 character
3. WHILE isLoading is true, THE Component_State model SHALL not expose isEmpty to consumers and SHALL not render empty-state UI
4. THE Component_State model SHALL enforce state transitions following the permitted paths: Idle to Loading, Loading to Success, Loading to Error, Error to Loading (retry), and Success to Loading (refresh)
5. IF a state transition is attempted that does not match a permitted path, THEN THE Component_State model SHALL reject the transition and retain the current state unchanged
6. THE Component_State model SHALL initialize in the Idle state with isLoading false, isError false, errorMessage null, and isEmpty not evaluated

### Requirement 7: Domain-Specific Components

**User Story:** As a developer, I want pre-built domain components for vendor cards, booking tiles, and escrow indicators, so that complex domain UI patterns are consistent and reusable.

#### Acceptance Criteria

1. THE Component_Library SHALL provide a VendorCard component in four variants: Standard (name, locality, base price, rating, cover photo), Compact (name, rating, cover photo), Featured (full details with verified badge and fast-filling indicator), and AdminReview (all Standard fields plus approval status and admin notes)
2. THE Component_Library SHALL provide a BookingStatusCard component that displays vendor name, event date, booking status, and total amount, with an optional embedded EscrowProgressBar showing milestone completion
3. THE Component_Library SHALL provide an EscrowProgressBar component that visualizes each milestone as a segmented bar where each segment represents one milestone's proportion of the total amount, color-coded by status: held, released, or frozen
4. THE Component_Library SHALL provide a StatCard component displaying a title (maximum 40 characters), a numeric value, an optional trend direction (up, down, or neutral) with corresponding directional icon, and a configurable accent color from the Design_Token_System
5. THE Component_Library SHALL provide an AvailabilityCalendar component that visually distinguishes three date states using distinct background colors from the Design_Token_System: available, booked, and high-demand (defined as dates with 80% or more of vendor capacity reserved)
6. THE Component_Library SHALL provide a RatingDisplay component in three variants: Compact (numeric score only), Expanded (numeric score with review count), and Stars (filled and unfilled star icons representing the rating out of 5.0)
7. WHEN a domain component is in loading state, THE Component_Library SHALL display a skeleton loader that replicates the component's layout dimensions and element positions using placeholder shapes
8. WHEN a domain component has no data, THE Component_Library SHALL display an empty state containing an icon, a title describing the missing data type, and a description suggesting a next action relevant to that component's domain

### Requirement 8: Navigation System

**User Story:** As a user, I want consistent and predictable navigation, so that I always know where I am and how to get back.

#### Acceptance Criteria

1. THE Navigation_System SHALL provide a defined back-navigation path for every reachable screen such that pressing the system back button or a back affordance returns the user to the previous screen, and root-level screens SHALL exit the app or show an exit confirmation rather than creating a dead end
2. WHEN the Admin_App is active, THE Navigation_System SHALL use a side drawer combined with a top bar layout with the drawer providing access to all top-level sections and the top bar displaying the current section title and contextual actions
3. WHEN the Vendor_App is active, THE Navigation_System SHALL use a bottom navigation bar with five tabs: Dashboard, Bookings, Earnings, Calendar, and Profile
4. WHEN the Client_App is active, THE Navigation_System SHALL use a bottom navigation bar with four tabs: Home, Search, Bookings, and Profile, plus contextual bottom sheets triggered by actions within detail screens
5. WHILE a user is on an authentication or onboarding screen, THE Navigation_System SHALL hide the bottom navigation bar and the side drawer, displaying only a minimal top bar with a back or close affordance
6. WHEN a user navigates to a detail screen in the Client_App, THE Navigation_System SHALL use a collapsing top bar that transitions from expanded to collapsed state when the user scrolls down by 56dp or more
7. WHILE any app is active, THE Navigation_System SHALL visually indicate the currently selected tab or drawer item so the user can identify their location within the app at all times
8. WHEN a user taps a bottom navigation tab that is already selected, THE Navigation_System SHALL scroll the current tab content to the top or reset the tab to its root screen if the user has navigated deeper within that tab

### Requirement 9: Responsive Layout

**User Story:** As a user with various Android devices, I want the app to display correctly on my screen, so that no content is cut off or overlapping.

#### Acceptance Criteria

1. THE Component_Library SHALL render all screens without content overflow or clipping on devices from 320dp to 412dp width at any font scale between 0.8 and 1.4
2. WHEN content exceeds the available viewport height, THE Navigation_System SHALL enable scrolling behavior matching the screen's configured ScrollBehavior value (Static for fixed-height screens, Scroll for single-axis scrollable screens, or NestedScroll for screens with independently scrollable child regions)
3. THE Component_Library SHALL use the defined spacing tokens to produce non-overlapping layouts and SHALL truncate single-line text with an ellipsis when it exceeds its container width, or wrap multi-line text within container bounds
4. WHEN a screen is rendered at 320dp width with font scale 1.4, THE Component_Library SHALL maintain all content visible through scrolling or text truncation with no horizontal overflow

### Requirement 10: Animation and Performance

**User Story:** As a user on a mid-range device, I want smooth animations and transitions, so that the app feels responsive and premium.

#### Acceptance Criteria

1. THE Component_Library SHALL render all animations and transitions within a 16ms frame budget to maintain 60fps on devices with 4GB RAM or less and mid-tier processors (Snapdragon 600-series equivalent or below)
2. THE Component_Library SHALL use Material 3 motion curves for all component animations with individual animation durations between 100ms and 500ms
3. WHEN haptic feedback is enabled in ThemeConfig, THE Component_Library SHALL provide haptic feedback on button presses, toggle changes, confirmation actions, and destructive action triggers
4. WHEN animations are disabled in ThemeConfig, THE Component_Library SHALL skip all decorative animations (hover effects, entrance fades, micro-interactions) while preserving state-change animations that communicate data transitions (loading to loaded, screen entry/exit, and component visibility changes)
5. IF an animation frame exceeds the 16ms budget, THEN THE Component_Library SHALL drop intermediate frames and complete the animation at the target end-state rather than blocking the UI thread

### Requirement 11: Empty State Handling

**User Story:** As a user, I want to see helpful guidance when there is no data, so that I understand what to do next rather than seeing a blank screen.

#### Acceptance Criteria

1. WHEN a list or data-driven screen has no content to display, THE Component_Library SHALL render an Empty_State composable displaying an icon, a title of no more than 60 characters, and a description of no more than 150 characters
2. IF an actionable next step is configured for the empty state, THEN THE Component_Library SHALL render a call-to-action button with the supplied label and action below the description
3. IF no actionable next step is configured for the empty state, THEN THE Component_Library SHALL render the empty state without a call-to-action button
4. WHEN a search returns zero results, THE Component_Library SHALL display the empty state with at least one alternative action presented as a tappable element, such as clearing active filters or browsing all items
5. WHEN an empty state is displayed, THE Component_Library SHALL ensure the icon has a content description for accessibility and all text meets the WCAG_AA contrast requirements defined in the Design_Token_System

### Requirement 12: Loading State Handling

**User Story:** As a user, I want visual feedback while data is loading, so that I know the app is working and not frozen.

#### Acceptance Criteria

1. WHEN a screen fetches remote data for the first time with no cached content available, THE Component_Library SHALL display a skeleton loader that matches the expected content layout shape until data arrives or a timeout of 30 seconds elapses
2. WHEN a screen fetches remote data and cached content is available, THE Component_Library SHALL display a non-intrusive loading indicator (such as a progress bar or spinner overlay) without replacing the cached content
3. WHILE a data fetch is in progress, THE Component_Library SHALL hide any content regions that have not yet received data and display the corresponding skeleton placeholder in their place, preventing null or placeholder text from appearing
4. WHEN a data refresh is triggered by user action (pull-to-refresh or refresh button), THE Component_Library SHALL display a visible progress indicator at the top of the content area while retaining all existing content below it
5. IF a data fetch does not complete within 30 seconds, THEN THE Component_Library SHALL transition from loading state to error state and display a retry action

### Requirement 13: Error Handling and Recovery

**User Story:** As a user, I want clear error messages and recovery options, so that I can resolve issues without losing my progress.

#### Acceptance Criteria

1. WHEN a network failure occurs during an API call, THE Client_App SHALL display an inline error banner with a retry action and preserve last-known data with a stale indicator
2. WHEN a network failure occurs, THE Client_App SHALL attempt automatic retry with exponential backoff starting at 1 second, doubling per attempt, up to a maximum of 3 retry attempts before displaying the error banner for manual intervention
3. WHEN an authentication token expires during an active session, THE Client_App SHALL attempt a token refresh without interrupting user interaction or displaying loading UI
4. IF the token refresh fails, THEN THE Client_App SHALL display a session expired bottom sheet that does not block underlying content until acknowledged, and redirect to login with preserved navigation state after user acknowledgment
5. WHEN a form validation failure occurs, THE Component_Library SHALL display inline field-level error messages below each invalid field and scroll to the first error field
6. WHILE a user corrects an invalid form field, THE Component_Library SHALL clear the field error within 300ms of the input satisfying the validation rule
7. IF a form submission fails due to a network or server error, THEN THE Client_App SHALL preserve all user-entered form data and display an error message indicating the submission failed with a retry action
8. IF an API call returns a server error response, THEN THE Client_App SHALL display an inline error message indicating the operation could not be completed and provide a retry action

### Requirement 14: Security and Data Protection

**User Story:** As a platform administrator, I want sensitive data protected in the UI, so that financial and personal information is not inadvertently exposed.

#### Acceptance Criteria

1. THE Admin_App SHALL mask escrow amounts and bank details (bankAccountNumber, bankIfscCode, upiId) by default, displaying only the last 4 characters with the remainder replaced by bullet characters, and SHALL reveal the full value only upon explicit user tap on the masked field
2. WHEN a screen displays vendor financial data (bankAccountNumber, bankIfscCode, upiId, escrow amounts) or contact details (mobileNumber, emailId, whatsAppNumber), THE Admin_App SHALL set FLAG_SECURE on that screen's window to prevent screenshots and screen recording
3. THE Component_Library SHALL encode all user-supplied text inputs by escaping HTML special characters (less-than, greater-than, ampersand, quotes) before rendering in WebView components to prevent script injection
4. WHERE biometric authentication is available, THE Admin_App SHALL offer optional biometric lock that activates when the app returns to foreground after being backgrounded for 30 seconds or more
5. WHEN a masked field is revealed by user tap, THE Admin_App SHALL automatically re-mask the field after 30 seconds of no interaction or when the user navigates away from the screen, whichever occurs first

### Requirement 15: Performance Optimization

**User Story:** As a user, I want the app to load quickly and scroll smoothly, so that my experience feels fast and responsive.

#### Acceptance Criteria

1. THE Component_Library SHALL use lazy loading (LazyColumn/LazyRow) with stable, unique keys derived from item identifiers for all list screens to prevent unnecessary recompositions during scrolling
2. THE Client_App SHALL use asynchronous image loading with memory and disk caching and display a placeholder shimmer animation until the image is fully loaded or a loading failure occurs
3. THE Theme_Provider SHALL pre-compute all token values at app startup before the first frame is rendered to avoid runtime color calculations
4. THE Admin_App SHALL use the Android 12+ SplashScreen API with a vector drawable, displaying the branded splash within the first rendered frame of a cold start
5. IF the device runs an Android version below 12, THEN THE Admin_App SHALL display a themed launch activity with the same vector drawable branding as a fallback
6. WHEN a cold start is initiated, THE Client_App, Vendor_App, and Admin_App SHALL render the first interactive frame within 1500 milliseconds on a mid-range device (as defined by Android vitals baseline)

### Requirement 16: Cross-Platform Design Parity

**User Story:** As a brand manager, I want the web portals to match the native app branding, so that the GoMandap experience is consistent regardless of platform.

#### Acceptance Criteria

1. WHEN the design tokens are ported to the web platform, THE Design_Token_System SHALL express all color, typography, spacing, elevation, and shape token categories as CSS custom properties or Tailwind configuration values using numerically identical values to the native Android tokens
2. THE Client_App web portal SHALL reference the same color hex values, typography scale ratios, and spacing values in pixels as the native Android Client_App, with no hardcoded overrides permitted outside the token system
3. THE Brand_Identity_System SHALL provide the logo, favicon, and app icons in all required platform formats (SVG for web, PNG at 16px, 32px, 180px, and 512px for favicons and PWA icons) using identical source artwork across all native and web platforms
4. IF a design token defined in the native Android token set has no supported CSS equivalent on the web platform, THEN THE Design_Token_System SHALL map it to the closest CSS property that preserves the intended visual effect and document the deviation
5. WHEN a brand manager compares any screen of the Client_App web portal against the same screen on the native Android Client_App, THE Design_Token_System SHALL produce no difference in color values, font family selection, font size ratios, or spacing measurements as verified by token value inspection
