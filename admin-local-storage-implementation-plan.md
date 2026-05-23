# GoMandap Vendor App Onboarding, Login & Admin Approval Pipeline — Implementation Plan

This updated implementation plan expands the architectural blueprint and visual specifications for the **GoMandap Vendor App (`:vendor`)** native Android module. 

It introduces a premium, high-trust **Vendor Login Screen**, detailed category-specific profile builders supporting **photo/video portfolios and custom metadata inspired by WedMeGood & WeddingBazaar**, and a local **Verification Pipeline** that passes submissions to the **GmAdmin App (`:admin`)** for approval before publishing live to the **GoMandap Client App (`:app`)** storefront.

---

## 🎨 Unified System Pipeline & State Transitions

To preserve the 100% serverless, offline design, all state changes are orchestrated locally in the shared `SharedPreferences` catalog database (`gomandap_catalog_prefs`). 

When a vendor registers and completes their category form, their catalog entry is marked with `approvalStatus = "PENDING_APPROVAL"`. This draft state hides the business from the client app. Once the admin approves the listing in the **GmAdmin App**, the status changes to `APPROVED`, publishing it instantly to the client storefront.

```mermaid
graph TD
    A["[Vendor App] Beautiful Login & Category Setup"] --> B["[Vendor App] Category-Specific Profile Form (Metadata + Media URLs)"]
    B --> C{Vendor Submits for Verification}
    C -->|Draft Submission| D["approvalStatus = 'PENDING_APPROVAL' / isLive = false"]
    D --> E["[GmAdmin App] Pending Approvals Review Screen"]
    E --> F{Admin Inspects Metadata & Media}
    F -->|Request Revisions (Notes)| G["approvalStatus = 'REVISION_REQUESTED' / isLive = false"]
    G -->|Vendor Dashboard Alert| B
    F -->|Verify & Publish Live| H["approvalStatus = 'APPROVED' / isLive = true"]
    H --> I["[GoMandap Client] Active Storefront (Instant Live Listing)"]
```

---

## 🔐 1. Premium Vendor Login Screen (`VendorLoginScreen.kt`)

A visually stunning landing portal using GoMandap's luxury aesthetics (Royal Navy background `#0F172A`, champagne gold borders `#DFBA73`, and soft gold lettering).

### UI/UX Design Elements
*   **Aesthetic Logo Header**: Royal golden seal of GoMandap with fine microcopy: *"India's Premier Wedding Partner Network"*.
*   **Dual Mode Auth Tab**:
    *   **Tab 1: Partner OTP Sign-in** — Quick mobile number input with an instant **"Request Auspicious OTP"** simulated verification system.
    *   **Tab 2: Password Login** — Secure username/password form with tactile feedback.
*   **Dynamic Category Onboarding Portal**: 
    *   For new partners, a **"Join as Verified Partner"** button redirects to a selection flow displaying the 5 core categories (Banquets, Photography, Decor, Catering, Makeup) with micro-icons and brief descriptive labels.
*   **Verification Credentials Section**: Enter GSTIN and FSSAI License numbers (caterers) with live formatting regex.

---

## 🌸 2. Category-Specific Data Models (Inspired by WedMeGood & WeddingBazaar)

Each category is uniquely structured to match the search-filtering needs of couples. Vendors can input distinct technical metrics, package options, portfolio photos, and video links (YouTube/Vimeo URLs).

### I. 🏛️ Banquets & Kalyana Mandapams
*   **Auspicious Metadata**:
    *   `Seating Capacity (Pax)` (Slider: 100 - 3,000)
    *   `Floating Capacity (Pax)` (Slider: 200 - 5,000)
    *   `Veg Plate Price (₹)` & `Non-Veg Plate Price (₹)` (Standard Indian wedding buffet tiers)
    *   `Room Count` (Total guest rooms: e.g., 25) & `Green Rooms` (Bridal changing rooms: e.g., 2)
    *   `Valet Parking Capacity` (Number of cars)
*   **Strict Operational Policies**:
    *   `Decor Policy` (Toggle: In-House Only, Outside Decorators Allowed, Panel-Only)
    *   `Alcohol Policy` (Toggle: Allowed, Forbidden, Outside License Required)
    *   `Music/DJ Policy` (Toggle: Permitted indoors only, Permitted up to 10 PM, 24/7)
*   **Media Gallery Checklist**:
    *   Mandap Centerpiece photo, Grand Entry facade, Dining Hall dining layout, Green Room interiors.
    *   Virtual Tour video URL (Vimeo/YouTube walkthrough).

### II. 📷 Candid Photographers & Videographers
*   **Day Rate Specifications**:
    *   `Candid Photography Day Price (₹)`
    *   `Cinematic Wedding Film Day Price (₹)`
    *   `Traditional Photo & Video Day Price (₹)`
    *   `Pre-Wedding Couple Shoot Price (₹)`
*   **Deliverable Metrics**:
    *   `Delivery Timeframe` (Slider: 2 weeks to 12 weeks)
    *   `Album Details` (Leatherbound coffee table book, wooden box case, hardbound gloss)
    *   `Estimated Deliverables` (Raw images count, edited high-res images count)
*   **Specialty Toggles**:
    *   Drone Coverage (Yes/No), Same-day Edit Teaser (Yes/No), Multi-city travel charges included (Yes/No).
*   **Media Gallery Checklist**:
    *   Portfolio album categorized by event types (*Wedding, Engagement, Haldi/Mehndi, Couple Portraits*).
    *   Vimeo/YouTube Wedding Teaser cinematic video link.

### III. 🌸 Wedding Decorators & Theme Designers
*   **Decor Package Budgeting**:
    *   `Starting Canopy & Stage Decor Package (₹)`
    *   `Premium Royal Mandap Theme Pricing (₹)`
*   **Design Capabilities**:
    *   `Max Stage Width (ft)` (e.g., 40 ft)
    *   `Flower Sourcing` (Toggle: 100% Fresh Local, Exotic Imported, Mixed Faux Premium)
    *   `Lighting Inventory` (Chandeliers count, LED up-lighters, serial warm light bulbs)
    *   `Setup Time Duration` (Hours needed: e.g., 12 hours)
*   **Media Gallery Checklist**:
    *   Before/After transformation split photos.
    *   Specific setups (*Grand Mandap, Flower Archway, Photobooth Stage, Aisle Pathways*).
    *   YouTube reel of active decoration installation.

### IV. 🍽️ Premium Caterers & Gastronomy Partners
*   **Gastronomy Pricing Tiers**:
    *   `Standard Veg Plate Cost (₹)` & `Standard Non-Veg Plate Cost (₹)`
    *   `Deluxe Veg Plate Cost (₹)` & `Deluxe Non-Veg Plate Cost (₹)`
    *   `Minimum Guest Booking Threshold` (e.g., 150 guests)
*   **Kitchen & Menu Specializations**:
    *   `Cuisines Offered` (South Indian Traditional, Royal Awadhi/North Indian, live chat station, Jain Menu, Continental Fusion)
    *   `Service Style` (Standard Buffet, Premium Silverware, Traditional Banana Leaf)
*   **Professional Inclusions**:
    *   Uniformed serving waitstaff (Yes/No), Live Tandoor counters (Yes/No), FSSAI Certified Kitchen number.
*   **Media Gallery Checklist**:
    *   Food presentation spreads, live action counters, uniformed chefs, kitchen sanitization close-ups.
    *   Food service active buffet video link.

### V. 💄 Bridal Makeup Artists & Stylists
*   **Bridal Styling Toggles & Rates**:
    *   `HD Bridal Makeup Rate (₹)`
    *   `Airbrush Bridal Makeup Rate (₹)`
    *   `Guest/Sider Makeup Rate (₹)`
    *   `Saree Pleating & Dupatta Draping Rate (₹)`
    *   `Hair Styling & Premium Extensions Price (₹)`
*   **Styling Policies**:
    *   `Paid Trial Available` (Yes/No, with cost and refundability policy upon booking)
    *   `Travel to Venue` (Does the artist travel to kalyana mandapam/hotel: Yes/No)
*   **Product Safety**:
    *   Brands inventory (MAC, Kryolan, Huda Beauty, Bobbi Brown, NARS).
*   **Media Gallery Checklist**:
    *   Before/After transition shots (high-res closeups of eyes, hairstyle designs, full bridal drape look).
    *   Transformation reel video link.

---

## 🛡️ 3. Admin Review & verification Pipeline (`GmAdmin`)

We will expand the **GmAdmin App (`:admin`)** with a state-of-the-art verification center.

### I. Approvals Queue Screen (`VendorApprovalQueueScreen.kt`)
*   Displays a list of all vendors with `approvalStatus == "PENDING_APPROVAL"`.
*   Displays critical overview badges: `🏛️ BANQUETS`, `FSSAI CHECK REQUIRED`, `₹₹ High-Ticket`.

### II. Detailed Inspection Sheet (`VendorInspectionSheet.kt`)
*   **Side-by-Side Metadata**: Clearly separates base billing, capacity options, and category specifications in a structured comparison grid.
*   **Interactive Media Inspector**: Tapping a photo expands it in a fullscreen modal with high-res details. Video URLs are loaded in an inline WebView player for instant review.
*   **Credentials Check List**: Interactive toggles for:
    *   `[ ] GSTIN Verified`
    *   `[ ] FSSAI Certificate Valid` (for caterers)
    *   `[ ] Standard Pricing Compliance Check`
*   **Action Decision Bar**:
    *   `🔴 Request Revision`: Prompts a text box where the Admin writes notes (e.g., *"Please upload higher resolution photos of the dining hall, the current image is too dark."*). Sets status to `REVISION_REQUESTED`.
    *   `🟢 Verify & Publish`: Sets status to `APPROVED` and `isLive = true`, releasing the profile live to GoMandap Client.

---

## 🌸 4. Client App Storefront Improvements (`GoMandap Client`)

We will update the search lists and details page in the **GoMandap Client App (`:app`)** to accommodate the newly added rich profiles:

*   **Category-Specific Feature Badges**:
    *   Banquets: *"Fits 1,200 Guests"* | Caterers: *"Authentic Banana Leaf"* | Photographers: *"4-Week Delivery"*.
*   **Dynamic Visual Portfolios**:
    *   Adds a high-performance image slider/carousel at the top of the detail pages.
    *   Adds a **"View Cinematic Tour"** button that opens a beautiful overlay video player streaming their YouTube/Vimeo tour.
*   **Trust badging**: Approved vendors display an elegant champagne gold star badge: `⭐ GoMandap Verified Partner`.

---

## 🛠️ Execution & Coding Steps

To complete this expansion, we will follow these exact files modifications:

### Step 1: Shared Models (`:common` Module)
Modify `com.gomandap.common.domain.Vendor` to support the comprehensive media array and status fields:
```kotlin
enum class ApprovalStatus { DRAFT, PENDING_APPROVAL, APPROVED, REVISION_REQUESTED }

data class Vendor(
    val id: String,
    val name: String,
    val category: String,
    val locality: String,
    val approvalStatus: ApprovalStatus = ApprovalStatus.DRAFT,
    val adminNotes: String = "",
    val isLive: Boolean = false,
    val photos: List<String> = emptyList(),
    val videoUrl: String = "",
    // Category-specific expanded fields
    val details: Map<String, String> = emptyMap()
)
```

### Step 2: Vendor Login (`:vendor` Module)
*   **File**: `com.gomandap.vendor.presentation.auth.VendorLoginScreen.kt` **[NEW]**
*   Create a premium login layout that routes to the Onboarding Super-form or Dashboard based on setup state.

### Step 3: Expanded Onboarding (`:vendor` Module)
*   **File**: `com.gomandap.vendor.presentation.onboard.VendorOnboardScreen.kt` **[MODIFY]**
*   Expand each category's Compose step to include FSSAI/GSTIN text fields, media links input boxes, and the specialized metadata fields listed in Section 2.

### Step 4: Admin Verification (`:admin` Module)
*   **File**: `com.gomandap.admin.presentation.approvals.VendorApprovalQueueScreen.kt` **[NEW]**
*   **File**: `com.gomandap.admin.presentation.approvals.VendorInspectionSheet.kt` **[NEW]**
*   Implement the approvals queue and detailed media review sheets to manage status overrides.

### Step 5: Client Storefront Gallery (`:app` Module)
*   **File**: `com.gomandap.app.presentation.detail.VenueDetailScreen.kt` **[MODIFY]**
*   Enhance page layouts to show the verified star badge, the image carousels, and inline YouTube video player overlays.

---

## 🚀 Verification & Testing Plan

### Automated Build Test
*   Run the unified orchestrator script to compile all targets in a single clean pass:
    ```powershell
    powershell.exe -ExecutionPolicy Bypass -File build.ps1 -Clean
    ```

### Manual Verification Flow
1.  **Vendor Sign Up**: Open the **Vendor App**, tap *Join Partner Network*, choose *Banquets*, and input the comprehensive metadata (e.g. `Valet Parking: 150 cars`, `AC: Yes`), add 4 photo URLs, and a YouTube walkthrough link. Tap *Submit for Verification*.
2.  **State Masking Test**: Open the **GoMandap Client App** and confirm that this banquet hall is **NOT** visible in the search feed (since it is pending approval).
3.  **Admin Review**: Open the **GmAdmin App**, navigate to the *Approvals Queue*, open the banquet's detailed inspection sheet, verify the FSSAI/GSTIN entries, inspect the images, and tap *Verify & Publish*.
4.  **Instant Live Sync**: Return to the **GoMandap Client App** and confirm that the venue now appears instantly, showcasing the gold verified badge, the image slider, and plays the tour video in one tap!

---

## 💬 User Feedback Requested

Please review the proposed categories metadata, fields, and pipeline transition designs. Let me know if you would like any adjustments to the specific fields or terminology, or type **Approved** to begin the implementation phase!
