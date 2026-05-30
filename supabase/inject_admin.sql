-- ============================================================
-- GoMandap - Inject Admin Credentials Script
-- ============================================================
-- Run this script in your Supabase SQL Editor (Dashboard > SQL Editor)
-- This will insert the admin user into the auth tables so you can log in.

-- Enable pgcrypto if it's not already enabled (needed for encrypting passwords)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$ 
DECLARE
  new_user_id uuid := gen_random_uuid();
BEGIN
  -- 1. Insert into auth.users if they don't exist
  IF NOT EXISTS (SELECT 1 FROM auth.users WHERE email = 'admin@gomandap.com') THEN
    INSERT INTO auth.users (
      instance_id,
      id,
      aud,
      role,
      email,
      encrypted_password,
      email_confirmed_at,
      raw_app_meta_data,
      raw_user_meta_data,
      created_at,
      updated_at
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      new_user_id,
      'authenticated',
      'authenticated',
      'admin@gomandap.com',
      crypt('Gomandap@587487', gen_salt('bf')),
      now(),
      '{"provider":"email","providers":["email"]}',
      '{"name":"GoMandap Admin"}',
      now(),
      now()
    );

    -- 2. Insert into auth.identities
    INSERT INTO auth.identities (
      id,
      provider_id,
      user_id,
      identity_data,
      provider,
      last_sign_in_at,
      created_at,
      updated_at
    ) VALUES (
      gen_random_uuid(),
      new_user_id::text,
      new_user_id,
      format('{"sub":"%s","email":"admin@gomandap.com"}', new_user_id::text)::jsonb,
      'email',
      now(),
      now(),
      now()
    );
  END IF;
END $$;
