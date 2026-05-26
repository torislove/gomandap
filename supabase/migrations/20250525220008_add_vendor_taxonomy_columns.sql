-- Migration: Add expanded vendor taxonomy columns
-- Task 1.1: Add new columns to vendors table for 17-category support
-- Requirements: 2.5, 3.1

-- ─── NEW COLUMNS FOR EXPANDED 17-CATEGORY TAXONOMY ──────────────────────────

-- Category column: one of the 17 wedding service categories
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS category TEXT DEFAULT 'Venues';

-- Price label: category-appropriate pricing unit (Per Day, Per Plate, Per Session, etc.)
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS price_label TEXT DEFAULT 'Per Day';

-- Description: vendor's service description
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS description TEXT DEFAULT '';

-- Service tags: array of service keywords for search and display
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS service_tags TEXT[] DEFAULT '{}';

-- Gallery URLs: additional gallery images beyond cover photo
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS gallery_urls TEXT[] DEFAULT '{}';

-- Preferred: whether vendor is a preferred/promoted listing
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS preferred BOOLEAN DEFAULT false;

-- Shortlist count: number of users who have shortlisted this vendor
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS shortlist_count INT DEFAULT 0;

-- Availability status: current availability (available, booked, limited)
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS availability_status TEXT DEFAULT 'available';

-- Review count: total number of reviews for this vendor
ALTER TABLE vendors ADD COLUMN IF NOT EXISTS review_count INT DEFAULT 0;

-- ─── INDEXES FOR NEW COLUMNS ────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_vendors_category ON vendors(category);
CREATE INDEX IF NOT EXISTS idx_vendors_preferred ON vendors(preferred);
CREATE INDEX IF NOT EXISTS idx_vendors_availability_status ON vendors(availability_status);

-- ─── COMMENT ON type_data JSONB COLUMN ──────────────────────────────────────
-- The type_data JSONB column (already exists) stores category-specific fields.
-- It supports all 17 category schemas without structural constraints:
--
-- Venues: venue_type, capacity, parking_count, room_count, ac_rooms,
--   has_backup_power, has_bridal_room, outside_decor_allowed,
--   outside_catering_allowed, outside_dj_allowed, alcohol_allowed,
--   valet_parking, food_type, price_per_plate_veg, price_per_plate_nonveg,
--   event_areas, property_type, pricing_model
--
-- Photography: styles[], deliverables[], team_size, delivery_time_weeks,
--   full_wedding_package, outstation_travel, price_photo_only,
--   price_video_only, price_combo
--
-- Makeup: makeup_types[], hair_styling_included, draping_included,
--   paid_trial_available, brands[], studio_price, venue_price
--
-- Decor: themes[], setup_types[], flower_types[], lighting_included,
--   stage_included, mandap_included, min_budget, max_budget
--
-- Catering: cuisine_types[], food_type, min_plate_count, max_plate_count,
--   live_counter, service_staff_included, crockery_included,
--   price_per_plate_veg, price_per_plate_nonveg
--
-- Mehndi: styles[], coverage_options[], bridal_price, guest_price,
--   travel_included, min_guests
--
-- Invitations: types[], materials[], customization_level, min_order,
--   digital_available, delivery_time_days
--
-- Jewellery: types[], materials[], rental_available, custom_design,
--   certification, price_range_min, price_range_max
--
-- DJ & Live Music: genres[], equipment_included, setup_time_hours,
--   sound_system_capacity, lighting_included, mc_available
--
-- Bridal Designers: styles[], fabric_types[], custom_design,
--   alteration_included, delivery_time_weeks, price_range_min, price_range_max
--
-- Cars: vehicle_types[], fleet_size, chauffeur_included, decoration_included,
--   hourly_rate, daily_rate, outstation_available
--
-- Entertainment: act_types[], duration_minutes, setup_requirements[],
--   indoor_outdoor, group_size
--
-- Choreographers: dance_styles[], group_size_max, sessions_included,
--   music_arrangement, costume_guidance, video_recording
--
-- Gifts: gift_types[], customization_available, bulk_discount,
--   packaging_included, delivery_available, min_order
--
-- Pandits: languages[], ceremony_types[], travel_included,
--   materials_included, duration_hours, experience_years
--
-- Honeymoon/Travel: destinations[], package_types[], duration_days,
--   flights_included, hotels_included, visa_assistance, group_size_max
--
-- Wedding Planners: service_scope[], events_managed, team_size,
--   vendor_network_size, destination_wedding, partial_planning_available

COMMENT ON COLUMN vendors.type_data IS 'Category-specific JSONB fields supporting all 17 vendor category schemas. Structure varies by category value.';
COMMENT ON COLUMN vendors.category IS 'One of 17 wedding service categories: Venues, Photography, Makeup, Decor, Catering, Mehndi, Invitations, Jewellery, DJ & Live Music, Bridal Designers, Cars, Entertainment, Choreographers, Gifts, Pandits, Honeymoon/Travel, Wedding Planners';
COMMENT ON COLUMN vendors.availability_status IS 'Current availability: available, booked, limited';
