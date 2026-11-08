-- ====================================================================
-- SECOND SHELF - Seed Data for Supabase PostgreSQL
-- ====================================================================

-- 1. Textbook Categories
INSERT INTO public.textbook_categories (name, slug, description, is_active)
VALUES
  ('Degree Books', 'degree-books', 'Undergraduate and postgraduate college textbooks (B.Com, B.Sc, BA, BCA, BBA)', true),
  ('PUC Books', 'puc-books', 'Karnataka Pre-University College (1st & 2nd PUC Science, Commerce, Arts)', true),
  ('Class 10th / SSLC Books', 'sslc-10th-books', '10th Standard / SSLC state syllabus and CBSE textbooks', true),
  ('School Books', 'school-books', 'Primary and high school textbooks (Grades 1 to 9)', true),
  ('Engineering Books', 'engineering-books', 'VTU and autonomous engineering syllabus textbooks (CSE, ECE, Mech, Civil)', true),
  ('Medical and Competitive Exam Books', 'medical-competitive-exam', 'MBBS, BDS, NEET, JEE, UPSC, KPSC and Banking exam preparation books', true),
  ('Story Books and Novels', 'story-books-novels', 'English, Kannada, Hindi literature, fiction, and non-fiction novels', true),
  ('Other Educational Books', 'other-educational', 'Dictionaries, encyclopedias, reference guides, and skill development', true)
ON CONFLICT (name) DO NOTHING;

-- 2. Valuation Rules (Configurable Condition Payout Caps)
INSERT INTO public.valuation_rules (condition_name, max_percentage, description)
VALUES
  ('Like New', 30.0, 'No marks, intact binding, all pages present, covers pristine. Maximum offer 30% of original price.'),
  ('Good', 30.0, 'Minor pencil annotations or light shelf wear, complete pages. Maximum offer 30% of original price.'),
  ('Used', 20.0, 'Highlighted passages, normal wear, intact pages. Maximum offer 20% of original price.'),
  ('Old or Damaged', 15.0, 'Worn covers, yellowed pages, but readable and complete. Maximum offer 15% of original price.')
ON CONFLICT (condition_name) DO UPDATE SET
  max_percentage = EXCLUDED.max_percentage,
  description = EXCLUDED.description;

-- 3. Initial Platform Guidelines (Admin Published)
INSERT INTO public.guidelines (title, content, section_page, is_published)
VALUES
  (
    'Anti-Piracy & Textbook Submission Rules',
    'SECOND SHELF strictly prohibits photocopied books, counterfeit prints, and illegally duplicated study materials. Only genuine publisher editions with all pages intact are accepted. Submitting pirated books results in immediate account termination across participating book stalls.',
    'textbook_submission',
    true
  ),
  (
    'Fair Valuation Percentage Caps',
    'Estimated offers are calculated from the declared purchase price and physical condition: Like New (up to 30%), Good (up to 30%), Used (up to 20%), Old/Damaged (up to 15%). Book stalls may quote lower upon physical inspection but can never exceed the condition cap.',
    'valuation_rules',
    true
  ),
  (
    'Strict 10 kg Minimum Scrap Requirement',
    'In accordance with recycling logistics and vendor viability, waste paper submissions below 10 kg cannot be processed. If doorstep measurement registers below 10 kg, the scrap dealer may decline pickup or propose an updated rate without penalty to the seller.',
    'scrap_weight',
    true
  ),
  (
    'Pickup & Handover Guidelines',
    'For counter handovers, sellers have 7 days to visit the selected bookstore. For scrap collections, verified scrap owners arrive with calibrated digital weighing scales. Both parties must witness and verify the weight reading.',
    'pickup_instructions',
    true
  ),
  (
    'Two-Party Payment Confirmation Policy',
    'SECOND SHELF is a marketplace facilitator and does not hold funds in escrow. All payments (UPI, Cash in Hand, Bank Transfer) occur directly between seller and buyer. The buyer records the payment reference (UTR), and the order is marked Completed only when the seller clicks "Confirm Payment Received".',
    'payment_guidelines',
    true
  );
