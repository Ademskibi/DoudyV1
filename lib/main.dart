import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/app_router.dart';
import 'core/utils/responsive.dart';
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

  // Determine logical screen width early (before runApp) so we can set
  // preferred orientations immediately. This prevents the system from
  // allowing unwanted rotations at startup.
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

    // Initialize responsive size helper using a Builder so MediaQuery is available.
    runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Determine device type (phone vs tablet) after first frame using MediaQuery
  // and apply preferred orientations.
  // Orientation is applied at startup in `main()`; no runtime policy needed.

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(), // Firebase is ready by now
      lazy: false,
      child: Builder(builder: (inner) {
        SizeConfig.init(inner);
        return MaterialApp.router(
          title: 'DOUDY',
          theme: AppTheme.light(),
          routerConfig: appRouter,
        );
      }),
    );
  }
}
