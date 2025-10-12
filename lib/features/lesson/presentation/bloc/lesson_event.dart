abstract class LessonEvent {}

class LoadLessons extends LessonEvent {
  final String module_id;
  LoadLessons(this.module_id);
}
