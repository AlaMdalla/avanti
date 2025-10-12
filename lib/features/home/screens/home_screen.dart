import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_widgets.dart';
import '../../profile/screens/profile_screen.dart';

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
                                Icons.person_outline,
                                color: AppColors.textOnPrimary,
                              ),
                              onPressed: () {
                                // Find the MainNavigation parent and switch to profile tab
                                final mainNavigationState = context.findAncestorStateOfType<State<StatefulWidget>>();
                                if (mainNavigationState != null && mainNavigationState.mounted) {
                                  // This is a simple way to switch tabs, in a real app you might use a more sophisticated state management
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Use the Profile tab at the bottom!')),
                                  );
                                }
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
            
            // Welcome Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: const [AppShadows.soft],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: const Icon(
                              Icons.waving_hand,
                              color: AppColors.textOnPrimary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome to Avanti!',
                                  style: AppTextStyles.h4,
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Your learning journey starts here',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                          title: 'Settings',
                          subtitle: 'App preferences',
                          icon: Icons.settings,
                          color: AppColors.primary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Settings coming soon!')),
                            );
                          },
                        ),
                        FeatureCard(
                          title: 'Help & Support',
                          subtitle: 'Get help and support',
                          icon: Icons.help_outline,
                          color: AppColors.secondary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Help & Support coming soon!')),
                            );
                          },
                        ),
                        FeatureCard(
                          title: 'Notifications',
                          subtitle: 'Manage notifications',
                          icon: Icons.notifications_outlined,
                          color: AppColors.success,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notifications coming soon!')),
                            );
                          },
                        ),
                        FeatureCard(
                          title: 'About',
                          subtitle: 'App information',
                          icon: Icons.info_outline,
                          color: AppColors.warning,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('About page coming soon!')),
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
