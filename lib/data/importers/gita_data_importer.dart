import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../database/app_database.dart';
import 'import_validator.dart';

class GitaDataImporter {
  final AppDatabase _db;

  GitaDataImporter([AppDatabase? db]) : _db = db ?? AppDatabase.instance;

  /// Imports authorized JSON string, validates every entry, and writes to SQLite
  Future<ValidationResult> importFromJsonString(String jsonContent) async {
    final dynamic decoded = json.decode(jsonContent);
    if (decoded is! List) {
      return const ValidationResult(
        isValid: false,
        totalCount: 0,
        errors: ['Top-level JSON structure must be an array of verse objects.'],
        warnings: [],
        chapterVerseCounts: {},
      );
    }

    final validation = ImportValidator.validate(decoded);
    if (!validation.isValid) {
      return validation;
    }

    final db = await _db.database;
    final batch = db.batch();

    for (var item in decoded) {
      final ch = item['chapter'] ?? item['chapter_number'];
      final vr = item['verse'] ?? item['verse_number'];

      batch.insert(
        'verses',
        {
          'chapter_number': ch,
          'verse_number': vr,
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
    return validation;
  }
}

