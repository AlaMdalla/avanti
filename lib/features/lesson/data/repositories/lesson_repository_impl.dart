import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_remote_data_source.dart';

class LessonRepositoryImpl implements LessonRepository {
  final LessonRemoteDataSource remoteDataSource;

  LessonRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Lesson>> getLessonsByModule(String moduleId) {
    return remoteDataSource.fetchLessons(moduleId);
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
    await remoteDataSource.addLesson(lesson);
  }

  @override
  Future<void> deleteLesson(String lessonId) {
    return remoteDataSource.deleteLesson(lessonId);
  }

  @override
  Future<void> updateLesson(Lesson lesson) async {
    await remoteDataSource.updateLesson(lesson);
  }
}