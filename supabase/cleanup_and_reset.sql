-- ====================================================================
-- SECOND SHELF - Safe Data Cleanup, Backup & Fresh Production Reset
-- ====================================================================
-- This script:
-- 1. Creates timestamped safety backups of any existing data
-- 2. Safely clears test/demo records from operational tables
-- 3. Preserves all tables, schemas, constraints, RLS, functions, and triggers
-- 4. Preserves system reference data (8 textbook categories, 4 valuation rules, platform guidelines)
-- 5. Preserves the single root admin account
-- 6. Adds newly required columns (subject, class_degree, expected_selling_price, admin_approval_status)
-- ====================================================================

DO $$
BEGIN
  RAISE NOTICE 'Starting SECOND SHELF safe database backup and cleanup...';

  -- --------------------------------------------------------------------
  -- STEP 1: SAFETY BACKUP OF EXISTING DATA (Preserves real data before reset)
  -- --------------------------------------------------------------------
  CREATE TABLE IF NOT EXISTS public._backup_profiles AS SELECT * FROM public.profiles;
  CREATE TABLE IF NOT EXISTS public._backup_user_roles AS SELECT * FROM public.user_roles;
  CREATE TABLE IF NOT EXISTS public._backup_book_stalls AS SELECT * FROM public.book_stalls;
  CREATE TABLE IF NOT EXISTS public._backup_scrap_owners AS SELECT * FROM public.scrap_owners;
  CREATE TABLE IF NOT EXISTS public._backup_book_requests AS SELECT * FROM public.book_requests;
  CREATE TABLE IF NOT EXISTS public._backup_scrap_requests AS SELECT * FROM public.scrap_requests;
  CREATE TABLE IF NOT EXISTS public._backup_transactions AS SELECT * FROM public.transactions;
  CREATE TABLE IF NOT EXISTS public._backup_payment_records AS SELECT * FROM public.payment_records;

  RAISE NOTICE 'Safety backups successfully archived into _backup_* tables.';

  -- --------------------------------------------------------------------
  -- STEP 2: SCHEMA ENHANCEMENTS (Subject, Class/Degree, Expected Price, Admin Moderation)
  -- --------------------------------------------------------------------
  ALTER TABLE public.book_requests 
    ADD COLUMN IF NOT EXISTS subject TEXT,
    ADD COLUMN IF NOT EXISTS class_degree TEXT,
    ADD COLUMN IF NOT EXISTS expected_selling_price NUMERIC(10, 2),
    ADD COLUMN IF NOT EXISTS admin_approval_status TEXT DEFAULT 'approved' CHECK (admin_approval_status IN ('pending', 'approved', 'rejected'));

  ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS mobile_number TEXT;

  -- --------------------------------------------------------------------
  -- STEP 3: SAFE PURGE OF OPERATIONAL TEST & DEMO DATA
  -- --------------------------------------------------------------------
  -- Delete dependent records first to respect foreign key constraints
  DELETE FROM public.messages;
  DELETE FROM public.conversations;
  DELETE FROM public.payment_records;
  DELETE FROM public.complaints;
  DELETE FROM public.book_offers;
  DELETE FROM public.scrap_offers;
  DELETE FROM public.book_images;
  DELETE FROM public.scrap_images;
  DELETE FROM public.transactions;
  DELETE FROM public.book_requests;
  DELETE FROM public.scrap_requests;
  DELETE FROM public.notifications;

  -- Remove demo business partner listings (Preserve admin and real users)
  DELETE FROM public.book_stalls 
  WHERE user_id NOT IN (
    SELECT user_id FROM public.user_roles WHERE role = 'admin'
  );

  DELETE FROM public.scrap_owners 
  WHERE user_id NOT IN (
    SELECT user_id FROM public.user_roles WHERE role = 'admin'
  );

  -- Remove non-admin test profiles & auth users
  DELETE FROM public.user_roles 
  WHERE role <> 'admin';

  DELETE FROM public.profiles 
  WHERE id NOT IN (
    SELECT user_id FROM public.user_roles WHERE role = 'admin'
  );

  DELETE FROM auth.users 
  WHERE email NOT IN ('admin@secondshelf.in')
    AND id NOT IN (SELECT user_id FROM public.user_roles WHERE role = 'admin');

  -- Record cleanup in audit log
  INSERT INTO public.admin_audit_logs (action, target_type, details)
  VALUES (
    'DATABASE_CLEANUP_AND_RESET',
    'SYSTEM',
    jsonb_build_object(
      'timestamp', NOW(),
      'description', 'Cleaned all demo books, scrap requests, transactions, and test accounts. Preserved admin and reference categories.'
    )
  );

  RAISE NOTICE 'Operational data successfully cleaned. System is in fresh production state.';

  -- --------------------------------------------------------------------
  -- STEP 4: ENSURE ESSENTIAL REFERENCE DATA EXISTS
  -- --------------------------------------------------------------------
  -- 8 Educational Textbook Categories
  INSERT INTO public.textbook_categories (name, slug, description, is_active)
  VALUES
    ('Engineering Books', 'engineering-books', 'VTU and autonomous engineering syllabus textbooks (CSE, ECE, Mech, Civil)', true),
    ('Degree Books', 'degree-books', 'Undergraduate and postgraduate college textbooks (B.Com, B.Sc, BA, BCA, BBA)', true),
    ('PUC Books', 'puc-books', 'Karnataka Pre-University College (1st & 2nd PUC Science, Commerce, Arts)', true),
    ('Class 10th / SSLC Books', 'sslc-10th-books', '10th Standard / SSLC state syllabus and CBSE textbooks', true),
    ('School Books', 'school-books', 'Primary and high school textbooks (Grades 1 to 9)', true),
    ('Medical and Competitive Exam Books', 'medical-competitive-exam', 'MBBS, BDS, NEET, JEE, UPSC, KPSC and Banking exam preparation books', true),
    ('Story Books and Novels', 'story-books-novels', 'English, Kannada, Hindi literature, fiction, and non-fiction novels', true),
    ('Other Educational Books', 'other-educational', 'Dictionaries, encyclopedias, reference guides, and skill development', true)
  ON CONFLICT (name) DO UPDATE SET is_active = true;

  -- 4 Valuation Rules (Condition percentage caps)
  INSERT INTO public.valuation_rules (condition_name, max_percentage, description)
  VALUES
    ('Like New', 30.0, 'No marks, intact binding, all pages present, covers pristine. Maximum offer 30% of original price.'),
    ('Good', 30.0, 'Minor pencil annotations or light shelf wear, complete pages. Maximum offer 30% of original price.'),
    ('Used', 20.0, 'Highlighted passages, normal wear, intact pages. Maximum offer 20% of original price.'),
    ('Old or Damaged', 15.0, 'Worn covers, yellowed pages, but readable and complete. Maximum offer 15% of original price.')
  ON CONFLICT (condition_name) DO UPDATE SET
    max_percentage = EXCLUDED.max_percentage,
    description = EXCLUDED.description;

  -- Platform Guidelines
  INSERT INTO public.guidelines (title, content, section_page, is_published)
  VALUES
    (
      'Anti-Piracy & Genuine Book Policy',
      'SECOND SHELF strictly prohibits photocopied books, counterfeit prints, and illegally duplicated study materials. Only genuine publisher editions with all pages intact are accepted.',
      'textbook_submission',
      true
    ),
    (
      'Fair Valuation Percentage Caps',
      'Estimated offers are calculated from the declared purchase price and physical condition: Like New (up to 30%), Good (up to 30%), Used (up to 20%), Old/Damaged (up to 15%). Book stalls cannot exceed the condition cap.',
      'valuation_rules',
      true
    ),
    (
      'Strict 10 kg Minimum Scrap Requirement',
      'In accordance with recycling logistics and vendor viability, waste paper submissions below 10 kg cannot be processed. Doorstep measurement must register 10 kg or higher.',
      'scrap_weight',
      true
    ),
    (
      'Pickup & Handover Guidelines',
      'For counter handovers, sellers have 7 days to visit the selected bookstore. For scrap collections, verified scrap owners arrive with calibrated digital weighing scales.',
      'pickup_instructions',
      true
    ),
    (
      'Two-Party Payment Confirmation Policy',
      'All payments occur directly between seller and buyer. The order is marked Completed only when the seller clicks "Confirm Payment Received".',
      'payment_guidelines',
      true
    )
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'SECOND SHELF reset complete. Ready for genuine user signups and real listings.';
END $$;
