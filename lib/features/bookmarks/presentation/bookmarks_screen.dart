import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.bookmarks),
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.read(bookmarksProvider.notifier).loadBookmarks(),
        ),
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return EmptyStateView(
              icon: Icons.bookmark_border_rounded,
              title: AppStrings.noBookmarks,
              message: AppStrings.noBookmarksSubtitle,
              buttonText: AppStrings.browseAllChapters,
              onButtonPressed: () => context.go('/'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            itemCount: bookmarks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final b = bookmarks[index];
              return Dismissible(
                key: Key('bookmark_${b.chapterNumber}_${b.verseNumber}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref
                      .read(bookmarksProvider.notifier)
                      .removeBookmark(b.chapterNumber, b.verseNumber);
                  ref.invalidate(
                      isVerseBookmarkedProvider('${b.chapterNumber}:${b.verseNumber}'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed ${b.reference} from bookmarks'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300,
                      width: 0.8,
                    ),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkAccentRed : AppColors.accentRed)
                            .withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bookmark,
                        color: isDark ? AppColors.darkAccentRed : AppColors.accentRed,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      b.reference,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        b.translationPreview ?? 'Tap to read this bookmarked verse.',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.secondaryTextDark
                              : AppColors.secondaryTextLight,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Remove',
                      onPressed: () {
                        ref
                            .read(bookmarksProvider.notifier)
                            .removeBookmark(b.chapterNumber, b.verseNumber);
                        ref.invalidate(
                            isVerseBookmarkedProvider('${b.chapterNumber}:${b.verseNumber}'));
                      },
                    ),
                    onTap: () {
                      context.push('/reader/${b.chapterNumber}/${b.verseNumber}');
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

