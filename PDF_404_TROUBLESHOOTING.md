# 🎯 PDF Upload 404 Error - Troubleshooting Guide

## The Problem Flow

```
User clicks "Create" on course form with PDF
    ↓
PDF upload starts
    ↓
❌ 404 Error - "Bucket not found"
    ↓
Upload fails
```

## Root Causes & Solutions

### Cause 1️⃣: Bucket Doesn't Exist (Most Common)

```
❌ GET https://[project].supabase.co/storage/v1/object/public/course-pdfs/...
❌ 404 Not Found - Bucket "course-pdfs" does not exist
```

**Fix:**
1. Go to Supabase Dashboard → **Storage**
2. Click **"Create a new bucket"**
3. Enter name: `course-pdfs`
4. Toggle **"Public bucket"** to **ON** (green)
5. Click **"Create bucket"**
6. ✅ Bucket now exists

---

### Cause 2️⃣: RLS Policies Not Set

```
❌ POST https://[project].supabase.co/storage/v1/object/course-pdfs/...
❌ 401 Unauthorized - Missing RLS policy for INSERT
```

**Fix:**
1. Go to **Supabase Dashboard** → **SQL Editor**
2. Copy SQL from: `SUPABASE_PDF_COMPLETE_SETUP.sql`
3. Run the entire script
4. ✅ RLS policies now enabled

---

### Cause 3️⃣: Database Column Missing

```
Error when saving course: column "pdf_url" does not exist
```

**Fix:**
1. Go to **Supabase Dashboard** → **SQL Editor**
2. Run:
   ```sql
   ALTER TABLE courses ADD COLUMN IF NOT EXISTS pdf_url TEXT;
   ```
3. ✅ Column added

---

### Cause 4️⃣: Not Authenticated

```
❌ 403 Forbidden - auth.uid() is NULL
```

**Fix:**
1. Make sure you're **logged in** before creating course
2. Check that Supabase auth is working in your app
3. Verify user is displayed in navbar/profile

---

## Verification Checklist

Run these commands in Supabase SQL Editor to verify:

### ✅ Check 1: Bucket Exists
In Storage UI, you should see `course-pdfs` listed.

**Or in SQL:**
```sql
SELECT * FROM storage.buckets WHERE name = 'course-pdfs';
```
Expected: 1 row with `public = true`

### ✅ Check 2: Database Column Exists
```sql
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'courses' AND column_name = 'pdf_url';
```
Expected: 1 row with `pdf_url`

### ✅ Check 3: RLS Enabled
```sql
SELECT rowsecurity FROM pg_tables 
WHERE schemaname = 'storage' AND tablename = 'objects';
```
Expected: `true`

### ✅ Check 4: Policies Exist
```sql
SELECT policyname, qual FROM pg_policies 
WHERE tablename = 'objects' AND policyname LIKE 'course-pdfs%';
```
Expected: 4 rows with:
- `course-pdfs: authenticated upload`
- `course-pdfs: public read`
- `course-pdfs: owner delete`
- `course-pdfs: owner update`

---

## Quick Fix Steps (In Order)

1. **Create bucket manually** (UI)
   - Storage → Create a new bucket → `course-pdfs` → Public ON

2. **Run SQL setup** (SQL Editor)
   - Copy `SUPABASE_PDF_COMPLETE_SETUP.sql` → Run

3. **Verify setup** (Run check commands above)

4. **Test in app**
   - Create course with PDF
   - Should work now! ✅

---

## Error Messages & Fixes

### "Failed to upload PDF: 404 Not Found"
```
Fix: Create course-pdfs bucket (Step 1 above)
```

### "Failed to upload PDF: 401 Unauthorized"
```
Fix: Make sure you're logged in
Or: Run RLS setup SQL (Step 2 above)
```

### "Failed to upload PDF: 403 Permission denied"
```
Fix: Run RLS setup SQL (Step 2 above)
```

### "Failed to upload PDF: Bucket not found"
```
Fix: Create course-pdfs bucket (Step 1 above)
```

### "column pdf_url does not exist"
```
Fix: Run SQL: ALTER TABLE courses ADD COLUMN pdf_url TEXT;
```

---

## After Fixing

Once everything works, you'll see:

✅ PDF uploads successfully
✅ PDF URL saved to database
✅ Course created with PDF link
✅ You can download/view the PDF later

---

## Prevention Checklist

- [ ] Bucket exists and is PUBLIC
- [ ] RLS policies are enabled
- [ ] User is authenticated before uploading
- [ ] PDF file is under 50MB
- [ ] PDF file extension is .pdf
- [ ] Database column exists
- [ ] Using correct bucket name: `course-pdfs`

---

## Still Not Working?

Check these in order:

1. **Browser Console** → Any errors?
2. **Flutter Logs** → Look for detailed error messages
3. **Supabase Logs** → Go to Logs in dashboard
4. **Network Tab** → See actual HTTP error
5. **RLS Policies** → Make sure all 4 policies exist

---

**Most Common Fix: Create the bucket with PUBLIC toggle ON!** 🎯
