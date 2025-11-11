-- ========================================
-- COMPLETE SUPABASE SETUP FOR PDF STORAGE
-- ========================================
-- Run each section in your Supabase SQL Editor
-- Copy-paste each query and click RUN

-- ========================================
-- SECTION 1: Add PDF Column to Courses Table
-- ========================================
-- Run this first to add the column to your courses table

ALTER TABLE courses ADD COLUMN IF NOT EXISTS pdf_url TEXT;

-- Create index for performance
CREATE INDEX IF NOT EXISTS idx_courses_pdf_url ON courses(pdf_url) WHERE pdf_url IS NOT NULL;


-- ========================================
-- SECTION 2: Verify Bucket Exists
-- ========================================
-- This is informational - check if bucket exists in Storage UI
-- Go to: Supabase Dashboard → Storage
-- Look for a bucket named "course-pdfs"
-- If it doesn't exist, you must create it manually in the UI:
-- 1. Click "Create a new bucket"
-- 2. Name: course-pdfs
-- 3. Toggle "Public bucket" to ON
-- 4. Click "Create bucket"


-- ========================================
-- SECTION 3: Enable RLS for storage.objects
-- ========================================
-- First, enable Row Level Security on the storage.objects table

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;


-- ========================================
-- SECTION 4: Create RLS Policies for course-pdfs bucket
-- ========================================
-- These policies control who can upload, view, and delete PDFs

-- Policy 1: Allow authenticated users to upload PDFs
DROP POLICY IF EXISTS "course-pdfs: authenticated upload" ON storage.objects;
CREATE POLICY "course-pdfs: authenticated upload"
ON storage.objects
FOR INSERT
WITH CHECK (
  bucket_id = 'course-pdfs'
  AND auth.role() = 'authenticated'
);

-- Policy 2: Allow public read access (everyone can view)
DROP POLICY IF EXISTS "course-pdfs: public read" ON storage.objects;
CREATE POLICY "course-pdfs: public read"
ON storage.objects
FOR SELECT
USING (bucket_id = 'course-pdfs');

-- Policy 3: Allow users to delete their own files
DROP POLICY IF EXISTS "course-pdfs: owner delete" ON storage.objects;
CREATE POLICY "course-pdfs: owner delete"
ON storage.objects
FOR DELETE
USING (
  bucket_id = 'course-pdfs'
  AND auth.uid()::text = owner
);

-- Policy 4: Allow authenticated users to update their files
DROP POLICY IF EXISTS "course-pdfs: owner update" ON storage.objects;
CREATE POLICY "course-pdfs: owner update"
ON storage.objects
FOR UPDATE
USING (
  bucket_id = 'course-pdfs'
  AND auth.uid()::text = owner
);


-- ========================================
-- SECTION 5: Verification Queries
-- ========================================
-- Run these to verify everything is set up correctly

-- Check if pdf_url column exists
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'courses' AND column_name = 'pdf_url';

-- Check if RLS is enabled on storage.objects
SELECT schemaname, tablename, rowsecurity FROM pg_tables 
WHERE tablename = 'objects' AND schemaname = 'storage';

-- Check all policies on storage.objects
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  qual AS policy_condition
FROM pg_policies 
WHERE tablename = 'objects' 
ORDER BY policyname;
