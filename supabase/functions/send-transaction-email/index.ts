// Supabase Edge Function: send-transaction-email
// Dispatches transactional email notifications for key SECOND SHELF milestones

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface EmailPayload {
  to: string;
  recipient_name: string;
  event: 
    | "offer_received" 
    | "offer_accepted" 
    | "book_inspected" 
    | "payment_recorded" 
    | "payment_confirmed" 
    | "dispute_raised";
  request_number: string;
  amount?: number;
  payment_method?: string;
  payment_utr?: string;
  notes?: string;
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload: EmailPayload = await req.json();
    const { to, recipient_name, event, request_number, amount, payment_method, payment_utr, notes } = payload;

    if (!to || !event || !request_number) {
      return new Response(
        JSON.stringify({ error: "Missing required fields" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    let subject = "";
    let bodyText = "";

    switch (event) {
      case "offer_received":
        subject = `[SECOND SHELF] New Offer for Request #${request_number}`;
        bodyText = `Hello ${recipient_name},\n\nA verified partner has submitted an offer of ₹${amount} for your request #${request_number}.\n\nPlease log in to SECOND SHELF to review and accept or decline this offer.\n\nThank you,\nSECOND SHELF Team`;
        break;

      case "offer_accepted":
        subject = `[SECOND SHELF] Offer Accepted for #${request_number}`;
        bodyText = `Hello ${recipient_name},\n\nThe seller has accepted your offer for request #${request_number}. You can now view their handover/pickup details on your dashboard.\n\nThank you,\nSECOND SHELF Team`;
        break;

      case "book_inspected":
        subject = `[SECOND SHELF] Inspection Update for Book #${request_number}`;
        bodyText = `Hello ${recipient_name},\n\nYour books for request #${request_number} have been physically inspected at the book stall.\n\nFinal Offered Amount: ₹${amount}\nNotes: ${notes || "Condition verified."}\n\nPlease review and confirm acceptance in your dashboard.\n\nThank you,\nSECOND SHELF Team`;
        break;

      case "payment_recorded":
        subject = `[ACTION REQUIRED] Confirm Payment Received for #${request_number}`;
        bodyText = `Hello ${recipient_name},\n\nThe buyer has recorded a direct payment of ₹${amount} via ${payment_method?.toUpperCase()} (Ref/UTR: ${payment_utr || "N/A"}).\n\nPlease check your bank account/UPI app. Once verified, click "Confirm Payment Received" in your SECOND SHELF dashboard to complete this transaction.\n\nThank you,\nSECOND SHELF Team`;
        break;

      case "payment_confirmed":
        subject = `[SECOND SHELF] Transaction Completed - #${request_number}`;
        bodyText = `Hello ${recipient_name},\n\nThe seller has confirmed receiving ₹${amount} for request #${request_number}. This transaction is now marked Completed.\n\nThank you for giving books a second life!\nSECOND SHELF Team`;
        break;

      case "dispute_raised":
        subject = `[SECOND SHELF] Dispute Logged for #${request_number}`;
        bodyText = `Hello ${recipient_name},\n\nA dispute has been raised regarding request #${request_number}.\nReason: ${notes}\n\nOur administrative support team is reviewing the records and will follow up shortly.\n\nThank you,\nSECOND SHELF Team`;
        break;
    }

    // Example delivery with Resend API if API key is configured
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    if (resendApiKey) {
      const res = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${resendApiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          from: "SECOND SHELF <notifications@secondshelf.in>",
          to: [to],
          subject,
          text: bodyText,
        }),
      });

      const resData = await res.json();
      return new Response(JSON.stringify({ success: true, provider: "resend", resData }), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // In development / demo environment without RESEND_API_KEY
    console.log(`[SIMULATED EMAIL DISPATCH] To: ${to} | Subject: ${subject}\n${bodyText}`);
    return new Response(
      JSON.stringify({
        success: true,
        simulated: true,
        to,
        subject,
        message: "Email logged in console. Configure RESEND_API_KEY in Supabase Edge Secrets for live SMTP/API delivery."
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: err.message || "Failed to process email" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
