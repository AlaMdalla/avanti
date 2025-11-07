import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avanti_mobile/features/home/screens/home_screen.dart';
import 'package:avanti_mobile/features/quiz/screens/quiz_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://fqhffadnewyrdacmliyk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxaGZmYWRuZXd5cmRhY21saXlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIzMzA2MjEsImV4cCI6MjA3NzkwNjYyMX0.SWAg2HoPo_W5MVwcmW5RAW_ze46CA-Loup4DtlEb95s',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avanti Learning',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const HomeScreen(),
      routes: {
        '/quiz': (context) => const QuizScreen(
              courseId: '',
              courseTitle: 'Quiz',
            ),
      },
    );
  }
}
