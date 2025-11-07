-- Update policies to authorize via courses.instructor_id instead of quizzes.instructor_id

-- quiz_questions
DO $$ BEGIN
  DROP POLICY IF EXISTS quiz_questions_modify ON public.quiz_questions;
EXCEPTION WHEN undefined_object THEN NULL; END $$;

CREATE POLICY quiz_questions_modify ON public.quiz_questions
FOR ALL USING (
  EXISTS (
    SELECT 1
    FROM public.quizzes q
    JOIN public.courses c ON c.id = q.course_id
    WHERE q.id = quiz_questions.quiz_id
      AND c.instructor_id = auth.uid()
  )
) WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.quizzes q
    JOIN public.courses c ON c.id = q.course_id
    WHERE q.id = quiz_questions.quiz_id
      AND c.instructor_id = auth.uid()
  )
);

-- quiz_options
DO $$ BEGIN
  DROP POLICY IF EXISTS quiz_options_modify ON public.quiz_options;
EXCEPTION WHEN undefined_object THEN NULL; END $$;

CREATE POLICY quiz_options_modify ON public.quiz_options
FOR ALL USING (
  EXISTS (
    SELECT 1
    FROM public.quiz_questions qq
    JOIN public.quizzes q ON q.id = qq.quiz_id
    JOIN public.courses c ON c.id = q.course_id
    WHERE qq.id = quiz_options.question_id
      AND c.instructor_id = auth.uid()
  )
) WITH CHECK (
  EXISTS (
    SELECT 1
    FROM public.quiz_questions qq
    JOIN public.quizzes q ON q.id = qq.quiz_id
    JOIN public.courses c ON c.id = q.course_id
    WHERE qq.id = quiz_options.question_id
      AND c.instructor_id = auth.uid()
  )
);
