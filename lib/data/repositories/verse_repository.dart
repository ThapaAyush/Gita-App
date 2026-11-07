import '../../features/search/domain/scripture_search_engine.dart';
import '../database/app_database.dart';
import '../models/verse.dart';

abstract class VerseRepository {
  Future<Verse?> getVerse(int chapterNumber, int verseNumber);
  Future<List<Verse>> getVersesForChapter(int chapterNumber);
  Future<Map<String, int>?> getPreviousCoordinates(int chapterNumber, int verseNumber);
  Future<Map<String, int>?> getNextCoordinates(int chapterNumber, int verseNumber);
  Future<List<Verse>> search(String query);
  Future<List<SearchMatchResult>> searchAdvanced(String query);
  Future<Verse?> getDailyVerse([DateTime? date]);
}

class SqliteVerseRepository implements VerseRepository {
  final AppDatabase _db;
  List<Verse>? _cachedVerses;

  SqliteVerseRepository([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  Future<List<Verse>> _getOrLoadAllVerses() async {
    if (_cachedVerses != null && _cachedVerses!.isNotEmpty) {
      return _cachedVerses!;
    }
    _cachedVerses = await _db.getAllVerses();
    return _cachedVerses!;
  }

  @override
  Future<Verse?> getVerse(int chapterNumber, int verseNumber) async {
    return await _db.getVerse(chapterNumber, verseNumber);
  }

  @override
  Future<List<Verse>> getVersesForChapter(int chapterNumber) async {
    return await _db.getVersesForChapter(chapterNumber);
  }

  @override
  Future<Map<String, int>?> getPreviousCoordinates(int chapterNumber, int verseNumber) async {
    return await _db.getPreviousVerseCoordinate(chapterNumber, verseNumber);
  }

  @override
  Future<Map<String, int>?> getNextCoordinates(int chapterNumber, int verseNumber) async {
    return await _db.getNextVerseCoordinate(chapterNumber, verseNumber);
  }

  @override
  Future<List<SearchMatchResult>> searchAdvanced(String query) async {
    final all = await _getOrLoadAllVerses();
    return ScriptureSearchEngine.search(allVerses: all, query: query);
  }

  @override
  Future<List<Verse>> search(String query) async {
    final matches = await searchAdvanced(query);
    return matches.map((m) => m.verse).toList();
  }

  @override
  Future<Verse?> getDailyVerse([DateTime? date]) async {
    return await _db.getDailyVerse(date);
  }
}

