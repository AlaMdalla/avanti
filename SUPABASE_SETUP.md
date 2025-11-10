# Supabase Setup Checklist for Stripe Payment Integration

## ✅ What You Need to Do in Supabase

### 1. Deploy the Edge Function
You created the function file, but you need to **deploy it** to Supabase:

```bash
cd /home/noya/dev/avanti_mobile
supabase functions deploy create-payment-intent
```

**What this does:**
- Uploads your `create-payment-intent` function to Supabase servers
- Makes it available at: `https://your-project-url/functions/v1/create-payment-intent`
- Without deployment, the function only exists locally (404 error!)

---

### 2. Set the STRIPE_SECRET_KEY Secret

The Edge Function needs your Stripe secret key to call Stripe API:

```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_[YOUR_SECRET_KEY_HERE]
```

**What this does:**
- Stores your Stripe secret key securely in Supabase
- The Edge Function can access it via: `Deno.env.get("STRIPE_SECRET_KEY")`
- **IMPORTANT:** Never expose this key in your Flutter app!

**How it works in the function:**
```typescript
const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
// Now it can use this to authenticate with Stripe API
```

---

### 3. Verify the Function Works (Optional but Recommended)

Test the function directly in Supabase:

```bash
supabase functions invoke create-payment-intent --body '{"plan_id":"test_plan","user_id":"test_user"}'
```

**Expected response:**
```json
{
  "client_secret": "pi_xxx_secret_xxx",
  "payment_intent_id": "pi_xxx",
  "amount": 999,
  "currency": "usd"
}
```

---

## 📋 Step-by-Step Guide

### Option A: Using Terminal (Recommended)

**Step 1:** Deploy the function
```bash
cd /home/noya/dev/avanti_mobile
supabase functions deploy create-payment-intent
```

**Step 2:** Set the secret
```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_[YOUR_SECRET_KEY_HERE]
```

**Step 3:** Verify it's deployed
```bash
supabase functions list
```

You should see:
```
✓ create-payment-intent
✓ create-checkout-session
✓ create-subscription-session
✓ stripe-webhook
```

---

### Option B: Using Supabase Dashboard (Web Interface)

1. Go to: https://app.supabase.com/
2. Select your project
3. Go to: **Functions** (left sidebar)
4. Look for `create-payment-intent`
5. Click it and verify it's deployed
6. Go to: **Settings** → **Secrets**
7. Add `STRIPE_SECRET_KEY` with your secret key value

---

## 🔄 The Complete Flow After Setup

```
1. User taps "Continue" on payment confirmation
   ↓
2. Flutter app calls: StripeService.processPayment()
   ↓
3. StripeService invokes Edge Function: "create-payment-intent"
   ↓
4. Supabase routes to: /functions/v1/create-payment-intent ✅ FOUND
   ↓
5. Edge Function gets STRIPE_SECRET_KEY from Supabase secrets ✅
   ↓
6. Edge Function calls Stripe API with secret key
   ↓
7. Stripe returns Payment Intent with client_secret
   ↓
8. Edge Function returns client_secret to Flutter app
   ↓
9. Flutter shows Stripe Payment Sheet
   ↓
10. User completes payment
   ↓
11. Navigate to subscription screen
```

---

## ⚠️ Common Mistakes to Avoid

### ❌ Mistake 1: Forgetting to Deploy
```bash
# WRONG - Just creating the file isn't enough
# You need to run:
supabase functions deploy create-payment-intent
```

### ❌ Mistake 2: Not Setting the Secret
```bash
# WRONG - Function won't work without the key
# You need to run:
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx
```

### ❌ Mistake 3: Using Test Key Instead of Secret
```bash
# WRONG - Using PUBLISHABLE key for secret
supabase secrets set STRIPE_SECRET_KEY=pk_test_xxx  ❌

# RIGHT - Using SECRET key for secret
supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx  ✅
```

### ❌ Mistake 4: Exposing Secret Key in Flutter App
```dart
// WRONG - Secret key in app code
final secretKey = 'sk_test_xxx';  ❌

// RIGHT - Secret key only on server (Edge Function)
// Only use publishable key in Flutter
Stripe.publishableKey = 'pk_test_xxx';  ✅
```

---

## 🔐 Security: Keys Explained

| Key | Type | Location | Purpose |
|-----|------|----------|---------|
| `STRIPE_PUBLISHABLE_KEY` | Public | Flutter app (`.env`) | Identifies your app to Stripe |
| `STRIPE_SECRET_KEY` | Secret | Supabase secrets | Authenticates API calls from server |

---

## 🧪 Testing the Setup

### Test 1: Check Function is Deployed
```bash
supabase functions list
```

### Test 2: Check Secret is Set
```bash
supabase secrets list
```

### Test 3: Invoke Function
```bash
supabase functions invoke create-payment-intent \
  --body '{"plan_id":"plan_123","user_id":"user_456"}'
```

### Test 4: Check Logs (if error)
```bash
supabase functions logs create-payment-intent
```

---

## 📱 After Setup - What Happens in Your App

### On iOS/Android:
```
User taps "Choose" on a plan
   ↓
PaymentCheckoutScreen shows "Opening checkout..."
   ↓
Calls create-payment-intent Edge Function ✅
   ↓
Receives client_secret ✅
   ↓
Initializes Stripe Payment Sheet ✅
   ↓
Shows native payment UI ✅
   ↓
User enters card details and taps "Pay"
   ↓
Payment successful!
   ↓
Navigate to subscription screen
```

### On Web/Linux (Fallback):
```
Uses browser-based checkout
(Still calls create-checkout-session function)
```

---

## Summary Checklist

Before testing payment:

- [ ] Created `/supabase/functions/create-payment-intent/index.ts` ✅ (Done)
- [ ] Deploy function: `supabase functions deploy create-payment-intent`
- [ ] Set secret: `supabase secrets set STRIPE_SECRET_KEY=sk_test_xxx`
- [ ] Verify deployment: `supabase functions list`
- [ ] Test invocation: `supabase functions invoke create-payment-intent --body '{"plan_id":"test","user_id":"test"}'`
- [ ] Build Flutter app: `flutter run` (on iOS/Android device)
- [ ] Test payment flow

