# GoMandap Client Panel — Ultimate Master UI/UX Specification
## Page-by-Page Blueprints · Modern Glassmorphic Design Systems · Milestone-Based Escrow Interactions

This document details the comprehensive UI/UX specifications, layouts, visual frameworks, and interactive features across the entire **GoMandap Client Panel**. Built on the philosophy of *Luxury Simplicity*, GoMandap blends rich visual aesthetics (champagne gold, royal navy, emerald green) with smooth custom spring physics and compact, high-density layouts.

---

## 🎨 1. Core Visual Tokens & Design System

To ensure a cohesive and premium look across all pages, the client panel uses a unified glassmorphic theme and tight spatial layout constraints:

*   **Primary Palette**:
    *   `Royal Navy` (`#0F172A`): Core backgrounds, headers, and primary text colors.
    *   `Champagne Gold` (`#DFBA73` → `#C59A48`): Action buttons, selection highlights, active outlines, premium tags.
    *   `Emerald Green` (`#10B981`): Verification badges, success states, milestone releases.
    *   `Slate Gray` (`#64748B`): Secondary text, captions, inactive states.
    *   `Pearl White` (`#F8FAFC`): Background blocks, subtle sheet backings, clean separators.
*   **Aesthetic Rules**:
    *   **3D Glassmorphism**: Floating panels must utilize `BackdropFilter` with `ImageFilters.blur(sigmaX: 8, sigmaY: 8)`, white borders with `0.2` opacity, and custom shadows with a gold or slate accent under-glow.
    *   **High-Density Spacing**: Margins and paddings are kept strictly between `8px` and `16px`. Whitespace is minimized to provide maximum information scanning at first glance.
    *   **Spring Physics**: Rotation, scaling, card expands, and bottom-sheet spring transitions must use spring parameters (Tension: `180`, Friction: `0.72`) to create organic visual feedback.

---

## 📱 2. Page-by-Page Interactive Blueprint

```
 ┌─────────────────┐
 │ 1. Login Page   │ ───> Credential Inputs & Full Name (Personalized Entry)
 └────────┬────────┘
          │
          ▼
 ┌─────────────────┐
 │ 2. Onboarding   │ ───> 4-Stage Calibration (Languages, Events, GPS, Budgets)
 └────────┬────────┘
          │
          ▼
 ┌─────────────────┐
 │ 3. Home Screen  │ ───> Parallax Headers · Sorted Glass Grids · Trust Shelf · SVG Ads
 └────────┬────────┘
          │
          ├─────────────────────────┐
          ▼                         ▼
 ┌─────────────────┐       ┌─────────────────┐
 │ 4. Search Feed  │       │ 5. Detail View  │ ───> Slider Galleries · Date Calendars
 └────────┬────────┘       └────────┬────────┘
          │                         │
          ├─────────────────────────┘
          ▼
 ┌─────────────────┐
 │ 6. Checkout     │ ───> Multi-Vendor Cart · Customized Plates · Milestone Escrow
 └────────┬────────┘
          │
          ▼
 ┌─────────────────┐
 │ 7. Escrow Track │ ───> Active vertical timeline payouts & lock releases
 └─────────────────┘
```

### 🔐 Stage 1: Premium Personalized Login
*   **Layout**: Full-screen slate layout with an elevated, glassmorphic credentials card floating in the center.
*   **Features**:
    *   **Full Name Field**: Sleek, gold-bordered text input field for personalization.
    *   **Phone OTP Validation**: Responsive character counters and instant keyboard slide-ins.
    *   **Dual-Path Entry**: Solid Champagne Gold button for verification code submission, and a frosted "Browse as Guest" text button bypassing authentication.
*   **Micro-interactions**: Inputs glow with a thin gold border when active; error state triggers a subtle elastic horizontal shake.

### 🌟 Stage 2: 4-Stage Onboarding Calibration Wizard
*   **Layout**: Full-bleed PageView wizard right after authentication, with a top stepper indicator showing progress blocks.
*   **Stages**:
    1.  **Animated Language Selection**: 7 major Indian languages (*English, Telugu, Hindi, Tamil, Kannada, Malayalam, Bengali*) rendered inside floating glass chips. Tapping scales the chip (`1.04x`) and locks a Champagne Gold glowing boundary.
    2.  **Indian Regional Event Types**: Selection grids covering regional celebrations (*Muhurtham/Weddings, Sangeet/Reception, Birthdays, Corporate Gatherings*) using custom-colored illustration icons.
    3.  **GPS Radar Geolocator**: Concentric-circle expanding radar animation using native `CustomPaint`. Automatically triggers satellite geofencing scans and resolves matching local contexts (e.g. *Jubilee Hills, Hyderabad*), with a manual search dropdown fallback.
    4.  **Pax & Budget Calibrations**: Compact horizontal sliders allowing guest counts (100 - 3000 Pax) and lakh budgets (1L - 100L) adjustments to pre-filter matching home feed items.

### 🏛 Stage 3: High-Density Home Dashboard
*   **Layout**: Scrollable parallax layout with minimal gaps and structured shelves.
*   **Shelves**:
    1.  **Parallax Hero Banner**: Previews premium trending packages using a 3D horizontal parallax scroll and smooth page indicators.
    2.  **Venue Types Grid**: Premium **3-column grid** right at the top displaying the 3 primary function categories (*Banquet Halls, Kalyana Mandapams, Open Lawns*) styled in floating 3D glass.
    3.  **GoMandap Trust Shelf**: Extremely compact, low-profile horizontal frosted glass row explaining our value propositions (**Milestone Escrow** and **Verified Partners**).
    4.  **Other Services Grid**: Space-saving **4-column grid** displaying the remaining 17 categories.
    5.  **Elite Events Sponsorship Card**: High-fidelity vector SVG ad banner animating domes, sparklers, and silhouette dancers using HSL gradient glows.
    6.  **Parallax City Directory**: Parallax images displaying main metropolitan booking hubs (*Hyderabad, Chennai, Bangalore*) that scroll at `0.65x` speed.

### 🔍 Stage 4: Omni-Search & Deep Polymorphic Filters
*   **Layout**: Sticky glassmorphic search input header with a floating omni-chip bar underneath.
*   **Features**:
    *   **Omni-Filter Chip Row**: Horizontal frosted list of categories that updates search results instantly.
    *   **Deep Polymorphic Filter Sheet**: Bottom-sheet slides up on demand. It dynamically updates options based on the active category:
        *   *Venues*: Renders capacity ranges, amenities checkboxes (AC, parking spots, catering external allowed, lodging rooms), and per-plate pricing sliders.
        *   *Catering*: South/North/Asian cuisines checklist, veg/non-veg switches, minimum plate bookings.
        *   *Services (DJs, Planners, Makeup)*: Standard budget package sliders and specialized checkable sub-service chips.
    *   **Rolling Apply Button**: An animated apply button displaying matching results count with a rolling numbers transition.

### 📷 Stage 5: Immersive Venue & Vendor Details
*   **Layout**: Interactive scroll page with a sticky parallax `SliverAppBar` header image.
*   **Features**:
    *   **Media Gallery Carousel**: Swipeable high-resolution portfolio images + inline custom video player showing a 60-second video introduction.
    *   **3-State Date Availability Calendar**: Interactive calendar grid displaying days in 3 logical booking statuses:
        *   *Green*: Available dates.
        *   *Amber*: Tentative / Fast-filling dates (triggers "fast action required" badges).
        *   *Red*: Fully booked dates.
    *   **Key Trust Panels**:
        *   *"Why Choose Us"*: Audited metrics (years in business, total events hosted, verified platform bookings).
        *   *"Key Insights"*: Extracting high-sentiment review tags (*"Spacious Dining"*, *"Flawless Acoustics"*).
    *   **Specs Accordion**: Sleek, tap-to-expand list items describing precise capacity limitations, parking details, power backups, and cancellation rules.

### 🛒 Stage 6: Multi-Vendor Cart & Milestone Escrow Checkout
*   **Layout**: Dual-pane checkout containing a persistent bottom checkout drawer.
*   **Features**:
    *   **Multi-Vendor Event Cart**: Single checkout to book multiple services (e.g. Venue + Caterer + Decorator) under a unified event profile.
    *   **Real-time Package Customizer**: Expandable steppers inside cards allowing users to adjust guest numbers, custom plate configurations, and booking add-ons with real-time total updates.
    *   **Milestone Escrow Progress Stepper**: 4-stage visual stepper mapping the escrow release schedule:
        1.  *Stage 1 (Dates & Customizer)*: Locks specific bookings.
        2.  *Stage 2 (Locking Deposit)*: Displays 25% holding deposit lock.
        3.  *Stage 3 (Escrow Visualizer)*: Maps milestone releases (25% Initial -> 50% Intermediate -> 25% Final).
        4.  *Stage 4 (Secure Payment)*: Champagne Gold payment gateway triggers showing partner bank lock notifications and a booking success screen.

### 🛡 Stage 7: Escrow Payout & Dispute Tracker
*   **Layout**: Structured vertical dashboard mapping funds security.
*   **Features**:
    *   **Vertical Funds Timeline**: Displays milestones with active locks:
        *   *Locked*: Milestone not yet due.
        *   *Held in Partner Bank*: Funds holding securely.
        *   *Released to Vendor*: Funds cleared to vendor on client authorization.
    *   **Release Payout Button**: Premium emerald-green button requiring user touch authentication to authorize funds release to the vendor on milestone completion.
    *   **Dispute Portal Trigger**: Sleek caution-colored button to hold payments in case of project discrepancies, locking the escrow account for manual platform arbitration.
