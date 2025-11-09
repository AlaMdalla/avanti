// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:e_learning_project/main.dart';
import 'package:e_learning_project/features/lesson/domain/usecases/get_lessons_by_module.dart';
import 'package:e_learning_project/features/lesson/domain/repositories/lesson_repository.dart';
import 'package:e_learning_project/features/lesson/domain/entities/lesson.dart';

class _FakeLessonRepository implements LessonRepository {
  @override
  Future<void> addLesson(lesson) async {}

  @override
  Future<void> deleteLesson(String lessonId) async {}

  @override
  Future<Lesson?> getLessonById(String lessonId) async => null;

  @override
  Future<List<Lesson>> getLessonsByModule(String module_id) async => [];

  @override
  Future<void> updateLesson(lesson) async {}
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
  final getLessonsUseCase = GetLessonsByModule(_FakeLessonRepository());
  await tester.pumpWidget(MyApp(getLessonsUseCase: getLessonsUseCase));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
