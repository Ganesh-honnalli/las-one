import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || '';

// Live Supabase client (only initialized if credentials exist)
export const supabase = (supabaseUrl && supabaseAnonKey) 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null;

export const isLiveBackendAvailable = () => Boolean(supabase);

/**
 * Calculates estimated valuation based on condition and original price
 * Server/Edge Function equivalent
 */
export function calculateItemEstimate(originalPrice: number, condition: string, copies: number = 1): number {
  const caps: Record<string, number> = {
    'Like New': 30.0,
    'Good': 30.0,
    'Used': 20.0,
    'Old or Damaged': 15.0
  };
  const percentage = caps[condition] ?? 20.0;
  return Number(((originalPrice * (percentage / 100)) * copies).toFixed(2));
}

/**
 * Validates whether a stall's offer is permissible under the declared condition cap
 */
export function validateOfferCap(offeredAmount: number, maxAllowedPayout: number): { valid: boolean; error?: string } {
  if (offeredAmount <= 0) {
    return { valid: false, error: 'Offer amount must be a positive number.' };
  }
  if (offeredAmount > maxAllowedPayout) {
    return {
      valid: false,
      error: `Offer of ₹${offeredAmount} exceeds the maximum allowable payout cap of ₹${maxAllowedPayout.toFixed(2)}.`
    };
  }
  return { valid: true };
}

/**
 * Validates Raddi weight requirement (minimum 10 kg)
 */
export function validateRaddiWeight(weightKg: number): { valid: boolean; error?: string } {
  if (weightKg < 10.0) {
    return {
      valid: false,
      error: 'Minimum 10 kg of waste paper is required to submit a request.'
    };
  }
  return { valid: true };
}
