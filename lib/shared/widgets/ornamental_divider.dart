import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class OrnamentalDivider extends StatelessWidget {
  final double? width;
  final Color? color;

  const OrnamentalDivider({
    super.key,
    this.width,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ornamentColor = color ?? (isDark ? AppColors.darkAccentRed : AppColors.accentRed);

    return Center(
      child: Container(
        width: width ?? 160,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ornamentColor.withValues(alpha: 0.0),
                      ornamentColor.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.diamond_outlined, size: 10, color: ornamentColor),
                  const SizedBox(width: 4),
                  Icon(Icons.brightness_7, size: 14, color: ornamentColor),
                  const SizedBox(width: 4),
                  Icon(Icons.diamond_outlined, size: 10, color: ornamentColor),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ornamentColor.withValues(alpha: 0.6),
                      ornamentColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

