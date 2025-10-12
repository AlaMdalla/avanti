import '../../domain/entities/lesson.dart';

abstract class LessonState {}

class LessonInitial extends LessonState {}

class LessonLoading extends LessonState {}

class LessonLoaded extends LessonState {
  final List<Lesson> lessons;
  LessonLoaded(this.lessons);
}

class LessonError extends LessonState {
  final String message;
  LessonError(this.message);
}
