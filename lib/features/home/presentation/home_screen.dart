import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_progress.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/ornamental_divider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final chaptersAsync = ref.watch(allChaptersProvider);
    final progressAsync = ref.watch(readingProgressNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: AppStrings.search,
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            tooltip: AppStrings.bookmarks,
            onPressed: () => context.push('/bookmarks'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: AppStrings.settings,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Hero Devotional Banner
          SliverToBoxAdapter(
            child: AppCard(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 4),
                  const OrnamentalDivider(width: 140),
                  Text(
                    AppStrings.authorAttribution,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 12,
                      color: isDark ? AppColors.secondaryTextDark : AppColors.secondaryTextLight,
                    ),
                  ),
                  const SizedBox(height: 18),
                  // Continue Reading Button
                  progressAsync.when(
                    data: (ReadingProgress progress) => FilledButton.icon(
                      onPressed: () {
                        context.push(
                          '/reader/${progress.lastChapter}/${progress.lastVerse}',
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: Text(
                        'Continue (${progress.reference})',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),

          // All Chapters Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 8.0),
              child: Row(
                children: [
                  Text(
                    'ALL CHAPTERS (18)',
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

          // Chapters List
          chaptersAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: ErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(allChaptersProvider),
              ),
            ),
            data: (chapters) {
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final chapter = chapters[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: theme.dividerTheme.color ?? Colors.grey.shade300,
                            width: 0.8,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 6.0,
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (isDark ? AppColors.darkAccentRed : AppColors.accentRed)
                                  .withValues(alpha: 0.1),
                            ),
                            child: Text(
                              '${chapter.chapterNumber}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                              ),
                            ),
                          ),
                          title: Text(
                            chapter.title,
                            style: const TextStyle(
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '${chapter.verseCount} Verses',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? AppColors.secondaryTextDark
                                  : AppColors.secondaryTextLight,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () {
                            context.push('/chapters/${chapter.chapterNumber}');
                          },
                        ),
                      );
                    },
                    childCount: chapters.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: OrnamentalDivider(),
            ),
          ),
        ],
      ),
    );
  }
}
