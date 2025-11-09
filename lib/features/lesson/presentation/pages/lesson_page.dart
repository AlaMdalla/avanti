import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lesson_youtube_page.dart';
import 'lesson_pdf_page.dart';
import 'lesson_video_page.dart';
import 'package:e_learning_project/features/lesson/presentation/pages/lesson_form_page.dart';
import '../bloc/lesson_bloc.dart';
import '../bloc/lesson_event.dart';
import '../bloc/lesson_state.dart';

class LessonPage extends StatelessWidget {
  final String module_id;

  const LessonPage({
    super.key,
    required this.module_id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        title: const Text(
          "Leçons",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<LessonBloc, LessonState>(
        builder: (context, state) {
          if (state is LessonLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LessonLoaded) {
            final lessons = state.lessons;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.indigo[50],
                      child: Icon(_getLessonIcon(lesson.type), color: Colors.indigo),
                    ),
                    title: Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.description,
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                          if (lesson.duration != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              "Durée : ${formatDuration(lesson.duration!)}",
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            lesson.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () async {
                            final updated = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LessonFormPage(
                                  module_id: module_id,
                                  lesson: lesson,
                                ),
                              ),
                            );
                            if (updated == true) {
                              context.read<LessonBloc>().add(LoadLessons(module_id));
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteLesson(context, lesson.id),
                        ),
                      ],
                    ),
                    onTap: () => _openLesson(lesson.type, lesson.contentUrl, context),
                  ),
                );
              },
            );
          } else if (state is LessonError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LessonFormPage(module_id: module_id),
            ),
          );
          if (added == true && context.mounted) {
            context.read<LessonBloc>().add(LoadLessons(module_id));
          }
        },
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getLessonIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }

  void _openLesson(String type, String? url, BuildContext context) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pas de contenu disponible pour cette leçon")),
      );
      return;
    }
    // Ouvrir les vidéos YouTube et les PDFs dans l'application.
    final lower = url.toLowerCase();

    // Détecter YouTube
    final isYoutube = lower.contains('youtube.com') || lower.contains('youtu.be');
    // Détecter PDF - VÉRIFIER EN PREMIER pour les fichiers locaux
    final isPdf = lower.endsWith('.pdf') || lower.contains('application/pdf');
    // Détecter vidéo directe (mp4, mov, webm)
    final isVideoFile = lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.webm');

    try {
      if (isYoutube) {
        // Open in-app YouTube player
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonYoutubePage(videoUrl: url)),
        );
        return;
      }

      if (isPdf) {
        // Open in-app PDF viewer (réseau ou local)
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonPdfPage(pdfUrl: url)),
        );
        return;
      }

      if (isVideoFile) {
        print('🎬 [LESSON] Tentative d\'ouverture vidéo: $url');
        // Vérifier existence locale si ce n'est pas une URL réseau
        final isNetwork = url.startsWith('http://') || url.startsWith('https://');
        print('🌐 [LESSON] Est réseau: $isNetwork');
        
        if (!isNetwork) {
          final file = File(url);
          print('📁 [LESSON] Vérification fichier: ${file.path}');
          print('📁 [LESSON] Existe: ${file.existsSync()}');
          
          if (!file.existsSync()) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Fichier vidéo introuvable:\n$url'),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
            return;
          }
        }
        print('✅ [LESSON] Navigation vers LessonVideoPage');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LessonVideoPage(videoUrl: url)),
        );
        return;
      }

      // Fallback: try to open externally
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d’ouvrir ce contenu")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l’ouverture : $e')),
      );
    }
  }

  void _confirmDeleteLesson(BuildContext context, String lessonId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la leçon'),
        content: const Text('Voulez-vous vraiment supprimer cette leçon ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final client = Supabase.instance.client;
      await client.from('lessons').delete().eq('id', lessonId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🗑️ Leçon supprimée')),
      );
      context.read<LessonBloc>().add(LoadLessons(module_id));
    }
  }
}

String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final secs = twoDigits(duration.inSeconds.remainder(60));
  return duration.inHours > 0 ? "$hours:$minutes:$secs" : "$minutes:$secs";
}