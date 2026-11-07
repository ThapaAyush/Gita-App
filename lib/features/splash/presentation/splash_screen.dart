import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/database/app_database.dart';
import '../../../shared/widgets/ornamental_divider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _animController.forward();

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Seed local database from assets if first run
    await AppDatabase.instance.seedDatabaseIfNeeded();

    // Subtle devotional pause for 2 seconds
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Official App Logo
                Image.asset(
                  AppConstants.appLogo,
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 28),

                // App Title
                Text(
                  AppStrings.appName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),

                const SizedBox(height: 12),

                const OrnamentalDivider(width: 140),

                const SizedBox(height: 8),

                Text(
                  AppStrings.authorAttribution,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 13,
                    color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                  ),
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

