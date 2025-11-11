# 🚀 FIX: 404 Error When Uploading PDFs - Complete Solution

## ❌ Problem
You're getting a 404 error when trying to upload PDFs, which means:
1. The `course-pdfs` bucket doesn't exist, OR
2. RLS policies aren't configured, OR
3. The database column is missing

## ✅ Solution (Step by Step)

---

## 🔧 STEP 1: Create the Storage Bucket (MANUAL in Dashboard)

This MUST be done manually in the Supabase UI:

1. **Go to:** https://app.supabase.com/
2. **Select your project**
3. **Click** Storage (left sidebar)
4. **Click** "Create a new bucket"
5. **Name:** `course-pdfs` (exactly this)
6. **Toggle** "Public bucket" to **ON** (green)
7. **Click** "Create bucket"

✅ You should now see `course-pdfs` in your bucket list

---

## 🗄️ STEP 2: Run SQL to Add Database Column & Policies

1. **Go to:** Supabase Dashboard → **SQL Editor**
2. **Click** "New Query"
3. **Copy the entire content** from: `SUPABASE_PDF_COMPLETE_SETUP.sql`
4. **Paste it** into the SQL editor
5. **Click** "Run" button (or Ctrl+Enter)

✅ All tables, columns, and policies will be created

---

## 🔐 STEP 3: Verify Setup

After running the SQL, verify everything:

### Check 1: Database Column
In SQL Editor, run:
```sql
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'courses' AND column_name = 'pdf_url';
```

**Expected result:** One row with `pdf_url`

### Check 2: RLS Enabled
Run:
```sql
SELECT schemaname, tablename, rowsecurity FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';
```

**Expected result:** `rowsecurity = true`

### Check 3: Policies Created
Run:
```sql
SELECT policyname FROM pg_policies 
WHERE tablename = 'objects' 
ORDER BY policyname;
```

**Expected result:** Should see policies like:
- `course-pdfs: authenticated upload`
- `course-pdfs: public read`
- `course-pdfs: owner delete`
- `course-pdfs: owner update`

---

## 📱 STEP 4: Test in Your App

1. **Make sure you're logged in** (required for authenticated uploads)
2. **Go to** Create Course screen
3. **Fill in:**
   - Title
   - Description
   - Image (optional)
   - **PDF Content** ← Click "Choose PDF"
4. **Select a PDF file**
5. **Click** Create/Save

✅ PDF should upload successfully!

---

## 🐛 If Still Getting 404 Error

### Troubleshooting Checklist:

**❌ Error: "Bucket not found"**
- [ ] Go to Storage → Verify `course-pdfs` bucket exists
- [ ] Make sure bucket name is exactly `course-pdfs` (lowercase, no spaces)
- [ ] Make sure "Public bucket" toggle is ON

**❌ Error: "Permission denied"**
- [ ] Verify you're logged in when uploading
- [ ] Check RLS policies exist (Step 3 Check 3)
- [ ] Make sure INSERT policy is for `bucket_id = 'course-pdfs'`

**❌ Error: "Column pdf_url does not exist"**
- [ ] Run SQL from Step 2 again
- [ ] Verify column was created (Step 3 Check 1)

**❌ Error: "auth.uid() is null"**
- [ ] This means you're not authenticated
- [ ] Make sure user is logged in before creating course
- [ ] Check Supabase auth is working

---

## 📊 What Gets Created

### Database
```sql
courses table
├── id (UUID)
├── title (TEXT)
├── description (TEXT)
├── image_url (TEXT)
├── pdf_url (TEXT) ← ADDED
├── instructor_id (UUID)
├── created_at (TIMESTAMP)
└── updated_at (TIMESTAMP)
```

### Storage
```
course-pdfs/ (bucket)
└── course-pdfs/
    └── uploads/
        └── [user_id]_[timestamp].pdf
```

### RLS Policies
```
storage.objects table
├── course-pdfs: authenticated upload (INSERT)
├── course-pdfs: public read (SELECT)
├── course-pdfs: owner delete (DELETE)
└── course-pdfs: owner update (UPDATE)
```

---

## 🎯 Quick Reference

| Component | Location | Action |
|-----------|----------|--------|
| Create bucket | Supabase UI → Storage | Manual ✋ |
| Add column | Supabase → SQL Editor | Run SQL ✅ |
| Add policies | Supabase → SQL Editor | Run SQL ✅ |
| Test upload | Flutter App | Create Course with PDF |

---

## 📝 Expected Flow After Setup

```
User creates course with PDF
    ↓
PDF file picked locally
    ↓
Upload to: https://[project].supabase.co/storage/v1/object/public/course-pdfs/[path]
    ↓
RLS policy checks: bucket_id = 'course-pdfs' AND auth.role() = 'authenticated'
    ↓
✅ File uploaded successfully
    ↓
Public URL saved to courses.pdf_url
    ↓
Course created with PDF link
```

---

## 🚨 Important Notes

1. **The bucket MUST be public** - Toggle must be ON in Storage UI
2. **RLS must be enabled** - Run the SQL commands
3. **You must be logged in** - PDF upload requires authentication
4. **PDF path:** `course-pdfs/uploads/[userId]_[timestamp].pdf`

---

## ✨ After Everything Works

Once you can upload PDFs, you can:

1. **Display PDF button** in course details:
   ```dart
   if (course.pdfUrl != null)
     ElevatedButton.icon(
       onPressed: () => launch(course.pdfUrl!),
       icon: const Icon(Icons.picture_as_pdf),
       label: const Text('Download PDF'),
     )
   ```

2. **View PDF in app** using `pdfrx` package

3. **Share PDF URL** directly with students

---

**Follow these steps and your PDF upload will work! 🎉**
