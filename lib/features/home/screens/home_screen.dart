import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.email?.split('@').first ?? 'Student';
    
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
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
                    
                    // Search Bar
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
            
            // Progress Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: AppTextStyles.h4,
                    ),
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
            
            // Categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          CategoryChip(
                            label: 'All',
                            isSelected: true,
                            onTap: () {},
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          CategoryChip(
                            label: 'Programming',
                            isSelected: false,
                            onTap: () {},
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          CategoryChip(
                            label: 'Design',
                            isSelected: false,
                            onTap: () {},
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          CategoryChip(
                            label: 'Business',
                            isSelected: false,
                            onTap: () {},
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          CategoryChip(
                            label: 'Marketing',
                            isSelected: false,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Continue Learning
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Continue Learning',
                          style: AppTextStyles.h4,
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('View all courses coming soon!')),
                            );
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 240,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: 200,
                            child: CourseCard(
                              title: 'Flutter Development Basics',
                              instructor: 'John Doe',
                              duration: '4h 30m',
                              progress: 0.65,
                              imageUrl: '',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Course details coming soon!')),
                                );
                              },
                              isFeatured: true,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          SizedBox(
                            width: 200,
                            child: CourseCard(
                              title: 'UI/UX Design Principles',
                              instructor: 'Jane Smith',
                              duration: '3h 15m',
                              progress: 0.30,
                              imageUrl: '',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Course details coming soon!')),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          SizedBox(
                            width: 200,
                            child: CourseCard(
                              title: 'JavaScript Fundamentals',
                              instructor: 'Mike Johnson',
                              duration: '5h 45m',
                              progress: 0.15,
                              imageUrl: '',
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Course details coming soon!')),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.2,
                      children: [
                        FeatureCard(
                          title: 'My Courses',
                          subtitle: 'View all enrolled courses',
                          icon: Icons.school,
                          color: AppColors.primary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('My Courses coming soon!')),
                            );
                          },
                        ),
                        FeatureCard(
                          title: 'Certificates',
                          subtitle: 'View earned certificates',
                          icon: Icons.workspace_premium,
                          color: AppColors.secondary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Certificates coming soon!')),
                            );
                          },
                        ),
                        FeatureCard(
                          title: 'Study Plan',
                          subtitle: 'Organize your learning',
                          icon: Icons.schedule,
                          color: AppColors.success,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Study Plan coming soon!')),
                            );
                          },
                        ),
                        FeatureCard(
                          title: 'Community',
                          subtitle: 'Connect with learners',
                          icon: Icons.people,
                          color: AppColors.warning,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Community coming soon!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xl),
            ),
          ],
        ),
      ),
    );
  }


}
