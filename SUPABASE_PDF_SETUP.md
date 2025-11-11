# 🚀 Supabase Setup - PDF Integration for Courses

## Step 1️⃣: Update Your Database Schema

### Option A: Using SQL Editor (Recommended)

1. Go to **Supabase Dashboard** → Your Project
2. Click **SQL Editor** (left sidebar)
3. Click **New Query**
4. Copy and paste this SQL:

```sql
-- Add PDF URL column to courses table
ALTER TABLE courses ADD COLUMN pdf_url TEXT;

-- Add index for better query performance
CREATE INDEX idx_courses_pdf_url ON courses(pdf_url) WHERE pdf_url IS NOT NULL;

-- Optional: Add comment to document the column
COMMENT ON COLUMN courses.pdf_url IS 'URL to the course PDF content stored in Supabase storage bucket (course-pdfs)';
```

5. Click **Run** (or press Ctrl+Enter)

### Option B: Using Migrations (If you have Supabase CLI)

```bash
cd /home/noya/dev/avanti_mobile

# Create a new migration
supabase migration new add_pdf_url_to_courses

# Then copy the SQL from COURSES_PDF_MIGRATION.sql into the generated file
# And run:
supabase db push
```

---

## Step 2️⃣: Create the Storage Bucket

1. Go to **Supabase Dashboard** → **Storage** (left sidebar)
2. Click **Create a new bucket**
3. Name it: `course-pdfs`
4. Toggle **Public bucket** to ON
5. Click **Create bucket**

---

## Step 3️⃣: Add Row Level Security (RLS) Policies

In Supabase Dashboard, go to **Storage** → **course-pdfs** → **Policies**

### Policy 1: Allow authenticated users to upload

```sql
CREATE POLICY "Authenticated users can upload PDFs"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'course-pdfs' 
  AND auth.role() = 'authenticated'
);
```

**Or use the Dashboard:**
1. Click **New Policy**
2. Select **For INSERT**
3. In the "ROLES" section, select **authenticated**
4. In the "Using expression" box, paste:
   ```
   bucket_id = 'course-pdfs'
   ```

### Policy 2: Allow public read access

```sql
CREATE POLICY "Public can view PDFs"
ON storage.objects
FOR SELECT
USING (bucket_id = 'course-pdfs');
```

**Or use the Dashboard:**
1. Click **New Policy**
2. Select **For SELECT**
3. Leave "ROLES" as default (everyone)
4. In the "Using expression" box, paste:
   ```
   bucket_id = 'course-pdfs'
   ```

### Policy 3: Allow users to delete their own PDFs

```sql
CREATE POLICY "Users can delete own PDFs"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'course-pdfs' 
  AND auth.uid()::text = owner
);
```

**Or use the Dashboard:**
1. Click **New Policy**
2. Select **For DELETE**
3. Select **authenticated** role
4. In the "Using expression" box, paste:
   ```
   bucket_id = 'course-pdfs' AND auth.uid()::text = owner
   ```

---

## Step 4️⃣: Verify in Your App

1. Run your Flutter app:
   ```bash
   flutter run -d linux
   ```

2. Create a new course:
   - Go to **Create Course** screen
   - Fill in title, description, image
   - Click **Choose PDF** and select a PDF file
   - Click **Create**

3. Check if the course was created with PDF URL in Supabase:
   - Go to **SQL Editor**
   - Run:
     ```sql
     SELECT id, title, pdf_url FROM courses ORDER BY created_at DESC LIMIT 5;
     ```

---

## 🔍 Verification Checklist

✅ Database column added:
```sql
-- Check if pdf_url column exists
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'courses' AND column_name = 'pdf_url';
```

✅ Bucket created:
- Go to Storage and look for `course-pdfs` bucket

✅ RLS policies enabled:
- Go to Storage → course-pdfs → Policies
- Should see 3 policies listed

✅ Can upload PDF:
- Create a course with PDF in your app
- PDF should appear in Storage → course-pdfs

---

## 🐛 Troubleshooting

### Error: "Column pdf_url already exists"
**Solution:** The column is already there, skip Step 1

### Error: "Permission denied" when uploading PDF
**Solution:** Check RLS policies - make sure INSERT policy is enabled for authenticated users

### Error: "Bucket course-pdfs not found"
**Solution:** Create the bucket first (Step 2)

### PDF URL is NULL after creating course
**Solution:** 
1. Check if RLS policies allow uploads
2. Make sure you're logged in when creating course
3. Check Flutter logs for upload errors

---

## 📋 Database Schema After Update

```sql
-- Your courses table will now look like this:
CREATE TABLE courses (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  pdf_url TEXT,                    -- ← NEW COLUMN
  instructor_id UUID NOT NULL REFERENCES profiles(user_id),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🎯 What's Next?

After setup, you can:

1. **Display PDF in course detail screen:**
   ```dart
   if (course.pdfUrl != null)
     ElevatedButton.icon(
       onPressed: () => _viewPdf(course.pdfUrl!),
       icon: const Icon(Icons.picture_as_pdf),
       label: const Text('View PDF'),
     ),
   ```

2. **Open PDF in browser:**
   ```dart
   import 'package:url_launcher/url_launcher.dart';
   
   Future<void> _viewPdf(String pdfUrl) async {
     await launchUrl(Uri.parse(pdfUrl));
   }
   ```

3. **Add PDF viewer widget (optional):**
   - Use `pdfrx` or `pdfx` package for native PDF viewing

---

**🎉 Your Supabase setup is complete!**
