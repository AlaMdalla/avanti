-- Add PDF URL column to courses table
-- Run this in Supabase SQL Editor

ALTER TABLE courses ADD COLUMN pdf_url TEXT;

-- Add index for better query performance
CREATE INDEX idx_courses_pdf_url ON courses(pdf_url) WHERE pdf_url IS NOT NULL;

-- Optional: Add comment to document the column
COMMENT ON COLUMN courses.pdf_url IS 'URL to the course PDF content stored in Supabase storage bucket (course-pdfs)';
