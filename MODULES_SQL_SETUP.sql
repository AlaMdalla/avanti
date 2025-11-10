-- ============================================================================
-- SUPABASE SQL SETUP FOR MODULES
-- ============================================================================
-- Copy and paste these SQL commands into your Supabase SQL Editor
-- This creates the modules table and the module_courses junction table
-- ============================================================================

-- ============================================================================
-- 1. CREATE MODULES TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS modules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  "order" INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE modules IS 'Course modules that contain multiple courses';
COMMENT ON COLUMN modules.title IS 'Module title/name';
COMMENT ON COLUMN modules.description IS 'Optional module description';
COMMENT ON COLUMN modules.course_id IS 'Reference to the parent course';
COMMENT ON COLUMN modules."order" IS 'Order/sequence of modules within a course';

-- Create indexes
CREATE INDEX idx_modules_course_id ON modules(course_id);
CREATE INDEX idx_modules_order ON modules("order");

-- ============================================================================
-- 2. CREATE MODULE_COURSES JUNCTION TABLE
-- ============================================================================
-- This table creates a many-to-many relationship between modules and courses
CREATE TABLE IF NOT EXISTS module_courses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id UUID NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(module_id, course_id)
);

-- Add comments
COMMENT ON TABLE module_courses IS 'Junction table for many-to-many relationship between modules and courses';
COMMENT ON COLUMN module_courses.module_id IS 'Reference to the module';
COMMENT ON COLUMN module_courses.course_id IS 'Reference to the course in the module';

-- Create indexes
CREATE INDEX idx_module_courses_module_id ON module_courses(module_id);
CREATE INDEX idx_module_courses_course_id ON module_courses(course_id);

-- ============================================================================
-- 3. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================

ALTER TABLE modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE module_courses ENABLE ROW LEVEL SECURITY;

-- Modules: Instructors can manage their course modules, anyone can read
CREATE POLICY "Anyone can read modules" ON modules
  FOR SELECT
  USING (true);

CREATE POLICY "Instructors can insert modules for their courses" ON modules
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = course_id
      AND c.instructor_id = auth.uid()
    )
  );

CREATE POLICY "Instructors can update their modules" ON modules
  FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = course_id
      AND c.instructor_id = auth.uid()
    )
  );

CREATE POLICY "Instructors can delete their modules" ON modules
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = course_id
      AND c.instructor_id = auth.uid()
    )
  );

-- Module Courses: Instructors can manage their module courses
CREATE POLICY "Anyone can read module courses" ON module_courses
  FOR SELECT
  USING (true);

CREATE POLICY "Instructors can insert module courses" ON module_courses
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM modules m
      JOIN courses c ON m.course_id = c.id
      WHERE m.id = module_id
      AND c.instructor_id = auth.uid()
    )
  );

CREATE POLICY "Instructors can delete module courses" ON module_courses
  FOR DELETE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM modules m
      JOIN courses c ON m.course_id = c.id
      WHERE m.id = module_id
      AND c.instructor_id = auth.uid()
    )
  );

-- ============================================================================
-- 4. SAMPLE DATA (Optional)
-- ============================================================================
-- Insert sample modules (adjust course_id to match your actual courses)
-- Replace 'YOUR_COURSE_ID' with an actual UUID from your courses table

-- Example:
-- INSERT INTO modules (title, description, course_id, "order")
-- VALUES 
--   ('Module 1: Basics', 'Introduction to the course basics', 'YOUR_COURSE_ID', 1),
--   ('Module 2: Intermediate', 'Building on the basics', 'YOUR_COURSE_ID', 2),
--   ('Module 3: Advanced', 'Advanced topics and practice', 'YOUR_COURSE_ID', 3);

-- ============================================================================
-- 5. USEFUL QUERIES
-- ============================================================================

-- Get all modules for a course with their courses
-- SELECT 
--   m.*,
--   json_agg(
--     json_build_object(
--       'id', c.id,
--       'title', c.title,
--       'description', c.description,
--       'instructor_id', c.instructor_id
--     )
--   ) as courses
-- FROM modules m
-- LEFT JOIN module_courses mc ON m.id = mc.module_id
-- LEFT JOIN courses c ON mc.course_id = c.id
-- GROUP BY m.id;

-- Get modules by course ID
-- SELECT m.* FROM modules m WHERE m.course_id = 'YOUR_COURSE_ID' ORDER BY m."order";

-- Get courses in a specific module
-- SELECT c.* FROM courses c
-- JOIN module_courses mc ON c.id = mc.course_id
-- WHERE mc.module_id = 'YOUR_MODULE_ID';
