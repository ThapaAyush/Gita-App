import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhagavad_gita_as_it_is/core/constants/app_constants.dart';
import 'package:bhagavad_gita_as_it_is/data/models/verse.dart';
import 'package:bhagavad_gita_as_it_is/features/search/domain/scripture_search_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Verse> allVerses;

  setUpAll(() async {
    final seedString = await rootBundle.loadString(AppConstants.seedJsonPath);
    final List<dynamic> jsonList = json.decode(seedString);
    allVerses = jsonList.map((item) => Verse.fromJson(item)).toList();
  });

  group('ScriptureSearchEngine Comprehensive Verification Tests', () {
    test('1. Direct verse coordinate search (4.7, BG 4.7, 4:7)', () {
      final res1 = ScriptureSearchEngine.search(allVerses: allVerses, query: '4.7');
      expect(res1.isNotEmpty, isTrue);
      expect(res1.first.verse.chapterNumber, equals(4));
      expect(res1.first.verse.verseNumber, equals(7));

      final res2 = ScriptureSearchEngine.search(allVerses: allVerses, query: 'BG 4.7');
      expect(res2.first.verse.chapterNumber, equals(4));
      expect(res2.first.verse.verseNumber, equals(7));

      final res3 = ScriptureSearchEngine.search(allVerses: allVerses, query: '4:7');
      expect(res3.first.verse.chapterNumber, equals(4));
      expect(res3.first.verse.verseNumber, equals(7));
    });

    test('2. Sanskrit Devanagari exact word search (धर्मक्षेत्रे)', () {
      final results = ScriptureSearchEngine.search(allVerses: allVerses, query: 'धर्मक्षेत्रे');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.verse.chapterNumber, equals(1));
      expect(results.first.verse.verseNumber, equals(1));
      expect(results.first.category, equals(SearchMatchCategory.sanskrit));
    });

    test('3. Sanskrit Devanagari phonetic typo variant (धर्मच्छेत्रे)', () {
      final results = ScriptureSearchEngine.search(allVerses: allVerses, query: 'धर्मच्छेत्रे');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.verse.chapterNumber, equals(1));
      expect(results.first.verse.verseNumber, equals(1));
      expect(results.first.category, equals(SearchMatchCategory.sanskrit));
    });

    test('4. Sanskrit Devanagari nasal conjunct normalization (संजय matches सञ्जय)', () {
      final results = ScriptureSearchEngine.search(allVerses: allVerses, query: 'संजय');
      expect(results.isNotEmpty, isTrue);
      // BG 1.1 and 1.2 feature Sanjaya
      expect(results.any((r) => r.verse.chapterNumber == 1 && r.verse.verseNumber == 1), isTrue);
      expect(results.any((r) => r.verse.chapterNumber == 1 && r.verse.verseNumber == 2), isTrue);
    });

    test('5. Roman transliteration without diacritics (dharmakshetre -> BG 1.1)', () {
      final results = ScriptureSearchEngine.search(allVerses: allVerses, query: 'dharmakshetre');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.verse.chapterNumber, equals(1));
      expect(results.first.verse.verseNumber, equals(1));
    });

    test('6. Famous sloka phrase search (yada yada -> BG 4.7)', () {
      final results = ScriptureSearchEngine.search(allVerses: allVerses, query: 'yada yada');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.verse.chapterNumber, equals(4));
      expect(results.first.verse.verseNumber, equals(7));
    });

    test('7. Famous sloka phrase search (karmanye -> BG 2.47)', () {
      final results = ScriptureSearchEngine.search(allVerses: allVerses, query: 'karmanye');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.verse.chapterNumber, equals(2));
      expect(results.first.verse.verseNumber, equals(47));
    });

    test('8. Final teaching search (sarva dharman -> BG 18.66)', () {
      final results = ScriptureSearchEngine.search(allVerses: allVerses, query: 'sarva dharman');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.verse.chapterNumber, equals(18));
      expect(results.first.verse.verseNumber, equals(66));
    });

    test('9. English translation and philosophical search (disciplic succession)', () {
      final results = ScriptureSearchEngine.search(allVerses: allVerses, query: 'disciplic succession');
      expect(results.isNotEmpty, isTrue);
      expect(results.any((r) => r.verse.chapterNumber == 4 && r.verse.verseNumber == 2), isTrue);
    });
  });
}

