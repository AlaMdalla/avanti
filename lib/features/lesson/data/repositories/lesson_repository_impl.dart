import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_remote_data_source.dart';

class LessonRepositoryImpl implements LessonRepository {
  final LessonRemoteDataSource remoteDataSource;

  LessonRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Lesson>> getLessonsByModule(String module_id) {
    return remoteDataSource.fetchLessons(module_id);
  }

  @override
  Future<Lesson?> getLessonById(String lessonId) async {
    final lessons = await remoteDataSource.fetchLessons('module1');
    try {
      return lessons.firstWhere((l) => l.id == lessonId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addLesson(Lesson lesson) async {
    print('Ajout de la leçon : ${lesson.title}');
  }

  @override
  Future<void> updateLesson(Lesson lesson) async {
    print('Mise à jour de la leçon : ${lesson.id}');
  }

  @override
  Future<void> deleteLesson(String lessonId) async {
    print('Suppression de la leçon : $lessonId');
  }
}
