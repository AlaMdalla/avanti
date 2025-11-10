# ✅ Reclamation Module - Implementation Checklist

## 🚀 Quick Setup (5 Minutes)

### Step 1: Fix Database Policies ⚡
- [ ] Open Supabase SQL Editor
- [ ] Run the updated `RECLAMATION_SUPABASE_SETUP.sql`
- [ ] OR run the specific policy fixes from `RECLAMATION_FIX_GUIDE.md`
- [ ] Verify success message

### Step 2: Verify Flutter Code ✨
- [ ] AdminReclamationsScreen created ✅
- [ ] ReclamationDetailScreen updated with admin features ✅
- [ ] main_navigation.dart updated ✅
- [ ] All imports added ✅

### Step 3: Test the App 🧪
- [ ] Run `flutter run`
- [ ] Wait for hot reload
- [ ] No compilation errors

---

## 👥 User Testing

### Regular User Flow:
- [ ] Log in as regular user
- [ ] Click "Reclamations" in sidebar
- [ ] See "My Reclamations" list (ReclamationsListScreen)
- [ ] Click **+** button to create new
- [ ] Fill form and submit
  - [ ] Title (min 5 chars)
  - [ ] Description (min 10 chars)
  - [ ] Category dropdown
  - [ ] Priority dropdown
  - [ ] Optional rating
- [ ] New reclamation appears in list
- [ ] Click on reclamation to view details
- [ ] See status badge and priority
- [ ] See description in detail view
- [ ] See responses from admin
- [ ] Add new response and send
- [ ] Response appears immediately
- [ ] See "Admin: Update Status" section?
  - [ ] **NO** - User shouldn't see this ✓

---

## 👨‍💼 Admin Testing

### Admin User Flow:
- [ ] Log in as admin user
- [ ] Click "Reclamations" in sidebar
- [ ] See "All Reclamations - Admin" (different screen!)
- [ ] See statistics dashboard
  - [ ] Total count
  - [ ] Open count
  - [ ] Resolved count
  - [ ] Closed count
- [ ] See all reclamations from all users
- [ ] Use Status filter dropdown
  - [ ] Select "Open"
  - [ ] List updates to show only open
  - [ ] Select "All"
  - [ ] Shows all again
- [ ] Use Priority filter dropdown
  - [ ] Select "High"
  - [ ] Shows only high priority
- [ ] Click on a reclamation
- [ ] See "Admin: Update Status" section
  - [ ] Dropdown with status options
  - [ ] Text field for reason
  - [ ] Update button
- [ ] Select new status (e.g., "In Progress")
- [ ] Add reason (optional)
- [ ] Click "Update Status" button
- [ ] Success message appears
- [ ] Status badge updates
- [ ] See responses section
- [ ] Add admin response
- [ ] Response appears with "Support Team" badge
- [ ] User would see this response

---

## 🔍 Database Verification

### Check RLS Policies:
```sql
-- Run in Supabase SQL Editor to verify:

-- Should return 5 policies
SELECT policyname FROM pg_policies 
WHERE tablename = 'reclamations';

-- Test SELECT as user
SELECT COUNT(*) FROM reclamations;
-- Should return only user's reclamations

-- Test SELECT as admin
-- Should return all reclamations
```

---

## 🐛 Troubleshooting

### Issue: Compilation Error in Flutter
**Solution:**
- [ ] Check imports in files
- [ ] Run `flutter pub get`
- [ ] Clean and rebuild: `flutter clean && flutter run`

### Issue: App builds but crashes on Reclamations tab
**Solution:**
- [ ] Check Supabase connection
- [ ] Check RLS policies are applied
- [ ] Check user is authenticated
- [ ] View console/logcat for errors

### Issue: User sees no reclamations even after creating
**Solution:**
- [ ] RLS policies not fixed yet
- [ ] Run the SQL fixes from Step 1
- [ ] Log out and log back in
- [ ] Try creating another reclamation

### Issue: Admin sees only their own reclamations
**Solution:**
- [ ] Verify user has `role = 'admin'` in profiles table
- [ ] Check RLS policies were updated
- [ ] Clear app cache: `flutter clean`
- [ ] Restart app

### Issue: Admin can't update status
**Solution:**
- [ ] Make sure status dropdown has a value selected
- [ ] Check Supabase logs for permission errors
- [ ] Verify admin role in profiles table

---

## 📊 Data Verification Queries

### Check if tables exist:
```sql
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('reclamations', 'reclamation_responses', 'reclamation_history');
```
Should return: 3 tables

### Check if RLS is enabled:
```sql
SELECT tablename, rowsecurity FROM pg_tables 
WHERE tablename IN ('reclamations', 'reclamation_responses', 'reclamation_history');
```
All should show: `rowsecurity = true`

### Check policies:
```sql
SELECT policyname, cmd, qual FROM pg_policies 
WHERE tablename = 'reclamations';
```
Should return: 3 policies (select, insert, update)

### Count reclamations (as user):
```sql
SELECT COUNT(*) FROM reclamations;
```
Should return: only your reclamations (RLS enforced)

---

## 🎯 Feature Checklist

### Basic Features:
- [x] Users can create reclamations
- [x] Users can view their reclamations
- [x] Users can add responses
- [x] Users can rate before/after
- [x] Status tracking
- [x] Priority levels
- [x] Categories

### Admin Features:
- [x] View all reclamations
- [x] Filter by status
- [x] Filter by priority
- [x] Update status with reason
- [x] View statistics
- [x] Add admin responses
- [x] See user IDs

### Security:
- [x] RLS policies enforced
- [x] Users see only their own
- [x] Admins see all
- [x] Admin check via profiles table
- [x] Status updates logged

---

## 📱 Screen Navigation

### User Sidebar:
```
Home
├── Courses
├── Modules
├── Reclamations (⭐ NEW - User view)
├── Profile
├── Edit Profile
└── Messages
```

### Admin Sidebar:
```
Home
├── Courses
├── Modules
├── Reclamations (⭐ NEW - Admin view, different!)
├── Admin Dashboard
├── Profile
├── Edit Profile
└── Messages
```

---

## 🚦 Status Indicators

### User Creates:
- Status: "open" (blue)
- Priority: Selected by user
- Created At: Now
- Can be viewed, responded to

### Admin Reviews:
- Can change status to "in_progress" (amber)
- Can add reason
- Change logged in history table
- User sees history

### Admin Resolves:
- Changes status to "resolved" (green)
- Adds reason: "Fixed in v2.1"
- Sets resolved_at timestamp
- User can close or stay open

### Final:
- Status: "closed" (gray)
- No more changes
- Can view history

---

## ✨ Expected Behavior After Fix

| Scenario | Before Fix | After Fix |
|----------|-----------|-----------|
| User creates reclamation | ❌ Can't see it | ✅ Sees in list |
| Admin logs in | ❌ Can't see any | ✅ Sees all |
| User adds response | ❌ Error | ✅ Works |
| Admin updates status | ❌ Can't do it | ✅ Status changes |
| Check reclamation history | ❌ No history | ✅ Shows all changes |

---

## 🎓 Learning Resources

**Understand RLS:**
- Check `RECLAMATION_SUPABASE_SETUP.sql` for policy details
- Read comments explaining each policy

**Understand Screens:**
- `ReclamationsListScreen` - User view
- `AdminReclamationsScreen` - Admin view
- `ReclamationDetailScreen` - Detail view with admin features

**Understand Service:**
- `ReclamationService` - All API calls
- Methods for create, read, update, delete
- Methods for responses and history

---

## 📞 Support

**Need help?**
1. Check `RECLAMATION_FIX_GUIDE.md` for common issues
2. Check `RECLAMATION_MODULE_GUIDE.md` for features
3. Check `RECLAMATION_QUICK_START.md` for quick setup
4. Check Supabase logs for database errors

---

## ✅ Sign-Off

When all tests pass:
- [ ] Mark as "Ready for Production"
- [ ] Deploy to production
- [ ] Monitor for errors
- [ ] Gather user feedback

---

**Status:** 🔧 Implementation in Progress
**Completion:** Ready after SQL fix
**Test Coverage:** Comprehensive checklist above
