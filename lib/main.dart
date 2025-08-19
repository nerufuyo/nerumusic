import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/themes/app_theme.dart';
import 'core/utils/injection.dart';
import 'presentation/pages/home_page.dart';

/// Main entry point for Neru Music application
/// Initializes all core services and dependency injection
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  await dotenv.load(fileName: '.env');

  // Initialize local storage
  await Hive.initFlutter();

  // Configure dependency injection
  await configureDependencies();

  // Initialize core services
  await initializeCoreServices();

  runApp(
    const ProviderScope(
      child: NeruMusicApp(),
    ),
  );
}

/// Root application widget with dark theme and routing
class NeruMusicApp extends StatelessWidget {
  const NeruMusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neru Music',
      debugShowCheckedModeBanner: false,
      theme: AppThemeData.darkTheme,
      home: const HomePage(),
    );
  }
}
