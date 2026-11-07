import '../database/app_database.dart';
import '../models/chapter.dart';

abstract class ChapterRepository {
  Future<List<Chapter>> getChapters();
  Future<Chapter?> getChapterByNumber(int chapterNumber);
}

class SqliteChapterRepository implements ChapterRepository {
  final AppDatabase _db;

  SqliteChapterRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  @override
  Future<List<Chapter>> getChapters() async {
    return await _db.getAllChapters();
  }

  @override
  Future<Chapter?> getChapterByNumber(int chapterNumber) async {
    return await _db.getChapter(chapterNumber);
  }
}

