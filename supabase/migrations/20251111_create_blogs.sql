-- Migration: Create blogs table
-- Created: 2025-11-11
-- Purpose: Store user blog posts with images from avatars bucket

-- Create blogs table
CREATE TABLE IF NOT EXISTS blogs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for user_id to speed up user's blog queries
CREATE INDEX IF NOT EXISTS blogs_user_id_idx ON blogs(user_id);

-- Create index for published blogs (for public view)
CREATE INDEX IF NOT EXISTS blogs_published_idx ON blogs(published) WHERE published = true;

-- Create index for sorting by created_at
CREATE INDEX IF NOT EXISTS blogs_created_at_idx ON blogs(created_at DESC);

-- Enable RLS on blogs table
ALTER TABLE blogs ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can see their own blogs (published or not)
CREATE POLICY "Users can see their own blogs" ON blogs
  FOR SELECT
  USING (auth.uid() = user_id);

-- RLS Policy: Users can see published blogs from other users
CREATE POLICY "Users can see published blogs" ON blogs
  FOR SELECT
  USING (published = true OR auth.uid() = user_id);

-- RLS Policy: Users can insert their own blogs
CREATE POLICY "Users can create their own blogs" ON blogs
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS Policy: Users can update their own blogs
CREATE POLICY "Users can update their own blogs" ON blogs
  FOR UPDATE
  USING (auth.uid() = user_id);

-- RLS Policy: Users can delete their own blogs
CREATE POLICY "Users can delete their own blogs" ON blogs
  FOR DELETE
  USING (auth.uid() = user_id);

-- Admins can see and manage all blogs
CREATE POLICY "Admins can see all blogs" ON blogs
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can update any blog" ON blogs
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

CREATE POLICY "Admins can delete any blog" ON blogs
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = auth.uid()
      AND profiles.role = 'admin'
    )
  );

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_blogs_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to call the function
CREATE TRIGGER blogs_update_updated_at
BEFORE UPDATE ON blogs
FOR EACH ROW
EXECUTE FUNCTION update_blogs_updated_at();

-- Helper function: Get user's blogs with author info
CREATE OR REPLACE FUNCTION get_user_blogs(p_user_id UUID)
RETURNS TABLE(
  id UUID,
  user_id UUID,
  title TEXT,
  content TEXT,
  image_url TEXT,
  published BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  author_pseudo TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    b.id,
    b.user_id,
    b.title,
    b.content,
    b.image_url,
    b.published,
    b.created_at,
    b.updated_at,
    p.pseudo
  FROM blogs b
  LEFT JOIN profiles p ON b.user_id = p.user_id
  WHERE b.user_id = p_user_id
  ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- Helper function: Get published blogs (for public feed)
CREATE OR REPLACE FUNCTION get_published_blogs()
RETURNS TABLE(
  id UUID,
  user_id UUID,
  title TEXT,
  content TEXT,
  image_url TEXT,
  published BOOLEAN,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  author_pseudo TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    b.id,
    b.user_id,
    b.title,
    b.content,
    b.image_url,
    b.published,
    b.created_at,
    b.updated_at,
    p.pseudo
  FROM blogs b
  LEFT JOIN profiles p ON b.user_id = p.user_id
  WHERE b.published = true
  ORDER BY b.created_at DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- Helper function: Get blog count for a user
CREATE OR REPLACE FUNCTION get_user_blog_count(p_user_id UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER FROM blogs WHERE user_id = p_user_id;
$$ LANGUAGE SQL STABLE;

-- Helper function: Get published blog count
CREATE OR REPLACE FUNCTION get_published_blog_count()
RETURNS INTEGER AS $$
  SELECT COUNT(*)::INTEGER FROM blogs WHERE published = true;
$$ LANGUAGE SQL STABLE;
