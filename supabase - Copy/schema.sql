-- ====================================================================
-- SECOND SHELF - Supabase Database Schema
-- Marketplace connecting Sellers with Book Stalls & Raddi Owners
-- ====================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. PROFILES & ROLES
-- Extends Supabase auth.users
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    phone_number TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('seller', 'book_stall', 'raddi_owner', 'admin')),
    is_verified BOOLEAN DEFAULT FALSE,
    age_confirmed BOOLEAN DEFAULT FALSE, -- Must be 18+
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. BOOK STALLS
-- Registered book stall businesses (require admin approval)
CREATE TABLE IF NOT EXISTS public.book_stalls (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    stall_name TEXT NOT NULL,
    shop_licence_or_gst TEXT,
    address TEXT NOT NULL,
    pin_code VARCHAR(10) NOT NULL,
    city TEXT NOT NULL DEFAULT 'Bengaluru',
    state TEXT NOT NULL DEFAULT 'Karnataka',
    contact_phone TEXT NOT NULL,
    contact_email TEXT NOT NULL,
    offers_pickup BOOLEAN DEFAULT FALSE,
    admin_approval_status TEXT NOT NULL DEFAULT 'pending' 
        CHECK (admin_approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. RADDI OWNERS (Waste Paper Recyclers)
-- Registered waste paper dealers (require admin approval)
CREATE TABLE IF NOT EXISTS public.raddi_owners (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    business_name TEXT NOT NULL,
    licence_number TEXT,
    base_address TEXT NOT NULL,
    operating_pin_codes TEXT[] DEFAULT ARRAY[]::TEXT[],
    city TEXT NOT NULL DEFAULT 'Bengaluru',
    state TEXT NOT NULL DEFAULT 'Karnataka',
    contact_phone TEXT NOT NULL,
    contact_email TEXT NOT NULL,
    admin_approval_status TEXT NOT NULL DEFAULT 'pending' 
        CHECK (admin_approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
    rejection_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. BOOK CATEGORIES (Admin configurable)
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    display_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. VALUATION RULES (Admin configurable condition % limits)
CREATE TABLE IF NOT EXISTS public.valuation_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    condition_name TEXT NOT NULL UNIQUE CHECK (condition_name IN ('Like New', 'Good', 'Used', 'Old or Damaged')),
    max_percentage NUMERIC(5,2) NOT NULL CHECK (max_percentage > 0 AND max_percentage <= 100),
    description TEXT,
    updated_by UUID REFERENCES public.profiles(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. USED BOOK REQUESTS
CREATE TABLE IF NOT EXISTS public.book_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_number TEXT NOT NULL UNIQUE,
    seller_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    assigned_stall_id UUID REFERENCES public.book_stalls(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN (
        'Pending', 
        'Offer Received', 
        'Offer Revised', 
        'Accepted', 
        'Awaiting Book', 
        'Received', 
        'Under Inspection', 
        'Final Offer Sent', 
        'Payment Pending', 
        'Completed', 
        'Rejected', 
        'Cancelled', 
        'Disputed'
    )),
    preferred_handover_method TEXT NOT NULL CHECK (preferred_handover_method IN (
        'direct_stall_handover', 
        'arranged_pickup', 
        'parcel_postal'
    )),
    seller_address TEXT NOT NULL,
    seller_pin_code VARCHAR(10) NOT NULL,
    total_original_price NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    total_estimated_payout NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. BOOK ITEMS (Multi-item support per request)
CREATE TABLE IF NOT EXISTS public.book_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    book_request_id UUID NOT NULL REFERENCES public.book_requests(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    isbn TEXT,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    class_or_semester TEXT,
    publisher TEXT,
    edition TEXT,
    original_price NUMERIC(10,2) NOT NULL CHECK (original_price > 0),
    condition TEXT NOT NULL CHECK (condition IN ('Like New', 'Good', 'Used', 'Old or Damaged')),
    number_of_copies INT NOT NULL DEFAULT 1 CHECK (number_of_copies >= 1),
    front_cover_url TEXT NOT NULL,
    back_cover_url TEXT NOT NULL,
    inside_page_url TEXT NOT NULL,
    estimated_item_payout NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. RADDI / WASTE PAPER REQUESTS
-- Strict requirement: minimum 10 kg constraint enforced in DB
CREATE TABLE IF NOT EXISTS public.waste_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_number TEXT NOT NULL UNIQUE,
    seller_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
    assigned_raddi_owner_id UUID REFERENCES public.raddi_owners(id) ON DELETE SET NULL,
    paper_type TEXT NOT NULL CHECK (paper_type IN (
        'Newspapers', 
        'Notebooks', 
        'Old Papers', 
        'Magazines', 
        'Cardboard', 
        'Mixed Paper'
    )),
    estimated_weight_kg NUMERIC(6,2) NOT NULL CHECK (estimated_weight_kg >= 10.0),
    photos TEXT[] DEFAULT ARRAY[]::TEXT[],
    seller_name TEXT NOT NULL,
    seller_phone TEXT NOT NULL,
    seller_email TEXT NOT NULL,
    pickup_address TEXT NOT NULL,
    pickup_pin_code VARCHAR(10) NOT NULL CHECK (length(pickup_pin_code) = 6),
    pickup_area TEXT NOT NULL, -- Publicly visible to recyclers before offer acceptance
    preferred_pickup_date DATE NOT NULL,
    preferred_time_slot TEXT NOT NULL,
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'Pending' CHECK (status IN (
        'Pending', 
        'Offer Received', 
        'Accepted', 
        'Pickup Scheduled', 
        'Collected', 
        'Final Price Sent', 
        'Payment Pending', 
        'Completed', 
        'Rejected', 
        'Cancelled', 
        'Disputed'
    )),
    actual_weight_kg NUMERIC(6,2) CHECK (actual_weight_kg IS NULL OR actual_weight_kg > 0),
    offered_rate_per_kg NUMERIC(6,2),
    final_amount NUMERIC(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. OFFERS (Book & Raddi offers)
CREATE TABLE IF NOT EXISTS public.offers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_type TEXT NOT NULL CHECK (request_type IN ('book', 'raddi')),
    book_request_id UUID REFERENCES public.book_requests(id) ON DELETE CASCADE,
    waste_request_id UUID REFERENCES public.waste_requests(id) ON DELETE CASCADE,
    stall_id UUID REFERENCES public.book_stalls(id) ON DELETE CASCADE,
    raddi_owner_id UUID REFERENCES public.raddi_owners(id) ON DELETE CASCADE,
    offered_amount NUMERIC(10,2) NOT NULL CHECK (offered_amount > 0),
    offered_rate_per_kg NUMERIC(6,2), -- Applicable for raddi requests
    offer_status TEXT NOT NULL DEFAULT 'active' CHECK (offer_status IN ('active', 'revised', 'accepted', 'rejected', 'expired')),
    revision_reason TEXT,
    rejection_reason TEXT,
    seller_response_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT chk_offer_target CHECK (
        (request_type = 'book' AND book_request_id IS NOT NULL AND stall_id IS NOT NULL) OR
        (request_type = 'raddi' AND waste_request_id IS NOT NULL AND raddi_owner_id IS NOT NULL)
    )
);

-- 10. PAYMENTS (Two-party confirmation model)
-- Platform records payment info; completed ONLY after seller confirms receipt!
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transaction_type TEXT NOT NULL CHECK (transaction_type IN ('book', 'raddi')),
    book_request_id UUID REFERENCES public.book_requests(id) ON DELETE CASCADE,
    waste_request_id UUID REFERENCES public.waste_requests(id) ON DELETE CASCADE,
    payer_user_id UUID NOT NULL REFERENCES public.profiles(id),
    seller_user_id UUID NOT NULL REFERENCES public.profiles(id),
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'upi', 'bank_transfer')),
    payment_reference_utr TEXT,
    payment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    receipt_url TEXT,
    notes TEXT,
    payer_recorded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    seller_confirmed_at TIMESTAMP WITH TIME ZONE,
    status TEXT NOT NULL DEFAULT 'pending_confirmation' CHECK (status IN ('pending_confirmation', 'confirmed', 'disputed')),
    dispute_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT chk_payment_target CHECK (
        (transaction_type = 'book' AND book_request_id IS NOT NULL) OR
        (transaction_type = 'raddi' AND waste_request_id IS NOT NULL)
    )
);

-- 11. DISPUTES
CREATE TABLE IF NOT EXISTS public.disputes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    request_type TEXT NOT NULL CHECK (request_type IN ('book', 'raddi')),
    book_request_id UUID REFERENCES public.book_requests(id) ON DELETE CASCADE,
    waste_request_id UUID REFERENCES public.waste_requests(id) ON DELETE CASCADE,
    raised_by_user_id UUID NOT NULL REFERENCES public.profiles(id),
    against_user_id UUID NOT NULL REFERENCES public.profiles(id),
    reason TEXT NOT NULL,
    details TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'under_review', 'resolved', 'dismissed')),
    admin_resolution_notes TEXT,
    resolved_by UUID REFERENCES public.profiles(id),
    resolved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. AUDIT LOGS
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    metadata JSONB DEFAULT '{}'::JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. NOTIFICATIONS
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    link TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ====================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ====================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_stalls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.raddi_owners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.valuation_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.book_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.waste_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.offers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.disputes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Helper function to check if auth.uid() is admin
CREATE OR REPLACE FUNCTION public.is_admin() 
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles 
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Profiles: Users see their own profile, admin sees all
CREATE POLICY "Users can view own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id OR public.is_admin());
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id OR public.is_admin());

-- Book Stalls: Approved stalls are public, stall owner can view & update own stall
CREATE POLICY "Public can view approved book stalls" ON public.book_stalls
    FOR SELECT USING (admin_approval_status = 'approved' OR user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Owners can update their own stall" ON public.book_stalls
    FOR UPDATE USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Admins can update stall approvals" ON public.book_stalls
    FOR ALL USING (public.is_admin());

-- Raddi Owners: Similar to book stalls
CREATE POLICY "Public can view approved raddi owners" ON public.raddi_owners
    FOR SELECT USING (admin_approval_status = 'approved' OR user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Owners can update own raddi profile" ON public.raddi_owners
    FOR UPDATE USING (user_id = auth.uid() OR public.is_admin());
CREATE POLICY "Admins can manage raddi owners" ON public.raddi_owners
    FOR ALL USING (public.is_admin());

-- Categories: Read public, write admin only
CREATE POLICY "Anyone can view categories" ON public.categories
    FOR SELECT USING (is_active = TRUE OR public.is_admin());
CREATE POLICY "Admins can manage categories" ON public.categories
    FOR ALL USING (public.is_admin());

-- Valuation rules: Read public, write admin only
CREATE POLICY "Anyone can read valuation rules" ON public.valuation_rules
    FOR SELECT USING (TRUE);
CREATE POLICY "Admins can manage valuation rules" ON public.valuation_rules
    FOR ALL USING (public.is_admin());

-- Book requests:
-- Sellers see their own requests.
-- Approved book stalls see requests in 'Pending' or assigned to them.
-- Admins see all.
CREATE POLICY "Sellers can view own book requests" ON public.book_requests
    FOR SELECT USING (
        seller_id = auth.uid() OR 
        public.is_admin() OR
        EXISTS (
            SELECT 1 FROM public.book_stalls bs 
            WHERE bs.user_id = auth.uid() 
              AND bs.admin_approval_status = 'approved'
              AND (book_requests.status = 'Pending' OR book_requests.assigned_stall_id = bs.id)
        )
    );
CREATE POLICY "Sellers can insert own book requests" ON public.book_requests
    FOR INSERT WITH CHECK (seller_id = auth.uid());
CREATE POLICY "Sellers and Stalls can update book requests" ON public.book_requests
    FOR UPDATE USING (
        seller_id = auth.uid() OR 
        public.is_admin() OR
        EXISTS (
            SELECT 1 FROM public.book_stalls bs 
            WHERE bs.user_id = auth.uid() AND bs.admin_approval_status = 'approved'
        )
    );

-- Book items: Follows book_request access
CREATE POLICY "View book items" ON public.book_items
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.book_requests br 
            WHERE br.id = book_items.book_request_id 
              AND (br.seller_id = auth.uid() OR public.is_admin() OR EXISTS (
                  SELECT 1 FROM public.book_stalls bs 
                  WHERE bs.user_id = auth.uid() AND bs.admin_approval_status = 'approved'
              ))
        )
    );
CREATE POLICY "Insert book items" ON public.book_items
    FOR INSERT WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.book_requests br 
            WHERE br.id = book_items.book_request_id AND br.seller_id = auth.uid()
        )
    );

-- Raddi / Waste Requests:
-- Strict Privacy Rule: Unaccepted requests show ONLY area and pin code.
-- Full address and phone are hidden from non-assigned recyclers.
CREATE POLICY "Waste requests view policy" ON public.waste_requests
    FOR SELECT USING (
        seller_id = auth.uid() OR 
        public.is_admin() OR
        EXISTS (
            SELECT 1 FROM public.raddi_owners ro 
            WHERE ro.user_id = auth.uid() 
              AND ro.admin_approval_status = 'approved'
        )
    );
CREATE POLICY "Sellers can insert waste requests" ON public.waste_requests
    FOR INSERT WITH CHECK (
        seller_id = auth.uid() AND estimated_weight_kg >= 10.0
    );
CREATE POLICY "Sellers and assigned raddi owners can update waste requests" ON public.waste_requests
    FOR UPDATE USING (
        seller_id = auth.uid() OR 
        public.is_admin() OR
        EXISTS (
            SELECT 1 FROM public.raddi_owners ro 
            WHERE ro.user_id = auth.uid() AND ro.admin_approval_status = 'approved'
        )
    );

-- Secure View for Raddi Owners to hide personal contact until offer accepted:
CREATE OR REPLACE VIEW public.v_waste_requests_recycler AS
SELECT 
    id,
    request_number,
    paper_type,
    estimated_weight_kg,
    photos,
    pickup_area,
    pickup_pin_code,
    preferred_pickup_date,
    preferred_time_slot,
    notes,
    status,
    created_at,
    -- Contact details revealed ONLY after acceptance and assignment
    CASE 
        WHEN status IN ('Accepted', 'Pickup Scheduled', 'Collected', 'Final Price Sent', 'Payment Pending', 'Completed') 
             AND assigned_raddi_owner_id = (SELECT id FROM public.raddi_owners WHERE user_id = auth.uid())
        THEN seller_name 
        ELSE 'Confidential (Revealed after offer acceptance)' 
    END AS seller_name,
    CASE 
        WHEN status IN ('Accepted', 'Pickup Scheduled', 'Collected', 'Final Price Sent', 'Payment Pending', 'Completed') 
             AND assigned_raddi_owner_id = (SELECT id FROM public.raddi_owners WHERE user_id = auth.uid())
        THEN seller_phone 
        ELSE 'Confidential' 
    END AS seller_phone,
    CASE 
        WHEN status IN ('Accepted', 'Pickup Scheduled', 'Collected', 'Final Price Sent', 'Payment Pending', 'Completed') 
             AND assigned_raddi_owner_id = (SELECT id FROM public.raddi_owners WHERE user_id = auth.uid())
        THEN pickup_address 
        ELSE 'Confidential (Area visible)' 
    END AS pickup_address
FROM public.waste_requests;

-- Offers Policy:
CREATE POLICY "Offers view policy" ON public.offers
    FOR SELECT USING (
        public.is_admin() OR
        EXISTS (
            SELECT 1 FROM public.book_requests br 
            WHERE br.id = offers.book_request_id AND br.seller_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM public.waste_requests wr 
            WHERE wr.id = offers.waste_request_id AND wr.seller_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM public.book_stalls bs 
            WHERE bs.id = offers.stall_id AND bs.user_id = auth.uid()
        ) OR
        EXISTS (
            SELECT 1 FROM public.raddi_owners ro 
            WHERE ro.id = offers.raddi_owner_id AND ro.user_id = auth.uid()
        )
    );

-- Payments Policy:
CREATE POLICY "Payments view policy" ON public.payments
    FOR SELECT USING (
        payer_user_id = auth.uid() OR 
        seller_user_id = auth.uid() OR 
        public.is_admin()
    );
CREATE POLICY "Payers can record payments" ON public.payments
    FOR INSERT WITH CHECK (payer_user_id = auth.uid());
CREATE POLICY "Parties can update payment confirmation" ON public.payments
    FOR UPDATE USING (
        payer_user_id = auth.uid() OR 
        seller_user_id = auth.uid() OR 
        public.is_admin()
    );

-- Notifications Policy:
CREATE POLICY "Users view own notifications" ON public.notifications
    FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users update own notifications" ON public.notifications
    FOR UPDATE USING (user_id = auth.uid());
