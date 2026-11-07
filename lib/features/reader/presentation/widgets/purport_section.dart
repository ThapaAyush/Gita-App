import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class PurportSection extends StatelessWidget {
  final String purport;
  final double fontSize;

  const PurportSection({
    super.key,
    required this.purport,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (purport.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkAccentRed : AppColors.accentRed;
    final textColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.purportTitle.toUpperCase(),
            style: TextStyle(
              fontSize: (fontSize - 2).clamp(12.0, 16.0),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            purport,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: fontSize,
              height: 1.75,
              color: textColor,
              letterSpacing: 0.15,
            ),
          ),
        ],
      ),
    );
  }
}

