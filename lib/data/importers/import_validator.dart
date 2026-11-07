import '../../core/constants/app_constants.dart';

class ValidationResult {
  final bool isValid;
  final int totalCount;
  final List<String> errors;
  final List<String> warnings;
  final Map<int, int> chapterVerseCounts;

  const ValidationResult({
    required this.isValid,
    required this.totalCount,
    required this.errors,
    required this.warnings,
    required this.chapterVerseCounts,
  });

  bool get isCompleteCoverage => totalCount == AppConstants.totalVerses && errors.isEmpty;
}

class ImportValidator {
  /// Validates a list of verse maps according to the strict canonical guidelines
  static ValidationResult validate(List<dynamic> rawList) {
    final List<String> errors = [];
    final List<String> warnings = [];
    final Set<String> seenCoordinates = {};
    final Map<int, int> counts = {};

    for (int i = 0; i < rawList.length; i++) {
      final item = rawList[i];
      if (item is! Map) {
        errors.add('Item at index $i is not a valid JSON map');
        continue;
      }

      final chapter = item['chapter'] ?? item['chapter_number'];
      final verse = item['verse'] ?? item['verse_number'];

      // 1. Chapter number validation (1 to 18)
      if (chapter == null || chapter is! int) {
        errors.add('Item at index $i: Missing or invalid "chapter" field');
        continue;
      }
      if (chapter < 1 || chapter > AppConstants.totalChapters) {
        errors.add('Item at index $i: Chapter $chapter is outside the valid range 1-18');
        continue;
      }

      // 2. Verse number validation
      if (verse == null || verse is! int) {
        errors.add('Item at index $i: Missing or invalid "verse" field in Chapter $chapter');
        continue;
      }
      final maxVerses = AppConstants.chapterVerseCounts[chapter] ?? 1;
      if (verse < 1 || verse > maxVerses) {
        errors.add('Item at index $i: Verse $verse is outside canonical range 1-$maxVerses for Chapter $chapter');
      }

      // 3. Unique chapter/verse combination
      final coord = '$chapter:$verse';
      if (seenCoordinates.contains(coord)) {
        errors.add('Duplicate verse found for coordinate BG $chapter.$verse at index $i');
      } else {
        seenCoordinates.add(coord);
        counts[chapter] = (counts[chapter] ?? 0) + 1;
      }

      // 4. Required fields presence and content
      final sanskrit = item['sanskrit'] as String?;
      final transliteration = item['transliteration'] as String?;
      final synonyms = item['synonyms'] as String?;
      final translation = item['translation'] as String?;
      final purport = item['purport'] as String?;

      if (sanskrit == null || sanskrit.trim().isEmpty) {
        errors.add('BG $chapter.$verse: Missing or empty "sanskrit" text');
      } else {
        // 5. Unicode Devanagari validation check
        final hasDevanagari = RegExp(r'[\u0900-\u097F]').hasMatch(sanskrit);
        if (!hasDevanagari) {
          warnings.add('BG $chapter.$verse: "sanskrit" does not seem to contain Devanagari Unicode characters');
        }
      }

      if (transliteration == null || transliteration.trim().isEmpty) {
        errors.add('BG $chapter.$verse: Missing or empty "transliteration" text');
      }

      if (synonyms == null || synonyms.trim().isEmpty) {
        errors.add('BG $chapter.$verse: Missing or empty "synonyms" text');
      }

      if (translation == null || translation.trim().isEmpty) {
        errors.add('BG $chapter.$verse: Missing or empty "translation" text');
      }

      if (purport == null || purport.trim().isEmpty) {
        warnings.add('BG $chapter.$verse: Purport is empty or absent');
      }
    }

    // Check complete coverage
    for (int ch = 1; ch <= AppConstants.totalChapters; ch++) {
      final expected = AppConstants.chapterVerseCounts[ch] ?? 0;
      final actual = counts[ch] ?? 0;
      if (actual < expected) {
        warnings.add('Chapter $ch has $actual/$expected verses loaded.');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      totalCount: seenCoordinates.length,
      errors: errors,
      warnings: warnings,
      chapterVerseCounts: counts,
    );
  }
}

