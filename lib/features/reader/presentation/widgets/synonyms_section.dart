import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class SynonymsSection extends StatelessWidget {
  final String synonyms;
  final double fontSize;

  const SynonymsSection({
    super.key,
    required this.synonyms,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (synonyms.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkAccentRed : AppColors.accentRed;
    final bodyColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.synonymsTitle.toUpperCase(),
            style: TextStyle(
              fontSize: (fontSize - 3).clamp(11.0, 15.0),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 6),
          SelectableText(
            synonyms,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: fontSize - 1.0,
              height: 1.6,
              color: bodyColor.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}

