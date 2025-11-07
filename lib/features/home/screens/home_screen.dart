import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_widgets.dart';
import 'package:avanti_mobile/features/quiz/screens/quiz_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // 🔹 Déconnexion utilisateur
  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 🔹 Récupération des cours depuis Supabase
  Future<List<dynamic>> _fetchCourses() async {
    final response = await Supabase.instance.client
        .from('courses')
        .select()
        .order('created_at', ascending: false);
    return response;
  }

  // 🔹 Test connexion Supabase
  Future<void> _testConnection(BuildContext context) async {
    try {
      final response = await Supabase.instance.client.from('courses').select();

      if (response.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Connexion OK, mais la table est vide.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Connexion réussie : ${response[0]['title']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur connexion Supabase : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.email?.split('@').first ?? 'Student';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 🔹 En-tête avec nom utilisateur
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textOnPrimary.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              userName,
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: AppColors.textOnPrimary,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Notifications coming soon!')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout,
                                color: AppColors.textOnPrimary,
                              ),
                              onPressed: () => _signOut(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // 🔹 Barre de recherche
                    CustomSearchBar(
                      hintText: 'Search courses, topics...',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Search feature coming soon!')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 Progression utilisateur
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Progress', style: AppTextStyles.h4),
                    const SizedBox(height: AppSpacing.md),
                    ProgressCard(
                      title: 'Weekly Learning Goal',
                      subtitle: '4 of 7 days completed this week',
                      progress: 0.57,
                      progressText: '57%',
                      icon: Icons.emoji_events,
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 Cours (depuis Supabase)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Continue Learning', style: AppTextStyles.h4),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    FutureBuilder<List<dynamic>>(
                      future: _fetchCourses(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text('Erreur : ${snapshot.error}');
                        }
                        final courses = snapshot.data ?? [];
                        if (courses.isEmpty) {
                          return const Text('Aucun cours disponible.');
                        }

                        return SizedBox(
                          height: 240,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
                              return SizedBox(
                                width: 200,
                                child: CourseCard(
                                  title: course['title'] ?? 'Sans titre',
                                  instructor: course['instructor'] ?? 'Inconnu',
                                  duration: course['duration'] ?? '',
                                  progress: (course['progress'] ?? 0.0).toDouble(),
                                  imageUrl: course['image_url'] ?? '',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizScreen(
                                          courseId: course['id'],
                                          courseTitle: course['title'],
                                        ),
                                      ),
                                    );
                                  },

                                  isFeatured: index == 0,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 Bouton test de connexion Supabase
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: ElevatedButton.icon(
                  onPressed: () => _testConnection(context),
                  icon: const Icon(Icons.cloud_done),
                  label: const Text('Tester la connexion Supabase'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }
}
