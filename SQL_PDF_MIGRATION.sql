-- Add PDF support to courses table
-- Run this in Supabase SQL Editor

-- 1. Add pdf_url column to courses table
ALTER TABLE courses ADD COLUMN pdf_url TEXT;

-- 2. Create storage bucket policies for course-pdfs
-- These policies control who can upload, view, and delete PDFs

-- Policy: Allow authenticated users to upload PDFs
CREATE POLICY "Authenticated users can upload course PDFs"
ON storage.objects
FOR INSERT
WITH CHECK (bucket_id = 'course-pdfs' AND auth.role() = 'authenticated');

-- Policy: Allow public read access to PDFs
CREATE POLICY "Public can view course PDFs"
ON storage.objects
FOR SELECT
USING (bucket_id = 'course-pdfs');

-- Policy: Allow users to delete their own PDFs
CREATE POLICY "Users can delete own course PDFs"
ON storage.objects
FOR DELETE
USING (bucket_id = 'course-pdfs' AND auth.uid()::text = owner);

-- Verify the column was added
-- Run this query to check:
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'courses';
