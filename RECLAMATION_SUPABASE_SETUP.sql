-- ============================================================================
-- RECLAMATION MODULE - SUPABASE SQL SETUP
-- ============================================================================
-- Copy and paste this entire block into Supabase SQL Editor
-- ============================================================================

-- ============================================================================
-- 1. CREATE RECLAMATIONS TABLE
-- ============================================================================
CREATE TABLE IF NOT EXISTS reclamations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  course_id UUID REFERENCES courses(id) ON DELETE SET NULL,
  module_id UUID REFERENCES modules(id) ON DELETE SET NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL, -- 'course_issue', 'content_issue', 'technical', 'other'
  status TEXT NOT NULL DEFAULT 'open', -- 'open', 'in_progress', 'resolved', 'closed'
  priority TEXT NOT NULL DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
  rating_before INTEGER, -- Rating/satisfaction before issue
  rating_after INTEGER, -- Rating/satisfaction after resolution
  attachment_url TEXT, -- URL to attachment if uploaded
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- Add comments
COMMENT ON TABLE reclamations IS 'User complaints and reclamations about courses/modules';
COMMENT ON COLUMN reclamations.user_id IS 'User who filed the reclamation';
COMMENT ON COLUMN reclamations.course_id IS 'Related course (optional)';
COMMENT ON COLUMN reclamations.module_id IS 'Related module (optional)';
COMMENT ON COLUMN reclamations.category IS 'Type of issue: course_issue, content_issue, technical, other';
COMMENT ON COLUMN reclamations.status IS 'Status: open, in_progress, resolved, closed';
COMMENT ON COLUMN reclamations.priority IS 'Priority level: low, medium, high, urgent';

-- ============================================================================
-- 2. CREATE RECLAMATION_RESPONSES TABLE (for admin/support replies)
-- ============================================================================
CREATE TABLE IF NOT EXISTS reclamation_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reclamation_id UUID NOT NULL REFERENCES reclamations(id) ON DELETE CASCADE,
  responder_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  response_text TEXT NOT NULL,
  is_admin_response BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE reclamation_responses IS 'Responses from admins/support staff to reclamations';
COMMENT ON COLUMN reclamation_responses.responder_id IS 'Admin or support staff who responded';
COMMENT ON COLUMN reclamation_responses.is_admin_response IS 'True if response is from admin/support';

-- ============================================================================
-- 3. CREATE RECLAMATION_HISTORY TABLE (for tracking changes)
-- ============================================================================
CREATE TABLE IF NOT EXISTS reclamation_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reclamation_id UUID NOT NULL REFERENCES reclamations(id) ON DELETE CASCADE,
  changed_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  field_name TEXT NOT NULL, -- 'status', 'priority', 'assigned_to', etc.
  old_value TEXT,
  new_value TEXT,
  change_reason TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add comments
COMMENT ON TABLE reclamation_history IS 'Audit log for reclamation status changes';
COMMENT ON COLUMN reclamation_history.changed_by IS 'User who made the change';

-- ============================================================================
-- 4. CREATE INDEXES FOR PERFORMANCE
-- ============================================================================
CREATE INDEX idx_reclamations_user ON reclamations(user_id);
CREATE INDEX idx_reclamations_course ON reclamations(course_id);
CREATE INDEX idx_reclamations_module ON reclamations(module_id);
CREATE INDEX idx_reclamations_status ON reclamations(status);
CREATE INDEX idx_reclamations_priority ON reclamations(priority);
CREATE INDEX idx_reclamations_created_at ON reclamations(created_at DESC);
CREATE INDEX idx_reclamation_responses_reclamation ON reclamation_responses(reclamation_id);
CREATE INDEX idx_reclamation_history_reclamation ON reclamation_history(reclamation_id);

-- ============================================================================
-- 5. ENABLE ROW LEVEL SECURITY (RLS)
-- ============================================================================
ALTER TABLE reclamations ENABLE ROW LEVEL SECURITY;
ALTER TABLE reclamation_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE reclamation_history ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- 6. CREATE RLS POLICIES
-- ============================================================================

-- Reclamations: Users can see their own, admins can see all
CREATE POLICY "Users can view their own reclamations" ON reclamations
  FOR SELECT
  USING (
    auth.uid() = user_id OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Users can create their own reclamations" ON reclamations
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own open reclamations" ON reclamations
  FOR UPDATE
  USING (
    (auth.uid() = user_id AND status = 'open') OR
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Reclamation Responses: Users can view replies to their reclamations
CREATE POLICY "Users can view responses to their reclamations" ON reclamation_responses
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM reclamations
      WHERE reclamations.id = reclamation_responses.reclamation_id
      AND (
        reclamations.user_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM profiles
          WHERE profiles.id = auth.uid()
          AND profiles.role = 'admin'
        )
      )
    )
  );

CREATE POLICY "Only admins can create responses" ON reclamation_responses
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Reclamation History: Users can view their own history, admins can view all
CREATE POLICY "Users can view history of their reclamations" ON reclamation_history
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM reclamations
      WHERE reclamations.id = reclamation_history.reclamation_id
      AND (
        reclamations.user_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM profiles
          WHERE profiles.id = auth.uid()
          AND profiles.role = 'admin'
        )
      )
    )
  );

-- ============================================================================
-- 7. CREATE HELPER FUNCTIONS
-- ============================================================================

-- Function to get reclamation count by status
CREATE OR REPLACE FUNCTION get_reclamation_counts()
RETURNS TABLE(status TEXT, count BIGINT) AS $$
  SELECT status, COUNT(*) as count
  FROM reclamations
  GROUP BY status;
$$ LANGUAGE SQL STABLE;

-- Function to get user's reclamation count
CREATE OR REPLACE FUNCTION get_user_reclamation_count(p_user_id UUID)
RETURNS BIGINT AS $$
  SELECT COUNT(*)
  FROM reclamations
  WHERE user_id = p_user_id;
$$ LANGUAGE SQL STABLE;

-- Function to get open reclamations count
CREATE OR REPLACE FUNCTION get_open_reclamations_count()
RETURNS BIGINT AS $$
  SELECT COUNT(*)
  FROM reclamations
  WHERE status != 'closed';
$$ LANGUAGE SQL STABLE;

-- Function to update reclamation status
CREATE OR REPLACE FUNCTION update_reclamation_status(
  p_reclamation_id UUID,
  p_new_status TEXT,
  p_changed_by UUID,
  p_change_reason TEXT DEFAULT NULL
)
RETURNS VOID AS $$
DECLARE
  v_old_status TEXT;
BEGIN
  -- Get old status
  SELECT status INTO v_old_status
  FROM reclamations
  WHERE id = p_reclamation_id;

  -- Update status
  UPDATE reclamations
  SET status = p_new_status,
      updated_at = NOW(),
      resolved_at = CASE WHEN p_new_status = 'resolved' THEN NOW() ELSE resolved_at END
  WHERE id = p_reclamation_id;

  -- Log the change
  INSERT INTO reclamation_history (
    reclamation_id,
    changed_by,
    field_name,
    old_value,
    new_value,
    change_reason
  ) VALUES (
    p_reclamation_id,
    p_changed_by,
    'status',
    v_old_status,
    p_new_status,
    p_change_reason
  );
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 8. INSERT SAMPLE DATA (Optional)
-- ============================================================================
-- Uncomment if you want to test with sample data

-- INSERT INTO reclamations (
--   user_id,
--   title,
--   description,
--   category,
--   status,
--   priority
-- ) VALUES (
--   (SELECT id FROM auth.users LIMIT 1),
--   'Course content is outdated',
--   'The Python module has outdated examples that do not work with the latest version',
--   'content_issue',
--   'open',
--   'medium'
-- )
-- ON CONFLICT DO NOTHING;

-- ============================================================================
-- 9. VERIFICATION QUERIES
-- ============================================================================
-- Run these to verify setup:
SELECT 'Reclamation tables created successfully!' as status;
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('reclamations', 'reclamation_responses', 'reclamation_history')
ORDER BY table_name;
