import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/parent_home_screen.dart';
import '../features/home/screens/child_home_screen.dart';
import '../features/home/screens/admin_dashboard.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (c, s) => SplashScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => OnboardingScreen()),
    GoRoute(path: '/login', builder: (c, s) => LoginScreen()),
    GoRoute(path: '/register', builder: (c, s) => RegisterScreen()),
    GoRoute(path: '/parent', builder: (c, s) => ParentHomeScreen()),
    GoRoute(path: '/child', builder: (c, s) => ChildHomeScreen()),
    GoRoute(path: '/admin', builder: (c, s) => AdminDashboard()),
  ],
);
