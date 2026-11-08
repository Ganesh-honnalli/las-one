// Supabase Edge Function: validate-book-offer
// Enforces that stall offers do NOT exceed the admin-configured valuation caps for declared condition

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ?? "",
      Deno.env.get("SUPABASE_ANON_KEY") ?? "",
      { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
    );

    const { book_request_id, stall_id, offered_amount, revision_reason } = await req.json();

    if (!book_request_id || !stall_id || !offered_amount) {
      return new Response(
        JSON.stringify({ error: "Missing required fields: book_request_id, stall_id, offered_amount" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 1. Fetch book items and their condition
    const { data: items, error: itemsError } = await supabaseClient
      .from("book_items")
      .select("original_price, condition, number_of_copies")
      .eq("book_request_id", book_request_id);

    if (itemsError || !items || items.length === 0) {
      return new Response(
        JSON.stringify({ error: "Book request items not found" }),
        { status: 404, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 2. Fetch current valuation rules
    const { data: rules, error: rulesError } = await supabaseClient
      .from("valuation_rules")
      .select("condition_name, max_percentage");

    if (rulesError || !rules) {
      return new Response(
        JSON.stringify({ error: "Valuation rules could not be loaded" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const ruleMap = new Map<string, number>();
    rules.forEach((r) => ruleMap.set(r.condition_name, Number(r.max_percentage)));

    // 3. Compute absolute maximum allowable offer
    let maxAllowedTotal = 0;
    for (const item of items) {
      const maxPercent = ruleMap.get(item.condition) ?? 20.0;
      const itemMax = (Number(item.original_price) * (maxPercent / 100)) * (item.number_of_copies || 1);
      maxAllowedTotal += itemMax;
    }

    // 4. Server enforcement: Stall offer CANNOT exceed max allowed total
    if (Number(offered_amount) > maxAllowedTotal) {
      return new Response(
        JSON.stringify({
          error: `Offered amount of ₹${offered_amount} exceeds the system maximum allowed payout of ₹${maxAllowedTotal.toFixed(2)} based on declared condition limits.`,
          max_allowed: maxAllowedTotal,
        }),
        { status: 422, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 5. Insert offer into database
    const { data: offer, error: offerError } = await supabaseClient
      .from("offers")
      .insert({
        request_type: "book",
        book_request_id,
        stall_id,
        offered_amount: Number(offered_amount),
        offer_status: "active",
        revision_reason: revision_reason || null,
      })
      .select()
      .single();

    if (offerError) throw offerError;

    // Update book request status to 'Offer Received'
    await supabaseClient
      .from("book_requests")
      .update({ status: "Offer Received", assigned_stall_id: stall_id })
      .eq("id", book_request_id);

    return new Response(
      JSON.stringify({ success: true, offer, max_allowed: maxAllowedTotal }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
