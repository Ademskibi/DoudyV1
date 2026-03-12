import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seenOnboarding') ?? false;
    await Future.delayed(Duration(milliseconds: 800));
    final auth = Provider.of<AuthService>(context, listen: false);
    debugPrint('Splash: seenOnboarding=$seen');
    try {
      // Prefer the current cached user if available to avoid waiting.
      var user = auth.firebaseUser;
      if (user == null) {
        // Wait for the first auth event but don't wait forever.
        try {
          user = await auth.authStateChanges().first.timeout(Duration(seconds: 3));
        } catch (_) {
          user = auth.firebaseUser;
        }
      }
      debugPrint('Splash: firebase user = ${user?.uid}');
      if (!mounted) return;
      if (!seen) {
        GoRouter.of(context).go('/login');
        return;
      }
      if (user == null) {
        GoRouter.of(context).go('/login');
        return;
      }
      // ensure appUser is loaded from FirestoreService (AuthService listens already)
      // If appUser isn't available yet (e.g. Firestore delays), wait briefly instead
      // of defaulting to 'parent' which causes incorrect routing.
      const maxWait = Duration(seconds: 5);
      const poll = Duration(milliseconds: 250);
      var waited = Duration.zero;
      while (auth.appUser == null && waited < maxWait) {
        await Future.delayed(poll);
        waited += poll;
      }

      final role = auth.appUser?.role;
      debugPrint('Splash: routing to role=$role (waited ${waited.inMilliseconds}ms)');
      if (role == null) {
        // Couldn't determine role reliably — go to login to allow re-auth/repair
        GoRouter.of(context).go('/login');
        return;
      }
      if (role == 'parent') {
        GoRouter.of(context).go('/parent');
      } else if (role == 'child') {
        GoRouter.of(context).go('/child');
      } else {
        GoRouter.of(context).go('/admin');
      }
      return;
    } catch (e) {
      debugPrint('Splash routing error: $e');
      if (!mounted) return;
      GoRouter.of(context).go('/login');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('DOUDY', style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 12),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
