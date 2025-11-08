import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/EditProfile_screen.dart';
import '../../features/profile/screens/UserListScreen.dart'; // Import UserListScreen
import '../../features/messages/screens/chat_screen.dart'; // Import ChatScreen
import '../../features/course/screens/course_list_screen.dart';
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
        if (_isAdmin) const AdminDashboardScreen(),
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
    return Scaffold(
  body: _screens[_currentIndex.clamp(0, _screens.length - 1)],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [AppShadows.soft],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: AppTextStyles.caption.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.caption,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Courses',
            ),
            if (_isAdmin)
              const BottomNavigationBarItem(
                icon: Icon(Icons.admin_panel_settings_outlined),
                activeIcon: Icon(Icons.admin_panel_settings),
                label: 'Admin',
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_outlined),
              activeIcon: Icon(Icons.edit),
              label: 'Edit Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Messages',
            ),
          ],
        ),
      ),
    );
  }
}
