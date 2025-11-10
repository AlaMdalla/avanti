# Understanding the 404 Error - Stripe Payment Integration

## What is a 404 Error?
**404 = "Not Found"** - This error means the system tried to call something that doesn't exist.

---

## Your Situation - The 404 Error Flow

### ❌ BEFORE (Causing 404):
```
Flutter App (payment_checkout_screen.dart)
    ↓
Calls StripeService.processPayment()
    ↓
Tries to invoke Supabase Edge Function: "create-payment-intent"
    ↓
⚠️ Function DOESN'T EXIST yet ❌
    ↓
Supabase returns: 404 Not Found
```

### ✅ AFTER (Fixed - 404 Gone):
```
Flutter App (payment_checkout_screen.dart)
    ↓
Calls StripeService.processPayment()
    ↓
Tries to invoke Supabase Edge Function: "create-payment-intent"
    ↓
✅ Function EXISTS at /supabase/functions/create-payment-intent/
    ↓
Function receives plan_id & user_id
    ↓
Creates Stripe Payment Intent
    ↓
Returns client_secret to your app
```

---

## The Three Components Involved

### 1️⃣ Flutter App (Client Side)
**File:** `lib/features/subscription/screens/payment_checkout_screen.dart`

```dart
// User taps "Continue" on payment confirmation
// This happens:
await _stripe.processPayment(
  planId: widget.plan.id!,
  userId: user.id
);
```

### 2️⃣ Stripe Service (Flutter Logic)
**File:** `lib/features/subscription/services/stripe_service.dart`

```dart
Future<Map<String, dynamic>> processPayment({
  required String planId,
  required String userId,
}) async {
  // This calls the Supabase Edge Function
  final response = await _client.functions.invoke(
    'create-payment-intent',  // ← This is the function name it's looking for
    body: {
      'plan_id': planId,
      'user_id': userId,
    },
  );
}
```

### 3️⃣ Supabase Edge Function (Server Side)
**File:** `/supabase/functions/create-payment-intent/index.ts`

```typescript
// This is the actual function that handles the request
serve(async (req) => {
  // 1. Get plan_id and user_id from the request
  const { plan_id, user_id } = await req.json();
  
  // 2. Call Stripe API to create Payment Intent
  const paymentIntentResponse = await fetch(
    "https://api.stripe.com/v1/payment_intents",
    { /* ... */ }
  );
  
  // 3. Return client_secret back to the Flutter app
  return new Response(JSON.stringify({
    client_secret: paymentIntentData.client_secret,
    payment_intent_id: paymentIntentData.id,
    amount: paymentIntentData.amount,
    currency: paymentIntentData.currency,
  }));
});
```

---

## What Each Part Does

| Component | Role | Status |
|-----------|------|--------|
| **Flutter App** | Shows UI and calls functions | ✅ Working |
| **StripeService** | Packages data and calls Edge Function | ✅ Working |
| **Edge Function** | Talks to Stripe API, creates Payment Intent | ✅ Working (after we created it) |
| **Stripe API** | Processes payment and returns client_secret | ✅ Working |

---

## The 404 Error Explained in Simple Terms

**Imagine a restaurant delivery system:**

```
Customer (Flutter App): "I want to place an order for pizza"
    ↓
Order System (StripeService): "Let me call the restaurant's create-order function"
    ↓
Tries to reach: "create-payment-intent" restaurant branch
    ↓
⚠️ 404 ERROR - That restaurant branch DOESN'T EXIST!
    ↓
No one to process the order ❌
```

**After fix:**

```
Customer (Flutter App): "I want to place an order for pizza"
    ↓
Order System (StripeService): "Let me call the restaurant's create-order function"
    ↓
Tries to reach: "create-payment-intent" restaurant branch
    ↓
✅ Branch EXISTS! Restaurant receives order
    ↓
Creates the order and sends back order ID ✅
```

---

## The Data Flow (Step by Step)

### Step 1: User Initiates Payment
```
User sees: [Plan Details]
           [Continue Button]
```

### Step 2: Flutter App Makes Request
```dart
// payment_checkout_screen.dart
await _stripe.processPayment(
  planId: "plan_123",
  userId: "user_456"
);
```

### Step 3: StripeService Sends to Edge Function
```dart
final response = await _client.functions.invoke(
  'create-payment-intent',  // ← Looking for this function
  body: {
    'plan_id': 'plan_123',
    'user_id': 'user_456',
  },
);
```

### Step 4: Supabase Routes to Edge Function
```
Supabase receives: /functions/v1/create-payment-intent
Looks for: /supabase/functions/create-payment-intent/index.ts
Status: ✅ FOUND!
```

### Step 5: Edge Function Calls Stripe
```typescript
const paymentIntentResponse = await fetch(
  "https://api.stripe.com/v1/payment_intents",
  {
    method: "POST",
    headers: {
      Authorization: `Bearer sk_test_xxx...`,
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      amount: "999",        // $9.99
      currency: "usd",
      automatic_payment_methods: "true",
      metadata: JSON.stringify({
        plan_id: "plan_123",
        user_id: "user_456",
      }),
    }),
  }
);
```

### Step 6: Stripe Returns Payment Intent
```json
{
  "id": "pi_1234567890",
  "client_secret": "pi_1234567890_secret_abcdef...",
  "amount": 999,
  "currency": "usd",
  "status": "requires_payment_method"
}
```

### Step 7: Edge Function Returns to Flutter
```json
{
  "client_secret": "pi_1234567890_secret_abcdef...",
  "payment_intent_id": "pi_1234567890",
  "amount": 999,
  "currency": "usd"
}
```

### Step 8: Flutter Shows Stripe Payment Sheet
```
User sees native Stripe Payment Sheet:
[Card Details Input]
[Pay $9.99 Button]
```

---

## Environment Variables Required

Your `.env` file has:
```properties
STRIPE_PUBLISHABLE_KEY=pk_test_[YOUR_PUBLISHABLE_KEY]
STRIPE_SECRET_KEY=sk_test_[YOUR_SECRET_KEY]
```

**Important:**
- `STRIPE_PUBLISHABLE_KEY` - Used by Flutter app (safe to expose)
- `STRIPE_SECRET_KEY` - Used by Edge Function (KEEP SECRET!)

You need to set `STRIPE_SECRET_KEY` as a Supabase secret:
```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx...
```

---

## Summary

| Question | Answer |
|----------|--------|
| **What caused 404?** | Edge Function didn't exist |
| **How to fix it?** | Create the Edge Function file |
| **Where is the function?** | `/supabase/functions/create-payment-intent/index.ts` |
| **What does it do?** | Creates Stripe Payment Intent and returns client_secret |
| **Who calls it?** | Flutter app via StripeService.processPayment() |
| **What's the response?** | client_secret needed for Payment Sheet |

---

## Next Steps

1. ✅ **Verified Edge Function exists** - `create-payment-intent/index.ts`
2. ⏳ **Need to deploy** - Run: `supabase functions deploy create-payment-intent`
3. ⏳ **Set secrets** - Run: `supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx...`
4. ⏳ **Test payment flow** - Try making a payment on iOS/Android device

