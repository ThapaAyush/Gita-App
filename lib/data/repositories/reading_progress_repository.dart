import '../database/app_database.dart';
import '../models/reading_progress.dart';

abstract class ReadingProgressRepository {
  Future<ReadingProgress> getProgress();
  Future<void> saveProgress(int chapterNumber, int verseNumber);
}

class SqliteReadingProgressRepository implements ReadingProgressRepository {
  final AppDatabase _db;

  SqliteReadingProgressRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  @override
  Future<ReadingProgress> getProgress() async {
    return await _db.getReadingProgress();
  }

  @override
  Future<void> saveProgress(int chapterNumber, int verseNumber) async {
    await _db.saveReadingProgress(chapterNumber, verseNumber);
  }
}

