import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/chapter.dart';
import '../../../../data/providers.dart';

/// A bottom sheet that lets the user select a chapter, view all verses of that
/// chapter in a responsive grid or list, and jump directly to any chosen verse.
class ChapterVersePickerSheet extends ConsumerStatefulWidget {
  final int currentChapter;
  final int currentVerse;
  final void Function(int chapter, int verse) onVerseSelected;

  const ChapterVersePickerSheet({
    super.key,
    required this.currentChapter,
    required this.currentVerse,
    required this.onVerseSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentChapter,
    required int currentVerse,
    required void Function(int chapter, int verse) onVerseSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ChapterVersePickerSheet(
        currentChapter: currentChapter,
        currentVerse: currentVerse,
        onVerseSelected: onVerseSelected,
      ),
    );
  }

  @override
  ConsumerState<ChapterVersePickerSheet> createState() => _ChapterVersePickerSheetState();
}

class _ChapterVersePickerSheetState extends ConsumerState<ChapterVersePickerSheet> {
  int? _selectedChapterNumber;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(allChaptersProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = isDark ? AppColors.darkAccentRed : AppColors.accentRed;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Animated Switcher between Chapters List and Verses List
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _selectedChapterNumber == null
                    ? _buildChaptersList(
                        context,
                        chaptersAsync,
                        scrollController,
                        isDark,
                        accent,
                      )
                    : _buildVersesView(
                        context,
                        _selectedChapterNumber!,
                        chaptersAsync,
                        scrollController,
                        isDark,
                        accent,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Step 1: Chapters List View
  Widget _buildChaptersList(
    BuildContext context,
    AsyncValue<List<Chapter>> chaptersAsync,
    ScrollController scrollController,
    bool isDark,
    Color accent,
  ) {
    return Column(
      key: const ValueKey('chapters_list'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Chapter',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap any chapter to view its verses',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 12, thickness: 0.8),
        Expanded(
          child: chaptersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error loading chapters: $err')),
            data: (chapters) {
              return ListView.builder(
                controller: scrollController,
                itemCount: chapters.length,
                itemBuilder: (context, idx) {
                  final ch = chapters[idx];
                  final isCurrent = ch.chapterNumber == widget.currentChapter;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    leading: CircleAvatar(
                      backgroundColor: isCurrent ? accent : accent.withValues(alpha: 0.12),
                      foregroundColor: isCurrent ? Colors.white : accent,
                      child: Text(
                        '${ch.chapterNumber}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      ch.title,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight,
                      ),
                    ),
                    subtitle: Text(
                      '${ch.verseCount} verses',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.secondaryTextDark
                            : AppColors.secondaryTextLight,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    onTap: () {
                      setState(() {
                        _selectedChapterNumber = ch.chapterNumber;
                      });
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Step 2: Verses View of Selected Chapter (Grid / List)
  Widget _buildVersesView(
    BuildContext context,
    int chapterNum,
    AsyncValue<List<Chapter>> chaptersAsync,
    ScrollController scrollController,
    bool isDark,
    Color accent,
  ) {
    final chapter = chaptersAsync.value?.firstWhere(
      (c) => c.chapterNumber == chapterNum,
      orElse: () => Chapter(
        id: chapterNum,
        chapterNumber: chapterNum,
        title: 'Chapter $chapterNum',
        verseCount: AppConstants.chapterVerseCounts[chapterNum] ?? 1,
      ),
    );
    final totalVerses = AppConstants.chapterVerseCounts[chapterNum] ?? (chapter?.verseCount ?? 1);
    final chapterTitle = chapter?.title ?? 'Chapter $chapterNum';

    return Column(
      key: ValueKey('verses_for_chapter_$chapterNum'),
      children: [
        // Navigation Header: Back Button + Chapter Details + View Toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: accent,
                tooltip: 'Back to Chapters',
                onPressed: () {
                  setState(() {
                    _selectedChapterNumber = null;
                  });
                },
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter $chapterNum',
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$chapterTitle • $totalVerses verses',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded),
                color: accent,
                tooltip: _isGridView ? 'Switch to List View' : 'Switch to Grid View',
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(height: 8, thickness: 0.8),

        // Verses Display (Grid or List)
        Expanded(
          child: _isGridView
              ? _buildVerseGrid(totalVerses, chapterNum, scrollController, isDark, accent)
              : _buildVerseList(chapterNum, scrollController, isDark, accent),
        ),
      ],
    );
  }

  /// Grid of Verses (1, 2, 3 ... N)
  Widget _buildVerseGrid(
    int totalVerses,
    int chapterNum,
    ScrollController scrollController,
    bool isDark,
    Color accent,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GridView.builder(
        controller: scrollController,
        itemCount: totalVerses,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          final verseNum = index + 1;
          final isCurrent = (chapterNum == widget.currentChapter && verseNum == widget.currentVerse);
          final cardBg = isCurrent
              ? accent
              : (isDark ? AppColors.darkCard : AppColors.parchmentCard);
          final textColor = isCurrent
              ? Colors.white
              : (isDark ? AppColors.primaryTextDark : AppColors.primaryTextLight);
          final borderColor = isCurrent
              ? accent
              : (isDark ? AppColors.darkDivider : AppColors.dividerColorLight);

          return Material(
            color: cardBg,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                widget.onVerseSelected(chapterNum, verseNum);
              },
              borderRadius: BorderRadius.circular(8),
              enableFeedback: false,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 0.8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$verseNum',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// List of Verses with preview
  Widget _buildVerseList(
    int chapterNum,
    ScrollController scrollController,
    bool isDark,
    Color accent,
  ) {
    final versesAsync = ref.watch(versesForChapterProvider(chapterNum));

    return versesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading verses: $err')),
      data: (verses) {
        if (verses.isEmpty) {
          return const Center(child: Text('No verses found for this chapter.'));
        }

        return ListView.separated(
          controller: scrollController,
          itemCount: verses.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
          itemBuilder: (context, index) {
            final v = verses[index];
            final isCurrent = (v.chapterNumber == widget.currentChapter &&
                v.verseNumber == widget.currentVerse);

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrent ? accent : accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'BG ${v.chapterNumber}.${v.verseNumber}',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isCurrent ? Colors.white : accent,
                  ),
                ),
              ),
              title: Text(
                v.transliteration.isNotEmpty ? v.transliteration : v.sanskrit,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              subtitle: Text(
                v.translation,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward, size: 14),
              onTap: () {
                Navigator.pop(context);
                widget.onVerseSelected(v.chapterNumber, v.verseNumber);
              },
            );
          },
        );
      },
    );
  }
}
