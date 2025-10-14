import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'features/lesson/domain/usecases/get_lessons_by_module.dart';
import 'features/lesson/data/datasources/lesson_remote_data_source.dart';
import 'features/lesson/data/repositories/lesson_repository_impl.dart';
import 'features/modules/presentation/pages/module_list_page.dart';
import 'features/lesson/presentation/pages/lesson_form_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // 🔐 Initialiser Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  // ⚙️ Préparer les dépendances pour le module Lesson
  final client = Supabase.instance.client;
  final remoteDataSource = LessonRemoteDataSourceImpl(client);
  final repository = LessonRepositoryImpl(remoteDataSource);
  final getLessonsUseCase = GetLessonsByModule(repository);

  runApp(MyApp(getLessonsUseCase: getLessonsUseCase));
}

class MyApp extends StatelessWidget {
  final GetLessonsByModule getLessonsUseCase;
  const MyApp({super.key, required this.getLessonsUseCase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "E-Learning Platform",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),

      // 🧭 Routes centralisées
      initialRoute: '/',
      routes: {
        '/': (context) => ModuleListPage(getLessonsUseCase: getLessonsUseCase),
        '/add-lesson': (context) => LessonFormPage(module_id: ''),
      },
    );
  }
}
