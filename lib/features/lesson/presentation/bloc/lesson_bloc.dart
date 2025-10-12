import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_lessons_by_module.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final GetLessonsByModule getLessonsByModule;

  LessonBloc(this.getLessonsByModule) : super(LessonInitial()) {
    on<LoadLessons>((event, emit) async {
      emit(LessonLoading());
      try {
        final lessons = await getLessonsByModule(event.module_id);
        emit(LessonLoaded(lessons));
      } catch (_) {
        emit(LessonError("Erreur lors du chargement des leçons."));
      }
    });
  }
}
