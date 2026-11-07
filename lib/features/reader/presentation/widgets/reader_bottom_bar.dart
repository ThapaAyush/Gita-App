import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/sacred_grid_icon.dart';

class ReaderBottomBar extends StatelessWidget {
  final int chapterNumber;
  final int verseNumber;
  final int totalVersesInChapter;
  final VoidCallback onOpenChapterPicker;
  final VoidCallback onOpenVersePicker;
  final VoidCallback onOpenFontSize;
  final VoidCallback? onPreviousVerse;
  final VoidCallback? onNextVerse;
  final bool hasPrevious;
  final bool hasNext;

  const ReaderBottomBar({
    super.key,
    required this.chapterNumber,
    required this.verseNumber,
    required this.totalVersesInChapter,
    required this.onOpenChapterPicker,
    required this.onOpenVersePicker,
    required this.onOpenFontSize,
    this.onPreviousVerse,
    this.onNextVerse,
    this.hasPrevious = true,
    this.hasNext = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final barBg = isDark ? AppColors.darkCard : AppColors.parchmentCard;
    final accent = isDark ? AppColors.darkAccentRed : AppColors.accentRed;
    final disabledColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;
    final borderColor = isDark ? AppColors.darkDivider : AppColors.dividerColorLight;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: bottomInset > 0 ? bottomInset + 4 : 10,
      ),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(
            color: borderColor,
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height: 42,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Left: Chapter Selection Button (Chapters List Icon)
            Align(
              alignment: Alignment.centerLeft,
              child: Tooltip(
                message: 'All Chapters',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onOpenChapterPicker,
                    borderRadius: BorderRadius.circular(10),
                    enableFeedback: false,
                    child: SizedBox(
                      width: 40,
                      height: 38,
                      child: Center(
                        child: Icon(
                          Icons.format_list_bulleted_rounded,
                          size: 22,
                          color: accent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Center: Perfectly Centered Verse Picker Button (Clean & Borderless)
            Align(
              alignment: Alignment.center,
              child: Tooltip(
                message: 'Select Chapter & Verse',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onOpenVersePicker,
                    borderRadius: BorderRadius.circular(19),
                    enableFeedback: false,
                    child: SizedBox(
                      height: 38,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SacredGridIcon(size: 15),
                            const SizedBox(width: 8),
                            Text(
                              'BG $chapterNumber.$verseNumber',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.3,
                                color: isDark
                                    ? AppColors.primaryTextDark
                                    : AppColors.primaryTextLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Right: Reading Preferences (TT) + Nav (< >)
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // TT Font Size Button (Clean & Borderless)
                  Tooltip(
                    message: 'Text Size & Theme',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onOpenFontSize,
                        borderRadius: BorderRadius.circular(10),
                        enableFeedback: false,
                        child: SizedBox(
                          width: 40,
                          height: 38,
                          child: Center(
                            child: Icon(
                              Icons.format_size_rounded,
                              size: 20,
                              color: accent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Navigation Prev (<)
                  Tooltip(
                    message: 'Previous Verse',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(19),
                        onTap: hasPrevious ? onPreviousVerse : null,
                        enableFeedback: false,
                        child: SizedBox(
                          width: 36,
                          height: 38,
                          child: Center(
                            child: Icon(
                              Icons.chevron_left_rounded,
                              size: 24,
                              color: hasPrevious ? accent : disabledColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Navigation Next (>)
                  Tooltip(
                    message: 'Next Verse',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(19),
                        onTap: hasNext ? onNextVerse : null,
                        enableFeedback: false,
                        child: SizedBox(
                          width: 36,
                          height: 38,
                          child: Center(
                            child: Icon(
                              Icons.chevron_right_rounded,
                              size: 24,
                              color: hasNext ? accent : disabledColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
