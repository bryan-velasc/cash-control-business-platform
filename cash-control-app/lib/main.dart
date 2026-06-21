import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';

import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';

import 'providers/theme_provider.dart';

import 'providers/eye_control_provider.dart';

import 'providers/date_filter_provider.dart';

import 'screens/login_screen.dart';

import 'screens/quick_note_screen.dart';

import 'widgets/eye_control_overlay.dart';

import 'services/app_launch_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();

  await Hive.openBox(
    "cash_control_local",
  );

  final initialRoute =
      await AppLaunchService.getInitialRoute();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => EyeControlProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DateFilterProvider(),
        ),
      ],
      child: MyApp(
        initialRoute: initialRoute,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({
    super.key,
    required this.initialRoute,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(
      context,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "CASH-CONTROL",
      themeMode: themeProvider.themeMode,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      initialRoute: initialRoute,
      routes: {
        "/": (context) => const LoginScreen(),
        "/quick-note": (context) =>
            const QuickNoteScreen(),
      },
      builder: (
        context,
        child,
      ) {
        return EyeControlOverlay(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}