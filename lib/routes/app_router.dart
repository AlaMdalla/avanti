import 'package:flutter/material.dart';
import '../features/modules/presentation/pages/module_list_page.dart';
import '../features/lesson/presentation/pages/lesson_form_page.dart';
import '../features/lesson/domain/usecases/get_lessons_by_module.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
      RouteSettings settings, GetLessonsByModule getLessonsUseCase) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => ModuleListPage(getLessonsUseCase: getLessonsUseCase),
        );

      case '/add-lesson':
        final module_id = settings.arguments as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => LessonFormPage(module_id: module_id),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('❌ Page non trouvée')),
          ),
        );
    }
  }
}
