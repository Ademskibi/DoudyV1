import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/app_router.dart';
import 'core/utils/responsive.dart';
import 'services/auth_service.dart';
import 'services/story_progress_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Helpful debug: print the project id the app initialized with at runtime
      try {
        // ignore: avoid_print
        print('Firebase project at runtime: ${Firebase.app().options.projectId}');
      } catch (_) {}
    } catch (e, st) {
      // Don't let Firebase init failure block UI — log and continue so Splash shows.
      // ignore: avoid_print
      print('Firebase.initializeApp failed: $e');
      // ignore: avoid_print
      print(st);
    }
  }

  try {
    // best-effort print if Firebase is available
    // ignore: avoid_print
    print('Firebase project id: ${Firebase.apps.isNotEmpty ? Firebase.app().options.projectId : 'none'}');
  } catch (_) {}

  final pd = WidgetsBinding.instance.platformDispatcher;
  final view = pd.views.first;
  final devicePixelRatio = view.devicePixelRatio;
  final physical = view.physicalSize;
  final logicalWidth = physical.width / devicePixelRatio;
  final isTablet = logicalWidth >= 600;

  if (isTablet) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  } else {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  runApp(const MyApp());
}

// Show build/runtime errors on screen instead of a grey/black screen.
// This helps surface Flutter build exceptions in release/debug runs.
void _installErrorWidget() {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    final message = details.exceptionAsString();
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('App Error:\n$message', style: const TextStyle(color: Colors.black), textAlign: TextAlign.center),
        ),
      ),
    );
  };
}

// Install error widget immediately so crashes during app startup are visible.
final _ = _installErrorWidget();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService(), lazy: false),
        ChangeNotifierProvider(create: (_) => StoryProgressService()..init()),
      ],
      child: Builder(
        builder: (inner) {
          SizeConfig.init(inner);
          return MaterialApp.router(
            title: 'DOUDY',
            theme: AppTheme.light(),
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}