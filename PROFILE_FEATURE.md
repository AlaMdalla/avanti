## Profile Feature

### Quiz Certification
Users earn a quiz certification automatically when they score 70% or higher on a quiz.

Behavior:
- On submission, the app computes the score percentage.
- If >= 70%, it inserts a row into `quiz_certifications (quiz_id, user_id, awarded_at, score_percent)` if one doesn't already exist.
- The result screen shows a premium badge and message.

Surfacing in Profile:
- Query `quiz_certifications` for the current user to list earned certifications.
- Join with `quizzes` to display quiz titles.
