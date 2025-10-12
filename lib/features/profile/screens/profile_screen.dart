import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;

  Future<void> _signOut(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed out successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = user?.email?.split('@').first ?? 'Student';
    final userInitials = userName.substring(0, 2).toUpperCase();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar with Profile Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  children: [
                    // Title and Edit Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Profile',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.textOnPrimary,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit profile coming soon!')),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Profile Avatar and Info
                    Column(
                      children: [
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.circular),
                            border: Border.all(
                              color: AppColors.textOnPrimary,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              userInitials,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textOnPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        
                        // User Name
                        Text(
                          userName,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        
                        // User Email
                        Text(
                          user?.email ?? 'No email',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        
                        // User Status
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textOnPrimary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.circular),
                          ),
                          child: Text(
                            'Premium Student',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Statistics Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Learning Statistics',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Statistics Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard(
                          'Courses Completed',
                          '12',
                          Icons.school,
                          AppColors.success,
                        ),
                        _buildStatCard(
                          'Total Study Time',
                          '84h',
                          Icons.access_time,
                          AppColors.secondary,
                        ),
                        _buildStatCard(
                          'Certificates Earned',
                          '8',
                          Icons.workspace_premium,
                          AppColors.warning,
                        ),
                        _buildStatCard(
                          'Current Streak',
                          '15 days',
                          Icons.local_fire_department,
                          AppColors.error,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Progress Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Progress',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    ProgressCard(
                      title: 'Monthly Learning Goal',
                      subtitle: '18 of 25 hours completed this month',
                      progress: 0.72,
                      progressText: '72%',
                      icon: Icons.trending_up,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    ProgressCard(
                      title: 'Course Completion Rate',
                      subtitle: '8 out of 10 courses completed',
                      progress: 0.80,
                      progressText: '80%',
                      icon: Icons.check_circle,
                    ),
                  ],
                ),
              ),
            ),
            
            // Settings Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings & Preferences',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Settings List
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            'Notifications',
                            'Manage your notification preferences',
                            Icons.notifications_outlined,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Notifications settings coming soon!')),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildSettingsItem(
                            'Privacy & Security',
                            'Manage your account security',
                            Icons.security,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Privacy settings coming soon!')),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildSettingsItem(
                            'Learning Preferences',
                            'Customize your learning experience',
                            Icons.tune,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Learning preferences coming soon!')),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildSettingsItem(
                            'Download Settings',
                            'Manage offline content',
                            Icons.download,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Download settings coming soon!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Account Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: const [AppShadows.soft],
                      ),
                      child: Column(
                        children: [
                          _buildSettingsItem(
                            'Help & Support',
                            'Get help and contact support',
                            Icons.help_outline,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Help & Support coming soon!')),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildSettingsItem(
                            'About Avanti',
                            'App version and information',
                            Icons.info_outline,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('About page coming soon!')),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildSettingsItem(
                            'Sign Out',
                            'Sign out of your account',
                            Icons.logout,
                            () => _signOut(context),
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: const [AppShadows.soft],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDestructive 
                    ? AppColors.error.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: isDestructive ? AppColors.error : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDestructive ? AppColors.error : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
