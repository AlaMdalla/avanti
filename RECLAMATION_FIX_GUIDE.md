# 🔧 Reclamation Module - Fix for User & Admin Views

## ✅ What Was Fixed

### Problem 1: Users Couldn't See Their Own Reclamations
**Root Cause:** RLS policies were checking `auth.users.raw_user_meta_data->>'role'` instead of the `profiles` table

**Solution:** Updated all RLS policies to check `profiles.role` column instead

### Problem 2: Admins Couldn't Review All Reclamations
**Root Cause:** No admin view/screen was created

**Solution:** Created `AdminReclamationsScreen` with:
- View all reclamations
- Filter by status and priority
- Statistics dashboard
- Admin-only features

---

## 📊 Updated RLS Policies

### ✅ Fixed Policies in SQL

**Before (BROKEN):**
```sql
CREATE POLICY "Users can view their own reclamations" ON reclamations
  FOR SELECT
  USING (
    auth.uid() = user_id OR
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND auth.users.raw_user_meta_data->>'role' = 'admin'  -- ❌ WRONG!
    )
  );
```

**After (FIXED):**
```sql
CREATE POLICY "Users can view their own reclamations" ON reclamations
  FOR SELECT
  USING (
    auth.uid() = user_id OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'  -- ✅ CORRECT!
    )
  );
```

---

## 📱 New Admin Features

### AdminReclamationsScreen
**File:** `lib/features/reclamation/screens/admin_reclamations_screen.dart`

**Features:**
- 📊 Statistics dashboard (Total, Open, Resolved, Closed)
- 🔍 Filter by status (all, open, in_progress, resolved, closed)
- 🎯 Filter by priority (all, low, medium, high, urgent)
- 📋 View all user reclamations
- 👤 See which user filed each reclamation
- 📅 Timestamps for when filed and resolved

**Screens:**
1. List all reclamations with statistics
2. Filter and sort options
3. Click to view details and respond

---

## 👨‍💼 Admin Functions in Detail View

### UpdateReclamation Status (Admin Only)

**New features added to `ReclamationDetailScreen`:**

1. **Status Update Panel** (only visible for admins)
   - Dropdown to select new status
   - Text field for reason (optional)
   - Update button

2. **Status Transitions:**
   ```
   open → in_progress → resolved → closed
                  ↑_________________↓
   (Admins can move status forward)
   ```

3. **Auto-Logging:**
   - Every status change is logged in `reclamation_history`
   - Records: who changed it, why, when
   - Users can see the history

---

## 🔄 Data Flow - How It Works Now

### For Users:
```
User taps "Reclamations" in sidebar
    ↓
ReclamationsListScreen opens
    ↓
Shows ONLY their own reclamations (RLS enforced)
    ↓
Can create new, view details, add responses
```

### For Admins:
```
Admin taps "Reclamations" in sidebar
    ↓
AdminReclamationsScreen opens (different screen!)
    ↓
Shows ALL reclamations from all users
    ↓
Can filter, update status, add responses
    ↓
Changes are logged in history table
```

---

## 🚀 How to Apply the Fix

### Step 1: Update SQL in Supabase

Go to: https://supabase.com/dashboard → SQL Editor → New Query

Copy the updated `RECLAMATION_SUPABASE_SETUP.sql` file and paste it.

**OR** run these specific fixes:

```sql
-- DROP old policies (if they exist)
DROP POLICY IF EXISTS "Users can view their own reclamations" ON reclamations;
DROP POLICY IF EXISTS "Users can update their own open reclamations" ON reclamations;
DROP POLICY IF EXISTS "Users can view responses to their reclamations" ON reclamation_responses;
DROP POLICY IF EXISTS "Only admins can create responses" ON reclamation_responses;
DROP POLICY IF EXISTS "Users can view history of their reclamations" ON reclamation_history;

-- CREATE new fixed policies
CREATE POLICY "Users can view their own reclamations" ON reclamations
  FOR SELECT
  USING (
    auth.uid() = user_id OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Users can create their own reclamations" ON reclamations
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own open reclamations" ON reclamations
  FOR UPDATE
  USING (
    (auth.uid() = user_id AND status = 'open') OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Users can view responses to their reclamations" ON reclamation_responses
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM reclamations
      WHERE reclamations.id = reclamation_responses.reclamation_id
      AND (
        reclamations.user_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM profiles
          WHERE profiles.id = auth.uid()
          AND profiles.role = 'admin'
        )
      )
    )
  );

CREATE POLICY "Only admins can create responses" ON reclamation_responses
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Users can view history of their reclamations" ON reclamation_history
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM reclamations
      WHERE reclamations.id = reclamation_history.reclamation_id
      AND (
        reclamations.user_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM profiles
          WHERE profiles.id = auth.uid()
          AND profiles.role = 'admin'
        )
      )
    )
  );
```

Click **Run** ✓

### Step 2: Flutter Code Already Updated ✅

✅ ReclamationDetailScreen - Added admin features
✅ AdminReclamationsScreen - Created new admin view
✅ main_navigation.dart - Integrated into sidebar
✅ ReclamationService - Already supports all operations

---

## 📁 Files Changed

### Modified:
- ✏️ `RECLAMATION_SUPABASE_SETUP.sql` - Fixed RLS policies
- ✏️ `lib/features/reclamation/screens/reclamation_detail_screen.dart` - Added admin status update
- ✏️ `lib/shared/navigation/main_navigation.dart` - Added admin screen

### Created:
- ✨ `lib/features/reclamation/screens/admin_reclamations_screen.dart` - Admin dashboard

---

## 🧪 Testing Checklist

### User Tests:
- [ ] User logs in
- [ ] User taps "Reclamations" in sidebar
- [ ] Sees their own reclamations list
- [ ] Creates new reclamation
- [ ] New one appears in list
- [ ] Clicks to view details
- [ ] Sees responses from admin
- [ ] Can add new response

### Admin Tests:
- [ ] Admin logs in
- [ ] Admin taps "Reclamations" in sidebar
- [ ] Sees "All Reclamations - Admin" screen (different from user)
- [ ] Shows statistics (Total, Open, Resolved, Closed)
- [ ] Can filter by status
- [ ] Can filter by priority
- [ ] Clicks on reclamation
- [ ] Sees "Admin: Update Status" section
- [ ] Can select new status from dropdown
- [ ] Can add reason for change
- [ ] Clicks "Update Status"
- [ ] Status changes and shows in history
- [ ] Can add response
- [ ] Response shows with "Support Team" badge

---

## 🎯 Key Differences: User vs Admin

| Feature | User | Admin |
|---------|------|-------|
| **Screen Type** | ReclamationsListScreen | AdminReclamationsScreen |
| **Can See** | Own reclamations only | All reclamations |
| **Can Create** | Yes | Yes (but labeled as their own) |
| **Can Update Status** | No | Yes (with reason) |
| **Can Respond** | Yes (user responses) | Yes (admin responses) |
| **See Statistics** | No | Yes (dashboard) |
| **Can Filter** | By status only | By status AND priority |
| **See All Users** | No | Yes (User ID shown) |

---

## 🔐 Security

### ✅ Row Level Security (RLS) is Enforced

- Users query: `SELECT * FROM reclamations WHERE user_id = current_user OR is_admin`
- Admins query: `SELECT * FROM reclamations` (all allowed)
- Database enforces this at SQL level
- No need to filter in app code

### ✅ Admin Check Uses Profiles Table

- Checks `profiles.role = 'admin'`
- Matches your app's authorization system
- Safe and consistent

---

## 📞 Troubleshooting

**Q: Still can't see reclamations?**
A: 
1. Make sure you ran the SQL to fix RLS policies
2. Try logging out and back in
3. Check browser console for auth errors

**Q: Admin doesn't see all reclamations?**
A:
1. Verify user has `role = 'admin'` in profiles table
2. Check RLS policies are applied correctly
3. Verify the import in main_navigation.dart

**Q: Status update button disabled?**
A: You must select a new status from the dropdown first

**Q: Status didn't change?**
A: Check Supabase logs for errors. Make sure you're logged in as admin.

---

## ✨ What's Next?

### Optional Enhancements:
1. **Bulk Actions** - Admin can close multiple at once
2. **Assignment** - Assign reclamation to support staff
3. **Email Notifications** - Notify user when status changes
4. **Categories Management** - Admin can create custom categories
5. **Search** - Full-text search of reclamations
6. **Export** - Export to CSV for reporting

---

## 📝 Summary

**Before:**
- ❌ Users couldn't see their reclamations
- ❌ Admins had no way to review complaints
- ❌ No way to track status changes

**After:**
- ✅ Users see only their own reclamations
- ✅ Admins have dedicated admin dashboard
- ✅ Admins can update status with reasons
- ✅ All changes are logged in history
- ✅ Full RLS security enforcement

---

**Status:** 🟢 Ready to test
**Last Updated:** November 10, 2025
