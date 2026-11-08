# SECOND SHELF 📚♻️
> *"Give Your Old Books a Second Life."*

SECOND SHELF is a responsive, Amazon-inspired marketplace website that connects book sellers with registered used-book stalls and certified recycle scrap owners across India. Built for college projects, university campuses, and commercial deployment.

---

## 🌟 Key Features & Business Rules

### 1. Two Dedicated Marketplaces
- **Used Books**: Multi-item textbook submission, physical condition estimation (Like New 30%, Good 30%, Used 20%, Damaged 15%), choice of handover (stall counter drop-off, arranged pickup, or postal courier).
- **Recycle Scrap (Paper & Cardboard)**: Paper recycling with a **strict 10 kg minimum weight constraint** enforced on frontend UI and database `CHECK` constraints. Recycler doorstep pickup with electronic weighing.

### 2. Privacy-First Recycling Feed (DPDP Act 2023 Compliant)
- In the public recycle scrap feed, recyclers only see the **area and 6-digit PIN code** (e.g., `Jayanagar 4th Block, 560041`).
- Exact house addresses and mobile phone numbers remain strictly confidential until the seller voluntarily accepts that recycler's price-per-kg offer.

### 3. Server-Enforced Condition Caps
- Valuation formulas:
  - **Book Payout Estimate** = `Original Price × Condition % × Number of Copies`
  - **Recycle Scrap Estimate** = `Weight (kg) × Offered Rate per kg`
- Stall offers **cannot exceed** the maximum percentage cap for the declared condition. The server rejects any offer that attempts to exceed the cap.

### 4. Two-Party Payment Confirmation (No Platform Escrow)
- The platform does not process in-app payments. Payments (Cash, UPI, Bank Transfer) occur directly between parties.
- A transaction is marked `Completed` **only after both parties confirm**:
  1. The buyer (stall or recycle scrap owner) records the payment method and bank UTR reference.
  2. The seller checks their bank/UPI app and clicks **"Confirm Payment Received"**.

### 5. Four Distinct Role Dashboards
- **Seller**: Track requests, review offers, accept/reject bids, confirm payments, raise disputes.
- **Book Stall Owner**: Review book submissions, inspect condition photos, make capped offers, record payments.
- **Recycle Scrap Owner**: Filter eligible pickup requests (≥ 10 kg) by PIN code, quote rate per kg, coordinate doorstep collection.
- **Administrator**: Approve or suspend stalls & recyclers, adjust condition percentage caps, manage categories, resolve disputes, view audit logs.

### 6. Bilingual Support
- Instant toggle between **English** and **ಕನ್ನಡ (Kannada)** across navigation, categories, and calls to action.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Frontend** | React 18 / Modern Component Architecture, Tailwind CSS, Canvas Confetti |
| **Backend** | Supabase (PostgreSQL 15, Row Level Security, Supabase Auth) |
| **Server Functions** | Supabase Edge Functions (Deno / TypeScript) |
| **Email Service** | Custom SMTP / Resend API via Supabase Edge Function |
| **Currency** | Indian Rupees (₹) |

---

## 🚀 Instant Quickstart (Zero Installation Required)

You can launch and test the entire marketplace **right now** without installing any heavy npm dependencies!

### Option A: Built-in Node.js Server
From the project folder, run:
```bash
node server.js
```
Open [http://localhost:3000](http://localhost:3000) in your web browser.

### Option B: Direct Browser Opening
Simply double-click `index.html` or open:
`file:///C:/Users/Akshata/.gemini/antigravity/scratch/second-shelf/index.html`

### Option C: Role Switcher in Top Bar
When the application opens, click any of the 4 demo role buttons in the top banner:
- `👤 Seller` (Priya Sharma - RVCE Student)
- `🏬 Stall Owner` (Rajesh Gowda - Vidyarthi Book House, Avenue Rd)
- `♻️ Recycle Scrap Owner` (Anand Rao - Karnataka Eco Recyclers)
- `🛡️ Admin` (Super Administrator Control Panel)

---

## 🗄️ Supabase Cloud Database Setup

To connect a live Supabase PostgreSQL backend:

1. Create a free project at [supabase.com](https://supabase.com).
2. Navigate to **SQL Editor** in the Supabase dashboard.
3. Copy and run `supabase/schema.sql`. This sets up:
   - Tables (`profiles`, `book_stalls`, `raddi_owners`, `categories`, `valuation_rules`, `book_requests`, `book_items`, `waste_requests`, `offers`, `payments`, `disputes`, `audit_logs`).
   - CHECK constraint `CHECK (estimated_weight_kg >= 10.0)` ensuring the 10 kg rule cannot be bypassed.
   - Row Level Security (RLS) policies for sellers, stalls, recyclers, and admins.
   - Secure recycler view masking contact information.
4. Copy and run `supabase/seed.sql` to populate initial categories, valuation rules, and demo accounts.
5. In project settings, copy your `SUPABASE_URL` and `SUPABASE_ANON_KEY` into `.env`:
   ```env
   VITE_SUPABASE_URL=https://your-project.supabase.co
   VITE_SUPABASE_ANON_KEY=your-anon-key-here
   ```

---

## ✅ Testing & Verification Checklist

| Test Case | How to Test in SECOND SHELF | Expected Result |
|---|---|---|
| **10 kg Recycle Scrap Rule** | In Recycle Scrap Calculator or Submission Modal, enter `8 kg`. | System displays red alert `"Minimum 10 kg of recycle scrap is required"`, and the submission button is disabled. |
| **Condition Valuation Cap** | Enter a book with original price ₹1000 and condition `Used`. | Payout is capped at 20% (₹200). A stall cannot send an offer higher than this limit. |
| **Two-Party Payment** | As Seller, view request `#BOK-2026-0001` with status `Payment Pending`. | The order remains pending until the seller clicks `"Confirm Payment Received"`. Clicking triggers confetti celebration and sets status to `Completed`. |
| **Recycler Privacy Masking** | Switch to `♻️ Recycle Scrap Owner` view and inspect request `#RAD-2026-0002`. | Only Area & PIN code (`Basaveshwaranagar, 560079`) are shown. Full address and phone display `"🔒 Exact address hidden until offer accepted"`. |
| **Admin Business Approval** | Switch to `🛡️ Admin` -> `Business Approvals`. Approve `Sapna Used Book Corner`. | Status changes from `Pending` to `Approved ✅`, allowing the stall to bid on student requests. |
| **Kannada Translation** | Click `🌐 ಕನ್ನಡ (Kannada)` in the top right banner. | Tagline, hero title, buttons, and subnav switch to Kannada instantly. |
| **18+ Age Check** | Open Auth Modal -> `Create Account`. Try submitting without checking 18+ box. | Form prevents registration and requires age verification. |

---

## 📄 License & College Presentation Note
Created for the **SECOND SHELF** initiative. Designed for university evaluation and real-world deployment in Indian student communities.
