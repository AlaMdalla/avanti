import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class AddLesson {
  final LessonRepository repository;

  AddLesson(this.repository);

  Future<void> call(Lesson lesson) {
    return repository.addLesson(lesson);
  }
}
