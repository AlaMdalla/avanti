// @ts-ignore: allow remote std import in Deno functions
import { serve } from "https://deno.land/std@0.224.0/http/server.ts";

// Minimal function: returns a checkout URL for the chosen plan.
// It supports two modes:
// 1) If PAYMENT_CHECKOUT_URL env is set, returns `${PAYMENT_CHECKOUT_URL}?plan_id=...&user_id=...`.
// 2) Otherwise, returns 500 with guidance to configure the function.

// @ts-ignore: Deno runtime provides env
const PAYMENT_CHECKOUT_URL = Deno.env.get("PAYMENT_CHECKOUT_URL");

serve(async (req) => {
    if (req.method !== "POST") {
        return new Response(JSON.stringify({ error: "Method Not Allowed" }), {
            status: 405,
            headers: { "content-type": "application/json" },
        });
    }

    try {
        const { plan_id, user_id, success_url, cancel_url } = await req.json();
        if (!plan_id || !user_id) {
            return new Response(JSON.stringify({ error: "plan_id and user_id are required" }), {
                status: 400,
                headers: { "content-type": "application/json" },
            });
        }

        if (PAYMENT_CHECKOUT_URL) {
            const url = new URL(PAYMENT_CHECKOUT_URL);
            url.searchParams.set("plan_id", String(plan_id));
            url.searchParams.set("user_id", String(user_id));
            if (success_url) url.searchParams.set("success_url", String(success_url));
            if (cancel_url) url.searchParams.set("cancel_url", String(cancel_url));
            return new Response(JSON.stringify({ url: url.toString() }), {
                status: 200,
                headers: { "content-type": "application/json" },
            });
        }

        // No integration configured.
        return new Response(
            JSON.stringify({
                error: "PAYMENT_CHECKOUT_URL not configured",
                hint:
                    "Set the PAYMENT_CHECKOUT_URL secret for this function or replace with your PSP integration.",
            }),
            { status: 500, headers: { "content-type": "application/json" } },
        );
    } catch (e) {
        return new Response(JSON.stringify({ error: String(e) }), {
            status: 500,
            headers: { "content-type": "application/json" },
        });
    }
});
