-- Migration: Create supporting tables for client panel revamp
-- Tables: shortlists, gallery_items, chat_messages, chat_conversations
-- Requirements: 12.1 (Wishlist/Shortlist), 14.1 (Shoppable Gallery), 15.1 (Chat)

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

-- ─── ROW LEVEL SECURITY ─────────────────────────────────────────────────────

ALTER TABLE shortlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE gallery_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Public read access for gallery items (anyone can browse the gallery)
CREATE POLICY "Public read access" ON gallery_items FOR SELECT USING (true);

-- Public write access for now (restrict later with proper auth)
CREATE POLICY "Public write access" ON shortlists FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON gallery_items FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON chat_conversations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public write access" ON chat_messages FOR ALL USING (true) WITH CHECK (true);
