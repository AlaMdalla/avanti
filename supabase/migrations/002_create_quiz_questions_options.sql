-- Migration: create quiz_questions and quiz_options tables
-- Assumes existing quizzes table with id uuid and instructor_id uuid

CREATE TABLE IF NOT EXISTS public.quiz_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id uuid NOT NULL REFERENCES public.quizzes(id) ON DELETE CASCADE,
  text text NOT NULL,
  "order" int NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS public.quiz_options (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id uuid NOT NULL REFERENCES public.quiz_questions(id) ON DELETE CASCADE,
  text text NOT NULL,
  is_correct boolean NOT NULL DEFAULT false
);

-- Enable RLS
ALTER TABLE public.quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz_options ENABLE ROW LEVEL SECURITY;

-- Policies: read for authenticated users
CREATE POLICY quiz_questions_select ON public.quiz_questions FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY quiz_options_select ON public.quiz_options FOR SELECT USING (auth.role() = 'authenticated');

-- Write policies: only quiz instructor (join quizzes)
CREATE POLICY quiz_questions_modify ON public.quiz_questions FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.quizzes q
    WHERE q.id = quiz_questions.quiz_id AND q.instructor_id = auth.uid()
  )
) WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.quizzes q
    WHERE q.id = quiz_questions.quiz_id AND q.instructor_id = auth.uid()
  )
);

CREATE POLICY quiz_options_modify ON public.quiz_options FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.quiz_questions qq
    JOIN public.quizzes q ON q.id = qq.quiz_id
    WHERE qq.id = quiz_options.question_id AND q.instructor_id = auth.uid()
  )
) WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.quiz_questions qq
    JOIN public.quizzes q ON q.id = qq.quiz_id
    WHERE qq.id = quiz_options.question_id AND q.instructor_id = auth.uid()
  )
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz_id ON public.quiz_questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_options_question_id ON public.quiz_options(question_id);
