import '../repositories/lesson_repository.dart';

class DeleteLesson {
  final LessonRepository repository;

  DeleteLesson(this.repository);

  Future<void> call(String lessonId) {
    return repository.deleteLesson(lessonId);
  }
}
