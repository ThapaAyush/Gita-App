import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TransliterationSection extends StatelessWidget {
  final String transliteration;
  final double fontSize;

  const TransliterationSection({
    super.key,
    required this.transliteration,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (transliteration.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SelectableText(
          transliteration,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: fontSize + 1.0,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w500,
            height: 1.7,
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

