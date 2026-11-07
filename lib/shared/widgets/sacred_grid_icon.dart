import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A devotional grid icon representing the sacred 10-point Tilak / Japa grid
/// seen in canonical scripture reader navigation (3x3 grid + 1 base point).
class SacredGridIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const SacredGridIcon({
    super.key,
    this.size = 18.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dotColor = color ?? (isDark ? AppColors.darkAccentRed : AppColors.accentRed);

    return CustomPaint(
      size: Size(size * 0.75, size),
      painter: _SacredGridPainter(dotColor: dotColor),
    );
  }
}

class _SacredGridPainter extends CustomPainter {
  final Color dotColor;

  const _SacredGridPainter({required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.12;
    final colSpacing = size.width * 0.38;
    final rowSpacing = size.height * 0.24;

    final startX = size.width * 0.12;
    final startY = size.height * 0.12;

    // 3 rows x 3 columns
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final x = startX + col * colSpacing;
        final y = startY + row * rowSpacing;
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }

    // 4th row: single center dot below (sacred base point)
    final centerX = startX + colSpacing;
    final bottomY = startY + 3 * rowSpacing;
    canvas.drawCircle(Offset(centerX, bottomY), dotRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _SacredGridPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor;
  }
}

