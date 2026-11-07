import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SanskritSection extends StatelessWidget {
  final String sanskrit;
  final double fontSize;

  const SanskritSection({
    super.key,
    required this.sanskrit,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (sanskrit.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.sanskritGoldDark : AppColors.sanskritGold;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SelectableText(
          sanskrit,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize + 3.0,
            fontWeight: FontWeight.w700,
            height: 1.8,
            color: textColor,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}

