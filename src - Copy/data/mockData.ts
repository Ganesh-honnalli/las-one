import { BookRequest, WasteRequest, BookStall, RaddiOwner, DisputeRecord, AuditLogEntry, UserProfile } from '../types';

export const INITIAL_PROFILES: Record<string, UserProfile> = {
  seller: {
    id: 'b0000000-0000-0000-0000-000000000001',
    email: 'priya.sharma@gmail.com',
    fullName: 'Priya Sharma (Student)',
    phoneNumber: '+91 98451 12345',
    role: 'seller',
    isVerified: true,
    ageConfirmed: true
  },
  book_stall: {
    id: 'c0000000-0000-0000-0000-000000000001',
    email: 'vidyarthi.books@avenue.in',
    fullName: 'Rajesh Gowda (Vidyarthi Books)',
    phoneNumber: '+91 98440 22334',
    role: 'book_stall',
    isVerified: true,
    ageConfirmed: true
  },
  raddi_owner: {
    id: 'd0000000-0000-0000-0000-000000000001',
    email: 'anand@ecorecyclers.in',
    fullName: 'Anand Rao (Eco Recyclers)',
    phoneNumber: '+91 99001 55667',
    role: 'raddi_owner',
    isVerified: true,
    ageConfirmed: true
  },
  admin: {
    id: 'a0000000-0000-0000-0000-000000000001',
    email: 'admin@secondshelf.in',
    fullName: 'Antigravity Super Admin',
    phoneNumber: '+91 98765 43210',
    role: 'admin',
    isVerified: true,
    ageConfirmed: true
  }
};

export const INITIAL_BOOK_STALLS: BookStall[] = [
  {
    id: 'e0000000-0000-0000-0000-000000000001',
    userId: 'c0000000-0000-0000-0000-000000000001',
    stallName: 'Vidyarthi Book House',
    shopLicenceOrGst: 'KA-BBMP-BL-2018-9941',
    address: 'Shop #14, Avenue Road, Chickpet, Bengaluru',
    pinCode: '560002',
    city: 'Bengaluru',
    state: 'Karnataka',
    contactPhone: '+91 98440 22334',
    contactEmail: 'vidyarthi.books@avenue.in',
    offersPickup: true,
    adminApprovalStatus: 'approved'
  },
  {
    id: 'e0000000-0000-0000-0000-000000000002',
    userId: 'c0000000-0000-0000-0000-000000000002',
    stallName: 'Sapna Used Book Corner',
    shopLicenceOrGst: 'KA-BBMP-BL-2022-3841',
    address: 'Shop #8, Gandhi Bazaar Main Road, Basavanagudi, Bengaluru',
    pinCode: '560004',
    city: 'Bengaluru',
    state: 'Karnataka',
    contactPhone: '+91 94480 33445',
    contactEmail: 'sapna.corner@books.in',
    offersPickup: false,
    adminApprovalStatus: 'pending'
  }
];

export const INITIAL_RADDI_OWNERS: RaddiOwner[] = [
  {
    id: 'f0000000-0000-0000-0000-000000000001',
    userId: 'd0000000-0000-0000-0000-000000000001',
    businessName: 'Karnataka Eco Recyclers',
    licenceNumber: 'KSPCB-HAZ-REC-2020-112',
    baseAddress: 'Yard #42, Industrial Area, Rajajinagar 1st Block',
    operatingPinCodes: ['560001', '560002', '560010', '560041', '560070'],
    city: 'Bengaluru',
    state: 'Karnataka',
    contactPhone: '+91 99001 55667',
    contactEmail: 'anand@ecorecyclers.in',
    adminApprovalStatus: 'approved'
  },
  {
    id: 'f0000000-0000-0000-0000-000000000002',
    userId: 'd0000000-0000-0000-0000-000000000002',
    businessName: 'Green Paper Traders',
    licenceNumber: 'KSPCB-HAZ-REC-2023-450',
    baseAddress: 'Shed 12, Mysuru Road, Nayandahalli',
    operatingPinCodes: ['560039', '560040', '560050'],
    city: 'Bengaluru',
    state: 'Karnataka',
    contactPhone: '+91 98860 66778',
    contactEmail: 'syed@greenpaper.in',
    adminApprovalStatus: 'pending'
  }
];

export const INITIAL_BOOK_REQUESTS: BookRequest[] = [
  {
    id: '10000000-0000-0000-0000-000000000001',
    requestNumber: 'BOK-2026-0001',
    sellerId: 'b0000000-0000-0000-0000-000000000001',
    sellerName: 'Priya Sharma',
    sellerPhone: '+91 98451 12345',
    sellerAddress: '#24, 7th Cross, Jayanagar 4th Block, Bengaluru',
    sellerPinCode: '560041',
    assignedStallId: 'e0000000-0000-0000-0000-000000000001',
    stallName: 'Vidyarthi Book House',
    status: 'Payment Pending',
    preferredHandoverMethod: 'direct_stall_handover',
    totalOriginalPrice: 1450.0,
    totalEstimatedPayout: 395.0,
    createdAt: '2026-10-24T10:15:00Z',
    items: [
      {
        id: 'item-1',
        bookRequestId: '10000000-0000-0000-0000-000000000001',
        title: 'Data Structures Using C',
        author: 'Reema Thareja',
        isbn: '978-0198099307',
        category: 'Engineering Books',
        classOrSemester: '3rd Sem B.E (CSE)',
        publisher: 'Oxford University Press',
        edition: '2nd Edition',
        originalPrice: 650.0,
        condition: 'Like New',
        numberOfCopies: 1,
        frontCoverUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500',
        backCoverUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=500',
        insidePageUrl: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500',
        estimatedItemPayout: 195.0
      },
      {
        id: 'item-2',
        bookRequestId: '10000000-0000-0000-0000-000000000001',
        title: 'Discrete Mathematics and Its Applications',
        author: 'Kenneth H. Rosen',
        isbn: '978-0070681880',
        category: 'Engineering Books',
        classOrSemester: '3rd Sem B.E',
        publisher: 'McGraw Hill',
        edition: '7th Edition',
        originalPrice: 800.0,
        condition: 'Good',
        numberOfCopies: 1,
        frontCoverUrl: 'https://images.unsplash.com/photo-1532012164546-f432f2e3777f?w=500',
        backCoverUrl: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=500',
        insidePageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=500',
        estimatedItemPayout: 200.0
      }
    ],
    currentOffer: {
      amount: 395.0,
      notes: 'Condition verified at counter'
    },
    payment: {
      amount: 395.0,
      method: 'upi',
      utr: 'UPI/261025884920/GPay',
      date: '2026-10-25',
      notes: 'Transferred via Google Pay. Inspected condition matches Like New & Good.',
      payerRecorded: true,
      sellerConfirmed: false
    }
  }
];

export const INITIAL_RADDI_REQUESTS: WasteRequest[] = [
  {
    id: '30000000-0000-0000-0000-000000000001',
    requestNumber: 'RAD-2026-0001',
    sellerId: 'b0000000-0000-0000-0000-000000000001',
    sellerName: 'Priya Sharma',
    sellerPhone: '+91 98451 12345',
    sellerEmail: 'priya.sharma@gmail.com',
    pickupAddress: '#24, 7th Cross, Jayanagar 4th Block, Near Cool Joint, Bengaluru',
    pickupPinCode: '560041',
    pickupArea: 'Jayanagar 4th Block',
    paperType: 'Newspapers',
    estimatedWeightKg: 25.0, // Strictly >= 10 kg
    actualWeightKg: 26.5,
    preferredPickupDate: '2026-10-28',
    preferredTimeSlot: 'Morning (9 AM - 12 PM)',
    notes: '6 months of English & Kannada newspapers bundled with twine.',
    status: 'Payment Pending',
    assignedOwnerId: 'f0000000-0000-0000-0000-000000000001',
    ownerBusinessName: 'Karnataka Eco Recyclers',
    agreedRatePerKg: 14.0,
    finalAmount: 371.0,
    createdAt: '2026-10-23T11:00:00Z',
    payment: {
      amount: 371.0,
      method: 'cash',
      utr: 'CASH-261025-01',
      date: '2026-10-25',
      notes: 'Weighed 26.5 kg on electronic scale. Paid cash at doorstep.',
      payerRecorded: true,
      sellerConfirmed: false
    }
  }
];

export const INITIAL_DISPUTES: DisputeRecord[] = [
  {
    id: 'dsp-01',
    requestNumber: 'BOK-2026-0099',
    raisedBy: 'Ramesh Kumar',
    against: 'Sapna Used Book Corner',
    reason: 'wrong_payment_amount',
    details: 'Agreed final offer was ₹450, but transfer received was ₹350.',
    status: 'under_review',
    createdAt: '2026-10-22'
  }
];

export const INITIAL_AUDIT_LOGS: AuditLogEntry[] = [
  { id: 'log-1', timestamp: '2026-10-25 09:30', user: 'System Admin', action: 'Valuation Rule Checked', details: 'Condition caps confirmed: 30%, 30%, 20%, 15%' },
  { id: 'log-2', timestamp: '2026-10-25 10:15', user: 'Rajesh Gowda (Stall)', action: 'Payment Logged', details: 'Logged ₹395 UPI payment for BOK-2026-0001' },
  { id: 'log-3', timestamp: '2026-10-25 11:20', user: 'Anand Rao (Recycler)', action: 'Payment Logged', details: 'Logged ₹371 Cash settlement for RAD-2026-0001' }
];
