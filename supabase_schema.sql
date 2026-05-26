-- ============================================================
-- Gomandap Supabase Schema Migration
-- Project: bfaajuskircbvngjenug
-- Run this in your Supabase SQL Editor (Dashboard > SQL Editor)
-- ============================================================

-- ─── VENDORS TABLE (single table with JSONB for type-specific fields) ────────

CREATE TABLE IF NOT EXISTS vendors (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL DEFAULT 'Banquet' CHECK (type IN ('Banquet', 'Photography', 'Decorator', 'Catering', 'Makeup')),
    name TEXT NOT NULL DEFAULT '',
    locality TEXT NOT NULL DEFAULT '',
    base_price DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    rating REAL NOT NULL DEFAULT 5.0,
    image_urls TEXT[] DEFAULT '{}',
    is_escrow_protected BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_fast_filling BOOLEAN DEFAULT FALSE,
    approval_status TEXT NOT NULL DEFAULT 'PENDING_APPROVAL' CHECK (approval_status IN ('PENDING_APPROVAL', 'APPROVED', 'REVISION_REQUESTED', 'REJECTED')),
    is_live BOOLEAN DEFAULT FALSE,
    photos TEXT[] DEFAULT '{}',
    video_url TEXT DEFAULT '',
    cover_photo_url TEXT DEFAULT '',
    details JSONB DEFAULT '{}',
    admin_notes TEXT DEFAULT '',
    year_established INTEGER DEFAULT 2024,
    instagram_url TEXT DEFAULT '',
    google_maps_url TEXT DEFAULT '',
    payment_advance_percent INTEGER DEFAULT 50,
    cancellation_policy TEXT DEFAULT 'Non-Refundable',

    -- Location
    full_address TEXT DEFAULT '',
    city TEXT DEFAULT '',
    state TEXT DEFAULT '',
    pincode TEXT DEFAULT '',
    landmark TEXT DEFAULT '',

    -- Contact
    mobile_number TEXT DEFAULT '',
    email_id TEXT DEFAULT '',
    whatsapp_number TEXT DEFAULT '',

    -- Banking
    bank_account_name TEXT DEFAULT '',
    bank_account_number TEXT DEFAULT '',
    bank_name TEXT DEFAULT '',
    bank_ifsc_code TEXT DEFAULT '',
    upi_id TEXT DEFAULT '',

    -- Misc
    geohash TEXT DEFAULT '',
    gstin TEXT DEFAULT '',
    fssai_license TEXT DEFAULT '',
    before_after_images JSONB DEFAULT '[]',

    -- Type-specific fields stored as JSONB
    type_data JSONB DEFAULT '{}',

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for common queries
CREATE INDEX IF NOT EXISTS idx_vendors_type ON vendors(type);
CREATE INDEX IF NOT EXISTS idx_vendors_is_live ON vendors(is_live);
CREATE INDEX IF NOT EXISTS idx_vendors_approval_status ON vendors(approval_status);
CREATE INDEX IF NOT EXISTS idx_vendors_city ON vendors(city);

-- ─── CONTENT CMS TABLES ─────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS instant_packages (
    id SERIAL PRIMARY KEY,
    is_active BOOLEAN DEFAULT TRUE,
    title JSONB NOT NULL DEFAULT '{}',
    category JSONB NOT NULL DEFAULT '{}',
    price TEXT NOT NULL DEFAULT '',
    period JSONB NOT NULL DEFAULT '{}',
    emoji TEXT DEFAULT '',
    tag JSONB DEFAULT '{}',
    tag_color BIGINT DEFAULT 4278255489,
    amenity1_text JSONB DEFAULT '{}',
    amenity2_text JSONB DEFAULT '{}',
    amenity3_text JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS featured_deals (
    id SERIAL PRIMARY KEY,
    is_active BOOLEAN DEFAULT TRUE,
    title JSONB NOT NULL DEFAULT '{}',
    description JSONB NOT NULL DEFAULT '{}',
    cta_text JSONB NOT NULL DEFAULT '{}',
    background_color TEXT DEFAULT '#1A0A2E',
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vip_concierge (
    id SERIAL PRIMARY KEY,
    is_active BOOLEAN DEFAULT TRUE,
    headline JSONB NOT NULL DEFAULT '{}',
    description JSONB NOT NULL DEFAULT '{}',
    features JSONB DEFAULT '[]',
    cta_text JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS banners (
    id SERIAL PRIMARY KEY,
    is_active BOOLEAN DEFAULT TRUE,
    title JSONB NOT NULL DEFAULT '{}',
    subtitle JSONB NOT NULL DEFAULT '{}',
    tag_label JSONB DEFAULT '{}',
    background_color TEXT DEFAULT '#1A0A2E',
    display_order INTEGER DEFAULT 0,
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS footer (
    id SERIAL PRIMARY KEY,
    is_active BOOLEAN DEFAULT TRUE,
    company_description JSONB NOT NULL DEFAULT '{}',
    contact_email TEXT DEFAULT '',
    phone_number TEXT DEFAULT '',
    social_links JSONB DEFAULT '{}',
    legal_text JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── FEATURE TOGGLES ────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS feature_toggles (
    feature_key TEXT PRIMARY KEY,
    display_name TEXT NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE
);

-- Seed default feature toggles
INSERT INTO feature_toggles (feature_key, display_name, is_enabled) VALUES
    ('home_packages', 'Home Packages', true),
    ('featured_deals', 'Featured Deals', true),
    ('vip_concierge', 'VIP Concierge', true),
    ('banners', 'Hero Banners', true),
    ('wishlist', 'Wishlist', true),
    ('cart', 'Cart', true),
    ('bookings', 'Bookings', true)
ON CONFLICT (feature_key) DO NOTHING;

-- ─── CART TABLE ─────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS cart_items (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    vendor_id TEXT NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    sku_name TEXT NOT NULL DEFAULT '',
    sku_price DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    quantity INTEGER DEFAULT 1,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cart_items_user_id ON cart_items(user_id);

-- ─── ESCROW / MILESTONES TABLE ──────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS escrow_milestones (
    id SERIAL PRIMARY KEY,
    booking_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    vendor_id TEXT NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT '',
    amount DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    status TEXT NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'FUNDED', 'RELEASED', 'DISPUTED', 'REFUNDED')),
    due_date TIMESTAMPTZ,
    funded_at TIMESTAMPTZ,
    released_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_escrow_booking_id ON escrow_milestones(booking_id);
CREATE INDEX IF NOT EXISTS idx_escrow_user_id ON escrow_milestones(user_id);

-- ─── CRM CONTACTS TABLE ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS crm_contacts (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL DEFAULT '',
    email TEXT DEFAULT '',
    phone TEXT DEFAULT '',
    vendor_id TEXT REFERENCES vendors(id) ON DELETE SET NULL,
    contact_type TEXT DEFAULT 'lead' CHECK (contact_type IN ('lead', 'vendor', 'client', 'partner')),
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'converted')),
    notes TEXT DEFAULT '',
    tags TEXT[] DEFAULT '{}',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_crm_contacts_vendor_id ON crm_contacts(vendor_id);
CREATE INDEX IF NOT EXISTS idx_crm_contacts_type ON crm_contacts(contact_type);

-- ─── CRM INTERACTIONS TABLE ────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS crm_interactions (
    id SERIAL PRIMARY KEY,
    contact_id INTEGER REFERENCES crm_contacts(id) ON DELETE CASCADE,
    interaction_type TEXT NOT NULL DEFAULT 'note' CHECK (interaction_type IN ('call', 'email', 'meeting', 'note', 'whatsapp')),
    subject TEXT DEFAULT '',
    body TEXT DEFAULT '',
    outcome TEXT DEFAULT '',
    scheduled_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_by TEXT DEFAULT '',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_crm_interactions_contact_id ON crm_interactions(contact_id);

-- ─── BOOKINGS TABLE ─────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS bookings (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    vendor_id TEXT NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
    event_date TIMESTAMPTZ,
    event_type TEXT DEFAULT '',
    guest_count INTEGER DEFAULT 0,
    total_amount DOUBLE PRECISION DEFAULT 0.0,
    advance_paid DOUBLE PRECISION DEFAULT 0.0,
    status TEXT DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED')),
    notes TEXT DEFAULT '',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_vendor_id ON bookings(vendor_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);

-- ─── SHORTLISTS TABLE (user wishlists) ──────────────────────────────────────

CREATE TABLE IF NOT EXISTS shortlists (
    id SERIAL PRIMARY KEY,
    user_id TEXT NOT NULL,
    vendor_id TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, vendor_id)
);

CREATE INDEX IF NOT EXISTS idx_shortlists_user_id ON shortlists(user_id);
CREATE INDEX IF NOT EXISTS idx_shortlists_vendor_id ON shortlists(vendor_id);

-- ─── GALLERY ITEMS TABLE (shoppable gallery) ────────────────────────────────

CREATE TABLE IF NOT EXISTS gallery_items (
    id SERIAL PRIMARY KEY,
    vendor_id TEXT NOT NULL REFERENCES vendors(id),
    image_url TEXT NOT NULL,
    category TEXT NOT NULL,
    caption TEXT DEFAULT '',
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_gallery_items_vendor_id ON gallery_items(vendor_id);
CREATE INDEX IF NOT EXISTS idx_gallery_items_category ON gallery_items(category);

-- ─── CHAT CONVERSATIONS TABLE ───────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS chat_conversations (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    vendor_id TEXT NOT NULL,
    last_message TEXT DEFAULT '',
    last_message_at TIMESTAMPTZ DEFAULT NOW(),
    unread_count INT DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_chat_conversations_user_id ON chat_conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_vendor_id ON chat_conversations(vendor_id);

-- ─── CHAT MESSAGES TABLE ────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS chat_messages (
    id SERIAL PRIMARY KEY,
    conversation_id TEXT NOT NULL,
    sender_id TEXT NOT NULL,
    receiver_id TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation_id ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_sender_id ON chat_messages(sender_id);

-- ─── ROW LEVEL SECURITY (basic — enable for all tables) ─────────────────────

ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE instant_packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE featured_deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE vip_concierge ENABLE ROW LEVEL SECURITY;
ALTER TABLE banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE footer ENABLE ROW LEVEL SECURITY;
ALTER TABLE feature_toggles ENABLE ROW LEVEL SECURITY;
ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE escrow_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_interactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE shortlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Public read access for content tables (anyone can read published content)
CREATE POLICY "Public read access" ON vendors FOR SELECT USING (true);
CREATE POLICY "Public read access" ON instant_packages FOR SELECT USING (true);
CREATE POLICY "Public read access" ON featured_deals FOR SELECT USING (true);
CREATE POLICY "Public read access" ON vip_concierge FOR SELECT USING (true);
CREATE POLICY "Public read access" ON banners FOR SELECT USING (true);
CREATE POLICY "Public read access" ON footer FOR SELECT USING (true);
CREATE POLICY "Public read access" ON feature_toggles FOR SELECT USING (true);

-- Public write access for now (you can restrict later with auth)
CREATE POLICY "Public write access" ON vendors FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON instant_packages FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON featured_deals FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON vip_concierge FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON banners FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON footer FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON feature_toggles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON cart_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON escrow_milestones FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON crm_contacts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON crm_interactions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON bookings FOR ALL USING (true) WITH CHECK (true);

-- Public read access for gallery items
CREATE POLICY "Public read access" ON gallery_items FOR SELECT USING (true);

-- Public write access for new tables (restrict later with proper auth)
CREATE POLICY "Public write access" ON shortlists FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON gallery_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON chat_conversations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON chat_messages FOR ALL USING (true) WITH CHECK (true);

-- ─── AUTO-UPDATE updated_at TRIGGER ─────────────────────────────────────────

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_vendors_updated_at BEFORE UPDATE ON vendors FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_instant_packages_updated_at BEFORE UPDATE ON instant_packages FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_featured_deals_updated_at BEFORE UPDATE ON featured_deals FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_vip_concierge_updated_at BEFORE UPDATE ON vip_concierge FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_banners_updated_at BEFORE UPDATE ON banners FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_footer_updated_at BEFORE UPDATE ON footer FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_cart_items_updated_at BEFORE UPDATE ON cart_items FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_escrow_milestones_updated_at BEFORE UPDATE ON escrow_milestones FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_contacts_updated_at BEFORE UPDATE ON crm_contacts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_crm_interactions_updated_at BEFORE UPDATE ON crm_interactions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
