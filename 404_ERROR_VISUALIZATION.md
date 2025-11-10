# 404 Error Visualization

## The Problem - 404 Not Found

```
┌─────────────────────────────────────────────────────────────┐
│                  YOUR FLUTTER APP                            │
│  (lib/features/subscription/screens/payment_checkout_screen)│
│                                                               │
│  User taps [Continue] button                                 │
│  ↓                                                            │
│  Calls: _stripe.processPayment()                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              STRIPE SERVICE (Flutter)                        │
│  (lib/features/subscription/services/stripe_service.dart)   │
│                                                               │
│  Prepares request:                                           │
│  {                                                           │
│    'plan_id': 'plan_123',                                    │
│    'user_id': 'user_456'                                     │
│  }                                                           │
│                                                               │
│  Calls: _client.functions.invoke('create-payment-intent')   │
└─────────────────────────────────────────────────────────────┘
                          ↓
         ┌────────────────────────────────┐
         │  Supabase (Backend)            │
         │  Looking for Edge Function:    │
         │  'create-payment-intent'       │
         │                                │
         │  ❌ FUNCTION NOT FOUND!        │
         │  404 ERROR RETURNED            │
         └────────────────────────────────┘
                          ↓
         ┌────────────────────────────────┐
         │  Error Response                │
         │  {                             │
         │    "error": "404",             │
         │    "message": "Not Found"      │
         │  }                             │
         └────────────────────────────────┘
                          ↓
         ┌────────────────────────────────┐
         │  Flutter App Shows Error       │
         │  "Function not found"          │
         └────────────────────────────────┘
```

---

## The Solution - Function Now Exists

```
┌─────────────────────────────────────────────────────────────┐
│                  YOUR FLUTTER APP                            │
│  (payment_checkout_screen.dart)                              │
│                                                               │
│  User taps [Continue] button                                 │
│  ↓                                                            │
│  Calls: _stripe.processPayment()                             │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              STRIPE SERVICE (Flutter)                        │
│  (stripe_service.dart)                                      │
│                                                               │
│  Sends: {                                                    │
│    'plan_id': 'plan_123',                                    │
│    'user_id': 'user_456'                                     │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
         ┌────────────────────────────────┐
         │  Supabase (Backend)            │
         │  Looking for Edge Function:    │
         │  'create-payment-intent'       │
         │                                │
         │  ✅ FUNCTION FOUND!            │
         │  Routing to function handler   │
         └────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│         EDGE FUNCTION (TypeScript/Deno)                      │
│  (/supabase/functions/create-payment-intent/index.ts)       │
│                                                               │
│  Receives request:                                           │
│  {                                                           │
│    plan_id: 'plan_123',                                      │
│    user_id: 'user_456'                                       │
│  }                                                           │
│                                                               │
│  Creates Stripe Payment Intent:                             │
│  POST https://api.stripe.com/v1/payment_intents             │
│  Authorization: Bearer sk_test_xxx...                        │
│  amount: 999                                                 │
│  currency: usd                                               │
└─────────────────────────────────────────────────────────────┘
                          ↓
         ┌────────────────────────────────┐
         │  Stripe API (Payment Provider) │
         │                                │
         │  ✅ Creates Payment Intent     │
         │  Returns:                      │
         │  {                             │
         │    id: 'pi_1234567890',        │
         │    client_secret: '...',       │
         │    amount: 999,                │
         │    status: 'requires...'       │
         │  }                             │
         └────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│         EDGE FUNCTION (TypeScript/Deno)                      │
│                                                               │
│  Extracts important fields:                                  │
│  {                                                           │
│    client_secret: 'pi_xxx_secret_...',                       │
│    payment_intent_id: 'pi_1234567890',                       │
│    amount: 999,                                              │
│    currency: 'usd'                                           │
│  }                                                           │
│                                                               │
│  ✅ Returns 200 OK                                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│              STRIPE SERVICE (Flutter)                        │
│                                                               │
│  Receives response:                                          │
│  {                                                           │
│    'success': true,                                          │
│    'clientSecret': 'pi_xxx_secret_...'                       │
│  }                                                           │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│            PAYMENT CHECKOUT SCREEN                           │
│  (payment_checkout_screen.dart)                              │
│                                                               │
│  Initializes Stripe Payment Sheet:                           │
│  await Stripe.instance.initPaymentSheet(                     │
│    paymentIntentClientSecret: 'pi_xxx_secret_...'            │
│  );                                                          │
│                                                               │
│  Presents Payment Sheet to user:                             │
│  ┌─────────────────────┐                                     │
│  │ 💳 Add your card    │                                     │
│  │                     │                                     │
│  │ Card number: ______ │                                     │
│  │ Exp: __ / __  CVC:__│                                     │
│  │                     │                                     │
│  │    [Pay $9.99]      │                                     │
│  └─────────────────────┘                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Points About 404 Error

### ❌ BEFORE (404 Error)
- Edge function file **didn't exist**
- Supabase couldn't find the function handler
- Request returned: **404 Not Found**
- Payment flow **STOPPED**

### ✅ AFTER (No 404)
- Edge function file **exists** at correct path
- Supabase **finds and executes** the function
- Function communicates with **Stripe API**
- Returns **client_secret** to Flutter app
- Payment flow **CONTINUES**

---

## File Structure

```
avanti_mobile/
│
├── lib/
│   └── features/
│       └── subscription/
│           ├── screens/
│           │   └── payment_checkout_screen.dart   ← User taps button
│           └── services/
│               └── stripe_service.dart             ← Calls Edge Function
│
└── supabase/
    └── functions/
        └── create-payment-intent/
            └── index.ts                            ← 404 Was here! Now exists ✅
```

---

## What Each Layer Does

```
LAYER 1: USER INTERFACE (Flutter)
├─ Shows plan details
├─ Shows checkout button
└─ Captures user interaction

                    ↓
LAYER 2: CLIENT LOGIC (StripeService)
├─ Packages data
├─ Calls Edge Function
└─ Handles response

                    ↓
LAYER 3: SERVER LOGIC (Edge Function)
├─ Validates input
├─ Calls Stripe API
└─ Returns payment intent

                    ↓
LAYER 4: PAYMENT PROVIDER (Stripe)
├─ Creates payment intent
├─ Returns client secret
└─ Processes payment
```

---

## Common 404 Causes

| Cause | Status | Fix |
|-------|--------|-----|
| Edge function file doesn't exist | ❌ | Create the file |
| Wrong function name in invoke() | ❌ | Check spelling |
| Edge function not deployed | ❌ | Run `supabase functions deploy` |
| Supabase project offline | ❌ | Check project status |
| Wrong Supabase URL | ❌ | Verify supabase_config.dart |

---

## How to Debug 404 Errors

### Step 1: Check Function Exists
```bash
ls -la supabase/functions/create-payment-intent/
# Should show: index.ts
```

### Step 2: Check Function Name in Code
```dart
// stripe_service.dart - Line 71
final response = await _client.functions.invoke(
  'create-payment-intent',  // ← Must match folder name exactly
  body: { /* ... */ },
);
```

### Step 3: Deploy Function
```bash
supabase functions deploy create-payment-intent
```

### Step 4: Set Secrets
```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx...
```

### Step 5: Check Logs
```bash
supabase functions logs create-payment-intent
```

