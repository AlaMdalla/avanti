# 🚀 RECLAMATION MODULE - QUICK START

## 1️⃣ SUPABASE SETUP (5 minutes)

### Step 1: Open Supabase SQL Editor
- Go to https://supabase.com/dashboard
- Select your project
- Click **SQL Editor** → **New Query**

### Step 2: Copy & Paste SQL
Open this file: `RECLAMATION_SUPABASE_SETUP.sql`

Copy ALL content and paste into SQL Editor.

Click **Run** ✓

### Step 3: Verify
Paste this to verify:
```sql
SELECT COUNT(*) as table_count FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('reclamations', 'reclamation_responses', 'reclamation_history');
```

Should return: **3 tables created**

---

## 2️⃣ FLUTTER ALREADY DONE ✓

✅ Models created: `lib/features/reclamation/models/reclamation.dart`
✅ Service created: `lib/features/reclamation/services/reclamation_service.dart`
✅ Screens created:
   - `reclamations_list_screen.dart` - View all reclamations
   - `create_reclamation_screen.dart` - Create new reclamation
   - `reclamation_detail_screen.dart` - View details & responses
✅ Navigation integrated - "Reclamations" in sidebar

---

## 3️⃣ TEST IT

1. Run app: `flutter run`
2. Click **Reclamations** in sidebar
3. Click **+** to create new reclamation
4. Fill form and submit
5. See it in list with status badge
6. Click to view details

---

## 📊 WHAT YOU CAN DO

### Users Can:
- Create new reclamations
- View all their reclamations
- Filter by status
- Add responses/comments
- Track issue resolution
- Rate satisfaction (before/after)

### Admins Can:
- View all reclamations
- Update status
- Add official responses
- Track resolution history
- View statistics

---

## 🎯 KEY FEATURES

✨ **Statuses**: Open → In Progress → Resolved → Closed
⚡ **Priorities**: Low, Medium, High, Urgent
🏷️ **Categories**: Course Issue, Content Issue, Technical, Other
🔐 **Secure**: RLS policies prevent data leaks
📱 **Responsive**: Works on all screen sizes
🎨 **Themed**: Uses AppColors & AppTextStyles

---

## 📁 FILES

**Database:**
- `RECLAMATION_SUPABASE_SETUP.sql` - All SQL needed

**Frontend:**
- `lib/features/reclamation/models/reclamation.dart`
- `lib/features/reclamation/services/reclamation_service.dart`
- `lib/features/reclamation/screens/reclamations_list_screen.dart`
- `lib/features/reclamation/screens/create_reclamation_screen.dart`
- `lib/features/reclamation/screens/reclamation_detail_screen.dart`

**Documentation:**
- `RECLAMATION_MODULE_GUIDE.md` - Full guide (this file)
- `RECLAMATION_SUPABASE_SETUP.sql` - Copy to SQL Editor

---

## ⚡ QUICK REFERENCE

**Create Reclamation:**
```dart
await reclamationService.createReclamation(
  title: 'Course is broken',
  description: 'Videos not playing',
  category: 'technical',
  priority: 'high',
  courseId: 'course-123',
);
```

**Get User Reclamations:**
```dart
final reclamations = await reclamationService.getUserReclamations();
```

**Add Response:**
```dart
await reclamationService.addResponse(
  reclamationId: 'rec-123',
  responseText: 'We fixed this in v2.1',
);
```

**Update Status:**
```dart
await reclamationService.updateReclamationStatus(
  reclamationId: 'rec-123',
  newStatus: 'resolved',
  changeReason: 'Fixed in latest update',
);
```

---

## 🎨 COLORS & ICONS

**Statuses:**
- Open: 🔵 Blue
- In Progress: 🟡 Amber
- Resolved: 🟢 Green
- Closed: ⚪ Gray

**Priorities:**
- Low: 🟢 Green
- Medium: 🟡 Amber
- High: 🔴 Red
- Urgent: 🟣 Purple

**Categories:**
- Course Issue: 📚 Icon
- Content Issue: 📄 Icon
- Technical: 🐛 Icon
- Other: ⋯ Icon

---

## ✅ NEXT STEPS

1. ✅ Run SQL in Supabase (STEP 1️⃣ above)
2. ✅ Run `flutter run`
3. ✅ Test creating a reclamation
4. ✅ Check navigation sidebar
5. 🔄 Admin dashboard integration (optional)

---

## 🆘 TROUBLESHOOTING

**Q: Reclamations screen shows error**
A: Make sure you ran the SQL in Supabase first

**Q: Can't create reclamation**
A: Check if user is authenticated. Must be logged in.

**Q: Responses not showing**
A: Check RLS policies - make sure you're the owner of the reclamation

**Q: Need to add file upload?**
A: Use Supabase Storage with `attachment_url` field

---

## 📞 SUPPORT

Check these files for more info:
- `RECLAMATION_MODULE_GUIDE.md` - Full documentation
- `RECLAMATION_SUPABASE_SETUP.sql` - Database setup
- Code comments in service & models

---

**✨ Your reclamation module is ready!**
