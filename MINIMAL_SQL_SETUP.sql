-- ============================================================================
-- MINIMAL SUPABASE SQL SETUP FOR STRIPE (QUICK & WORKING)
-- ============================================================================
-- Just copy and paste into Supabase SQL Editor
-- ============================================================================

-- 1. PLANS TABLE
CREATE TABLE IF NOT EXISTS plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price_cents INTEGER NOT NULL CHECK (price_cents > 0),
  currency TEXT DEFAULT 'usd',
  interval TEXT DEFAULT 'month',
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 2. SUBSCRIPTIONS TABLE  
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  plan_id UUID NOT NULL REFERENCES plans(id),
  status TEXT DEFAULT 'active',
  stripe_subscription_id TEXT,
  start_date TIMESTAMP DEFAULT NOW(),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. PAYMENTS TABLE
CREATE TABLE IF NOT EXISTS payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  plan_id UUID NOT NULL REFERENCES plans(id),
  stripe_payment_intent_id TEXT,
  amount_cents INTEGER,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);

-- 4. INSERT SAMPLE PLANS (only paid plans, no free)
INSERT INTO plans (name, description, price_cents, currency, interval, active)
VALUES
  ('Premium Monthly', 'All features - Monthly', 999, 'usd', 'month', true),
  ('Premium Yearly', 'All features - Yearly', 9999, 'usd', 'year', true)
ON CONFLICT DO NOTHING;
