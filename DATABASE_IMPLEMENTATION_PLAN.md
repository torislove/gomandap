# GoMandap Database Implementation Plan

## 🎯 Goal
Eliminate all mock data across the GoMandap monorepo (Client, Vendor, and Admin apps) and integrate fully with Supabase (PostgreSQL) and Cloudflare R2 for object storage.

## 📋 Phased Approach

### Phase 1: Database Schema & Auth
1. **Schema Validation**: Ensure all tables defined in `GOMANDAP_IMPLEMENTATION_PLAN.md` (e.g., `vendors`, `users`, `bookings`, `carousels`, `campaigns`) exist in Supabase and match the Dart data models.
2. **Authentication Flow**:
   - Replace the `123456` mock OTP bypass in `app_router.dart` and login screens with actual Supabase OTP verification.
   - Map authenticated users to their roles (Client, Vendor, Admin) in the database.

### Phase 2: Replacing Mock Data Repositories
1. **Vendor Application Flow**:
   - In `vendor_application_repository.dart`, delete `_mockStore` and implement direct Supabase inserts and realtime streams.
2. **Home Screen Content**:
   - Update `supabase_client.dart` to fetch `carousels` and `campaigns` from the database instead of using `defaultBanners` and `defaultCampaign`.
3. **Categories & Search**:
   - Ensure the category stream fetches live categories from Supabase instead of the hardcoded `[1,2,3,4,5,9,13,17]` fallback.

### Phase 3: File Uploads & R2 Integration
1. **Cloudflare R2 Configuration**:
   - Remove the `isConfigured` check fallback in `r2_upload_service.dart` that returns a mock URL.
   - Enforce real uploads for vendor portfolios and user avatars.
2. **Onboarding Integration**:
   - Replace `_simulateCloudflareR2AndSupabaseSync()` in onboarding screens with real file uploads and subsequent database record creation.

### Phase 4: Escrow & Bookings
1. **Booking Flow**:
   - Connect the checkout process to the `bookings` and `escrow` tables in Supabase.
2. **Admin Escrow Control**:
   - Wire the Admin panel's disbursement actions to update real escrow records in the database.

## 🚀 Execution Strategy
- Begin with Phase 1 to ensure a solid foundation.
- Tackle repositories one by one, replacing mock fallback logic with robust error handling for Supabase calls.
- Use `flutter pub run build_runner build` to regenerate models if schema changes require it.
- Finally, conduct end-to-end testing of the complete flow from vendor onboarding to client booking.
