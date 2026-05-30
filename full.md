# GoMandap Full Implementation Plan & Feature Blueprint

This document outlines the complete implementation plan, features, and UI/UX improvements for the GoMandap ecosystem (Client, Vendor, and Admin apps). The backend relies on a robust database structure (Supabase/Firebase) with Realtime capabilities, strict Role-Level Security, and an offline-first architecture. 

**Note:** As requested, this plan contains zero AI-driven features. It focuses entirely on a solid, scalable, professional marketplace ecosystem.

---

## 1. UI/UX & Styling Architecture

The goal is to maintain a premium, trustworthy, and culturally resonant aesthetic using the shared `GomandapTokens`.

### 1.1 Core Design Language
*   **Color Palette:**
    *   `Pearl White` (`#F8F9FA`) & `Soft Mist`: Clean, spacious backgrounds.
    *   `Royal Navy` (`#0F172A`): Primary text and luxury accents.
    *   `Champagne Gold` (`#DFBA73`) & `Dark Gold`: Celebratory highlights, icons, and progress bars.
    *   `Emerald Green` (`#10B981`): Trust signals, "Verified" badges, and primary Call-to-Action (CTA) buttons.
*   **Typography:** Professional sans-serif (e.g., Google Fonts' Poppins or Inter) with high readability for detailed specs and legal texts.
*   **Visual Patterns:**
    *   **Glassmorphism:** Used in `glass_card.dart` and `glass_chip.dart` for overlapping UI elements (e.g., sticky action bars over venue images).
    *   **Neumorphism/Soft Shadows:** Subtle elevations to separate content blocks without harsh borders.

### 1.2 UX Improvements
*   **Skeleton Loaders:** Replace all circular spinners with shimmer skeleton loaders (`skeleton_loader.dart`) to reduce perceived wait times.
*   **Micro-Interactions:** Implement `antigravity_bouncy_switch.dart` and fluid Hero transitions between catalog grids and detail pages.
*   **Consistent Shell:** Unified responsive shells (`main_shell.dart`, `vendor_responsive_shell.dart`) ensuring bottom navigation on mobile and side-navigation on tablets/web.

---

## 2. Client App Implementation

The Client App is optimized for discovery, trust-building, and seamless booking.

### 2.1 Core Features
*   **Discovery Home Screen (`home_screen.dart`):**
    *   Auto-playing `hero_carousel.dart` for premium venue advertisements.
    *   `city_parallax_row.dart` for exploring venues by location.
    *   `category_grid.dart` (Banquets, Photography, Decor, Makeup, etc.).
*   **Deep Search & Filtering (`search_screen.dart`):**
    *   `omni_filter_bar.dart` and `deep_filter_sheet.dart` for multi-parameter filtering (Date, Budget, Guest Count, Amenities).
    *   `live_count_apply_button.dart` showing dynamic result counts as filters are adjusted.
*   **Venue/Service Details (`venue_detail_screen.dart`):**
    *   `shoppable_gallery_screen.dart` for high-res portfolio viewing.
    *   `specs_accordion.dart` for granular details (AC capacity, veg/non-veg pricing, decor policies).
    *   `review_panel.dart` for verified customer reviews.
*   **Escrow Checkout Flow (`booking_checkout_screen.dart`):**
    *   100% Protected Escrow Payout Model visualizer (`escrow_visualizer_stage.dart`).
    *   Multi-stage checkout: Availability Check → Package Customizer → Payment.

### 2.2 Client Improvements
*   **Offline Caching:** Cache recently viewed venues and wishlist items locally using `common/lib/data/local/`.
*   **Interactive Maps:** Add a map-view toggle in search results with clustering for venues in dense areas.
*   **Unified Cart:** Persistent cart state (`cart_notifier.dart`) allowing users to book a Venue, Photographer, and Decorator in a single transaction.

---

## 3. Vendor App Implementation

The Vendor App focuses on business management, schedule blocking, and revenue tracking.

### 3.1 Core Features
*   **Strict Onboarding & KYC (`vendor_kyc_screen.dart`):**
    *   Multi-step wizard collecting Business Details, GSTIN, Trade License, and Banking information.
    *   Live status tracking (Pending, Needs Correction, Approved).
*   **Business Dashboard (`vendor_dashboard_screen.dart`):**
    *   Radial progress charts showing booking fulfillment.
    *   Quick stats (`stat_card.dart`): Total Revenue, Pending Escrow, Profile Views, New Leads.
*   **Catalog & Pricing Management (`vendor_service_catalog_screen.dart`):**
    *   Self-serve UI to update package pricing, upload new gallery images to Supabase/R2 storage, and toggle amenities.
*   **Calendar Management (`vendor_calendar_screen.dart`):**
    *   Visual calendar to block out unavailable dates and view upcoming confirmed events.
*   **Escrow Tracking (`vendor_escrow_screen.dart`):**
    *   Transparent ledger showing funds held in Escrow and upcoming disbursement dates (e.g., 20% Booking, 50% Pre-Event, 30% Post-Event).

### 3.2 Vendor Improvements
*   **Push Notifications:** Instant alerts for new booking requests, admin KYC feedback, and escrow releases.
*   **In-App Chat (`vendor_chat_screen.dart`):** Direct messaging with booked clients for coordination, utilizing Supabase Realtime.

---

## 4. Admin App Implementation

The Admin App is a secure, tablet/web-optimized portal for platform moderation and financial oversight.

### 4.1 Core Features
*   **Master Dashboard (`admin_dashboard_screen.dart`):**
    *   High-level platform metrics: Gross Merchandise Value (GMV), Total Active Vendors, User Registrations.
*   **Vendor Approval Pipeline (`admin_vendor_approval_screen.dart`):**
    *   Dedicated queue for reviewing new `vendor_applications`.
    *   UI to view uploaded KYC documents, with the ability to Approve, Reject, or return to vendor with specific `CorrectionNote`s (e.g., "GSTIN format invalid").
*   **Escrow & Disbursement Control (`admin_escrow_disbursement_screen.dart`):**
    *   Monitor all active escrow contracts.
    *   Manual override capabilities for dispute resolution and triggering manual payouts.
*   **User & Content Moderation (`admin_users_screen.dart`):**
    *   Manage client and vendor accounts (suspend, ban, reset passwords).
    *   Review flagged reviews or inappropriate portfolio images.

### 4.2 Admin Improvements
*   **Data Export:** Capability to export financial and user data to CSV/Excel for accounting.
*   **Audit Logs:** A hidden activity log tracking which Admin approved which vendor or authorized which payout.

---

## 5. Database & Architecture (Supabase)

### 5.1 Data Models (`common/lib/domain/models/`)
*   `VendorApplication`: Tracks KYC flow (`status`, `correction_notes`, `kyc_doc_url`).
*   `Vendor` / `CategoryModel`: Live catalog data.
*   `Cart` & `Escrow` / `Milestone`: Financial transaction states.

### 5.2 Supabase Schema & Security
*   **Authentication:** Supabase Auth mapping to the `users` table.
*   **Role-Level Security (RLS) Policies:**
    *   *Clients:* `SELECT` on verified vendors; `ALL` on their own bookings/cart.
    *   *Vendors:* `ALL` on their own profile, catalog, and related bookings.
    *   *Admins:* `ALL` across all tables (enforced via `role = 'admin'` claim).
*   **Realtime Subscriptions:**
    *   Admin dashboard listens to `INSERT` on `vendor_applications`.
    *   Vendor app listens to `UPDATE` on `bookings` (for new leads).
    *   Client app listens to `UPDATE` on `escrow` milestones.
*   **Storage Buckets:**
    *   `public-portfolios`: Open read access, vendor-only write.
    *   `private-kyc`: Read/write restricted to the specific vendor and admins.

### 5.3 Offline-First Repository Pattern
*   Utilize `offline_first_vendor_repository.dart` and `vendor_database.dart` (drift/sqflite) to cache data.
*   If the device loses network, the app falls back to local data, queueing mutations to sync with Supabase once the connection is restored.

---

## 6. Step-by-Step Execution Roadmap

To bring this blueprint to life, here is the phased execution strategy:

### Phase 1: Foundation & Shared Architecture (Weeks 1-2)
- **Goal:** Set up shared packages, themes, and database connections.
- **Tasks:**
  1. Finalize `GomandapTokens` in `common/lib/theme/`. Apply consistently across all three apps.
  2. Implement shared UI components: `glass_card`, `skeleton_loader`, `gomandap_button`.
  3. Initialize Supabase project and run migrations (`supabase/migrations/`).
  4. Implement `offline_first_vendor_repository.dart` using sqflite/drift.

### Phase 2: Vendor App & Admin Moderation Flow (Weeks 3-4)
- **Goal:** Allow vendors to onboard and admins to approve them.
- **Tasks:**
  1. Build the Vendor KYC Wizard (`vendor_kyc_screen.dart`). Capture business details and upload documents to the `private-kyc` bucket.
  2. Build Admin Approval Pipeline (`admin_vendor_approval_screen.dart`). Stream pending applications and implement Approve/Reject/Needs Correction logic.
  3. Implement Vendor Dashboard (`vendor_dashboard_screen.dart`) displaying real-time application status.

### Phase 3: Client App Discovery & Search (Weeks 5-6)
- **Goal:** Allow clients to browse approved vendors and filter effectively.
- **Tasks:**
  1. Build `home_screen.dart` with `hero_carousel` and `category_grid`.
  2. Implement `search_screen.dart` with `omni_filter_bar` and live result counts.
  3. Build `venue_detail_screen.dart` pulling live data from Supabase.
  4. Implement `shoppable_gallery_screen` for high-res portfolio viewing.

### Phase 4: Cart, Escrow, and Booking Flow (Weeks 7-8)
- **Goal:** End-to-end transactional capabilities.
- **Tasks:**
  1. Implement persistent Cart state in the Client App.
  2. Build the Escrow Checkout Flow (`escrow_checkout_sheet.dart`) with the 20/50/30 milestone breakdown visualizer.
  3. Connect payment gateway (e.g., Razorpay/Stripe) to fund the escrow contract.
  4. Build Vendor Escrow Tracker (`vendor_escrow_screen.dart`) to show pending/released funds.

### Phase 5: Polish, Notifications, & Launch (Weeks 9-10)
- **Goal:** Final UX improvements and production readiness.
- **Tasks:**
  1. Integrate Push Notifications via Firebase Cloud Messaging (FCM) mapped to Supabase users.
  2. Build the In-App Chat system (`vendor_chat_screen.dart` & client equivalent) using Supabase Realtime.
  3. Conduct end-to-end QA testing on offline capabilities (e.g., favoriting a venue without internet).
  4. App Store & Play Store deployment preparation.