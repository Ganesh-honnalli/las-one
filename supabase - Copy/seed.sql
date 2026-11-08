-- ====================================================================
-- SECOND SHELF - Seed Data for PostgreSQL / Supabase
-- Populates initial categories, valuation rules, and demo accounts
-- ====================================================================

-- 1. VALUATION RULES (Configurable maximum percentages)
INSERT INTO public.valuation_rules (condition_name, max_percentage, description)
VALUES 
    ('Like New', 30.00, 'Unmarked, crisp pages, intact spine, minimal shelf wear. Max 30% of original price.'),
    ('Good', 30.00, 'Clean interior, minor cover creases or neat highlighting. Max 30% of original price.'),
    ('Used', 20.00, 'Standard second-hand condition, readable, moderate highlighting. Max 20% of original price.'),
    ('Old or Damaged', 15.00, 'Heavily used, aging paper, binding wear, but 100% complete with no missing pages. Max 15% of original price.')
ON CONFLICT (condition_name) DO UPDATE 
SET max_percentage = EXCLUDED.max_percentage, description = EXCLUDED.description;

-- 2. CATEGORIES
INSERT INTO public.categories (name, slug, description, display_order)
VALUES 
    ('Degree Books', 'degree-books', 'Undergraduate and postgraduate textbooks for B.Sc, B.Com, B.A, BBA, BCA, etc.', 1),
    ('PUC Books', 'puc-books', 'Karnataka 1st and 2nd PUC textbooks (Science, Commerce, Arts).', 2),
    ('Class 10th / SSLC Books', 'sslc-10th-books', 'KSEEB, CBSE & ICSE Class 10th textbooks and study guides.', 3),
    ('School Books', 'school-books', 'General school books for Primary and High School classes 1 to 9.', 4),
    ('Engineering Books', 'engineering-books', 'VTU, autonomous and university engineering textbooks across all branches.', 5),
    ('Medical and Competitive Exam Books', 'medical-competitive-exam', 'NEET, JEE, KCET, UPSC, GATE, KPSC preparation books and manuals.', 6),
    ('Story Books and Novels', 'story-books-novels', 'Kannada & English literature, fiction, non-fiction, biographies and classics.', 7),
    ('Other Educational Books', 'other-educational', 'Dictionaries, encyclopedias, reference guides and general education material.', 8)
ON CONFLICT (name) DO NOTHING;

-- 3. DEMO ACCOUNTS (Profiles)
-- IDs use deterministic UUIDs for seed linking
INSERT INTO public.profiles (id, email, full_name, phone_number, role, is_verified, age_confirmed)
VALUES 
    -- Admin
    ('a0000000-0000-0000-0000-000000000001', 'admin@secondshelf.in', 'Antigravity Super Admin', '+91 98765 43210', 'admin', TRUE, TRUE),
    
    -- Seller 1 (Priya Sharma)
    ('b0000000-0000-0000-0000-000000000001', 'priya.sharma@gmail.com', 'Priya Sharma (Student)', '+91 98451 12345', 'seller', TRUE, TRUE),
    
    -- Seller 2 (Ramesh Kumar)
    ('b0000000-0000-0000-0000-000000000002', 'ramesh.kumar@yahoo.com', 'Ramesh Kumar', '+91 97402 98765', 'seller', TRUE, TRUE),
    
    -- Book Stall 1 (Approved - Vidyarthi Book House)
    ('c0000000-0000-0000-0000-000000000001', 'vidyarthi.books@avenue.in', 'Rajesh Gowda (Vidyarthi Books)', '+91 98440 22334', 'book_stall', TRUE, TRUE),
    
    -- Book Stall 2 (Pending - Sapna Used Book Corner)
    ('c0000000-0000-0000-0000-000000000002', 'sapna.corner@books.in', 'Mahesh Hegde (Sapna Corner)', '+91 94480 33445', 'book_stall', TRUE, TRUE),
    
    -- Raddi Owner 1 (Approved - Karnataka Eco Recyclers)
    ('d0000000-0000-0000-0000-000000000001', 'anand@ecorecyclers.in', 'Anand Rao (Eco Recyclers)', '+91 99001 55667', 'raddi_owner', TRUE, TRUE),
    
    -- Raddi Owner 2 (Pending - Green Paper Traders)
    ('d0000000-0000-0000-0000-000000000002', 'syed@greenpaper.in', 'Syed Khaleel (Green Paper)', '+91 98860 66778', 'raddi_owner', TRUE, TRUE)
ON CONFLICT (id) DO NOTHING;

-- 4. BOOK STALL RECORDS
INSERT INTO public.book_stalls (id, user_id, stall_name, shop_licence_or_gst, address, pin_code, city, state, contact_phone, contact_email, offers_pickup, admin_approval_status)
VALUES 
    ('e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'Vidyarthi Book House', 'KA-BBMP-BL-2018-9941', 'Shop #14, Avenue Road, Opp. State Bank of India, Chickpet', '560002', 'Bengaluru', 'Karnataka', '+91 98440 22334', 'vidyarthi.books@avenue.in', TRUE, 'approved'),
    ('e0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000002', 'Sapna Used Book Corner', 'KA-BBMP-BL-2022-3841', 'Shop #8, Gandhi Bazaar Main Road, Basavanagudi', '560004', 'Bengaluru', 'Karnataka', '+91 94480 33445', 'sapna.corner@books.in', FALSE, 'pending')
ON CONFLICT (id) DO NOTHING;

-- 5. RADDI OWNER RECORDS
INSERT INTO public.raddi_owners (id, user_id, business_name, licence_number, base_address, operating_pin_codes, city, state, contact_phone, contact_email, admin_approval_status)
VALUES 
    ('f0000000-0000-0000-0000-000000000001', 'd0000000-0000-0000-0000-000000000001', 'Karnataka Eco Recyclers', 'KSPCB-HAZ-REC-2020-112', 'Yard #42, Industrial Area, Rajajinagar 1st Block', ARRAY['560001','560002','560010','560041','560070'], 'Bengaluru', 'Karnataka', '+91 99001 55667', 'anand@ecorecyclers.in', 'approved'),
    ('f0000000-0000-0000-0000-000000000002', 'd0000000-0000-0000-0000-000000000002', 'Green Paper Traders', 'KSPCB-HAZ-REC-2023-450', 'Shed 12, Mysuru Road, Nayandahalli', ARRAY['560039','560040','560050'], 'Bengaluru', 'Karnataka', '+91 98860 66778', 'syed@greenpaper.in', 'pending')
ON CONFLICT (id) DO NOTHING;

-- 6. DEMO BOOK REQUESTS
INSERT INTO public.book_requests (id, request_number, seller_id, assigned_stall_id, status, preferred_handover_method, seller_address, seller_pin_code, total_original_price, total_estimated_payout, notes)
VALUES 
    ('10000000-0000-0000-0000-000000000001', 'BOK-2026-0001', 'b0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'Payment Pending', 'direct_stall_handover', '#24, 7th Cross, Jayanagar 4th Block', '560041', 1450.00, 395.00, 'VTU Computer Science 3rd semester books in great shape'),
    ('10000000-0000-0000-0000-000000000002', 'BOK-2026-0002', 'b0000000-0000-0000-0000-000000000001', NULL, 'Pending', 'arranged_pickup', '#24, 7th Cross, Jayanagar 4th Block', '560041', 850.00, 255.00, 'NEET Prep Biology & Chemistry guides')
ON CONFLICT (id) DO NOTHING;

-- 7. DEMO BOOK ITEMS
INSERT INTO public.book_items (id, book_request_id, title, author, isbn, class_or_semester, publisher, edition, original_price, condition, number_of_copies, front_cover_url, back_cover_url, inside_page_url, estimated_item_payout)
VALUES 
    ('20000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', 'Data Structures Using C', 'Reema Thareja', '978-0198099307', '3rd Sem B.E (CSE)', 'Oxford University Press', '2nd Edition', 650.00, 'Like New', 1, 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500', 195.00),
    ('20000000-0000-0000-0000-000000000002', '10000000-0000-0000-0000-000000000001', 'Discrete Mathematics and Its Applications', 'Kenneth H. Rosen', '978-0070681880', '3rd Sem B.E', 'McGraw Hill', '7th Edition', 800.00, 'Good', 1, 'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?w=500', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=500', 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=500', 200.00),
    ('20000000-0000-0000-0000-000000000003', '10000000-0000-0000-0000-000000000002', 'Objective Biology for NEET Vol 1', 'Dr. Ali', '978-9386320114', 'NEET / Medical', 'MTG Learning', '2023 Edition', 850.00, 'Like New', 1, 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=500', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500', 255.00)
ON CONFLICT (id) DO NOTHING;

-- 8. DEMO RADDI REQUESTS (Strictly >= 10 kg)
INSERT INTO public.waste_requests (id, request_number, seller_id, assigned_raddi_owner_id, paper_type, estimated_weight_kg, seller_name, seller_phone, seller_email, pickup_address, pickup_pin_code, pickup_area, preferred_pickup_date, preferred_time_slot, notes, status, actual_weight_kg, offered_rate_per_kg, final_amount)
VALUES 
    ('30000000-0000-0000-0000-000000000001', 'RAD-2026-0001', 'b0000000-0000-0000-0000-000000000001', 'f0000000-0000-0000-0000-000000000001', 'Newspapers', 25.00, 'Priya Sharma', '+91 98451 12345', 'priya.sharma@gmail.com', '#24, 7th Cross, Jayanagar 4th Block, Near Cool Joint', '560041', 'Jayanagar 4th Block', '2026-10-28', 'Morning (9 AM - 12 PM)', '6 months of English & Kannada newspapers bundled with twine.', 'Payment Pending', 26.50, 14.00, 371.00),
    ('30000000-0000-0000-0000-000000000002', 'RAD-2026-0002', 'b0000000-0000-0000-0000-000000000002', NULL, 'Notebooks', 15.00, 'Ramesh Kumar', '+91 97402 98765', 'ramesh.kumar@yahoo.com', '#102, Shanti Nilaya, 3rd Stage, Basaveshwaranagar', '560079', 'Basaveshwaranagar', '2026-10-29', 'Afternoon (2 PM - 5 PM)', 'Old college long notebooks and project drafts.', 'Pending', NULL, NULL, NULL)
ON CONFLICT (id) DO NOTHING;

-- 9. DEMO PAYMENTS (Two-party verification records)
INSERT INTO public.payments (id, transaction_type, book_request_id, payer_user_id, seller_user_id, amount, payment_method, payment_reference_utr, payment_date, notes, payer_recorded_at, status)
VALUES 
    ('40000000-0000-0000-0000-000000000001', 'book', '10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'b0000000-0000-0000-0000-000000000001', 395.00, 'upi', 'UPI/261025884920/GPay', CURRENT_DATE, 'Transferred to Priya via Google Pay. Inspected condition matches Like New & Good.', NOW(), 'pending_confirmation')
ON CONFLICT (id) DO NOTHING;
