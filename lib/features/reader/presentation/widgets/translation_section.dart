import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class TranslationSection extends StatelessWidget {
  final String translation;
  final double fontSize;

  const TranslationSection({
    super.key,
    required this.translation,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (translation.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkAccentRed : AppColors.accentRed;
    final textColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.translationTitle.toUpperCase(),
            style: TextStyle(
              fontSize: (fontSize - 2).clamp(12.0, 16.0),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            translation,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: fontSize + 1.0,
              fontWeight: FontWeight.w600,
              height: 1.65,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

