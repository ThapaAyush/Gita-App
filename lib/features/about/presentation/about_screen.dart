import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/ornamental_divider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.about),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // Devotional Header Card
            AppCard(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Official App Logo
                  Image.asset(
                    AppConstants.appLogo,
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const OrnamentalDivider(),
                  Text(
                    'Author & Founder-Acharya',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.authorAttribution,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Dedication Card
            AppCard(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DEDICATION',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This app is dedicated to His Divine Grace A.C. Bhaktivedanta Swami Srila Prabhupada, founder of ISKCON and BBT.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Georgia',
                          fontSize: 14,
                          height: 1.6,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Licensing and Attribution Card
            AppCard(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CONTENT & ATTRIBUTION',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'This application is built for the reverent study of the teachings of Bhagavad Gita As It Is by His Divine Grace A.C. Bhaktivedanta Swami Srila Prabhupada.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.publisherAttribution,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // App Specs Card
            AppCard(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildSpecRow('Version', '1.0.0 (Release)'),
                  const Divider(height: 16),
                  _buildSpecRow('Canonical Chapters', '${AppConstants.totalChapters} Chapters'),
                  const Divider(height: 16),
                  _buildSpecRow('Canonical Verses', '${AppConstants.totalVerses} Slokas'),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
