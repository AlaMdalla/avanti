-- ============================================================================
-- SUPABASE SQL SETUP FOR STRIPE PAYMENT INTEGRATION
-- ============================================================================
-- Copy and paste these SQL commands into your Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- 1. CREATE PLANS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price_cents INTEGER NOT NULL, -- Price in cents (e.g., 999 = $9.99)
  currency TEXT NOT NULL DEFAULT 'usd',
  interval TEXT NOT NULL DEFAULT 'month', -- 'month', 'year'
  stripe_plan_id TEXT UNIQUE,
  active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE plans IS 'Subscription plans for the application';
COMMENT ON COLUMN plans.price_cents IS 'Price in cents (multiply by 100 for API calls)';
COMMENT ON COLUMN plans.stripe_plan_id IS 'Stripe product/plan ID for sync';

-- Create index for active plans
CREATE INDEX idx_plans_active ON plans(active);

-- ============================================================================
-- 2. CREATE SUBSCRIPTIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES plans(id) ON DELETE RESTRICT,
  stripe_subscription_id TEXT UNIQUE,
  stripe_customer_id TEXT,
  status TEXT NOT NULL DEFAULT 'pending', 
  -- Status: 'pending', 'active', 'canceled', 'expired'
  current_period_start TIMESTAMP WITH TIME ZONE,
  current_period_end TIMESTAMP WITH TIME ZONE,
  cancel_at TIMESTAMP WITH TIME ZONE,
  canceled_at TIMESTAMP WITH TIME ZONE,
  ended_at TIMESTAMP WITH TIME ZONE,
  start_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE subscriptions IS 'User subscriptions to plans';
COMMENT ON COLUMN subscriptions.status IS 'Subscription status: pending, active, canceled, expired';
COMMENT ON COLUMN subscriptions.stripe_subscription_id IS 'Stripe subscription ID for webhook tracking';

-- Create indexes
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_plan ON subscriptions(plan_id);
CREATE INDEX idx_subscriptions_stripe_id ON subscriptions(stripe_subscription_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- ============================================================================
-- 3. CREATE PAYMENTS TABLE (to track payment attempts)
-- ============================================================================
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
  -- Status: 'pending', 'processing', 'succeeded', 'failed', 'canceled'
  error_message TEXT,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE payments IS 'Payment transaction history';
COMMENT ON COLUMN payments.stripe_payment_intent_id IS 'Stripe Payment Intent ID';
COMMENT ON COLUMN payments.stripe_charge_id IS 'Stripe Charge ID after success';
COMMENT ON COLUMN payments.metadata IS 'Additional payment metadata in JSON';

-- Create indexes
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_subscription ON payments(subscription_id);
CREATE INDEX idx_payments_stripe_intent ON payments(stripe_payment_intent_id);
CREATE INDEX idx_payments_status ON payments(status);

-- ============================================================================
-- 4. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

-- Plans table (everyone can read active plans)
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read active plans" ON plans
  FOR SELECT
  USING (active = true);

CREATE POLICY "Authenticated users can read all plans" ON plans
  FOR SELECT
  TO authenticated
  USING (true);

-- Subscriptions table (users can see only their own)
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own subscriptions" ON subscriptions
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Authenticated can insert subscriptions" ON subscriptions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own subscriptions" ON subscriptions
  FOR UPDATE
  USING (auth.uid() = user_id);

-- Payments table (users can see only their own)
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own payments" ON payments
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Authenticated can insert payments" ON payments
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- ============================================================================
-- 5. INSERT SAMPLE PLANS
-- ============================================================================

INSERT INTO plans (name, description, price_cents, currency, interval, active)
VALUES
  (
    'Free Plan',
    'Access to basic courses',
    0,
    'usd',
    'month',
    true
  ),
  (
    'Premium Monthly',
    'Access to all premium courses - renews monthly',
    999,
    'usd',
    'month',
    true
  ),
  (
    'Premium Annual',
    'Access to all premium courses - saves 20%',
    9999,
    'usd',
    'year',
    true
  )
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 6. CREATE HELPER FUNCTIONS
-- ============================================================================

-- Function to get user's active subscription
CREATE OR REPLACE FUNCTION get_user_active_subscription(p_user_id UUID)
RETURNS subscriptions AS $$
  SELECT *
  FROM subscriptions
  WHERE user_id = p_user_id
    AND status = 'active'
    AND (current_period_end IS NULL OR current_period_end > NOW())
  ORDER BY created_at DESC
  LIMIT 1;
$$ LANGUAGE SQL STABLE;

-- Function to check if user has active subscription
CREATE OR REPLACE FUNCTION has_active_subscription(p_user_id UUID)
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1
    FROM subscriptions
    WHERE user_id = p_user_id
      AND status = 'active'
      AND (current_period_end IS NULL OR current_period_end > NOW())
  );
$$ LANGUAGE SQL STABLE;

-- ============================================================================
-- 7. CREATE TRIGGERS FOR AUTOMATIC TIMESTAMPS
-- ============================================================================

-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for plans
CREATE TRIGGER plans_updated_at BEFORE UPDATE ON plans
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for subscriptions
CREATE TRIGGER subscriptions_updated_at BEFORE UPDATE ON subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for payments
CREATE TRIGGER payments_updated_at BEFORE UPDATE ON payments
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- 8. VERIFY SETUP
-- ============================================================================

-- Check that tables are created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('plans', 'subscriptions', 'payments');

-- Check that sample plans exist
SELECT id, name, price_cents, currency, interval FROM plans ORDER BY price_cents;

-- ============================================================================
-- END OF SQL SETUP
-- ============================================================================
-- After running this SQL, you need to:
-- 1. Set STRIPE_SECRET_KEY as a Supabase Secret
-- 2. Deploy the create-payment-intent Edge Function
-- 3. Test the payment flow on iOS/Android
-- ============================================================================
