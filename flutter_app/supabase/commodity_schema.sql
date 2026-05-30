-- GoMandap Phase 5: Commodity Model Schema

-- 0. Ensure base tables exist for local dev environments
CREATE TABLE IF NOT EXISTS public.vendors (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS public.bookings (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id uuid
);

-- 1. Create Enums
DO $$ BEGIN
    CREATE TYPE inventory_type AS ENUM ('per_plate', 'per_day', 'per_event');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 2. Create the Vendor Inventory Table
CREATE TABLE IF NOT EXISTS public.vendor_inventory (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  vendor_id uuid REFERENCES public.vendors(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  inv_type inventory_type NOT NULL,
  price numeric NOT NULL,
  max_capacity integer,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.vendor_inventory ENABLE ROW LEVEL SECURITY;

-- 3. Create the Inventory Availability Table
CREATE TABLE IF NOT EXISTS public.inventory_availability (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  inventory_id uuid REFERENCES public.vendor_inventory(id) ON DELETE CASCADE,
  available_date date NOT NULL,
  is_booked boolean DEFAULT false,
  locked_by_booking_id uuid REFERENCES public.bookings(id) ON DELETE SET NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  UNIQUE(inventory_id, available_date)
);

ALTER TABLE public.inventory_availability ENABLE ROW LEVEL SECURITY;

-- 4. Update existing Bookings table to link to Inventory
ALTER TABLE public.bookings ADD COLUMN IF NOT EXISTS inventory_id uuid REFERENCES public.vendor_inventory(id) ON DELETE SET NULL;

-- ─── RLS POLICIES FOR COMMODITIES ────────────────────────────────────

-- Drop existing policies if re-running
DROP POLICY IF EXISTS "Public can view vendor inventory" ON public.vendor_inventory;
DROP POLICY IF EXISTS "Vendors can insert own inventory" ON public.vendor_inventory;
DROP POLICY IF EXISTS "Vendors can update own inventory" ON public.vendor_inventory;
DROP POLICY IF EXISTS "Vendors can delete own inventory" ON public.vendor_inventory;
DROP POLICY IF EXISTS "Public can view availability" ON public.inventory_availability;
DROP POLICY IF EXISTS "Vendors can manage own availability" ON public.inventory_availability;

CREATE POLICY "Public can view vendor inventory" ON public.vendor_inventory FOR SELECT USING (true);
CREATE POLICY "Vendors can insert own inventory" ON public.vendor_inventory FOR INSERT WITH CHECK (auth.uid() = vendor_id);
CREATE POLICY "Vendors can update own inventory" ON public.vendor_inventory FOR UPDATE USING (auth.uid() = vendor_id);
CREATE POLICY "Vendors can delete own inventory" ON public.vendor_inventory FOR DELETE USING (auth.uid() = vendor_id);
CREATE POLICY "Public can view availability" ON public.inventory_availability FOR SELECT USING (true);
CREATE POLICY "Vendors can manage own availability" ON public.inventory_availability FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.vendor_inventory 
    WHERE id = public.inventory_availability.inventory_id AND vendor_id = auth.uid()
  )
);

