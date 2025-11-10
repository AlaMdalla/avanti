import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/custom_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  
  // Settings state variables
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _analyticsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';

  @override
  Widget build(BuildContext context) {
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
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textOnPrimary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        Text(
                          'Settings',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Settings icon
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.textOnPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.circular),
                      ),
                      child: const Icon(
                        Icons.settings,
                        color: AppColors.textOnPrimary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Customize your experience',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textOnPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Notifications Settings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notifications',
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
                          _buildSwitchSetting(
                            'Enable Notifications',
                            'Receive app notifications',
                            Icons.notifications,
                            _notificationsEnabled,
                            (value) => setState(() => _notificationsEnabled = value),
                          ),
                          const Divider(height: 1),
                          _buildSwitchSetting(
                            'Push Notifications',
                            'Receive push notifications on device',
                            Icons.phone_android,
                            _pushNotifications,
                            (value) => setState(() => _pushNotifications = value),
                            enabled: _notificationsEnabled,
                          ),
                          const Divider(height: 1),
                          _buildSwitchSetting(
                            'Email Notifications',
                            'Receive notifications via email',
                            Icons.email,
                            _emailNotifications,
                            (value) => setState(() => _emailNotifications = value),
                            enabled: _notificationsEnabled,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Appearance Settings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Appearance',
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
                          _buildSelectionSetting(
                            'Theme',
                            'Choose your preferred theme',
                            Icons.palette,
                            _selectedTheme,
                            ['System', 'Light', 'Dark'],
                            (value) => setState(() => _selectedTheme = value),
                          ),
                          const Divider(height: 1),
                          _buildSelectionSetting(
                            'Language',
                            'Select your preferred language',
                            Icons.language,
                            _selectedLanguage,
                            ['English', 'Spanish', 'French', 'German', 'Arabic'],
                            (value) => setState(() => _selectedLanguage = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Security Settings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security & Privacy',
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
                          _buildActionSetting(
                            'Change Password',
                            'Update your account password',
                            Icons.lock,
                            () => _showChangePasswordDialog(),
                          ),
                          const Divider(height: 1),
                          _buildSwitchSetting(
                            'Biometric Authentication',
                            'Use fingerprint or face unlock',
                            Icons.fingerprint,
                            _biometricEnabled,
                            (value) => setState(() => _biometricEnabled = value),
                          ),
                          const Divider(height: 1),
                          _buildActionSetting(
                            'Two-Factor Authentication',
                            'Add extra security to your account',
                            Icons.security,
                            () => _showTwoFactorDialog(),
                          ),
                          const Divider(height: 1),
                          _buildSwitchSetting(
                            'Analytics & Crash Reporting',
                            'Help improve the app',
                            Icons.analytics,
                            _analyticsEnabled,
                            (value) => setState(() => _analyticsEnabled = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Account Management
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Management',
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
                          _buildActionSetting(
                            'Export Data',
                            'Download your account data',
                            Icons.download,
                            () => _showExportDataDialog(),
                          ),
                          const Divider(height: 1),
                          _buildActionSetting(
                            'Delete Account',
                            'Permanently delete your account',
                            Icons.delete_forever,
                            () => _showDeleteAccountDialog(),
                            isDestructive: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // App Information
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
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
                          _buildInfoSetting('App Version', '1.0.0', Icons.info),
                          const Divider(height: 1),
                          _buildActionSetting(
                            'Terms of Service',
                            'Read our terms and conditions',
                            Icons.description,
                            () => _showTermsDialog(),
                          ),
                          const Divider(height: 1),
                          _buildActionSetting(
                            'Privacy Policy',
                            'Learn about our privacy practices',
                            Icons.privacy_tip,
                            () => _showPrivacyDialog(),
                          ),
                          const Divider(height: 1),
                          _buildActionSetting(
                            'Contact Support',
                            'Get help and support',
                            Icons.support_agent,
                            () => _showSupportDialog(),
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

  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: enabled ? AppColors.primary : AppColors.textTertiary,
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
                    color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionSetting(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
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
                      color: isDestructive ? AppColors.error : AppColors.textPrimary,
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

  Widget _buildSelectionSetting(
    String title,
    String subtitle,
    IconData icon,
    String currentValue,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return InkWell(
      onTap: () => _showSelectionDialog(title, options, currentValue, onChanged),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
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
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$subtitle: $currentValue',
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

  Widget _buildInfoSetting(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.labelLarge,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Dialog Methods
  void _showSelectionDialog(
    String title,
    List<String> options,
    String currentValue,
    ValueChanged<String> onChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) => RadioListTile<String>(
            title: Text(option),
            value: option,
            groupValue: currentValue,
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
                Navigator.pop(context);
              }
            },
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password feature coming soon!')),
    );
  }

  void _showTwoFactorDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Two-factor authentication coming soon!')),
    );
  }

  void _showExportDataDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data export feature coming soon!')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service coming soon!')),
    );
  }

  void _showPrivacyDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy coming soon!')),
    );
  }

  void _showSupportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact Support coming soon!')),
    );
  }
}
