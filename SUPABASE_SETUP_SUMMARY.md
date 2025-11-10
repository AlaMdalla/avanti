# Supabase Setup Summary - Manual SQL Editor

## 📋 Files to Reference

I've created 3 helpful files for you:

### 1. **QUICK_SUPABASE_SETUP.md** ⭐ START HERE
   - Copy-paste ready SQL
   - 3 simple steps
   - Takes 5 minutes

### 2. **SUPABASE_SQL_SETUP.sql**
   - Full SQL with comments
   - Use if you need detailed explanation
   - Can also use in migrations

### 3. **MANUAL_SUPABASE_SETUP.md**
   - Step-by-step instructions
   - Troubleshooting guide
   - Verification queries

---

## ✅ What You Need to Do Manually

### Step 1: Create Database Tables
**Where:** Supabase Dashboard → SQL Editor  
**Action:** Paste the SQL from `QUICK_SUPABASE_SETUP.md`  
**Time:** 2 minutes

### Step 2: Set Stripe Secret
**Where:** Supabase Dashboard → Settings → Secrets  
**Action:** Create a new secret called `STRIPE_SECRET_KEY`  
**Value:** Your Stripe secret key from `.env`  
**Time:** 1 minute

### Step 3: Verify Edge Function
**Where:** Supabase Dashboard → Edge Functions  
**Status:** Should be auto-deployed (check if exists)  
**Time:** 1 minute to check

---

## 📊 Database Schema

```
┌──────────────────┐
│     PLANS        │  (3 samples provided)
│  id, name, price │  - Free Plan ($0)
│  currency        │  - Premium Monthly ($9.99)
│  interval        │  - Premium Annual ($99.99)
└────────┬─────────┘
         │
         │ FK: plan_id
         ↓
┌──────────────────────┐
│  SUBSCRIPTIONS       │  (user subscriptions)
│  id, user_id         │
│  plan_id             │
│  status (active...)  │
│  period dates        │
└────────┬─────────────┘
         │
         │ FK: subscription_id
         ↓
┌──────────────────────┐
│    PAYMENTS          │  (payment history)
│  id, user_id         │
│  stripe_intent_id    │
│  amount, status      │
│  error_message       │
└──────────────────────┘
```

---

## 🔒 Security (RLS - Row Level Security)

**Plans Table:**
- Public: Can read active plans only
- Authenticated: Can read all plans

**Subscriptions Table:**
- Users: Can only see their own subscriptions
- Can create: For themselves only

**Payments Table:**
- Users: Can only see their own payments
- Can create: For themselves only

---

## 🔧 Helper Functions Created

```sql
-- Get user's current active subscription
SELECT * FROM get_user_active_subscription('user-id-here');

-- Check if user has active subscription
SELECT has_active_subscription('user-id-here');
```

---

## 📱 How It Works After Setup

1. **User browses plans** (from `plans` table)
2. **User clicks "Subscribe"**
3. **App creates payment intent** (via `create-payment-intent` Edge Function)
   - Function uses `STRIPE_SECRET_KEY` to call Stripe API
   - Returns `client_secret` to the app
4. **Stripe Payment Sheet appears** (native UI)
5. **User enters card details**
6. **Payment succeeds**
7. **Webhook creates record** in `payments` table
8. **Subscription created** in `subscriptions` table with `status = 'active'`
9. **App navigates** to subscription screen

---

## ⏱️ Timeline

| Step | Time | Where |
|------|------|-------|
| Run SQL | 2 min | Supabase SQL Editor |
| Set Secret | 1 min | Supabase Settings |
| Verify | 1 min | Supabase Functions |
| **Total** | **~5 min** | |

---

## 🆘 Troubleshooting

**Q: "Table already exists" error**
A: Safe to ignore - SQL uses `IF NOT EXISTS`

**Q: "Permission denied"**
A: Make sure you're logged in as admin in Supabase

**Q: Tables created but no data shows up**
A: Run the verification query - if tables exist, data is ready

**Q: 404 error still happening**
A: Make sure `STRIPE_SECRET_KEY` is set in Secrets

---

## 📋 Checklist

- [ ] Opened Supabase SQL Editor
- [ ] Copied SQL from `QUICK_SUPABASE_SETUP.md`
- [ ] Pasted into SQL Editor and clicked Run
- [ ] Verified tables exist (check section below)
- [ ] Went to Settings → Secrets
- [ ] Created `STRIPE_SECRET_KEY` secret
- [ ] Verified Edge Function exists
- [ ] Ready to test payment flow!

---

## ✅ Verification Queries

Paste these one at a time in SQL Editor to verify:

```sql
-- 1. Check tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('plans', 'subscriptions', 'payments');
-- Expected: 3 rows (plans, subscriptions, payments)

-- 2. Check sample plans
SELECT id, name, price_cents, currency FROM plans ORDER BY price_cents;
-- Expected: 3 plans (0 cents, 999 cents, 9999 cents)

-- 3. Check RLS enabled
SELECT tablename FROM pg_tables 
WHERE tablename IN ('plans', 'subscriptions', 'payments') AND rowsecurity = true;
-- Expected: 3 rows (all have RLS)

-- 4. Test helper function
SELECT has_active_subscription('00000000-0000-0000-0000-000000000000'::UUID);
-- Expected: false (no subscription for this user)
```

---

## 🎯 Next Steps

1. ✅ Run the SQL in Supabase
2. ✅ Set STRIPE_SECRET_KEY in Secrets
3. ⏳ Deploy Edge Function (usually auto-deployed)
4. ⏳ Test on iOS or Android device
5. ⏳ Monitor payments in Supabase → Tables → payments

---

## 📞 Support

If you have issues:
1. Check the verification queries above
2. Read `MANUAL_SUPABASE_SETUP.md` for detailed help
3. Check Supabase Dashboard → Logs for errors
4. Verify Edge Function logs: Dashboard → Functions → create-payment-intent → Logs

---

**You're all set! Ready to accept payments! 🎉**

