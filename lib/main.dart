import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style to match traditional spiritual aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize and seed local database if needed
  try {
    await AppDatabase.instance.seedDatabaseIfNeeded();
  } catch (e) {
    debugPrint('Database initialization notice: $e');
  }

  runApp(
    const ProviderScope(
      child: BhagavadGitaApp(),
    ),
  );
}

class BhagavadGitaApp extends ConsumerWidget {
  const BhagavadGitaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);

    ThemeMode themeMode;
    if (settings.readingBackground == ReadingBackgroundMode.dark || settings.themeMode == 'dark') {
      themeMode = ThemeMode.dark;
    } else if (settings.themeMode == 'light') {
      themeMode = ThemeMode.light;
    } else {
      themeMode = ThemeMode.system;
    }

    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? AppColors.darkCard : AppColors.parchmentCard,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}
