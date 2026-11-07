import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/error_view.dart';

class ChapterDetailScreen extends ConsumerWidget {
  final int chapterNumber;

  const ChapterDetailScreen({
    super.key,
    required this.chapterNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterAsync = ref.watch(chapterDetailProvider(chapterNumber));
    final versesAsync = ref.watch(versesForChapterProvider(chapterNumber));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalVerses = AppConstants.chapterVerseCounts[chapterNumber] ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapter $chapterNumber',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            if (chapterAsync.value?.title != null)
              Text(
                chapterAsync.value!.title,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                  fontWeight: FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
      body: chapterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.refresh(chapterDetailProvider(chapterNumber)),
        ),
        data: (chapter) {
          return CustomScrollView(
            slivers: [
              // Verses List Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    children: [
                      Text(
                        'VERSES ($totalVerses)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: isDark ? AppColors.darkDivider : AppColors.dividerColorLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Verses List
              versesAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $err')),
                ),
                data: (loadedVerses) {
                  // Map loaded verses by verse number for quick lookup
                  final loadedMap = {for (var v in loadedVerses) v.verseNumber: v};

                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final verseNum = index + 1;
                          final loadedVerse = loadedMap[verseNum];
                          final hasFullText = loadedVerse != null;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300,
                                width: 0.8,
                              ),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                              leading: Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: (isDark ? AppColors.darkAccentRed : AppColors.accentRed)
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$verseNum',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                                  ),
                                ),
                              ),
                              title: Text(
                                'BG $chapterNumber.$verseNum',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                hasFullText
                                    ? loadedVerse.translation
                                    : 'Text and purports from Bhagavad Gita As It Is',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? AppColors.secondaryTextDark
                                      : AppColors.secondaryTextLight,
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                                size: 20,
                              ),
                              onTap: () {
                                context.push('/reader/$chapterNumber/$verseNum');
                              },
                            ),
                          );
                        },
                        childCount: totalVerses,
                      ),
                    ),
                  );
                },
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }
}
