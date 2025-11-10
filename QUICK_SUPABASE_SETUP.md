# QUICK SETUP - Copy & Paste Ready

## 🚀 Quick Start (3 Steps)

### STEP 1: Open Supabase SQL Editor
- Go to: https://supabase.com/dashboard
- Select your project
- Left sidebar → **SQL Editor**
- Click **New Query**

---

### STEP 2: Copy This Entire Block and Paste into SQL Editor

```sql
-- CREATE PLANS TABLE
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

-- CREATE SUBSCRIPTIONS TABLE
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

-- CREATE PAYMENTS TABLE
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

-- ENABLE ROW LEVEL SECURITY
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- CREATE POLICIES
CREATE POLICY "Anyone can read active plans" ON plans
  FOR SELECT USING (active = true);

CREATE POLICY "Authenticated can read all plans" ON plans
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can read own subscriptions" ON subscriptions
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Authenticated can insert subscriptions" ON subscriptions
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subscriptions" ON subscriptions
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can read own payments" ON payments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Authenticated can insert payments" ON payments
  FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);

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
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name IN ('plans', 'subscriptions', 'payments');
```

Click **Run** and wait for it to complete ✅

---

### STEP 3: Set Stripe Secret Key

**Via Dashboard (Easier):**
1. Go to Supabase Dashboard
2. Settings → **Secrets and variables** (left sidebar)
3. Click **New secret**
4. Name: `STRIPE_SECRET_KEY`
5. Value: Copy from your `.env` file
   ```
   sk_test_[YOUR_SECRET_KEY_HERE]
   ```
6. Click **Add secret**

---

## ✅ Verification

Run this in SQL Editor to verify everything works:

```sql
-- Check tables
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name IN ('plans', 'subscriptions', 'payments');

-- Check plans
SELECT id, name, price_cents FROM plans;

-- Check RLS enabled
SELECT tablename FROM pg_tables 
WHERE tablename IN ('plans', 'subscriptions', 'payments') AND rowsecurity = true;
```

---

## 📊 What Gets Created

| Table | Purpose |
|-------|---------|
| `plans` | Subscription plan options |
| `subscriptions` | User's active subscriptions |
| `payments` | Payment transaction history |

---

## 🔐 Security

- ✅ Row Level Security (RLS) enabled on all tables
- ✅ Users can only see their own data
- ✅ Public can read active plans
- ✅ Service role can manage everything

---

## 🚀 That's It!

Your Supabase is now ready for Stripe payments! 

Your app will now:
1. Let users browse plans
2. Create payment intents via Edge Function
3. Track payments in the `payments` table
4. Update subscriptions when payment succeeds

---

## 📝 Notes

- The `create-payment-intent` Edge Function will automatically use the `STRIPE_SECRET_KEY` secret
- All tables have automatic `updated_at` timestamps
- Sample plans are inserted (Free, Premium Monthly, Premium Annual)
- Helper functions available for checking user subscriptions

