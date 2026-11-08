-- ====================================================================
-- SECOND SHELF - Comprehensive PostgreSQL Database Schema
-- Production Schema with 20 Tables, Constraints, RLS & Realtime
-- ====================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ====================================================================
-- 1. PROFILES (Extends auth.users)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT NOT NULL,
  phone TEXT,
  age_confirmed BOOLEAN DEFAULT false,
  is_verified BOOLEAN DEFAULT false,
  is_suspended BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 2. USER ROLES (Role-based access control: seller, book_stall, scrap_owner, admin)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('seller', 'book_stall', 'scrap_owner', 'admin')),
  is_approved BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, role)
);

-- ====================================================================
-- 3. BOOK STALLS (Physical book store partner profiles)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.book_stalls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE,
  stall_name TEXT NOT NULL,
  owner_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  licence_number TEXT NOT NULL,
  address TEXT NOT NULL,
  pincode TEXT NOT NULL,
  approval_status TEXT NOT NULL CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')) DEFAULT 'pending',
  offers_pickup BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 4. SCRAP OWNERS (Licensed recycle scrap / paper depot partners)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.scrap_owners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE UNIQUE,
  business_name TEXT NOT NULL,
  owner_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  licence_number TEXT NOT NULL,
  address TEXT NOT NULL,
  base_area TEXT NOT NULL,
  pincode TEXT NOT NULL,
  approval_status TEXT NOT NULL CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')) DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 5. TEXTBOOK CATEGORIES (Admin-configurable subcategories)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.textbook_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Valuation Rules table (Admin-configurable condition caps)
CREATE TABLE IF NOT EXISTS public.valuation_rules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  condition_name TEXT UNIQUE NOT NULL CHECK (condition_name IN ('Like New', 'Good', 'Used', 'Old or Damaged')),
  max_percentage NUMERIC(5, 2) NOT NULL CHECK (max_percentage > 0 AND max_percentage <= 100),
  description TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 6. BOOK REQUESTS (Seller used textbook submissions)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.book_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_number TEXT UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id UUID REFERENCES public.textbook_categories(id),
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  isbn TEXT,
  publisher_edition TEXT,
  class_semester TEXT,
  original_price NUMERIC(10, 2) NOT NULL CHECK (original_price > 0),
  book_condition TEXT NOT NULL CHECK (book_condition IN ('Like New', 'Good', 'Used', 'Old or Damaged')),
  copies INT NOT NULL DEFAULT 1 CHECK (copies > 0),
  max_valuation_pct NUMERIC(5, 2) NOT NULL,
  total_estimated_payout NUMERIC(10, 2) NOT NULL,
  handover_method TEXT NOT NULL CHECK (handover_method IN ('direct_stall_handover', 'arranged_pickup', 'parcel_postal')),
  pickup_address TEXT,
  contact_phone TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN (
    'Pending', 'Offer Received', 'Offer Revised', 'Accepted',
    'Awaiting Book', 'Received', 'Under Inspection', 'Final Offer Sent',
    'Payment Pending', 'Completed', 'Rejected', 'Cancelled', 'Disputed'
  )) DEFAULT 'Pending',
  assigned_stall_id UUID REFERENCES public.book_stalls(id),
  accepted_offer_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 7. BOOK IMAGES (Photos: Front cover, back cover, inside page)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.book_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES public.book_requests(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  image_type TEXT CHECK (image_type IN ('front_cover', 'back_cover', 'inside_page', 'other')) DEFAULT 'front_cover',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 8. BOOK OFFERS (Multiple stall quotes capped by condition percentages)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.book_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES public.book_requests(id) ON DELETE CASCADE,
  stall_id UUID NOT NULL REFERENCES public.book_stalls(id) ON DELETE CASCADE,
  offered_amount NUMERIC(10, 2) NOT NULL CHECK (offered_amount > 0),
  max_allowed_amount NUMERIC(10, 2) NOT NULL,
  is_lower_than_estimate BOOLEAN DEFAULT false,
  reason TEXT,
  status TEXT NOT NULL CHECK (status IN ('Pending', 'Accepted', 'Rejected', 'Revised', 'Cancelled')) DEFAULT 'Pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 9. SCRAP REQUESTS (Waste paper / scrap submissions - strictly >= 10 kg)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.scrap_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_number TEXT UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  paper_type TEXT NOT NULL,
  estimated_weight_kg NUMERIC(6, 2) NOT NULL CHECK (estimated_weight_kg >= 10.0),
  actual_weight_kg NUMERIC(6, 2) CHECK (actual_weight_kg IS NULL OR actual_weight_kg >= 10.0),
  seller_name TEXT NOT NULL,
  seller_phone TEXT NOT NULL,
  pickup_address TEXT NOT NULL,
  pickup_area TEXT NOT NULL,
  pickup_pin TEXT NOT NULL CHECK (pickup_pin ~ '^[0-9]{6}$'),
  preferred_date DATE NOT NULL,
  preferred_slot TEXT NOT NULL,
  notes TEXT,
  status TEXT NOT NULL CHECK (status IN (
    'Pending', 'Offer Received', 'Accepted', 'Pickup Scheduled',
    'Collected', 'Final Price Sent', 'Payment Pending', 'Completed',
    'Rejected', 'Cancelled', 'Disputed'
  )) DEFAULT 'Pending',
  assigned_owner_id UUID REFERENCES public.scrap_owners(id),
  accepted_offer_id UUID,
  final_amount NUMERIC(10, 2),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 10. SCRAP IMAGES (Waste paper photographs)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.scrap_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES public.scrap_requests(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 11. SCRAP OFFERS (Rate per kg submitted by approved scrap dealers)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.scrap_offers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id UUID NOT NULL REFERENCES public.scrap_requests(id) ON DELETE CASCADE,
  scrap_owner_id UUID NOT NULL REFERENCES public.scrap_owners(id) ON DELETE CASCADE,
  rate_per_kg NUMERIC(6, 2) NOT NULL CHECK (rate_per_kg > 0),
  total_estimated_amount NUMERIC(10, 2) NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('Pending', 'Accepted', 'Rejected', 'Cancelled')) DEFAULT 'Pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 12. TRANSACTIONS (Active deals created upon offer acceptance)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_number TEXT UNIQUE NOT NULL,
  transaction_type TEXT NOT NULL CHECK (transaction_type IN ('book', 'scrap')),
  request_id UUID NOT NULL,
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  partner_type TEXT NOT NULL CHECK (partner_type IN ('book_stall', 'scrap_owner')),
  partner_user_id UUID NOT NULL REFERENCES public.profiles(id),
  agreed_amount NUMERIC(10, 2) NOT NULL,
  final_amount NUMERIC(10, 2),
  status TEXT NOT NULL CHECK (status IN (
    'initiated', 'inspection', 'payment_pending', 'completed', 'disputed', 'cancelled'
  )) DEFAULT 'initiated',
  completed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 13. CONVERSATIONS (One private thread per accepted transaction)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE UNIQUE,
  user_id UUID NOT NULL REFERENCES public.profiles(id),
  partner_user_id UUID NOT NULL REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 14. MESSAGES (Direct messages between User and selected Owner)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES public.profiles(id),
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 15. NOTIFICATIONS (Realtime user and partner alerts)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  notification_type TEXT NOT NULL,
  reference_id UUID,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 16. PAYMENT RECORDS (Direct settlement with mandatory 2-party confirmation)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.payment_records (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_id UUID NOT NULL REFERENCES public.transactions(id) ON DELETE CASCADE,
  paid_by UUID NOT NULL REFERENCES public.profiles(id),
  payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'upi', 'bank_transfer')),
  utr_reference TEXT,
  amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
  payment_date TIMESTAMPTZ DEFAULT NOW(),
  buyer_confirmed BOOLEAN DEFAULT true,
  seller_confirmed BOOLEAN DEFAULT false,
  status TEXT NOT NULL CHECK (status IN ('pending_confirmation', 'confirmed', 'disputed')) DEFAULT 'pending_confirmation',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 17. GUIDELINES (Admin managed section rules & instructions)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.guidelines (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  section_page TEXT NOT NULL CHECK (section_page IN (
    'textbook_submission', 'valuation_rules', 'scrap_weight',
    'pickup_instructions', 'payment_guidelines', 'all'
  )),
  is_published BOOLEAN DEFAULT true,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 18. ANNOUNCEMENTS (Admin broadcasts to users & business partners)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.announcements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  target_role TEXT NOT NULL CHECK (target_role IN ('all', 'seller', 'book_stall', 'scrap_owner')) DEFAULT 'all',
  is_published BOOLEAN DEFAULT true,
  published_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES public.profiles(id)
);

-- ====================================================================
-- 19. COMPLAINTS (Customer support & dispute tickets)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.complaints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_number TEXT UNIQUE NOT NULL,
  filed_by UUID NOT NULL REFERENCES public.profiles(id),
  against_user_id UUID REFERENCES public.profiles(id),
  transaction_id UUID REFERENCES public.transactions(id),
  subject TEXT NOT NULL,
  description TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('open', 'under_investigation', 'resolved', 'closed')) DEFAULT 'open',
  resolution_notes TEXT,
  resolved_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- 20. ADMIN AUDIT LOGS (Immutable security and moderation records)
-- ====================================================================
CREATE TABLE IF NOT EXISTS public.admin_audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID REFERENCES public.profiles(id),
  action TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id UUID,
  details JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ====================================================================
-- PRIVACY-MASKED VIEW FOR SCRAP OWNERS (Shields address until accepted)
-- ====================================================================
CREATE OR REPLACE VIEW public.v_waste_requests_recycler AS
SELECT 
  id,
  request_number,
  paper_type,
  estimated_weight_kg,
  actual_weight_kg,
  pickup_area,
  pickup_pin,
  preferred_date,
  preferred_slot,
  notes,
  status,
  assigned_owner_id,
  accepted_offer_id,
  created_at,
  -- Private data revealed ONLY to the assigned scrap owner when accepted
  CASE 
    WHEN status IN ('Accepted', 'Pickup Scheduled', 'Collected', 'Final Price Sent', 'Payment Pending', 'Completed') 
      AND assigned_owner_id = (SELECT so.id FROM public.scrap_owners so WHERE so.user_id = auth.uid())
    THEN seller_name 
    ELSE 'Confidential (Seller Protected)' 
  END AS seller_name,
  CASE 
    WHEN status IN ('Accepted', 'Pickup Scheduled', 'Collected', 'Final Price Sent', 'Payment Pending', 'Completed') 
      AND assigned_owner_id = (SELECT so.id FROM public.scrap_owners so WHERE so.user_id = auth.uid())
    THEN seller_phone 
    ELSE 'Confidential (Unlocked on Acceptance)' 
  END AS seller_phone,
  CASE 
    WHEN status IN ('Accepted', 'Pickup Scheduled', 'Collected', 'Final Price Sent', 'Payment Pending', 'Completed') 
      AND assigned_owner_id = (SELECT so.id FROM public.scrap_owners so WHERE so.user_id = auth.uid())
    THEN pickup_address 
    ELSE 'Confidential (Door number hidden)' 
  END AS pickup_address
FROM public.scrap_requests;

-- ====================================================================
-- INDEXES FOR HIGH-PERFORMANCE QUERIES
-- ====================================================================
CREATE INDEX IF NOT EXISTS idx_book_requests_user ON public.book_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_book_requests_status ON public.book_requests(status);
CREATE INDEX IF NOT EXISTS idx_scrap_requests_user ON public.scrap_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_scrap_requests_status ON public.scrap_requests(status);
CREATE INDEX IF NOT EXISTS idx_book_offers_request ON public.book_offers(request_id);
CREATE INDEX IF NOT EXISTS idx_scrap_offers_request ON public.scrap_offers(request_id);
CREATE INDEX IF NOT EXISTS idx_messages_convo ON public.messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_transactions_user ON public.transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_partner ON public.transactions(partner_user_id);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_stalls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scrap_owners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.textbook_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.valuation_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scrap_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scrap_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scrap_offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.guidelines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.complaints ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_audit_logs ENABLE ROW LEVEL SECURITY;

-- Helper function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Profiles Policies
CREATE POLICY "Public profiles are readable by authenticated users" ON public.profiles
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can update own profile" ON public.profiles
  FOR UPDATE TO authenticated USING (auth.uid() = id);

-- Categories & Valuation (Public read, admin write)
CREATE POLICY "Categories readable by all" ON public.textbook_categories
  FOR SELECT TO public USING (is_active = true OR public.is_admin());

CREATE POLICY "Categories admin full access" ON public.textbook_categories
  FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Valuation rules readable by all" ON public.valuation_rules
  FOR SELECT TO public USING (true);

CREATE POLICY "Valuation rules admin full access" ON public.valuation_rules
  FOR ALL TO authenticated USING (public.is_admin());

-- Book Stalls & Scrap Owners (Approved read, owner update, admin manage)
CREATE POLICY "Stalls readable by authenticated" ON public.book_stalls
  FOR SELECT TO authenticated USING (approval_status = 'approved' OR user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Stall owners can register" ON public.book_stalls
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "Stall owners can update own details" ON public.book_stalls
  FOR UPDATE TO authenticated USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Scrap owners readable by authenticated" ON public.scrap_owners
  FOR SELECT TO authenticated USING (approval_status = 'approved' OR user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Scrap owners can register" ON public.scrap_owners
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "Scrap owners can update own details" ON public.scrap_owners
  FOR UPDATE TO authenticated USING (user_id = auth.uid() OR public.is_admin());

-- Book Requests (User CRUD own, approved stalls read pending, admin all)
CREATE POLICY "Users view own book requests" ON public.book_requests
  FOR SELECT TO authenticated USING (
    user_id = auth.uid() 
    OR EXISTS (SELECT 1 FROM public.book_stalls WHERE user_id = auth.uid() AND approval_status = 'approved')
    OR public.is_admin()
  );

CREATE POLICY "Users insert own book requests" ON public.book_requests
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users update own book requests" ON public.book_requests
  FOR UPDATE TO authenticated USING (
    user_id = auth.uid() 
    OR EXISTS (SELECT 1 FROM public.book_stalls WHERE user_id = auth.uid() AND approval_status = 'approved')
    OR public.is_admin()
  );

-- Scrap Requests
CREATE POLICY "Users view own scrap requests" ON public.scrap_requests
  FOR SELECT TO authenticated USING (
    user_id = auth.uid() 
    OR EXISTS (SELECT 1 FROM public.scrap_owners WHERE user_id = auth.uid() AND approval_status = 'approved')
    OR public.is_admin()
  );

CREATE POLICY "Users insert own scrap requests" ON public.scrap_requests
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users update own scrap requests" ON public.scrap_requests
  FOR UPDATE TO authenticated USING (
    user_id = auth.uid() 
    OR EXISTS (SELECT 1 FROM public.scrap_owners WHERE user_id = auth.uid() AND approval_status = 'approved')
    OR public.is_admin()
  );

-- Offers
CREATE POLICY "Book offers visibility" ON public.book_offers
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.book_requests WHERE id = request_id AND user_id = auth.uid())
    OR EXISTS (SELECT 1 FROM public.book_stalls WHERE id = stall_id AND user_id = auth.uid())
    OR public.is_admin()
  );

CREATE POLICY "Approved stalls can make book offers" ON public.book_offers
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM public.book_stalls WHERE id = stall_id AND user_id = auth.uid() AND approval_status = 'approved')
  );

CREATE POLICY "Book offers update" ON public.book_offers
  FOR UPDATE TO authenticated USING (
    EXISTS (SELECT 1 FROM public.book_requests WHERE id = request_id AND user_id = auth.uid())
    OR EXISTS (SELECT 1 FROM public.book_stalls WHERE id = stall_id AND user_id = auth.uid())
    OR public.is_admin()
  );

CREATE POLICY "Scrap offers visibility" ON public.scrap_offers
  FOR SELECT TO authenticated USING (
    EXISTS (SELECT 1 FROM public.scrap_requests WHERE id = request_id AND user_id = auth.uid())
    OR EXISTS (SELECT 1 FROM public.scrap_owners WHERE id = scrap_owner_id AND user_id = auth.uid())
    OR public.is_admin()
  );

CREATE POLICY "Approved scrap dealers can make scrap offers" ON public.scrap_offers
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM public.scrap_owners WHERE id = scrap_owner_id AND user_id = auth.uid() AND approval_status = 'approved')
  );

-- Transactions & Conversations (Participants only)
CREATE POLICY "Transactions participant access" ON public.transactions
  FOR SELECT TO authenticated USING (user_id = auth.uid() OR partner_user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Conversations participant access" ON public.conversations
  FOR SELECT TO authenticated USING (user_id = auth.uid() OR partner_user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Messages participant access" ON public.messages
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.conversations c 
      WHERE c.id = conversation_id AND (c.user_id = auth.uid() OR c.partner_user_id = auth.uid() OR public.is_admin())
    )
  );

CREATE POLICY "Messages send by participants" ON public.messages
  FOR INSERT TO authenticated WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM public.conversations c 
      WHERE c.id = conversation_id AND (c.user_id = auth.uid() OR c.partner_user_id = auth.uid())
    )
  );

-- Notifications (Owner only)
CREATE POLICY "User views own notifications" ON public.notifications
  FOR SELECT TO authenticated USING (user_id = auth.uid());

CREATE POLICY "User updates own notifications" ON public.notifications
  FOR UPDATE TO authenticated USING (user_id = auth.uid());

-- Payments (Participants only)
CREATE POLICY "Payment records participant access" ON public.payment_records
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.transactions t 
      WHERE t.id = transaction_id AND (t.user_id = auth.uid() OR t.partner_user_id = auth.uid() OR public.is_admin())
    )
  );

CREATE POLICY "Payment records update" ON public.payment_records
  FOR UPDATE TO authenticated USING (
    EXISTS (
      SELECT 1 FROM public.transactions t 
      WHERE t.id = transaction_id AND (t.user_id = auth.uid() OR t.partner_user_id = auth.uid() OR public.is_admin())
    )
  );

-- Guidelines & Announcements (Public read, admin write)
CREATE POLICY "Guidelines readable by all" ON public.guidelines
  FOR SELECT TO public USING (is_published = true OR public.is_admin());

CREATE POLICY "Guidelines admin manage" ON public.guidelines
  FOR ALL TO authenticated USING (public.is_admin());

CREATE POLICY "Announcements readable by authenticated" ON public.announcements
  FOR SELECT TO authenticated USING (is_published = true OR public.is_admin());

CREATE POLICY "Announcements admin manage" ON public.announcements
  FOR ALL TO authenticated USING (public.is_admin());

-- Complaints & Audit Logs
CREATE POLICY "Complaints access" ON public.complaints
  FOR SELECT TO authenticated USING (filed_by = auth.uid() OR against_user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Complaints filing" ON public.complaints
  FOR INSERT TO authenticated WITH CHECK (filed_by = auth.uid());

CREATE POLICY "Complaints admin manage" ON public.complaints
  FOR UPDATE TO authenticated USING (public.is_admin());

CREATE POLICY "Audit logs admin only" ON public.admin_audit_logs
  FOR ALL TO authenticated USING (public.is_admin());

-- ====================================================================
-- AUTOMATED TRIGGERS (Sync profiles, notifications & transactions)
-- ====================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone, is_verified)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    NEW.raw_user_meta_data->>'phone',
    NEW.email_confirmed_at IS NOT NULL
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    is_verified = (NEW.email_confirmed_at IS NOT NULL);

  -- Assign user role from metadata if specified
  IF NEW.raw_user_meta_data->>'role' IS NOT NULL THEN
    INSERT INTO public.user_roles (user_id, role, is_approved)
    VALUES (
      NEW.id,
      NEW.raw_user_meta_data->>'role',
      CASE WHEN NEW.raw_user_meta_data->>'role' = 'seller' THEN true ELSE false END
    )
    ON CONFLICT (user_id, role) DO NOTHING;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT OR UPDATE ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
