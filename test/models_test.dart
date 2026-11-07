import 'package:flutter_test/flutter_test.dart';
import 'package:bhagavad_gita_as_it_is/data/models/chapter.dart';
import 'package:bhagavad_gita_as_it_is/data/models/verse.dart';
import 'package:bhagavad_gita_as_it_is/data/models/bookmark.dart';
import 'package:bhagavad_gita_as_it_is/data/models/reading_progress.dart';

void main() {
  group('Models & Serialization Unit Tests', () {
    test('Verse model formats reference correctly and preserves Unicode', () {
      const verse = Verse(
        chapterNumber: 2,
        verseNumber: 13,
        sanskrit: 'देहिनोऽस्मिन्यथा देहे कौमारं यौवनं जरा |',
        transliteration: "dehino 'smin yathā dehe",
        synonyms: "dehinaḥ — of the embodied;",
        translation: "As the embodied soul continuously passes...",
        purport: "Since every living entity is an individual soul...",
      );

      expect(verse.reference, equals('BG 2.13'));
      expect(verse.sanskrit, contains('देहिनोऽस्मिन्यथा'));
      expect(verse.transliteration, contains('yathā'));

      final map = verse.toMap();
      expect(map['chapter_number'], equals(2));
      expect(map['verse_number'], equals(13));

      final fromMap = Verse.fromMap(map);
      expect(fromMap.reference, equals('BG 2.13'));
      expect(fromMap.sanskrit, equals(verse.sanskrit));
    });

    test('Chapter model properly parses map and JSON', () {
      final jsonMap = {
        'chapter_number': 1,
        'title': 'Observing the Armies on the Battlefield of Kurukshetra',
        'introduction': 'As the opposing armies stand poised...',
        'verse_count': 47,
      };

      final chapter = Chapter.fromJson(jsonMap);
      expect(chapter.chapterNumber, equals(1));
      expect(chapter.title, contains('Kurukshetra'));
      expect(chapter.verseCount, equals(47));
    });

    test('Bookmark model correctly references verse and formats timestamps', () {
      final now = DateTime.now();
      final bookmark = Bookmark(
        id: 1,
        chapterNumber: 9,
        verseNumber: 22,
        createdAt: now,
        translationPreview: 'But those who always worship Me with exclusive devotion...',
      );

      expect(bookmark.reference, equals('BG 9.22'));
      final map = bookmark.toMap();
      expect(map['chapter_number'], equals(9));
      expect(map['verse_number'], equals(22));
    });

    test('ReadingProgress records position accurately', () {
      final progress = ReadingProgress(
        lastChapter: 3,
        lastVerse: 36,
        updatedAt: DateTime.now(),
      );

      expect(progress.reference, equals('BG 3.36'));
      expect(progress.lastChapter, equals(3));
      expect(progress.lastVerse, equals(36));
    });
  });
}

