import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/config/supabase_config.dart';
import 'features/subscription/services/stripe_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/auth_screen.dart';
import 'shared/navigation/main_navigation.dart';
import 'home_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/EditProfile_screen.dart';
import 'features/course/screens/course_list_screen.dart';
import 'features/course/screens/course_form_screen.dart';
import 'features/subscription/screens/user_subscription_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  //add verification for .env load
  if (dotenv.env['HF_API_KEY'] == null) {
    throw Exception('Missing .env variable: HF_API_KEY');
  }
  else {
    print('HF_API_KEY loaded successfully');
  }
  
  // Initialize Stripe (only if supported)
  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'];
  if (stripeKey != null && stripeKey.isNotEmpty) {
    try {
      Stripe.publishableKey = stripeKey;
      await StripeService.initialize();
    } catch (e) {
      // Stripe not supported on this platform (e.g., Linux, Web)
      // This is expected - demo mode will be shown instead
    }
  }
  
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avanti - E-Learning',
        routes: {
       // '/': (context) => const HomeScreen(), // Your home screen
        '/profile': (context) => const ProfileScreen(), // Your profile screen
        '/edit-profile': (context) => const EditProfileScreen(),
        '/courses': (context) => const CourseListScreen(),
        '/courses/new': (context) => CourseFormScreen(),
        '/subscription': (context) => const UserSubscriptionScreen(),
        // ...other routes...
      },
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _getInitialSession();
    _listenToAuthChanges();
  }

  Future<void> _getInitialSession() async {
    final session = Supabase.instance.client.auth.currentSession;
    setState(() {
      _user = session?.user;
    });
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _user = data.session?.user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while checking authentication state
    if (_user == null) {
      return const AuthScreen();
    } else {
      return const MainNavigation();
    }
  }
}
