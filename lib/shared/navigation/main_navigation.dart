import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/EditProfile_screen.dart';
import '../../features/profile/screens/UserListScreen.dart'; // Import UserListScreen
import '../../features/messages/screens/chat_screen.dart'; // Import ChatScreen
import '../../features/course/screens/course_list_screen.dart';
import '../../features/course/screens/modules_list_screen.dart'; // Import ModulesListScreen
import '../../features/reclamation/screens/reclamations_list_screen.dart'; // Import ReclamationsListScreen
import '../../features/reclamation/screens/admin_reclamations_screen.dart'; // Import AdminReclamationsScreen
import '../../features/blog/screens/blog_list_screen.dart'; // Import BlogListScreen
import '../../features/events/screens/event_list_screen.dart'; // Import EventListScreen
import '../../features/admin/screens/admin_dashboard_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/profile/services/profile_service.dart';
import '../../features/profile/models/profile.dart';
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final _profileService = ProfileService();
  Profile? _profile;

  List<Widget> get _screens => [
        const HomeScreen(),
        const CourseListScreen(),
        const ModulesListScreen(),
        _isAdmin ? const AdminReclamationsScreen() : const ReclamationsListScreen(),
        if (_isAdmin) const AdminDashboardScreen(),
        const EventListScreen(),
        const BlogListScreen(),
        const ProfileScreen(),
        const EditProfileScreen(),
        UserListScreen(),
      ];

  bool get _isAdmin => _profile?.role == ProfileRole.admin;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    final p = await _profileService.getProfile(user.id);
    if (!mounted) return;
    setState(() => _profile = p);
  }

  @override
  Widget build(BuildContext context) {
    final navigationItems = [
      _NavigationItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        index: 0,
      ),
      _NavigationItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: 'Courses',
        index: 1,
      ),
      _NavigationItem(
        icon: Icons.library_books_outlined,
        activeIcon: Icons.library_books,
        label: 'Modules',
        index: 2,
      ),
      _NavigationItem(
        icon: Icons.speaker_notes_outlined,
        activeIcon: Icons.speaker_notes,
        label: 'Reclamations',
        index: 3,
      ),
      if (_isAdmin)
        _NavigationItem(
          icon: Icons.admin_panel_settings_outlined,
          activeIcon: Icons.admin_panel_settings,
          label: 'Admin',
          index: 4,
        ),
      _NavigationItem(
        icon: Icons.event_outlined,
        activeIcon: Icons.event,
        label: 'Events',
        index: _isAdmin ? 5 : 4,
      ),
      _NavigationItem(
        icon: Icons.article_outlined,
        activeIcon: Icons.article,
        label: 'My Blogs',
        index: _isAdmin ? 6 : 5,
      ),
      _NavigationItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        index: _isAdmin ? 7 : 6,
      ),
      _NavigationItem(
        icon: Icons.edit_outlined,
        activeIcon: Icons.edit,
        label: 'Edit Profile',
        index: _isAdmin ? 8 : 7,
      ),
      _NavigationItem(
        icon: Icons.chat_bubble_outline,
        activeIcon: Icons.chat_bubble,
        label: 'Messages',
        index: _isAdmin ? 9 : 8,
      ),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                right: BorderSide(
                  color: Colors.grey[300] ?? Colors.grey,
                  width: 1,
                ),
              ),
              boxShadow: const [AppShadows.soft],
            ),
            child: Column(
              children: [
                // Sidebar Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Navigation',
                        style: AppTextStyles.h4.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${navigationItems.length} sections',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Scrollable Navigation Items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: navigationItems.length,
                    itemBuilder: (context, index) {
                      final item = navigationItems[index];
                      return _SidebarNavigationItem(
                        item: item,
                        isSelected: _currentIndex == item.index,
                        onTap: () {
                          setState(() {
                            _currentIndex = item.index;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: _screens[_currentIndex.clamp(0, _screens.length - 1)],
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;

  _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
  });
}

class _SidebarNavigationItem extends StatelessWidget {
  final _NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavigationItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  isSelected ? item.activeIcon : item.icon,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiary,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
