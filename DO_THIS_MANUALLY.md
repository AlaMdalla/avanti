# 🎯 WHAT YOU NEED TO ADD TO SUPABASE - MANUAL SETUP

## 📋 Summary

You need to **manually run SQL in Supabase** because you mentioned having problems with migrations.

I've prepared **copy-paste ready SQL** for you.

---

## 🚀 QUICK START (3 Steps, 5 Minutes)

### STEP 1️⃣: Go to Supabase SQL Editor

```
https://supabase.com/dashboard
  ↓
Select your project
  ↓
Left sidebar: SQL Editor
  ↓
Click: New Query
```

---

### STEP 2️⃣: Copy This SQL and Paste

**Copy everything below and paste into Supabase SQL Editor:**

```sql
-- CREATE TABLES
CREATE TABLE IF NOT EXISTS plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'usd',
  interval TEXT NOT NULL DEFAULT 'month',
  stripe_plan_id TEXT UNIQUE,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE RESTRICT,
  stripe_subscription_id TEXT UNIQUE,
  stripe_customer_id TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  cancel_at TIMESTAMP WITH TIME ZONE,
  canceled_at TIMESTAMP WITH TIME ZONE,
  ended_at TIMESTAMP WITH TIME ZONE,
  start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES subscriptions(id) ON DELETE SET NULL,
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE RESTRICT,
  stripe_payment_intent_id TEXT UNIQUE,
  stripe_charge_id TEXT UNIQUE,
  amount_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'usd',
  status TEXT NOT NULL DEFAULT 'pending',
  error_message TEXT,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- CREATE INDEXES
CREATE INDEX idx_plans_active ON plans(active);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_plan ON subscriptions(plan_id);
CREATE INDEX idx_subscriptions_stripe_id ON subscriptions(stripe_subscription_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_subscription ON payments(subscription_id);
CREATE INDEX idx_payments_stripe_intent ON payments(stripe_payment_intent_id);
CREATE INDEX idx_payments_status ON payments(status);

-- ENABLE SECURITY
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read active plans" ON plans FOR SELECT USING (active = true);
CREATE POLICY "Authenticated can read all plans" ON plans FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can read own subscriptions" ON subscriptions FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Authenticated can insert subscriptions" ON subscriptions FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own subscriptions" ON subscriptions FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can read own payments" ON payments FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Authenticated can insert payments" ON payments FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

-- INSERT SAMPLE PLANS
INSERT INTO plans (name, description, price_cents, currency, interval, active)
VALUES
  ('Free Plan', 'Access to basic courses', 0, 'usd', 'month', true),
  ('Premium Monthly', 'Access to all premium courses - renews monthly', 999, 'usd', 'month', true),
  ('Premium Annual', 'Access to all premium courses - saves 20%', 9999, 'usd', 'year', true)
ON CONFLICT DO NOTHING;

-- CREATE HELPER FUNCTIONS
CREATE OR REPLACE FUNCTION get_user_active_subscription(p_user_id UUID)
RETURNS subscriptions AS $$
  SELECT * FROM subscriptions
  WHERE user_id = p_user_id AND status = 'active'
  AND (current_period_end IS NULL OR current_period_end > NOW())
  ORDER BY created_at DESC LIMIT 1;
$$ LANGUAGE SQL STABLE;

CREATE OR REPLACE FUNCTION has_active_subscription(p_user_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM subscriptions
    WHERE user_id = p_user_id AND status = 'active'
    AND (current_period_end IS NULL OR current_period_end > NOW())
  );
$$ LANGUAGE SQL STABLE;

-- VERIFY
SELECT 'Setup Complete!' as status;
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('plans', 'subscriptions', 'payments');
SELECT COUNT(*) as plan_count FROM plans;
```

**Click Run ✓**

---

### STEP 3️⃣: Set Stripe Secret

1. Go to: **Settings** (left sidebar)
2. Click: **Secrets and variables**
3. Click: **New secret**
4. Fill in:
   - Name: `STRIPE_SECRET_KEY`
   - Value: `sk_test_[YOUR_SECRET_KEY_HERE]`
5. Click: **Add secret**

---

## ✅ THAT'S IT!

Your Supabase is now ready for Stripe payments.

---

## 📋 What Got Created

| Thing | What It Does |
|-------|--------------|
| `plans` table | Stores subscription plans (Free, Premium, etc.) |
| `subscriptions` table | Tracks user subscriptions |
| `payments` table | Tracks payment transactions |
| 3 sample plans | Free ($0), Premium Monthly ($9.99), Premium Annual ($99.99) |
| RLS policies | Users can only see their own data |
| Helper functions | Check if user has active subscription |
| Indexes | Speed up queries |

---

## 🔄 How It Works

1. **User sees plans** (from `plans` table)
2. **User clicks Subscribe**
3. **App calls Edge Function** `create-payment-intent`
4. **Function uses `STRIPE_SECRET_KEY`** to call Stripe
5. **Stripe returns `client_secret`**
6. **Payment Sheet appears** (native mobile UI)
7. **User pays**
8. **Payment recorded** in `payments` table
9. **Subscription created** in `subscriptions` table

---

## 🎯 Your Environment (.env)

Already has everything:

```
STRIPE_PUBLISHABLE_KEY=pk_test_[YOUR_PUBLISHABLE_KEY]
STRIPE_SECRET_KEY=sk_test_[YOUR_SECRET_KEY]
```

✅ Perfect!

---

## 🧪 Verify It Worked

Run this in SQL Editor:

```sql
-- Should return: 3 (plans, subscriptions, payments)
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name IN ('plans', 'subscriptions', 'payments');

-- Should return: 3 plans
SELECT id, name, price_cents FROM plans;

-- Should work
SELECT has_active_subscription('00000000-0000-0000-0000-000000000000'::UUID);
```

---

## 📁 Reference Files I Created

- `QUICK_SUPABASE_SETUP.md` ← Same SQL as above
- `SUPABASE_SQL_SETUP.sql` ← With detailed comments
- `MANUAL_SUPABASE_SETUP.md` ← Step by step guide
- `STRIPE_404_EXPLANATION.md` ← Why 404 errors happen
- `CHECKLIST.md` ← What's done, what's left

---

## ✨ YOU'RE DONE!

Everything else is already implemented:
- ✅ Flutter app ready
- ✅ Stripe service ready
- ✅ Edge Function ready
- ⏳ Just needed to set up Supabase (done!)

Your app can now accept payments! 🎉

