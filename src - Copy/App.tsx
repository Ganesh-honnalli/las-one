import React, { useState } from 'react';
import { UserRole } from './types';
import { INITIAL_PROFILES, INITIAL_BOOK_REQUESTS, INITIAL_RADDI_REQUESTS, INITIAL_BOOK_STALLS, INITIAL_RADDI_OWNERS, INITIAL_DISPUTES, INITIAL_AUDIT_LOGS } from './data/mockData';
import { calculateItemEstimate, validateOfferCap, validateRaddiWeight } from './services/supabase';

export const App: React.FC = () => {
  const [role, setRole] = useState<UserRole>('seller');
  const [language, setLanguage] = useState<'en' | 'kn'>('en');
  const [bookRequests, setBookRequests] = useState(INITIAL_BOOK_REQUESTS);
  const [wasteRequests, setWasteRequests] = useState(INITIAL_RADDI_REQUESTS);
  const [bookStalls, setBookStalls] = useState(INITIAL_BOOK_STALLS);
  const [raddiOwners, setRaddiOwners] = useState(INITIAL_RADDI_OWNERS);
  const [disputes, setDisputes] = useState(INITIAL_DISPUTES);
  const [auditLogs, setAuditLogs] = useState(INITIAL_AUDIT_LOGS);

  // Valuation calculation state
  const [origPrice, setOrigPrice] = useState(1000);
  const [condition, setCondition] = useState('Used');
  const [copies, setCopies] = useState(1);
  const estPayout = calculateItemEstimate(origPrice, condition, copies);

  // Raddi estimation state
  const [raddiWeight, setRaddiWeight] = useState(25);
  const [raddiRate, setRaddiRate] = useState(14);
  const raddiWeightValidation = validateRaddiWeight(raddiWeight);
  const estRaddiPayout = raddiWeightValidation.valid ? raddiWeight * raddiRate : 0;

  return (
    <div className="min-h-screen bg-[#fdfbf7] text-slate-800 flex flex-col font-sans">
      {/* Top Demo Bar */}
      <div className="bg-[#0f261c] text-emerald-200 text-xs py-1.5 px-4 flex flex-wrap justify-between items-center gap-2">
        <div className="flex items-center gap-2">
          <span className="bg-amber-400 text-slate-900 font-bold px-1.5 py-0.5 rounded text-[10px] uppercase">React App Mode</span>
          <span className="text-slate-300">Active Role:</span>
          {(['seller', 'book_stall', 'raddi_owner', 'admin'] as UserRole[]).map(r => (
            <button
              key={r}
              onClick={() => setRole(r)}
              className={`px-2 py-0.5 rounded font-medium text-xs transition ${
                role === r ? 'bg-emerald-600 text-white font-bold' : 'bg-slate-800 text-slate-300 hover:text-white'
              }`}
            >
              {r === 'seller' && '👤 Seller'}
              {r === 'book_stall' && '🏬 Stall Owner'}
              {r === 'raddi_owner' && '♻️ Recycle Scrap Owner'}
              {r === 'admin' && '🛡️ Admin'}
            </button>
          ))}
        </div>
        <div className="flex items-center gap-3">
          <span className="text-amber-300 font-semibold">🇮🇳 All Prices in Indian Rupees (₹)</span>
          <button 
            onClick={() => setLanguage(l => l === 'en' ? 'kn' : 'en')}
            className="text-white hover:text-amber-300 bg-emerald-950 px-2 py-0.5 rounded border border-emerald-800"
          >
            {language === 'en' ? '🌐 ಕನ್ನಡ (Kannada)' : '🌐 English'}
          </button>
        </div>
      </div>

      {/* Navigation Bar */}
      <header className="bg-[#1b4332] text-white shadow sticky top-0 z-30">
        <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between gap-4">
          <div className="flex items-center gap-2">
            <span className="text-2xl p-2 bg-emerald-900 border border-amber-400 rounded-lg">📚</span>
            <div>
              <div className="text-xl font-extrabold tracking-wider">
                SECOND<span className="text-amber-400">SHELF</span>
              </div>
              <div className="text-[10px] text-emerald-200 -mt-1">
                {language === 'en' ? 'Give Your Old Books a Second Life' : 'ನಿಮ್ಮ ಹಳೆಯ ಪುಸ್ತಕಗಳಿಗೆ ಹೊಸ ಜೀವ ನೀಡಿ'}
              </div>
            </div>
          </div>

          <div className="hidden md:flex items-center text-xs text-slate-300 gap-1">
            <span className="text-amber-400 text-base">📍</span> Deliver to Bengaluru 560001
          </div>

          <div className="flex items-center gap-3">
            <div className="text-right text-xs">
              <div className="text-emerald-200 text-[10px]">Active Dashboard</div>
              <div className="font-bold text-amber-300 capitalize">{role.replace(/_/g, ' ')}</div>
            </div>
            <a 
              href="/index.html" 
              className="bg-amber-400 hover:bg-amber-500 text-slate-950 font-bold px-3 py-1.5 rounded text-xs shadow"
            >
              Open Full Portal
            </a>
          </div>
        </div>
      </header>

      {/* Main Container */}
      <main className="max-w-7xl mx-auto px-4 py-8 flex-1 space-y-8 w-full">
        {/* Hero Section */}
        <div className="bg-gradient-to-r from-[#1b4332] to-[#2d6a4f] text-white p-8 rounded-2xl shadow-xl flex flex-col md:flex-row items-center justify-between gap-8">
          <div className="space-y-4 max-w-xl">
            <span className="bg-emerald-800 text-emerald-200 text-xs px-3 py-1 rounded-full font-semibold border border-emerald-600">
              🌱 Verified Indian Marketplace Platform
            </span>
            <h1 className="text-3xl sm:text-5xl font-black leading-tight">
              Sell Your Old Books.<br />Recycle Paper.<br />
              <span className="text-amber-400">Earn Money.</span>
            </h1>
            <p className="text-emerald-100 text-sm">
              Connect with registered used-book stalls and certified recycle scrap dealers. Direct payments via UPI or Cash with mandatory two-party confirmation.
            </p>
          </div>

          {/* Quick Estimator Card */}
          <div className="bg-white text-slate-800 p-6 rounded-xl shadow-2xl max-w-sm w-full space-y-4 border border-slate-200">
            <div className="flex justify-between items-center border-b pb-2">
              <h3 className="font-bold text-sm text-slate-900">⚡ Live Valuation Estimator</h3>
              <span className="text-[10px] bg-amber-100 text-amber-900 px-1.5 py-0.5 rounded font-bold">Rule Engine</span>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-600">Original Price (₹)</label>
              <input 
                type="number" 
                value={origPrice} 
                onChange={e => setOrigPrice(Number(e.target.value))}
                className="w-full mt-1 p-2 text-sm border rounded font-bold" 
              />
            </div>

            <div className="grid grid-cols-2 gap-2">
              <div>
                <label className="block text-xs font-semibold text-slate-600">Condition</label>
                <select 
                  value={condition} 
                  onChange={e => setCondition(e.target.value)}
                  className="w-full mt-1 p-1.5 text-xs border rounded"
                >
                  <option value="Like New">Like New (30%)</option>
                  <option value="Good">Good (30%)</option>
                  <option value="Used">Used (20%)</option>
                  <option value="Old or Damaged">Old/Damaged (15%)</option>
                </select>
              </div>
              <div>
                <label className="block text-xs font-semibold text-slate-600">Copies</label>
                <input 
                  type="number" 
                  value={copies} 
                  min={1} 
                  onChange={e => setCopies(Number(e.target.value))}
                  className="w-full mt-1 p-1.5 text-xs border rounded" 
                />
              </div>
            </div>

            <div className="bg-emerald-50 p-3 rounded-lg border border-emerald-200 text-center">
              <div className="text-[11px] text-emerald-800 font-medium">Estimated Seller Payment</div>
              <div className="text-2xl font-black text-emerald-900">₹{estPayout.toFixed(2)}</div>
              <div className="text-[10px] text-slate-500 mt-1 italic">
                *Estimated payout cap enforced on server. Final settlement upon physical inspection.
              </div>
            </div>
          </div>
        </div>

        {/* 10 kg Recycle Scrap Rule Callout */}
        <div className="bg-amber-50 border-2 border-amber-300 rounded-xl p-6 flex flex-col md:flex-row items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <span className="text-2xl">⚖️</span>
              <h3 className="font-bold text-amber-950 text-base">Recycle Scrap 10 kg Minimum Accepted Weight Policy</h3>
              <span className="text-xs font-bold bg-rose-100 text-rose-800 px-2 py-0.5 rounded">Strict Rule</span>
            </div>
            <p className="text-xs text-amber-900 max-w-2xl">
              Requests below 10 kg are barred by both client validation and PostgreSQL database CHECK constraints. If the actual measured weight at collection is under 10 kg, the recycle scrap dealer may decline or revise the offer, and the seller may cancel freely without penalty.
            </p>
          </div>
          <div className="flex items-center gap-2">
            <span className="text-xs font-bold text-slate-700">Test weight:</span>
            <input 
              type="number" 
              value={raddiWeight} 
              onChange={e => setRaddiWeight(Number(e.target.value))}
              className={`w-20 p-1.5 text-xs border rounded font-bold ${!raddiWeightValidation.valid ? 'border-rose-500 bg-rose-50' : 'border-emerald-500'}`} 
            />
            <span className="text-xs font-bold">kg</span>
            {!raddiWeightValidation.valid ? (
              <span className="text-xs font-bold text-rose-700">⛔ Blocked (&lt; 10 kg)</span>
            ) : (
              <span className="text-xs font-bold text-emerald-700">✅ Eligible (Est: ₹{estRaddiPayout.toFixed(2)})</span>
            )}
          </div>
        </div>

        {/* Live Requests Feed */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200 space-y-4">
            <h3 className="font-bold text-base text-slate-900 flex items-center gap-2">
              <span>📚</span> Active Used Book Requests ({bookRequests.length})
            </h3>
            {bookRequests.map(b => (
              <div key={b.id} className="border p-4 rounded-lg bg-slate-50 space-y-2 text-xs">
                <div className="flex justify-between items-center">
                  <span className="font-bold text-slate-900">{b.requestNumber}</span>
                  <span className="bg-amber-100 text-amber-900 px-2 py-0.5 rounded font-bold">{b.status}</span>
                </div>
                <div className="text-slate-600">
                  {b.items.map(i => `${i.title} (${i.condition})`).join(', ')}
                </div>
                <div className="flex justify-between items-center pt-2 border-t font-semibold">
                  <span>Cap: ₹{b.totalEstimatedPayout}</span>
                  <span className="text-emerald-800 font-bold">Seller: {b.sellerName}</span>
                </div>
              </div>
            ))}
          </div>

          <div className="bg-white p-6 rounded-xl shadow-sm border border-slate-200 space-y-4">
            <h3 className="font-bold text-base text-slate-900 flex items-center gap-2">
              <span>♻️</span> Active Recycle Scrap Pickup Requests ({wasteRequests.length})
            </h3>
            {wasteRequests.map(r => (
              <div key={r.id} className="border p-4 rounded-lg bg-slate-50 space-y-2 text-xs">
                <div className="flex justify-between items-center">
                  <span className="font-bold text-slate-900">{r.requestNumber} ({r.paperType})</span>
                  <span className="bg-amber-100 text-amber-900 px-2 py-0.5 rounded font-bold">{r.status}</span>
                </div>
                <div className="text-slate-600">
                  Weight: <strong>{r.estimatedWeightKg} kg</strong> | Area: <strong>{r.pickupArea} ({r.pickupPinCode})</strong>
                </div>
                <div className="flex justify-between items-center pt-2 border-t font-semibold">
                  <span className="text-slate-400">🔒 Address hidden until offer accepted</span>
                  <span className="text-emerald-800 font-bold">{r.ownerBusinessName || 'Open for Bids'}</span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-[#0f261c] text-slate-400 text-xs py-6 border-t border-emerald-950 text-center">
        <p>© 2026 SECOND SHELF. DPDP Act 2023 Compliant • Two-Party Payment Confirmation Model</p>
      </footer>
    </div>
  );
};
