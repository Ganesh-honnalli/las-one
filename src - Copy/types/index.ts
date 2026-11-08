// SECOND SHELF TypeScript Type Definitions

export type UserRole = 'seller' | 'book_stall' | 'raddi_owner' | 'admin';

export type BookCondition = 'Like New' | 'Good' | 'Used' | 'Old or Damaged';

export type BookRequestStatus = 
  | 'Pending' 
  | 'Offer Received' 
  | 'Offer Revised' 
  | 'Accepted' 
  | 'Awaiting Book' 
  | 'Received' 
  | 'Under Inspection' 
  | 'Final Offer Sent' 
  | 'Payment Pending' 
  | 'Completed' 
  | 'Rejected' 
  | 'Cancelled' 
  | 'Disputed';

export type RecycleScrapRequestStatus =
  | 'Pending' 
  | 'Offer Received' 
  | 'Accepted' 
  | 'Pickup Scheduled' 
  | 'Collected' 
  | 'Final Price Sent' 
  | 'Payment Pending' 
  | 'Completed' 
  | 'Rejected' 
  | 'Cancelled' 
  | 'Disputed';

export type RaddiRequestStatus = RecycleScrapRequestStatus;

export type WastePaperType = 
  | 'Newspapers' 
  | 'Notebooks' 
  | 'Old Papers' 
  | 'Magazines' 
  | 'Cardboard' 
  | 'Mixed Paper';

export type HandoverMethod = 
  | 'direct_stall_handover' 
  | 'arranged_pickup' 
  | 'parcel_postal';

export type PaymentMethod = 'cash' | 'upi' | 'bank_transfer';

export interface UserProfile {
  id: string;
  email: string;
  fullName: string;
  phoneNumber: string;
  role: UserRole;
  isVerified: boolean;
  ageConfirmed: boolean; // Must be 18+
  avatarUrl?: string;
}

export interface BookStall {
  id: string;
  userId: string;
  stallName: string;
  shopLicenceOrGst: string;
  address: string;
  pinCode: string;
  city: string;
  state: string;
  contactPhone: string;
  contactEmail: string;
  offersPickup: boolean;
  adminApprovalStatus: 'pending' | 'approved' | 'rejected' | 'suspended';
}

export interface RecycleScrapOwner {
  id: string;
  userId: string;
  businessName: string;
  licence?: string;
  licenceNumber?: string;
  baseAddress: string;
  operatingPinCodes?: string[];
  city?: string;
  state?: string;
  contactPhone?: string;
  contactEmail?: string;
  approvalStatus?: 'pending' | 'approved' | 'rejected' | 'suspended';
  adminApprovalStatus?: 'pending' | 'approved' | 'rejected' | 'suspended';
}

export type RaddiOwner = RecycleScrapOwner;

export interface ValuationRule {
  conditionName: BookCondition;
  maxPercentage: number; // e.g. 30.00
  description: string;
}

export interface BookItem {
  id: string;
  bookRequestId: string;
  title: string;
  author: string;
  isbn?: string;
  category: string;
  classOrSemester?: string;
  publisher?: string;
  edition?: string;
  originalPrice: number; // Must be > 0
  condition: BookCondition;
  numberOfCopies: number; // Must be >= 1
  frontCoverUrl: string;
  backCoverUrl: string;
  insidePageUrl: string;
  estimatedItemPayout: number;
}

export interface BookRequest {
  id: string;
  requestNumber: string;
  sellerId: string;
  sellerName: string;
  sellerPhone: string;
  sellerAddress: string;
  sellerPinCode: string;
  assignedStallId?: string | null;
  stallName?: string | null;
  status: BookRequestStatus;
  preferredHandoverMethod: HandoverMethod;
  totalOriginalPrice: number;
  totalEstimatedPayout: number;
  notes?: string;
  items: BookItem[];
  currentOffer?: {
    amount: number;
    notes?: string;
  } | null;
  payment?: PaymentRecord | null;
  createdAt: string;
}

export interface WasteRequest {
  id: string;
  requestNumber: string;
  sellerId: string;
  sellerName: string;
  sellerPhone: string;
  sellerEmail: string;
  pickupAddress: string;
  pickupPinCode: string;
  pickupArea: string; // Visible before offer accepted
  paperType: WastePaperType;
  estimatedWeightKg: number; // Strictly >= 10.0
  actualWeightKg?: number | null;
  preferredPickupDate: string;
  preferredTimeSlot: string;
  notes?: string;
  status: RaddiRequestStatus;
  assignedOwnerId?: string | null;
  ownerBusinessName?: string | null;
  agreedRatePerKg?: number | null;
  finalAmount?: number | null;
  payment?: PaymentRecord | null;
  createdAt: string;
}

export interface PaymentRecord {
  id?: string;
  amount: number;
  method: PaymentMethod;
  utr: string;
  date: string;
  notes?: string;
  payerRecorded: boolean;
  sellerConfirmed: boolean;
  payerRecordedAt?: string;
  sellerConfirmedAt?: string;
}

export interface DisputeRecord {
  id: string;
  requestNumber: string;
  raisedBy: string;
  against: string;
  reason: string;
  details: string;
  status: 'open' | 'under_review' | 'resolved' | 'dismissed';
  createdAt: string;
}

export interface AuditLogEntry {
  id: string;
  timestamp: string;
  user: string;
  action: string;
  details: string;
}
