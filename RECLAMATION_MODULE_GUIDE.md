# 📋 Reclamation Module - Complete Setup Guide

## 🎯 Overview

The Reclamation Module allows users to file complaints and issues about courses/modules, and track their resolution status. Admins can manage, respond to, and resolve reclamations.

---

## 📊 Database Schema

### Tables Created:

#### 1. **reclamations** - Main reclamation records
```sql
- id (UUID) - Primary key
- user_id (UUID) - User who filed
- course_id (UUID) - Related course (optional)
- module_id (UUID) - Related module (optional)
- title (TEXT) - Issue title
- description (TEXT) - Detailed issue description
- category (TEXT) - Type: course_issue, content_issue, technical, other
- status (TEXT) - open, in_progress, resolved, closed
- priority (TEXT) - low, medium, high, urgent
- rating_before (INT) - Satisfaction before issue
- rating_after (INT) - Satisfaction after resolution
- attachment_url (TEXT) - File attachment URL
- created_at, updated_at, resolved_at (TIMESTAMPS)
```

#### 2. **reclamation_responses** - Admin/support responses
```sql
- id (UUID) - Primary key
- reclamation_id (UUID) - FK to reclamations
- responder_id (UUID) - Admin/support staff
- response_text (TEXT) - Reply message
- is_admin_response (BOOLEAN) - True if from admin
- created_at, updated_at (TIMESTAMPS)
```

#### 3. **reclamation_history** - Audit log
```sql
- id (UUID) - Primary key
- reclamation_id (UUID) - FK to reclamations
- changed_by (UUID) - Who made the change
- field_name (TEXT) - Which field changed (status, priority, etc.)
- old_value, new_value (TEXT) - Before/after values
- change_reason (TEXT) - Why the change
- created_at (TIMESTAMP)
```

---

## 🔐 Security (Row Level Security)

✅ **Implemented:**
- Users can only view their own reclamations
- Users can only create/edit their own reclamations while open
- Users can view responses to their reclamations
- Admins can view all reclamations
- Only admins can create responses

---

## 📱 Frontend Features

### 1. **ReclamationsListScreen**
- List all user reclamations
- Filter by status (all, open, resolved, closed)
- Quick actions (create new, refresh)
- Reclamation cards with status/priority indicators

### 2. **CreateReclamationScreen**
- Form to file new reclamation
- Category selection (dropdown)
- Priority level selection
- Optional satisfaction rating before issue
- Form validation

### 3. **ReclamationDetailScreen**
- Full reclamation details
- View all responses
- Add new responses (continue conversation)
- Show resolution timeline
- Display ratings if available

---

## 🗂️ File Structure

```
lib/features/reclamation/
├── models/
│   └── reclamation.dart              # Enums & Models
├── services/
│   └── reclamation_service.dart      # API calls
└── screens/
    ├── reclamations_list_screen.dart # List view
    ├── create_reclamation_screen.dart # Create form
    └── reclamation_detail_screen.dart # Detail view
```

---

## 🚀 Setup Steps

### Step 1: Add SQL to Supabase

1. Go to: https://supabase.com/dashboard
2. Select your project
3. **SQL Editor** → **New Query**
4. Copy entire content from: `RECLAMATION_SUPABASE_SETUP.sql`
5. Paste and click **Run**

✅ This creates:
- 3 tables (reclamations, responses, history)
- Indexes for performance
- RLS policies for security
- Helper functions for stats

### Step 2: Already Done ✓

The Flutter code is already integrated:
- ✅ Models (reclamation.dart)
- ✅ Service (reclamation_service.dart)
- ✅ Screens (3 screens)
- ✅ Navigation added

---

## 📋 Categories

- **Course Issue** - Problem with course structure/content
- **Content Issue** - Outdated or incorrect material
- **Technical** - Technical difficulties (access, playback, etc.)
- **Other** - Any other issue

---

## ⚡ Priorities

- **Low** - Minor inconvenience (green)
- **Medium** - Regular issue (amber)
- **High** - Major impact (red)
- **Urgent** - Blocking issue (purple)

---

## 📊 Statuses

- **Open** - Newly filed, awaiting review (blue)
- **In Progress** - Being investigated (amber)
- **Resolved** - Issue resolved (green)
- **Closed** - Completed, no more action needed (gray)

---

## 🔧 Helper Functions

```sql
-- Get count of reclamations by status
SELECT * FROM get_reclamation_counts();

-- Get user's total reclamations
SELECT get_user_reclamation_count(user_id);

-- Get all open reclamations
SELECT get_open_reclamations_count();

-- Update status with history
SELECT update_reclamation_status(
  reclamation_id,
  'resolved',
  admin_id,
  'Issue was fixed in latest patch'
);
```

---

## 📱 Usage

### For Users:
1. Go to **Reclamations** in sidebar
2. Click **+** to create new reclamation
3. Fill form with issue details
4. Submit
5. Track progress via status
6. View support responses in detail view

### For Admins:
1. Admin Dashboard shows statistics
2. Can filter by status/priority
3. Can add responses to reclamations
4. Can update status (triggers history log)
5. Can close reclamations

---

## 🧪 Testing

### Verification SQL:
```sql
-- Check tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('reclamations', 'reclamation_responses', 'reclamation_history');

-- Check indexes
SELECT * FROM pg_indexes 
WHERE tablename IN ('reclamations', 'reclamation_responses', 'reclamation_history');

-- Test RLS
SELECT COUNT(*) FROM reclamations; -- Should respect RLS
```

---

## 🎨 Design Elements

**Colors:**
- Status: Blue (open), Amber (in progress), Green (resolved), Gray (closed)
- Priority: Green (low), Amber (medium), Red (high), Purple (urgent)

**Typography:**
- Uses AppTextStyles from design system
- Consistent with app theme
- Icons from Material Design

---

## 🔄 Data Flow

```
User submits reclamation
    ↓
Creates entry in reclamations table
    ↓
Shows in ReclamationsListScreen
    ↓
User opens detail view
    ↓
Can view existing responses
    ↓
Admin responds (in reclamation_responses)
    ↓
Admin updates status → triggers history log
    ↓
Resolution complete
```

---

## ❓ FAQ

**Q: Can users edit their reclamation after submitting?**
A: Only if status is 'open'. Once in progress, only admins can modify.

**Q: Are attachments supported?**
A: Schema supports attachment_url field. File upload implementation can be added later.

**Q: How are ratings used?**
A: Users can rate their satisfaction before and after resolution, showing impact.

**Q: Is there admin dashboard?**
A: Yes, admin dashboard can show reclamation statistics and allow bulk actions.

---

## 📞 Support

For issues or questions:
1. Check the models (reclamation.dart) for data structure
2. Review service (reclamation_service.dart) for available methods
3. Check SQL functions in RECLAMATION_SUPABASE_SETUP.sql

---

## ✅ Checklist

- [x] SQL schema created
- [x] RLS policies set up
- [x] Models implemented
- [x] Service layer created
- [x] Screens implemented
- [x] Navigation integrated
- [ ] Run SQL in Supabase
- [ ] Test create reclamation
- [ ] Test view reclamations
- [ ] Test add response
- [ ] Admin dashboard integration (next)

---

**Status:** ✅ Ready for use after SQL setup
