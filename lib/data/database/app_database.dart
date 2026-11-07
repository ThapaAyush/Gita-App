import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../features/search/domain/scripture_search_engine.dart';
import '../models/chapter.dart';
import '../models/verse.dart';
import '../models/bookmark.dart';
import '../models/reading_progress.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bhagavad_gita_as_it_is.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chapters (
        id INTEGER PRIMARY KEY,
        chapter_number INTEGER NOT NULL UNIQUE,
        title TEXT NOT NULL,
        introduction TEXT,
        verse_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_number INTEGER NOT NULL,
        verse_number INTEGER NOT NULL,
        sanskrit TEXT NOT NULL,
        transliteration TEXT NOT NULL,
        synonyms TEXT NOT NULL,
        translation TEXT NOT NULL,
        purport TEXT NOT NULL,
        UNIQUE(chapter_number, verse_number)
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chapter_number INTEGER NOT NULL,
        verse_number INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(chapter_number, verse_number)
      )
    ''');

    await db.execute('''
      CREATE TABLE reading_progress (
        id INTEGER PRIMARY KEY,
        last_chapter INTEGER NOT NULL,
        last_verse INTEGER NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY,
        font_size REAL NOT NULL DEFAULT 17.0,
        theme_mode TEXT NOT NULL DEFAULT 'light',
        reading_background TEXT NOT NULL DEFAULT 'parchment'
      )
    ''');

    // Create indexes for instant offline search and fast lookups
    await db.execute('CREATE INDEX idx_verses_lookup ON verses(chapter_number, verse_number)');
    await db.execute('CREATE INDEX idx_bookmarks_lookup ON bookmarks(chapter_number, verse_number)');

    // Seed initial progress and default settings
    await db.insert('reading_progress', {
      'id': 1,
      'last_chapter': 1,
      'last_verse': 1,
      'updated_at': DateTime.now().toIso8601String(),
    });

    await db.insert('user_settings', {
      'id': 1,
      'font_size': 17.0,
      'theme_mode': 'light',
      'reading_background': 'parchment',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration hook for future revisions
  }

  /// Seeds chapters and initial verses from bundled asset files if empty
  Future<void> seedDatabaseIfNeeded() async {
    final db = await database;
    
    // Check if chapters table is seeded
    final chapterCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM chapters'),
    ) ?? 0;

    if (chapterCount < AppConstants.totalChapters) {
      try {
        final chaptersString = await rootBundle.loadString(AppConstants.chaptersJsonPath);
        final List<dynamic> chaptersList = json.decode(chaptersString);
        final batch = db.batch();
        for (var item in chaptersList) {
          batch.insert(
            'chapters',
            {
              'id': item['chapter_number'],
              'chapter_number': item['chapter_number'],
              'title': item['title'],
              'introduction': item['introduction'],
              'verse_count': item['verse_count'] ?? AppConstants.chapterVerseCounts[item['chapter_number']] ?? 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
      } catch (e) {
        // Fallback for standalone/test environments
        final batch = db.batch();
        AppConstants.chapterVerseCounts.forEach((chNum, count) {
          batch.insert(
            'chapters',
            {
              'id': chNum,
              'chapter_number': chNum,
              'title': 'Chapter $chNum',
              'introduction': 'Wisdom of Chapter $chNum',
              'verse_count': count,
            },
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        });
        await batch.commit(noResult: true);
      }
    }

    // Check if verses table has content
    final verseCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM verses'),
    ) ?? 0;
    debugPrint('Current verseCount in database: $verseCount');

    if (verseCount < 700) {
      try {
        debugPrint('Seeding verses from ${AppConstants.seedJsonPath}...');
        final seedString = await rootBundle.loadString(AppConstants.seedJsonPath);
        final List<dynamic> verseList = json.decode(seedString);
        debugPrint('Loaded ${verseList.length} verses from JSON. Writing to SQLite...');
        final batch = db.batch();
        for (var item in verseList) {
          batch.insert(
            'verses',
            {
              'chapter_number': item['chapter'] ?? item['chapter_number'],
              'verse_number': item['verse'] ?? item['verse_number'],
              'sanskrit': item['sanskrit'] ?? '',
              'transliteration': item['transliteration'] ?? '',
              'synonyms': item['synonyms'] ?? '',
              'translation': item['translation'] ?? '',
              'purport': item['purport'] ?? '',
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await batch.commit(noResult: true);
        final newCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM verses'),
        ) ?? 0;
        debugPrint('Successfully seeded verses! New count: $newCount');
      } catch (e, stack) {
        debugPrint('Error seeding verses: $e\n$stack');
      }
    }
  }

  // Chapter Queries
  Future<List<Chapter>> getAllChapters() async {
    final db = await database;
    final maps = await db.query('chapters', orderBy: 'chapter_number ASC');
    return maps.map((map) => Chapter.fromMap(map)).toList();
  }

  Future<Chapter?> getChapter(int chapterNumber) async {
    final db = await database;
    final maps = await db.query(
      'chapters',
      where: 'chapter_number = ?',
      whereArgs: [chapterNumber],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Chapter.fromMap(maps.first);
    }
    return null;
  }

  // Verse Queries
  Future<Verse?> getVerse(int chapterNumber, int verseNumber) async {
    final db = await database;
    final maps = await db.query(
      'verses',
      where: 'chapter_number = ? AND verse_number = ?',
      whereArgs: [chapterNumber, verseNumber],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Verse.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Verse>> getVersesForChapter(int chapterNumber) async {
    final db = await database;
    final maps = await db.query(
      'verses',
      where: 'chapter_number = ?',
      whereArgs: [chapterNumber],
      orderBy: 'verse_number ASC',
    );
    return maps.map((map) => Verse.fromMap(map)).toList();
  }

  /// Retrieves the Daily Verse based on the calendar date
  Future<Verse?> getDailyVerse([DateTime? targetDate]) async {
    final db = await database;
    final maps = await db.query('verses', orderBy: 'chapter_number ASC, verse_number ASC');
    if (maps.isEmpty) return null;
    final date = targetDate ?? DateTime.now();
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(startOfYear).inDays;
    final calendarSeed = (date.year * 365) + dayOfYear;
    final index = calendarSeed % maps.length;
    return Verse.fromMap(maps[index]);
  }

  /// Calculates previous verse coordinates with chapter boundary navigation
  Future<Map<String, int>?> getPreviousVerseCoordinate(int chapterNumber, int verseNumber) async {
    if (verseNumber > 1) {
      return {'chapter': chapterNumber, 'verse': verseNumber - 1};
    }
    if (chapterNumber > 1) {
      final prevChapter = chapterNumber - 1;
      final maxVerse = AppConstants.chapterVerseCounts[prevChapter] ?? 1;
      return {'chapter': prevChapter, 'verse': maxVerse};
    }
    return null; // Already at BG 1.1
  }

  /// Calculates next verse coordinates with chapter boundary navigation
  Future<Map<String, int>?> getNextVerseCoordinate(int chapterNumber, int verseNumber) async {
    final totalInChapter = AppConstants.chapterVerseCounts[chapterNumber] ?? 1;
    if (verseNumber < totalInChapter) {
      return {'chapter': chapterNumber, 'verse': verseNumber + 1};
    }
    if (chapterNumber < AppConstants.totalChapters) {
      return {'chapter': chapterNumber + 1, 'verse': 1};
    }
    return null; // Already at BG 18.78
  }

  // Bookmark Operations
  Future<void> addBookmark(int chapterNumber, int verseNumber) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      {
        'chapter_number': chapterNumber,
        'verse_number': verseNumber,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeBookmark(int chapterNumber, int verseNumber) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'chapter_number = ? AND verse_number = ?',
      whereArgs: [chapterNumber, verseNumber],
    );
  }

  Future<bool> isBookmarked(int chapterNumber, int verseNumber) async {
    final db = await database;
    final maps = await db.query(
      'bookmarks',
      where: 'chapter_number = ? AND verse_number = ?',
      whereArgs: [chapterNumber, verseNumber],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<List<Bookmark>> getAllBookmarks() async {
    final db = await database;
    const query = '''
      SELECT b.id, b.chapter_number, b.verse_number, b.created_at, v.translation
      FROM bookmarks b
      LEFT JOIN verses v ON b.chapter_number = v.chapter_number AND b.verse_number = v.verse_number
      ORDER BY b.id DESC
    ''';
    final maps = await db.rawQuery(query);
    return maps.map((map) => Bookmark.fromMap(map)).toList();
  }

  // Reading Progress Persistence
  Future<ReadingProgress> getReadingProgress() async {
    final db = await database;
    final maps = await db.query('reading_progress', where: 'id = 1', limit: 1);
    if (maps.isNotEmpty) {
      return ReadingProgress.fromMap(maps.first);
    }
    return ReadingProgress(
      lastChapter: 1,
      lastVerse: 1,
      updatedAt: DateTime.now(),
    );
  }

  Future<void> saveReadingProgress(int chapterNumber, int verseNumber) async {
    final db = await database;
    await db.insert(
      'reading_progress',
      {
        'id': 1,
        'last_chapter': chapterNumber,
        'last_verse': verseNumber,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Verse>> getAllVerses() async {
    final db = await database;
    final maps = await db.query(
      'verses',
      orderBy: 'chapter_number ASC, verse_number ASC',
    );
    return maps.map((map) => Verse.fromMap(map)).toList();
  }

  // Offline Search Implementation with ScriptureSearchEngine
  Future<List<Verse>> searchVerses(String query) async {
    if (query.trim().isEmpty) return [];
    final all = await getAllVerses();
    final matches = ScriptureSearchEngine.search(allVerses: all, query: query);
    return matches.map((m) => m.verse).toList();
  }

  Future<List<SearchMatchResult>> searchAdvanced(String query) async {
    if (query.trim().isEmpty) return [];
    final all = await getAllVerses();
    return ScriptureSearchEngine.search(allVerses: all, query: query);
  }

  // Close Database
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
