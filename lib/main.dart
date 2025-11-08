import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env.dart';
import 'features/lesson/domain/usecases/get_lessons_by_module.dart';
import 'features/lesson/data/datasources/lesson_remote_data_source.dart';
import 'features/lesson/data/repositories/lesson_repository_impl.dart';
import 'features/formateur/data/datasources/formateur_remote_data_source.dart';
import 'features/formateur/data/repositories/formateur_repository_impl.dart';
import 'features/formateur/domain/usecases/get_all_formateurs.dart';
import 'features/formateur/domain/usecases/add_formateur.dart';
import 'features/formateur/presentation/bloc/formateur_bloc.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  final client = Supabase.instance.client;
  
  // Configuration pour les leçons
  final remoteDataSource = LessonRemoteDataSourceImpl(client);
  final repository = LessonRepositoryImpl(remoteDataSource);
  final getLessonsUseCase = GetLessonsByModule(repository);

  // ✅ Configuration pour les formateurs
  final formateurRemoteDataSource = FormateurRemoteDataSourceImpl(client);
  final formateurRepository = FormateurRepositoryImpl(formateurRemoteDataSource);
  final getAllFormateurs = GetAllFormateurs(formateurRepository);
  final addFormateur = AddFormateur(formateurRepository);
  
  final formateurBloc = FormateurBloc(
    getAllFormateurs: getAllFormateurs,
    addFormateur: addFormateur,
  );

  runApp(MyApp(
    getLessonsUseCase: getLessonsUseCase,
    formateurBloc: formateurBloc,
  ));
}

class MyApp extends StatelessWidget {
  final GetLessonsByModule getLessonsUseCase;
  final FormateurBloc formateurBloc;

  const MyApp({
    super.key, 
    required this.getLessonsUseCase,
    required this.formateurBloc,
  });

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
      initialRoute: '/',
      onGenerateRoute: (settings) =>
          AppRouter.generateRoute(settings, getLessonsUseCase),
    );
  }
}