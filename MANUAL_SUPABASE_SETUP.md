# Manual Supabase Setup Guide - SQL Editor

## Step-by-Step Instructions

### Step 1: Open Supabase SQL Editor
1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to **SQL Editor** (left sidebar)
4. Click **New Query**

---

### Step 2: Copy and Paste the SQL

Open the file `SUPABASE_SQL_SETUP.sql` in your project root and copy ALL the SQL code.

Then paste it into the Supabase SQL Editor and click **Run**.

---

### Step 3: Verify the Setup

Run this query to verify tables were created:

```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('plans', 'subscriptions', 'payments');
```

You should see 3 rows:
- plans
- subscriptions  
- payments

---

### Step 4: Check Sample Plans

```sql
SELECT id, name, price_cents, currency, interval FROM plans;
```

You should see:
- Free Plan (0 cents)
- Premium Monthly (999 cents = $9.99)
- Premium Annual (9999 cents = $99.99)

---

## Step 5: Set Stripe Secret Key in Supabase

### Option A: Via Supabase Dashboard (Easiest)

1. Go to https://supabase.com/dashboard
2. Select your project
3. Go to **Settings** (left sidebar)
4. Click **Secrets and variables**
5. Click **New secret**
6. Name: `STRIPE_SECRET_KEY`
7. Value: `sk_test_[YOUR_SECRET_KEY_HERE]`
8. Click **Add secret**

### Option B: Via CLI

```bash
cd /home/noya/dev/avanti_mobile
supabase secrets set STRIPE_SECRET_KEY=sk_test_[YOUR_SECRET_KEY_HERE]
```

---

## Step 6: Deploy the Edge Function

If you have Supabase CLI installed:

```bash
cd /home/noya/dev/avanti_mobile
supabase functions deploy create-payment-intent
```

If you don't have CLI:
1. Go to Supabase Dashboard
2. Go to **Edge Functions** (left sidebar)
3. You should see `create-payment-intent` listed
4. It should be deployed automatically if the file exists

---

## What Gets Created

### Tables

**plans**
- Stores subscription plans
- Columns: id, name, description, price_cents, currency, interval, active, timestamps

**subscriptions**
- Stores user subscriptions
- Columns: id, user_id, plan_id, stripe_subscription_id, status, period dates, timestamps

**payments**
- Stores payment attempts
- Columns: id, user_id, plan_id, stripe IDs, amount, status, error message, timestamps

### Security Policies (RLS)

- Users can only read active plans
- Users can only see their own subscriptions
- Users can only see their own payments
- Service role (backend/functions) can access everything

### Helper Functions

- `get_user_active_subscription(user_id)` - Get user's current active subscription
- `has_active_subscription(user_id)` - Check if user has active subscription

---

## Verification Checklist

After setup, verify everything with these SQL queries:

```sql
-- 1. Check tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('plans', 'subscriptions', 'payments');

-- 2. Check sample plans exist
SELECT id, name, price_cents FROM plans ORDER BY price_cents;

-- 3. Check RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables 
WHERE tablename IN ('plans', 'subscriptions', 'payments');

-- 4. Check indexes
SELECT tablename, indexname FROM pg_indexes 
WHERE tablename IN ('plans', 'subscriptions', 'payments');
```

---

## Common Issues & Solutions

### Issue: "Table already exists"
**Solution:** The table creation uses `CREATE TABLE IF NOT EXISTS` so it's safe to run again.

### Issue: "Permission denied"
**Solution:** Make sure you're logged in with a Supabase admin account.

### Issue: "Stripe Secret Key not found"
**Solution:** Go to Settings → Secrets and verify `STRIPE_SECRET_KEY` is set.

### Issue: "Edge Function not found"
**Solution:** Make sure `create-payment-intent` folder exists at `/supabase/functions/create-payment-intent/index.ts`

---

## Database Schema Visualization

```
┌─────────────────┐
│     plans       │
├─────────────────┤
│ id (PK)         │
│ name            │
│ price_cents     │
│ interval        │
│ active          │
└────────┬────────┘
         │
         │ (one-to-many)
         ↓
┌─────────────────────┐
│  subscriptions      │
├─────────────────────┤
│ id (PK)             │
│ user_id (FK)        │
│ plan_id (FK)        │
│ status              │
│ period_start/end    │
└────────┬────────────┘
         │
         │ (one-to-many)
         ↓
┌─────────────────────┐
│     payments        │
├─────────────────────┤
│ id (PK)             │
│ user_id (FK)        │
│ subscription_id(FK) │
│ plan_id (FK)        │
│ stripe_intent_id    │
│ status              │
└─────────────────────┘
```

---

## Next Steps After Setup

1. ✅ Run the SQL in Supabase SQL Editor
2. ✅ Verify tables are created
3. ✅ Set STRIPE_SECRET_KEY secret
4. ✅ Deploy `create-payment-intent` Edge Function
5. ⏳ Test payment flow on iOS/Android device

---

## Support

If you have issues:
1. Check the **STRIPE_404_EXPLANATION.md** for payment flow details
2. Verify all secrets are set in Supabase Dashboard
3. Check Edge Function logs in Supabase Dashboard → Functions
4. Verify Flutter app can reach Supabase (check network tab in DevTools)

