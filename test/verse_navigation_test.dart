import 'package:flutter_test/flutter_test.dart';
import 'package:bhagavad_gita_as_it_is/data/database/app_database.dart';

void main() {
  group('Chapter & Verse Boundary Navigation Tests', () {
    final db = AppDatabase.instance;

    test('At BG 1.1, previous verse coordinate should be null', () async {
      final prev = await db.getPreviousVerseCoordinate(1, 1);
      expect(prev, isNull);
    });

    test('At BG 1.2, previous verse should be BG 1.1', () async {
      final prev = await db.getPreviousVerseCoordinate(1, 2);
      expect(prev, isNotNull);
      expect(prev!['chapter'], equals(1));
      expect(prev['verse'], equals(1));
    });

    test('At BG 2.1, previous verse should cross boundary into BG 1.47', () async {
      final prev = await db.getPreviousVerseCoordinate(2, 1);
      expect(prev, isNotNull);
      expect(prev!['chapter'], equals(1));
      expect(prev['verse'], equals(47)); // Chapter 1 has 47 verses
    });

    test('At BG 1.47, next verse should cross boundary into BG 2.1', () async {
      final next = await db.getNextVerseCoordinate(1, 47);
      expect(next, isNotNull);
      expect(next!['chapter'], equals(2));
      expect(next['verse'], equals(1));
    });

    test('At BG 2.72, next verse should cross boundary into BG 3.1', () async {
      final next = await db.getNextVerseCoordinate(2, 72);
      expect(next, isNotNull);
      expect(next!['chapter'], equals(3));
      expect(next['verse'], equals(1));
    });

    test('At BG 18.78 (final verse of Bhagavad Gita), next verse should be null', () async {
      final next = await db.getNextVerseCoordinate(18, 78);
      expect(next, isNull);
    });
  });
}
