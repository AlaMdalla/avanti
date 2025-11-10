// @ts-ignore: allow remote std import in Deno functions
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

// @ts-ignore: Deno runtime provides env
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");

serve(async (req) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method Not Allowed" }), {
      status: 405,
      headers: { "content-type": "application/json" },
    });
  }

  try {
    if (!STRIPE_SECRET_KEY) {
      return new Response(
        JSON.stringify({ error: "STRIPE_SECRET_KEY not set" }),
        { status: 500, headers: { "content-type": "application/json" } }
      );
    }

    const { plan_id, user_id, amount, currency } = await req.json();

    if (!plan_id || !user_id) {
      return new Response(
        JSON.stringify({ error: "plan_id and user_id required" }),
        { status: 400, headers: { "content-type": "application/json" } }
      );
    }

    // Use provided amount or default to 999 ($9.99)
    const paymentAmount = amount || 999;
    const paymentCurrency = currency || "usd";

    // Call Stripe API to create Payment Intent
    const response = await fetch(
      "https://api.stripe.com/v1/payment_intents",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: new URLSearchParams({
          amount: paymentAmount.toString(),
          currency: paymentCurrency,
          automatic_payment_methods: "true",
        }).toString(),
      }
    );

    const data = await response.json();

    if (!response.ok) {
      return new Response(JSON.stringify(data), {
        status: response.status,
        headers: { "content-type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({
        client_secret: data.client_secret,
        payment_intent_id: data.id,
        amount: data.amount,
        currency: data.currency,
      }),
      { status: 200, headers: { "content-type": "application/json" } }
    );
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { "content-type": "application/json" },
    });
  }
});