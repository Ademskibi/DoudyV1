import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/app_router.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') {
      // Real error — show it
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(e.toString(), textAlign: TextAlign.center),
            ),
          ),
        ),
      ));
      return;
    }
    // duplicate-app is fine — Firebase already initialized natively, continue
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),  // Firebase is guaranteed ready by now
      lazy: false,                   // force immediate creation AFTER init
      child: MaterialApp.router(
        title: 'DOUDY',
        theme: AppTheme.light(),
        routerConfig: appRouter,
      ),
    );
  }
}
