-- ====================================================================
-- SECOND SHELF - Secure Admin Provisioning Script (PostgreSQL / Supabase)
-- Single Administrator Provisioning Process
-- Run this in your Supabase SQL Editor once during setup
-- ====================================================================

DO $$
DECLARE
  v_admin_email TEXT := 'admin@secondshelf.in';  -- Change to your desired admin email
  v_admin_password TEXT := 'AdminSecure@2026';    -- Change to your secure admin password
  v_admin_user_id UUID;
  v_existing_admin_count INT;
BEGIN
  -- 1. Ensure strictly only ONE admin can exist
  SELECT COUNT(*) INTO v_existing_admin_count
  FROM public.user_roles
  WHERE role = 'admin';

  IF v_existing_admin_count > 0 THEN
    RAISE NOTICE 'An admin account already exists. Updating existing admin clearance...';
    SELECT user_id INTO v_admin_user_id
    FROM public.user_roles
    WHERE role = 'admin'
    LIMIT 1;

    -- Update the password and email in auth.users
    UPDATE auth.users
    SET 
      email = v_admin_email,
      encrypted_password = crypt(v_admin_password, gen_salt('bf')),
      email_confirmed_at = NOW(),
      updated_at = NOW()
    WHERE id = v_admin_user_id;

    UPDATE public.profiles
    SET 
      email = v_admin_email,
      full_name = 'Second Shelf Administrator',
      is_verified = true
    WHERE id = v_admin_user_id;

  ELSE
    -- 2. Create the single Admin User in auth.users
    v_admin_user_id := gen_random_uuid();

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
    )
    VALUES (
      '00000000-0000-0000-0000-000000000000',
      v_admin_user_id,
      'authenticated',
      'authenticated',
      v_admin_email,
      crypt(v_admin_password, gen_salt('bf')),
      NOW(),
      '{"provider":"email","providers":["email"]}',
      '{"full_name":"Second Shelf Administrator","role":"admin"}',
      NOW(),
      NOW()
    );

    -- 3. Create Admin Profile
    INSERT INTO public.profiles (
      id,
      email,
      full_name,
      phone,
      age_confirmed,
      is_verified
    )
    VALUES (
      v_admin_user_id,
      v_admin_email,
      'Second Shelf Administrator',
      '+91 98765 43210',
      true,
      true
    )
    ON CONFLICT (id) DO UPDATE SET
      email = EXCLUDED.email,
      is_verified = true;

    -- 4. Assign Single Admin Role
    INSERT INTO public.user_roles (
      user_id,
      role,
      is_approved
    )
    VALUES (
      v_admin_user_id,
      'admin',
      true
    )
    ON CONFLICT (user_id, role) DO NOTHING;

    -- 5. Record initial audit log entry
    INSERT INTO public.admin_audit_logs (
      admin_id,
      action,
      target_type,
      target_id,
      details
    )
    VALUES (
      v_admin_user_id,
      'ADMIN_PROVISIONED',
      'SYSTEM',
      v_admin_user_id,
      jsonb_build_object('email', v_admin_email, 'timestamp', NOW())
    );

    RAISE NOTICE 'Admin provisioned successfully with email: %', v_admin_email;
  END IF;
END $$;
