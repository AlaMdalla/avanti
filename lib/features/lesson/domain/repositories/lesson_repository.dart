import '../entities/lesson.dart';

abstract class LessonRepository {
  Future<List<Lesson>> getLessonsByModule(String module_id);
  Future<Lesson?> getLessonById(String lessonId);
  Future<void> addLesson(Lesson lesson);
  Future<void> updateLesson(Lesson lesson);
  Future<void> deleteLesson(String lessonId);
}