# 🚀 GoMandap — Comprehensive Implementation Plan

> *Transforming GoMandap into a world-class wedding marketplace competing with WeddingBazaar, WedMeGood & Mandap.com*

---

## 📋 Executive Summary

**Current State:** A Flutter monorepo with 3 apps (Client, Vendor, Admin) + 1 shared package. Mock data is pervasive across all layers. The UI/UX is functional but not competitive with industry leaders. The Supabase backend has partial schema but missing critical tables. Cloudflare R2 is wired up but with mock fallbacks. The admin panel has basic functionality but lacks full platform control.

**Target State:** A premium Indian wedding marketplace where:
- **Clients** discover, compare, and book wedding vendors with an inspiring UX
- **Vendors** manage their full business lifecycle (profiles → bookings → payments)
- **Admins** have full control over the platform — UI/UX configuration, vendor lifecycle, escrow, content management — all via a dashboard
- **Zero mock data** — everything flows through Supabase + R2
- **Industry-leading UI/UX** on par with the best wedding platforms

---

## 🧠 Business Model (Derived from Codebase)

```
┌─────────────────────────────────────────────────────────────────┐
│                        GOMANDAP PLATFORM                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐    ┌──────────────┐    ┌───────────────────┐  │
│  │  CLIENT APP  │    │  VENDOR APP  │    │   ADMIN PANEL     │  │
│  │  (Couples)   │    │ (Vendors)    │    │ (GoMandap Team)   │  │
│  ├──────────────┤    ├──────────────┤    ├───────────────────┤  │
│  │ • Browse      │    │ • Profile    │    │ • Vendor Approval │  │
│  │ • Search      │    │ • Catalog    │    │ • Config Mgmt     │  │
│  │ • Compare     │    │ • Bookings   │    │ • Escrow Control  │  │
│  │ • Book        │    │ • Chat       │    │ • User Mgmt       │  │
│  │ • Escrow Pay  │    │ • Escrow     │    │ • Content Mgmt    │  │
│  │ • Reviews     │    │ • Calendar   │    │ • Analytics       │  │
│  └──────┬───────┘    └──────┬───────┘    └────────┬──────────┘  │
│         │                  │                       │            │
│         └──────────────────┼───────────────────────┘            │
│                            │                                    │
│                   ┌────────▼────────┐                           │
│                   │   SUPABASE + R2  │                          │
│                   │   (Postgres DB)  │                          │
│                   │   (Object Store) │                          │
│                   └─────────────────┘                           │
│                                                                 │
│  Revenue Streams:                                               │
│  • Commission on bookings (10-15%)                              │
│  • Vendor subscription tiers (Basic/Premium/Elite)             │
│  • Featured listings & promoted search                          │
│  • Escrow fee (1-2%)                                            │
│  • Sponsored ads & banners                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🔍 Complete Mock Data Inventory

Every location where mock/hardcoded data exists and must be eliminated:

### 1️⃣ Common Package — Supabase Client (`supabase_client.dart`)
| Line(s) | What | Replace With |
|---------|------|--------------|
| 19-21 | `debugPrint('falling back to premium offline mocks')` | Remove — no fallback |
| 50-53 | Categories stream error → `return [1,2,3,4,5,9,13,17]` | Let stream emit empty / error propagate |
| 59-73 | `defaultBanners` — 4 hardcoded banner objects | Delete — fetch from Supabase `carousels` table |
| 74-93 | `loadCarousels()` — returns `defaultBanners` on error or empty | Just return empty list |
| 100-108 | `defaultCampaign` — hardcoded campaign object | Delete — fetch from `campaigns` table |
| 108-129 | `loadActiveCampaign()` — returns `defaultCampaign` on error/null | Return null on error |

### 2️⃣ Common Package — R2 Upload Service (`r2_upload_service.dart`)
| Line(s) | What | Replace With |
|---------|------|--------------|
| 50-52 | `if (!isConfigured) return 'https://mock-r2.gomandap.com/...'` | Throw clear configuration error / early return null |
| 45-48 | `_simulateCloudflareR2AndSupabaseSync()` calls in onboarding | Remove entirely — do actual upload |

### 3️⃣ Common Package — Vendor Application Repository (`vendor_application_repository.dart`)
| Line(s) | What | Replace With |
|---------|------|--------------|
| 17-45 | `_mockStore` — 2 hardcoded VendorApplication objects | Delete entirely |
| 64-76 | `submitApplication()` — offline mock return | Must have Supabase — throw if unavailable |
| 98-103 | `approveApplication()` — falls back to `_mockStore` | Supabase only |
| 130-136 | `updateApplication()` — falls back to `_mockStore` | Supabase only |
| 159-163 | `watchAllApplications()` — mock stream | Supabase realtime stream only |
| 182-188 | `getApplicationByPhone()` — mock fallback | Supabase only |
| 210 | `_mockStore.where(...)` fallback | Supabase only |

### 4️⃣ Client App — Onboarding Wizard (`vendor_onboarding_wizard.dart`)
| Line(s) | What | Replace With |
|---------|------|--------------|
| 56 | `// Step 3 Mock Portfolios` | Replace with live portfolio builder |
| 63 | `_isPlayingMockVideo` | Remove — use real video upload |
| 975-1021 | Mock video UI | Replace with actual media viewer |
| 1286 | `// Mock registration details card` | Real data binding |
| 1125, 1165 | `_simulateCloudflareR2AndSupabaseSync()` | Actual upload + DB write |

### 5️⃣ Client App — Wishlist (`wishlist_screen.dart`)
| Line(s) | What | Replace With |
|---------|------|--------------|
| 19 | `// Mock wishlist data` | Live data from Supabase `wishlists` table |

### 6️⃣ Client App — Home Notifier (`home_notifier.dart`)
| Line(s) | What | Replace With |
|---------|------|--------------|
| Throughout | Returns mock/hardcoded vendor lists for home screen | Fetch from Supabase realtime streams |

### 7️⃣ Client App — Search Notifier (`search_notifier.dart`)
| Line(s) | What | Replace With |
|---------|------|--------------|
| Throughout | Large mock vendor list for search results | Supabase full-text search + filters |

### 8️⃣ Vendor App — Login (`vendor_login_screen.dart`)
| Line(s) | What | Replace With |
|---------|------|--------------|
| 11-12 | `MOCK_OTP`, `MOCK_AUTH` compile-time flags | Remove entirely |
| 119-164 | Mock OTP verification logic | Real Supabase Auth OTP flow |
| 400-424 | Mock post-login navigation | Real auth state-driven navigation |

### 9️⃣ Vendor App — KYC (`vendor_kyc_screen.dart`)
| Line(s) | What | Replace With |
|---------|------|--------------|
| 65 | `DateTime.now().millisecondsSinceEpoch.toString() // Mock ID` | Real ID from Supabase/generated UUID |

---

## 🏗️ Proposed Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                        FLUTTER APPS                              │
│  ┌────────────────┐  ┌────────────────┐  ┌────────────────────┐  │
│  │ Client (Web)   │  │ Vendor (Web)   │  │ Admin (Web)        │  │
│  │ gomandap.com   │  │ vendor.gomandap│  │ admin.gomandap.com │  │
│  └────────┬───────┘  └───────┬────────┘  └─────────┬──────────┘  │
│           │                  │                      │             │
│  ┌────────▼──────────────────▼──────────────────────▼──────────┐  │
│  │              PACKAGES / COMMON (Shared Layer)               │  │
│  │  • Auth (Supabase Auth)   • Theme (Premium Indian)         │  │
│  │  • Models (Freezed)       • Widgets (Reusable)             │  │
│  │  • Repositories (Abstract)• R2 Upload Service              │  │
│  └──────────────────────────────┬──────────────────────────────┘  │
└─────────────────────────────────┼─────────────────────────────────┘
                                  │
┌─────────────────────────────────┼─────────────────────────────────┐
│  SUPABASE (Backend)             │                                 │
│  ┌──────────────────────────────▼──────────────────────────┐     │
│  │                    DATABASE (Postgres)                    │     │
│  │  vendors │ vendor_applications │ services │ categories   │     │
│  │  bookings │ escrows │ milestones │ wishlists │ reviews   │     │
│  │  conversations │ messages │ carousels │ campaigns       │     │
│  │  platform_config │ subscription_tiers                  │     │
│  ├────────────────────────────────────────────────────────┤     │
│  │                  REAL-TIME (WebSocket)                   │     │
│  │  vendor_applications:insert/update                      │     │
│  │  bookings:insert/update                                 │     │
│  │  escrows:update                                         │     │
│  │  chat:messages                                           │     │
│  ├────────────────────────────────────────────────────────┤     │
│  │                  AUTH (GoTrue)                           │     │
│  │  Email/OTP | Magic Link | Google OAuth                  │     │
│  ├────────────────────────────────────────────────────────┤     │
│  │                  STORAGE (S3-compatible)                  │     │
│  │  vendor-images │ vendor-portfolios │ banners │ avatars  │     │
│  └────────────────────────────────────────────────────────┘     │
└──────────────────────────────────────────────────────────────────┘
                                  │
┌─────────────────────────────────┼─────────────────────────────────┐
│              CLOUDFLARE R2      │                                 │
│  ┌──────────────────────────────▼──────────────────────────┐     │
│  │    S3-Compatible Object Storage (Private Bucket)        │     │
│  │  • Vendor profile images  • Portfolio galleries         │     │
│  │  • Event photos           • Platform banners            │     │
│  │  • KYC documents          • Invoice PDFs                │     │
│  └────────────────────────────────────────────────────────┘     │
│  • Presigned URLs for uploads (client-side)                     │
│  • Public CDN URLs for reads (via R2.dev domain)                │
└──────────────────────────────────────────────────────────────────┘
```

---

## 📦 Complete Supabase Schema (Required Tables)

Below is the full schema with ALL tables needed, grouped by domain. **Bold** = exists already.

### Vendors Domain
| Table | Status | Purpose |
|-------|--------|---------|
| **vendors** | ✅ Partial | Business info, category, rating, location |
| vendor_services | ❌ Missing | Per-vendor service catalog with pricing |
| **vendor_applications** | ✅ Exists | Onboarding pipeline (pending→approved) |
| vendor_availability | ❌ Missing | Calendar block-out dates |
| vendor_portfolios | ❌ Missing | Gallery images with captions |
| vendor_subscriptions | ❌ Missing | Subscription tier + payment status |
| vendor_reviews | ❌ Missing | Client reviews with ratings |

### Bookings Domain
| Table | Status | Purpose |
|-------|--------|---------|
| bookings | ❌ Missing | Booking record linking client↔vendor |
| **escrows** | ✅ Partial | Escrow account for booking |
| **milestones** | ✅ Partial | Milestone-based payment release |
| conversations | ❌ Missing | Chat conversations |
| messages | ❌ Missing | Individual chat messages |

### Platform Domain
| Table | Status | Purpose |
|-------|--------|---------|
| **categories** | ✅ Partial | Vendor categories (photography, catering...) |
| carousels | ❌ Missing | Hero banner images + CTAs for client app |
| campaigns | ❌ Missing | Promotional campaigns (e.g. "Summer Wedding Sale") |
| **platform_config** | ✅ Basic | System-wide configuration |
| subscription_tiers | ❌ Missing | Pricing tiers for vendors |

### Client Domain
| Table | Status | Purpose |
|-------|--------|---------|
| **wishlists** | ❌ Missing | Saved vendors per client |
| client_profiles | ❌ Missing | Client preferences, budget, wedding date |
| notifications | ❌ Missing | In-app notification log |

---

## 📅 Phased Implementation Roadmap

---

### 🔷 PHASE 1: Foundation — Database Schema & Infrastructure *(Week 1-2)*

**Goal:** Establish a rock-solid backend with zero mock data paths.

#### 1.1 Complete Supabase Schema Migrations
- [ ] Create migration: `vendor_services` table (id, vendor_id, name, category, price, description, images, is_active)
- [ ] Create migration: `vendor_availability` table (id, vendor_id, date, is_available, reason)
- [ ] Create migration: `vendor_portfolios` table (id, vendor_id, image_url, caption, sort_order)
- [ ] Create migration: `vendor_subscriptions` table (id, vendor_id, tier, start_date, end_date, status)
- [ ] Create migration: `vendor_reviews` table (id, vendor_id, client_id, rating, comment, created_at)
- [ ] Create migration: `bookings` table (id, client_id, vendor_id, service_id, date, status, total_amount)
- [ ] Create migration: `conversations` table (id, booking_id, client_id, vendor_id, last_message_at)
- [ ] Create migration: `messages` table (id, conversation_id, sender_id, content, type, created_at)
- [ ] Create migration: `carousels` table (id, image_url, title, subtitle, cta_label, cta_action, sort_order, is_active)
- [ ] Create migration: `campaigns` table (id, title, description, image_url, action_label, action_url, glow_color, is_active)
- [ ] Create migration: `wishlists` table (id, client_id, vendor_id, created_at)
- [ ] Create migration: `client_profiles` table (id, user_id, name, wedding_date, budget, city)
- [ ] Create migration: `notifications` table (id, user_id, type, title, body, data, is_read, created_at)
- [ ] Add RLS policies for ALL tables
- [ ] Create proper indexes on frequently queried columns

#### 1.2 RLS Policies & Security
- [ ] Clients can read: vendors, services, categories, reviews
- [ ] Clients can write: bookings, wishlists, conversations, messages, reviews
- [ ] Vendors can read/write: their own services, availability, portfolios
- [ ] Admin can read/write: ALL tables
- [ ] Supabase Auth integration with role-based access

#### 1.3 Set Up Row-Level Security + Env Variables
- [ ] Configure Supabase project with environment variables in all 3 apps
- [ ] Set up Cloudflare R2 bucket + credentials
- [ ] Configure R2 CORS for browser uploads
- [ ] Create `.env` files for each app (gitignored)
- [ ] Create environment variable loading utilities

---

### 🔷 PHASE 2: Remove ALL Mock Data *(Week 2-3)*

**Goal:** Every data path goes through Supabase + R2 — zero fallbacks to mock data.

#### 2.1 Common Package — Repository Layer
- [ ] **`supabase_client.dart`**:
  - Remove `defaultBanners`, `defaultCampaign` constants
  - Remove all `return defaultBanners` / `return defaultCampaign` fallbacks
  - Clean up error handlers that return mock IDs
  - All streams should error-propagate or emit empty states
- [ ] **`vendor_application_repository.dart`**:
  - Remove `_mockStore` entirely
  - Remove all offline/mock fallback in `submitApplication()`, `approveApplication()`, `updateApplication()`
  - Remove mock periodic stream in `watchAllApplications()`
  - All methods require valid Supabase client — throw `StateError` otherwise
- [ ] **`r2_upload_service.dart`**:
  - Remove `'https://mock-r2.gomandap.com/...'` fallback
  - Better error handling that surfaces config issues at build/dev time
  - Remove `_simulateCloudflareR2AndSupabaseSync()` — do actual uploads with presigned URLs

#### 2.2 Client App — Notifiers & Screens
- [ ] **`home_notifier.dart`**: Remove all mock vendor lists → fetch from `vendors` table with Supabase realtime
- [ ] **`search_notifier.dart`**: Remove mock data → implement real Supabase full-text search with filtering
- [ ] **`cart_notifier.dart`**: Remove any mock cart items → persist in Supabase `bookings` / `carts` tables
- [ ] **`wishlist_screen.dart`**: Remove mock wishlist items → fetch from `wishlists` table
- [ ] **`vendor_onboarding_wizard.dart`**: Remove `_isPlayingMockVideo`, mock portfolios → real R2 uploads + Supabase writes

#### 2.3 Vendor App — Auth & Screens
- [ ] **`vendor_login_screen.dart`**: Remove `MOCK_OTP`, `MOCK_AUTH` compile-time env flags, mock OTP verification → real Supabase Auth OTP flow
- [ ] **`vendor_kyc_screen.dart`**: Remove mock ID generation → real UUID from Supabase

#### 2.4 Validation
- [ ] Create a startup validation that checks Supabase connectivity
- [ ] Fail gracefully with clear error messages (no silent mock fallback)
- [ ] Run full `flutter analyze` across all 3 apps + common package
- [ ] Verify zero compilation errors
- [ ] Manual smoke test of all data flows

---

### 🔷 PHASE 3: Admin Panel — Full Platform Control *(Week 3-4)*

**Goal:** The admin panel becomes the command center for the entire GoMandap platform.

#### 3.1 Authentication & Dashboard
- [ ] **Admin Login**: Supabase Auth with admin role check
- [ ] **Dashboard** — Live metrics dashboard:
  - Total vendors (registered, approved, pending)
  - Total bookings (pending, confirmed, completed)
  - Revenue metrics (escrow volume, commission earned)
  - Active users (clients, vendors online)
  - Real-time graphs using Supabase queries

#### 3.2 Vendor Management
- [ ] **Vendor Approval Pipeline** (Enhanced from current):
  - Queue of pending applications with detailed review panel
  - Approve/Reject/Request Changes actions
  - Vendor search & filter (by category, status, city, subscription tier)
  - Bulk actions (export CSV, batch approve)
  - Vendor detail view (profile, services, bookings, reviews, escrow history)

#### 3.3 UI/UX Configuration *(New — Key Differentiator)*
- [ ] **Platform Theme Config**:
  - Primary color picker (affects all 3 apps)
  - Header/footer branding (logo, tagline)
  - Font family selector
  - Border radius & spacing controls
- [ ] **Carousel Manager**:
  - Add/Edit/Reorder hero banners for client app home screen
  - Set CTA text + action per banner
  - Schedule banners (start date, end date)
  - Preview how they'll look on client app
- [ ] **Campaign Manager**:
  - Create promotional campaigns (e.g. "Monsoon Wedding Special")
  - Set glow color, CTA, landing page
  - Activate/deactivate campaigns
- [ ] **Category Manager**:
  - CRUD for service categories
  - Assign icons/illustrations to each category
  - Set display order

#### 3.4 Content Management
- [ ] **Static Pages Manager**:
  - About Us, Terms of Service, Privacy Policy, FAQ
  - Rich text editor (markdown or WYSIWYG)
- [ ] **Blog/Stories**:
  - Wedding inspiration blog posts
  - Vendor spotlight features
- [ ] **Notification Center**:
  - Send push notifications to all clients / vendors / segments
  - View notification history

#### 3.5 Financial Control
- [ ] **Escrow Disbursement Dashboard** (Enhanced from current):
  - All active escrows with milestone tracking
  - Release/hold payments per milestone
  - Dispute resolution panel
  - Payout history to vendors
- [ ] **Subscription Manager**:
  - View all vendor subscriptions
  - Tier upgrade/downgrade
  - Payment status tracking

#### 3.6 User Management
- [ ] **Client Management**:
  - View all registered clients
  - Client activity log
  - Block/suspend users
- [ ] **Vendor Management**:
  - Full vendor profiles view
  - Vendor performance analytics (views, inquiries, conversion)
  - Suspend/activate vendors
- [ ] **Admin Management**:
  - Add/remove admin accounts
  - Role-based permissions (super admin, moderator, support)

#### 3.7 Analytics & Reporting
- [ ] Platform-wide KPIs dashboard
- [ ] Vendor performance reports
- [ ] Booking conversion funnel
- [ ] Revenue reports (commission, subscriptions, ads)
- [ ] User growth trends

---

### 🔷 PHASE 4: Client App — Premium Marketplace UX *(Week 4-6)*

**Goal:** A stunning, inspiring wedding planning experience that rivals/beats WedMeGood.

#### 4.1 Home Screen — Inspiration-First Redesign
- [ ] **Hero Section**: Dynamic carousel from Supabase `carousels` table — full-bleed video/image with parallax
- [ ] **Category Grid**: Icons + labels from `categories` table, animated entry
- [ ] **Top Venues Row**: Horizontal scroll of featured/trending vendors
- [ ] **Real Weddings Gallery**: User-generated content from reviews + portfolios
- [ ] **Personalized Recommendations**: "Based on your budget/wedding date" section
- [ ] **City Discovery**: Browse vendors by city with beautiful parallax row
- [ ] **Sponsored Section**: Premium vendor placements with "Ad" badge
- [ ] **Live Campaign Banner**: Dynamic campaign banner from `campaigns` table

#### 4.2 Search & Discovery — Advanced Filters
- [ ] **Supabase Full-Text Search**: Instant search across vendor names, cities, categories
- [ ] **Filter Panel**:
  - Category (multi-select)
  - Price range (budget slider)
  - Rating (min 3.0/4.0/4.5)
  - City/Location
  - Availability date picker
  - Services offered (checkboxes)
- [ ] **Sort Options**: Relevance, Rating (high→low), Price (low→high), Distance
- [ ] **Search History**: Recent searches saved per user
- [ ] **Vendor Preview Cards**: Rich cards with gallery thumbnails, price badge, rating, quick-actions (save, share, call)

#### 4.3 Vendor Detail Page — Immersive Experience
- [ ] **Full-Screen Gallery**: Swipeable portfolio images with pinch-to-zoom
- [ ] **Vendor Profile**: Business name, category, rating, location, response time
- [ ] **Service Catalog**: Tabbed view of all services with pricing, descriptions
- [ ] **Availability Calendar**: Month view showing blocked/available dates
- [ ] **Reviews & Ratings Panel**: Star ratings, written reviews, photo reviews
- [ ] **Similar Vendors**: "You might also like" section
- [ ] **Sticky Action Bar**: Fixed bottom bar with "Save", "Share", "Send Inquiry", "Book Now"
- [ ] **Quick Inquiry**: Pre-filled message form to contact vendor
- [ ] **Video Tour**: Vendor introduction video (if available)

#### 4.4 Booking Flow — Escrow-Protected
- [ ] **Cart**: Add multiple services from vendor
- [ ] **Checkout Stages**:
  - 1. Select services + quantities
  - 2. Choose date + time
  - 3. Review total (service prices + platform fee + taxes)
  - 4. Payment (escrow deposit — 30% advance)
- [ ] **Escrow Visualizer**: Beautiful timeline showing milestone payments (30%→50%→20%→0%)
- [ ] **Payment**: UPI / Credit Card / Net Banking via escrow
- [ ] **Booking Confirmation**: Animated success screen with booking ID, QR code

#### 4.5 My Bookings — Client Dashboard
- [ ] **Upcoming Events**: Cards showing event date, vendor name, status, countdown
- [ ] **Past Events**: Completed bookings with "Write a Review" prompt
- [ ] **Booking Detail**: Full breakdown with vendor info, services, payment milestones, chat button
- [ ] **Escrow Tracker**: Visual progress of payment release milestones
- [ ] **Add-On Services**: Modify booking to add services mid-way

#### 4.6 Chat — Client ↔ Vendor
- [ ] **Conversation List**: All chats with vendors, sorted by last message
- [ ] **Chat View**: Rich messages (text, images, share booking reference)
- [ ] **Quick Replies**: Common inquiry messages
- [ ] **Booking Integration**: Each chat shows related booking summary

#### 4.7 Profile & Settings
- [ ] **My Profile**: Name, wedding date, budget, location
- [ ] **Wishlist**: Grid of saved vendors with quick actions
- [ ] **Saved Searches**: Filtered search presets for quick reuse
- [ ] **Notification Settings**: Push/email preferences
- [ ] **Become a Vendor**: Onboarding flow to register as vendor

#### 4.8 Premium UI/UX Details
- [ ] **Indian-Inspired Design**: Marigold orange, gold accents, silk textures
- [ ] **Smooth Animations**: Page transitions, card entrances, shimmer loading
- [ ] **Empty States**: Beautiful illustrations when no data
- [ ] **Error States**: Friendly error messages with retry
- [ ] **Responsive**: Seamless from mobile to desktop
- [ ] **PWA Support**: Install prompt, offline-capable with cached data

---

### 🔷 PHASE 5: Vendor App — Business Management Powerhouse *(Week 6-7)*

**Goal:** Vendors can manage their entire business — from onboarding to getting paid.

#### 5.1 Vendor Registration & KYC
- [ ] **Registration Flow** (Enhanced from current):
  - Step 1: Basic details (business name, owner name, phone, email)
  - Step 2: Category + services selection
  - Step 3: Upload KYC docs (GST, PAN, business proof) → R2 presigned URLs
  - Step 4: Portfolio upload (up to 10 images) → R2
  - Step 5: Pricing setup (per-service pricing)
  - Step 6: Verification — submit for admin approval
  - **Live Supabase writes at each step** — no mock data

#### 5.2 Dashboard
- [ ] **Today's Overview**: New inquiries, upcoming bookings, pending tasks
- [ ] **Performance Metrics**: Profile views, inquiry conversion rate, revenue this month
- [ ] **Quick Actions**: Update availability, respond to messages, upload new photos
- [ ] **Notifications**: Recent alerts (new booking, milestone released, review received)

#### 5.3 Catalog & Services Management
- [ ] **Service List**: All services offered with prices, descriptions
- [ ] **Add/Edit Service**: Name, category, price, description, images (R2 upload)
- [ ] **Package Builder**: Create packages (e.g. "Silver", "Gold", "Platinum")
- [ ] **Portfolio Gallery**: Manage images with drag-to-reorder (R2)
- [ ] **Video Upload**: Business introduction video (R2)

#### 5.4 Calendar & Availability
- [ ] **Month View**: Full calendar with colored indicators (available, booked, blocked)
- [ ] **Block Dates**: Mark dates as unavailable
- [ ] **Blackout Periods**: Set recurring off-days (e.g. every Monday)
- [ ] **Booking Requests**: Incoming requests with accept/decline

#### 5.5 Bookings Management
- [ ] **Booking List**: All bookings (pending, confirmed, completed, cancelled)
- [ ] **Booking Detail**: Client info, selected services, total amount, escrow status
- [ ] **Confirm/Reject**: Manual approval before booking is finalized
- [ ] **Reschedule**: Change date/time with client approval flow
- [ ] **Booking Notes**: Internal notes only vendor can see

#### 5.6 Escrow & Payments
- [ ] **Escrow Dashboard**: All active escrows with their milestone progress
- [ ] **Milestone Releases**: Request milestone release when work is done
- [ ] **Payout History**: All completed payouts with dates, amounts
- [ ] **Invoice Generation**: Generate PDF invoice for completed bookings
- [ ] **Bank Account Setup**: Withdrawal bank account details

#### 5.7 Reviews & Reputation
- [ ] **Review Inbox**: All client reviews with option to respond publicly
- [ ] **Rating Breakdown**: Average rating across categories (service, punctuality, quality)
- [ ] **Review Request**: Ask clients to leave a review after completed booking
- [ ] **Badges**: "Top Rated", "Quick Responder", "Premium Partner" badges

#### 5.8 Chat — Vendor ↔ Client
- [ ] **Conversation List**: All client conversations
- [ ] **Quick Responses**: Saved templates for common questions
- [ ] **Share Portfolio**: Send portfolio images directly in chat
- [ ] **Booking Shortcuts**: Quickly view/create bookings from chat

#### 5.9 Profile & Settings
- [ ] **Business Profile**: Edit business info, logo, cover photo
- [ ] **Service Area**: Define cities/locations you serve
- [ ] **Subscription**: View current plan, upgrade/downgrade
- [ ] **Notifications**: Configure alert preferences

---

### 🔷 PHASE 6: Payment & Escrow — Trust Engine *(Week 7-8)*

**Goal:** A trusted, transparent payment system that protects both clients and vendors.

#### 6.1 Escrow Architecture
- [ ] **Supabase escrows table**: Full schema with booking_id, total_amount, current_balance, status, created_at
- [ ] **Milestone Definition**: Each booking has predefined milestones:
  - Milestone 1 (Booking): 30% — released upon booking confirmation
  - Milestone 2 (Preparation): 50% — released after vendor starts work (event day - 7 days)
  - Milestone 3 (Event Day): 20% — released after event completion
  - Milestone 4 (Completion): released 48h after event (auto-release if no dispute)
- [ ] **Payment Gateway Integration**: Razorpay / Cashfree for UPI + cards
- [ ] **Escrow Account**: Funds held in platform escrow account (via payment gateway)
- [ ] **Dispute Resolution**: Admin-mediated hold/release of disputed funds

#### 6.2 Commission Model
- [ ] **Platform Fee**: 10-15% commission on each booking
- [ ] **Tiered Commission**: Lower commission for subscribed vendors
- [ ] **Subscription Tiers**:
  - **Basic** (Free): 15% commission, basic profile, 5 portfolio images
  - **Premium** (₹999/mo): 10% commission, priority listing, 20 images, analytics
  - **Elite** (₹2,499/mo): 8% commission, featured badge, unlimited images, dedicated support

#### 6.3 Escrow R2V Integration
- [ ] R2V (Request-to-Verify) flow: vendor uploads proof of work → client verifies → milestone releases
- [ ] Escrow visualizer in client app (already partially built in `escrow_checkout_sheet.dart`)
- [ ] Admin override for dispute scenarios

---

### 🔷 PHASE 7: UI/UX — Premium Design Overhaul *(Week 8-10)*

**Goal:** Create a visually stunning, emotionally resonant experience that users *love* to use.

#### 7.1 Design System
- [ ] **Premium Indian Design Tokens** (already started in `gomandap_tokens.dart`):
  - Gold/Champagne accents for premium feel
  - Marigold orange + emerald green + royal navy palette
  - Outfit + Inter font pairing (already set up)
  - Glass-morphism cards with gold borders
  - Subtle ethnic filigree patterns (already exists as `EthnicFiligreePainter`)
- [ ] **Light + Dark Mode**: Full theme support for both
- [ ] **Responsive Breakpoints**: Mobile, Tablet, Desktop layouts for all 3 apps

#### 7.2 Client App Premium UX
- [ ] **Home Screen**: Immersive full-bleed hero, smooth parallax scroll, staggered section reveals
- [ ] **Vendor Cards**: Rich cards with image carousel, price badge, rating stars, save button
- [ ] **Detail Page**: Sticky tab bar (Photos, Services, Reviews, About), smooth tab transitions
- [ ] **Booking Flow**: Beautiful progress stepper with animated checkmarks
- [ ] **Empty States**: Custom illustrated SVGs for empty wishlist, no bookings, no search results
- [ ] **Loading States**: Skeletons with gold shimmer animation (already has this)
- [ ] **Celebrations**: Confetti animation on booking confirmation
- [ ] **Touch Feedback**: Haptic + visual feedback on all interactive elements

#### 7.3 Vendor App Premium UX
- [ ] **Dashboard**: Premium card-based metrics with sparkline charts
- [ ] **Calendar**: Beautiful month view with color-coded dates
- [ ] **Catalog**: Drag-to-reorder portfolio images with preview
- [ ] **Form Design**: Clean, step-by-step forms with progress indicator
- [ ] **Mobile-First**: Responsive design that works on phone + desktop

#### 7.4 Admin Panel Premium UX
- [ ] **Sidebar Navigation**: Collapsible sidebar with icons + labels
- [ ] **Data Tables**: Sortable, filterable, searchable tables
- [ ] **Charts**: Revenue graph, vendor growth chart, booking funnel
- [ ] **Dark Mode**: Admin-friendly dark theme
- [ ] **Quick Actions**: Global search, notifications dropdown, quick-create menu

---

### 🔷 PHASE 8: Infrastructure & Deployment *(Week 10)*

**Goal:** Professional deployment with CI/CD, monitoring, and scalability.

#### 8.1 Deployment
- [ ] **Client App**: Deploy to Vercel/Netlify at `gomandap.com`
- [ ] **Vendor App**: Deploy to `vendor.gomandap.com`
- [ ] **Admin App**: Deploy to `admin.gomandap.com` (password-protected)
- [ ] **Flutter Web**: Build optimization (code splitting, tree shaking, caching)

#### 8.2 CI/CD
- [ ] GitHub Actions for all 3 apps:
  - `flutter analyze` on PR
  - `flutter build web` on merge to main
  - Auto-deploy to hosting
- [ ] Supabase migrations in CI
- [ ] R2 bucket configuration as code

#### 8.3 Monitoring
- [ ] Supabase Logs for DB queries and errors
- [ ] Sentry/Datadog for frontend error tracking
- [ ] Uptime monitoring for all 3 apps
- [ ] Performance budgets (Lighthouse scores > 85)

#### 8.4 SEO & PWA
- [ ] Meta tags for all pages (title, description, OG image)
- [ ] Structured data (JSON-LD for vendors, categories)
- [ ] Service Worker for offline capabilities
- [ ] PWA manifest with install prompt

---

## ⚠️ Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Removing mock data breaks all screens | High | Test each screen after removing mock data; use empty states |
| Supabase RLS misconfiguration | High | Test each query type with different auth roles |
| Payment gateway integration complexity | High | Use Razorpay's well-documented API; phase escrow after basic flows work |
| Flutter Web performance with heavy animations | Medium | Use `RepaintBoundary`, minimize rebuilds, test on low-end devices |
| Scope creep (too many features at once) | High | Strictly follow phased approach; user approves each phase before starting |
| Vendor adoption/onboarding friction | Medium | Simplify vendor registration to < 5 minutes; mobile-first |

---

## ✅ Approval Checklist

Please review and approve each phase by responding to the plan:

| Phase | Description | Approve? |
|-------|-------------|----------|
| **Phase 1** | Foundation — Database Schema & Infrastructure | ⬜ |
| **Phase 2** | Remove ALL Mock Data — Supabase + R2 Only | ⬜ |
| **Phase 3** | Admin Panel — Full Platform Control | ⬜ |
| **Phase 4** | Client App — Premium Marketplace UX | ⬜ |
| **Phase 5** | Vendor App — Business Management | ⬜ |
| **Phase 6** | Payment & Escrow — Trust Engine | ⬜ |
| **Phase 7** | UI/UX — Premium Design Overhaul | ⬜ |
| **Phase 8** | Infrastructure & Deployment | ⬜ |

---

> **Next Step:** Reply to this plan with your feedback, amendments, or approval of specific phases. Once you approve a phase, I'll begin implementation with working code — no mock data, all Supabase-connected, production-ready.
