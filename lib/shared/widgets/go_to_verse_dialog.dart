import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class GoToVerseDialog extends StatefulWidget {
  final int? initialChapter;
  final int? initialVerse;
  final void Function(int chapter, int verse)? onVerseSelected;

  const GoToVerseDialog({
    super.key,
    this.initialChapter,
    this.initialVerse,
    this.onVerseSelected,
  });

  /// Displays the "Go to verse..." dialog as a top modal
  static Future<void> show(
    BuildContext context, {
    int? initialChapter,
    int? initialVerse,
    void Function(int chapter, int verse)? onVerseSelected,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => GoToVerseDialog(
        initialChapter: initialChapter,
        initialVerse: initialVerse,
        onVerseSelected: onVerseSelected,
      ),
    );
  }

  @override
  State<GoToVerseDialog> createState() => _GoToVerseDialogState();
}

class _GoToVerseDialogState extends State<GoToVerseDialog> {
  late TextEditingController _chapterController;
  late TextEditingController _verseController;
  late FocusNode _chapterFocus;
  late FocusNode _verseFocus;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _chapterController = TextEditingController(
      text: widget.initialChapter != null ? '${widget.initialChapter}' : '',
    );
    _verseController = TextEditingController(
      text: widget.initialVerse != null ? '${widget.initialVerse}' : '',
    );
    _chapterFocus = FocusNode();
    _verseFocus = FocusNode();

    // Select text on focus for effortless replacement
    _chapterFocus.addListener(() {
      if (_chapterFocus.hasFocus && _chapterController.text.isNotEmpty) {
        _chapterController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _chapterController.text.length,
        );
      }
    });

    _verseFocus.addListener(() {
      if (_verseFocus.hasFocus && _verseController.text.isNotEmpty) {
        _verseController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _verseController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _chapterController.dispose();
    _verseController.dispose();
    _chapterFocus.dispose();
    _verseFocus.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _errorMessage = null);

    final chapterText = _chapterController.text.trim();
    final verseText = _verseController.text.trim();

    final chapter = int.tryParse(chapterText);
    final verse = int.tryParse(verseText);

    if (chapter == null || chapter < 1 || chapter > AppConstants.totalChapters) {
      setState(() {
        _errorMessage = 'Chapter must be between 1 and ${AppConstants.totalChapters}';
      });
      _chapterFocus.requestFocus();
      return;
    }

    final maxVerse = AppConstants.chapterVerseCounts[chapter] ?? 1;
    if (verse == null || verse < 1 || verse > maxVerse) {
      setState(() {
        _errorMessage = 'Chapter $chapter has $maxVerse verses (1 - $maxVerse)';
      });
      _verseFocus.requestFocus();
      return;
    }

    Navigator.of(context).pop();

    if (widget.onVerseSelected != null) {
      widget.onVerseSelected!(chapter, verse);
    } else {
      context.push('/reader/$chapter/$verse');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dialogBg = isDark ? AppColors.darkCard : const Color(0xFFFBF8EA);
    final inputBg = isDark ? const Color(0xFF38352A) : const Color(0xFFE2DEC0);
    final buttonBg = isDark ? const Color(0xFF007A87) : const Color(0xFF006874);

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Close 'X' in red, Title 'Go to verse...'
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: AppColors.accentRed, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Close',
                ),
                const SizedBox(width: 12),
                Text(
                  'Go to verse...',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Main Input Row: BG [ Chapter ] . [ Verse ] [ → ]
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'BG',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight,
                  ),
                ),
                const SizedBox(width: 14),

                // Chapter Number Box
                _buildNumberField(
                  controller: _chapterController,
                  focusNode: _chapterFocus,
                  backgroundColor: inputBg,
                  hint: '1',
                  autofocus: true,
                  isDark: isDark,
                  onChanged: (val) {
                    if (val.length >= 2) {
                      _verseFocus.requestFocus();
                    }
                  },
                  onSubmitted: (_) => _verseFocus.requestFocus(),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '.',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Verse Number Box
                _buildNumberField(
                  controller: _verseController,
                  focusNode: _verseFocus,
                  backgroundColor: inputBg,
                  hint: '1',
                  autofocus: false,
                  isDark: isDark,
                  onChanged: (_) {},
                  onSubmitted: (_) => _submit(),
                ),

                const SizedBox(width: 14),

                // Go Arrow Button [ → ]
                Material(
                  color: buttonBg,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: _submit,
                    borderRadius: BorderRadius.circular(6),
                    enableFeedback: false,
                    child: const SizedBox(
                      width: 50,
                      height: 46,
                      child: Center(
                        child: Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 14),
              Center(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: AppColors.accentRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required Color backgroundColor,
    required String hint,
    required bool autofocus,
    required bool isDark,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
  }) {
    return Container(
      width: 62,
      height: 46,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: focusNode.hasFocus
              ? (isDark ? AppColors.darkAccentRed : AppColors.accentRed)
              : Colors.black.withValues(alpha: 0.1),
          width: focusNode.hasFocus ? 1.5 : 1.0,
        ),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onChanged: onChanged,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}

