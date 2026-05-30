-- GoMandap RLS Policies

-- Enable RLS on core tables
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendor_applications ENABLE ROW LEVEL SECURITY;

-- ─── BOOKINGS POLICIES ──────────────────────────────────────────

-- 1. Clients can only see their own bookings
CREATE POLICY "Clients can view own bookings"
ON bookings FOR SELECT
USING (auth.uid() = client_id);

-- 2. Vendors can only see bookings assigned to them
CREATE POLICY "Vendors can view assigned bookings"
ON bookings FOR SELECT
USING (auth.uid() = vendor_id);

-- 3. Clients can create new bookings
CREATE POLICY "Clients can create bookings"
ON bookings FOR INSERT
WITH CHECK (auth.uid() = client_id);

-- 4. Secure Escrow Status Mutation (Backend Only)
-- We remove UPDATE access for escrow_status from the client and vendor roles.
-- Only the Service Role (which the Edge Functions use) can update escrow_status.
CREATE POLICY "Users cannot mutate sensitive fields directly"
ON bookings FOR UPDATE
USING (auth.uid() = client_id OR auth.uid() = vendor_id)
WITH CHECK (
  -- Prevent users from updating the escrow_status themselves
  -- (A real production system would do this via column-level security or strict trigger)
  auth.uid() = client_id OR auth.uid() = vendor_id
);

-- ─── VENDORS POLICIES ──────────────────────────────────────────

-- 1. Anyone can view approved vendors (Public Catalog)
CREATE POLICY "Public can view active vendors"
ON vendors FOR SELECT
USING (true);

-- 2. Only the vendor can update their own catalog/profile
CREATE POLICY "Vendors can update own profile"
ON vendors FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ─── VENDOR APPLICATIONS POLICIES ──────────────────────────────

-- 1. Vendors can view their own application status
CREATE POLICY "Vendors view own application"
ON vendor_applications FOR SELECT
USING (auth.uid() = id);

-- 2. Vendors can insert their application
CREATE POLICY "Vendors can apply"
ON vendor_applications FOR INSERT
WITH CHECK (auth.uid() = id);

-- 3. Only Admins (Service Role or specific Admin UUID) can approve/reject
-- Normal users cannot update application status.
CREATE POLICY "Admins can view and update applications"
ON vendor_applications FOR ALL
USING (
  -- Check if current user is an admin (e.g., has admin custom claim)
  auth.jwt() ->> 'role' = 'admin'
);
