import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/providers.dart';

class FontSizeDialog extends ConsumerWidget {
  final double? currentFontSize;
  final ReadingBackgroundMode? currentBackground;
  final ValueChanged<double>? onFontSizeChanged;
  final ValueChanged<ReadingBackgroundMode>? onBackgroundChanged;

  const FontSizeDialog({
    super.key,
    this.currentFontSize,
    this.currentBackground,
    this.onFontSizeChanged,
    this.onBackgroundChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final activeFontSize = currentFontSize ?? settings.fontSize;
    final activeBackground = currentBackground ?? settings.readingBackground;

    final isDark = activeBackground == ReadingBackgroundMode.dark ||
        settings.themeMode == 'dark' ||
        Theme.of(context).brightness == Brightness.dark;

    final dialogBg = isDark ? AppColors.darkCard : AppColors.parchmentCard;
    final primaryTextColor = isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight;
    final accent = isDark ? AppColors.darkAccentRed : AppColors.accentRed;

    return Dialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reading Preferences',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: primaryTextColor,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Font Size (${activeFontSize.toInt()} pt)',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.text_decrease),
                  color: accent,
                  onPressed: activeFontSize > 13
                      ? () {
                          final newSize = activeFontSize - 1;
                          onFontSizeChanged?.call(newSize);
                          ref.read(userSettingsProvider.notifier).setFontSize(newSize);
                        }
                      : null,
                ),
                Expanded(
                  child: Slider(
                    value: activeFontSize,
                    min: 13,
                    max: 28,
                    divisions: 15,
                    activeColor: accent,
                    inactiveColor: isDark ? AppColors.darkDivider : AppColors.dividerColorLight,
                    label: '${activeFontSize.toInt()} pt',
                    onChanged: (newSize) {
                      onFontSizeChanged?.call(newSize);
                      ref.read(userSettingsProvider.notifier).setFontSize(newSize);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.text_increase),
                  color: accent,
                  onPressed: activeFontSize < 28
                      ? () {
                          final newSize = activeFontSize + 1;
                          onFontSizeChanged?.call(newSize);
                          ref.read(userSettingsProvider.notifier).setFontSize(newSize);
                        }
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Reading Background',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBackgroundChoice(
                  context,
                  ref,
                  title: 'Parchment',
                  color: AppColors.bgParchment,
                  mode: ReadingBackgroundMode.parchment,
                  activeBackground: activeBackground,
                  accent: accent,
                  primaryTextColor: primaryTextColor,
                  isDark: isDark,
                ),
                _buildBackgroundChoice(
                  context,
                  ref,
                  title: 'Sepia',
                  color: AppColors.bgSepia,
                  mode: ReadingBackgroundMode.sepia,
                  activeBackground: activeBackground,
                  accent: accent,
                  primaryTextColor: primaryTextColor,
                  isDark: isDark,
                ),
                _buildBackgroundChoice(
                  context,
                  ref,
                  title: 'Paper',
                  color: AppColors.bgPaper,
                  mode: ReadingBackgroundMode.paper,
                  activeBackground: activeBackground,
                  accent: accent,
                  primaryTextColor: primaryTextColor,
                  isDark: isDark,
                ),
                _buildBackgroundChoice(
                  context,
                  ref,
                  title: 'Dark',
                  color: AppColors.bgDark,
                  mode: ReadingBackgroundMode.dark,
                  activeBackground: activeBackground,
                  accent: accent,
                  primaryTextColor: primaryTextColor,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundChoice(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required Color color,
    required ReadingBackgroundMode mode,
    required ReadingBackgroundMode activeBackground,
    required Color accent,
    required Color primaryTextColor,
    required bool isDark,
  }) {
    final isSelected = activeBackground == mode;

    return GestureDetector(
      onTap: () {
        onBackgroundChanged?.call(mode);
        ref.read(userSettingsProvider.notifier).setReadingBackground(mode);
      },
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? accent : (isDark ? AppColors.darkDivider : Colors.grey.shade400),
                width: isSelected ? 3.0 : 1.0,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: accent.withValues(alpha: 0.35),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
              ],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    size: 22,
                    color: mode == ReadingBackgroundMode.dark ? Colors.white : accent,
                  )
                : null,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Georgia',
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? accent : primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
