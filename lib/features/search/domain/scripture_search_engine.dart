import 'dart:math';
import '../../../data/models/verse.dart';

enum SearchMatchCategory {
  verseReference,
  sanskrit,
  transliteration,
  translation,
  synonyms,
  purport,
}

class SearchMatchResult {
  final Verse verse;
  final SearchMatchCategory category;
  final String matchSnippet;
  final int score;
  final List<String> highlightTerms;

  const SearchMatchResult({
    required this.verse,
    required this.category,
    required this.matchSnippet,
    required this.score,
    required this.highlightTerms,
  });

  String get categoryLabel {
    switch (category) {
      case SearchMatchCategory.verseReference:
        return 'Exact Verse';
      case SearchMatchCategory.sanskrit:
        return 'Sanskrit Sloka';
      case SearchMatchCategory.transliteration:
        return 'Transliteration';
      case SearchMatchCategory.translation:
        return 'Translation';
      case SearchMatchCategory.synonyms:
        return 'Synonyms';
      case SearchMatchCategory.purport:
        return 'Purport';
    }
  }
}

class ScriptureSearchEngine {
  /// Normalizes Devanagari text by standardizing phonetic variants,
  /// conjunct nasals, visargas, and stripping punctuation.
  static String normalizeDevanagari(String text) {
    if (text.isEmpty) return '';
    var t = text;

    // Normalize ASCII colon to Devanagari visarga
    t = t.replaceAll(':', 'ः');

    // Normalize 'छ' / 'च्छ' variants into 'क्ष' (e.g. धर्मच्छेत्रे -> धर्मक्षेत्रे)
    t = t.replaceAll('च्छ', 'क्ष').replaceAll('छ', 'क्ष');

    // Normalize conjunct nasals before consonants into anusvara (e.g. सञ्जय -> संजय)
    t = t.replaceAll(RegExp(r'[ङञणनम]्'), 'ं');

    // Normalize ज्ञ into ग्य
    t = t.replaceAll('ज्ञ', 'ग्य');

    // Normalize sibilants श, ष to standard स for phonetic tolerance
    t = t.replaceAll('ष', 'श').replaceAll('स', 'श');

    // Remove dandas, punctuation, hyphens, and whitespace
    t = t.replaceAll(RegExp(r'[।॥\-\s\n\r,\.\?:;!\(\)\[\]]'), '');

    return t;
  }

  /// Normalizes Roman transliteration by stripping diacritics, hyphens, and punctuation
  /// (e.g. 'dharma-kṣetre' -> 'dharmaksetre', 'kṛṣṇa' -> 'krishna' / 'krsna')
  static String normalizeRoman(String text) {
    if (text.isEmpty) return '';
    var t = text.toLowerCase();

    // Map IAST diacritics
    const diacriticMap = {
      'ā': 'a',
      'ī': 'i',
      'ū': 'u',
      'ṛ': 'ri',
      'ṝ': 'ri',
      'ḷ': 'l',
      'ḹ': 'l',
      'ṅ': 'n',
      'ñ': 'n',
      'ṇ': 'n',
      'ṭ': 't',
      'ḍ': 'd',
      'ś': 'sh',
      'ṣ': 'sh',
      'ṁ': 'm',
      'ḥ': 'h',
    };

    diacriticMap.forEach((k, v) {
      t = t.replaceAll(k, v);
    });

    // Remove hyphens, spaces, punctuation
    t = t.replaceAll(RegExp(r'''[\-\s\n\r,\.\?:;!\(\)\[\]"'\u2018\u2019\u201c\u201d]'''), '');

    return t;
  }

  /// Normalizes plain English text for translation/purport search
  static String normalizeEnglish(String text) {
    if (text.isEmpty) return '';
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'''[\-\s\n\r,\.\?:;!\(\)\[\]"'\u2018\u2019\u201c\u201d]'''), '');
  }

  /// Extracts an excerpt around the match for clean presentation
  static String extractExcerpt(String fullText, String query, {int radius = 60}) {
    if (fullText.isEmpty) return '';
    final lowerText = fullText.toLowerCase();
    final lowerQuery = query.toLowerCase();

    int index = lowerText.indexOf(lowerQuery);
    if (index == -1) {
      // Try searching for individual query words
      final words = query.toLowerCase().split(RegExp(r'\s+')).where((w) => w.length >= 3);
      for (final w in words) {
        index = lowerText.indexOf(w);
        if (index != -1) break;
      }
    }

    if (index == -1) {
      return fullText.length > (radius * 2)
          ? '${fullText.substring(0, radius * 2).trim()}...'
          : fullText.trim();
    }

    final start = max(0, index - radius);
    final end = min(fullText.length, index + query.length + radius);

    var snippet = fullText.substring(start, end).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (start > 0) snippet = '...$snippet';
    if (end < fullText.length) snippet = '$snippet...';

    return snippet;
  }

  /// Performs an intelligent multi-layered search across all verses
  static List<SearchMatchResult> search({
    required List<Verse> allVerses,
    required String query,
    int maxResults = 50,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final results = <SearchMatchResult>[];

    // 1. Check for specific Chapter & Verse format: e.g. "4.7", "BG 4.7", "4:7", "4 7", "4,7", "chapter 4 verse 7"
    final verseRefRegex = RegExp(
      r'^(?:BG|chapter|ch)?\s*(\d{1,2})(?:[.:,\s]+(?:verse|v)?\s*(\d{1,2}))?$',
      caseSensitive: false,
    );
    final match = verseRefRegex.firstMatch(trimmed);

    if (match != null) {
      final ch = int.tryParse(match.group(1) ?? '');
      final vr = int.tryParse(match.group(2) ?? '');

      if (ch != null && ch >= 1 && ch <= 18) {
        if (vr != null && vr >= 1) {
          // Exact coordinate match
          final exact = allVerses.where((v) => v.chapterNumber == ch && v.verseNumber == vr).toList();
          if (exact.isNotEmpty) {
            return [
              SearchMatchResult(
                verse: exact.first,
                category: SearchMatchCategory.verseReference,
                matchSnippet: exact.first.translation,
                score: 10000,
                highlightTerms: [exact.first.reference],
              )
            ];
          }
        } else if (vr == null) {
          // Chapter number search: return all verses of that chapter
          final chVerses = allVerses.where((v) => v.chapterNumber == ch).toList();
          return chVerses
              .map(
                (v) => SearchMatchResult(
                  verse: v,
                  category: SearchMatchCategory.verseReference,
                  matchSnippet: v.translation,
                  score: 5000 - v.verseNumber,
                  highlightTerms: ['Chapter $ch', v.reference],
                ),
              )
              .toList();
        }
      }
    }

    // 2. Prepare normalized query variants
    final rawLower = trimmed.toLowerCase();
    final normDevaQuery = normalizeDevanagari(trimmed);
    final normRomanQuery = normalizeRoman(trimmed);
    final normEngQuery = normalizeEnglish(trimmed);

    // Distinct search keywords (for multi-word queries)
    final words = trimmed
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .map((w) => w.trim())
        .toList();

    for (final verse in allVerses) {
      int score = 0;
      SearchMatchCategory? bestCategory;
      String matchSnippet = '';
      final matchedTerms = <String>[];

      // A. Sanskrit Devanagari matching
      final normDevaSanskrit = normalizeDevanagari(verse.sanskrit);
      if (verse.sanskrit.contains(trimmed)) {
        score += 2000;
        bestCategory = SearchMatchCategory.sanskrit;
        matchSnippet = verse.sanskrit;
        matchedTerms.add(trimmed);
      } else if (normDevaQuery.isNotEmpty && normDevaSanskrit.contains(normDevaQuery)) {
        score += 1500;
        bestCategory = SearchMatchCategory.sanskrit;
        matchSnippet = verse.sanskrit;
        matchedTerms.add(trimmed);
      } else if (normDevaQuery.length >= 3) {
        // Multi-word / partial Devanagari
        int subCount = 0;
        for (final w in words) {
          final nw = normalizeDevanagari(w);
          if (nw.isNotEmpty && normDevaSanskrit.contains(nw)) {
            subCount++;
          }
        }
        if (subCount > 0) {
          score += 800 * subCount;
          bestCategory = SearchMatchCategory.sanskrit;
          matchSnippet = verse.sanskrit;
          matchedTerms.addAll(words);
        }
      }

      // B. Roman Transliteration matching
      final normRomanTrans = normalizeRoman(verse.transliteration);
      if (verse.transliteration.toLowerCase().contains(rawLower)) {
        const currentScore = 1800;
        if (currentScore > score) {
          score = currentScore;
          bestCategory = SearchMatchCategory.transliteration;
          matchSnippet = verse.transliteration;
          matchedTerms.add(trimmed);
        }
      } else if (normRomanQuery.isNotEmpty && normRomanTrans.contains(normRomanQuery)) {
        const currentScore = 1400;
        if (currentScore > score) {
          score = currentScore;
          bestCategory = SearchMatchCategory.transliteration;
          matchSnippet = verse.transliteration;
          matchedTerms.add(trimmed);
        }
      } else if (normRomanQuery.length >= 3) {
        int subCount = 0;
        for (final w in words) {
          final nw = normalizeRoman(w);
          if (nw.isNotEmpty && normRomanTrans.contains(nw)) {
            subCount++;
          }
        }
        if (subCount > 0) {
          final currentScore = 700 * subCount;
          if (currentScore > score) {
            score = currentScore;
            bestCategory = SearchMatchCategory.transliteration;
            matchSnippet = verse.transliteration;
            matchedTerms.addAll(words);
          }
        }
      }

      // C. English Translation matching
      final transLower = verse.translation.toLowerCase();
      if (transLower.contains(rawLower)) {
        const currentScore = 1200;
        if (currentScore > score) {
          score = currentScore;
          bestCategory = SearchMatchCategory.translation;
          matchSnippet = extractExcerpt(verse.translation, trimmed);
          matchedTerms.add(trimmed);
        } else {
          score += 200; // Bonus for multi-field match
        }
      } else if (normEngQuery.isNotEmpty && normalizeEnglish(verse.translation).contains(normEngQuery)) {
        const currentScore = 1000;
        if (currentScore > score) {
          score = currentScore;
          bestCategory = SearchMatchCategory.translation;
          matchSnippet = extractExcerpt(verse.translation, trimmed);
          matchedTerms.add(trimmed);
        }
      } else {
        int wordMatch = 0;
        for (final w in words) {
          if (w.length >= 3 && transLower.contains(w.toLowerCase())) {
            wordMatch++;
          }
        }
        if (wordMatch > 0) {
          final currentScore = 400 * wordMatch;
          if (currentScore > score) {
            score = currentScore;
            bestCategory = SearchMatchCategory.translation;
            matchSnippet = extractExcerpt(verse.translation, words.first);
            matchedTerms.addAll(words);
          }
        }
      }

      // D. Synonyms matching
      final synLower = verse.synonyms.toLowerCase();
      if (synLower.contains(rawLower) || (normRomanQuery.isNotEmpty && normalizeRoman(verse.synonyms).contains(normRomanQuery))) {
        const currentScore = 800;
        if (currentScore > score) {
          score = currentScore;
          bestCategory = SearchMatchCategory.synonyms;
          matchSnippet = extractExcerpt(verse.synonyms, trimmed);
          matchedTerms.add(trimmed);
        } else {
          score += 150;
        }
      }

      // E. Purport matching
      final purportLower = verse.purport.toLowerCase();
      if (purportLower.contains(rawLower)) {
        const currentScore = 500;
        if (currentScore > score) {
          score = currentScore;
          bestCategory = SearchMatchCategory.purport;
          matchSnippet = extractExcerpt(verse.purport, trimmed);
          matchedTerms.add(trimmed);
        } else {
          score += 100;
        }
      }

      if (score > 0 && bestCategory != null) {
        results.add(
          SearchMatchResult(
            verse: verse,
            category: bestCategory,
            matchSnippet: matchSnippet.isNotEmpty ? matchSnippet : verse.translation,
            score: score,
            highlightTerms: matchedTerms.isNotEmpty ? matchedTerms : [trimmed],
          ),
        );
      }
    }

    // Sort by relevance score descending, then by chapter & verse ascending
    results.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      final chCompare = a.verse.chapterNumber.compareTo(b.verse.chapterNumber);
      if (chCompare != 0) return chCompare;
      return a.verse.verseNumber.compareTo(b.verse.verseNumber);
    });

    if (results.length > maxResults) {
      return results.sublist(0, maxResults);
    }

    return results;
  }
}
