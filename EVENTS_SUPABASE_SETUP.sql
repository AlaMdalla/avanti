-- Create events table
CREATE TABLE events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  event_date TIMESTAMPTZ NOT NULL,
  location TEXT,
  image_url TEXT,
  category_id uuid,
  created_by uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  max_attendees INTEGER,
  current_attendees INTEGER DEFAULT 0,
  is_online BOOLEAN DEFAULT FALSE,
  event_link TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create event_attendees table for registration
CREATE TABLE event_attendees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  registered_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(event_id, user_id)
);

-- Create indexes for better performance
CREATE INDEX idx_events_event_date ON events(event_date);
CREATE INDEX idx_events_created_by ON events(created_by);
CREATE INDEX idx_events_is_online ON events(is_online);
CREATE INDEX idx_event_attendees_event_id ON event_attendees(event_id);
CREATE INDEX idx_event_attendees_user_id ON event_attendees(user_id);

-- Enable RLS (Row Level Security)
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_attendees ENABLE ROW LEVEL SECURITY;

-- RLS Policies for events table
-- Anyone can view events
CREATE POLICY "Allow public read access to events"
  ON events
  FOR SELECT
  USING (true);

-- Users can create events
CREATE POLICY "Users can create events"
  ON events
  FOR INSERT
  WITH CHECK (auth.uid() = created_by);

-- Users can update their own events
CREATE POLICY "Users can update their own events"
  ON events
  FOR UPDATE
  USING (auth.uid() = created_by)
  WITH CHECK (auth.uid() = created_by);

-- Users can delete their own events
CREATE POLICY "Users can delete their own events"
  ON events
  FOR DELETE
  USING (auth.uid() = created_by);

-- RLS Policies for event_attendees table
-- Users can view attendees of events
CREATE POLICY "Allow public read access to event_attendees"
  ON event_attendees
  FOR SELECT
  USING (true);

-- Users can register themselves
CREATE POLICY "Users can register for events"
  ON event_attendees
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can unregister themselves
CREATE POLICY "Users can unregister from events"
  ON event_attendees
  FOR DELETE
  USING (auth.uid() = user_id);
