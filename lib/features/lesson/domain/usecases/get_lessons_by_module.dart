import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

class GetLessonsByModule {
  final LessonRepository repository;

  GetLessonsByModule(this.repository);

  Future<List<Lesson>> call(String moduleId) async {
    return await repository.getLessonsByModule(moduleId);
  }
}
