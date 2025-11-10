-- Create quiz_attempts and quiz_certifications tables (idempotent)

-- quiz_attempts stores a user's scored submission for a quiz
CREATE TABLE IF NOT EXISTS public.quiz_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  correct_count int NOT NULL,
  total int NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.quiz_attempts ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own attempts
DO $$ BEGIN
  CREATE POLICY quiz_attempts_select ON public.quiz_attempts
  FOR SELECT USING (auth.role() = 'authenticated' AND user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Allow users to insert their own attempts
DO $$ BEGIN
  CREATE POLICY quiz_attempts_insert ON public.quiz_attempts
  FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_quiz_attempts_quiz_user ON public.quiz_attempts(quiz_id, user_id);

-- quiz_certifications stores a single certification when a user passes the quiz threshold
CREATE TABLE IF NOT EXISTS public.quiz_certifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  awarded_at timestamptz NOT NULL DEFAULT now(),
  score_percent double precision,
  UNIQUE (quiz_id, user_id)
);

ALTER TABLE public.quiz_certifications ENABLE ROW LEVEL SECURITY;

-- Allow users to read their own certifications
DO $$ BEGIN
  CREATE POLICY quiz_certifications_select ON public.quiz_certifications
  FOR SELECT USING (auth.role() = 'authenticated' AND user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Allow users to insert their own certification rows
DO $$ BEGIN
  CREATE POLICY quiz_certifications_insert ON public.quiz_certifications
  FOR INSERT WITH CHECK (auth.role() = 'authenticated' AND user_id = auth.uid());
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_quiz_certifications_quiz_user ON public.quiz_certifications(quiz_id, user_id);
