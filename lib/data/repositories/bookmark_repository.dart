import '../database/app_database.dart';
import '../models/bookmark.dart';

abstract class BookmarkRepository {
  Future<List<Bookmark>> getBookmarks();
  Future<bool> isBookmarked(int chapterNumber, int verseNumber);
  Future<void> addBookmark(int chapterNumber, int verseNumber);
  Future<void> removeBookmark(int chapterNumber, int verseNumber);
}

class SqliteBookmarkRepository implements BookmarkRepository {
  final AppDatabase _db;

  SqliteBookmarkRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  @override
  Future<List<Bookmark>> getBookmarks() async {
    return await _db.getAllBookmarks();
  }

  @override
  Future<bool> isBookmarked(int chapterNumber, int verseNumber) async {
    return await _db.isBookmarked(chapterNumber, verseNumber);
  }

  @override
  Future<void> addBookmark(int chapterNumber, int verseNumber) async {
    await _db.addBookmark(chapterNumber, verseNumber);
  }

  @override
  Future<void> removeBookmark(int chapterNumber, int verseNumber) async {
    await _db.removeBookmark(chapterNumber, verseNumber);
  }
}

