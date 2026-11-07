import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/share_helper.dart';
import '../../../data/models/user_settings.dart';
import '../../../data/models/verse.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/go_to_verse_dialog.dart';
import '../../../shared/widgets/ornamental_divider.dart';
import 'widgets/chapter_verse_picker_sheet.dart';
import 'widgets/font_size_dialog.dart';
import 'widgets/purport_section.dart';
import 'widgets/reader_bottom_bar.dart';
import 'widgets/sanskrit_section.dart';
import 'widgets/synonyms_section.dart';
import 'widgets/translation_section.dart';
import 'widgets/transliteration_section.dart';

class VerseReaderScreen extends ConsumerStatefulWidget {
  final int chapterNumber;
  final int verseNumber;

  const VerseReaderScreen({
    super.key,
    required this.chapterNumber,
    required this.verseNumber,
  });

  @override
  ConsumerState<VerseReaderScreen> createState() => _VerseReaderScreenState();
}

class _VerseReaderScreenState extends ConsumerState<VerseReaderScreen> {
  late PageController _pageController;
  late int _currentChapter;
  late int _currentVerse;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapterNumber;
    _currentVerse = widget.verseNumber;
    _currentIndex = AppConstants.coordinateToGlobalIndex(
      widget.chapterNumber,
      widget.verseNumber,
    );
    _pageController = PageController(initialPage: _currentIndex);

    // Record reading progress automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readingProgressNotifierProvider.notifier).updateProgress(
            _currentChapter,
            _currentVerse,
          );
    });
  }

  @override
  void didUpdateWidget(covariant VerseReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chapterNumber != widget.chapterNumber ||
        oldWidget.verseNumber != widget.verseNumber) {
      final newIndex = AppConstants.coordinateToGlobalIndex(
        widget.chapterNumber,
        widget.verseNumber,
      );
      if (newIndex != _currentIndex) {
        setState(() {
          _currentChapter = widget.chapterNumber;
          _currentVerse = widget.verseNumber;
          _currentIndex = newIndex;
        });
        if (_pageController.hasClients && _pageController.page?.round() != newIndex) {
          _pageController.jumpToPage(newIndex);
        }
        ref.read(readingProgressNotifierProvider.notifier).updateProgress(
              _currentChapter,
              _currentVerse,
            );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const FontSizeDialog(),
    );
  }

  void _showChapterPicker(BuildContext context) {
    ChapterVersePickerSheet.show(
      context,
      currentChapter: _currentChapter,
      currentVerse: _currentVerse,
      onVerseSelected: (chapter, verse) {
        final targetIndex = AppConstants.coordinateToGlobalIndex(
          chapter,
          verse,
        );
        setState(() {
          _currentIndex = targetIndex;
          _currentChapter = chapter;
          _currentVerse = verse;
        });
        ref.read(readingProgressNotifierProvider.notifier).updateProgress(
              chapter,
              verse,
            );
        _pageController.jumpToPage(targetIndex);
      },
    );
  }

  void _showGoToVerseDialog(BuildContext context) {
    GoToVerseDialog.show(
      context,
      initialChapter: _currentChapter,
      initialVerse: _currentVerse,
      onVerseSelected: (newChapter, newVerse) {
        final targetIndex = AppConstants.coordinateToGlobalIndex(
          newChapter,
          newVerse,
        );
        setState(() {
          _currentIndex = targetIndex;
          _currentChapter = newChapter;
          _currentVerse = newVerse;
        });
        ref.read(readingProgressNotifierProvider.notifier).updateProgress(
              newChapter,
              newVerse,
            );
        _pageController.jumpToPage(targetIndex);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = AppTheme.getBackgroundColor(settings.readingBackground, isDark);
    final verseKey = '$_currentChapter:$_currentVerse';
    final isBookmarkedAsync = ref.watch(isVerseBookmarkedProvider(verseKey));
    final isBookmarked = isBookmarkedAsync.value ?? false;

    final repo = ref.watch(verseRepositoryProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          'BG $_currentChapter.$_currentVerse',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppTheme.getPrimaryTextColor(settings.readingBackground, isDark),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: AppStrings.search,
            onPressed: () => context.push('/search'),
          ),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.accentRed : null,
            ),
            tooltip: 'Bookmark Verse',
            onPressed: () async {
              await ref
                  .read(bookmarksProvider.notifier)
                  .toggleBookmark(_currentChapter, _currentVerse);
              ref.invalidate(isVerseBookmarkedProvider(verseKey));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBookmarked
                          ? 'Bookmark removed'
                          : 'Verse BG $_currentChapter.$_currentVerse bookmarked',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Verse',
            onPressed: () async {
              final v = await repo.getVerse(_currentChapter, _currentVerse);
              if (v != null) {
                await ShareHelper.shareVerse(v);
              }
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: AppConstants.totalVerses,
        physics: const PageScrollPhysics(),
        onPageChanged: (pageIndex) {
          final coord = AppConstants.globalIndexToCoordinate(pageIndex);
          setState(() {
            _currentIndex = pageIndex;
            _currentChapter = coord.chapter;
            _currentVerse = coord.verse;
          });
          ref.read(readingProgressNotifierProvider.notifier).updateProgress(
                coord.chapter,
                coord.verse,
              );
        },
        itemBuilder: (context, pageIndex) {
          final coord = AppConstants.globalIndexToCoordinate(pageIndex);
          return _VersePageView(
            key: ValueKey('verse_${coord.chapter}_${coord.verse}'),
            chapterNumber: coord.chapter,
            verseNumber: coord.verse,
            settings: settings,
          );
        },
      ),
      bottomNavigationBar: ReaderBottomBar(
        chapterNumber: _currentChapter,
        verseNumber: _currentVerse,
        totalVersesInChapter: AppConstants.chapterVerseCounts[_currentChapter] ?? 1,
        hasPrevious: _currentIndex > 0,
        hasNext: _currentIndex < AppConstants.totalVerses - 1,
        onOpenChapterPicker: () => _showChapterPicker(context),
        onOpenVersePicker: () => _showGoToVerseDialog(context),
        onOpenFontSize: () => _showFontSizeDialog(context),
        onPreviousVerse: () {
          if (_currentIndex > 0) {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }
        },
        onNextVerse: () {
          if (_currentIndex < AppConstants.totalVerses - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }
        },
      ),
    );
  }
}

class _VersePageView extends ConsumerStatefulWidget {
  final int chapterNumber;
  final int verseNumber;
  final UserSettings settings;

  const _VersePageView({
    super.key,
    required this.chapterNumber,
    required this.verseNumber,
    required this.settings,
  });

  @override
  ConsumerState<_VersePageView> createState() => _VersePageViewState();
}

class _VersePageViewState extends ConsumerState<_VersePageView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final repo = ref.watch(verseRepositoryProvider);

    return FutureBuilder<Verse?>(
      future: repo.getVerse(widget.chapterNumber, widget.verseNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final verse = snapshot.data;

        if (verse == null) {
          return EmptyStateView(
            icon: Icons.auto_stories_outlined,
            title: 'BG ${widget.chapterNumber}.${widget.verseNumber}',
            message:
                'This verse has not yet been loaded into the database.\nUse the import system or read another verse.',
            buttonText: 'Return to Chapters',
            onButtonPressed: () => context.go('/'),
          );
        }

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Sanskrit Verse
              SanskritSection(
                sanskrit: verse.sanskrit,
                fontSize: widget.settings.fontSize,
              ),

              const SizedBox(height: 12),

              // 2. Roman Transliteration with diacritics
              TransliterationSection(
                transliteration: verse.transliteration,
                fontSize: widget.settings.fontSize,
              ),

              const SizedBox(height: 20),

              // 3. Synonyms
              SynonymsSection(
                synonyms: verse.synonyms,
                fontSize: widget.settings.fontSize,
              ),

              // 4. Translation
              TranslationSection(
                translation: verse.translation,
                fontSize: widget.settings.fontSize,
              ),

              // 5. Purport
              PurportSection(
                purport: verse.purport,
                fontSize: widget.settings.fontSize,
              ),

              const SizedBox(height: 32),
              const OrnamentalDivider(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
