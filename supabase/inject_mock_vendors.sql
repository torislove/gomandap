-- ============================================================
-- GoMandap - Inject Mock Vendors Data
-- ============================================================
-- Run this script in your Supabase SQL Editor to populate the vendors table.
-- Note: This bypasses RLS and will successfully insert the data.

-- 0. Create tables if they do not exist
CREATE TABLE IF NOT EXISTS public.vendors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  name TEXT,
  type TEXT,
  city TEXT,
  locality TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  rating DOUBLE PRECISION,
  base_price DOUBLE PRECISION,
  cover_photo_url TEXT,
  photos TEXT[],
  approval_status TEXT,
  is_live BOOLEAN,
  cancellation_policy TEXT,
  type_data JSONB DEFAULT '{}'::jsonb,
  category TEXT DEFAULT 'Venues',
  price_label TEXT DEFAULT 'Per Day',
  description TEXT DEFAULT '',
  service_tags TEXT[] DEFAULT '{}',
  gallery_urls TEXT[] DEFAULT '{}',
  preferred BOOLEAN DEFAULT false,
  shortlist_count INT DEFAULT 0,
  availability_status TEXT DEFAULT 'available',
  review_count INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.vendor_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID,
  business_name TEXT,
  owner_name TEXT,
  city TEXT,
  status TEXT
);

-- 1. Optional: Clear existing mock vendors
DELETE FROM public.vendors WHERE approval_status = 'APPROVED' OR approval_status = 'PENDING';

-- 2. Insert new realistic mock vendors
INSERT INTO public.vendors (
  id, user_id, name, type, city, locality, latitude, longitude, rating, 
  base_price, cover_photo_url, photos, approval_status, is_live, cancellation_policy
) VALUES 
-- BANQUET (Venue)
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'The Royal Mandapam & Gardens', 'Banquet', 'Hyderabad', 'Jubilee Hills', 17.43, 78.41, 4.9, 180000, 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800', ARRAY['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800', 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'], 'APPROVED', true, 'Cancel up to 7 days before'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'Grand Imperial Convention Hall', 'Banquet', 'Hyderabad', 'Banjara Hills', 17.41, 78.44, 4.7, 250000, 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800', ARRAY['https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'], 'APPROVED', true, 'Cancel up to 14 days before'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'ITC Kohinoor Grand Ball', 'Banquet', 'Hyderabad', 'HITEC City', 17.44, 78.38, 5.0, 500000, 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800', ARRAY['https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800'], 'APPROVED', true, 'No cancellation'),

-- PHOTOGRAPHY
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'Candid Tales Photography', 'Photography', 'Hyderabad', 'Kukatpally', 17.48, 78.39, 4.8, 65000, 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800', ARRAY['https://images.unsplash.com/photo-1555244162-803834f70033?w=800'], 'APPROVED', true, 'Flexible'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'Moments by Raj', 'Photography', 'Hyderabad', 'Gachibowli', 17.44, 78.36, 4.6, 45000, 'https://images.unsplash.com/photo-1505909182942-e2f09aee3e89?w=800', ARRAY['https://images.unsplash.com/photo-1505909182942-e2f09aee3e89?w=800'], 'APPROVED', true, 'Cancel up to 3 days before'),

-- DECORATION
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'Floral Dreams Decorators', 'Decoration', 'Hyderabad', 'Secunderabad', 17.44, 78.50, 4.9, 85000, 'https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800', ARRAY['https://images.unsplash.com/photo-1469334031218-e382a71b716b?w=800'], 'APPROVED', true, 'Cancel up to 5 days before'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'Elite Wedding Designs', 'Decoration', 'Hyderabad', 'Madhapur', 17.45, 78.38, 4.7, 120000, 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800', ARRAY['https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800'], 'APPROVED', true, 'Strict'),

-- CATERING
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'Spices of India Catering', 'Catering', 'Hyderabad', 'Begumpet', 17.44, 78.46, 4.8, 1500, 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800', ARRAY['https://images.unsplash.com/photo-1555244162-803834f70033?w=800'], 'APPROVED', true, 'Cancel up to 10 days before'),
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'Mughlai Masters', 'Catering', 'Hyderabad', 'Tolichowki', 17.40, 78.41, 4.5, 1200, 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800', ARRAY['https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800'], 'APPROVED', true, 'Flexible'),

-- MAKEUP
(gen_random_uuid(), '00000000-0000-0000-0000-000000000000', 'Glamour by Aditi', 'Makeup', 'Hyderabad', 'Banjara Hills', 17.41, 78.44, 4.9, 25000, 'https://images.unsplash.com/photo-1505909182942-e2f09aee3e89?w=800', ARRAY['https://images.unsplash.com/photo-1505909182942-e2f09aee3e89?w=800'], 'APPROVED', true, 'Cancel up to 2 days before');

-- 3. Enable Realtime on Vendors and Vendor Applications for Admin Panel Sync
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'vendors'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE vendors;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' AND tablename = 'vendor_applications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE vendor_applications;
  END IF;
END $$;
