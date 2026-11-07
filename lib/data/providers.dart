import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import 'database/app_database.dart';
import 'models/bookmark.dart';
import 'models/chapter.dart';
import 'models/reading_progress.dart';
import 'models/user_settings.dart';
import 'models/verse.dart';
import 'repositories/bookmark_repository.dart';
import 'repositories/chapter_repository.dart';
import 'repositories/reading_progress_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/verse_repository.dart';

// Database & Repositories
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final chapterRepositoryProvider = Provider<ChapterRepository>((ref) {
  return SqliteChapterRepository(ref.watch(databaseProvider));
});

final verseRepositoryProvider = Provider<VerseRepository>((ref) {
  return SqliteVerseRepository(ref.watch(databaseProvider));
});

final bookmarkRepositoryProvider = Provider<BookmarkRepository>((ref) {
  return SqliteBookmarkRepository(ref.watch(databaseProvider));
});

final readingProgressRepositoryProvider = Provider<ReadingProgressRepository>((ref) {
  return SqliteReadingProgressRepository(ref.watch(databaseProvider));
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SharedPreferencesSettingsRepository();
});

// Chapters List Provider
final allChaptersProvider = FutureProvider<List<Chapter>>((ref) async {
  final repo = ref.watch(chapterRepositoryProvider);
  return await repo.getChapters();
});

// Single Chapter Provider
final chapterDetailProvider = FutureProvider.family<Chapter?, int>((ref, chapterNumber) async {
  final repo = ref.watch(chapterRepositoryProvider);
  return await repo.getChapterByNumber(chapterNumber);
});

// Verses for Chapter Provider
final versesForChapterProvider = FutureProvider.family<List<Verse>, int>((ref, chapterNumber) async {
  final repo = ref.watch(verseRepositoryProvider);
  return await repo.getVersesForChapter(chapterNumber);
});

// Daily Verse Provider (Changes every day according to calendar date)
final dailyVerseProvider = FutureProvider<Verse?>((ref) async {
  final repo = ref.watch(verseRepositoryProvider);
  return await repo.getDailyVerse();
});

// Bookmarks List Notifier
class BookmarksNotifier extends StateNotifier<AsyncValue<List<Bookmark>>> {
  final BookmarkRepository _repo;

  BookmarksNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repo.getBookmarks();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleBookmark(int chapterNumber, int verseNumber) async {
    final isMarked = await _repo.isBookmarked(chapterNumber, verseNumber);
    if (isMarked) {
      await _repo.removeBookmark(chapterNumber, verseNumber);
    } else {
      await _repo.addBookmark(chapterNumber, verseNumber);
    }
    await loadBookmarks();
  }

  Future<void> removeBookmark(int chapterNumber, int verseNumber) async {
    await _repo.removeBookmark(chapterNumber, verseNumber);
    await loadBookmarks();
  }
}

final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, AsyncValue<List<Bookmark>>>((ref) {
  final repo = ref.watch(bookmarkRepositoryProvider);
  return BookmarksNotifier(repo);
});

final isVerseBookmarkedProvider = FutureProvider.family<bool, String>((ref, key) async {
  // key format "chapter:verse"
  final parts = key.split(':');
  if (parts.length != 2) return false;
  final ch = int.tryParse(parts[0]) ?? 1;
  final vr = int.tryParse(parts[1]) ?? 1;
  final repo = ref.watch(bookmarkRepositoryProvider);
  return await repo.isBookmarked(ch, vr);
});

// Reading Progress Notifier
class ReadingProgressNotifier extends StateNotifier<AsyncValue<ReadingProgress>> {
  final ReadingProgressRepository _repo;

  ReadingProgressNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadProgress();
  }

  Future<void> loadProgress() async {
    state = const AsyncValue.loading();
    try {
      final p = await _repo.getProgress();
      state = AsyncValue.data(p);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProgress(int chapter, int verse) async {
    await _repo.saveProgress(chapter, verse);
    state = AsyncValue.data(ReadingProgress(
      lastChapter: chapter,
      lastVerse: verse,
      updatedAt: DateTime.now(),
    ));
  }
}

final readingProgressNotifierProvider =
    StateNotifierProvider<ReadingProgressNotifier, AsyncValue<ReadingProgress>>((ref) {
  final repo = ref.watch(readingProgressRepositoryProvider);
  return ReadingProgressNotifier(repo);
});

// User Settings Notifier
class SettingsNotifier extends StateNotifier<UserSettings> {
  final SettingsRepository _repo;

  SettingsNotifier(this._repo) : super(const UserSettings()) {
    _init();
  }

  Future<void> _init() async {
    final s = await _repo.getSettings();
    state = s;
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    await _repo.updateFontSize(size);
  }

  Future<void> setThemeMode(String mode) async {
    ReadingBackgroundMode newBg = state.readingBackground;
    if (mode == 'dark') {
      newBg = ReadingBackgroundMode.dark;
    } else if (mode == 'light' && newBg == ReadingBackgroundMode.dark) {
      newBg = ReadingBackgroundMode.parchment;
    }
    state = state.copyWith(
      themeMode: mode,
      readingBackground: newBg,
    );
    await _repo.updateThemeMode(mode);
    await _repo.updateReadingBackground(newBg);
  }

  Future<void> setReadingBackground(ReadingBackgroundMode mode) async {
    final newThemeMode = (mode == ReadingBackgroundMode.dark) ? 'dark' : 'light';
    state = state.copyWith(
      readingBackground: mode,
      themeMode: newThemeMode,
    );
    await _repo.updateReadingBackground(mode);
    await _repo.updateThemeMode(newThemeMode);
  }

  Future<void> reset() async {
    await _repo.resetSettings();
    state = const UserSettings();
  }
}

final userSettingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});

